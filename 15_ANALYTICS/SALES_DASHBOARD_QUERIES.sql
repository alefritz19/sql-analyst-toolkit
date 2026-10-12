/*
================================================================================
KPI QUERIES FÜR MANAGEMENT SALES-DASHBOARDS
Zentrale Kennzahlen: Total Revenue, MoM, YoY, AOV, Top Categories
================================================================================
*/

DROP TABLE IF EXISTS #DashboardData;
CREATE TABLE #DashboardData (
    OrderDate DATE,
    Category VARCHAR(50),
    Amount DECIMAL(10,2),
    Cost DECIMAL(10,2)
);

INSERT INTO #DashboardData VALUES
('2026-08-15', 'Elektronik', 1500, 900),
('2026-09-10', 'Elektronik', 2200, 1300),
('2026-09-12', 'Möbel',      1800, 1100),
('2026-10-01', 'Elektronik', 3100, 1700),
('2026-10-05', 'Möbel',      2400, 1400);

-- KPI-Karte: Gesamtumsatz, Gesamtkosten, Marge
SELECT 
    SUM(Amount) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Amount - Cost) AS GrossProfit,
    ROUND((SUM(Amount - Cost) * 100.0) / NULLIF(SUM(Amount), 0), 2) AS GrossMarginPct,
    COUNT(*) AS TotalOrdersCount,
    ROUND(AVG(Amount), 2) AS AvgOrderValue
FROM #DashboardData;
