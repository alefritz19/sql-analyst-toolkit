/*
================================================================================
FÜR POWER BI OPTIMIERTE T-SQL-ABFRAGE
Faktentabelle im Sternschema mit optimierten Datentypen.
================================================================================
*/

-- Bewährte Praxis für Power BI (DirectQuery / Import):
-- Keine SELECT * verwenden, Spaltentypen sauber casten, NULLs vermeiden.
WITH RawSales AS (
    SELECT 
        1 AS OrderID, CAST('2026-10-01' AS DATE) AS OrderDateKey, 
        101 AS CustomerKey, 501 AS ProductKey, 2 AS Qty, 150.00 AS UnitPrice
)
SELECT 
    CAST(OrderID AS INT) AS OrderID,
    OrderDateKey,
    CAST(CustomerKey AS INT) AS CustomerKey,
    CAST(ProductKey AS INT) AS ProductKey,
    CAST(Qty AS INT) AS Quantity,
    CAST(UnitPrice AS DECIMAL(10,2)) AS UnitPrice,
    CAST(Qty * UnitPrice AS DECIMAL(12,2)) AS ExtendedAmount
FROM RawSales;
