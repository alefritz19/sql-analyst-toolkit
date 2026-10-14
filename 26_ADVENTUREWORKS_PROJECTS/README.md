# 💼 AdventureWorks Analytics Projects (End-to-End Business Cases)

Willkommen im Bereich für **vollständige, praxisnahe Analyseprojekte** auf Basis der offiziellen Microsoft-Referenzdatenbank **`AdventureWorks2022`**.

Während die vorangehenden 25 Module gezielte Syntax- und Mustervorlagen für einzelne SQL-Konzepte bereitstellen, demonstriert dieses Verzeichnis **komplexe, mehrstufige Business-Intelligence- und Data-Analytics-Fallstudien**, wie sie in Unternehmen täglich für das Management, Marketing und Controlling erstellt werden.

---

## 🎯 Überblick über die 6 Case Studies

| Skript | Projektthema | Verwendete SQL-Konzepte & KPIs |
| :--- | :--- | :--- |
| **`01_sales_dashboard.sql`** | **Executive Sales & Regional Performance** | Territoriums-Performance, AOV (Average Order Value), Online- vs. B2B-Kanalvergleich, Quota Attainment % für Vertriebsmitarbeiter |
| **`02_customer_segmentation.sql`** | **RFM-Kundensegmentierung & CRM Personas** | Recency, Frequency, Monetary mit `NTILE(4)`, Persona-Mapping (Champions, Loyal, At Risk, Lost), Segment-Deckungsbeiträge |
| **`03_product_analysis.sql`** | **Sortimentsanalyse & ABC-Pareto** | Kumulierte Umsatzanteile (`SUM() OVER`), A/B/C-Klassifizierung (80/15/5%), Bestandsabgleich mit `ProductInventory` (Lagerwarnungen) |
| **`04_customer_retention.sql`** | **Kohortenanalyse & Retention Matrix** | Erstkauf-Kohorten nach Monat, Monatliche Aktivitätsmatrix (Month 0 bis 6), Retention Rate %, Wiederkaufrate (Repeat Purchase Rate) |
| **`05_profitability_analysis.sql`** | **Deckungsbeitrags- & Margenanalyse** | Nettoerlöse, COGS (StandardCost), Rabattverluste (`SpecialOffer`), Rohertragsmarge (Gross Margin %) nach Kategorie und Vertriebskanal |
| **`06_monthly_kpis.sql`** | **Monatliche KPI-Suite & Trends** | MoM-Wachstum (`LAG(1)`), YoY-Vorjahresvergleich (`LAG(12)`), Year-to-Date (`SUM() OVER PARTITION BY`), Gleitender 3-Monats-Schnitt |

---

## 🚀 Interview-Leitfaden: Wie du dieses Projekt im Bewerbungsgespräch präsentierst

Wenn dich ein Hiring Manager oder Lead Data Analyst im Interview fragt:
> *"Haben Sie praktische Erfahrung mit SQL auf echten Unternehmensdatenbanken?"*

Kannst du selbstbewusst antworten:

> *"Ja, neben meiner modularen T-SQL-Wissensbasis habe ich in meinem Portfolio sechs abgeschlossene End-to-End-Analyseprojekte auf der Microsoft AdventureWorks-Datenbank umgesetzt. Ich habe dort unter anderem eine vollständige RFM-Kundensegmentierung für CRM-Kampagnen entwickelt, eine Pareto-ABC-Sortimentsanalyse inklusive Bestandsabgleich gebaut sowie Kohortenanalysen zur Messung von Kundenabwanderung (Retention Rate) und monatliche MoM/YoY-KPI-Suiten mit Window Functions realisiert."*

---

## 🛠 Voraussetzungen & Ausführung

1. **Datenbank:** `AdventureWorks2022` auf einer lokalen Microsoft SQL Server Instanz (oder Azure SQL).
2. Falls die Datenbank noch nicht vorhanden ist: Installationsanweisungen befinden sich in [`sample-datasets/README.md`](../sample-datasets/README.md).
3. Jedes Skript beginnt mit `USE AdventureWorks2022; GO` und kann direkt in **SSMS**, **Azure Data Studio** oder via **sqlcmd** fehlerfrei ausgeführt werden.
