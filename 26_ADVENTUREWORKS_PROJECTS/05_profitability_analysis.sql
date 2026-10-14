-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 05_profitability_analysis.sql
-- Case Study 5: Rentabilitäts- & Deckungsbeitragsanalyse (Gross Margin & Channel ROI)
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Tiefgehende betriebswirtschaftliche Analyse:
-- 1. Bruttoertrag & Rohertragsmarge (Gross Profit = Umsatz - Standardherstellkosten).
-- 2. Rabatteffekt: Wie stark reduzieren Sonderangebote / Rabatte (SpecialOffer) die Marge?
-- 3. Rentabilität nach Produktkategorie und Subkategorie.
-- 4. Deckungsbeitrag nach Vertriebskanal (Online Shop vs. Fachhandels-Reseller).
-- ================================================================================

USE AdventureWorks2022;
GO

-- --------------------------------------------------------------------------------
-- 1. Margenanalyse nach Produktkategorie & Subkategorie
-- --------------------------------------------------------------------------------
WITH ProductProfitability AS (
    SELECT 
        cat.Name AS CategoryName,
        sub.Name AS SubcategoryName,
        COUNT(DISTINCT h.SalesOrderID) AS OrderCount,
        SUM(d.OrderQty) AS TotalUnitsSold,
        SUM(d.OrderQty * d.UnitPrice) AS GrossUndiscountedRevenue,
        SUM(d.OrderQty * d.UnitPrice * d.UnitPriceDiscount) AS TotalDiscountsGiven,
        SUM(d.LineTotal) AS NetRevenue,
        SUM(d.OrderQty * p.StandardCost) AS CostOfGoodsSold,
        SUM(d.LineTotal - (d.OrderQty * p.StandardCost)) AS GrossProfit
    FROM Sales.SalesOrderDetail d
    INNER JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory sub ON p.ProductSubcategoryID = sub.ProductSubcategoryID
    INNER JOIN Production.ProductCategory cat ON sub.ProductCategoryID = cat.ProductCategoryID
    GROUP BY cat.Name, sub.Name
)
SELECT 
    CategoryName,
    SubcategoryName,
    OrderCount,
    TotalUnitsSold,
    ROUND(NetRevenue, 2) AS NetRevenue,
    ROUND(CostOfGoodsSold, 2) AS COGS,
    ROUND(TotalDiscountsGiven, 2) AS DiscountsGiven,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ROUND((GrossProfit / NULLIF(NetRevenue, 0)) * 100.0, 2) AS GrossMarginPct,
    ROUND((TotalDiscountsGiven / NULLIF(GrossUndiscountedRevenue, 0)) * 100.0, 2) AS EffectiveDiscountRatePct
FROM ProductProfitability
ORDER BY GrossProfit DESC;

-- --------------------------------------------------------------------------------
-- 2. Margenvergleich: Online B2C vs. Reseller B2B
-- --------------------------------------------------------------------------------
SELECT 
    CASE WHEN h.OnlineOrderFlag = 1 THEN 'Online Webshop (B2C)' ELSE 'Reseller / Store (B2B)' END AS Channel,
    COUNT(DISTINCT h.SalesOrderID) AS TotalOrders,
    ROUND(SUM(h.SubTotal), 2) AS NetProductSales,
    ROUND(SUM(d.OrderQty * p.StandardCost), 2) AS CostOfGoodsSold,
    ROUND(SUM(h.SubTotal - (d.OrderQty * p.StandardCost)), 2) AS GrossMarginAmount,
    ROUND((SUM(h.SubTotal - (d.OrderQty * p.StandardCost)) / NULLIF(SUM(h.SubTotal), 0)) * 100.0, 2) AS GrossMarginPct,
    ROUND(SUM(h.Freight), 2) AS TotalFreight,
    ROUND(SUM(h.TaxAmt), 2) AS TotalTax,
    ROUND(SUM(h.TotalDue), 2) AS TotalBilled
FROM Sales.SalesOrderHeader h
INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID = p.ProductID
GROUP BY h.OnlineOrderFlag;
