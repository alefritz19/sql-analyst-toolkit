-- Aggregationen: GROUP BY und HAVING-Klausel

DROP TABLE IF EXISTS #Sales;
CREATE TABLE #Sales (Region VARCHAR(50), Category VARCHAR(50), Revenue DECIMAL(10,2));

INSERT INTO #Sales VALUES
('Nord', 'Elektronik', 12000),
('Nord', 'Möbel', 4500),
('Nord', 'Elektronik', 8500),
('Süd', 'Elektronik', 15000),
('Süd', 'Möbel', 9000),
('West', 'Möbel', 3200);

SELECT
    Region,
    Category,
    COUNT(*) AS NumberOfSales,
    SUM(Revenue) AS TotalRevenue,
    AVG(Revenue) AS AvgRevenue,
    MIN(Revenue) AS MinRevenue,
    MAX(Revenue) AS MaxRevenue
FROM #Sales
GROUP BY Region, Category
HAVING SUM(Revenue) > 5000 -- HAVING filtert aggregierte Werte
ORDER BY TotalRevenue DESC;
