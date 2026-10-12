-- Advanced T-SQL: Mengenbasierte Operationen (Set-Based) statt Cursor
-- Cursor verarbeiten Zeile für Zeile (RBAR: Row-By-Agonizing-Row) und sind extrem langsam

DROP TABLE IF EXISTS #SalesDaily;
CREATE TABLE #SalesDaily (DayID INT, Amount DECIMAL(10,2));
INSERT INTO #SalesDaily VALUES (1, 100), (2, 250), (3, 180), (4, 400);

-- SCHLECHT: Cursor mit Schleife
-- GUT: Fensterfunktion (Set-Based)
SELECT 
    DayID,
    Amount,
    SUM(Amount) OVER (ORDER BY DayID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SetBasedRunningTotal
FROM #SalesDaily;
