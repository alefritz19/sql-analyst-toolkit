-- PIVOT-Operator: Zeilen in Spalten transformieren

DROP TABLE IF EXISTS #QuarterlyData;
CREATE TABLE #QuarterlyData (YearNo INT, QuarterCode VARCHAR(5), Revenue DECIMAL(10,2));

INSERT INTO #QuarterlyData VALUES
(2025, 'Q1', 10000), (2025, 'Q2', 15000), (2025, 'Q3', 12000), (2025, 'Q4', 20000),
(2026, 'Q1', 11000), (2026, 'Q2', 17000), (2026, 'Q3', 14000), (2026, 'Q4', 22000);

SELECT 
    YearNo,
    [Q1], [Q2], [Q3], [Q4]
FROM (
    SELECT YearNo, QuarterCode, Revenue 
    FROM #QuarterlyData
) AS SourceTable
PIVOT (
    SUM(Revenue)
    FOR QuarterCode IN ([Q1], [Q2], [Q3], [Q4])
) AS PivotTable;
