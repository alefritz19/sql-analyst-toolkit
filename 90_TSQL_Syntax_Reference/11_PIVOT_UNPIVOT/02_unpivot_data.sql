-- UNPIVOT-Operator: Spalten zurück in Zeilen normalisieren

DROP TABLE IF EXISTS #WideTable;
CREATE TABLE #WideTable (YearNo INT, Q1 DECIMAL(10,2), Q2 DECIMAL(10,2), Q3 DECIMAL(10,2), Q4 DECIMAL(10,2));

INSERT INTO #WideTable VALUES (2026, 11000, 17000, 14000, 22000);

SELECT 
    YearNo,
    QuarterCode,
    Revenue
FROM #WideTable
UNPIVOT (
    Revenue FOR QuarterCode IN (Q1, Q2, Q3, Q4)
) AS UnpivotTable;
