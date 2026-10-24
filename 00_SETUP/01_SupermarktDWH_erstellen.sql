/* =====================================================================================
   SupermarktDWH – Reproduzierbarer Datengenerator für die „FrischMarkt GmbH“
   -------------------------------------------------------------------------------------
   Zweck      : Erstellt eine vollständige, realistische Einzelhandelsdatenbank als
                gemeinsame Datengrundlage für alle Portfolio-Projekte:
                  • sql-analyst-toolkit            (SQL-Lernpfad & Business Cases)
                  • PowerBI-Supermarkt-Analytics   (Sternschema, DAX, Dashboard)
                  • Supermarkt-Medallion-Lakehouse-Fabric (Bronze → Silver → Gold)
   Datenlage  : SYNTHETISCH erzeugt – keine echten Personen- oder Unternehmensdaten.
                Die Daten enthalten bewusst realistische Muster (Saisonalität,
                Wochentagseffekte, Preissteigerungen, Aktionen, Abschriften, Kundenabwanderung),
                die in den Analysemodulen aufgedeckt werden.
   Determinismus: Alle Zufallswerte werden per SHA2-Hash aus festen Schlüsseln abgeleitet.
                Jede Ausführung erzeugt exakt denselben Datenbestand.
   Laufzeit   : ca. 1–3 Minuten (SQL Server 2022 Express)
   Umfang     : 5 Filialen · 8 Kategorien · 120 Artikel · 3.000 Kundenkarten · 40 Mitarbeiter
                ~190.000 Kassenbons · ~700.000 Bonpositionen · Zeitraum 01/2024 – 09/2026
   Voraussetzung: SQL Server 2022 (GENERATE_SERIES, Kompatibilitätsgrad 160)

   ⚠ ACHTUNG: Das Skript löscht eine evtl. vorhandene Datenbank „SupermarktDWH“ und legt
              sie neu an. Andere Datenbanken (z. B. SupermarktV2) bleiben unberührt.
   ===================================================================================== */

SET NOCOUNT ON;
USE master;
GO

IF DB_ID(N'SupermarktDWH') IS NOT NULL
BEGIN
    ALTER DATABASE SupermarktDWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SupermarktDWH;
END;
GO

CREATE DATABASE SupermarktDWH;
GO
ALTER DATABASE SupermarktDWH SET RECOVERY SIMPLE;
GO

USE SupermarktDWH;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE SCHEMA stg  AUTHORIZATION dbo;   -- Rohdaten-Importe (bewusst „schmutzig“)
GO
CREATE SCHEMA dwh  AUTHORIZATION dbo;   -- Sternschema für Power BI / Reporting
GO
CREATE SCHEMA util AUTHORIZATION dbo;   -- Hilfsobjekte des Generators
GO

PRINT N'[1/10] Hilfsobjekte: Zahlentabelle und deterministischer Zufallsgenerator';

CREATE TABLE util.Zahlen (n INT NOT NULL PRIMARY KEY);
INSERT INTO util.Zahlen (n) SELECT value FROM GENERATE_SERIES(0, 99999);
GO

