-- Einfaches CASE (Simple CASE)

WITH Orders AS (
    SELECT 1 AS OrderID, 'N' AS StatusCode UNION ALL
    SELECT 2, 'P' UNION ALL
    SELECT 3, 'D' UNION ALL
    SELECT 4, 'C'
)
SELECT 
    OrderID,
    StatusCode,
    CASE StatusCode
        WHEN 'N' THEN 'Neu'
        WHEN 'P' THEN 'In Bearbeitung'
        WHEN 'D' THEN 'Geliefert'
        WHEN 'C' THEN 'Storniert'
        ELSE 'Unbekannt'
    END AS StatusName
FROM Orders;
