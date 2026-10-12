-- Leerzeichen entfernen (TRIM, LTRIM, RTRIM)

WITH RawCustomers AS (
    SELECT 1 AS ID, '  Firma Meier AG  ' AS CustomerName UNION ALL
    SELECT 2, 'Schmidt GmbH   ' UNION ALL
    SELECT 3, '   Bauer & Co'
)
SELECT 
    ID,
    CustomerName AS Original,
    TRIM(CustomerName) AS CleanName
FROM RawCustomers;