-- Liefert eine reproduzierbare Pseudo-Zufallszahl im Intervall [0, 1)
CREATE FUNCTION util.fn_Zufall (@Schluessel BIGINT, @Salz INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT Z = CAST(
                 (CAST(CAST(SUBSTRING(HASHBYTES('SHA2_256', CONCAT(@Schluessel, N'|', @Salz)), 1, 4) AS INT) AS BIGINT)
                  + 2147483648) / 4294967296.0
               AS FLOAT);
GO

/* =====================================================================================
   [2/10] Kalender und Feiertage
   ===================================================================================== */
PRINT N'[2/10] Kalender (dwh.dim_datum) und Feiertage';

CREATE TABLE dbo.Feiertage (
    Datum        DATE         NOT NULL,
    Bundesland   CHAR(4)      NOT NULL,   -- 'ALLE' = bundesweit, 'NI' = Niedersachsen, 'NW' = Nordrhein-Westfalen
    FeiertagName NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_Feiertage PRIMARY KEY (Datum, Bundesland)
);

INSERT INTO dbo.Feiertage (Datum, Bundesland, FeiertagName) VALUES
-- 2024
('2024-01-01','ALLE',N'Neujahr'), ('2024-03-29','ALLE',N'Karfreitag'), ('2024-04-01','ALLE',N'Ostermontag'),
('2024-05-01','ALLE',N'Tag der Arbeit'), ('2024-05-09','ALLE',N'Christi Himmelfahrt'), ('2024-05-20','ALLE',N'Pfingstmontag'),
('2024-05-30','NW',N'Fronleichnam'), ('2024-10-03','ALLE',N'Tag der Deutschen Einheit'), ('2024-10-31','NI',N'Reformationstag'),
('2024-11-01','NW',N'Allerheiligen'), ('2024-12-25','ALLE',N'1. Weihnachtstag'), ('2024-12-26','ALLE',N'2. Weihnachtstag'),
-- 2025
('2025-01-01','ALLE',N'Neujahr'), ('2025-04-18','ALLE',N'Karfreitag'), ('2025-04-21','ALLE',N'Ostermontag'),
('2025-05-01','ALLE',N'Tag der Arbeit'), ('2025-05-29','ALLE',N'Christi Himmelfahrt'), ('2025-06-09','ALLE',N'Pfingstmontag'),
('2025-06-19','NW',N'Fronleichnam'), ('2025-10-03','ALLE',N'Tag der Deutschen Einheit'), ('2025-10-31','NI',N'Reformationstag'),
('2025-11-01','NW',N'Allerheiligen'), ('2025-12-25','ALLE',N'1. Weihnachtstag'), ('2025-12-26','ALLE',N'2. Weihnachtstag'),
-- 2026
('2026-01-01','ALLE',N'Neujahr'), ('2026-04-03','ALLE',N'Karfreitag'), ('2026-04-06','ALLE',N'Ostermontag'),
('2026-05-01','ALLE',N'Tag der Arbeit'), ('2026-05-14','ALLE',N'Christi Himmelfahrt'), ('2026-05-25','ALLE',N'Pfingstmontag'),
('2026-06-04','NW',N'Fronleichnam'), ('2026-10-03','ALLE',N'Tag der Deutschen Einheit'), ('2026-10-31','NI',N'Reformationstag'),
('2026-11-01','NW',N'Allerheiligen'), ('2026-12-25','ALLE',N'1. Weihnachtstag'), ('2026-12-26','ALLE',N'2. Weihnachtstag');

CREATE TABLE dwh.dim_datum (
    DatumKey        INT           NOT NULL PRIMARY KEY,   -- Format JJJJMMTT
    Datum           DATE          NOT NULL UNIQUE,
    Jahr            SMALLINT      NOT NULL,
    QuartalNr       TINYINT       NOT NULL,
    Quartal         CHAR(2)       NOT NULL,
    JahrQuartal     CHAR(7)       NOT NULL,
    MonatNr         TINYINT       NOT NULL,
    MonatName       NVARCHAR(15)  NOT NULL,
    MonatKurz       NVARCHAR(10)  NOT NULL,
    JahrMonat       CHAR(7)       NOT NULL,
    JahrMonatNr     INT           NOT NULL,               -- Sortierschlüssel JJJJMM
    TagImMonat      TINYINT       NOT NULL,
    KW              TINYINT       NOT NULL,               -- ISO-8601-Kalenderwoche
    ISOJahr         SMALLINT      NOT NULL,
    WochentagNr     TINYINT       NOT NULL,               -- 1 = Montag … 7 = Sonntag (unabhängig von DATEFIRST)
    WochentagName   NVARCHAR(10)  NOT NULL,
    WochentagKurz   NCHAR(2)      NOT NULL,
    IstWochenende   BIT           NOT NULL,
    IstFeiertag     BIT           NOT NULL,               -- nur bundesweite Feiertage
    FeiertagName    NVARCHAR(40)  NULL,
    IstVerkaufstag  BIT           NOT NULL,               -- Mo–Sa und kein bundesweiter Feiertag
    Saison          NVARCHAR(10)  NOT NULL,
    IstMonatsende   BIT           NOT NULL
);

INSERT INTO dwh.dim_datum
SELECT
    DatumKey       = CONVERT(INT, CONVERT(CHAR(8), d.Datum, 112)),
    Datum          = d.Datum,
    Jahr           = YEAR(d.Datum),
    QuartalNr      = DATEPART(QUARTER, d.Datum),
    Quartal        = CONCAT('Q', DATEPART(QUARTER, d.Datum)),
    JahrQuartal    = CONCAT(YEAR(d.Datum), '-Q', DATEPART(QUARTER, d.Datum)),
    MonatNr        = MONTH(d.Datum),
    MonatName      = CHOOSE(MONTH(d.Datum), N'Januar',N'Februar',N'März',N'April',N'Mai',N'Juni',N'Juli',N'August',N'September',N'Oktober',N'November',N'Dezember'),
    MonatKurz      = CHOOSE(MONTH(d.Datum), N'Jan',N'Feb',N'Mär',N'Apr',N'Mai',N'Jun',N'Jul',N'Aug',N'Sep',N'Okt',N'Nov',N'Dez'),
    JahrMonat      = CONVERT(CHAR(7), d.Datum, 120),
    JahrMonatNr    = YEAR(d.Datum) * 100 + MONTH(d.Datum),
    TagImMonat     = DAY(d.Datum),
    KW             = DATEPART(ISO_WEEK, d.Datum),
    ISOJahr        = YEAR(DATEADD(DAY, 26 - DATEPART(ISO_WEEK, d.Datum), d.Datum)),
    WochentagNr    = w.Nr,
    WochentagName  = CHOOSE(w.Nr, N'Montag',N'Dienstag',N'Mittwoch',N'Donnerstag',N'Freitag',N'Samstag',N'Sonntag'),
    WochentagKurz  = CHOOSE(w.Nr, N'Mo',N'Di',N'Mi',N'Do',N'Fr',N'Sa',N'So'),
    IstWochenende  = IIF(w.Nr >= 6, 1, 0),
    IstFeiertag    = IIF(f.Datum IS NOT NULL, 1, 0),
    FeiertagName   = f.FeiertagName,
    IstVerkaufstag = IIF(w.Nr <= 6 AND f.Datum IS NULL, 1, 0),
    Saison         = CASE WHEN MONTH(d.Datum) IN (12,1,2) THEN N'Winter'
                          WHEN MONTH(d.Datum) IN (3,4,5)  THEN N'Frühling'
                          WHEN MONTH(d.Datum) IN (6,7,8)  THEN N'Sommer'
                          ELSE N'Herbst' END,
    IstMonatsende  = IIF(d.Datum = EOMONTH(d.Datum), 1, 0)
FROM (SELECT Datum = DATEADD(DAY, n, CAST('2024-01-01' AS DATE)) FROM util.Zahlen WHERE n <= DATEDIFF(DAY, '2024-01-01', '2026-12-31')) AS d
CROSS APPLY (SELECT Nr = DATEDIFF(DAY, '19000101', d.Datum) % 7 + 1) AS w     -- 01.01.1900 war ein Montag
LEFT JOIN dbo.Feiertage AS f ON f.Datum = d.Datum AND f.Bundesland = 'ALLE';
GO

/* =====================================================================================
   [3/10] Stammdaten: Filialen, Kategorien, Artikel, Preishistorie
   ===================================================================================== */
PRINT N'[3/10] Stammdaten: Filialen, Kategorien, Artikel, Preishistorie';

CREATE TABLE dbo.Filialen (
    FilialeID          INT           NOT NULL PRIMARY KEY,
    Filialcode         CHAR(3)       NOT NULL UNIQUE,
    FilialName         NVARCHAR(40)  NOT NULL,
    Strasse            NVARCHAR(60)  NOT NULL,
    PLZ                CHAR(5)       NOT NULL,
    Stadt              NVARCHAR(40)  NOT NULL,
    Bundesland         NVARCHAR(30)  NOT NULL,
    BundeslandKz       CHAR(2)       NOT NULL,
    Region             NVARCHAR(10)  NOT NULL,
    VerkaufsflaecheQM  INT           NOT NULL,
    Eroeffnungsdatum   DATE          NOT NULL
);

INSERT INTO dbo.Filialen VALUES
(1,'F01',N'Hannover-Mitte', N'Georgstraße 21',     '30159',N'Hannover',    N'Niedersachsen',          'NI',N'Nord', 1400,'2012-04-02'),
(2,'F02',N'Hannover-List',  N'Lister Meile 88',    '30161',N'Hannover',    N'Niedersachsen',          'NI',N'Nord',  900,'2016-09-01'),
(3,'F03',N'Braunschweig',   N'Bohlweg 45',         '38100',N'Braunschweig',N'Niedersachsen',          'NI',N'Ost',  1200,'2014-03-03'),
(4,'F04',N'Hildesheim',     N'Almsstraße 12',      '31134',N'Hildesheim',  N'Niedersachsen',          'NI',N'Süd',  1000,'2018-10-01'),
(5,'F05',N'Bielefeld',      N'Bahnhofstraße 30',   '33602',N'Bielefeld',   N'Nordrhein-Westfalen',    'NW',N'West', 1600,'2024-09-02');

CREATE TABLE dbo.Kategorien (
    KategorieID     INT           NOT NULL PRIMARY KEY,
    KategorieName   NVARCHAR(40)  NOT NULL UNIQUE,
    Warenbereich    NVARCHAR(20)  NOT NULL,
    IstFrischware   BIT           NOT NULL
);

INSERT INTO dbo.Kategorien VALUES
(1,N'Obst & Gemüse',       N'Frische',          1),
(2,N'Molkereiprodukte',    N'Frische',          1),
(3,N'Fleisch & Wurst',     N'Frische',          1),
(4,N'Backwaren',           N'Frische',          1),
(5,N'Getränke',            N'Getränke',         0),
(6,N'Süßwaren & Snacks',   N'Trockensortiment', 0),
(7,N'Trockensortiment',    N'Trockensortiment', 0),
(8,N'Drogerie & Haushalt', N'Non-Food',         0);

CREATE TABLE dbo.Produkte (
    ProduktID       INT            NOT NULL PRIMARY KEY,
    EAN             CHAR(13)       NOT NULL UNIQUE,
    ProduktName     NVARCHAR(60)   NOT NULL,
    KategorieID     INT            NOT NULL REFERENCES dbo.Kategorien (KategorieID),
    Marke           NVARCHAR(40)   NOT NULL,
    IstEigenmarke   BIT            NOT NULL,
    Saisonprofil    NVARCHAR(12)   NOT NULL,   -- Ganzjährig | Sommer | Winter
    MwStSatz        DECIMAL(4,2)   NOT NULL,   -- 0.07 ermäßigt | 0.19 regulär
    IstAktiv        BIT            NOT NULL DEFAULT 1
);

-- Generator-Parameter je Artikel (Startpreis brutto 2024 und Beliebtheit 1–10)
CREATE TABLE util.Artikelparameter (ProduktID INT PRIMARY KEY, VK2024 DECIMAL(10,2), Beliebtheit INT);

DECLARE @Artikel TABLE (ID INT, Name NVARCHAR(60), Kat INT, Marke NVARCHAR(40), Eigen BIT, Saison NVARCHAR(12), VK DECIMAL(10,2), Bel INT);
INSERT INTO @Artikel VALUES
-- 1 Obst & Gemüse
(  1,N'Bananen 1 kg',                    1,N'Chiquita',            0,N'Ganzjährig', 1.79,10),
(  2,N'Äpfel Elstar 1 kg',               1,N'FrischMarkt',         1,N'Ganzjährig', 2.49, 8),
(  3,N'Rispentomaten 500 g',             1,N'FrischMarkt',         1,N'Ganzjährig', 1.99, 8),
(  4,N'Salatgurke Stück',                1,N'FrischMarkt',         1,N'Ganzjährig', 0.69, 9),
(  5,N'Kartoffeln festkochend 2,5 kg',   1,N'FrischMarkt',         1,N'Ganzjährig', 3.49, 7),
(  6,N'Speisezwiebeln 1 kg',             1,N'FrischMarkt',         1,N'Ganzjährig', 1.29, 7),
(  7,N'Karotten 1 kg',                   1,N'FrischMarkt',         1,N'Ganzjährig', 1.19, 7),
(  8,N'Paprika Mix 500 g',               1,N'FrischMarkt',         1,N'Ganzjährig', 2.29, 6),
(  9,N'Eisbergsalat Stück',              1,N'FrischMarkt',         1,N'Ganzjährig', 1.09, 6),
( 10,N'Zitronen 500 g',                  1,N'FrischMarkt',         1,N'Ganzjährig', 1.49, 4),
( 11,N'Erdbeeren 500 g',                 1,N'FrischMarkt',         1,N'Sommer',     2.99, 5),
( 12,N'Avocado Stück',                   1,N'FrischMarkt',         1,N'Ganzjährig', 1.29, 4),
( 13,N'Bio-Möhren 1 kg',                 1,N'FrischMarkt Bio',     1,N'Ganzjährig', 1.89, 3),
( 14,N'Weintrauben hell 500 g',          1,N'FrischMarkt',         1,N'Ganzjährig', 2.49, 4),
( 15,N'Champignons 400 g',               1,N'FrischMarkt',         1,N'Ganzjährig', 1.99, 4),
-- 2 Molkereiprodukte
( 16,N'Frische Vollmilch 3,5 % 1 l',     2,N'Weihenstephan',       0,N'Ganzjährig', 1.59,10),
( 17,N'H-Milch 1,5 % 1 l',               2,N'FrischMarkt',         1,N'Ganzjährig', 0.99, 9),
( 18,N'Butter 250 g',                    2,N'Kerrygold',           0,N'Ganzjährig', 2.99, 8),
( 19,N'Naturjoghurt 500 g',              2,N'FrischMarkt',         1,N'Ganzjährig', 0.89, 7),
( 20,N'Fruchtjoghurt 150 g',             2,N'Müller',              0,N'Ganzjährig', 0.59, 7),
( 21,N'Gouda jung in Scheiben 400 g',    2,N'FrischMarkt',         1,N'Ganzjährig', 2.79, 7),
( 22,N'Mozzarella 125 g',                2,N'Galbani',             0,N'Ganzjährig', 1.19, 6),
( 23,N'Magerquark 500 g',                2,N'FrischMarkt',         1,N'Ganzjährig', 1.19, 6),
( 24,N'Schlagsahne 200 g',               2,N'FrischMarkt',         1,N'Ganzjährig', 1.09, 5),
( 25,N'Freilandeier 10 Stück',           2,N'FrischMarkt',         1,N'Ganzjährig', 2.99, 8),
( 26,N'Frischkäse 200 g',                2,N'Philadelphia',        0,N'Ganzjährig', 1.99, 5),
( 27,N'Skyr Natur 450 g',                2,N'Arla',                0,N'Ganzjährig', 1.89, 4),
( 28,N'Haferdrink 1 l',                  2,N'Oatly',               0,N'Ganzjährig', 2.29, 4),
( 29,N'Emmentaler gerieben 200 g',       2,N'FrischMarkt',         1,N'Ganzjährig', 1.79, 5),
( 30,N'Kefir 500 ml',                    2,N'FrischMarkt',         1,N'Ganzjährig', 1.29, 3),
-- 3 Fleisch & Wurst
( 31,N'Hähnchenbrustfilet 600 g',        3,N'FrischMarkt',         1,N'Ganzjährig', 6.99, 7),
( 32,N'Rinderhackfleisch 500 g',         3,N'FrischMarkt',         1,N'Ganzjährig', 5.49, 7),
( 33,N'Gemischtes Hackfleisch 500 g',    3,N'FrischMarkt',         1,N'Ganzjährig', 4.29, 6),
( 34,N'Schweineschnitzel 500 g',         3,N'FrischMarkt',         1,N'Ganzjährig', 4.99, 5),
( 35,N'Grillbratwurst 4 Stück',          3,N'FrischMarkt',         1,N'Sommer',     3.49, 5),
( 36,N'Salami in Scheiben 100 g',        3,N'Herta',               0,N'Ganzjährig', 1.79, 6),
( 37,N'Kochschinken 200 g',              3,N'FrischMarkt',         1,N'Ganzjährig', 2.29, 7),
( 38,N'Wiener Würstchen 6 Stück',        3,N'Meica',               0,N'Ganzjährig', 2.99, 5),
( 39,N'Leberwurst 125 g',                3,N'Rügenwalder Mühle',   0,N'Ganzjährig', 1.69, 4),
( 40,N'Vegane Frikadellen 180 g',        3,N'Rügenwalder Mühle',   0,N'Ganzjährig', 2.99, 3),
( 41,N'Lachsfilet 250 g',                3,N'FrischMarkt',         1,N'Ganzjährig', 5.99, 4),
( 42,N'Putenbrust-Aufschnitt 150 g',     3,N'FrischMarkt',         1,N'Ganzjährig', 1.99, 5),
( 43,N'Grillsteak mariniert 400 g',      3,N'FrischMarkt',         1,N'Sommer',     5.99, 3),
( 44,N'Speckwürfel 150 g',               3,N'FrischMarkt',         1,N'Ganzjährig', 1.49, 4),
( 45,N'Chicken Nuggets 450 g',           3,N'FrischMarkt',         1,N'Ganzjährig', 3.79, 4),
-- 4 Backwaren
( 46,N'Brötchen 6 Stück',                4,N'FrischMarkt Backstube',1,N'Ganzjährig', 1.49,10),
( 47,N'Vollkornbrot 750 g',              4,N'FrischMarkt Backstube',1,N'Ganzjährig', 2.49, 7),
( 48,N'Buttertoast 500 g',               4,N'Golden Toast',        0,N'Ganzjährig', 1.69, 7),
( 49,N'Buttercroissant Stück',           4,N'FrischMarkt Backstube',1,N'Ganzjährig', 0.79, 6),
( 50,N'Laugenbrezel Stück',              4,N'FrischMarkt Backstube',1,N'Ganzjährig', 0.69, 7),
( 51,N'Baguette Stück',                  4,N'FrischMarkt Backstube',1,N'Ganzjährig', 1.19, 6),
( 52,N'Roggenmischbrot 1 kg',            4,N'FrischMarkt Backstube',1,N'Ganzjährig', 2.99, 5),
( 53,N'Körnerbrötchen Stück',            4,N'FrischMarkt Backstube',1,N'Ganzjährig', 0.55, 6),
( 54,N'Butterkuchen Stück',              4,N'FrischMarkt Backstube',1,N'Ganzjährig', 1.29, 4),
( 55,N'Berliner Stück',                  4,N'FrischMarkt Backstube',1,N'Ganzjährig', 0.99, 4),
( 56,N'Christstollen 750 g',             4,N'FrischMarkt Backstube',1,N'Winter',     7.99, 2),
( 57,N'Laugenstange Stück',              4,N'FrischMarkt Backstube',1,N'Ganzjährig', 0.79, 4),
( 58,N'Zwiebelkuchen Stück',             4,N'FrischMarkt Backstube',1,N'Ganzjährig', 1.99, 2),
( 59,N'Dinkelbrot 500 g',                4,N'FrischMarkt Backstube',1,N'Ganzjährig', 2.79, 4),
( 60,N'Apfeltasche Stück',               4,N'FrischMarkt Backstube',1,N'Ganzjährig', 1.19, 4),
-- 5 Getränke
( 61,N'Mineralwasser still 6 x 1,5 l',   5,N'Gerolsteiner',        0,N'Sommer',     4.49, 8),
( 62,N'Mineralwasser spritzig 1,5 l',    5,N'FrischMarkt',         1,N'Ganzjährig', 0.29, 8),
( 63,N'Cola 1,5 l',                      5,N'Coca-Cola',           0,N'Ganzjährig', 1.79, 8),
( 64,N'Apfelschorle 1 l',                5,N'FrischMarkt',         1,N'Ganzjährig', 0.99, 6),
( 65,N'Orangensaft 1 l',                 5,N'Hohes C',             0,N'Ganzjährig', 2.49, 6),
( 66,N'Pils Kasten 20 x 0,5 l',          5,N'Krombacher',          0,N'Sommer',    16.99, 5),
( 67,N'Pils 0,5 l',                      5,N'Beck''s',             0,N'Ganzjährig', 0.99, 5),
( 68,N'Rotwein trocken 0,75 l',          5,N'FrischMarkt',         1,N'Winter',     4.99, 4),
( 69,N'Weißwein trocken 0,75 l',         5,N'FrischMarkt',         1,N'Ganzjährig', 4.49, 4),
( 70,N'Sekt trocken 0,75 l',             5,N'Rotkäppchen',         0,N'Ganzjährig', 4.29, 3),
( 71,N'Eistee Pfirsich 1,5 l',           5,N'FrischMarkt',         1,N'Sommer',     0.89, 5),
( 72,N'Energy Drink 0,25 l',             5,N'Red Bull',            0,N'Ganzjährig', 1.49, 5),
( 73,N'Spezi 1,5 l',                     5,N'Paulaner',            0,N'Ganzjährig', 1.69, 3),
( 74,N'Weißbier alkoholfrei 0,5 l',      5,N'Erdinger',            0,N'Sommer',     1.19, 4),
( 75,N'Glühwein 1 l',                    5,N'FrischMarkt',         1,N'Winter',     2.99, 2),
-- 6 Süßwaren & Snacks
( 76,N'Alpenmilch-Schokolade 100 g',     6,N'Milka',               0,N'Ganzjährig', 1.49, 8),
( 77,N'Fruchtgummi 175 g',               6,N'Haribo',              0,N'Ganzjährig', 1.29, 7),
( 78,N'Kartoffelchips Paprika 175 g',    6,N'Funny-frisch',        0,N'Ganzjährig', 1.99, 6),
( 79,N'Salzstangen 250 g',               6,N'FrischMarkt',         1,N'Ganzjährig', 0.89, 5),
( 80,N'Butterkekse 200 g',               6,N'Bahlsen',             0,N'Ganzjährig', 1.69, 5),
( 81,N'Nuss-Nougat-Creme 450 g',         6,N'Nutella',             0,N'Ganzjährig', 3.99, 5),
( 82,N'Schokoriegel 4er-Pack',           6,N'Snickers',            0,N'Ganzjährig', 1.99, 4),
( 83,N'Studentenfutter 200 g',           6,N'FrischMarkt',         1,N'Ganzjährig', 2.29, 4),
( 84,N'Lebkuchen 500 g',                 6,N'FrischMarkt',         1,N'Winter',     2.99, 2),
( 85,N'Schoko-Weihnachtsmann 125 g',     6,N'Lindt',               0,N'Winter',     3.49, 2),
( 86,N'Popcorn süß 100 g',               6,N'FrischMarkt',         1,N'Ganzjährig', 1.19, 3),
( 87,N'Erdnüsse geröstet 200 g',         6,N'ültje',               0,N'Ganzjährig', 2.19, 4),
( 88,N'Pralinen-Mischung 200 g',         6,N'Merci',               0,N'Winter',     3.99, 3),
( 89,N'Lakritzschnecken 200 g',          6,N'Haribo',              0,N'Ganzjährig', 1.29, 3),
( 90,N'Vanilleeis 900 ml',               6,N'Langnese',            0,N'Sommer',     3.99, 4),
-- 7 Trockensortiment
( 91,N'Spaghetti 500 g',                 7,N'Barilla',             0,N'Ganzjährig', 1.99, 7),
( 92,N'Penne Rigate 500 g',              7,N'FrischMarkt',         1,N'Ganzjährig', 0.89, 7),
( 93,N'Basmati-Reis 1 kg',               7,N'FrischMarkt',         1,N'Ganzjährig', 2.49, 6),
( 94,N'Passierte Tomaten 500 g',         7,N'FrischMarkt',         1,N'Ganzjährig', 0.79, 6),
( 95,N'Röstkaffee gemahlen 500 g',       7,N'Jacobs',              0,N'Ganzjährig', 6.99, 7),
( 96,N'Kaffeebohnen 1 kg',               7,N'Tchibo',              0,N'Ganzjährig',13.99, 4),
( 97,N'Weizenmehl Type 405 1 kg',        7,N'FrischMarkt',         1,N'Ganzjährig', 0.79, 5),
( 98,N'Zucker 1 kg',                     7,N'Südzucker',           0,N'Ganzjährig', 1.29, 5),
( 99,N'Sonnenblumenöl 1 l',              7,N'FrischMarkt',         1,N'Ganzjährig', 1.99, 5),
(100,N'Zarte Haferflocken 500 g',        7,N'Kölln',               0,N'Ganzjährig', 1.79, 5),
(101,N'Beeren-Müsli 750 g',              7,N'FrischMarkt',         1,N'Ganzjährig', 2.99, 4),
(102,N'Thunfisch in Öl 185 g',           7,N'FrischMarkt',         1,N'Ganzjährig', 1.69, 4),
(103,N'Tomatenketchup 500 ml',           7,N'Heinz',               0,N'Ganzjährig', 2.79, 5),
(104,N'Mayonnaise 500 ml',               7,N'Thomy',               0,N'Ganzjährig', 2.49, 4),
(105,N'Kidneybohnen 400 g',              7,N'FrischMarkt',         1,N'Ganzjährig', 0.89, 3),
-- 8 Drogerie & Haushalt
(106,N'Toilettenpapier 8 Rollen',        8,N'FrischMarkt',         1,N'Ganzjährig', 3.99, 6),
(107,N'Küchenrolle 4 Rollen',            8,N'FrischMarkt',         1,N'Ganzjährig', 2.99, 4),
(108,N'Vollwaschmittel 20 WL',           8,N'Persil',              0,N'Ganzjährig', 6.99, 3),
(109,N'Handspülmittel 500 ml',           8,N'Fairy',               0,N'Ganzjährig', 1.99, 4),
(110,N'Duschgel 250 ml',                 8,N'Nivea',               0,N'Ganzjährig', 2.49, 4),
(111,N'Zahncreme 75 ml',                 8,N'Colgate',             0,N'Ganzjährig', 1.79, 4),
(112,N'Shampoo 300 ml',                  8,N'Schauma',             0,N'Ganzjährig', 2.29, 3),
(113,N'Müllbeutel 35 l',                 8,N'FrischMarkt',         1,N'Ganzjährig', 1.99, 3),
(114,N'Taschentücher 10er-Pack',         8,N'Tempo',               0,N'Ganzjährig', 1.99, 4),
(115,N'Deospray 150 ml',                 8,N'Rexona',              0,N'Ganzjährig', 2.79, 3),
(116,N'Allzweckreiniger 1 l',            8,N'FrischMarkt',         1,N'Ganzjährig', 1.49, 3),
(117,N'Spülmaschinen-Tabs 40 Stück',     8,N'Finish',              0,N'Ganzjährig', 8.99, 2),
(118,N'Babywindeln Gr. 4 (44 Stück)',    8,N'Pampers',             0,N'Ganzjährig',12.99, 2),
(119,N'Katzen-Nassfutter 12 x 100 g',    8,N'Felix',               0,N'Ganzjährig', 5.49, 3),
(120,N'Batterien AA 8 Stück',            8,N'Varta',               0,N'Ganzjährig', 6.99, 1);

INSERT INTO dbo.Produkte (ProduktID, EAN, ProduktName, KategorieID, Marke, IstEigenmarke, Saisonprofil, MwStSatz)
SELECT ID,
       CONCAT('40', RIGHT(CONCAT('0000000000', ID * 7919 + 1000000), 10), ID % 10),
       Name, Kat, Marke, Eigen, Saison,
       CASE WHEN Kat IN (5, 8) AND ID <> 119 THEN 0.19 ELSE 0.07 END   -- Getränke & Drogerie 19 %, Tierfutter ermäßigt
FROM @Artikel;

INSERT INTO util.Artikelparameter SELECT ID, VK, Bel FROM @Artikel;
GO

-- Preishistorie (SCD Typ 2): Verkaufspreis brutto und Einstandspreis netto je Gültigkeitszeitraum.
-- Eingebautes Muster: 2026 steigen die Einkaufspreise bei Molkereiprodukten (+9 %) deutlich stärker
-- als die Verkaufspreise → Margendruck in der Kategorie.
-- Hinweis zum Nominalfaktor 1,025: durch die Preisendung (FLOOR auf 10 Cent + 0,09) liegt die
-- tatsächliche Verkaufspreiserhöhung höher, im Mittel bei etwa +6,6 %.
CREATE TABLE dbo.Preishistorie (
    ProduktID     INT            NOT NULL REFERENCES dbo.Produkte (ProduktID),
    GueltigAb     DATE           NOT NULL,
    GueltigBis    DATE           NOT NULL,
    VK_Brutto     DECIMAL(10,2)  NOT NULL,
    EK_Netto      DECIMAL(10,4)  NOT NULL,
    CONSTRAINT PK_Preishistorie PRIMARY KEY (ProduktID, GueltigAb)
);

;WITH Basis AS (
    SELECT p.ProduktID, p.KategorieID, p.MwStSatz, a.VK2024,
           EK2024 = ROUND(a.VK2024 / (1 + p.MwStSatz)
                    * (1 - CHOOSE(p.KategorieID, 0.35, 0.22, 0.28, 0.45, 0.30, 0.33, 0.27, 0.38)   -- Kategorienspanne
                         - IIF(p.IstEigenmarke = 1, 0.05, 0)                                       -- Eigenmarken-Bonus
                         + (z.Z - 0.5) * 0.08), 4)                                                 -- Artikelstreuung ±4 %
    FROM dbo.Produkte p
    JOIN util.Artikelparameter a ON a.ProduktID = p.ProduktID
    CROSS APPLY util.fn_Zufall(p.ProduktID, 11) z
),
Faktoren AS (
    SELECT *,
           VK2025 = FLOOR(VK2024 * IIF(KategorieID = 2, 1.06, 1.035) * 10) / 10 + 0.09,
           EK2025 = EK2024 * IIF(KategorieID = 2, 1.06, 1.04)
    FROM Basis
)
INSERT INTO dbo.Preishistorie (ProduktID, GueltigAb, GueltigBis, VK_Brutto, EK_Netto)
SELECT ProduktID, '2024-01-01', '2024-12-31', VK2024, EK2024 FROM Faktoren
UNION ALL
SELECT ProduktID, '2025-01-01', '2025-12-31', IIF(VK2025 < VK2024, VK2024, VK2025), ROUND(EK2025, 4) FROM Faktoren
UNION ALL
SELECT ProduktID, '2026-01-01', '9999-12-31',
       FLOOR(IIF(VK2025 < VK2024, VK2024, VK2025) * 1.025 * 10) / 10 + 0.09,
       ROUND(EK2025 * CASE KategorieID WHEN 2 THEN 1.09 WHEN 3 THEN 1.06 ELSE 1.03 END, 4)
FROM Faktoren;
GO

/* =====================================================================================
   [4/10] Mitarbeiter, Kunden (Kundenkarte), Aktionen
   ===================================================================================== */
PRINT N'[4/10] Mitarbeiter, Kundenkarten und Aktionen';

CREATE TABLE util.Vornamen (Geschlecht CHAR(1), Idx INT, Vorname NVARCHAR(30), PRIMARY KEY (Geschlecht, Idx));
INSERT INTO util.Vornamen
SELECT 'w', ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, v FROM (VALUES
 (N'Anna'),(N'Maria'),(N'Laura'),(N'Julia'),(N'Sarah'),(N'Lena'),(N'Lisa'),(N'Katharina'),(N'Sabine'),(N'Petra'),
 (N'Monika'),(N'Claudia'),(N'Andrea'),(N'Stefanie'),(N'Nicole'),(N'Sandra'),(N'Melanie'),(N'Christina'),(N'Jana'),(N'Lea'),
 (N'Hannah'),(N'Emma'),(N'Mia'),(N'Sophie'),(N'Johanna'),(N'Ursula'),(N'Renate'),(N'Birgit'),(N'Jessica'),(N'Elena'),
 (N'Natalia'),(N'Olga'),(N'Ayşe'),(N'Fatma'),(N'Marta'),(N'Jasmin'),(N'Svenja'),(N'Kerstin'),(N'Heike'),(N'Ingrid')) v(v);
INSERT INTO util.Vornamen
SELECT 'm', ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, v FROM (VALUES
 (N'Thomas'),(N'Michael'),(N'Andreas'),(N'Stefan'),(N'Christian'),(N'Markus'),(N'Daniel'),(N'Alexander'),(N'Peter'),(N'Frank'),
 (N'Jan'),(N'Tobias'),(N'Lukas'),(N'Felix'),(N'Jonas'),(N'Leon'),(N'Paul'),(N'Maximilian'),(N'Sebastian'),(N'Florian'),
 (N'Matthias'),(N'Klaus'),(N'Jürgen'),(N'Uwe'),(N'Wolfgang'),(N'Dieter'),(N'Sven'),(N'Dennis'),(N'Kevin'),(N'Niklas'),
 (N'Dmitri'),(N'Sergej'),(N'Mehmet'),(N'Ali'),(N'Piotr'),(N'Marco'),(N'Timo'),(N'Bernd'),(N'Ralf'),(N'Oliver')) v(v);

CREATE TABLE util.Nachnamen (Idx INT PRIMARY KEY, Nachname NVARCHAR(30));
INSERT INTO util.Nachnamen
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, v FROM (VALUES
 (N'Müller'),(N'Schmidt'),(N'Schneider'),(N'Fischer'),(N'Weber'),(N'Meyer'),(N'Wagner'),(N'Becker'),(N'Schulz'),(N'Hoffmann'),
 (N'Schäfer'),(N'Koch'),(N'Bauer'),(N'Richter'),(N'Klein'),(N'Wolf'),(N'Schröder'),(N'Neumann'),(N'Schwarz'),(N'Zimmermann'),
 (N'Braun'),(N'Krüger'),(N'Hofmann'),(N'Hartmann'),(N'Lange'),(N'Schmitt'),(N'Werner'),(N'Schmitz'),(N'Krause'),(N'Meier'),
 (N'Lehmann'),(N'Schmid'),(N'Schulze'),(N'Maier'),(N'Köhler'),(N'Herrmann'),(N'König'),(N'Walter'),(N'Mayer'),(N'Huber'),
 (N'Kaiser'),(N'Fuchs'),(N'Peters'),(N'Lang'),(N'Scholz'),(N'Möller'),(N'Weiß'),(N'Jung'),(N'Hahn'),(N'Vogel'),
 (N'Friedrich'),(N'Keller'),(N'Günther'),(N'Frank'),(N'Berger'),(N'Winkler'),(N'Roth'),(N'Beck'),(N'Lorenz'),(N'Baumann'),
 (N'Yılmaz'),(N'Kaya'),(N'Nowak'),(N'Kowalski'),(N'Popov'),(N'Fritzler'),(N'Janssen'),(N'Albers'),(N'Brandt'),(N'Haase')) v(v);
GO

CREATE TABLE dbo.Mitarbeiter (
    MitarbeiterID   INT           NOT NULL PRIMARY KEY,
    Personalnummer  CHAR(6)       NOT NULL UNIQUE,
    Vorname         NVARCHAR(30)  NOT NULL,
    Nachname        NVARCHAR(30)  NOT NULL,
    Position        NVARCHAR(30)  NOT NULL,
    FilialeID       INT           NOT NULL REFERENCES dbo.Filialen (FilialeID),
    Eintrittsdatum  DATE          NOT NULL
);

;WITH M AS (
    SELECT MitarbeiterID = (f.FilialeID - 1) * 8 + s.n + 1, f.FilialeID, Stelle = s.n, f.Eroeffnungsdatum
    FROM dbo.Filialen f CROSS JOIN (SELECT n FROM util.Zahlen WHERE n < 8) s
)
INSERT INTO dbo.Mitarbeiter
SELECT M.MitarbeiterID,
       CONCAT('P', RIGHT(CONCAT('00000', 10000 + M.MitarbeiterID), 5)),
       v.Vorname, nn.Nachname,
       CASE WHEN M.Stelle = 0 THEN N'Filialleitung'
            WHEN M.Stelle = 1 THEN N'Stellv. Filialleitung'
            WHEN M.Stelle <= 5 THEN N'Kassierer/in'
            ELSE N'Verkäufer/in' END,
       M.FilialeID,
       DATEADD(DAY, CAST(z3.Z * DATEDIFF(DAY, M.Eroeffnungsdatum, '2024-06-30') AS INT), M.Eroeffnungsdatum)
FROM M
CROSS APPLY util.fn_Zufall(M.MitarbeiterID, 21) z1
CROSS APPLY util.fn_Zufall(M.MitarbeiterID, 22) z2
CROSS APPLY util.fn_Zufall(M.MitarbeiterID, 23) z3
JOIN util.Vornamen  v  ON v.Geschlecht = IIF(z1.Z < 0.6, 'w', 'm') AND v.Idx = CAST(z2.Z * 40 AS INT)
JOIN util.Nachnamen nn ON nn.Idx = CAST(z3.Z * 70 AS INT);

-- Bielefeld wurde erst 2024 eröffnet: Eintrittsdatum frühestens zur Eröffnung
UPDATE dbo.Mitarbeiter SET Eintrittsdatum = DATEADD(DAY, -14 + MitarbeiterID % 10, '2024-09-02') WHERE FilialeID = 5;

-- Kassenpersonal je Filiale (Stellv. Filialleitung, 4 Kassierer/innen, 1 Verkäufer/in) mit Index 0–5
CREATE TABLE util.Kassenpersonal (FilialeID INT, Idx INT, MitarbeiterID INT, PRIMARY KEY (FilialeID, Idx));
INSERT INTO util.Kassenpersonal
SELECT FilialeID, ROW_NUMBER() OVER (PARTITION BY FilialeID ORDER BY MitarbeiterID) - 1, MitarbeiterID
FROM dbo.Mitarbeiter
WHERE (MitarbeiterID - 1) % 8 BETWEEN 1 AND 6;
GO

CREATE TABLE dbo.Kunden (
    KundeID              INT            NOT NULL PRIMARY KEY,
    Kundennummer         CHAR(8)        NOT NULL UNIQUE,
    Anrede               NVARCHAR(10)   NOT NULL,
    Vorname              NVARCHAR(30)   NOT NULL,
    Nachname             NVARCHAR(30)   NOT NULL,
    Geschlecht           CHAR(1)        NOT NULL,     -- w | m | d
    Geburtsdatum         DATE           NOT NULL,
    PLZ                  CHAR(5)        NOT NULL,
    Stadt                NVARCHAR(40)   NOT NULL,
    Email                NVARCHAR(100)  NOT NULL,
    NewsletterOptIn      BIT            NOT NULL,
    Registrierungsdatum  DATE           NOT NULL,
    StammfilialeID       INT            NOT NULL REFERENCES dbo.Filialen (FilialeID)
);

-- Verborgenes Kundenverhalten (wird am Ende gelöscht – die Analysen müssen es selbst aufdecken)
CREATE TABLE util.Kundenverhalten (KundeID INT PRIMARY KEY, Gewicht INT, Abwanderungsdatum DATE NULL);

;WITH K AS (
    SELECT KundeID = n + 1 FROM util.Zahlen WHERE n < 3000
),
R AS (
    SELECT K.KundeID, z1.Z AS zG, z2.Z AS zV, z3.Z AS zN, z4.Z AS zA, z5.Z AS zF, z6.Z AS zR, z7.Z AS zP, z8.Z AS zNL
    FROM K
    CROSS APPLY util.fn_Zufall(K.KundeID, 31) z1 CROSS APPLY util.fn_Zufall(K.KundeID, 32) z2
    CROSS APPLY util.fn_Zufall(K.KundeID, 33) z3 CROSS APPLY util.fn_Zufall(K.KundeID, 34) z4
    CROSS APPLY util.fn_Zufall(K.KundeID, 35) z5 CROSS APPLY util.fn_Zufall(K.KundeID, 36) z6
    CROSS APPLY util.fn_Zufall(K.KundeID, 37) z7 CROSS APPLY util.fn_Zufall(K.KundeID, 38) z8
),
B AS (
    SELECT R.*,
           Geschlecht = CASE WHEN zG < 0.01 THEN 'd' WHEN zG < 0.53 THEN 'w' ELSE 'm' END,
           FilialeID  = CASE WHEN zF < 0.22 THEN 1 WHEN zF < 0.35 THEN 2 WHEN zF < 0.53 THEN 3 WHEN zF < 0.68 THEN 4 ELSE 5 END
    FROM R
)
INSERT INTO dbo.Kunden
SELECT B.KundeID,
       CONCAT('K-', 100000 + B.KundeID),
       CASE B.Geschlecht WHEN 'w' THEN N'Frau' WHEN 'm' THEN N'Herr' ELSE N'Divers' END,
       v.Vorname, nn.Nachname, B.Geschlecht,
       DATEADD(DAY, -CAST((18 + POWER(B.zA, 1.15) * 67) * 365.25 AS INT), CAST('2026-09-30' AS DATE)),
       plz.PLZ, f.Stadt,
       LOWER(CONCAT(
           REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v.Vorname,  N'ä',N'ae'),N'ö',N'oe'),N'ü',N'ue'),N'ß',N'ss'),N'ş',N's'), N'.',
           REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nn.Nachname,N'ä',N'ae'),N'ö',N'oe'),N'ü',N'ue'),N'ß',N'ss'),N'ı',N'i'),
           B.KundeID % 97, N'@beispiel-mail.de')),
       IIF(B.zNL < 0.42, 1, 0),
       CASE WHEN B.FilialeID = 5
            THEN DATEADD(DAY, CAST(POWER(B.zR, 1.5) * 758 AS INT), CAST('2024-09-02' AS DATE))
            ELSE DATEADD(DAY, CAST(POWER(B.zR, 1.8) * 996 AS INT), CAST('2024-01-08' AS DATE)) END,
       B.FilialeID
