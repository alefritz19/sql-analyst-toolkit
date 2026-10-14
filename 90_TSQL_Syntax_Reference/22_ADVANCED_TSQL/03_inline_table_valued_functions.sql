-- Advanced T-SQL: Inline Table-Valued Functions (iTVF) vs. Skalare Funktionen
-- iTVF werden vom Query Optimizer wie normale Views behandelt (höchste Performance)

-- Definitionssyntax für Produktionscode:
/*
CREATE OR ALTER FUNCTION dbo.fn_GetCustomerOrdersByYear
(
    @CustomerID INT,
    @OrderYear INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT OrderID, CustomerID, OrderDate, Amount
    FROM dbo.Orders
    WHERE CustomerID = @CustomerID AND YEAR(OrderDate) = @OrderYear
);
*/

SELECT 'Inline TVFs sind skalaren Funktionen in T-SQL immer vorzuziehen' AS BestPracticeRule;
