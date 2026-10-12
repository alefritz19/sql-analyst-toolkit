-- Microsoft Fabric: Synapse Data Warehouse T-SQL Features
-- Vollwertiges ACID-fähiges Data Warehouse mit Unterstützung für DML (INSERT, UPDATE, DELETE)

/*
CREATE TABLE dbo.DimStore
(
    StoreKey INT NOT NULL,
    StoreName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL
);

COPY INTO dbo.DimStore
FROM 'https://myaccount.dfs.core.windows.net/container/stores.parquet'
WITH (FILE_TYPE = 'PARQUET');
*/

SELECT 'Fabric Warehouse bietet vollständige Transaktionssicherheit (ACID) über Parquet' AS WarehouseCapability;
