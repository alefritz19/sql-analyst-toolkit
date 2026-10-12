-- Filterung auf NULL-Werte (IS NULL, IS NOT NULL)

WITH Leads AS (
    SELECT 1 AS ID, 'Firma A' AS Company, 'info@a.de' AS Email, '+4912345' AS Phone UNION ALL
    SELECT 2, 'Firma B', NULL, '+4956789' UNION ALL
    SELECT 3, 'Firma C', 'kontakt@c.de', NULL UNION ALL
    SELECT 4, 'Firma D', NULL, NULL
)
SELECT *
FROM Leads
WHERE Email IS NULL 
   OR Phone IS NULL;