FROM B
JOIN dbo.Filialen f ON f.FilialeID = B.FilialeID
JOIN util.Vornamen  v  ON v.Geschlecht = IIF(B.Geschlecht = 'd', IIF(B.zV < 0.5, 'w', 'm'), B.Geschlecht) AND v.Idx = CAST(B.zV * 40 AS INT)
JOIN util.Nachnamen nn ON nn.Idx = CAST(B.zN * 70 AS INT)
CROSS APPLY (SELECT PLZ = CASE B.FilialeID
        WHEN 1 THEN CHOOSE(1 + CAST(B.zP * 6 AS INT), '30159','30161','30163','30169','30171','30173')
        WHEN 2 THEN CHOOSE(1 + CAST(B.zP * 4 AS INT), '30161','30163','30177','30655')
        WHEN 3 THEN CHOOSE(1 + CAST(B.zP * 6 AS INT), '38100','38102','38104','38106','38114','38118')
        WHEN 4 THEN CHOOSE(1 + CAST(B.zP * 5 AS INT), '31134','31135','31137','31139','31141')
        ELSE        CHOOSE(1 + CAST(B.zP * 6 AS INT), '33602','33604','33605','33607','33609','33611') END) plz;

-- Kaufhäufigkeit (Stammkunde 15 % | Regelmäßig 35 % | Gelegentlich 50 %) und Abwanderung
;WITH S AS (
    SELECT k.KundeID, k.Registrierungsdatum, z1.Z AS zS, z2.Z AS zC, z3.Z AS zD
    FROM dbo.Kunden k
    CROSS APPLY util.fn_Zufall(k.KundeID, 41) z1
    CROSS APPLY util.fn_Zufall(k.KundeID, 42) z2
    CROSS APPLY util.fn_Zufall(k.KundeID, 43) z3
),
T AS (
    SELECT *, Gewicht = CASE WHEN zS < 0.15 THEN 12 WHEN zS < 0.50 THEN 5 ELSE 1 END,
              Quote   = CASE WHEN zS < 0.15 THEN 0.10 WHEN zS < 0.50 THEN 0.25 ELSE 0.40 END
    FROM S
)
INSERT INTO util.Kundenverhalten
SELECT KundeID, Gewicht,
       CASE WHEN zC < Quote AND DATEADD(DAY, 45 + CAST(zD * 700 AS INT), Registrierungsdatum) <= '2026-09-30'
            THEN DATEADD(DAY, 45 + CAST(zD * 700 AS INT), Registrierungsdatum) END
