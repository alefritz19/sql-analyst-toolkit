-- Duplikate identifizieren mit GROUP BY & HAVING

WITH Users AS (
    SELECT 1 AS UserID, 'alex@example.com' AS Email UNION ALL
    SELECT 2, 'anna@example.com' UNION ALL
    SELECT 3, 'alex@example.com' UNION ALL
    SELECT 4, 'bernd@example.com' UNION ALL
    SELECT 5, 'anna@example.com'
)
SELECT 
    Email,
    COUNT(*) AS DuplicateCount
FROM Users
GROUP BY Email
HAVING COUNT(*) > 1;
