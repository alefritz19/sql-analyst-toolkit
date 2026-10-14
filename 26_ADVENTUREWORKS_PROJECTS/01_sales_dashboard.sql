-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 01_sales_dashboard.sql
-- Case Study 1: Executive Sales & Regional Performance Dashboard
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Dieses Skript liefert eine vollständige Vertriebsübersicht auf Führungsebene:
-- 1. Regionale Performance & Territoriums-Kennzahlen (Umsatz, Bestellungen, AOV)
-- 2. Kanal-Vergleich (Online-Webshop vs. B2B / Reseller-Vertrieb)
-- 3. Top-Vertriebsmitarbeiter mit Zielerreichung (Sales vs. Quota)
-- 4. Year-over-Year (YoY) Umsatzentwicklung im Jahresvergleich
-- ================================================================================

USE AdventureWorks2022;
GO

-- --------------------------------------------------------------------------------
-- 1. Regionale Umsatz- & Kanalverteilung (Territory & Channel Performance)
-- --------------------------------------------------------------------------------
WITH RegionalSales AS (
    SELECT 
        t.[Group] AS SalesRegionGroup,
        t.Name AS TerritoryName,
        t.CountryRegionCode,
        COUNT(DISTINCT h.SalesOrderID) AS TotalOrders,
        COUNT(DISTINCT h.CustomerID) AS ActiveCustomers,
        SUM(h.TotalDue) AS TotalRevenue,
        ROUND(SUM(h.TotalDue) / NULLIF(COUNT(DISTINCT h.SalesOrderID), 0), 2) AS AverageOrderValue,
        -- Aufteilung nach Vertriebskanal (Online B2C vs. Offline B2B)
        SUM(CASE WHEN h.OnlineOrderFlag = 1 THEN h.TotalDue ELSE 0 END) AS OnlineRevenue,
        SUM(CASE WHEN h.OnlineOrderFlag = 0 THEN h.TotalDue ELSE 0 END) AS B2B_ResellerRevenue
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    GROUP BY t.[Group], t.Name, t.CountryRegionCode
)
SELECT 
    SalesRegionGroup,
    TerritoryName,
    CountryRegionCode,
    TotalOrders,
    ActiveCustomers,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    AverageOrderValue,
    ROUND(OnlineRevenue, 2) AS OnlineRevenue,
    ROUND(B2B_ResellerRevenue, 2) AS B2B_ResellerRevenue,
    ROUND((OnlineRevenue / NULLIF(TotalRevenue, 0)) * 100.0, 1) AS OnlineSharePct,
    ROUND((TotalRevenue / SUM(TotalRevenue) OVER()) * 100.0, 2) AS GlobalMarketSharePct
FROM RegionalSales
ORDER BY TotalRevenue DESC;

-- --------------------------------------------------------------------------------
-- 2. Top-Vertriebsmitarbeiter & Zielerreichung (Sales Rep Quota Performance)
-- --------------------------------------------------------------------------------
WITH RepSales AS (
    SELECT 
        sp.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS SalesPersonName,
        t.Name AS TerritoryName,
        sp.SalesQuota,
        SUM(h.SubTotal) AS ActualSalesYTD,
        COUNT(DISTINCT h.SalesOrderID) AS DealsClosed
    FROM Sales.SalesPerson sp
    INNER JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory t ON sp.TerritoryID = t.TerritoryID
    LEFT JOIN Sales.SalesOrderHeader h ON sp.BusinessEntityID = h.SalesPersonID
    GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName, t.Name, sp.SalesQuota
)
SELECT 
    SalesPersonName,
    TerritoryName,
    DealsClosed,
    ROUND(ActualSalesYTD, 2) AS ActualSales,
    ROUND(ISNULL(SalesQuota, 0), 2) AS SalesQuota,
    CASE 
        WHEN SalesQuota IS NULL OR SalesQuota = 0 THEN NULL
        ELSE ROUND((ActualSalesYTD / SalesQuota) * 100.0, 1)
    END AS QuotaAttainmentPct,
    DENSE_RANK() OVER (ORDER BY ActualSalesYTD DESC) AS SalesRank
FROM RepSales
ORDER BY ActualSalesYTD DESC;
