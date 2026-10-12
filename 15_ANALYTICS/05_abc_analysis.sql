-- Basis ABC-Klassifizierung

WITH Sales AS (
    SELECT 101 AS ProductID, 45000 AS Revenue UNION ALL
    SELECT 102, 28000 UNION ALL
    SELECT 103, 12000 UNION ALL
    SELECT 104, 8000 UNION ALL
    SELECT 105, 3000
)
SELECT 
    ProductID,
    Revenue,
    SUM(Revenue) OVER () AS TotalRevenue,
    ROUND(Revenue * 100.0 / SUM(Revenue) OVER (), 2) AS PctShare
FROM Sales
ORDER BY Revenue DESC;
