-- Microsoft Fabric: Datenbankübergreifende Abfragen (Cross-Database Queries)
-- Abfragen über mehrere Warehouses und Lakehouses hinweg ohne Data Movement

/*
SELECT 
    w.SalesOrderKey,
    l.CustomerDemographics
FROM SalesWarehouse.dbo.FactSales w
JOIN MarketingLakehouse.dbo.CustomerProfiles l ON w.CustomerKey = l.CustomerKey;
*/

SELECT 'In Fabric OneLake können Tabellen verschiedener Workspaces nativ gejoint werden' AS CrossQueryRule;
