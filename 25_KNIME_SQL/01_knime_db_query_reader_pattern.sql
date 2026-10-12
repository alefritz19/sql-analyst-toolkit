-- KNIME Analytics Platform: DB Query Reader Best Practice
-- Aggregation und Vorfilterung direkt in der Datenbank (Pushdown Optimization)

DROP TABLE IF EXISTS #RawTransactions;
CREATE TABLE #RawTransactions (TxID INT, CustomerID INT, TxDate DATE, Amount DECIMAL(10,2));

INSERT INTO #RawTransactions VALUES
(1, 101, '2026-10-01', 150), (2, 101, '2026-10-05', 300),
(3, 102, '2026-10-02', 80),  (4, 103, '2026-10-07', 950);

-- Dieser SQL-Block wird direkt im KNIME Node 'DB Query Reader' platziert:
SELECT 
    CustomerID,
    COUNT(TxID) AS TotalOrdersCount,
    SUM(Amount) AS TotalRevenue,
    ROUND(AVG(Amount), 2) AS AverageOrderAmount
FROM #RawTransactions
WHERE TxDate >= '2026-10-01'
GROUP BY CustomerID;
