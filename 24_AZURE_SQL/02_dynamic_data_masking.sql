-- Azure SQL & SQL Server: Dynamische Datenmaskierung (Dynamic Data Masking - DDM)
-- Maskiert sensible Daten (DSGVO / GDPR) zur Laufzeit für unprivilegierte Benutzer

DROP TABLE IF EXISTS #ProtectedEmployees;
CREATE TABLE #ProtectedEmployees (
    EmpID INT,
    FirstName VARCHAR(50),
    Email VARCHAR(100) MASKED WITH (FUNCTION = 'email()'),
    Salary DECIMAL(10,2) MASKED WITH (FUNCTION = 'random(1000, 9999)')
);

INSERT INTO #ProtectedEmployees VALUES 
(1, 'Max', 'max.mustermann@unternehmen.de', 75000.00);

SELECT * FROM #ProtectedEmployees;
