-- ETL Pattern: Staging-Tabelle bereinigen & initial laden (Truncate & Load)

DROP TABLE IF EXISTS #Staging_Customers;
DROP TABLE IF EXISTS #Core_Customers;

CREATE TABLE #Staging_Customers (RawID VARCHAR(50), RawName VARCHAR(100), RawEmail VARCHAR(100));
CREATE TABLE #Core_Customers (CustomerID INT PRIMARY KEY, CustomerName VARCHAR(100), Email VARCHAR(100), LoadedAt DATETIME);

-- Rohdaten in Staging
INSERT INTO #Staging_Customers VALUES ('101', '  Max Mustermann  ', 'max@muster.de  '), ('102', 'Anna Schmidt', 'anna@work.com');

-- Bereinigter Ladevorgang in Core
INSERT INTO #Core_Customers (CustomerID, CustomerName, Email, LoadedAt)
SELECT 
    CAST(TRIM(RawID) AS INT),
    TRIM(RawName),
    LOWER(TRIM(RawEmail)),
    GETDATE()
FROM #Staging_Customers;

SELECT * FROM #Core_Customers;
