-- Index-Grundlagen: Clustered vs. Non-Clustered Index

-- Ein Clustered Index sortiert die physische Tabelle (nur 1 pro Tabelle möglich)
-- Ein Non-Clustered Index ist ein separates Inhaltsverzeichnis

-- Syntax-Beispiel:
-- CREATE CLUSTERED INDEX CIX_Orders_OrderID ON dbo.Orders(OrderID);
-- CREATE NONCLUSTERED INDEX NIX_Orders_Cust_Date ON dbo.Orders(CustomerID, OrderDate) INCLUDE (Amount);

SELECT 
    'Indexes accelerate WHERE, JOIN and ORDER BY operations' AS IndexRule,
    'Always avoid SELECT * to allow Index Covering (INCLUDE columns)' AS BestPractice;
