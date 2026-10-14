-- SQL Challenge: Akzeptanzrate von Freundschaftsanfragen (LeetCode Style)

DROP TABLE IF EXISTS #FriendRequests;
DROP TABLE IF EXISTS #RequestAccepted;

CREATE TABLE #FriendRequests (SenderID INT, SendToID INT, RequestDate DATE);
CREATE TABLE #RequestAccepted (RequesterID INT, AccepterID INT, AcceptDate DATE);

INSERT INTO #FriendRequests VALUES (1, 2, '2026-06-01'), (1, 3, '2026-06-01'), (2, 3, '2026-06-02'), (3, 4, '2026-06-09');
INSERT INTO #RequestAccepted VALUES (1, 2, '2026-06-03'), (2, 3, '2026-06-08'), (3, 4, '2026-06-10');

SELECT 
    ROUND(
        COUNT(DISTINCT CONCAT(a.RequesterID, '-', a.AccepterID)) * 1.0 / 
        NULLIF(COUNT(DISTINCT CONCAT(r.SenderID, '-', r.SendToID)), 0), 
        2
    ) AS OverallAcceptanceRate
FROM #FriendRequests r
LEFT JOIN #RequestAccepted a ON r.SenderID = a.RequesterID AND r.SendToID = a.AccepterID;
