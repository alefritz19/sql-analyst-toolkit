# 🗄️ SQL Analyst Toolkit & Production Business Intelligence Hub
### Praxisorientierte T-SQL Referenzarchitektur & Enterprise Analytics auf Microsoft SQL Server 2022
### Datengrundlage: FrischMarkt GmbH (`SupermarktDWH`) · 5 Filialen · 120 Artikel · ~755.000 Positionen

[![SQL Server](https://img.shields.io/badge/SQL_Server-2022_Enterprise_Ready-CC292B?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/Language-T--SQL-0078D4)](https://learn.microsoft.com/sql/t-sql/)
[![DWH Star Schema](https://img.shields.io/badge/Schema-Kimball_Star_Schema-success)](#)
[![Business Analytics](https://img.shields.io/badge/Focus-Retail_KPIs_%26_Retention-orange)](#)

---

## 📌 Übersicht: Wofür dieses Repository steht

Dieses Repository ist **keine lose Ansammlung theoretischer Syntax-Snippets**, sondern ein **zusammenhängendes technisches Werkzeug für Business Intelligence & Data Analytics**. 

Alle Kernmodule basieren auf einer gemeinsamen, realistischen Unternehmensdatenbank: der **FrischMarkt GmbH (`SupermarktDWH`)**. Vom deterministischen Setup über Datenbereinigung bis hin zu komplexen Fensterfunktionen und Kundenwert-Modellen (RFM & Kohorten) wird eine konsistente geschäftliche Geschichte erzählt.

---

## 🎯 Struktur der Kernmodule

```text
sql-analyst-toolkit/
├── 00_SETUP/                                          # Deterministischer DWH-Datengenerator
├── 01_DATA_CLEANING/                                  # Datenbereinigung, Auditierung & Deduplizierung
├── 02_WINDOW_FUNCTIONS/                               # Fensterfunktionen: DENSE_RANK, LAG, Moving Averages
├── 03_BUSINESS_ANALYTICS_RFM/                         # RFM-Segmentierung & Monatliche Kohorten-Retention
└── 90_TSQL_Syntax_Reference/                          # Umfassende Syntax-Bibliothek (CTEs, PIVOT, JSON etc.)
```

---

### 1. Datenbereinigung & Qualitätssicherung (`01_DATA_CLEANING`)
* **[`DATA_CLEANING_MASTER.sql`](01_DATA_CLEANING/DATA_CLEANING_MASTER.sql):**
  * Whitespace-Bereinigung (`TRIM`, verschachtelte `REPLACE`).
  * Sichere Datumskonvertierung via `TRY_CONVERT` (Harmonisierung von ISO-, DE- und US-Formaten).
  * Syntaktische Prüfung und Korrektur von E-Mail-Adressen.
  * In-Flight-Deduplizierung über `ROW_NUMBER() PARTITION BY SaubererKundenCode ORDER BY RohID DESC`.

---

### 2. Fortgeschrittene Fensterfunktionen (`02_WINDOW_FUNCTIONS`)
* **[`WINDOW_FUNCTIONS_MASTER.sql`](02_WINDOW_FUNCTIONS/WINDOW_FUNCTIONS_MASTER.sql):**
  * `DENSE_RANK() OVER (PARTITION BY KategorieID ORDER BY Umsatz DESC)` für Top-Seller je Sortiment.
  * `LAG(UmsatzAktuell, 1) OVER (ORDER BY JahrMonat)` zur Berechnung des Month-over-Month (MoM) Wachstums in Euro und Prozent.
  * Gleitender 7-Tage-Durchschnitt (`AVG() OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)`) zur Glättung starker Wochentagsschwankungen (Samstagsspitzen).
  * Monats-Running-Total (`SUM() OVER (PARTITION BY Monat ORDER BY Datum)`).

---

### 3. Business Analytics, Retention & RFM (`03_BUSINESS_ANALYTICS_RFM`)
* **[`ADVANCED_ANALYTICS_MASTER.sql`](03_BUSINESS_ANALYTICS_RFM/ADVANCED_ANALYTICS_MASTER.sql):**
  * **RFM-Kundensegmentierung:** Quantil-Einteilung über `NTILE(5)` für Recency (Tage seit Kauf), Frequency (Einkaufszahl) und Monetary (Gesamtumsatz) in *Champions*, *Loyale Kunden*, *Gefährdete Kunden* und *Inaktive*.
  * **Monatliche Kohortenanalyse (Retention Matrix):** Dynamische Ermittlung des Ersteinkaufs-Monats und Berechnung der Wiederkehrrate für Folgemonate M+1, M+2, M+3, M+6.

#### 📊 Beispiel-Output: RFM-Kundensegmentierung (`SupermarktDWH`)

Die folgende Auswertung zeigt das tatsächliche Ergebnis der RFM-Segmentierung über den 3-Jahres-Bestand:

| RFM-Segment (Ausgabe des Skripts) | Kunden | Anteil Kunden | Gesamtumsatz | Ø Bonwert | Ø Bons je Kunde |
| :--- | :---: | :---: | ---: | ---: | :---: |
| **Champions (Top-Stammkunden)** | 760 | 26,5 % | 630.241,88 € | 13,89 € | 59,7 |
| **Loyale Kunden (Regelmäßig)** | 560 | 19,6 % | 187.397,18 € | 13,71 € | 24,4 |
| **Gefährdete Stammkunden** | 137 | 4,8 % | 58.907,05 € | 13,43 € | 32,0 |
| **Durchschnittskunden** | 452 | 15,8 % | 46.228,51 € | 13,51 € | 7,6 |
| **Inaktive / Verlorene Kunden** | 749 | 26,2 % | 37.333,60 € | 13,70 € | 3,6 |
| **Neukunden / Potenzial** | 205 | 7,2 % | 12.468,29 € | 14,57 € | 4,2 |

*Grundgesamtheit: 2.863 Kundenkarten mit mindestens einem Einkauf (von 3.000 ausgegebenen Karten). Ø Bonwert = Gesamtumsatz / Anzahl Bons des Segments.*

> **Analytische Erkenntnis:**  
> Die Segmente *Champions* und *Loyale Kunden* stellen zusammen **46,1 % der aktiven Kundenkartenbesitzer**, erwirtschaften jedoch **84,1 % des gesamten kartenbasierten Umsatzes** (817.639 € von 972.577 €). Umgekehrt binden die 749 abgewanderten Kunden (*Inaktive / Verlorene Kunden*) Potenzial, das durch zielgerichtete Reaktivierungs-Kampagnen (Gutscheine auf Lieblingskategorien) adressiert werden kann.

---

## 🚀 Setup: Eigene Datenbank in 2 Minuten aufsetzen

Im Verzeichnis `00_SETUP` liegt der vollständige, deterministische Datengenerator:

```powershell
sqlcmd -S .\SQLEXPRESS -E -f 65001 -i 00_SETUP\01_SupermarktDWH_erstellen.sql
```

Nach rund 2 Minuten steht die Datenbank `SupermarktDWH` bereit mit:
* 5 Filialen (Hannover-Mitte, Hannover-List, Braunschweig, Hildesheim, Bielefeld)
* 120 Artikeln in 8 Warengruppen
* 3.000 Kundenkarten
* 185.418 Kassenbons und 754.690 Positionen
* Staging-Tabelle `stg.Kunden_Rohimport` (9.000 Zeilen mit Dubletten und Formatfehlern) für Data-Cleaning-Übungen
