-- Power BI Datensatz: Komplettes Sternschema (Star Schema Overview)
-- Zeigt die Verknüpfung zwischen Fact Table und den Dimensionen

-- Fact Table:
-- dbo.FactSales (OrderKey, DateKey, CustomerKey, ProductKey, Quantity, SalesAmount)
-- Dimensionen:
-- dbo.DimCustomer (CustomerKey, CustomerName, City, Country)
-- dbo.DimProduct  (ProductKey, ProductName, Category)
-- dbo.DimDate     (DateKey, Year, Month, Quarter)

SELECT 
    'FactSales 1:n DimCustomer' AS Relationship_1,
    'FactSales 1:n DimProduct'  AS Relationship_2,
    'FactSales 1:n DimDate'     AS Relationship_3,
    'Best Practice: Einweg-Filterrichtung (Single Cross-Filter Direction)' AS Recommendation;
