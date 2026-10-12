-- Power BI Datensatz: Kundendimension (Dimension Table)
-- Keine Fakten/Umsätze, nur beschreibende Attribute für Filter/Slicer

WITH RawCustomers AS (
    SELECT 101 AS CustID, 'Alpha GmbH' AS Name, 'München' AS City, 'Bayern' AS State, 'DE' AS Country UNION ALL
    SELECT 102, 'Beta AG', 'Hamburg', 'Hamburg', 'DE'
)
SELECT 
    CAST(CustID AS INT) AS CustomerKey,
    CAST(Name AS VARCHAR(100)) AS CustomerName,
    CAST(City AS VARCHAR(50)) AS City,
    CAST(State AS VARCHAR(50)) AS State,
    CAST(Country AS VARCHAR(10)) AS Country
FROM RawCustomers;
