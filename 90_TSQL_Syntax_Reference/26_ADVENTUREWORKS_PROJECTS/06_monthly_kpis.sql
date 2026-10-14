-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 06_monthly_kpis.sql
-- Case Study 6: Monatliches KPI-Reporting & Wachstumstrends (Executive KPI Suite)
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Eine umfassende monatliche Management-Reporting-Abfrage:
-- 1. Monatlicher Umsatz, Bestellanzahl & Unique Customers.
-- 2. Durchschnittlicher Warenkorbwert (Average Order Value / AOV).
-- 3. Month-over-Month (MoM) Umsatzwachstum in Prozent via LAG(1).
-- 4. Year-over-Year (YoY) Umsatzwachstum im Vorjahresmonatsvergleich via LAG(12).
-- 5. Kumulierter Jahresumsatz (Year-to-Date / YTD) mit PARTITION BY Jahr.
-- 6. Gleitender 3-Monats-Durchschnitt (Rolling 3-Month Moving Average).
-- ================================================================================

USE AdventureWorks2022;
GO

WITH MonthlyAgg AS (
    SELECT 
        YEAR(OrderDate) AS OrderYear,
        MONTH(OrderDate) AS OrderMonthNum,
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS YearMonthDate,
        COUNT(DISTINCT SalesOrderID) AS TotalOrders,
        COUNT(DISTINCT CustomerID) AS UniqueCustomers,
        SUM(TotalDue) AS MonthlyRevenue,
        SUM(SubTotal) AS NetProductSales
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
),
KPI_TrendCalculation AS (
    SELECT 
        YearMonthDate,
        OrderYear,
        OrderMonthNum,
        TotalOrders,
        UniqueCustomers,
        MonthlyRevenue,
        NetProductSales,
        -- Average Order Value (AOV)
        ROUND(MonthlyRevenue / NULLIF(TotalOrders, 0), 2) AS AverageOrderValue,
        -- Vormonatswert (MoM Referenz)
        LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonthDate) AS PrevMonthRevenue,
        -- Vorjahresmonatswert (YoY Referenz)
        LAG(MonthlyRevenue, 12) OVER (ORDER BY YearMonthDate) AS PrevYearMonthRevenue,
        -- Kumulierter YTD-Umsatz innerhalb des Kalenderjahres
        SUM(MonthlyRevenue) OVER (
            PARTITION BY OrderYear 
            ORDER BY YearMonthDate 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS YTD_CumulativeRevenue,
        -- Gleitender 3-Monats-Umsatzdurchschnitt (Glättung saisonaler Schwankungen)
        AVG(MonthlyRevenue) OVER (
            ORDER BY YearMonthDate 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling3M_AvgRevenue
    FROM MonthlyAgg
)
SELECT 
    CONVERT(VARCHAR(7), YearMonthDate, 120) AS [YearMonth],
    TotalOrders,
    UniqueCustomers,
    ROUND(MonthlyRevenue, 2) AS MonthlyRevenue,
    AverageOrderValue,
    -- MoM Wachstumsrate (%)
    CASE 
        WHEN PrevMonthRevenue IS NULL THEN NULL
        ELSE ROUND(((MonthlyRevenue - PrevMonthRevenue) / PrevMonthRevenue) * 100.0, 2)
    END AS MoM_GrowthPct,
    -- YoY Wachstumsrate (%)
    CASE 
        WHEN PrevYearMonthRevenue IS NULL THEN NULL
        ELSE ROUND(((MonthlyRevenue - PrevYearMonthRevenue) / PrevYearMonthRevenue) * 100.0, 2)
    END AS YoY_GrowthPct,
    ROUND(YTD_CumulativeRevenue, 2) AS YTD_Revenue,
    ROUND(Rolling3M_AvgRevenue, 2) AS Rolling3M_Average
FROM KPI_TrendCalculation
ORDER BY YearMonthDate DESC;