FROM T;

-- Gewichteter Kundenpool je Stammfiliale (häufige Käufer kommen mehrfach vor)
CREATE TABLE util.Kundenpool (FilialeID INT, Idx INT, KundeID INT, PRIMARY KEY (FilialeID, Idx));
INSERT INTO util.Kundenpool
SELECT k.StammfilialeID, ROW_NUMBER() OVER (PARTITION BY k.StammfilialeID ORDER BY k.KundeID, z.n) - 1, k.KundeID
FROM dbo.Kunden k
JOIN util.Kundenverhalten kv ON kv.KundeID = k.KundeID
JOIN util.Zahlen z ON z.n < kv.Gewicht;
GO

CREATE TABLE dbo.Aktionen (
    AktionID       INT            NOT NULL PRIMARY KEY,
    AktionName     NVARCHAR(80)   NOT NULL,
    Aktionstyp     NVARCHAR(30)   NOT NULL,
    KategorieID    INT            NOT NULL REFERENCES dbo.Kategorien (KategorieID),
    RabattProzent  DECIMAL(4,2)   NOT NULL,
    StartDatum     DATE           NOT NULL,
    EndDatum       DATE           NOT NULL
);

;WITH A AS (
    SELECT AktionID = n + 1,
           StartDatum  = DATEADD(DAY, n * 21, CAST('2024-01-08' AS DATE)),
           KategorieID = (n * 5) % 8 + 1,
           n
    FROM util.Zahlen WHERE n < 48
)
INSERT INTO dbo.Aktionen
SELECT A.AktionID,
       CONCAT(t.Typ, N' ', k.KategorieName, N' (KW ', DATEPART(ISO_WEEK, A.StartDatum), N'/', YEAR(A.StartDatum), N')'),
       t.Typ, A.KategorieID, r.Rabatt, A.StartDatum,
       DATEADD(DAY, IIF(z2.Z < 0.6, 5, 12), A.StartDatum)          -- Mo–Sa (1 Woche) oder 2 Wochen
