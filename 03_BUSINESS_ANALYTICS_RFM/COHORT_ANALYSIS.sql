/*
================================================================================
KOHORTENANALYSE (RETENTION / KUNDENBINDUNG) IN T-SQL
Gruppierung von Kunden nach ihrem Beitrittsmonat und Analyse der Folgekäufe.
================================================================================
*/

DROP TABLE IF EXISTS #UserOrders;
CREATE TABLE #UserOrders (UserID INT, OrderDate DATE);

INSERT INTO #UserOrders VALUES
(1, '2026-01-10'), (1, '2026-02-15'), (1, '2026-03-20'),
(2, '2026-01-20'), (2, '2026-03-05'),
(3, '2026-02-01'), (3, '2026-02-28'),
(4, '2026-02-14'),
(5, '2026-03-01');

WITH UserCohorts AS (
    SELECT 
        UserID,
        DATEFROMPARTS(YEAR(MIN(OrderDate)), MONTH(MIN(OrderDate)), 1) AS CohortMonth
    FROM #UserOrders
    GROUP BY UserID
),
ActivityMonths AS (
    SELECT DISTINCT
        o.UserID,
        c.CohortMonth,
        DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS ActivityMonth,
        DATEDIFF(month, c.CohortMonth, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)) AS MonthIndex
    FROM #UserOrders o
    JOIN UserCohorts c ON o.UserID = c.UserID
)
SELECT 
    CohortMonth,
    MonthIndex,
    COUNT(DISTINCT UserID) AS ActiveUsersCount
FROM ActivityMonths
GROUP BY CohortMonth, MonthIndex
ORDER BY CohortMonth, MonthIndex;
