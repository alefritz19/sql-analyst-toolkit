-- Business Case: Top 20 % Kunden (Pareto-Kundenanalyse)

DROP TABLE IF EXISTS #TopClients;
CREATE TABLE #TopClients (ClientID INT, ClientName VARCHAR(50), TotalSpend DECIMAL(10,2));

INSERT INTO #TopClients VALUES
(1, 'TechCorp AG', 125000),
(2, 'RetailPro GmbH', 85000),
(3, 'Consulting 24', 45000),
(4, 'WebShop Media', 32000),
(5, 'Local Bakery', 4500),
(6, 'Kiosk Berlin', 2100),
(7, 'Print Service', 1500);

WITH RankedClients AS (
    SELECT 
        ClientID,
        ClientName,
        TotalSpend,
        NTILE(5) OVER (ORDER BY TotalSpend DESC) AS PercentileGroup,
        ROUND(TotalSpend * 100.0 / SUM(TotalSpend) OVER (), 2) AS ShareOfTotalSpendPct
    FROM #TopClients
)
SELECT 
    ClientID,
    ClientName,
    TotalSpend,
    ShareOfTotalSpendPct,
    CASE WHEN PercentileGroup = 1 THEN 'Top 20% Key Account' ELSE 'Standard Client' END AS ClientTier
FROM RankedClients
ORDER BY TotalSpend DESC;
