-- JSON in T-SQL verarbeiten: ISJSON, JSON_VALUE, JSON_QUERY, OPENJSON

DECLARE @JsonDoc NVARCHAR(MAX) = N'{
    "orderId": 5001,
    "customer": {
        "id": 12,
        "name": "Alex Fritz",
        "city": "Berlin"
    },
    "items": [
        {"product": "Laptop", "price": 1200},
        {"product": "Mouse", "price": 30}
    ]
}';

-- 1. Validierung
SELECT ISJSON(@JsonDoc) AS IsValidJson;

-- 2. Skalare Werte extrahieren (JSON_VALUE)
SELECT 
    JSON_VALUE(@JsonDoc, '$.orderId') AS OrderID,
    JSON_VALUE(@JsonDoc, '$.customer.name') AS CustomerName,
    JSON_VALUE(@JsonDoc, '$.customer.city') AS CustomerCity;

-- 3. Array in relationale Zeilen aufbrechen (OPENJSON)
SELECT *
FROM OPENJSON(@JsonDoc, '$.items')
WITH (
    Product VARCHAR(50) '$.product',
    Price DECIMAL(10,2) '$.price'
);
