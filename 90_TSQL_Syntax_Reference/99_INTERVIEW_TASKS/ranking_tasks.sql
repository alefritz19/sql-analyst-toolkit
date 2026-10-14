-- Interview Cheatsheet: Ranking-Aufgaben (ROW_NUMBER vs. DENSE_RANK)

DROP TABLE IF EXISTS #Candidates;
CREATE TABLE #Candidates (ID INT, Score INT);
INSERT INTO #Candidates VALUES (1, 100), (2, 95), (3, 95), (4, 90), (5, 80);

-- Finde alle Kandidaten in den Top 2 Rängen (inklusive Gleichstände)
WITH RankedScores AS (
    SELECT ID, Score, DENSE_RANK() OVER (ORDER BY Score DESC) AS rnk
    FROM #Candidates
)
SELECT ID, Score, rnk
FROM RankedScores
WHERE rnk <= 2;
