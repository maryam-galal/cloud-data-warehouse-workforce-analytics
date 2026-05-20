-- ============================================
-- FULL FACT REFRESH (CLEAN LOAD)
-- ============================================

BEGIN;

-- 1. CLEAN OLD DATA
TRUNCATE dw.fact_prediction RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_alert RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_quality_review RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_utilization RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_project_requirement RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_employee_skill RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_task_progress RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_time_log RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_monitoring_indicator RESTART IDENTITY CASCADE;
TRUNCATE dw.fact_trend_indicator RESTART IDENTITY CASCADE;


-- ============================================
-- 2. LOAD FACTS
-- ============================================

-- TIME LOG
INSERT INTO dw.fact_time_log (
    date_key, employee_key, project_key, task_key, hours_logged, is_overtime
)
SELECT
    dd.date_key,
    de.employee_key,
    dp.project_key,
    dt.task_key,
    tl.hours_logged,
    tl.is_overtime
FROM staging.stg_time_log tl
LEFT JOIN dw.dim_date dd ON tl.log_date = dd.full_date
LEFT JOIN dw.dim_employee de ON tl.employee_id = de.employee_id
LEFT JOIN dw.dim_project dp ON tl.project_id = dp.project_id
LEFT JOIN dw.dim_task dt ON tl.task_id = dt.task_id;


-- TASK PROGRESS
INSERT INTO dw.fact_task_progress (
    date_key, task_key, project_key, changed_by_employee_key,
    progress_percent, old_status, new_status
)
SELECT
    dd.date_key,
    dt.task_key,
    dp.project_key,
    de.employee_key,
    tph.progress_percent,
    tph.old_status,
    tph.new_status
FROM staging.stg_task_progress_history tph
LEFT JOIN dw.dim_date dd ON tph.change_date::date = dd.full_date
LEFT JOIN dw.dim_task dt ON tph.task_id = dt.task_id
LEFT JOIN dw.dim_project dp ON dt.project_key = dp.project_key
LEFT JOIN dw.dim_employee de ON tph.changed_by = de.employee_id;


-- EMPLOYEE SKILL
INSERT INTO dw.fact_employee_skill (
    employee_key, skill_key, department_key, role_key,
    proficiency_score, years_experience, skill_level
)
SELECT
    de.employee_key,
    ds.skill_key,
    de.department_key,
    de.role_key,
    es.proficiency_score,
    es.years_experience,
    es.skill_level
FROM staging.stg_employee_skill es
LEFT JOIN dw.dim_employee de ON es.employee_id = de.employee_id
LEFT JOIN dw.dim_skill ds ON es.skill_id = ds.skill_id;


-- PROJECT REQUIREMENT
INSERT INTO dw.fact_project_requirement (
    project_key, skill_key, importance_weight, required_count, required_level
)
SELECT
    dp.project_key,
    ds.skill_key,
    prs.importance_weight,
    prs.required_count,
    prs.required_level
FROM staging.stg_project_required_skill prs
LEFT JOIN dw.dim_project dp ON prs.project_id = dp.project_id
LEFT JOIN dw.dim_skill ds ON prs.skill_id = ds.skill_id;


-- UTILIZATION
INSERT INTO dw.fact_utilization (
    date_key, employee_key, available_hours, logged_hours,
    utilization_rate, overload_flag, underutilized_flag
)
SELECT
    dd.date_key,
    de.employee_key,
    um.available_hours,
    um.logged_hours,
    um.utilization_rate,
    um.overload_flag,
    um.underutilized_flag
FROM staging.stg_utilization_measure um
LEFT JOIN dw.dim_date dd ON um.measure_date = dd.full_date
LEFT JOIN dw.dim_employee de ON um.employee_id = de.employee_id;


-- QUALITY REVIEW
INSERT INTO dw.fact_quality_review (
    date_key, project_key, task_key,
    reviewer_employee_key, reviewed_employee_key,
    quality_score, productivity_score, defects_found, rework_required
)
SELECT
    dd.date_key,
    dp.project_key,
    dt.task_key,
    reviewer.employee_key,
    reviewed.employee_key,
    qr.quality_score,
    qr.productivity_score,
    qr.defects_found,
    qr.rework_required
FROM staging.stg_quality_review qr
LEFT JOIN dw.dim_date dd ON qr.review_date::date = dd.full_date
LEFT JOIN dw.dim_project dp ON qr.project_id = dp.project_id
LEFT JOIN dw.dim_task dt ON qr.task_id = dt.task_id
LEFT JOIN dw.dim_employee reviewer ON qr.reviewer_id = reviewer.employee_id
LEFT JOIN dw.dim_employee reviewed ON qr.reviewed_employee_id = reviewed.employee_id;


-- ALERT
INSERT INTO dw.fact_alert (
    date_key, project_key, task_key, employee_key,
    alert_type, severity, status, alert_count
)
SELECT
    dd.date_key,
    dp.project_key,
    dt.task_key,
    de.employee_key,
    a.alert_type,
    a.severity,
    a.status,
    1
FROM staging.stg_alert a
LEFT JOIN dw.dim_date dd ON a.alert_date::date = dd.full_date
LEFT JOIN dw.dim_project dp ON a.project_id = dp.project_id
LEFT JOIN dw.dim_task dt ON a.task_id = dt.task_id
LEFT JOIN dw.dim_employee de ON a.employee_id = de.employee_id;


-- 🔥 PREDICTION (FIXED)
INSERT INTO dw.fact_prediction (
    date_key, employee_key, project_key, task_key,
    prediction_type, predicted_value, confidence_score,
    target_date, model_version
)
SELECT
    dd.date_key,
    de.employee_key,
    dp.project_key,
    dt.task_key,
    p.prediction_type,
    p.predicted_value,
    p.confidence_score,
    p.target_date,
    p.model_version
FROM staging.stg_prediction_output p
LEFT JOIN dw.dim_date dd ON p.generated_at::date = dd.full_date
LEFT JOIN dw.dim_employee de
    ON p.entity_type = 'employee'
   AND p.entity_id = de.employee_id::text
LEFT JOIN dw.dim_project dp
    ON p.entity_type = 'project'
   AND p.entity_id = dp.project_id::text
LEFT JOIN dw.dim_task dt
    ON p.entity_type = 'task'
   AND p.entity_id = dt.task_id::text;


-- MONITORING
INSERT INTO dw.fact_monitoring_indicator (
    date_key, project_key, employee_key,
    indicator_name, indicator_value, threshold_value, status
)
SELECT
    dd.date_key,
    dp.project_key,
    de.employee_key,
    mi.indicator_name,
    mi.indicator_value,
    mi.threshold_value,
    mi.status
FROM staging.stg_monitoring_indicator mi
LEFT JOIN dw.dim_date dd ON mi.indicator_date = dd.full_date
LEFT JOIN dw.dim_project dp ON mi.project_id = dp.project_id
LEFT JOIN dw.dim_employee de ON mi.employee_id = de.employee_id;


-- TREND
INSERT INTO dw.fact_trend_indicator (
    date_key, entity_type, entity_id,
    metric_name, metric_value, trend_direction, trend_percent
)
SELECT
    dd.date_key,
    ti.entity_type,
    ti.entity_id,
    ti.metric_name,
    ti.metric_value,
    ti.trend_direction,
    ti.trend_percent
FROM staging.stg_trend_indicator ti
LEFT JOIN dw.dim_date dd ON ti.trend_date = dd.full_date;


COMMIT;
