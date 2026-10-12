-- Business Case: RFM Kundensegmentierung (Recency, Frequency, Monetary)

DROP TABLE IF EXISTS #SalesLog;
CREATE TABLE #SalesLog (ClientID INT, TxDate DATE, TxAmount DECIMAL(10,2));

INSERT INTO #SalesLog VALUES
(10, '2026-10-01', 500), (10, '2026-10-08', 350),
(20, '2026-04-12', 120),
(30, '2026-09-28', 1800), (30, '2026-10-05', 2100), (30, '2026-10-11', 950),
(40, '2025-12-01', 80);

DECLARE @Stichtag DATE = '2026-10-12';

WITH RFM_Raw AS (
    SELECT 
        ClientID,
        DATEDIFF(day, MAX(TxDate), @Stichtag) AS RecencyDays,
        COUNT(*) AS FrequencyCount,
        SUM(TxAmount) AS MonetarySum
    FROM #SalesLog
    GROUP BY ClientID
)
SELECT 
    ClientID,
    RecencyDays,
    FrequencyCount,
    MonetarySum,
    NTILE(3) OVER (ORDER BY RecencyDays DESC) AS R_Score,
    NTILE(3) OVER (ORDER BY FrequencyCount ASC) AS F_Score,
    NTILE(3) OVER (ORDER BY MonetarySum ASC) AS M_Score
FROM RFM_Raw;
