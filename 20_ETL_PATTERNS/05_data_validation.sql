-- ETL Pattern: Datenvalidierung & Exception Logging (Quality Checks)

DROP TABLE IF EXISTS #StagingRecords;
DROP TABLE IF EXISTS #ETL_Exceptions;

CREATE TABLE #StagingRecords (RecordID INT, Email VARCHAR(100), Amount DECIMAL(10,2));
CREATE TABLE #ETL_Exceptions (RecordID INT, ErrorReason VARCHAR(100), LoggedAt DATETIME);

INSERT INTO #StagingRecords VALUES 
(1, 'valid@email.com', 100.00),
(2, 'invalid-email', 250.00),
(3, 'test@web.de', -50.00); -- Negativer Betrag nicht erlaubt

-- Ausnahme-Protokollierung
INSERT INTO #ETL_Exceptions (RecordID, ErrorReason, LoggedAt)
SELECT RecordID, 'Ungültige E-Mail-Adresse', GETDATE()
FROM #StagingRecords
WHERE Email NOT LIKE '%_@__%.__%'
UNION ALL
SELECT RecordID, 'Negativer Betrag unzulässig', GETDATE()
FROM #StagingRecords
WHERE Amount < 0;

SELECT * FROM #ETL_Exceptions;
