-- Vergleichsoperatoren (=, <>, !=, >, <, >=, <=)

WITH Sales AS (
    SELECT 1 AS ID, 150 AS Amount UNION ALL
    SELECT 2, 450 UNION ALL
    SELECT 3, 800 UNION ALL
    SELECT 4, 300
)
SELECT *
FROM Sales
WHERE Amount >= 300 AND Amount <> 450;
