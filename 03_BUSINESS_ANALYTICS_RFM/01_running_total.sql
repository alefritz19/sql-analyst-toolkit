-- Laufender Umsatz (Cumulative Running Total)

WITH Sales AS (
    SELECT CAST('2026-01-01' AS DATE) AS OrderDate, 1500.0 AS Amount UNION ALL
    SELECT '2026-01-02', 2200.0 UNION ALL
    SELECT '2026-01-03', 1800.0 UNION ALL
    SELECT '2026-01-04', 3100.0
)
SELECT
    OrderDate,
    Amount,
    -- ROWS ... CURRENT ROW statt des Standardrahmens RANGE: bei mehreren Zeilen mit
    -- gleichem Datum bekäme sonst jede davon dieselbe Summe
    SUM(Amount) OVER (ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Sales;
