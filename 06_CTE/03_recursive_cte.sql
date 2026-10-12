-- Rekursive CTE: Zahlenfolge generieren und Hierarchien auflösen

-- Beispiel: Datumskalender
WITH NumberSequence AS (
    -- Anker-Element (Anchor Member)
    SELECT 1 AS Number
    UNION ALL
    -- Rekursives Element (Recursive Member)
    SELECT Number + 1
    FROM NumberSequence
    WHERE Number < 10
)
SELECT Number
FROM NumberSequence
OPTION (MAXRECURSION 100);
