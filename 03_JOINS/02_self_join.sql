-- SELF JOIN - Eine Tabelle mit sich selbst verknüpfen (z. B. Mitarbeiter & Vorgesetzte)

DROP TABLE IF EXISTS #Employees;
CREATE TABLE #Employees (EmployeeID INT, Name VARCHAR(50), ManagerID INT);

INSERT INTO #Employees VALUES 
(1, 'CEO Boss', NULL),
(2, 'Department Lead A', 1),
(3, 'Department Lead B', 1),
(4, 'Junior Analyst', 2),
(5, 'Senior Developer', 3);

SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    ISNULL(m.Name, 'TOP MANAGEMENT') AS ManagerName
FROM #Employees e
LEFT JOIN #Employees m ON e.ManagerID = m.EmployeeID;
