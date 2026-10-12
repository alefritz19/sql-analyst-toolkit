-- Performance & Ausführungspläne: Häufige Stolperfallen

-- 1. SARGability (Search Argumentable):
-- SCHLECHT (verhindert Indexnutzung / Index Scan statt Seek):
-- WHERE YEAR(OrderDate) = 2026;
-- GUT (nutzt Index Seek):
-- WHERE OrderDate >= '2026-01-01' AND OrderDate < '2027-01-01';

-- 2. Keine implizite Typkonvertierung:
-- WHERE VarcharColumn = 123;   --> Schlecht
-- WHERE VarcharColumn = '123'; --> Gut

SELECT 1 AS IsPerformant;
