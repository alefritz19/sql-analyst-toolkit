-- Datenqualitätsprüfung: Auffinden unvollständiger Datensätze

WITH ClientMaster AS (
    SELECT 1 AS ID, 'Alex' AS Name, 'alex@domain.de' AS Email, 'DE' AS Country UNION ALL
    SELECT 2, 'Anna', NULL, 'AT' UNION ALL
    SELECT 3, 'Bernd', 'bernd@domain.de', NULL UNION ALL
    SELECT 4, 'Clara', NULL, NULL
)
SELECT *
FROM ClientMaster
WHERE Email IS NULL 
   OR Country IS NULL;
