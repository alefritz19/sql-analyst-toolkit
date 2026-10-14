-- KNIME Analytics Platform: Dynamische Parameter über Flow Variables
-- In KNIME werden Variablen im SQL-Query mit [Ivariable_name] injiziert

DROP TABLE IF EXISTS #ReportData;
CREATE TABLE #ReportData (LogDate DATE, ValueAmount DECIMAL(10,2));
INSERT INTO #ReportData VALUES ('2026-10-01', 500), ('2026-10-02', 750);

-- Entspricht im KNIME Node:
-- WHERE LogDate >= '[Scurrent_month_start]'
DECLARE @knime_flow_variable_date DATE = '2026-10-01';

SELECT *
FROM #ReportData
WHERE LogDate >= @knime_flow_variable_date;
