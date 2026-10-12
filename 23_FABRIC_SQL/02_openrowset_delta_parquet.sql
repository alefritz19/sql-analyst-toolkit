-- Microsoft Fabric / Synapse: OPENROWSET zur Abfrage von Delta Lake & Parquet
-- Serverless SQL Abfrage direkt auf Azure Data Lake Storage (ADLS Gen2)

/*
SELECT TOP 100 *
FROM OPENROWSET(
    BULK 'https://myfabricstorage.dfs.core.windows.net/lakehouse/Tables/sales_delta/',
    FORMAT = 'DELTA'
) AS [result];
*/

SELECT 'OPENROWSET liest Parquet, CSV und Delta Lake ohne vorheriges Laden in Tabellen' AS OpenrowsetNote;
