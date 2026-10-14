/*
================================================================================
MASTER-GUIDE: DATUMSFUNKTIONEN & KALENDER-DIMENSION (DATE FUNCTIONS MASTERCLASS)
Vollständiger Werkzeugkasten für BI & Reporting in T-SQL.
================================================================================
*/

-- 1. DATUMSGENERATOR: Kalendertabelle erzeugen (Date Dimension Table)
DECLARE @StartYear DATE = '2026-01-01';
DECLARE @EndYear DATE   = '2026-12-31';

WITH DateGenerator AS (
    SELECT @StartYear AS CalendarDate
    UNION ALL
    SELECT DATEADD(day, 1, CalendarDate)
    FROM DateGenerator
    WHERE CalendarDate < @EndYear
)
SELECT 
    CalendarDate,
    YEAR(CalendarDate) AS CalendarYear,
    MONTH(CalendarDate) AS MonthNumber,
    DATENAME(month, CalendarDate) AS MonthNameDE,
    DAY(CalendarDate) AS DayOfMonth,
    DATEPART(quarter, CalendarDate) AS QuarterNumber,
    CONCAT('Q', DATEPART(quarter, CalendarDate), ' ', YEAR(CalendarDate)) AS QuarterYear,
    DATEPART(iso_week, CalendarDate) AS ISO_WeekNumber,
    DATEPART(weekday, CalendarDate) AS DayOfWeekNumber,
    DATENAME(weekday, CalendarDate) AS DayOfWeekName,
    CASE WHEN DATEPART(weekday, CalendarDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend,
    DATEFROMPARTS(YEAR(CalendarDate), MONTH(CalendarDate), 1) AS MonthStart,
    EOMONTH(CalendarDate) AS MonthEnd
FROM DateGenerator
OPTION (MAXRECURSION 366);
