-- Skalare Unterabfragen (Liefern genau 1 Wert zurück)

WITH Employees AS (
    SELECT 1 AS ID, 'Anna' AS Name, 4000 AS Salary UNION ALL
    SELECT 2, 'Bernd', 6000 UNION ALL
    SELECT 3, 'Clara', 5000 UNION ALL
    SELECT 4, 'David', 9000
)
SELECT 
    ID,
    Name,
    Salary,
    (SELECT AVG(Salary) FROM Employees) AS CompanyAvgSalary,
    Salary - (SELECT AVG(Salary) FROM Employees) AS DiffToAverage
FROM Employees;
