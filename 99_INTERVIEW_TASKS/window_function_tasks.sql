-- Interview Cheatsheet: Typische Aufgaben zu Fensterfunktionen

DROP TABLE IF EXISTS #SalesReps;
CREATE TABLE #SalesReps (RepID INT, Region VARCHAR(20), SalesAmount INT);
INSERT INTO #SalesReps VALUES (1, 'Nord', 100), (2, 'Nord', 150), (3, 'Süd', 80), (4, 'Süd', 200);

-- Aufgabe: Prozentualer Anteil des Vertreters am Gesamtumsatz seiner Region
SELECT 
    RepID,
    Region,
    SalesAmount,
    SUM(SalesAmount) OVER (PARTITION BY Region) AS RegionTotal,
    ROUND(SalesAmount * 100.0 / SUM(SalesAmount) OVER (PARTITION BY Region), 2) AS ShareOfRegionPct
FROM #SalesReps;