FROM A
JOIN dbo.Kategorien k ON k.KategorieID = A.KategorieID
CROSS APPLY util.fn_Zufall(A.AktionID, 51) z1
CROSS APPLY util.fn_Zufall(A.AktionID, 52) z2
CROSS APPLY (SELECT Rabatt = CAST(CHOOSE(1 + CAST(z1.Z * 5 AS INT), 0.10, 0.15, 0.20, 0.25, 0.30) AS DECIMAL(4,2))) r
CROSS APPLY (SELECT Typ = CASE WHEN MONTH(A.StartDatum) = 12 THEN N'Weihnachtsaktion'
                               WHEN r.Rabatt >= 0.25 THEN N'Preis-Knaller'
                               ELSE N'Wochenangebot' END) t
WHERE A.StartDatum <= '2026-09-19';
GO

/* =====================================================================================
   [5/10] Kassenbons
   ===================================================================================== */
PRINT N'[5/10] Kassenbons erzeugen';

-- Öffnungstage je Filiale mit erwarteter Bonanzahl
-- Eingebaute Muster: Wochentag, Monat/Weihnachten, Brückentage vor Feiertagen, Wachstum +3 % p. a.,
-- Neueröffnung Bielefeld (Anlaufkurve), Wettbewerber-Eröffnung in Braunschweig ab 06/2025
-- (Faktor 0,84 auf die erwartete Bonanzahl; im Ergebnis ca. −14 % Bons und −11 % Umsatz,
--  weil Wachstum und Saisonalität gegenläufig wirken)
SELECT d.Datum, d.DatumKey, d.WochentagNr, d.MonatNr, f.FilialeID,
       Anzahl = CAST(ROUND(
                p.Basis
              * CHOOSE(d.WochentagNr, 0.90, 0.88, 0.92, 0.98, 1.15, 1.30)
              * CHOOSE(d.MonatNr, 0.88, 0.90, 0.97, 1.00, 1.00, 1.02, 1.00, 0.98, 1.00, 1.00, 1.03, 1.18)
              * (1 + 0.03 * DATEDIFF(DAY, '2024-01-01', d.Datum) / 365.0)
              * CASE WHEN MONTH(d.Datum) = 12 AND DAY(d.Datum) BETWEEN 20 AND 23 THEN 1.45
                     WHEN EXISTS (SELECT 1 FROM dbo.Feiertage h WHERE h.Datum = DATEADD(DAY, 1, d.Datum) AND h.Bundesland IN ('ALLE', f.BundeslandKz)) THEN 1.30
                     ELSE 1.0 END
              * IIF(f.FilialeID = 3 AND d.Datum >= '2025-06-01', 0.84, 1.0)
              * IIF(f.FilialeID = 5, IIF(DATEDIFF(DAY, '2024-09-02', d.Datum) >= 270, 1.0, 0.55 + 0.45 * DATEDIFF(DAY, '2024-09-02', d.Datum) / 270.0), 1.0)
              * (0.85 + 0.30 * z.Z), 0) AS INT)
