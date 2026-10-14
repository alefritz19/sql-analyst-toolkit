-- DWH Modeling: Sternschema-Architektur (Kimball Methodologie)
-- Zentrales Faktenmodell mit Dimensionstabellen

DROP TABLE IF EXISTS #DimDate;
DROP TABLE IF EXISTS #DimCustomer;
DROP TABLE IF EXISTS #FactSales;

CREATE TABLE #DimDate (DateKey INT PRIMARY KEY, CalendarDate DATE, [Year] INT, [Quarter] VARCHAR(5), [Month] INT);
CREATE TABLE #DimCustomer (CustomerKey INT PRIMARY KEY, CustomerID VARCHAR(20), CustomerName VARCHAR(100), City VARCHAR(50));
CREATE TABLE #FactSales (SalesKey BIGINT IDENTITY(1,1), DateKey INT, CustomerKey INT, Quantity INT, ExtendedAmount DECIMAL(12,2));

INSERT INTO #DimDate VALUES (20261001, '2026-10-01', 2026, 'Q4', 10);
INSERT INTO #DimCustomer VALUES (1, 'CUST-001', 'Alpha Technologies', 'München');
INSERT INTO #FactSales (DateKey, CustomerKey, Quantity, ExtendedAmount) VALUES (20261001, 1, 5, 2490.00);

SELECT 
    d.CalendarDate,
    d.[Quarter],
    c.CustomerName,
    c.City,
    f.Quantity,
    f.ExtendedAmount
FROM #FactSales f
INNER JOIN #DimDate d ON f.DateKey = d.DateKey
INNER JOIN #DimCustomer c ON f.CustomerKey = c.CustomerKey;
