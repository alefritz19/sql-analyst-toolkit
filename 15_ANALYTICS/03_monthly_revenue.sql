-- Monatlicher Umsatz & Wachstumsrate (MoM Growth)

WITH Sales AS (
    SELECT CAST('2026-01-10' AS DATE) AS OrderDate, 12000.0 AS Amount UNION ALL
    SELECT '2026-01-25', 15000.0 UNION ALL
    SELECT '2026-02-05', 18000.0 UNION ALL
    SELECT '2026-02-20', 14000.0 UNION ALL
    SELECT '2026-03-12', 35000.0
),
MonthlySales AS (
    SELECT
        YEAR(OrderDate) AS YearNo,
        MONTH(OrderDate) AS MonthNo,
        SUM(Amount) AS Revenue
    FROM Sales
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    YearNo,
    MonthNo,
    Revenue,
    LAG(Revenue) OVER (ORDER BY YearNo, MonthNo) AS PrevMonthRevenue,
    ROUND((Revenue - LAG(Revenue) OVER (ORDER BY YearNo, MonthNo)) * 100.0 / NULLIF(LAG(Revenue) OVER (ORDER BY YearNo, MonthNo), 0), 2) AS MoM_GrowthPct
FROM MonthlySales
ORDER BY YearNo, MonthNo;
