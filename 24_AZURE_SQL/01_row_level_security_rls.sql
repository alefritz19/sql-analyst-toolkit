-- Azure SQL & SQL Server: Zeilenebenen-Sicherheit (Row-Level Security - RLS)
-- Schränkt den Datenzugriff basierend auf dem angemeldeten Benutzer ein

/*
-- 1. Prädikatsfunktion erstellen
CREATE FUNCTION Security.fn_SecurityPredicate(@SalesRegion VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_SecurityPredicate_Result
WHERE @SalesRegion = USER_NAME() OR USER_NAME() = 'AdminUser';

-- 2. Sicherheitsrichtlinie anwenden
CREATE SECURITY POLICY Security.SalesFilterPolicy
ADD FILTER PREDICATE Security.fn_SecurityPredicate(Region)
ON dbo.FactSales
WITH (STATE = ON);
*/

SELECT 'Row-Level Security verhindert unberechtigten Zugriff auf Datensatzebene transparent' AS RlsSecurity;
