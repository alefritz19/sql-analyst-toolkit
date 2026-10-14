-- 01_SELECT / 01_basic_select.sql - Grundlagen der Abfrage

-- Mock Data (Autonome Daten ohne Tabelle)
WITH Employees AS (
    SELECT 1 AS EmployeeID, 'Max' AS FirstName, 'Mustermann' AS LastName, 'Sales' AS Department, 55000 AS Salary UNION ALL
    SELECT 2, 'Anna', 'Schmidt', 'IT', 72000 UNION ALL
    SELECT 3, 'David', 'Meyer', 'Sales', 48000
)
SELECT
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary
FROM Employees;
