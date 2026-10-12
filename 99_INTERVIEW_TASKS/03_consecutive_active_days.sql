-- Interview-Aufgabe: N aufeinanderfolgende Tage aktiv (Gaps and Islands)

WITH UserLogins AS (
    SELECT 1 AS UserID, CAST('2026-10-01' AS DATE) AS LoginDate UNION ALL
    SELECT 1, '2026-10-02' UNION ALL
    SELECT 1, '2026-10-03' UNION ALL
    SELECT 1, '2026-10-05' UNION ALL
    SELECT 2, '2026-10-01' UNION ALL
    SELECT 2, '2026-10-02'
),
DateDifferences AS (
    SELECT
        UserID,
        LoginDate,
        DATEADD(day, -ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY LoginDate), LoginDate) AS GroupGroupKey
    FROM UserLogins
)
SELECT
    UserID,
    MIN(LoginDate) AS StreakStart,
    MAX(LoginDate) AS StreakEnd,
    COUNT(*) AS ConsecutiveDaysCount
FROM DateDifferences
GROUP BY UserID, GroupGroupKey
HAVING COUNT(*) >= 3; -- Mindestens 3 Tage in Folge
