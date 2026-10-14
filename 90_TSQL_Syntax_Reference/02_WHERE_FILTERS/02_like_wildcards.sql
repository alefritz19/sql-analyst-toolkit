-- Mustersuche mit LIKE (Wildcards: %, _, [])

WITH Customers AS (
    SELECT 1 AS ID, 'Alex Fritz' AS FullName, 'alex@example.com' AS Email UNION ALL
    SELECT 2, 'Anna Fischer', 'anna@domain.de' UNION ALL
    SELECT 3, 'Bernd Weber', 'bernd@work.com' UNION ALL
    SELECT 4, 'Claudia Kraft', 'ckraft@web.de'
)
SELECT *
FROM Customers
WHERE FullName LIKE 'A%'          -- Beginnt mit A
  AND Email LIKE '%@example.com'; -- Endet auf @example.com
