-- Durchsuchtes CASE (Searched CASE) mit logischen Ausdrücken

WITH Scores AS (
    SELECT 'Student A' AS Name, 95 AS Score UNION ALL
    SELECT 'Student B', 82 UNION ALL
    SELECT 'Student C', 67 UNION ALL
    SELECT 'Student D', 45
)
SELECT 
    Name,
    Score,
    CASE 
        WHEN Score >= 90 THEN 'Sehr gut (A)'
        WHEN Score >= 80 THEN 'Gut (B)'
        WHEN Score >= 65 THEN 'Befriedigend (C)'
        ELSE 'Nicht bestanden (F)'
    END AS Grade
FROM Scores;
