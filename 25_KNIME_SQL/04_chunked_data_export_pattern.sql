-- KNIME Analytics Platform: Partitionierter Datenexport (Chunking / Batching)
-- Verhindert OutOfMemory Exceptions beim Laden von Millionen Datensätzen in KNIME

DROP TABLE IF EXISTS #BigBatchExport;
CREATE TABLE #BigBatchExport (RowID INT IDENTITY(1,1), Payload VARCHAR(50));
INSERT INTO #BigBatchExport (Payload) VALUES ('Alpha'), ('Beta'), ('Gamma'), ('Delta');

DECLARE @BatchSize INT = 2;
DECLARE @BatchNumber INT = 1; -- Vom KNIME Loop gesteuert

SELECT 
    RowID,
    Payload
FROM #BigBatchExport
ORDER BY RowID
OFFSET (@BatchNumber - 1) * @BatchSize ROWS
FETCH NEXT @BatchSize ROWS ONLY;
