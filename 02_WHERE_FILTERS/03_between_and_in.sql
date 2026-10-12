-- Wertebereiche (BETWEEN) und Wertelisten (IN)

WITH Products AS (
    SELECT 1 AS ID, 'Monitor' AS Name, 'IT' AS Category, 250 AS Price UNION ALL
    SELECT 2, 'Kabel', 'IT', 15 UNION ALL
    SELECT 3, 'Schreibtisch', 'Office', 300 UNION ALL
    SELECT 4, 'Stuhl', 'Office', 180 UNION ALL
    SELECT 5, 'Kaffee', 'Food', 12
)
SELECT *
FROM Products
WHERE Category IN ('IT', 'Office')
  AND Price BETWEEN 50 AND 300; -- Beide Grenzen inklusive
