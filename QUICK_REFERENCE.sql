/*
================================================================================
QUICK_REFERENCE.sql - Schnelle Navigation & SQLCMD-Ausführungshilfe
================================================================================
TIPP FÜR SSMS / AZURE DATA STUDIO:
Aktivieren Sie im Menü 'Abfrage' den 'SQLCMD-Modus', um einzelne Skripte
über den Befehl ':r .\Pfad\Zur\Datei.sql' direkt einzubinden und auszuführen.

WICHTIG: Alle Pfade sind relativ zum Wurzelverzeichnis des Repositorys. Diese Datei
ist als Inhaltsverzeichnis gedacht - einzelne ':r'-Zeilen markieren und ausführen,
nicht die gesamte Datei.
================================================================================
*/

-- 01_SELECT
:r .\90_TSQL_Syntax_Reference\01_SELECT\01_basic_select.sql
:r .\90_TSQL_Syntax_Reference\01_SELECT\02_distinct.sql
:r .\90_TSQL_Syntax_Reference\01_SELECT\03_aliases_and_calc.sql

-- 02_WHERE_FILTERS
:r .\90_TSQL_Syntax_Reference\02_WHERE_FILTERS\01_comparison_operators.sql
:r .\90_TSQL_Syntax_Reference\02_WHERE_FILTERS\02_like_wildcards.sql
:r .\90_TSQL_Syntax_Reference\02_WHERE_FILTERS\03_between_and_in.sql
:r .\90_TSQL_Syntax_Reference\02_WHERE_FILTERS\04_null_handling.sql

-- 03_JOINS
:r .\90_TSQL_Syntax_Reference\03_JOINS\01_all_joins.sql
:r .\90_TSQL_Syntax_Reference\03_JOINS\02_self_join.sql
:r .\90_TSQL_Syntax_Reference\03_JOINS\03_cross_join.sql

-- 04_AGGREGATIONS
:r .\90_TSQL_Syntax_Reference\04_AGGREGATIONS\01_group_by_having.sql
:r .\90_TSQL_Syntax_Reference\04_AGGREGATIONS\02_rollup_cube.sql

-- 05_CASE
:r .\90_TSQL_Syntax_Reference\05_CASE\01_simple_case.sql
:r .\90_TSQL_Syntax_Reference\05_CASE\02_searched_case.sql
:r .\90_TSQL_Syntax_Reference\05_CASE\03_conditional_aggregation.sql

-- 06_CTE
:r .\90_TSQL_Syntax_Reference\06_CTE\01_basic_cte.sql
:r .\90_TSQL_Syntax_Reference\06_CTE\02_multiple_ctes.sql
:r .\90_TSQL_Syntax_Reference\06_CTE\03_recursive_cte.sql

-- 07_SUBQUERIES
:r .\90_TSQL_Syntax_Reference\07_SUBQUERIES\01_scalar_subquery.sql
:r .\90_TSQL_Syntax_Reference\07_SUBQUERIES\02_correlated_subquery.sql
:r .\90_TSQL_Syntax_Reference\07_SUBQUERIES\03_exists_not_exists.sql

-- 02_WINDOW_FUNCTIONS (Kernmodul)
:r .\02_WINDOW_FUNCTIONS\01_row_number.sql
:r .\02_WINDOW_FUNCTIONS\02_rank.sql
:r .\02_WINDOW_FUNCTIONS\03_lag.sql
:r .\02_WINDOW_FUNCTIONS\04_lead.sql
:r .\02_WINDOW_FUNCTIONS\05_running_total_sum.sql
:r .\02_WINDOW_FUNCTIONS\WINDOW_FUNCTIONS_MASTER.sql

-- 09_DATES
:r .\90_TSQL_Syntax_Reference\09_DATES\01_current_date.sql
:r .\90_TSQL_Syntax_Reference\09_DATES\02_first_day_month.sql
:r .\90_TSQL_Syntax_Reference\09_DATES\03_dateadd_datediff.sql
:r .\90_TSQL_Syntax_Reference\09_DATES\DATE_FUNCTIONS_MASTER.sql

-- 10_STRING_FUNCTIONS
:r .\90_TSQL_Syntax_Reference\10_STRING_FUNCTIONS\01_string_manipulation.sql
:r .\90_TSQL_Syntax_Reference\10_STRING_FUNCTIONS\02_string_split_agg.sql

