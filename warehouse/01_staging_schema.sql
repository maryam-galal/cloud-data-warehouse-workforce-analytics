-- raw copied data, kies between ODB & DW
CREATE SCHEMA staging;
CREATE SCHEMA dw;
CREATE SCHEMA mart;

-- =========================
-- STAGING TABLES
-- Raw copies from public
-- =========================
CREATE TABLE IF NOT EXISTS staging.stg_employee AS
SELECT * FROM public.employee
WITH NO DATA;
TRUNCATE staging.stg_employee;
INSERT INTO staging.stg_employee
SELECT * FROM public.employee;

CREATE TABLE IF NOT EXISTS staging.stg_department AS
SELECT * FROM public.department
WITH NO DATA;
TRUNCATE staging.stg_department;
INSERT INTO staging.stg_department
SELECT * FROM public.department;

CREATE TABLE IF NOT EXISTS staging.stg_role AS
SELECT * FROM public.role
WITH NO DATA;
TRUNCATE staging.stg_role;
INSERT INTO staging.stg_role
SELECT * FROM public.role;

CREATE TABLE IF NOT EXISTS staging.stg_skill AS
SELECT * FROM public.skill
WITH NO DATA;
TRUNCATE staging.stg_skill;
INSERT INTO staging.stg_skill
SELECT * FROM public.skill;

CREATE TABLE IF NOT EXISTS staging.employee_skill AS
SELECT * FROM public.employee_skill
WITH NO DATA;
TRUNCATE staging.stg_employee_skill;
INSERT INTO staging.stg_employee_skill
SELECT * FROM public.employee_skill;

CREATE TABLE IF NOT EXISTS staging.stg_project AS
SELECT * FROM public.project
WITH NO DATA;
TRUNCATE staging.stg_project;
INSERT INTO staging.stg_project
SELECT * FROM public.project;

CREATE TABLE IF NOT EXISTS staging.stg_project_required_skill AS
SELECT * FROM public.project_required_skill
WITH NO DATA;
TRUNCATE staging.stg_project_required_skill;
INSERT INTO staging.stg_project_required_skill
SELECT * FROM public.project_required_skill;

CREATE TABLE IF NOT EXISTS staging.stg_task AS
SELECT * FROM public.task
WITH NO DATA;
TRUNCATE staging.stg_task;
INSERT INTO staging.stg_task
SELECT * FROM public.task;

CREATE TABLE IF NOT EXISTS staging.stg_task_assignment AS
SELECT * FROM public.task_assignment
WITH NO DATA;
TRUNCATE staging.stg_task_assignment;
INSERT INTO staging.stg_task_assignment
SELECT * FROM public.task_assignment;

CREATE TABLE IF NOT EXISTS staging.stg_task_skill AS
SELECT * FROM public.task_skill
WITH NO DATA;
TRUNCATE staging.stg_task_skill;
INSERT INTO staging.stg_task_skill
SELECT * FROM public.task_skill;

CREATE TABLE IF NOT EXISTS staging.stg_task_dependency AS
SELECT * FROM public.task_dependency
WITH NO DATA;
TRUNCATE staging.stg_task_dependency;
INSERT INTO staging.stg_task_dependency
SELECT * FROM public.task_dependency;

CREATE TABLE IF NOT EXISTS staging.stg_task_progress_history AS
SELECT * FROM public.task_progress_history
WITH NO DATA;
TRUNCATE staging.stg_task_progress_history;
INSERT INTO staging.stg_task_progress_history
SELECT * FROM public.task_progress_history;

CREATE TABLE IF NOT EXISTS staging.stg_time_log AS
SELECT * FROM public.time_log
WITH NO DATA;
TRUNCATE staging.stg_time_log;
INSERT INTO staging.stg_time_log
SELECT * FROM public.time_log;

CREATE TABLE IF NOT EXISTS staging.stg_quality_review AS
SELECT * FROM public.quality_review
WITH NO DATA;
TRUNCATE staging.stg_quality_review;
INSERT INTO staging.stg_quality_review
SELECT * FROM public.quality_review;

CREATE TABLE IF NOT EXISTS staging.stg_utilization_measure AS
SELECT * FROM public.utilization_measure
WITH NO DATA;
TRUNCATE staging.stg_utilization_measure;
INSERT INTO staging.stg_utilization_measure
SELECT * FROM public.utilization_measure;

CREATE TABLE IF NOT EXISTS staging.stg_alert AS
SELECT * FROM public.alert
WITH NO DATA;
TRUNCATE staging.stg_alert;
INSERT INTO staging.stg_alert
SELECT * FROM public.alert;

CREATE TABLE IF NOT EXISTS staging.stg_monitoring_indicator AS
SELECT * FROM public.monitoring_indicator
WITH NO DATA;
TRUNCATE staging.stg_monitoring_indicator;
INSERT INTO staging.stg_monitoring_indicator
SELECT * FROM public.monitoring_indicator;

CREATE TABLE IF NOT EXISTS staging.stg_trend_indicator AS
SELECT * FROM public.trend_indicator
WITH NO DATA;
TRUNCATE staging.stg_trend_indicator;
INSERT INTO staging.stg_trend_indicator
SELECT * FROM public.trend_indicator;

CREATE TABLE IF NOT EXISTS staging.stg_prediction_output AS
SELECT * FROM public.prediction_output
WITH NO DATA;
TRUNCATE staging.stg_prediction_output;
INSERT INTO staging.stg_prediction_output
SELECT * FROM public.prediction_output;
