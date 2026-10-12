-- Lokale (#) und Globale (##) temporäre Tabellen

-- Lokale temporäre Tabelle (nur in der aktuellen Session sichtbar, liegt in tempdb)
DROP TABLE IF EXISTS #TempReport;

CREATE TABLE #TempReport (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ReportDate DATE,
    TotalRevenue DECIMAL(12,2)
);

INSERT INTO #TempReport (ReportDate, TotalRevenue)
VALUES ('2026-10-01', 54200.50), ('2026-10-02', 61800.00);

SELECT * FROM #TempReport;
