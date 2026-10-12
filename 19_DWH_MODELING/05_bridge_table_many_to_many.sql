-- DWH Modeling: Brückentabelle (Bridge Table für m:n Beziehungen)
-- Beispiel: Ein Bankkonto hat mehrere Inhaber, ein Kunde hat mehrere Konten

DROP TABLE IF EXISTS #DimBridgeAccount;
DROP TABLE IF EXISTS #DimBridgeCustomer;
DROP TABLE IF EXISTS #BridgeAccountCustomer;

CREATE TABLE #DimBridgeAccount (AccountKey INT PRIMARY KEY, AccountNumber VARCHAR(30));
CREATE TABLE #DimBridgeCustomer (CustomerKey INT PRIMARY KEY, CustomerName VARCHAR(100));
CREATE TABLE #BridgeAccountCustomer (AccountKey INT, CustomerKey INT, OwnershipWeight DECIMAL(5,2));

INSERT INTO #DimBridgeAccount VALUES (1, 'DE89370400440532013000');
INSERT INTO #DimBridgeCustomer VALUES (101, 'Ehemann Müller'), (102, 'Ehefrau Müller');
INSERT INTO #BridgeAccountCustomer VALUES (1, 101, 0.50), (1, 102, 0.50);

SELECT 
    a.AccountNumber,
    c.CustomerName,
    b.OwnershipWeight
FROM #BridgeAccountCustomer b
INNER JOIN #DimBridgeAccount a ON b.AccountKey = a.AccountKey
INNER JOIN #DimBridgeCustomer c ON b.CustomerKey = c.CustomerKey;
