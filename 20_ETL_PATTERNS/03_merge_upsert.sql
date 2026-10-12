-- ETL Pattern: MERGE Anweisung (UPSERT: Update existing, Insert new)

DROP TABLE IF EXISTS #TargetStock;
DROP TABLE IF EXISTS #SourceStock;

CREATE TABLE #TargetStock (ProductID INT PRIMARY KEY, Qty INT, LastUpdated DATETIME);
CREATE TABLE #SourceStock (ProductID INT PRIMARY KEY, Qty INT);

INSERT INTO #TargetStock VALUES (1, 50, '2026-10-01'), (2, 20, '2026-10-01');
INSERT INTO #SourceStock VALUES (1, 75), (3, 100);

MERGE #TargetStock AS tgt
USING #SourceStock AS src
ON tgt.ProductID = src.ProductID
WHEN MATCHED THEN
    UPDATE SET tgt.Qty = src.Qty, tgt.LastUpdated = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ProductID, Qty, LastUpdated) VALUES (src.ProductID, src.Qty, GETDATE());

SELECT * FROM #TargetStock;
