-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 03_product_analysis.sql
-- Case Study 3: Sortimentsanalyse & ABC-Klassifizierung nach Pareto
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Strategische Produktportfolio-Analyse zur Identifikation von:
-- 1. A-Artikeln (die 80% des Gesamtumsatzes ausmachen)
-- 2. B-Artikeln (die nächsten 15% des Umsatzes)
-- 3. C-Artikeln (die verbleibenden 5% mit potenziellen Sortimentsbereinigungen)
-- 4. Verknüpfung mit Lagerbestand (Production.ProductInventory) zur Erkennung
--    von Überbeständen oder Lieferengpässen bei A-Artikeln.
-- ================================================================================

USE AdventureWorks2022;
GO

DROP TABLE IF EXISTS #ClassifiedProducts;

WITH ProductSalesAgg AS (
    SELECT 
        p.ProductID,
        p.ProductNumber,
        p.Name AS ProductName,
        cat.Name AS CategoryName,
        sub.Name AS SubcategoryName,
        p.StandardCost,
        p.ListPrice,
        SUM(d.OrderQty) AS TotalQuantitySold,
        COUNT(DISTINCT d.SalesOrderID) AS OrderPresenceCount,
        SUM(d.LineTotal) AS TotalRevenue,
        SUM(d.LineTotal - (d.OrderQty * p.StandardCost)) AS TotalGrossMargin
    FROM Sales.SalesOrderDetail d
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory sub ON p.ProductSubcategoryID = sub.ProductSubcategoryID
    INNER JOIN Production.ProductCategory cat ON sub.ProductCategoryID = cat.ProductCategoryID
    GROUP BY p.ProductID, p.ProductNumber, p.Name, cat.Name, sub.Name, p.StandardCost, p.ListPrice
),
ProductInventoryAgg AS (
    SELECT 
        ProductID,
        SUM(Quantity) AS TotalStockInWarehouses
    FROM Production.ProductInventory
    GROUP BY ProductID
),
ParetoWindow AS (
    SELECT 
        s.ProductID,
        s.ProductNumber,
        s.ProductName,
        s.CategoryName,
        s.SubcategoryName,
        s.TotalQuantitySold,
        s.OrderPresenceCount,
        ROUND(s.TotalRevenue, 2) AS TotalRevenue,
        ROUND(s.TotalGrossMargin, 2) AS TotalGrossMargin,
        ISNULL(i.TotalStockInWarehouses, 0) AS CurrentStock,
        -- Gesamter Umsatz über alle verkauften Artikel
        SUM(s.TotalRevenue) OVER () AS TotalPortfolioRevenue,
        -- Kumulierter Umsatz geordnet nach Umsatzstärke
        SUM(s.TotalRevenue) OVER (
            ORDER BY s.TotalRevenue DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeRevenue
    FROM ProductSalesAgg s
    LEFT JOIN ProductInventoryAgg i ON s.ProductID = i.ProductID
)
SELECT 
    ProductID,
    ProductNumber,
    ProductName,
    CategoryName,
    SubcategoryName,
    TotalQuantitySold,
    OrderPresenceCount,
    TotalRevenue,
    TotalGrossMargin,
    CurrentStock,
    ROUND((CumulativeRevenue / TotalPortfolioRevenue) * 100.0, 2) AS CumulativeSharePct,
    CASE 
        WHEN (CumulativeRevenue / TotalPortfolioRevenue) <= 0.80 THEN 'A-Produkt (Top 80%)'
        WHEN (CumulativeRevenue / TotalPortfolioRevenue) <= 0.95 THEN 'B-Produkt (Nächste 15%)'
        ELSE 'C-Produkt (Basis 5%)'
    END AS ABC_Class
INTO #ClassifiedProducts
FROM ParetoWindow;

-- --------------------------------------------------------------------------------
-- 1. Produktliste mit ABC-Status & Lagerwarnung bei A-Produkten
-- --------------------------------------------------------------------------------
SELECT TOP 30
    ProductID,
    ProductName,
    CategoryName,
    SubcategoryName,
    TotalQuantitySold,
    TotalRevenue,
    TotalGrossMargin,
    CurrentStock,
    CumulativeSharePct,
    ABC_Class,
    CASE 
        WHEN ABC_Class LIKE 'A-%' AND CurrentStock < 50 THEN 'CRITICAL: Niedriger Bestand bei A-Produkt'
        WHEN ABC_Class LIKE 'C-%' AND CurrentStock > 500 THEN 'WARNUNG: Möglicher Überbestand / Ladenhüter'
        ELSE 'OK'
    END AS InventoryActionFlag
FROM #ClassifiedProducts
ORDER BY TotalRevenue DESC;

-- --------------------------------------------------------------------------------
-- 2. Aggregierte Zusammenfassung: Wie viele Produkte machen wie viel Umsatz?
-- --------------------------------------------------------------------------------
SELECT 
    ABC_Class,
    COUNT(*) AS NumberOfProducts,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 1) AS ProductCountPct,
    ROUND(SUM(TotalRevenue), 2) AS RevenueGenerated,
    ROUND((SUM(TotalRevenue) * 100.0 / SUM(SUM(TotalRevenue)) OVER()), 1) AS RevenueSharePct,
    ROUND(AVG(TotalGrossMargin), 2) AS AvgMarginPerProduct
FROM #ClassifiedProducts
GROUP BY ABC_Class
ORDER BY RevenueGenerated DESC;

-- Bereinigung
DROP TABLE IF EXISTS #ClassifiedProducts;
