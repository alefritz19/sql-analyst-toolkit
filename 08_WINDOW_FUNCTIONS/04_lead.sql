-- LEAD() - Zugriff auf nachfolgende Zeile

WITH StageHistory AS (
    SELECT 1 AS DealID, 'Lead' AS Stage, CAST('2026-01-05' AS DATE) AS ChangedAt UNION ALL
    SELECT 1, 'Meeting', '2026-01-12' UNION ALL
    SELECT 1, 'Proposal', '2026-01-20' UNION ALL
    SELECT 1, 'Won', '2026-02-01'
)
SELECT 
    DealID,
    Stage,
    ChangedAt AS StartDate,
    LEAD(ChangedAt) OVER (PARTITION BY DealID ORDER BY ChangedAt) AS NextStageDate,
    DATEDIFF(day, ChangedAt, LEAD(ChangedAt) OVER (PARTITION BY DealID ORDER BY ChangedAt)) AS DaysInStage
FROM StageHistory;
