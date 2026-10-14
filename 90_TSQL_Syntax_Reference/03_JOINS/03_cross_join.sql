-- CROSS JOIN - Kartesisches Produkt (Alle möglichen Kombinationen)

DROP TABLE IF EXISTS #Sizes;
DROP TABLE IF EXISTS #Colors;
CREATE TABLE #Sizes (Size VARCHAR(10));
CREATE TABLE #Colors (Color VARCHAR(20));

INSERT INTO #Sizes VALUES ('S'), ('M'), ('L');
INSERT INTO #Colors VALUES ('Schwarz'), ('Weiss'), ('Blau');

SELECT 
    s.Size,
    c.Color,
    CONCAT('T-Shirt ', s.Size, ' - ', c.Color) AS SKU_Name
FROM #Sizes s
CROSS JOIN #Colors c;
