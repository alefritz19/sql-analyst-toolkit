-- ETL Pattern: Slowly Changing Dimension (SCD Type 1 & Type 2)

-- SCD Typ 1: Überschreiben (keine Historie)
-- UPDATE dbo.DimCustomer SET City = @NewCity WHERE CustKey = @Key;

-- SCD Typ 2: Historisierung mit Gültigkeitszeitraum & IsCurrent-Flag
DROP TABLE IF EXISTS #DimCustomer_SCD2;
CREATE TABLE #DimCustomer_SCD2 (
    CustKey INT IDENTITY(1,1),
    CustomerID INT,
    City VARCHAR(50),
    ValidFrom DATE,
    ValidTo DATE,
    IsCurrent BIT
);

INSERT INTO #DimCustomer_SCD2 VALUES
(101, 'München', '2024-01-01', '2026-06-30', 0),
(101, 'Berlin',  '2026-07-01', '9999-12-31', 1);

-- Abfrage des aktuell gültigen Zustands
SELECT * FROM #DimCustomer_SCD2 WHERE IsCurrent = 1;

-- Abfrage des historischen Zustands zum 01.03.2025
SELECT * FROM #DimCustomer_SCD2 WHERE '2025-03-01' BETWEEN ValidFrom AND ValidTo;
