-- Advanced T-SQL: Transaktionskontrolle & Fehlerbehandlung (TRY...CATCH & XACT_ABORT)

SET XACT_ABORT ON;

DROP TABLE IF EXISTS #BankAccounts;
CREATE TABLE #BankAccounts (AccountID INT PRIMARY KEY, Balance DECIMAL(10,2));
INSERT INTO #BankAccounts VALUES (1, 1000.00), (2, 500.00);

BEGIN TRY
    BEGIN TRANSACTION;
        -- 200 Euro von Konto 1 auf Konto 2 überweisen
        UPDATE #BankAccounts SET Balance = Balance - 200.00 WHERE AccountID = 1;
        UPDATE #BankAccounts SET Balance = Balance + 200.00 WHERE AccountID = 2;
    COMMIT TRANSACTION;
    SELECT 'Transaktion erfolgreich durchgeführt' AS StatusText;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    SELECT 
        ERROR_NUMBER() AS ErrorNum,
        ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

SELECT * FROM #BankAccounts;
