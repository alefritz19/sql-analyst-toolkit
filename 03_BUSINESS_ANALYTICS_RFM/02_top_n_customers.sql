-- Top N Kunden nach Umsatz

WITH Sales AS (
    SELECT 1 AS CustomerID, 500 AS Amount UNION ALL
    SELECT 1, 1200 UNION ALL
    SELECT 2, 450 UNION ALL
    SELECT 3, 2100 UNION ALL
    SELECT 4, 3200 UNION ALL
    SELECT 2, 800
)
SELECT TOP 3
    CustomerID,
    SUM(Amount) AS Revenue
FROM Sales
GROUP BY CustomerID
ORDER BY Revenue DESC;
