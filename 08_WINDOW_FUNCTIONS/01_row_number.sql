-- ROW_NUMBER() - Fortlaufende Zeilennummerierung

WITH Employees AS (
    SELECT 1 AS EmployeeID, 85000 AS Salary UNION ALL
    SELECT 2, 92000 UNION ALL
    SELECT 3, 78000 UNION ALL
    SELECT 4, 92000
)
SELECT
    EmployeeID,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS rn
FROM Employees;
