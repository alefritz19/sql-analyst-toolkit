-- Microsoft Fabric: T-SQL SQL Analytics Endpoint für Lakehouses
-- Direkter Lesezugriff auf Delta-Tabellen in OneLake

-- Beispielabfrage gegen eine Fabric Lakehouse Delta Parquet Tabelle:
/*
SELECT 
    c.CustomerName,
    COUNT(s.SalesOrderNumber) AS TotalOrders,
    SUM(s.TotalAmount) AS TotalRevenue
FROM my_lakehouse.dbo.customers c
INNER JOIN my_lakehouse.dbo.fact_sales s ON c.CustomerKey = s.CustomerKey
WHERE s.OrderDate >= '2026-01-01'
GROUP BY c.CustomerName
ORDER BY TotalRevenue DESC;
*/

SELECT 'Fabric SQL Analytics Endpoint ermöglicht T-SQL Direct Lake Zugriffe auf OneLake' AS FabricArchitecture;
