-- Relationale Daten in JSON umwandeln mit FOR JSON

WITH Orders AS (
    SELECT 1 AS OrderID, 'Alex' AS Client, 250 AS Total UNION ALL
    SELECT 2, 'Anna', 480
)
SELECT 
    OrderID,
    Client,
    Total
FROM Orders
FOR JSON PATH, ROOT('OrdersList');
