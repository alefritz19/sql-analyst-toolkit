-- Business Case: Kundenabwanderung (Customer Churn Rate)
-- Definition: Kunden ohne Aktivität innerhalb der letzten 90 Tage

DROP TABLE IF EXISTS #CustomerOrders;
CREATE TABLE #CustomerOrders (CustID INT, OrderDate DATE, Amount DECIMAL(10,2));

INSERT INTO #CustomerOrders VALUES
(1, '2026-10-01', 120), (1, '2026-10-05', 80),
(2, '2026-05-10', 400),
(3, '2026-09-20', 250),
(4, '2026-02-15', 180);

DECLARE @CurrentReportingDate DATE = '2026-10-12';

WITH CustomerLastActivity AS (
    SELECT 
        CustID,
        MAX(OrderDate) AS LastOrderDate,
        DATEDIFF(day, MAX(OrderDate), @CurrentReportingDate) AS InactivityDays
    FROM #CustomerOrders
    GROUP BY CustID
)
SELECT 
    CustID,
    LastOrderDate,
    InactivityDays,
    CASE 
        WHEN InactivityDays > 90 THEN 'Abgewandert (Churned)'
        WHEN InactivityDays BETWEEN 30 AND 90 THEN 'Gefährdet (At Risk)'
        ELSE 'Aktiv (Active)'
    END AS ChurnStatus
FROM CustomerLastActivity
ORDER BY InactivityDays DESC;
