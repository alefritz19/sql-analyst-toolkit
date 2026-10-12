-- Bedingte Aggregation (Pivot-Ersatz mit SUM/CASE)

WITH Transactions AS (
    SELECT 2025 AS YearNo, 'Q1' AS QuarterNo, 1000 AS Amount UNION ALL
    SELECT 2025, 'Q2', 1500 UNION ALL
    SELECT 2025, 'Q3', 1200 UNION ALL
    SELECT 2025, 'Q4', 1800 UNION ALL
    SELECT 2026, 'Q1', 1100 UNION ALL
    SELECT 2026, 'Q2', 1700
)
SELECT 
    YearNo,
    SUM(CASE WHEN QuarterNo = 'Q1' THEN Amount ELSE 0 END) AS Revenue_Q1,
    SUM(CASE WHEN QuarterNo = 'Q2' THEN Amount ELSE 0 END) AS Revenue_Q2,
    SUM(CASE WHEN QuarterNo = 'Q3' THEN Amount ELSE 0 END) AS Revenue_Q3,
    SUM(CASE WHEN QuarterNo = 'Q4' THEN Amount ELSE 0 END) AS Revenue_Q4,
    SUM(Amount) AS Total_Year_Revenue
FROM Transactions
GROUP BY YearNo;
