-- SQL Challenge: Exakte Median-Berechnung in T-SQL (PERCENTILE_CONT vs. ROW_NUMBER)

DROP TABLE IF EXISTS #TestScores;
CREATE TABLE #TestScores (Score INT);
INSERT INTO #TestScores VALUES (50), (60), (70), (80), (90), (100);

-- Methode 1: Standard ANSI-SQL mit PERCENTILE_CONT
SELECT DISTINCT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Score) OVER () AS MedianScore_Method1
FROM #TestScores;

-- Methode 2: Reine Mathematische Logik über Rangfolgen (funktioniert überall)
WITH OrderedScores AS (
    SELECT 
        Score,
        ROW_NUMBER() OVER (ORDER BY Score ASC) AS RowAsc,
        ROW_NUMBER() OVER (ORDER BY Score DESC) AS RowDesc
    FROM #TestScores
)
SELECT 
    AVG(Score * 1.0) AS MedianScore_Method2
FROM OrderedScores
WHERE ABS(CAST(RowAsc AS INT) - CAST(RowDesc AS INT)) <= 1;
