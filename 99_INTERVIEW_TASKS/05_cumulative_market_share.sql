-- Interview-Aufgabe: Prozentualer Marktanteil & kumulativer Anteil

WITH Competitors AS (
    SELECT 'Company A' AS Company, 5000000 AS Revenue UNION ALL
    SELECT 'Company B', 3200000 UNION ALL
    SELECT 'Company C', 1800000 UNION ALL
    SELECT 'Company D', 1000000
)
SELECT 
    Company,
    Revenue,
    ROUND(Revenue * 100.0 / SUM(Revenue) OVER (), 2) AS MarketSharePct,
    ROUND(SUM(Revenue) OVER (ORDER BY Revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 / SUM(Revenue) OVER (), 2) AS CumulativeSharePct
FROM Competitors;
