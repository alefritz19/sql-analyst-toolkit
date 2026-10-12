-- DWH Modeling: Schneeflockenschema (Snowflake Schema)
-- Normalisierte Dimensionen (Produkt -> Unterkategorie -> Hauptkategorie)

DROP TABLE IF EXISTS #DimCategory;
DROP TABLE IF EXISTS #DimSubcategory;
DROP TABLE IF EXISTS #DimProduct;

CREATE TABLE #DimCategory (CategoryKey INT PRIMARY KEY, CategoryName VARCHAR(50));
CREATE TABLE #DimSubcategory (SubcategoryKey INT PRIMARY KEY, CategoryKey INT, SubcategoryName VARCHAR(50));
CREATE TABLE #DimProduct (ProductKey INT PRIMARY KEY, SubcategoryKey INT, ProductName VARCHAR(100), UnitPrice DECIMAL(10,2));

INSERT INTO #DimCategory VALUES (1, 'Hardware');
INSERT INTO #DimSubcategory VALUES (10, 1, 'Computer');
INSERT INTO #DimProduct VALUES (100, 10, 'Enterprise Workstation', 1899.00);

-- Denormalisierte Sicht für Reporting
SELECT 
    p.ProductKey,
    p.ProductName,
    p.UnitPrice,
    s.SubcategoryName,
    c.CategoryName
FROM #DimProduct p
INNER JOIN #DimSubcategory s ON p.SubcategoryKey = s.SubcategoryKey
INNER JOIN #DimCategory c ON s.CategoryKey = c.CategoryKey;
