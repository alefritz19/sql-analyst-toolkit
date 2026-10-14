-- EXISTS und NOT EXISTS (Effiziente Existenzprüfung)

DROP TABLE IF EXISTS #Clients;
DROP TABLE IF EXISTS #Invoices;
CREATE TABLE #Clients (ClientID INT, Name VARCHAR(50));
CREATE TABLE #Invoices (InvoiceID INT, ClientID INT);

INSERT INTO #Clients VALUES (1, 'Firma 1'), (2, 'Firma 2'), (3, 'Firma 3');
INSERT INTO #Invoices VALUES (101, 1), (102, 1);

-- Kunden OHNE Rechnungen finden (NOT EXISTS ist performanter als NOT IN mit NULLs)
SELECT c.ClientID, c.Name
FROM #Clients c
WHERE NOT EXISTS (
    SELECT 1
    FROM #Invoices i
    WHERE i.ClientID = c.ClientID
);
