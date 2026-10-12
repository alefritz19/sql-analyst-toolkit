-- Advanced T-SQL: Sicheres dynamisches SQL mit sp_executesql & Parametrisierung

DROP TABLE IF EXISTS #Products;
CREATE TABLE #Products (ProductID INT, Category VARCHAR(50), Price DECIMAL(10,2));
INSERT INTO #Products VALUES (1, 'IT', 950), (2, 'Office', 120), (3, 'IT', 450);

DECLARE @SqlStmt NVARCHAR(MAX);
DECLARE @ParamDef NVARCHAR(500);
DECLARE @InputCategory VARCHAR(50) = 'IT';
DECLARE @MinPrice DECIMAL(10,2) = 400.00;

-- Parametrisierte Abfrage verhindert SQL-Injection und ermöglicht Plan-Caching
SET @SqlStmt = N'SELECT ProductID, Category, Price FROM #Products WHERE Category = @Cat AND Price >= @Min';
SET @ParamDef = N'@Cat VARCHAR(50), @Min DECIMAL(10,2)';

EXEC sp_executesql 
    @stmt = @SqlStmt, 
    @params = @ParamDef, 
    @Cat = @InputCategory, 
    @Min = @MinPrice;