-- 11_PIVOT_UNPIVOT
:r .\90_TSQL_Syntax_Reference\11_PIVOT_UNPIVOT\01_pivot_sales.sql
:r .\90_TSQL_Syntax_Reference\11_PIVOT_UNPIVOT\02_unpivot_data.sql

-- 12_TEMP_TABLES
:r .\90_TSQL_Syntax_Reference\12_TEMP_TABLES\01_temp_tables.sql
:r .\90_TSQL_Syntax_Reference\12_TEMP_TABLES\02_table_variables.sql

-- 13_JSON
:r .\90_TSQL_Syntax_Reference\13_JSON\01_json_parsing.sql
:r .\90_TSQL_Syntax_Reference\13_JSON\02_for_json.sql

-- 01_DATA_CLEANING (Kernmodul)
:r .\01_DATA_CLEANING\01_trim_spaces.sql
:r .\01_DATA_CLEANING\02_find_duplicates.sql
:r .\01_DATA_CLEANING\03_null_check.sql
:r .\01_DATA_CLEANING\04_deduplication.sql
:r .\01_DATA_CLEANING\DATA_CLEANING_MASTER.sql

-- 03_BUSINESS_ANALYTICS_RFM (Kernmodul)
:r .\03_BUSINESS_ANALYTICS_RFM\01_running_total.sql
:r .\03_BUSINESS_ANALYTICS_RFM\02_top_n_customers.sql
:r .\03_BUSINESS_ANALYTICS_RFM\03_monthly_revenue.sql
:r .\03_BUSINESS_ANALYTICS_RFM\04_customer_retention.sql
:r .\03_BUSINESS_ANALYTICS_RFM\05_abc_analysis.sql
:r .\03_BUSINESS_ANALYTICS_RFM\ABC_ANALYSIS.sql
:r .\03_BUSINESS_ANALYTICS_RFM\RFM_ANALYSIS.sql
:r .\03_BUSINESS_ANALYTICS_RFM\COHORT_ANALYSIS.sql
:r .\03_BUSINESS_ANALYTICS_RFM\CUSTOMER_LIFETIME_VALUE.sql
:r .\03_BUSINESS_ANALYTICS_RFM\FUNNEL_ANALYSIS.sql
:r .\03_BUSINESS_ANALYTICS_RFM\SALES_DASHBOARD_QUERIES.sql
:r .\03_BUSINESS_ANALYTICS_RFM\POWER_BI_DATASET_QUERIES.sql
:r .\03_BUSINESS_ANALYTICS_RFM\ADVANCED_ANALYTICS_MASTER.sql

-- 16_PERFORMANCE
:r .\90_TSQL_Syntax_Reference\16_PERFORMANCE\01_indexes_basics.sql
:r .\90_TSQL_Syntax_Reference\16_PERFORMANCE\02_execution_plans_tips.sql

-- 17_BUSINESS_CASES
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\01_sales_kpi.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\02_customer_retention.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\03_abc_analysis.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\04_rfm_analysis.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\05_customer_ltv.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\06_cohort_analysis.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\07_churn_analysis.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\08_top_customers.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\09_product_profitability.sql
:r .\90_TSQL_Syntax_Reference\17_BUSINESS_CASES\10_monthly_revenue_trend.sql

-- 18_POWER_BI_SQL
:r .\90_TSQL_Syntax_Reference\18_POWER_BI_SQL\fact_sales.sql
:r .\90_TSQL_Syntax_Reference\18_POWER_BI_SQL\dim_customer.sql
:r .\90_TSQL_Syntax_Reference\18_POWER_BI_SQL\dim_product.sql
:r .\90_TSQL_Syntax_Reference\18_POWER_BI_SQL\calendar_table.sql
:r .\90_TSQL_Syntax_Reference\18_POWER_BI_SQL\star_schema.sql

-- 19_DWH_MODELING
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\01_star_schema_architecture.sql
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\02_snowflake_schema.sql
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\03_surrogate_keys_hashing.sql
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\04_junk_dimension.sql
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\05_bridge_table_many_to_many.sql
:r .\90_TSQL_Syntax_Reference\19_DWH_MODELING\06_snapshot_fact_table.sql

