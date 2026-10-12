-- Azure SQL: Elastische Datenbankabfragen (Elastic Database Query / External Tables)
-- Verteilte Abfragen über mehrere separate Azure SQL Datenbanken hinweg

/*
CREATE EXTERNAL DATA SOURCE RemoteShardDatabase
WITH (
    TYPE = RDBMS,
    LOCATION = 'europeserver.database.windows.net',
    DATABASE_NAME = 'ShardCustomerDB',
    CREDENTIAL = ElasticDBQueryCred
);

CREATE EXTERNAL TABLE [dbo].[RemoteCustomers]
(
    CustomerID INT NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL
)
WITH (DATA_SOURCE = RemoteShardDatabase);
*/

SELECT 'Elastische Abfragen ermöglichen Sharding und Cross-DB Joins in Azure SQL' AS ElasticQueryNote;
