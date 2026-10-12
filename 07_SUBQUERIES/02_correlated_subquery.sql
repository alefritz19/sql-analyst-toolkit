-- Korrelierte Unterabfragen (Referenzieren die äußere Abfrage)

DROP TABLE IF EXISTS #Staff;
CREATE TABLE #Staff (ID INT, Dept VARCHAR(20), Salary INT);
INSERT INTO #Staff VALUES 
(1, 'IT', 7000), (2, 'IT', 8500), (3, 'IT', 6000),
(4, 'HR', 4000), (5, 'HR', 4500);

-- Finde Mitarbeiter, die mehr verdienen als der Durchschnitt ihrer Abteilung
SELECT s.ID, s.Dept, s.Salary
FROM #Staff s
WHERE s.Salary > (
    SELECT AVG(sub.Salary)
    FROM #Staff sub
    WHERE sub.Dept = s.Dept
);
