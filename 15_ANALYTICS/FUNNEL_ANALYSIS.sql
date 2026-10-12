/*
================================================================================
FUNNEL-ANALYSE (CONVERSION FUNNEL / TRICHTERANALYSE) IN T-SQL
Messung der Drop-Off-Raten über die Phasen des Kaufprozesses.
================================================================================
*/

DROP TABLE IF EXISTS #FunnelEvents;
CREATE TABLE #FunnelEvents (SessionID INT, StepName VARCHAR(50), StepOrder INT);

INSERT INTO #FunnelEvents VALUES
(101, '1_Homepage', 1), (101, '2_ProductPage', 2), (101, '3_AddToCart', 3), (101, '4_Purchase', 4),
(102, '1_Homepage', 1), (102, '2_ProductPage', 2), (102, '3_AddToCart', 3),
(103, '1_Homepage', 1), (103, '2_ProductPage', 2),
(104, '1_Homepage', 1),
(105, '1_Homepage', 1), (105, '2_ProductPage', 2), (105, '3_AddToCart', 3), (105, '4_Purchase', 4);

WITH FunnelCounts AS (
    SELECT 
        StepOrder,
        StepName,
        COUNT(DISTINCT SessionID) AS SessionsAtStep
    FROM #FunnelEvents
    GROUP BY StepOrder, StepName
),
FunnelWithFirstStep AS (
    SELECT 
        StepOrder,
        StepName,
        SessionsAtStep,
        FIRST_VALUE(SessionsAtStep) OVER (ORDER BY StepOrder ASC) AS TotalVisitors,
        LAG(SessionsAtStep) OVER (ORDER BY StepOrder ASC) AS PrevStepSessions
    FROM FunnelCounts
)
SELECT 
    StepName,
    SessionsAtStep,
    ROUND(SessionsAtStep * 100.0 / TotalVisitors, 2) AS ConversionFromStartPct,
    ROUND(SessionsAtStep * 100.0 / NULLIF(PrevStepSessions, 0), 2) AS StepConversionPct,
    ROUND(100.0 - (SessionsAtStep * 100.0 / NULLIF(PrevStepSessions, 0)), 2) AS DropOffPct
FROM FunnelWithFirstStep
ORDER BY StepOrder;
