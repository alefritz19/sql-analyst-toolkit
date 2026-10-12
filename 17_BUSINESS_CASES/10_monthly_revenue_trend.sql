-- Business Case: Monatlicher Umsatztrend & Wachstumsrate (MoM Growth Trend)

DROP TABLE IF EXISTS #MonthlyFinancials;
CREATE TABLE #MonthlyFinancials (YearNo INT, MonthNo INT, Revenue DECIMAL(12,2));

INSERT INTO #MonthlyFinancials VALUES
(2025, 1, 100000), (2025, 2, 110000), (2025, 3, 120000),
(2026, 1, 130000), (2026, 2, 145000), (2026, 3, 160000);

SELECT 
    YearNo,
    MonthNo,
    Revenue,
    LAG(Revenue, 1) OVER (ORDER BY YearNo, MonthNo) AS PrevMonthRevenue,
    ROUND((Revenue - LAG(Revenue, 1) OVER (ORDER BY YearNo, MonthNo)) * 100.0 / NULLIF(LAG(Revenue, 1) OVER (ORDER BY YearNo, MonthNo), 0), 2) AS MoM_GrowthPct,
    LAG(Revenue, 12) OVER (ORDER BY YearNo, MonthNo) AS SameMonthLastYear,
    ROUND((Revenue - LAG(Revenue, 12) OVER (ORDER BY YearNo, MonthNo)) * 100.0 / NULLIF(LAG(Revenue, 12) OVER (ORDER BY YearNo, MonthNo), 0), 2) AS YoY_GrowthPct
FROM #MonthlyFinancials;
