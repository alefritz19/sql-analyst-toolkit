-- Wiederherstellungsskript für WideWorldImporters
USE master;
GO

/*
RESTORE DATABASE WideWorldImporters
FROM DISK = 'C:\SQL_Backups\WideWorldImporters-Full.bak'
WITH 
    MOVE 'WWI_Primary' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\WideWorldImporters.mdf',
    MOVE 'WWI_UserData' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\WideWorldImporters_UserData.ndf',
    MOVE 'WWI_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\WideWorldImporters.ldf',
    REPLACE,
    STATS = 10;
GO
*/

SELECT 'WideWorldImporters Restore Script bereitgestellt' AS Info;