-- 20_ETL_PATTERNS
:r .\90_TSQL_Syntax_Reference\20_ETL_PATTERNS\01_staging_load.sql
:r .\90_TSQL_Syntax_Reference\20_ETL_PATTERNS\02_incremental_load.sql
:r .\90_TSQL_Syntax_Reference\20_ETL_PATTERNS\03_merge_upsert.sql
:r .\90_TSQL_Syntax_Reference\20_ETL_PATTERNS\04_slowly_changing_dimension.sql
:r .\90_TSQL_Syntax_Reference\20_ETL_PATTERNS\05_data_validation.sql

-- 21_SQL_CHALLENGES
:r .\90_TSQL_Syntax_Reference\21_SQL_CHALLENGES\01_gaps_and_islands_advanced.sql
:r .\90_TSQL_Syntax_Reference\21_SQL_CHALLENGES\02_median_without_median_func.sql
:r .\90_TSQL_Syntax_Reference\21_SQL_CHALLENGES\03_friend_requests_acceptance_rate.sql
:r .\90_TSQL_Syntax_Reference\21_SQL_CHALLENGES\04_trips_and_users_cancellation.sql
:r .\90_TSQL_Syntax_Reference\21_SQL_CHALLENGES\05_consecutive_numbers_streak.sql

-- 22_ADVANCED_TSQL
:r .\90_TSQL_Syntax_Reference\22_ADVANCED_TSQL\01_dynamic_sql_sp_executesql.sql
:r .\90_TSQL_Syntax_Reference\22_ADVANCED_TSQL\02_transactions_try_catch.sql
:r .\90_TSQL_Syntax_Reference\22_ADVANCED_TSQL\03_inline_table_valued_functions.sql
:r .\90_TSQL_Syntax_Reference\22_ADVANCED_TSQL\04_stored_procedures_best_practices.sql
:r .\90_TSQL_Syntax_Reference\22_ADVANCED_TSQL\05_cursor_vs_set_based_operations.sql

-- 23_FABRIC_SQL
:r .\90_TSQL_Syntax_Reference\23_FABRIC_SQL\01_fabric_lakehouse_endpoint.sql
:r .\90_TSQL_Syntax_Reference\23_FABRIC_SQL\02_openrowset_delta_parquet.sql
:r .\90_TSQL_Syntax_Reference\23_FABRIC_SQL\03_synapse_warehouse_t_sql.sql
:r .\90_TSQL_Syntax_Reference\23_FABRIC_SQL\04_cross_database_queries_onelake.sql

-- 24_AZURE_SQL
:r .\90_TSQL_Syntax_Reference\24_AZURE_SQL\01_row_level_security_rls.sql
:r .\90_TSQL_Syntax_Reference\24_AZURE_SQL\02_dynamic_data_masking.sql
:r .\90_TSQL_Syntax_Reference\24_AZURE_SQL\03_temporal_system_versioned_tables.sql
:r .\90_TSQL_Syntax_Reference\24_AZURE_SQL\04_external_tables_elastic_queries.sql

-- 25_KNIME_SQL
:r .\90_TSQL_Syntax_Reference\25_KNIME_SQL\01_knime_db_query_reader_pattern.sql
:r .\90_TSQL_Syntax_Reference\25_KNIME_SQL\02_knime_flow_variables_injection.sql
:r .\90_TSQL_Syntax_Reference\25_KNIME_SQL\03_in_database_pushdown_optimization.sql
:r .\90_TSQL_Syntax_Reference\25_KNIME_SQL\04_chunked_data_export_pattern.sql

-- 26_ADVENTUREWORKS_PROJECTS
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\01_sales_dashboard.sql
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\02_customer_segmentation.sql
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\03_product_analysis.sql
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\04_customer_retention.sql
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\05_profitability_analysis.sql
:r .\90_TSQL_Syntax_Reference\26_ADVENTUREWORKS_PROJECTS\06_monthly_kpis.sql

-- 99_INTERVIEW_TASKS
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\top_10_sql_questions.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\window_function_tasks.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\ranking_tasks.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\joins_tasks.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\cte_tasks.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\01_second_highest_salary.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\02_duplicates.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\03_consecutive_active_days.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\04_department_top_earners.sql
:r .\90_TSQL_Syntax_Reference\99_INTERVIEW_TASKS\05_cumulative_market_share.sql