INTO #Filialtage
FROM dwh.dim_datum d
CROSS JOIN dbo.Filialen f
JOIN (VALUES (1, 55), (2, 32), (3, 45), (4, 38), (5, 60)) p(FilialeID, Basis) ON p.FilialeID = f.FilialeID
CROSS APPLY util.fn_Zufall(CAST(d.DatumKey AS BIGINT) * 10 + f.FilialeID, 61) z
WHERE d.Datum BETWEEN '2024-01-02' AND '2026-09-30'
  AND d.Datum >= f.Eroeffnungsdatum
  AND d.WochentagNr <> 7
  AND NOT EXISTS (SELECT 1 FROM dbo.Feiertage h WHERE h.Datum = d.Datum AND h.Bundesland IN ('ALLE', f.BundeslandKz));

-- Stundenverteilung der Einkäufe (Mittags- und Feierabendspitze)
CREATE TABLE util.Stunden (Stunde INT PRIMARY KEY, KumVon FLOAT, KumBis FLOAT);
;WITH S AS (SELECT * FROM (VALUES (7,3),(8,5),(9,6),(10,7),(11,9),(12,9),(13,7),(14,6),(15,7),(16,9),(17,11),(18,10),(19,7),(20,4)) v(Stunde, Gewicht))
INSERT INTO util.Stunden
SELECT Stunde,
       1.0 * (SUM(Gewicht) OVER (ORDER BY Stunde) - Gewicht) / SUM(Gewicht) OVER (),
       1.0 *  SUM(Gewicht) OVER (ORDER BY Stunde)            / SUM(Gewicht) OVER ()
FROM S;

SELECT ft.Datum, ft.DatumKey, ft.WochentagNr, ft.MonatNr, ft.FilialeID, Nr = z.n,
       Schluessel = CAST(ft.DatumKey AS BIGINT) * 100000 + ft.FilialeID * 10000 + z.n
INTO #BonRoh
FROM #Filialtage ft
JOIN util.Zahlen z ON z.n < ft.Anzahl;

SELECT r.*,
       Uhrzeit = TIMEFROMPARTS(st.Stunde, CAST(zm.Z * 60 AS INT), CAST(zs.Z * 60 AS INT), 0, 0),
       KundeID = CASE WHEN zk.Z < 0.65
                       AND k.Registrierungsdatum <= r.Datum
                       AND (kv.Abwanderungsdatum IS NULL OR kv.Abwanderungsdatum > r.Datum)
                      THEN k.KundeID END,
       MitarbeiterID = kp.MitarbeiterID,
       Zahlungsart = CASE
            WHEN zz.Z < 0.45 - 0.15 * t.Anteil THEN N'Bar'
            WHEN zz.Z < 0.83 - 0.15 * t.Anteil THEN N'Girocard'
            WHEN zz.Z < 0.90 - 0.15 * t.Anteil THEN N'Kreditkarte'
            ELSE N'Mobile Payment' END,
       PosAnzahl = 1 + CAST(POWER(zp.Z, 1.6) * IIF(r.WochentagNr = 6, 11, 9) AS INT)
INTO #Bons
FROM #BonRoh r
CROSS APPLY util.fn_Zufall(r.Schluessel, 71) zh
CROSS APPLY util.fn_Zufall(r.Schluessel, 72) zm
CROSS APPLY util.fn_Zufall(r.Schluessel, 73) zs
CROSS APPLY util.fn_Zufall(r.Schluessel, 74) zk
CROSS APPLY util.fn_Zufall(r.Schluessel, 75) zi
CROSS APPLY util.fn_Zufall(r.Schluessel, 76) zc
CROSS APPLY util.fn_Zufall(r.Schluessel, 77) zz
CROSS APPLY util.fn_Zufall(r.Schluessel, 78) zp
CROSS APPLY (SELECT Anteil = DATEDIFF(DAY, '2024-01-01', r.Datum) / 1004.0) t
JOIN util.Stunden st ON zh.Z >= st.KumVon AND zh.Z < st.KumBis
JOIN util.Kassenpersonal kp ON kp.FilialeID = r.FilialeID AND kp.Idx = CAST(zc.Z * 6 AS INT)
CROSS APPLY (SELECT Groesse = COUNT(*) FROM util.Kundenpool WHERE FilialeID = r.FilialeID) ps
LEFT JOIN util.Kundenpool kpool ON kpool.FilialeID = r.FilialeID AND kpool.Idx = CAST(zi.Z * ps.Groesse AS INT)
LEFT JOIN dbo.Kunden k ON k.KundeID = kpool.KundeID
LEFT JOIN util.Kundenverhalten kv ON kv.KundeID = k.KundeID;

CREATE TABLE dbo.Bons (
    BonID          INT            NOT NULL PRIMARY KEY,
    BonNummer      VARCHAR(20)    NOT NULL UNIQUE,
    FilialeID      INT            NOT NULL REFERENCES dbo.Filialen (FilialeID),
    BonDatum       DATE           NOT NULL,
    BonUhrzeit     TIME(0)        NOT NULL,
    KundeID        INT            NULL REFERENCES dbo.Kunden (KundeID),        -- NULL = ohne Kundenkarte
    MitarbeiterID  INT            NOT NULL REFERENCES dbo.Mitarbeiter (MitarbeiterID),
    Zahlungsart    NVARCHAR(20)   NOT NULL
);

INSERT INTO dbo.Bons (BonID, BonNummer, FilialeID, BonDatum, BonUhrzeit, KundeID, MitarbeiterID, Zahlungsart)
SELECT ROW_NUMBER() OVER (ORDER BY Datum, Uhrzeit, FilialeID, Nr),
       CONCAT('F0', FilialeID, '-', CONVERT(CHAR(8), Datum, 112), '-',
              RIGHT(CONCAT('0000', ROW_NUMBER() OVER (PARTITION BY FilialeID, Datum ORDER BY Uhrzeit, Nr)), 4)),
       FilialeID, Datum, Uhrzeit, KundeID, MitarbeiterID, Zahlungsart
FROM #Bons;

-- Positionsanzahl an die endgültige BonID binden (identische Sortierung wie beim INSERT oben)
SELECT BonID = ROW_NUMBER() OVER (ORDER BY Datum, Uhrzeit, FilialeID, Nr), Datum AS BonDatum, MonatNr, PosAnzahl
INTO #BonPos
FROM #Bons;

CREATE CLUSTERED INDEX CX_BonPos ON #BonPos (BonID);
GO

/* =====================================================================================
   [6/10] Bonpositionen
   ===================================================================================== */
PRINT N'[6/10] Bonpositionen erzeugen';

-- Gewichteter Artikelpool je Saison: N = Normal, S = Sommer (Jun–Aug), W = Winter (Nov–Dez)
CREATE TABLE util.Artikelpool (PoolTyp CHAR(1), Idx INT, ProduktID INT, PRIMARY KEY (PoolTyp, Idx));
;WITH G AS (
    SELECT p.ProduktID, t.PoolTyp,
           Gewicht = a.Beliebtheit * CASE
                WHEN p.Saisonprofil = N'Ganzjährig' THEN 10
                WHEN p.Saisonprofil = N'Sommer' THEN CASE t.PoolTyp WHEN 'S' THEN 30 WHEN 'N' THEN 10 ELSE 3 END
                WHEN p.Saisonprofil = N'Winter' THEN CASE t.PoolTyp WHEN 'W' THEN 40 ELSE 0 END END
    FROM dbo.Produkte p
    JOIN util.Artikelparameter a ON a.ProduktID = p.ProduktID
    CROSS JOIN (VALUES ('N'), ('S'), ('W')) t(PoolTyp)
)
INSERT INTO util.Artikelpool
SELECT G.PoolTyp, ROW_NUMBER() OVER (PARTITION BY G.PoolTyp ORDER BY G.ProduktID, z.n) - 1, G.ProduktID
FROM G JOIN util.Zahlen z ON z.n < G.Gewicht;

CREATE TABLE util.Artikelpoolgroesse (PoolTyp CHAR(1) PRIMARY KEY, Groesse INT);
INSERT INTO util.Artikelpoolgroesse SELECT PoolTyp, COUNT(*) FROM util.Artikelpool GROUP BY PoolTyp;

