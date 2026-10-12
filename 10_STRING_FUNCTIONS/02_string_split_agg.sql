-- Moderne String-Funktionen: STRING_SPLIT und STRING_AGG (ab SQL Server 2017)

-- 1. STRING_SPLIT: CSV-String in Zeilen aufteilen
DECLARE @Tags VARCHAR(100) = 'SQL,Python,PowerBI,Azure,Docker';

SELECT value AS SkillName
FROM STRING_SPLIT(@Tags, ',');

-- 2. STRING_AGG: Zeilen zu einer kommagetrennten Liste aggregieren
WITH Employees AS (
    SELECT 'IT' AS Dept, 'Alex' AS Name UNION ALL
    SELECT 'IT', 'Anna' UNION ALL
    SELECT 'Sales', 'Bernd' UNION ALL
    SELECT 'Sales', 'Claudia'
)
SELECT 
    Dept,
    STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name ASC) AS TeamMembers
FROM Employees
GROUP BY Dept;
