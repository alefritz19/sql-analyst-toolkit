-- Business Case: Kohortenanalyse (Monatliche Retention-Matrix)

DROP TABLE IF EXISTS #UserEvents;
CREATE TABLE #UserEvents (UserID INT, ActivityDate DATE);

INSERT INTO #UserEvents VALUES
(1, '2026-01-05'), (1, '2026-02-10'), (1, '2026-03-15'),
(2, '2026-01-20'), (2, '2026-03-01'),
(3, '2026-02-05'), (3, '2026-02-22');

WITH Cohorts AS (
    SELECT 
        UserID,
        DATEFROMPARTS(YEAR(MIN(ActivityDate)), MONTH(MIN(ActivityDate)), 1) AS CohortMonth
    FROM #UserEvents
    GROUP BY UserID
)
SELECT 
    c.CohortMonth,
    DATEDIFF(month, c.CohortMonth, DATEFROMPARTS(YEAR(e.ActivityDate), MONTH(e.ActivityDate), 1)) AS MonthIndex,
    COUNT(DISTINCT e.UserID) AS RetainedUsers
FROM #UserEvents e
JOIN Cohorts c ON e.UserID = c.UserID
GROUP BY c.CohortMonth, DATEDIFF(month, c.CohortMonth, DATEFROMPARTS(YEAR(e.ActivityDate), MONTH(e.ActivityDate), 1))
ORDER BY c.CohortMonth, MonthIndex;
