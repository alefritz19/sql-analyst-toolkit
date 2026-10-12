-- Interview Cheatsheet: Häufige JOIN-Fragen

-- Frage: Was ist der Unterschied zwischen LEFT JOIN mit WHERE filter und mit ON filter?

DROP TABLE IF EXISTS #A;
DROP TABLE IF EXISTS #B;
CREATE TABLE #A (ID INT);
CREATE TABLE #B (ID INT, Val VARCHAR(10));
INSERT INTO #A VALUES (1), (2);
INSERT INTO #B VALUES (1, 'X'), (2, 'Y');

-- Filter im ON (behält alle Zeilen aus A):
SELECT a.ID, b.Val
FROM #A a
LEFT JOIN #B b ON a.ID = b.ID AND b.Val = 'X';

-- Filter im WHERE (macht aus dem LEFT JOIN faktisch einen INNER JOIN):
SELECT a.ID, b.Val
FROM #A a
LEFT JOIN #B b ON a.ID = b.ID
WHERE b.Val = 'X';
