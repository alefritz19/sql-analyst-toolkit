-- Mehrere verkettete CTEs in einer einzigen Abfrage

WITH RawSales AS (
    SELECT 1 AS OrderID, 10 AS CustomerID, 500 AS Revenue UNION ALL
    SELECT 2, 10, 800 UNION ALL
    SELECT 3, 20, 300 UNION ALL
    SELECT 4, 30, 1500
),
CustomerTotals AS (
    SELECT 
        CustomerID,
        SUM(Revenue) AS TotalSpend
    FROM RawSales
    GROUP BY CustomerID
),
ClassifiedCustomers AS (
    SELECT 
        CustomerID,
        TotalSpend,
        CASE WHEN TotalSpend >= 1000 THEN 'VIP' ELSE 'Standard' END AS Segment
    FROM CustomerTotals
)
SELECT *
FROM ClassifiedCustomers
ORDER BY TotalSpend DESC;
