/*
================================================================================
ABC-ANALYSE (PARETO-PRINZIP 80 / 15 / 5) IN T-SQL
Klassifizierung von Produkten nach ihrem kumulierten Anteil am Gesamtumsatz.
A = bis 80 % des Umsatzes (Top-Umsatzträger)
B = die nächsten 15 % (solide Mitte)
C = die restlichen 5 % (Marginalprodukte / Long Tail)
================================================================================
*/

DROP TABLE IF EXISTS #ProductSales;
CREATE TABLE #ProductSales (ProductID INT, ProductName VARCHAR(50), TotalRevenue DECIMAL(12,2));

INSERT INTO #ProductSales VALUES
(1, 'Notebook Pro', 85000.00),
(2, 'Server Blade', 65000.00),
(3, 'Desktop PC',   32000.00),
(4, 'Monitor 27"',  18000.00),
(5, 'Tastatur',      6500.00),
(6, 'USB-Kabel',     2100.00),
(7, 'Mauspad',        950.00);

WITH SalesRanked AS (
    SELECT 
        ProductID,
        ProductName,
        TotalRevenue,
        -- Kumulierter Umsatz über alle vorherigen Zeilen:
        SUM(TotalRevenue) OVER (
            ORDER BY TotalRevenue DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeRevenue,
        -- Gesamtumsatz aller Produkte:
        SUM(TotalRevenue) OVER () AS TotalPortfolioRevenue
    FROM #ProductSales
),
CumulativeCalculation AS (
    SELECT 
        ProductID,
        ProductName,
        TotalRevenue,
        CumulativeRevenue,
        ROUND(CumulativeRevenue * 100.0 / TotalPortfolioRevenue, 2) AS CumulativeSharePct
    FROM SalesRanked
)
SELECT 
    ProductID,
    ProductName,
    TotalRevenue,
    CumulativeRevenue,
    CumulativeSharePct,
    CASE 
        WHEN CumulativeSharePct <= 80.0 THEN 'A (Top 80%)'
        WHEN CumulativeSharePct <= 95.0 THEN 'B (Mittlere 15%)'
        ELSE 'C (Restliche 5%)'
    END AS ABC_Class
FROM CumulativeCalculation
ORDER BY TotalRevenue DESC;
