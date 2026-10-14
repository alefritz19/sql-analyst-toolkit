-- LAG() - Zugriff auf vorherige Zeile (Vorperiode vergleichen)

WITH Sales AS (
    SELECT CAST('2026-01-01' AS DATE) AS OrderDate, 1000 AS SalesAmount UNION ALL
    SELECT '2026-01-02', 1400 UNION ALL
    SELECT '2026-01-03', 1200 UNION ALL
    SELECT '2026-01-04', 1900
)
SELECT
    OrderDate,
    SalesAmount,
    LAG(SalesAmount) OVER (ORDER BY OrderDate) AS PreviousAmount,
    SalesAmount - LAG(SalesAmount) OVER (ORDER BY OrderDate) AS AbsoluteDiff,
    ROUND((SalesAmount - LAG(SalesAmount) OVER (ORDER BY OrderDate)) * 100.0 / NULLIF(LAG(SalesAmount) OVER (ORDER BY OrderDate), 0), 2) AS GrowthPct
FROM Sales;
