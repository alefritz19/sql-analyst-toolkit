-- String-Funktionen (LEN, SUBSTRING, CHARINDEX, UPPER, LOWER, REPLACE)

DECLARE @SampleText VARCHAR(100) = '   Max.Mustermann@company.de   ';

SELECT 
    @SampleText AS OriginalText,
    LEN(@SampleText) AS LengthWithTrailing,
    DATALENGTH(@SampleText) AS ExactBytes,
    TRIM(@SampleText) AS CleanTrimmed,
    UPPER(TRIM(@SampleText)) AS UppercaseText,
    LOWER(TRIM(@SampleText)) AS LowercaseText,
    -- Domain extrahieren (alles nach dem @-Zeichen):
    SUBSTRING(TRIM(@SampleText), CHARINDEX('@', TRIM(@SampleText)) + 1, LEN(@SampleText)) AS ExtractedDomain,
    -- Benutzername extrahieren:
    LEFT(TRIM(@SampleText), CHARINDEX('@', TRIM(@SampleText)) - 1) AS ExtractedUsername;
