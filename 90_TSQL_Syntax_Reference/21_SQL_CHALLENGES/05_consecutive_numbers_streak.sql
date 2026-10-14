-- SQL Challenge: Zahlen, die mindestens 3 Mal hintereinander erscheinen

DROP TABLE IF EXISTS #Logs;
CREATE TABLE #Logs (ID INT IDENTITY(1,1), Num INT);
INSERT INTO #Logs (Num) VALUES (1), (1), (1), (2), (1), (2), (2);

WITH NumberStreaks AS (
    SELECT 
        Num,
        LAG(Num, 1) OVER (ORDER BY ID) AS Prev1,
        LAG(Num, 2) OVER (ORDER BY ID) AS Prev2
    FROM #Logs
)
SELECT DISTINCT Num AS ConsecutiveNumber
FROM NumberStreaks
WHERE Num = Prev1 AND Num = Prev2;
