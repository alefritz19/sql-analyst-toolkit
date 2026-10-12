-- 09_DATES / 01_current_date.sql - Aktuelle Systemzeit

SELECT 
    GETDATE() AS SystemDateTime_datetime,
    SYSDATETIME() AS SystemDateTime_datetime2,
    CURRENT_TIMESTAMP AS AnsiCurrentTimestamp,
    CAST(GETDATE() AS DATE) AS TodayDateOnly,
    CAST(GETDATE() AS TIME) AS CurrentTimeOnly;
