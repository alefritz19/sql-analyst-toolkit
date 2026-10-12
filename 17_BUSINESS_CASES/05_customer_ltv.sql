-- Business Case: Customer Lifetime Value (CLV / LTV) & Customer Tenure

DROP TABLE IF EXISTS #SalesOrders;
CREATE TABLE #SalesOrders (OrderID INT, CustomerID INT, OrderDate DATE, NetAmount DECIMAL(10,2));

INSERT INTO #SalesOrders VALUES
(1, 10, '2025-01-15', 250), (2, 10, '2025-06-20', 300), (3, 10, '2026-03-10', 450),
(4, 20, '2025-08-01', 800),
(5, 30, '2025-02-14', 150), (6, 30, '2025-05-18', 200), (7, 30, '2026-01-10', 220);

SELECT 
    CustomerID,
    MIN(OrderDate) AS FirstPurchaseDate,
    MAX(OrderDate) AS LastPurchaseDate,
    DATEDIFF(day, MIN(OrderDate), MAX(OrderDate)) AS CustomerTenureDays,
    COUNT(OrderID) AS TotalPurchases,
    SUM(NetAmount) AS Historical_CLV,
    ROUND(AVG(NetAmount), 2) AS AverageOrderValue_AOV
FROM #SalesOrders
GROUP BY CustomerID
ORDER BY Historical_CLV DESC;
