-- ETL Pattern: Inkrementelles Laden (Delta-Load via High Watermark / LastModified)

DROP TABLE IF EXISTS #SourceOrders;
DROP TABLE IF EXISTS #TargetOrders;

CREATE TABLE #SourceOrders (OrderID INT, Amount DECIMAL(10,2), LastModified DATETIME);
CREATE TABLE #TargetOrders (OrderID INT PRIMARY KEY, Amount DECIMAL(10,2), LastModified DATETIME);

-- Zielbestand
INSERT INTO #TargetOrders VALUES (1, 100, '2026-10-01 10:00:00');

-- Neue & geänderte Quelldaten
INSERT INTO #SourceOrders VALUES 
(1, 150, '2026-10-05 12:00:00'), -- Geändert
(2, 200, '2026-10-05 14:00:00'); -- Neu

DECLARE @LastWatermark DATETIME = '2026-10-01 10:00:00';

-- Nur Delta abrufen
SELECT *
FROM #SourceOrders
WHERE LastModified > @LastWatermark;
