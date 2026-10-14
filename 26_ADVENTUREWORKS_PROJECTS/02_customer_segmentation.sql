-- ================================================================================
-- 26_ADVENTUREWORKS_PROJECTS / 02_customer_segmentation.sql
-- Case Study 2: Kundensegmentierung & RFM-Analyse (Recency, Frequency, Monetary)
-- Ziel-Datenbank: AdventureWorks2022
-- ================================================================================
-- BESCHREIBUNG:
-- Strategische Segmentierung des gesamten Kundenstamms anhand dreier Dimensionen:
-- - Recency (R): Tage seit der letzten Bestellung (Aktualität)
-- - Frequency (F): Gesamtzahl der getätigten Bestellungen (Kaufhäufigkeit)
-- - Monetary (M): Gesamtumsatz des Kunden (Umsatzvolumen)
--
-- BUSINESS VALUE:
-- Ermöglicht dem Marketing und Vertrieb die gezielte Kampagnensteuerung
-- (z. B. VIP-Betreuung, Reaktivierung abwanderungsgefährdeter Kunden).
-- ================================================================================

USE AdventureWorks2022;
GO

-- Stichtag dynamisch ermitteln (hier bezogen auf das jüngste Bestelldatum)
DECLARE @SnapshotDate DATE;
SELECT @SnapshotDate = DATEADD(day, 1, MAX(OrderDate)) FROM Sales.SalesOrderHeader;

DROP TABLE IF EXISTS #CustomerSegments;

WITH CustomerRFM_Raw AS (
    SELECT 
        c.CustomerID,
        ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
        CASE WHEN c.PersonID IS NOT NULL THEN 'B2C Individual' ELSE 'B2B Store' END AS CustomerType,
        t.Name AS TerritoryName,
        MAX(h.OrderDate) AS LastOrderDate,
        DATEDIFF(day, MAX(h.OrderDate), @SnapshotDate) AS RecencyDays,
        COUNT(DISTINCT h.SalesOrderID) AS FrequencyCount,
        SUM(h.TotalDue) AS MonetaryValue
    FROM Sales.Customer c
    INNER JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
    LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
    GROUP BY c.CustomerID, p.FirstName, p.LastName, s.Name, c.PersonID, t.Name
),
RFM_Scores AS (
    SELECT 
        CustomerID,
        CustomerName,
        CustomerType,
        TerritoryName,
        RecencyDays,
        FrequencyCount,
        MonetaryValue,
        -- Score 4 = Am besten, Score 1 = Am schwächsten
        NTILE(4) OVER (ORDER BY RecencyDays DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY FrequencyCount ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY MonetaryValue ASC) AS M_Score
    FROM CustomerRFM_Raw
)
SELECT 
    CustomerID,
    CustomerName,
    CustomerType,
    TerritoryName,
    RecencyDays,
    FrequencyCount,
    ROUND(MonetaryValue, 2) AS MonetaryValue,
    R_Score,
    F_Score,
    M_Score,
    -- CRM Persona Mapping
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN '1. Champions / VIP'
        WHEN R_Score >= 3 AND F_Score >= 3 THEN '2. Loyal Customers'
        WHEN R_Score >= 4 AND F_Score BETWEEN 1 AND 2 THEN '3. New / Recent Shoppers'
        WHEN R_Score BETWEEN 2 AND 3 AND F_Score >= 3 THEN '4. Needs Attention'
        WHEN R_Score = 1 AND F_Score >= 3 THEN '5. At Risk / Churn Warning'
        WHEN R_Score = 1 AND F_Score = 1 THEN '6. Lost / Hibernating'
        ELSE '7. Standard / Occasional'
    END AS CustomerSegment
INTO #CustomerSegments
FROM RFM_Scores;

-- --------------------------------------------------------------------------------
-- 1. Detaillierte Kundenliste mit Segmentzuordnung (Top 25 nach Umsatz)
-- --------------------------------------------------------------------------------
SELECT TOP 25
    CustomerID,
    CustomerName,
    CustomerType,
    TerritoryName,
    RecencyDays,
    FrequencyCount,
    MonetaryValue,
    CustomerSegment
FROM #CustomerSegments
ORDER BY MonetaryValue DESC;

-- --------------------------------------------------------------------------------
-- 2. Aggregierte Segment-Übersicht für das Management
-- --------------------------------------------------------------------------------
SELECT 
    CustomerSegment,
    COUNT(*) AS CustomerCount,
    ROUND(SUM(MonetaryValue), 2) AS TotalSegmentRevenue,
    ROUND(AVG(MonetaryValue), 2) AS AvgRevenuePerCustomer,
    ROUND(AVG(RecencyDays * 1.0), 0) AS AvgRecencyDays,
    ROUND((SUM(MonetaryValue) / SUM(SUM(MonetaryValue)) OVER()) * 100.0, 1) AS RevenueSharePct
FROM #CustomerSegments
GROUP BY CustomerSegment
ORDER BY TotalSegmentRevenue DESC;

-- Bereinigung
DROP TABLE IF EXISTS #CustomerSegments;
