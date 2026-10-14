-- Interview Cheatsheet: Top 10 SQL Interviewfragen

-- 1. Zweithöchstes Gehalt
-- 2. Duplikate finden und löschen
-- 3. Kunden ohne Bestellungen (NOT EXISTS vs. LEFT JOIN)
-- 4. Abteilung mit höchstem Durchschnittsgehalt
-- 5. Kumulierte Monatssummen (Running Total)
-- 6. Gleitender 7-Tage-Durchschnitt
-- 7. N aufeinanderfolgende Tage aktiv (Gaps and Islands)
-- 8. Top 3 Produkte je Kategorie
-- 9. Kundenbindung (Retention) berechnen
-- 10. Pivotierung von Verkaufsdaten

WITH Demo AS (SELECT 1 AS QuestionNumber, 'Top 10 Cheatsheet' AS Title)
SELECT * FROM Demo;
