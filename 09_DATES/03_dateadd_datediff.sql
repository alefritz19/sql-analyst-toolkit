-- Datumsarithmetik: DATEADD und DATEDIFF

DECLARE @StartDate DATE = '2026-01-15';
DECLARE @EndDate DATE = '2026-08-20';

SELECT 
    @StartDate AS StartDate,
    @EndDate AS EndDate,
    DATEDIFF(day, @StartDate, @EndDate) AS DiffDays,
    DATEDIFF(month, @StartDate, @EndDate) AS DiffMonths,
    DATEDIFF(year, @StartDate, @EndDate) AS DiffYears,
    DATEADD(day, 30, @StartDate) AS Plus30Days,
    DATEADD(month, -3, @StartDate) AS Minus3Months;
