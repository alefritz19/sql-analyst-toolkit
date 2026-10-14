# SQL Analyst Toolkit 🚀

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2017%20%7C%202019%20%7C%202022-CC292B?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![Azure SQL](https://img.shields.io/badge/Azure%20SQL-Cloud%20Database-blue?logo=microsoftazure)](https://azure.microsoft.com/products/azure-sql/)
[![Microsoft Fabric](https://img.shields.io/badge/Microsoft%20Fabric-OneLake%20%7C%20Synapse-0078D4)](https://www.microsoft.com/fabric)
[![KNIME](https://img.shields.io/badge/KNIME-In--Database%20Processing-FDD835?logo=knime&logoColor=black)](https://www.knime.com/)
[![T-SQL](https://img.shields.io/badge/Sprache-T--SQL-blue)](https://learn.microsoft.com/sql/t-sql/)
[![Offline Ready](https://img.shields.io/badge/Offline-100%25%20Lauffähig-success)](#)
[![Skripte](https://img.shields.io/badge/Skripte-120%2B%20Dateien-orange)](#)
[![Kategorien](https://img.shields.io/badge/Kategorien-26%20Module-purple)](#)

A practical collection of production-grade T-SQL examples, interview tasks, analytical queries, business cases, DWH modeling patterns, and cloud analytics architectures for:
* **Data Analysts**
* **BI Analysts & Report Developers**
* **Junior Data Engineers & Analytics Engineers**

Alle Skripte sind vollständig autonom mit eigenen Testdaten lauffähig, didaktisch strukturiert und auf Deutsch mit internationaler englischer SQL-Fachterminologie dokumentiert.

---

## 📌 Themenübersicht (26 Kategorien)

1. **SQL Fundamentals** (`01_SELECT`) — SELECT, DISTINCT, Berechnungen, Spaltenaliase
2. **WHERE Filters** (`02_WHERE_FILTERS`) — Vergleichsoperatoren, LIKE-Muster, BETWEEN, IN, NULL-Logik
3. **Joins** (`03_JOINS`) — INNER, LEFT, RIGHT, FULL, SELF JOIN, CROSS JOIN
4. **Aggregations** (`04_AGGREGATIONS`) — GROUP BY, HAVING, Zwischensummen mit ROLLUP & CUBE
5. **CASE & Logic** (`05_CASE`) — Simple & Searched CASE, bedingte Aggregationen
6. **CTEs** (`06_CTE`) — Common Table Expressions, verkettete und rekursive Abfragen
7. **Subqueries** (`07_SUBQUERIES`) — Skalare und korrelierte Unterabfragen, EXISTS / NOT EXISTS
8. **Window Functions** (`08_WINDOW_FUNCTIONS`) — ROW_NUMBER, RANK, DENSE_RANK, NTILE, LAG, LEAD, FIRST_VALUE, LAST_VALUE, SUM/AVG/COUNT OVER
9. **Date Functions** (`09_DATES`) — Systemzeit, DATEADD, DATEDIFF, EOMONTH, ISO-Standards, Kalenderdimension
10. **String Functions** (`10_STRING_FUNCTIONS`) — TRIM, SUBSTRING, CHARINDEX, STRING_SPLIT, STRING_AGG
11. **PIVOT / UNPIVOT** (`11_PIVOT_UNPIVOT`) — Zeilen in Spalten transformieren und Kreuztabellen normalisieren
12. **Temp Tables** (`12_TEMP_TABLES`) — Lokale (#) und globale (##) temporäre Tabellen, Tabellenvariablen (@Table)
13. **JSON in SQL** (`13_JSON`) — Validierung, JSON_VALUE, OPENJSON und FOR JSON
14. **Data Cleaning** (`14_DATA_CLEANING`) — Whitespace-Trimming, Duplikatserkennung, Deduplizierung via ROW_NUMBER
15. **Analytics & KPIs** (`15_ANALYTICS`) — Running Total, Top-N-Kunden, MoM Growth, Retention, Pareto-Klassifizierung
16. **Performance Tuning** (`16_PERFORMANCE`) — Clustered/Non-Clustered Indexe, SARGability, Ausführungspläne
17. **Business Cases** (`17_BUSINESS_CASES`) — Churn, Retention, ABC, RFM, LTV, Cohort, Profitability, Growth Trends
18. **Power BI SQL** (`18_POWER_BI_SQL`) — Sternschema-Architektur, Fact Table, Kundendimension, Produktdimension, Datumstabelle
19. **DWH Modeling** (`19_DWH_MODELING`) — Kimball-Methodologie, Stern- & Schneeflockenschema, Surrogatschlüssel (Hashing), Junk Dimensions, Bridge Tables, Snapshot Facts
20. **ETL Patterns** (`20_ETL_PATTERNS`) — Staging Load, Incremental Delta-Load, MERGE/UPSERT, SCD Typ 1 & 2, Data Validation
21. **SQL Challenges** (`21_SQL_CHALLENGES`) — Fortgeschrittene Gaps & Islands, Median-Berechnung, Akzeptanzraten, Stornierungsraten
22. **Advanced T-SQL** (`22_ADVANCED_TSQL`) — Sicheres dynamisches SQL (`sp_executesql`), TRY...CATCH & XACT_ABORT, Inline TVFs, Stored Procedures, Set-based statt Cursor
23. **Microsoft Fabric SQL** (`23_FABRIC_SQL`) — Fabric Lakehouse SQL Endpoint, OPENROWSET für Delta Parquet, Synapse Data Warehouse, OneLake Cross-Database Queries
24. **Azure SQL** (`24_AZURE_SQL`) — Row-Level Security (RLS), Dynamic Data Masking (DSGVO), Temporale Tabellen, Elastic Queries
25. **KNIME SQL** (`25_KNIME_SQL`) — In-Database Processing (Pushdown), DB Query Reader Patterns, Flow Variables Injection, Chunked Data Export
26. **AdventureWorks Projects** (`26_ADVENTUREWORKS_PROJECTS`) — 6 End-to-End Business Cases: Sales Dashboard, RFM-Kundensegmentierung, ABC/Pareto-Sortiment, Kohorten-Retention, Deckungsbeitragsmarge, Monatliche KPI-Suite
27. **Interview Tasks** (`99_INTERVIEW_TASKS`) — Top-10-Cheatsheets, Ranking, Window Functions, Joins, CTE-Hierarchien

---

## 🛠 Unterstützte Technologien

- **Datenbanken:** Microsoft SQL Server (2017, 2019, 2022), Azure SQL Database, Azure Synapse Analytics
- **Modern Data Stack:** Microsoft Fabric OneLake, Power BI (DirectQuery / Import), KNIME Analytics Platform

---

## 🏢 Beispieldatenbanken (sample-datasets)

Im Verzeichnis `sample-datasets/` befinden sich Installationsanleitungen und automatische Wiederherstellungsskripte für standardisierte Microsoft-Referenzdatenbanken:
* **AdventureWorks2022** (`restore_adventureworks.sql`)
* **WideWorldImporters** (`restore_wideworldimporters.sql`)

---

## ⚡ Schnellstart & Navigation (QUICK_REFERENCE.sql)

Im Stammverzeichnis befindet sich die Steuerdatei `QUICK_REFERENCE.sql`. In **SSMS** oder **Azure Data Studio** kann der **SQLCMD-Modus** aktiviert werden, um jedes Skript per `:r` Befehl direkt modular aufzurufen:

```sql
-- Beispiele aus QUICK_REFERENCE.sql:
:r .\08_WINDOW_FUNCTIONS\WINDOW_FUNCTIONS_MASTER.sql
:r .\17_BUSINESS_CASES\04_rfm_analysis.sql
:r .\19_DWH_MODELING\01_star_schema_architecture.sql
:r .\20_ETL_PATTERNS\03_merge_upsert.sql
:r .\23_FABRIC_SQL\01_fabric_lakehouse_endpoint.sql
:r .\25_KNIME_SQL\01_knime_db_query_reader_pattern.sql
```

---

## 📂 Vollständige Verzeichnisstruktur

```text
sql-analyst-toolkit/
├── README.md
├── .gitignore
├── QUICK_REFERENCE.sql     # Zentrale SQLCMD-Navigation aller 25 Module
│
├── 01_SELECT/              # 01_basic_select.sql, 02_distinct.sql, 03_aliases_and_calc.sql
├── 02_WHERE_FILTERS/       # 01_comparison_operators.sql, 02_like_wildcards.sql, 03_between_and_in.sql, 04_null_handling.sql
├── 03_JOINS/               # 01_all_joins.sql, 02_self_join.sql, 03_cross_join.sql
├── 04_AGGREGATIONS/        # 01_group_by_having.sql, 02_rollup_cube.sql
├── 05_CASE/                # 01_simple_case.sql, 02_searched_case.sql, 03_conditional_aggregation.sql
├── 06_CTE/                 # 01_basic_cte.sql, 02_multiple_ctes.sql, 03_recursive_cte.sql
├── 07_SUBQUERIES/          # 01_scalar_subquery.sql, 02_correlated_subquery.sql, 03_exists_not_exists.sql
├── 08_WINDOW_FUNCTIONS/    # 01_row_number.sql, 02_rank.sql, 03_lag.sql, 04_lead.sql, 05_running_total_sum.sql, WINDOW_FUNCTIONS_MASTER.sql
├── 09_DATES/               # 01_current_date.sql, 02_first_day_month.sql, 03_dateadd_datediff.sql, DATE_FUNCTIONS_MASTER.sql
├── 10_STRING_FUNCTIONS/    # 01_string_manipulation.sql, 02_string_split_agg.sql
├── 11_PIVOT_UNPIVOT/       # 01_pivot_sales.sql, 02_unpivot_data.sql
├── 12_TEMP_TABLES/         # 01_temp_tables.sql, 02_table_variables.sql
├── 13_JSON/                # 01_json_parsing.sql, 02_for_json.sql
├── 14_DATA_CLEANING/       # 01_trim_spaces.sql, 02_find_duplicates.sql, 03_null_check.sql, 04_deduplication.sql
├── 15_ANALYTICS/           # 01_running_total.sql, 02_top_n_customers.sql, 03_monthly_revenue.sql, 04_customer_retention.sql, 05_abc_analysis.sql, ABC_ANALYSIS.sql, RFM_ANALYSIS.sql, COHORT_ANALYSIS.sql, FUNNEL_ANALYSIS.sql, CUSTOMER_LIFETIME_VALUE.sql, SALES_DASHBOARD_QUERIES.sql, POWER_BI_DATASET_QUERIES.sql
├── 16_PERFORMANCE/         # 01_indexes_basics.sql, 02_execution_plans_tips.sql
├── 17_BUSINESS_CASES/      # 01_sales_kpi.sql, 02_customer_retention.sql, 03_abc_analysis.sql, 04_rfm_analysis.sql, 05_customer_ltv.sql, 06_cohort_analysis.sql, 07_churn_analysis.sql, 08_top_customers.sql, 09_product_profitability.sql, 10_monthly_revenue_trend.sql
├── 18_POWER_BI_SQL/        # fact_sales.sql, dim_customer.sql, dim_product.sql, calendar_table.sql, star_schema.sql
├── 19_DWH_MODELING/        # 01_star_schema_architecture.sql, 02_snowflake_schema.sql, 03_surrogate_keys_hashing.sql, 04_junk_dimension.sql, 05_bridge_table_many_to_many.sql, 06_snapshot_fact_table.sql
├── 20_ETL_PATTERNS/        # 01_staging_load.sql, 02_incremental_load.sql, 03_merge_upsert.sql, 04_slowly_changing_dimension.sql, 05_data_validation.sql
├── 21_SQL_CHALLENGES/      # 01_gaps_and_islands_advanced.sql, 02_median_without_median_func.sql, 03_friend_requests_acceptance_rate.sql, 04_trips_and_users_cancellation.sql, 05_consecutive_numbers_streak.sql
├── 22_ADVANCED_TSQL/       # 01_dynamic_sql_sp_executesql.sql, 02_transactions_try_catch.sql, 03_inline_table_valued_functions.sql, 04_stored_procedures_best_practices.sql, 05_cursor_vs_set_based_operations.sql
├── 23_FABRIC_SQL/          # 01_fabric_lakehouse_endpoint.sql, 02_openrowset_delta_parquet.sql, 03_synapse_warehouse_t_sql.sql, 04_cross_database_queries_onelake.sql
├── 24_AZURE_SQL/           # 01_row_level_security_rls.sql, 02_dynamic_data_masking.sql, 03_temporal_system_versioned_tables.sql, 04_external_tables_elastic_queries.sql
├── 25_KNIME_SQL/           # 01_knime_db_query_reader_pattern.sql, 02_knime_flow_variables_injection.sql, 03_in_database_pushdown_optimization.sql, 04_chunked_data_export_pattern.sql
├── 26_ADVENTUREWORKS_PROJECTS/ # README.md, 01_sales_dashboard.sql, 02_customer_segmentation.sql, 03_product_analysis.sql, 04_customer_retention.sql, 05_profitability_analysis.sql, 06_monthly_kpis.sql
├── 99_INTERVIEW_TASKS/     # top_10_sql_questions.sql, window_function_tasks.sql, ranking_tasks.sql, joins_tasks.sql, cte_tasks.sql, 01_second_highest_salary.sql, 02_duplicates.sql, 03_consecutive_active_days.sql, 04_department_top_earners.sql, 05_cumulative_market_share.sql
└── sample-datasets/        # README.md, restore_adventureworks.sql, restore_wideworldimporters.sql
```

---

## 👤 Autor / Author

**Alexander Fritzler**  
*Aspiring Data Analyst & Data Engineer*  
GitHub: [@alefritz19](https://github.com/alefritz19)

---

## 🚀 Offline-Nutzung

Dieses Repository ist zu 100 % autark. Jedes SQL-Skript enthält eigene integrierte Testdaten (via Common Table Expressions `WITH`, Tabellenvariablen `@Table` oder temporäre Tabellen `#Temp`). 

Sie können jede Abfrage direkt markieren und ausführen — **ohne externe Abhängigkeiten und ohne aktive Internetverbindung**.
