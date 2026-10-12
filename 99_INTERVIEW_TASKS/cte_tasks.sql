-- Interview Cheatsheet: CTE-Aufgaben (Hierarchien auflösen)

DROP TABLE IF EXISTS #OrgChart;
CREATE TABLE #OrgChart (EmpID INT, ManagerID INT, Title VARCHAR(50));
INSERT INTO #OrgChart VALUES (1, NULL, 'CEO'), (2, 1, 'VP Sales'), (3, 2, 'Sales Director'), (4, 3, 'Account Exec');

-- Aufgabe: Organisationslevel über rekursiven CTE ermitteln
WITH HierarchyCTE AS (
    SELECT EmpID, ManagerID, Title, 1 AS OrgLevel
    FROM #OrgChart
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT c.EmpID, c.ManagerID, c.Title, h.OrgLevel + 1
    FROM #OrgChart c
    JOIN HierarchyCTE h ON c.ManagerID = h.EmpID
)
SELECT * FROM HierarchyCTE;
