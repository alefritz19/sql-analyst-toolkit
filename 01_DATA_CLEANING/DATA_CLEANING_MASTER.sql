-- =====================================================================================
-- SQL ANALYST TOOLKIT | MODUL 01: DATA CLEANING & QUALITY AUDITING
-- -------------------------------------------------------------------------------------
-- Datenbank : SupermarktDWH (FrischMarkt GmbH)
-- Tabelle   : stg.Kunden_Rohimport
-- Ziel      : Praxisnahe Datenbereinigung mit T-SQL:
--             1. Leerzeichen & Whitespace bereinigen (TRIM / REPLACE)
--             2. Unstrukturierte Namen in Vor- und Nachname splitten (SUBSTRING / CHARINDEX)
--             3. Datumsformate harmonisieren (TRY_CONVERT / Standardisierung)
--             4. Dubletten-Erkennung & Deduplizierung mit ROW_NUMBER()
-- =====================================================================================

USE SupermarktDWH;
GO

-- =====================================================================================
-- 1. INSPEKTION: Erkennen der "schmutzigen" Datensätze im Staging-Layer
-- =====================================================================================
SELECT TOP 10
    RohID,
    KundenCode,
    VollstaendigerName,
    GeburtsdatumTxt,
    StadtPLZ,
    EmailAdresse
FROM stg.Kunden_Rohimport
ORDER BY RohID;
GO

-- =====================================================================================
-- 2. BEREINIGUNG & HARMONISIERUNG (In-Flight Cleaning via CTE)
-- =====================================================================================
WITH Bereinigt AS (
    SELECT 
        RohID,
        -- 1. KundenCode: Führende/nachgestellte Leerzeichen entfernen und in Großbuchstaben umwandeln
        UPPER(LTRIM(RTRIM(KundenCode))) AS SaubererKundenCode,
        
        -- 2. Namensbereinigung: Doppelte Leerzeichen verdichten
        LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(VollstaendigerName, '   ', ' '), '  ', ' '), '  ', ' '))) AS BereinigterName,
        
        -- 3. Datumsbereinigung: Sicher parsen (Ungültige Strings wie 'UNGÜLTIG' werden NULL)
        COALESCE(
            TRY_CONVERT(DATE, GeburtsdatumTxt, 120),  -- 1990-12-31 (ISO)
            TRY_CONVERT(DATE, GeburtsdatumTxt, 104),  -- 31.12.1990 (Deutsch)
            TRY_CONVERT(DATE, GeburtsdatumTxt, 101)   -- 12/31/1990 (US)
        ) AS SauberesGeburtsdatum,
        
        -- 4. Trennung von PLZ und Stadt (immer auf dem getrimmten Wert arbeiten,
        --    sonst verschiebt ein führendes Leerzeichen die Startposition des Stadtnamens)
        LEFT(LTRIM(StadtPLZ), 5) AS SauberePLZ,
        LTRIM(SUBSTRING(LTRIM(StadtPLZ), 7, 50)) AS SaubereStadt,
        
        -- 5. E-Mail-Validierung: Syntaxfehler (wie doppeltes @@) korrigieren
        LOWER(LTRIM(RTRIM(REPLACE(EmailAdresse, '@@', '@')))) AS SaubereEmail
    FROM stg.Kunden_Rohimport
),
Dedupliziert AS (
    SELECT 
        *,
        -- 6. Dubletten-Rangfolge: Pro sauberem KundenCode wird der aktuellste Datensatz mit Rang 1 markiert
        ROW_NUMBER() OVER (
            PARTITION BY SaubererKundenCode 
            ORDER BY RohID DESC
        ) AS DublettenRang
    FROM Bereinigt
)
SELECT 
    SaubererKundenCode,
    BereinigterName,
    SauberesGeburtsdatum,
    SauberePLZ,
    SaubereStadt,
    SaubereEmail,
    CASE WHEN SauberesGeburtsdatum IS NULL THEN N'⚠ Fehlendes Datum' ELSE N'OK' END AS DatenqualitaetsStatus
FROM Dedupliziert
WHERE DublettenRang = 1 -- Filtert exakt 1 eindeutigen Datensatz je Kunde heraus!
ORDER BY SaubererKundenCode;
GO