SELECT b.BonID, b.BonDatum, PosNr = z.n,
       PoolTyp = CASE WHEN b.MonatNr IN (6,7,8) THEN 'S' WHEN b.MonatNr IN (11,12) THEN 'W' ELSE 'N' END,
       Schluessel = CAST(b.BonID AS BIGINT) * 20 + z.n
INTO #PosRoh
FROM #BonPos b
JOIN util.Zahlen z ON z.n < b.PosAnzahl;

SELECT r.BonID, r.BonDatum, ap.ProduktID,
       Menge = CASE WHEN zm.Z < 0.04 THEN 3 WHEN zm.Z < 0.16 THEN 2 ELSE 1 END,
       zA = za.Z, zB = zb.Z
INTO #Pos
FROM #PosRoh r
JOIN util.Artikelpoolgroesse g ON g.PoolTyp = r.PoolTyp
CROSS APPLY util.fn_Zufall(r.Schluessel, 81) zp
CROSS APPLY util.fn_Zufall(r.Schluessel, 82) zm
CROSS APPLY util.fn_Zufall(r.Schluessel, 83) za
CROSS APPLY util.fn_Zufall(r.Schluessel, 84) zb
JOIN util.Artikelpool ap ON ap.PoolTyp = r.PoolTyp AND ap.Idx = CAST(zp.Z * g.Groesse AS INT);

CREATE TABLE dbo.Bonpositionen (
    PositionID     INT            NOT NULL PRIMARY KEY,
    BonID          INT            NOT NULL REFERENCES dbo.Bons (BonID),
    PosNr          SMALLINT       NOT NULL,
    ProduktID      INT            NOT NULL REFERENCES dbo.Produkte (ProduktID),
    Menge          SMALLINT       NOT NULL,
    Einzelpreis    DECIMAL(10,2)  NOT NULL,   -- Verkaufspreis brutto je Einheit (Regalpreis)
    RabattBetrag   DECIMAL(10,2)  NOT NULL,   -- Aktionsrabatt brutto für die gesamte Position
    AktionID       INT            NULL REFERENCES dbo.Aktionen (AktionID),
    MwStSatz       DECIMAL(4,2)   NOT NULL,
    EK_Netto       DECIMAL(10,4)  NOT NULL,   -- Einstandspreis netto je Einheit zum Verkaufszeitpunkt
    CONSTRAINT UQ_Bonposition UNIQUE (BonID, PosNr)
);

;WITH Zusammengefasst AS (           -- gleicher Artikel mehrfach gescannt → eine Position
    SELECT BonID, BonDatum, ProduktID, Menge = SUM(Menge), zA = MIN(zA), zB = MIN(zB)
    FROM #Pos
    GROUP BY BonID, BonDatum, ProduktID
),
MitAktion AS (
    SELECT z.*, p.KategorieID, p.MwStSatz,
           AktionID = IIF(a.AktionID IS NOT NULL AND z.zA < 0.65, a.AktionID, NULL),
           a.RabattProzent
    FROM Zusammengefasst z
    JOIN dbo.Produkte p ON p.ProduktID = z.ProduktID
    LEFT JOIN dbo.Aktionen a ON a.KategorieID = p.KategorieID AND z.BonDatum BETWEEN a.StartDatum AND a.EndDatum
)
INSERT INTO dbo.Bonpositionen (PositionID, BonID, PosNr, ProduktID, Menge, Einzelpreis, RabattBetrag, AktionID, MwStSatz, EK_Netto)
SELECT ROW_NUMBER() OVER (ORDER BY m.BonID, m.ProduktID),
       m.BonID,
       ROW_NUMBER() OVER (PARTITION BY m.BonID ORDER BY m.ProduktID),
       m.ProduktID,
       m.Menge + IIF(m.AktionID IS NOT NULL AND m.zB < 0.35, 1, 0),                      -- Aktionen erhöhen die Menge
       ph.VK_Brutto,
       IIF(m.AktionID IS NOT NULL,
           ROUND((m.Menge + IIF(m.zB < 0.35, 1, 0)) * ph.VK_Brutto * m.RabattProzent, 2), 0),
       m.AktionID, m.MwStSatz, ph.EK_Netto
FROM MitAktion m
JOIN dbo.Preishistorie ph ON ph.ProduktID = m.ProduktID AND m.BonDatum BETWEEN ph.GueltigAb AND ph.GueltigBis;
GO

-- Hinweis: Die Spaltenliste im INSERT oben legt die Zuordnung fest (PositionID, BonID, PosNr, …),
-- nicht die Reihenfolge im SELECT. Die Plausibilitätsprüfung am Ende verifiziert, dass PosNr je Bon bei 1 beginnt.
/* =====================================================================================
   [7/10] Abschreibungen & Verderb (MHD-Verluste, Bruch, Diebstahl)
   ===================================================================================== */
PRINT N'[7/10] Abschreibungen und Warenverderb (Losses / Shrinkage)';

CREATE TABLE dbo.Abschreibungen (
    AbschreibungID    INT            NOT NULL PRIMARY KEY,
    FilialeID         INT            NOT NULL REFERENCES dbo.Filialen (FilialeID),
    Datum             DATE           NOT NULL,
    ProduktID         INT            NOT NULL REFERENCES dbo.Produkte (ProduktID),
    Menge             INT            NOT NULL,
    Grund             NVARCHAR(30)   NOT NULL,   -- 'MHD abgelaufen' | 'Bruch/Beschädigung' | 'Inventurdifferenz'
    EK_Netto          DECIMAL(10,4)  NOT NULL,
    GesamtverlustNetto AS CAST(Menge * EK_Netto AS DECIMAL(10,2)) PERSISTED
);

-- Realistisches Muster: Frischekategorien (Obst/Gemüse, Molkerei, Fleisch, Backwaren) haben 80%+ des Verderbs
;WITH TageFrische AS (
    SELECT d.Datum, f.FilialeID, p.ProduktID, p.KategorieID,
           Schluessel = CAST(d.DatumKey AS BIGINT) * 1000 + f.FilialeID * 100 + p.ProduktID
    FROM dwh.dim_datum d
    CROSS JOIN dbo.Filialen f
    CROSS JOIN dbo.Produkte p
    WHERE d.Datum BETWEEN '2024-01-02' AND '2026-09-30'
      AND d.Datum >= f.Eroeffnungsdatum
      AND d.IstVerkaufstag = 1
      AND p.KategorieID IN (1, 2, 3, 4) -- Nur Frischeprodukte haben tägliche Abschreibungen
),
Kandidaten AS (
    SELECT tf.*, z1.Z AS zWahrsch, z2.Z AS zMenge, z3.Z AS zGrund
    FROM TageFrische tf
    CROSS APPLY util.fn_Zufall(tf.Schluessel, 91) z1
    CROSS APPLY util.fn_Zufall(tf.Schluessel, 92) z2
    CROSS APPLY util.fn_Zufall(tf.Schluessel, 93) z3
    WHERE z1.Z < 0.045 -- ca. 4.5% Chance pro Tag/Produkt/Filiale
)
INSERT INTO dbo.Abschreibungen (AbschreibungID, FilialeID, Datum, ProduktID, Menge, Grund, EK_Netto)
SELECT ROW_NUMBER() OVER (ORDER BY k.Datum, k.FilialeID, k.ProduktID),
       k.FilialeID, k.Datum, k.ProduktID,
       Menge = 1 + CAST(POWER(k.zMenge, 1.8) * 8 AS INT),
       Grund = CASE WHEN k.zGrund < 0.70 THEN N'MHD abgelaufen'
                    WHEN k.zGrund < 0.90 THEN N'Bruch/Beschädigung'
                    ELSE N'Qualitätsmangel' END,
       ph.EK_Netto
FROM Kandidaten k
JOIN dbo.Preishistorie ph ON ph.ProduktID = k.ProduktID AND k.Datum BETWEEN ph.GueltigAb AND ph.GueltigBis;
GO

/* =====================================================================================
   [8/10] Sternschema Views & Tabellen für Power BI (dwh-Schema)
   ===================================================================================== */
PRINT N'[8/10] Sternschema Dimensionen & Fakten (dwh-Schema)';
GO

-- dim_filiale
CREATE VIEW dwh.dim_filiale AS
SELECT 
    FilialeID,
    Filialcode,
    FilialName,
    Strasse,
    PLZ,
    Stadt,
    Bundesland,
    BundeslandKz,
    Region,
    VerkaufsflaecheQM,
    Eroeffnungsdatum
FROM dbo.Filialen;
GO

-- dim_produkt
CREATE VIEW dwh.dim_produkt AS
SELECT 
    p.ProduktID,
    p.EAN,
    p.ProduktName,
    k.KategorieID,
    k.KategorieName,
    k.Warenbereich,
    k.IstFrischware,
    p.Marke,
    p.IstEigenmarke,
    p.Saisonprofil,
    p.MwStSatz,
    ph.VK_Brutto AS Aktueller_VK_Brutto,
    ph.EK_Netto  AS Aktueller_EK_Netto,
    ROUND((ph.VK_Brutto / (1 + p.MwStSatz)) - ph.EK_Netto, 2) AS Aktuelle_Spanne_Netto
FROM dbo.Produkte p
JOIN dbo.Kategorien k ON k.KategorieID = p.KategorieID
JOIN dbo.Preishistorie ph ON ph.ProduktID = p.ProduktID AND CAST('2026-09-30' AS DATE) BETWEEN ph.GueltigAb AND ph.GueltigBis;
GO

-- dim_kunde
CREATE VIEW dwh.dim_kunde AS
SELECT 
    k.KundeID,
    k.Kundennummer,
    k.Anrede,
    k.Vorname,
    k.Nachname,
    CONCAT(k.Vorname, N' ', k.Nachname) AS KundenName,
    k.Geschlecht,
    k.Geburtsdatum,
    DATEDIFF(YEAR, k.Geburtsdatum, '2026-09-30') AS AlterJahre,
    CASE WHEN DATEDIFF(YEAR, k.Geburtsdatum, '2026-09-30') < 30 THEN N'18-29'
         WHEN DATEDIFF(YEAR, k.Geburtsdatum, '2026-09-30') < 50 THEN N'30-49'
         WHEN DATEDIFF(YEAR, k.Geburtsdatum, '2026-09-30') < 65 THEN N'50-64'
         ELSE N'65+' END AS Altersgruppe,
    k.PLZ,
    k.Stadt,
    k.Email,
    k.NewsletterOptIn,
    k.Registrierungsdatum,
    k.StammfilialeID
