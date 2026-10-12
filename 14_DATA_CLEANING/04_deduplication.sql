-- Duplikate sauber entfernen mit CTE & ROW_NUMBER()

DROP TABLE IF EXISTS #StagingData;
CREATE TABLE #StagingData (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(50),
    CreatedAt DATE,
    Status VARCHAR(20)
);

INSERT INTO #StagingData (Email, CreatedAt, Status) VALUES
('user1@web.de', '2026-01-01', 'Old'),
('user1@web.de', '2026-02-15', 'Active'), -- Neueste Version behalten
('user2@web.de', '2026-03-01', 'Active'),
('user3@web.de', '2026-01-10', 'Pending'),
('user3@web.de', '2026-01-10', 'Pending');

-- Muster: Nur Zeilen mit rn = 1 behalten (Deduplizieren)
WITH RankedRecords AS (
    SELECT 
        ID,
        Email,
        CreatedAt,
        Status,
        ROW_NUMBER() OVER (
            PARTITION BY Email 
            ORDER BY CreatedAt DESC, ID DESC
        ) AS rn
    FROM #StagingData
)
-- Im Produktivbetrieb: DELETE FROM RankedRecords WHERE rn > 1;
SELECT 
    ID, Email, CreatedAt, Status
FROM RankedRecords
WHERE rn = 1;
