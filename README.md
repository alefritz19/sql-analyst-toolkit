# 🗄️ SQL Analyst Toolkit & Production Business Intelligence Hub
### Praxisorientierte T-SQL Referenzarchitektur & Enterprise Analytics auf Microsoft SQL Server 2022
### Datengrundlage: FrischMarkt GmbH (`SupermarktDWH`) · 5 Filialen · 120 Artikel · ~755.000 Positionen

[![SQL Server](https://img.shields.io/badge/SQL_Server-2022_Enterprise_Ready-CC292B?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/Language-T--SQL-0078D4)](https://learn.microsoft.com/sql/t-sql/)
[![DWH Star Schema](https://img.shields.io/badge/Schema-Kimball_Star_Schema-success)](#)
[![Business Analytics](https://img.shields.io/badge/Focus-Retail_KPIs_%26_Retention-orange)](#)

---

## 📌 Übersicht: Wofür dieses Repository steht

Dieses Repository ist **keine lose Ansammlung theoretischer Syntax-Snippets**, sondern ein **zusammenhängendes technisches Werkzeug für angehende und gestandene Data Analysts & BI Developers**. 

Alle Abfragen und Module basieren auf einer gemeinsamen, realistischen Datenbank: der **FrischMarkt GmbH (`SupermarktDWH`)**. Vom ersten `SELECT` über komplexe Fensterfunktionen bis hin zur monatlichen Kohortenanalyse und Datenbereinigung wird eine konsistente geschäftliche Geschichte erzählt.

---

## 🎯 Struktur der Kernmodule

### 1. Datenbereinigung & Qualitätssicherung (`14_DATA_CLEANING`)
* **[`DATA_CLEANING_MASTER.sql`](14_DATA_CLEANING/DATA_CLEANING_MASTER.sql):**
  * Whitespace-Bereinigung (`TRIM`, verschachtelte `REPLACE`).
  * Sichere Datumskonvertierung via `TRY_CONVERT` (Harmonisierung von ISO-, DE- und US-Formaten).
  * Syntaktische Prüfung von E-Mail-Adressen.
  * In-Flight-Deduplizierung über `ROW_NUMBER() PARTITION BY ... ORDER BY ID DESC`.

### 2. Fortgeschrittene Fensterfunktionen (`08_WINDOW_FUNCTIONS`)
* **[`WINDOW_FUNCTIONS_MASTER.sql`](08_WINDOW_FUNCTIONS/WINDOW_FUNCTIONS_MASTER.sql):**
  * `DENSE_RANK() OVER (PARTITION BY Kategorie ORDER BY Umsatz DESC)` für Top-Seller je Sortiment.
  * `LAG(Umsatz, 1) OVER (ORDER BY JahrMonat)` zur Berechnung des Month-over-Month (MoM) Wachstums in Euro und Prozent.
  * Gleitender 7-Tage-Durchschnitt (`AVG() OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)`) zur Glättung starker Wochentagsschwankungen (Samstagsspitzen).
  * Monats-Running-Total (`SUM() OVER (PARTITION BY Monat ORDER BY Datum)`).

### 3. Business Analytics, Retention & RFM (`15_ANALYTICS`)
* **[`ADVANCED_ANALYTICS_MASTER.sql`](15_ANALYTICS/ADVANCED_ANALYTICS_MASTER.sql):**
  * **RFM-Kundensegmentierung:** Quantil-Einteilung über `NTILE(5)` für Recency (Tage seit Kauf), Frequency (Einkaufszahl) und Monetary (Gesamtumsatz) in *Champions*, *Loyale Kunden*, *Gefährdete Kunden* und *Inaktive*.
  * **Monatliche Kohortenanalyse (Retention Matrix):** Dynamische Ermittlung des Ersteinkaufs-Monats und Berechnung der Wiederkehrrate für Folgemonate M+1, M+2, M+3, M+6.
  * **Pareto-Sortimentsanalyse (80/20):** Ermittlung des kumulierten Rohertragsbeitrags.

---

## 🚀 Setup: Eigene Datenbank in 2 Minuten aufsetzen

Im Verzeichnis `00_SETUP` liegt der vollständige, deterministische Datengenerator:

```powershell
sqlcmd -S .\SQLEXPRESS -E -i 00_SETUP\01_SupermarktDWH_erstellen.sql
```

Nach wenigen Augenblicken steht die Datenbank `SupermarktDWH` bereit mit:
* 5 Filialen (Hannover-Mitte, Hannover-List, Braunschweig, Hildesheim, Bielefeld)
* 120 Artikeln in 8 Warengruppen
* 3.000 Kundenkarten
* Über 185.000 Kassenbons und 750.000 Positionen
* Staging-Tabelle `stg.Kunden_Rohimport` für Data-Cleaning-Übungen

---

## 💼 Demonstration für Fachgespräche & Interviews

Das Repository belegt fundierte Kenntnisse in:
* **Analytischem T-SQL:** Souveräner Umgang mit CTEs, Subqueries, bedingter Aggregation und Fensterfunktionen.
* **Datenqualitäts-Management:** Strukturierte Identifikation von Inkonsistenzen und Deduplizierung.
* **Verbindung zur Fachabteilung:** Übersetzung abstrakter Management-Fragen ("Welche Kunden wandern ab?", "Wie stark glättet ein 7-Tage-Schnitt das Wochenende?") in performanten SQL-Code.
