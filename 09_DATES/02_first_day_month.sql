-- Ersten und letzten Tag des Monats ermitteln

DECLARE @RefDate DATE = '2026-10-15';

SELECT
    @RefDate AS InputDate,
    -- Erster Tag des Monats
    DATEFROMPARTS(YEAR(@RefDate), MONTH(@RefDate), 1) AS FirstDayOfMonth_Method1,
    DATEADD(month, DATEDIFF(month, 0, @RefDate), 0) AS FirstDayOfMonth_Method2,
    -- Letzter Tag des Monats
    EOMONTH(@RefDate) AS LastDayOfMonth,
    -- Letzter Tag des Vormonats
    EOMONTH(@RefDate, -1) AS LastDayOfPreviousMonth;
