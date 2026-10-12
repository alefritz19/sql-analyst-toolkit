-- KNIME Analytics Platform: In-Database Processing (DB Table Selector -> DB GroupBy)
-- Vorberechnen im DBMS spart Netzwerkbandbreite und KNIME-Arbeitsspeicher (Heap)

DROP TABLE IF EXISTS #MassiveData;
CREATE TABLE #MassiveData (CatID INT, MetricValue DECIMAL(12,2));
INSERT INTO #MassiveData VALUES (1, 100), (1, 300), (2, 500), (2, 700);

-- KNIME Pushdown erzeugt intern folgende SQL-Logik:
SELECT 
    CatID,
    SUM(MetricValue) AS AggregatedSum,
    COUNT(*) AS RowCounter
FROM #MassiveData
GROUP BY CatID;
