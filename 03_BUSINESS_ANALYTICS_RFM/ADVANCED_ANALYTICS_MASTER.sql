-- =====================================================================================
-- SQL ANALYST TOOLKIT | MODUL 03: FORTGESCHRITTENE ANALYSEN (RFM & KOHORTEN)
-- -------------------------------------------------------------------------------------
-- Datenbank : SupermarktDWH (FrischMarkt GmbH)
-- Ziel      : Auswertungen zu Kundenwert, Loyalität und Kundenbindung (Kohorten)
--             anhand von echten Transaktionsmustern.
-- =====================================================================================

USE SupermarktDWH;
GO

-- =====================================================================================
-- 1. ANWENDUNGSFALL: RFM-Kundensegmentierung (Recency, Frequency, Monetary)
-- -------------------------------------------------------------------------------------
-- Frage des Marketingleiters:
-- "Welche Kundenkarten-Inhaber sind unsere treuesten Champions und welche
--  sind abwanderungsgefährdet und benötigen Reaktivierungs-Gutscheine?"
-- =====================================================================================
WITH KundenBasis AS (
    SELECT 
        k.KundeID,
        CONCAT(k.Vorname, ' ', k.Nachname) AS KundenName,
        k.Email,
        k.Stadt,
        -- Recency: Tage seit dem letzten Einkauf (Stichtag: 30.09.2026)
        DATEDIFF(DAY, MAX(f.BonDatum), '2026-09-30') AS TageSeitLetztemKauf,
        -- Frequency: Anzahl verschiedener Einkaufstage / Bons
        COUNT(DISTINCT f.BonID) AS AnzahlEinkaeufe,
        -- Monetary: Gesamter getätigter Bruttoumsatz
        CAST(SUM(f.UmsatzBrutto) AS DECIMAL(10,2)) AS GesamtUmsatzEUR
    FROM dbo.Kunden k
    JOIN dwh.fct_verkaeufe f ON f.KundeID = k.KundeID
    GROUP BY k.KundeID, k.Vorname, k.Nachname, k.Email, k.Stadt
),
RFM_Scores AS (
    SELECT 
        KundeID,
        KundenName,
        Email,
        Stadt,
        TageSeitLetztemKauf,
        AnzahlEinkaeufe,
        GesamtUmsatzEUR,
        -- NTILE(5) teilt die Kundenmenge in 5 gleich große Quantile (1 = schwach, 5 = top)
        NTILE(5) OVER (ORDER BY TageSeitLetztemKauf DESC) AS R_Score,  -- kürzer her = höhere Punktzahl
        NTILE(5) OVER (ORDER BY AnzahlEinkaeufe ASC)      AS F_Score,
        NTILE(5) OVER (ORDER BY GesamtUmsatzEUR ASC)      AS M_Score
    FROM KundenBasis
),
Segmentiert AS (
    SELECT 
        *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Cell,
        CASE 
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN N'Champions (Top-Stammkunden)'
            WHEN R_Score >= 3 AND F_Score >= 3 THEN N'Loyale Kunden (Regelmäßig)'
            WHEN R_Score >= 4 AND F_Score <= 2 THEN N'Neukunden / Potenzial'
            WHEN R_Score <= 2 AND F_Score >= 4 THEN N'Gefährdete Stammkunden (Abwanderung droht)'
            WHEN R_Score <= 2 AND F_Score <= 2 THEN N'Inaktive / Verlorene Kunden'
            ELSE N'Durchschnittskunden'
        END AS KundenSegment
    FROM RFM_Scores
)
SELECT 
    KundenSegment,
    COUNT(*) AS AnzahlKunden,
    CAST(AVG(GesamtUmsatzEUR) AS DECIMAL(10,2)) AS DurchschnUmsatzEUR,
    CAST(AVG(AnzahlEinkaeufe * 1.0) AS DECIMAL(5,1)) AS DurchschnBons,
    AVG(TageSeitLetztemKauf) AS DurchschnTageInaktiv
FROM Segmentiert
GROUP BY KundenSegment
ORDER BY DurchschnUmsatzEUR DESC;
GO

-- =====================================================================================
-- 2. ANWENDUNGSFALL: Monatliche Kohortenmatrix zur Kundenbindung
-- -------------------------------------------------------------------------------------
-- Frage der Geschäftsführung:
-- "Wie viel Prozent der Neukunden eines Registrierungsmonats kaufen in den 
--  Folgemonaten (Monat +1, +2, +3, ...) tatsächlich wieder bei FrischMarkt ein?"
-- =====================================================================================
WITH Ersteinkauf AS (
    -- Bestimmt den Kohortenmonat jedes Kunden anhand seines ersten Einkaufs
    SELECT 
        k.KundeID,
        DATEFROMPARTS(YEAR(MIN(f.BonDatum)), MONTH(MIN(f.BonDatum)), 1) AS KohortenMonat
    FROM dwh.fct_verkaeufe f
    JOIN dbo.Kunden k ON k.KundeID = f.KundeID
    GROUP BY k.KundeID
),
KundenAktivitaet AS (
    -- Ermittelt alle Monate, in denen der Kunde aktiv eingekauft hat
    SELECT DISTINCT
        e.KohortenMonat,
        e.KundeID,
        DATEDIFF(MONTH, e.KohortenMonat, DATEFROMPARTS(YEAR(f.BonDatum), MONTH(f.BonDatum), 1)) AS MonatsIndex
    FROM dwh.fct_verkaeufe f
    JOIN Ersteinkauf e ON e.KundeID = f.KundeID
),
KohortenGroessen AS (
    SELECT 
        KohortenMonat,
        COUNT(DISTINCT KundeID) AS KohortenStartGroesse
    FROM Ersteinkauf
    GROUP BY KohortenMonat
)
SELECT 
    FORMAT(a.KohortenMonat, 'yyyy-MM') AS Kohorte,
    g.KohortenStartGroesse AS KundenStart,
    COUNT(DISTINCT CASE WHEN a.MonatsIndex = 0 THEN a.KundeID END) AS M0,
    COUNT(DISTINCT CASE WHEN a.MonatsIndex = 1 THEN a.KundeID END) AS M1,
    COUNT(DISTINCT CASE WHEN a.MonatsIndex = 2 THEN a.KundeID END) AS M2,
    COUNT(DISTINCT CASE WHEN a.MonatsIndex = 3 THEN a.KundeID END) AS M3,
    COUNT(DISTINCT CASE WHEN a.MonatsIndex = 6 THEN a.KundeID END) AS M6,
    -- Wiederkaufrate für Monat 1 (% der Kohorte, die im Folgemonat wiederkommt)
    CAST(
        COUNT(DISTINCT CASE WHEN a.MonatsIndex = 1 THEN a.KundeID END) * 100.0 / 
        NULLIF(g.KohortenStartGroesse, 0)
        AS DECIMAL(5,1)
    ) AS [Retention_M1_%]
FROM KundenAktivitaet a
JOIN KohortenGroessen g ON g.KohortenMonat = a.KohortenMonat
WHERE a.KohortenMonat >= '2024-01-01' AND a.KohortenMonat <= '2025-12-01'
GROUP BY a.KohortenMonat, g.KohortenStartGroesse
ORDER BY a.KohortenMonat;
GO
