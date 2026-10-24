-- =====================================================================================
-- SQL ANALYST TOOLKIT | MODUL 02: WINDOW FUNCTIONS (FENSTERFUNKTIONEN)
-- -------------------------------------------------------------------------------------
-- Datenbank : SupermarktDWH (FrischMarkt GmbH)
-- Ziel      : Beherrschung von ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE sowie
--             gleitenden Fenstern (ROWS BETWEEN) anhand realistischer Filialdaten.
-- =====================================================================================

USE SupermarktDWH;
GO

-- =====================================================================================
-- 1. BUSINESS CASE: Die 3 umsatzstärksten Artikel je Warengruppe (DENSE_RANK)
-- -------------------------------------------------------------------------------------
-- Frage des Category Managers:
-- "Welche 3 Top-Seller treiben in jeder einzelnen Warengruppe den Umsatz an?"
-- =====================================================================================
WITH KategorieUmsatz AS (
    SELECT 
        k.KategorieName,
        p.ProduktName,
        SUM(f.Menge) AS VerkaufteMenge,
        CAST(SUM(f.UmsatzBrutto) AS DECIMAL(12,2)) AS BruttoUmsatzEUR,
        CAST(SUM(f.Deckungsbeitrag) AS DECIMAL(12,2)) AS RohertragEUR,
        -- DENSE_RANK vergibt lückenlose Ränge bei gleichem Umsatz
        DENSE_RANK() OVER (
            PARTITION BY k.KategorieID 
            ORDER BY SUM(f.UmsatzBrutto) DESC
        ) AS RangInKategorie
    FROM dwh.fct_verkaeufe f
    JOIN dbo.Produkte p ON p.ProduktID = f.ProduktID
    JOIN dbo.Kategorien k ON k.KategorieID = p.KategorieID
    GROUP BY k.KategorieID, k.KategorieName, p.ProduktName
)
SELECT 
    KategorieName,
    RangInKategorie,
    ProduktName,
    VerkaufteMenge,
    BruttoUmsatzEUR,
    RohertragEUR
FROM KategorieUmsatz
WHERE RangInKategorie <= 3
ORDER BY KategorieName, RangInKategorie;
GO

-- =====================================================================================
-- 2. BUSINESS CASE: Month-over-Month (MoM) Umsatzwachstum mit LAG()
-- -------------------------------------------------------------------------------------
-- Frage der Geschäftsführung:
-- "Wie entwickelt sich der monatliche Gesamtumsatz im Vergleich zum Vormonat und
--  in welchen Monaten gab es signifikante Einbrüche oder Spitzen?"
-- =====================================================================================
WITH Monatsumsatz AS (
    SELECT 
        d.Jahr,
        d.MonatNr,
        d.JahrMonat,
        d.MonatName,
        CAST(SUM(f.UmsatzBrutto) AS DECIMAL(12,2)) AS UmsatzAktuell
    FROM dwh.fct_verkaeufe f
    JOIN dwh.dim_datum d ON d.DatumKey = f.DatumKey
    GROUP BY d.Jahr, d.MonatNr, d.JahrMonat, d.MonatName
),
WachstumsVergleich AS (
    SELECT 
        JahrMonat,
        MonatName,
        UmsatzAktuell,
        -- LAG(..., 1) liest den Umsatz des vorherigen Monats aus
        LAG(UmsatzAktuell, 1) OVER (ORDER BY JahrMonat) AS UmsatzVormonat,
        UmsatzAktuell - LAG(UmsatzAktuell, 1) OVER (ORDER BY JahrMonat) AS AbsoluteAenderungEUR,
        CAST(
            (UmsatzAktuell - LAG(UmsatzAktuell, 1) OVER (ORDER BY JahrMonat)) * 100.0 / 
            NULLIF(LAG(UmsatzAktuell, 1) OVER (ORDER BY JahrMonat), 0) 
            AS DECIMAL(5,2)
        ) AS MoM_Wachstum_Pct
    FROM Monatsumsatz
)
SELECT 
    JahrMonat,
    MonatName,
    UmsatzAktuell,
    UmsatzVormonat,
    AbsoluteAenderungEUR,
    MoM_Wachstum_Pct,
    CASE 
        WHEN MoM_Wachstum_Pct >= 5.0 THEN N'▲ Starkes Wachstum (> +5%)'
        WHEN MoM_Wachstum_Pct <= -5.0 THEN N'▼ Deutlicher Rückgang (< -5%)'
        ELSE N'► Stabile Entwicklung (±5%)'
    END AS PerformanceTrend
FROM WachstumsVergleich
ORDER BY JahrMonat;
GO

-- =====================================================================================
-- 3. BUSINESS CASE: Gleitender 7-Tage-Durchschnitt zur Glättung von Wochentagseffekten
-- -------------------------------------------------------------------------------------
-- Frage des Filialleiters (Standort Hannover-Mitte):
-- "Da Samstage rund 70 % mehr Umsatz machen als Montage, brauche ich eine geglättete
--  Trendlinie (Rolling 7-Day Average) für die Personal- und Frischeplanung."
-- =====================================================================================
WITH Tagesumsatz AS (
    SELECT 
        d.Datum,
        d.WochentagKurz,
        CAST(SUM(f.UmsatzBrutto) AS DECIMAL(10,2)) AS TagesUmsatzEUR
    FROM dwh.fct_verkaeufe f
    JOIN dwh.dim_datum d ON d.DatumKey = f.DatumKey
    WHERE f.FilialeID = 1 -- Hannover-Mitte
      AND d.Datum BETWEEN '2026-06-01' AND '2026-08-31'
    GROUP BY d.Datum, d.WochentagKurz
)
SELECT 
    Datum,
    WochentagKurz,
    TagesUmsatzEUR,
    -- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW: Schiebefenster über 7 aufeinanderfolgende Tage
    CAST(
        AVG(TagesUmsatzEUR) OVER (
            ORDER BY Datum 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS DECIMAL(10,2)
    ) AS GleitenderSchnitt_7Tage,
    -- Kumulierter Monatsumsatz (Running Total innerhalb des jeweiligen Monats)
    CAST(
        SUM(TagesUmsatzEUR) OVER (
            PARTITION BY YEAR(Datum), MONTH(Datum)
            ORDER BY Datum 
            ROWS UNBOUNDED PRECEDING
        ) AS DECIMAL(12,2)
    ) AS RunningTotal_Monat
FROM Tagesumsatz
ORDER BY Datum;
GO
