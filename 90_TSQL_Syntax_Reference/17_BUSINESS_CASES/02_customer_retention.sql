-- Business Case: Kundenbindungsrate & Wiederholungskäufe (Repeat Purchase Rate)

DROP TABLE IF EXISTS #Transactions;
CREATE TABLE #Transactions (TransID INT, CustomerID INT, OrderDate DATE);

INSERT INTO #Transactions VALUES
(1, 101, '2026-01-15'), (2, 101, '2026-03-10'),
(3, 102, '2026-02-01'),
(4, 103, '2026-01-20'), (5, 103, '2026-02-15'), (6, 103, '2026-03-25'),
(7, 104, '2026-03-05');

WITH CustomerPurchaseCounts AS (
    SELECT 
        CustomerID,
        COUNT(*) AS TotalOrders
    FROM #Transactions
    GROUP BY CustomerID
)
SELECT 
    COUNT(*) AS TotalUniqueCustomers,
    SUM(CASE WHEN TotalOrders > 1 THEN 1 ELSE 0 END) AS RepeatCustomersCount,
    ROUND(SUM(CASE WHEN TotalOrders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RepeatPurchaseRatePct
FROM CustomerPurchaseCounts;
