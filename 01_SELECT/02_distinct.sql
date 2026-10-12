-- Eindeutige Werte abfragen mit DISTINCT

WITH Orders AS (
    SELECT 101 AS OrderID, 'Berlin' AS City UNION ALL
    SELECT 102, 'Hamburg' UNION ALL
    SELECT 103, 'Berlin' UNION ALL
    SELECT 104, 'München' UNION ALL
    SELECT 105, 'Hamburg'
)
SELECT DISTINCT City
FROM Orders;
