-- Erweiterte Gruppierung: ROLLUP und CUBE (Zwischensummen & Gesamtsumme)

DROP TABLE IF EXISTS #RegionalRevenue;
CREATE TABLE #RegionalRevenue (Year INT, Region VARCHAR(20), Amount DECIMAL(10,2));

INSERT INTO #RegionalRevenue VALUES
(2025, 'Nord', 100),
(2025, 'Süd', 150),
(2026, 'Nord', 200),
(2026, 'Süd', 250);

-- ROLLUP: Bildet hierarchische Zwischensummen (Subtotals)
SELECT 
    Year,
    Region,
    SUM(Amount) AS TotalRevenue
FROM #RegionalRevenue
GROUP BY ROLLUP (Year, Region);
