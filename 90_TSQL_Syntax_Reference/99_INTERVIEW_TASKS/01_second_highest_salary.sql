-- Interview-Aufgabe: Zweithöchstes Gehalt finden

DROP TABLE IF EXISTS #SalaryStaff;
CREATE TABLE #SalaryStaff (EmpID INT, Salary INT);
INSERT INTO #SalaryStaff VALUES (1, 100), (2, 200), (3, 300), (4, 300);

-- Lösung 1: Mit Subquery (Klassiker)
SELECT MAX(Salary) AS SecondHighest_Method1
FROM #SalaryStaff
WHERE Salary < (SELECT MAX(Salary) FROM #SalaryStaff);

-- Lösung 2: Mit DENSE_RANK() (Berücksichtigt Duplikate)
WITH RankedSalaries AS (
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
    FROM #SalaryStaff
)
SELECT MAX(Salary) AS SecondHighest_Method2
FROM RankedSalaries
WHERE rnk = 2;
