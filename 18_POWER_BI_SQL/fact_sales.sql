-- Power BI Datensatz: Faktentabelle (Fact Table)
-- Best Practice: Nur Fremdschlüssel (Surrogate Keys) und numerische Kennzahlen (Measures)

WITH RawOrders AS (
    SELECT 1001 AS OrderID, CAST('2026-10-01' AS DATE) AS OrderDate, 101 AS CustomerKey, 501 AS ProductKey, 2 AS Qty, 49.90 AS UnitPrice, 0.05 AS DiscountRate UNION ALL
    SELECT 1002, '2026-10-01', 102, 502, 1, 199.00, 0.00 UNION ALL
    SELECT 1003, '2026-10-02', 101, 503, 5, 12.50, 0.10
)
SELECT 
    CAST(OrderID AS BIGINT) AS OrderKey,
    CAST(OrderDate AS DATE) AS DateKey,
    CAST(CustomerKey AS INT) AS CustomerKey,
    CAST(ProductKey AS INT) AS ProductKey,
    CAST(Qty AS INT) AS Quantity,
    CAST(UnitPrice AS DECIMAL(10,2)) AS UnitPrice,
    CAST(DiscountRate AS DECIMAL(4,2)) AS DiscountRate,
    CAST(ROUND(Qty * UnitPrice * (1 - DiscountRate), 2) AS DECIMAL(12,2)) AS SalesAmountNetto
FROM RawOrders;
