/*
================================================================================
RFM-ANALYSE (KUNDENSEGMENTIERUNG) IN T-SQL
R = Recency   (Wie viele Tage seit dem letzten Kauf?)
F = Frequency (Wie oft hat der Kunde gekauft?)
M = Monetary  (Wie viel Geld hat der Kunde ausgegeben?)
================================================================================
*/

DROP TABLE IF EXISTS #CustomerTransactions;
CREATE TABLE #CustomerTransactions (CustID INT, OrderDate DATE, Amount DECIMAL(10,2));

INSERT INTO #CustomerTransactions VALUES
(1, '2026-10-01', 500), (1, '2026-10-08', 750), (1, '2026-10-11', 1200),
(2, '2026-05-15', 300), (2, '2026-06-20', 400),
(3, '2026-01-10', 150),
(4, '2026-10-10', 2500),
(5, '2025-11-05', 80);

DECLARE @AnalysisDate DATE = '2026-10-12';

WITH RawRFM AS (
    SELECT 
        CustID,
        DATEDIFF(day, MAX(OrderDate), @AnalysisDate) AS RecencyDays,
        COUNT(*) AS FrequencyCount,
        SUM(Amount) AS MonetaryTotal
    FROM #CustomerTransactions
    GROUP BY CustID
),
RFM_Scores AS (
    SELECT 
        CustID,
        RecencyDays,
        FrequencyCount,
        MonetaryTotal,
        -- NTILE(3) teilt die Kunden in 3 Segmente (1=niedrig, 3=hoch)
        -- Bei Recency: Je kleiner die Tage, desto besser der Score!
        NTILE(3) OVER (ORDER BY RecencyDays DESC) AS R_Score,
        NTILE(3) OVER (ORDER BY FrequencyCount ASC) AS F_Score,
        NTILE(3) OVER (ORDER BY MonetaryTotal ASC) AS M_Score
    FROM RawRFM
)
SELECT 
    CustID,
    RecencyDays,
    FrequencyCount,
    MonetaryTotal,
    R_Score, F_Score, M_Score,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Cell,
    CASE 
        WHEN R_Score = 3 AND F_Score = 3 AND M_Score = 3 THEN 'VIP Champions'
        WHEN R_Score = 3 AND F_Score >= 2 THEN 'Loyale Kunden (Loyal)'
        WHEN R_Score = 1 AND F_Score >= 2 THEN 'Abwanderungsgefährdet (At Risk)'
        WHEN R_Score = 1 AND F_Score = 1 THEN 'Verlorene Kunden (Lost)'
        ELSE 'Gelegenheitskäufer (Potential)'
    END AS CustomerSegment
FROM RFM_Scores
ORDER BY MonetaryTotal DESC;
