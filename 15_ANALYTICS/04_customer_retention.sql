-- Erstbestellung & Kundenaktivität (First Order Date)

WITH Orders AS (
    SELECT 101 AS OrderID, 1 AS CustomerID, CAST('2026-01-15' AS DATE) AS OrderDate UNION ALL
    SELECT 102, 2, '2026-01-20' UNION ALL
    SELECT 103, 1, '2026-02-10' UNION ALL
    SELECT 104, 3, '2026-02-14' UNION ALL
    SELECT 105, 2, '2026-03-05'
),
CustomerFirstOrder AS (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate,
        COUNT(OrderID) AS TotalOrdersCount
    FROM Orders
    GROUP BY CustomerID
)
SELECT *
FROM CustomerFirstOrder;
