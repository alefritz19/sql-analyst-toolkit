-- Interview-Aufgabe: Top 1 (oder Top N) Bestverdiener je Abteilung

WITH Staff AS (
    SELECT 'IT' AS Dept, 'Alex' AS Name, 8000 AS Salary UNION ALL
    SELECT 'IT', 'David', 9500 UNION ALL
    SELECT 'IT', 'Anna', 9500 UNION ALL
    SELECT 'HR', 'Laura', 5200 UNION ALL
    SELECT 'HR', 'Michael', 4800
),
RankedStaff AS (
    SELECT 
        Dept,
        Name,
        Salary,
        DENSE_RANK() OVER (PARTITION BY Dept ORDER BY Salary DESC) AS SalaryRank
    FROM Staff
)
SELECT Dept, Name, Salary
FROM RankedStaff
WHERE SalaryRank = 1;
