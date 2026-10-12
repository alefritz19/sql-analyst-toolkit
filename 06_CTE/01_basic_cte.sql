-- Grundlegende CTE (Common Table Expression / WITH-Klausel)

WITH HighValueOrders AS (
    SELECT 101 AS OrderID, 1200 AS Amount UNION ALL
    SELECT 102, 350 UNION ALL
    SELECT 103, 2400 UNION ALL
    SELECT 104, 150
)
SELECT *
FROM HighValueOrders
WHERE Amount > 1000;
