-- Power BI Datensatz: Produktdimension (Dimension Table)

WITH RawProducts AS (
    SELECT 501 AS ProdID, 'Ergonomische Maus' AS Name, 'Zubehör' AS Category, 'IT' AS Department UNION ALL
    SELECT 502, 'Bürostuhl Pro', 'Möbel', 'Office' UNION ALL
    SELECT 503, 'USB-C Hub', 'Kabel & Adapter', 'IT'
)
SELECT 
    CAST(ProdID AS INT) AS ProductKey,
    CAST(Name AS VARCHAR(100)) AS ProductName,
    CAST(Category AS VARCHAR(50)) AS ProductCategory,
    CAST(Department AS VARCHAR(50)) AS ProductDepartment
FROM RawProducts;
