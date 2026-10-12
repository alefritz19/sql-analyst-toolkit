-- Spaltenaliasnamen (AS) und mathematische Berechnungen

WITH Products AS (
    SELECT 1 AS ProductID, 'Laptop' AS ProductName, 1000.0 AS Price, 0.19 AS VATRate, 5 AS UnitsInStock UNION ALL
    SELECT 2, 'Maus', 25.0, 0.19, 50 UNION ALL
    SELECT 3, 'Tastatur', 60.0, 0.19, 20
)
SELECT 
    ProductID,
    ProductName,
    Price AS NettoPrice,
    ROUND(Price * (1 + VATRate), 2) AS BruttoPrice,
    Price * UnitsInStock AS TotalStockValue
FROM Products;
