/*
================================================================================
MASTER-GUIDE: FENSTERFUNKTIONEN IN T-SQL (WINDOW FUNCTIONS MASTERCLASS)
Alle 11 wichtigsten Fensterfunktionen an einem einzigen Datensatz:
  1. ROW_NUMBER()
  2. RANK()
  3. DENSE_RANK()
  4. NTILE()
  5. LAG()
  6. LEAD()
  7. FIRST_VALUE()
  8. LAST_VALUE()
  9. SUM() OVER()
  10. AVG() OVER()
  11. COUNT() OVER()
================================================================================
*/

DROP TABLE IF EXISTS #EmployeePerformance;

CREATE TABLE #EmployeePerformance (
    EmpID INT,
    EmpName VARCHAR(50),
    Department VARCHAR(50),
    Region VARCHAR(20),
    HireDate DATE,
    Salary DECIMAL(10,2),
    SalesCount INT
);

INSERT INTO #EmployeePerformance VALUES
(1, 'Klaus Müller',    'Sales', 'Nord', '2020-03-15', 65000, 120),
(2, 'Sarah Wagner',    'Sales', 'Nord', '2021-06-01', 72000, 150),
(3, 'Michael Koch',    'Sales', 'Süd',  '2019-11-10', 72000, 140),
(4, 'Julia Bauer',     'Sales', 'Süd',  '2022-01-15', 58000, 95),
(5, 'David Becker',    'IT',    'Nord', '2018-05-20', 85000, 10),
(6, 'Elena Schulz',    'IT',    'Nord', '2020-09-01', 90000, 15),
(7, 'Markus Braun',    'IT',    'Süd',  '2019-02-14', 82000, 8),
(8, 'Laura Hoffmann',  'HR',    'Nord', '2021-04-10', 50000, 5),
(9, 'Tobias Richter',  'HR',    'Süd',  '2022-08-22', 48000, 4);

-- 1. RANGFOLGE-FUNKTIONEN (Ranking Functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE)
SELECT 
    EmpName,
    Department,
    Salary,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS RowNum_In_Dept,
    RANK()       OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank_In_Dept,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DenseRank_In_Dept,
    NTILE(2)     OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryQuartile
FROM #EmployeePerformance;

-- 2. WERTE-FUNKTIONEN (Value Functions: LAG, LEAD, FIRST_VALUE, LAST_VALUE)
SELECT 
    EmpName,
    Department,
    HireDate,
    Salary,
    LAG(Salary, 1, 0) OVER (PARTITION BY Department ORDER BY HireDate) AS PrevHiredSalary,
    LEAD(Salary, 1, 0) OVER (PARTITION BY Department ORDER BY HireDate) AS NextHiredSalary,
    FIRST_VALUE(EmpName) OVER (PARTITION BY Department ORDER BY Salary DESC) AS TopEarnerInDept,
    -- WICHTIG: LAST_VALUE benötigt expliziten Fensterrahmen (ROWS BETWEEN ... AND UNBOUNDED FOLLOWING)
    LAST_VALUE(EmpName) OVER (
        PARTITION BY Department 
        ORDER BY Salary DESC 
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS LowestEarnerInDept
FROM #EmployeePerformance;

-- 3. AGGREGATIONEN MIT FENSTERRAHMEN (SUM, AVG, COUNT OVER)
SELECT 
    EmpName,
    Department,
    Salary,
    COUNT(*)    OVER (PARTITION BY Department) AS TotalEmployeesInDept,
    SUM(Salary) OVER (PARTITION BY Department) AS TotalDeptSalary,
    ROUND(Salary * 100.0 / SUM(Salary) OVER (PARTITION BY Department), 2) AS PctOfDeptSalary,
    AVG(Salary) OVER (PARTITION BY Department) AS AvgDeptSalary,
    -- Gleitender Durchschnitt (Moving Average über 3 Zeilen)
    AVG(Salary) OVER (
        PARTITION BY Department 
        ORDER BY HireDate 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS MovingAvgSalary_3Rows
FROM #EmployeePerformance;
