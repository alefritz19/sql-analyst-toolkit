-- Power BI Datensatz: Kalenderdimension (Date Table)
-- Zwingend erforderlich für Time Intelligence (SAMEPERIODLASTYEAR, TOTALYTD)

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE   = '2027-12-31';

WITH DateSequence AS (
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(day, 1, FullDate)
    FROM DateSequence
    WHERE FullDate < @EndDate
)
SELECT 
    FullDate AS DateKey,
    YEAR(FullDate) AS [Year],
    MONTH(FullDate) AS MonthNumber,
    DATENAME(month, FullDate) AS MonthNameDE,
    CONCAT('Q', DATEPART(quarter, FullDate)) AS [Quarter],
    CONCAT('Q', DATEPART(quarter, FullDate), ' ', YEAR(FullDate)) AS QuarterYear,
    DATEPART(iso_week, FullDate) AS ISO_Week,
    DATENAME(weekday, FullDate) AS WeekdayNameDE,
    CASE WHEN DATEPART(weekday, FullDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekendFlag
FROM DateSequence
OPTION (MAXRECURSION 1100);
