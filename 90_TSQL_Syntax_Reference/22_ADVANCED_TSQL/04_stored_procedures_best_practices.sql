-- Advanced T-SQL: Stored Procedures Best Practices (SET NOCOUNT ON & Error Handling)

/*
CREATE OR ALTER PROCEDURE dbo.usp_UpsertCustomerMonthlyKPI
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    BEGIN TRY
        -- Logik zur Aggregation
        SELECT 
            @Year AS ReportYear,
            @Month AS ReportMonth,
            COUNT(*) AS OrdersTotal
        FROM dbo.Orders
        WHERE YEAR(OrderDate) = @Year AND MONTH(OrderDate) = @Month;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
*/

SELECT 'Stored Procedures kapseln komplexe Geschäftslogik und sichern Ausführungspläne' AS Concept;
