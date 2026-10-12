-- Interview-Aufgabe: Duplikate finden und zählen

WITH Users AS (
    SELECT 'alex@domain.de' AS Email UNION ALL
    SELECT 'anna@domain.de' UNION ALL
    SELECT 'alex@domain.de' UNION ALL
    SELECT 'bernd@domain.de'
)
SELECT 
    Email,
    COUNT(*) AS DuplicateCount
FROM Users
GROUP BY Email
HAVING COUNT(*) > 1;
