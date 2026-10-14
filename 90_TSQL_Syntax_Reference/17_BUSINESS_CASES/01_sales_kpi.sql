-- Business Case: Management Sales KPIs (Umsatz, Kosten, Deckungsbeitrag, Marge)

DROP TABLE IF EXISTS #SalesKPI;
CREATE TABLE #SalesKPI (OrderID INT, Revenue DECIMAL(10,2), Cost DECIMAL(10,2));

INSERT INTO #SalesKPI VALUES
(1, 1500, 900), (2, 2200, 1300), (3, 1800, 1100), (4, 3100, 1700), (5, 2400, 1400);

SELECT 
    COUNT(*) AS TotalOrders,
    SUM(Revenue) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Revenue - Cost) AS GrossProfit,
    ROUND(SUM(Revenue - Cost) * 100.0 / NULLIF(SUM(Revenue), 0), 2) AS GrossMarginPct,
    ROUND(AVG(Revenue), 2) AS AvgOrderValue_AOV
FROM #SalesKPI;
