-- DWH Modeling: Junk-Dimension (Müllsammler für Flags & Statusindikatoren)
-- Vermeidet dutzende separate 1-Spalten-Dimensionen in der Faktentabelle

DROP TABLE IF EXISTS #DimTransactionFlags;
CREATE TABLE #DimTransactionFlags (
    FlagKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod VARCHAR(20),
    IsOnlinePurchase BIT,
    DeliveryStatus VARCHAR(20),
    IsReturned BIT
);

INSERT INTO #DimTransactionFlags (PaymentMethod, IsOnlinePurchase, DeliveryStatus, IsReturned)
VALUES 
('Kreditkarte', 1, 'Zugestellt', 0),
('PayPal', 1, 'In Zustellung', 0),
('Rechnung', 0, 'Storniert', 1),
('Lastschrift', 1, 'Retoure', 1);

SELECT * FROM #DimTransactionFlags;
