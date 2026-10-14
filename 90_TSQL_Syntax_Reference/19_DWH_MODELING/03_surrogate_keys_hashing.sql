-- DWH Modeling: Surrogatschlüssel & Hashing (HASHBYTES SHA2_256)
-- Generierung von konsistenten Schlüsseln ohne IDENTITY

DROP TABLE IF EXISTS #BusinessKeys;
CREATE TABLE #BusinessKeys (SourceSystem VARCHAR(10), NaturalID VARCHAR(50), FullName VARCHAR(100));

INSERT INTO #BusinessKeys VALUES 
('SAP', 'K-10045', 'Siemens AG'),
('CRM', 'ACC-982', 'Bosch GmbH');

SELECT 
    SourceSystem,
    NaturalID,
    FullName,
    -- Eindeutiger Hash-Schlüssel (32 Byte / 64 Zeichen)
    HASHBYTES('SHA2_256', CONCAT(SourceSystem, '|', NaturalID)) AS SurrogateHashBinary,
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(SourceSystem, '|', NaturalID)), 2) AS SurrogateHashHex
FROM #BusinessKeys;
