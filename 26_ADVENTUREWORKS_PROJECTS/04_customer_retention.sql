-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 04_customer_retention.sql
-- Case Study 4: Kohortenanalyse & Kundenbindungsrate (Customer Retention Matrix)
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Kohortenbasierte Retention-Analyse:
-- 1. Zuordnung jedes Kunden zu seiner "Geburtskohorte" (Monat der Erstbestellung).
-- 2. Nachverfolgung der Aktivität in den Folgemonaten (Monat +1, +2, +3 ...).
-- 3. Berechnung der Retention Rate (%) zur Identifikation von Churn-Tendenzen.
-- 4. Ermittlung der Wiederkaufrate (Repeat Purchase Rate).
-- ================================================================================

USE AdventureWorks2022;
GO

-- --------------------------------------------------------------------------------
-- 1. Monatliche Kohorten-Retention-Matrix (Monat 0 bis Monat 6)
-- --------------------------------------------------------------------------------
WITH CustomerOrders AS (
    SELECT 
        CustomerID,
        SalesOrderID,
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS OrderMonth
    FROM Sales.SalesOrderHeader
),
CustomerFirstOrder AS (
    SELECT 
        CustomerID,
        MIN(OrderMonth) AS CohortMonth
    FROM CustomerOrders
    GROUP BY CustomerID
),
CohortActivity AS (
    SELECT 
        c.CohortMonth,
        DATEDIFF(month, c.CohortMonth, o.OrderMonth) AS MonthOffset,
        COUNT(DISTINCT o.CustomerID) AS ActiveCustomers
    FROM CustomerOrders o
    INNER JOIN CustomerFirstOrder c ON o.CustomerID = c.CustomerID
    GROUP BY c.CohortMonth, DATEDIFF(month, c.CohortMonth, o.OrderMonth)
),
CohortSizes AS (
    SELECT 
        CohortMonth, 
        ActiveCustomers AS InitialCohortSize
    FROM CohortActivity
    WHERE MonthOffset = 0
)
SELECT 
    CONVERT(VARCHAR(7), a.CohortMonth, 120) AS Cohort,
    s.InitialCohortSize,
    a.MonthOffset,
    a.ActiveCustomers,
    ROUND((CAST(a.ActiveCustomers AS DECIMAL(10,2)) / s.InitialCohortSize) * 100.0, 1) AS RetentionRatePct
FROM CohortActivity a
INNER JOIN CohortSizes s ON a.CohortMonth = s.CohortMonth
WHERE a.CohortMonth >= '2013-01-01' AND a.MonthOffset BETWEEN 0 AND 6
ORDER BY a.CohortMonth, a.MonthOffset;

-- --------------------------------------------------------------------------------
-- 2. Wiederholungskäufer-Quote (Repeat Purchase Rate) nach Kundentyp
-- --------------------------------------------------------------------------------
WITH OrderFrequencies AS (
    SELECT 
        c.CustomerID,
        CASE WHEN c.PersonID IS NOT NULL THEN 'B2C Individual' ELSE 'B2B Store' END AS Segment,
        COUNT(DISTINCT h.SalesOrderID) AS LifetimeOrders,
        SUM(h.TotalDue) AS LifetimeSpend
    FROM Sales.Customer c
    INNER JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
    GROUP BY c.CustomerID, c.PersonID
)
SELECT 
    Segment,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN LifetimeOrders = 1 THEN 1 ELSE 0 END) AS OneTimeBuyers,
    SUM(CASE WHEN LifetimeOrders > 1 THEN 1 ELSE 0 END) AS RepeatBuyers,
    ROUND((SUM(CASE WHEN LifetimeOrders > 1 THEN 1.0 ELSE 0.0 END) / COUNT(*)) * 100.0, 1) AS RepeatPurchaseRatePct,
    ROUND(AVG(LifetimeOrders * 1.0), 2) AS AvgOrdersPerCustomer,
    ROUND(AVG(LifetimeSpend), 2) AS AvgSpendPerCustomer
FROM OrderFrequencies
GROUP BY Segment;
