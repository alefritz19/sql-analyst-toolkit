-- SQL Challenge: Fortgeschrittene Gaps and Islands (Zusammenhängende Intervalle)

DROP TABLE IF EXISTS #ServerLogins;
CREATE TABLE #ServerLogins (UserID INT, LoginDate DATE);

INSERT INTO #ServerLogins VALUES
(1, '2026-10-01'), (1, '2026-10-02'), (1, '2026-10-03'),
(1, '2026-10-06'), (1, '2026-10-07'),
(1, '2026-10-10');

WITH IslandGroups AS (
    SELECT 
        UserID,
        LoginDate,
        DATEADD(day, -ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY LoginDate), LoginDate) AS IslandGroupKey
    FROM #ServerLogins
)
SELECT 
    UserID,
    MIN(LoginDate) AS IslandStart,
    MAX(LoginDate) AS IslandEnd,
    COUNT(*) AS ConsecutiveDaysLength
FROM IslandGroups
GROUP BY UserID, IslandGroupKey
ORDER BY IslandStart;