FROM dbo.Kunden k;
GO

-- dim_mitarbeiter
CREATE VIEW dwh.dim_mitarbeiter AS
SELECT 
    m.MitarbeiterID,
    m.Personalnummer,
    CONCAT(m.Vorname, N' ', m.Nachname) AS MitarbeiterName,
    m.Position,
    m.FilialeID,
    m.Eintrittsdatum
FROM dbo.Mitarbeiter m;
GO

-- fct_verkaeufe (Materialisierte Faktentabelle für höchste Abfrage-Performance)
CREATE TABLE dwh.fct_verkaeufe (
    PositionID         INT            NOT NULL PRIMARY KEY,
    BonID              INT            NOT NULL,
    DatumKey           INT            NOT NULL REFERENCES dwh.dim_datum (DatumKey),
    BonDatum           DATE           NOT NULL,
    BonUhrzeit         TIME(0)        NOT NULL,
    FilialeID          INT            NOT NULL REFERENCES dbo.Filialen (FilialeID),
    KundeID            INT            NULL REFERENCES dbo.Kunden (KundeID),
    MitarbeiterID      INT            NOT NULL REFERENCES dbo.Mitarbeiter (MitarbeiterID),
    ProduktID          INT            NOT NULL REFERENCES dbo.Produkte (ProduktID),
    AktionID           INT            NULL REFERENCES dbo.Aktionen (AktionID),
    Menge              SMALLINT       NOT NULL,
    Einzelpreis        DECIMAL(10,2)  NOT NULL,
    RabattBetrag       DECIMAL(10,2)  NOT NULL,
    UmsatzBrutto       DECIMAL(10,2)  NOT NULL,
    MwStBetrag         DECIMAL(10,2)  NOT NULL,
    UmsatzNetto        DECIMAL(10,2)  NOT NULL,
    WareneinsatzNetto  DECIMAL(10,2)  NOT NULL,
    Deckungsbeitrag    DECIMAL(10,2)  NOT NULL,
    MargeProzent       DECIMAL(5,4)   NOT NULL,
    Zahlungsart        NVARCHAR(20)   NOT NULL
);

INSERT INTO dwh.fct_verkaeufe
SELECT 
    bp.PositionID,
    bp.BonID,
    CONVERT(INT, CONVERT(CHAR(8), b.BonDatum, 112)) AS DatumKey,
    b.BonDatum,
    b.BonUhrzeit,
    b.FilialeID,
    b.KundeID,
    b.MitarbeiterID,
    bp.ProduktID,
    bp.AktionID,
    bp.Menge,
    bp.Einzelpreis,
    bp.RabattBetrag,
    -- Umsatz Brutto
    ROUND(bp.Menge * bp.Einzelpreis - bp.RabattBetrag, 2) AS UmsatzBrutto,
    -- MwSt
    ROUND((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) - ((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz)), 2) AS MwStBetrag,
    -- Umsatz Netto
    ROUND((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz), 2) AS UmsatzNetto,
    -- Wareneinsatz Netto
    ROUND(bp.Menge * bp.EK_Netto, 2) AS WareneinsatzNetto,
    -- Deckungsbeitrag (Rohertrag)
    ROUND(((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz)) - (bp.Menge * bp.EK_Netto), 2) AS Deckungsbeitrag,
    -- Marge %
    CASE WHEN ROUND((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz), 2) > 0
         THEN ROUND((((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz)) - (bp.Menge * bp.EK_Netto))
                    / ((bp.Menge * bp.Einzelpreis - bp.RabattBetrag) / (1 + bp.MwStSatz)), 4)
         ELSE 0.0 END AS MargeProzent,
    b.Zahlungsart
FROM dbo.Bonpositionen bp
JOIN dbo.Bons b ON b.BonID = bp.BonID;

-- Indizes für analytische Queries
CREATE NONCLUSTERED INDEX IX_fct_verkaeufe_DatumKey ON dwh.fct_verkaeufe (DatumKey) INCLUDE (UmsatzBrutto, UmsatzNetto, Deckungsbeitrag);
CREATE NONCLUSTERED INDEX IX_fct_verkaeufe_KundeID ON dwh.fct_verkaeufe (KundeID) INCLUDE (UmsatzNetto, BonDatum);
CREATE NONCLUSTERED INDEX IX_fct_verkaeufe_ProduktID ON dwh.fct_verkaeufe (ProduktID) INCLUDE (Menge, UmsatzNetto, Deckungsbeitrag);
CREATE NONCLUSTERED INDEX IX_fct_verkaeufe_FilialeID ON dwh.fct_verkaeufe (FilialeID) INCLUDE (UmsatzBrutto, Deckungsbeitrag);
GO

/* =====================================================================================
   [9/10] Staging-Schema mit absichtlich „schmutzigen“ Daten für SQL-Cleaning-Modul
   ===================================================================================== */
PRINT N'[9/10] Staging-Tabelle mit typischen Fehlern (Dirty Data für Data Cleaning)';

CREATE TABLE stg.Kunden_Rohimport (
    RohID              INT IDENTITY(1,1) PRIMARY KEY,
    KundenCode         NVARCHAR(50),
    VollstaendigerName NVARCHAR(100),
    GeburtsdatumTxt    NVARCHAR(50),
    StadtPLZ           NVARCHAR(100),
    EmailAdresse       NVARCHAR(150),
    Telefonnummer      NVARCHAR(50),
    ImportZeitstempel   DATETIME DEFAULT GETDATE()
);

-- Befüllen mit echten Kunden + Dubletten, fehlerhaften Leerzeichen, vertauschten Formaten
INSERT INTO stg.Kunden_Rohimport (KundenCode, VollstaendigerName, GeburtsdatumTxt, StadtPLZ, EmailAdresse, Telefonnummer)
SELECT 
    CASE WHEN n % 17 = 0 THEN CONCAT('  ', k.Kundennummer, ' ') -- Leerzeichen-Problem
         WHEN n % 23 = 0 THEN LOWER(k.Kundennummer)             -- Kleinbuchstaben
         ELSE k.Kundennummer END,
    CASE WHEN n % 11 = 0 THEN CONCAT(UPPER(k.Nachname), ', ', k.Vorname) -- Format "Nachname, Vorname"
         WHEN n % 19 = 0 THEN CONCAT('  ', k.Vorname, '   ', k.Nachname, '  ') -- Multiple Spaces
         ELSE CONCAT(k.Vorname, ' ', k.Nachname) END,
    CASE WHEN n % 13 = 0 THEN CONVERT(VARCHAR(10), k.Geburtsdatum, 104) -- 31.12.1990
         WHEN n % 29 = 0 THEN CONVERT(VARCHAR(10), k.Geburtsdatum, 101) -- 12/31/1990
         WHEN n % 41 = 0 THEN 'UNGÜLTIG'                                 -- Datenfehler
         ELSE CONVERT(VARCHAR(10), k.Geburtsdatum, 120) END,            -- 1990-12-31
    CONCAT(k.PLZ, ' ', k.Stadt),
    CASE WHEN n % 31 = 0 THEN REPLACE(k.Email, '@', '@@')               -- E-Mail Syntaxfehler
         WHEN n % 37 = 0 THEN NULL                                      -- Fehlende Mail
         ELSE k.Email END,
    CONCAT('+49 ', 151 + (n % 40), ' ', 1000000 + (n * 37))
FROM dbo.Kunden k
JOIN util.Zahlen z ON z.n < 3; -- Erzeugt bewusst Dubletten!
GO

/* =====================================================================================
   [10/10] Aufräumen & Datenvalidierung
   ===================================================================================== */
PRINT N'[10/10] Validierung des erzeugten Datenbestands:';

-- Aufräumen der internen Hilfstabellen
DROP TABLE IF EXISTS util.Kundenpool;
DROP TABLE IF EXISTS util.Kundenverhalten;
DROP TABLE IF EXISTS util.Artikelpool;
DROP TABLE IF EXISTS util.Artikelpoolgroesse;
DROP TABLE IF EXISTS util.Artikelparameter;
DROP TABLE IF EXISTS util.Vornamen;
DROP TABLE IF EXISTS util.Nachnamen;
DROP TABLE IF EXISTS util.Kassenpersonal;
DROP TABLE IF EXISTS util.Stunden;
GO

SELECT 
    [Tabelle / View] = N'dbo.Filialen', [Zeilen] = COUNT(*) FROM dbo.Filialen
UNION ALL SELECT N'dbo.Kategorien', COUNT(*) FROM dbo.Kategorien
UNION ALL SELECT N'dbo.Produkte', COUNT(*) FROM dbo.Produkte
UNION ALL SELECT N'dbo.Kunden', COUNT(*) FROM dbo.Kunden
UNION ALL SELECT N'dbo.Mitarbeiter', COUNT(*) FROM dbo.Mitarbeiter
UNION ALL SELECT N'dbo.Aktionen', COUNT(*) FROM dbo.Aktionen
UNION ALL SELECT N'dbo.Bons', COUNT(*) FROM dbo.Bons
UNION ALL SELECT N'dbo.Bonpositionen', COUNT(*) FROM dbo.Bonpositionen
UNION ALL SELECT N'dbo.Abschreibungen', COUNT(*) FROM dbo.Abschreibungen
UNION ALL SELECT N'dwh.dim_datum', COUNT(*) FROM dwh.dim_datum
UNION ALL SELECT N'dwh.fct_verkaeufe', COUNT(*) FROM dwh.fct_verkaeufe
UNION ALL SELECT N'stg.Kunden_Rohimport (Dirty)', COUNT(*) FROM stg.Kunden_Rohimport;

SELECT 
    MinDatum = MIN(BonDatum), 
    MaxDatum = MAX(BonDatum), 
    UmsatzBruttoGesamt = FORMAT(SUM(UmsatzBrutto), 'N2', 'de-DE'),
    RohertragGesamt = FORMAT(SUM(Deckungsbeitrag), 'N2', 'de-DE'),
    GesamteBons = COUNT(DISTINCT BonID),
    ArtikelGesamt = COUNT(*)
FROM dwh.fct_verkaeufe;

PRINT N'✅ SupermarktDWH erfolgreich und vollständig generiert!';
GO
