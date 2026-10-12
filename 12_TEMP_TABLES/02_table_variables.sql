-- Tabellenvariablen (@TableVariable)

DECLARE @CategoryLookup TABLE (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50),
    TaxRate DECIMAL(4,2)
);

INSERT INTO @CategoryLookup VALUES 
(1, 'Lebensmittel', 0.07),
(2, 'Elektronik', 0.19),
(3, 'Bücher', 0.07);

SELECT * FROM @CategoryLookup;
