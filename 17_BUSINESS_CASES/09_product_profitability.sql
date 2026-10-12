-- Business Case: Produktrentabilität & Deckungsbeitrag (Margin Contribution)

DROP TABLE IF EXISTS #ProductsMargin;
CREATE TABLE #ProductsMargin (
    ProdID INT, 
    ProdName VARCHAR(50), 
    SalesQty INT, 
    SellingPrice DECIMAL(10,2), 
    CostPrice DECIMAL(10,2)
);

INSERT INTO #ProductsMargin VALUES
(1, 'Business Laptop', 40, 1200.00, 750.00),
(2, 'Dockingstation', 85,  180.00,  95.00),
(3, 'Ergo Tastatur', 150,  65.00,  40.00),
(4, 'Monitor 27"',    60,  320.00, 240.00);

SELECT 
    ProdName,
    SalesQty,
    SalesQty * SellingPrice AS TotalRevenue,
    SalesQty * CostPrice AS TotalCost,
    (SalesQty * SellingPrice) - (SalesQty * CostPrice) AS TotalGrossProfit,
    ROUND(((SellingPrice - CostPrice) * 100.0) / SellingPrice, 2) AS MarginPct
FROM #ProductsMargin
ORDER BY TotalGrossProfit DESC;
