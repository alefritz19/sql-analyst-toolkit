-- Business Case: ABC-Klassifizierung nach Pareto (A=80%, B=15%, C=5%)

WITH ProductRevenues AS (
    SELECT 1 AS ProdID, 'Notebook Core' AS ProdName, 95000.0 AS Revenue UNION ALL
    SELECT 2, 'Workstation', 75000.0 UNION ALL
    SELECT 3, 'Monitor 4K', 35000.0 UNION ALL
    SELECT 4, 'Docking Station', 15000.0 UNION ALL
    SELECT 5, 'Kabel Adapter', 3000.0
),
CumulativeShare AS (
    SELECT 
        ProdID,
        ProdName,
        Revenue,
        SUM(Revenue) OVER (ORDER BY Revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumRevenue,
        SUM(Revenue) OVER () AS TotalRevenue
    FROM ProductRevenues
)
SELECT 
    ProdID,
    ProdName,
    Revenue,
    ROUND(CumRevenue * 100.0 / TotalRevenue, 2) AS CumPctShare,
    CASE 
        WHEN (CumRevenue * 100.0 / TotalRevenue) <= 80 THEN 'A-Produkt'
        WHEN (CumRevenue * 100.0 / TotalRevenue) <= 95 THEN 'B-Produkt'
        ELSE 'C-Produkt'
    END AS ABC_Kategorie
FROM CumulativeShare;
