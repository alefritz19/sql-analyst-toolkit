-- RANK() vs. DENSE_RANK() - Rangfolgebildung bei gleichen Werten

WITH Employees AS (
    SELECT 1 AS EmployeeID, 92000 AS Salary UNION ALL
    SELECT 2, 92000 UNION ALL
    SELECT 3, 85000 UNION ALL
    SELECT 4, 78000
)
SELECT
    EmployeeID,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) AS rnk,          -- Lücken bei Gleichstand (1, 1, 3, 4)
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS drnk    -- Keine Lücken (1, 1, 2, 3)
FROM Employees;
