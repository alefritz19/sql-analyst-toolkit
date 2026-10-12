-- Azure SQL: Temporale Tabellen (System-Versioned Temporal Tables)
-- Automatische Nachverfolgung aller historischen Änderungen (Point-in-Time Queries)

/*
CREATE TABLE dbo.EmployeeSalaries
(
    EmpID INT PRIMARY KEY,
    Salary DECIMAL(10,2) NOT NULL,
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeSalaries_History));

-- Zeitreise-Abfrage (Historischer Stand zu einem Stichtag):
SELECT * FROM dbo.EmployeeSalaries FOR SYSTEM_TIME AS OF '2025-06-01 12:00:00';
*/

SELECT 'Temporale Tabellen protokollieren historische Änderungen vollautomatisch im DBMS' AS TemporalBenefit;
