-- 03_JOINS / 01_all_joins.sql - Alle JOIN-Typen im Überblick

-- Testdaten
DROP TABLE IF EXISTS #Customers;
DROP TABLE IF EXISTS #Orders;

CREATE TABLE #Customers (CustomerID INT, CustomerName VARCHAR(50));
CREATE TABLE #Orders (OrderID INT, CustomerID INT, OrderAmount DECIMAL(10,2));

INSERT INTO #Customers VALUES
(1, 'Alpha GmbH'),
(2, 'Beta AG'),
(3, 'Gamma Ltd'); -- Kein Auftrag

INSERT INTO #Orders VALUES
(101, 1, 500.00),
(102, 1, 300.00),
(103, 2, 850.00),
(104, 4, 120.00); -- Kunde existiert nicht in #Customers

-- 1. INNER JOIN (Nur Übereinstimmungen)
SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderAmount
FROM #Customers c
INNER JOIN #Orders o ON c.CustomerID = o.CustomerID;

-- 2. LEFT JOIN (Alle Kunden + vorhandene Aufträge)
SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderAmount
FROM #Customers c
LEFT JOIN #Orders o ON c.CustomerID = o.CustomerID;

-- 3. RIGHT JOIN (Alle Aufträge + vorhandene Kunden)
SELECT
    c.CustomerName,
    o.OrderID,
    o.OrderAmount
FROM #Customers c
RIGHT JOIN #Orders o ON c.CustomerID = o.CustomerID;

-- 4. FULL OUTER JOIN (Alle Kunden und alle Aufträge)
SELECT
    c.CustomerID AS Cust_ID,
    c.CustomerName,
    o.OrderID,
    o.CustomerID AS Order_Cust_ID,
    o.OrderAmount
FROM #Customers c
FULL JOIN #Orders o ON c.CustomerID = o.CustomerID;
