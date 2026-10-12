-- DWH Modeling: Periodische Schnappschuss-Faktentabelle (Periodic Snapshot Fact Table)
-- Stichtagsbezogene Lager- und Kontostände (End-of-Month)

DROP TABLE IF EXISTS #PeriodicInventorySnapshot;
CREATE TABLE #PeriodicInventorySnapshot (
    SnapshotDateKey INT,
    ProductKey INT,
    WarehouseKey INT,
    QuantityOnHand INT,
    TotalInventoryValue DECIMAL(12,2)
);

INSERT INTO #PeriodicInventorySnapshot VALUES
(20260831, 101, 1, 450, 112500.00),
(20260930, 101, 1, 380,  95000.00),
(20261031, 101, 1, 520, 130000.00);

SELECT 
    SnapshotDateKey,
    ProductKey,
    QuantityOnHand,
    TotalInventoryValue,
    QuantityOnHand - LAG(QuantityOnHand) OVER (PARTITION BY ProductKey ORDER BY SnapshotDateKey) AS InventoryDelta
FROM #PeriodicInventorySnapshot;
