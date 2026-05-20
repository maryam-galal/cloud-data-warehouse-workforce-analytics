CREATE OR REPLACE FUNCTION dw.refresh_staging()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE staging.stg_department;
    INSERT INTO staging.stg_department SELECT * FROM public.department;

    TRUNCATE staging.stg_role;
    INSERT INTO staging.stg_role SELECT * FROM public.role;

    TRUNCATE staging.stg_employee;
    INSERT INTO staging.stg_employee SELECT * FROM public.employee;

    TRUNCATE staging.stg_skill;
    INSERT INTO staging.stg_skill SELECT * FROM public.skill;

    TRUNCATE staging.stg_employee_skill;
    INSERT INTO staging.stg_employee_skill SELECT * FROM public.employee_skill;

    TRUNCATE staging.stg_project;
    INSERT INTO staging.stg_project SELECT * FROM public.project;

    TRUNCATE staging.stg_project_required_skill;
    INSERT INTO staging.stg_project_required_skill SELECT * FROM public.project_required_skill;

    TRUNCATE staging.stg_task;
    INSERT INTO staging.stg_task SELECT * FROM public.task;

    TRUNCATE staging.stg_task_assignment;
    INSERT INTO staging.stg_task_assignment SELECT * FROM public.task_assignment;

    TRUNCATE staging.stg_task_skill;
    INSERT INTO staging.stg_task_skill SELECT * FROM public.task_skill;

    TRUNCATE staging.stg_task_dependency;
    INSERT INTO staging.stg_task_dependency SELECT * FROM public.task_dependency;

    TRUNCATE staging.stg_task_progress_history;
    INSERT INTO staging.stg_task_progress_history SELECT * FROM public.task_progress_history;

    TRUNCATE staging.stg_time_log;
    INSERT INTO staging.stg_time_log SELECT * FROM public.time_log;

    TRUNCATE staging.stg_quality_review;
    INSERT INTO staging.stg_quality_review SELECT * FROM public.quality_review;

    TRUNCATE staging.stg_utilization_measure;
    INSERT INTO staging.stg_utilization_measure SELECT * FROM public.utilization_measure;

    TRUNCATE staging.stg_alert;
    INSERT INTO staging.stg_alert SELECT * FROM public.alert;

    TRUNCATE staging.stg_monitoring_indicator;
    INSERT INTO staging.stg_monitoring_indicator SELECT * FROM public.monitoring_indicator;

    TRUNCATE staging.stg_trend_indicator;
    INSERT INTO staging.stg_trend_indicator SELECT * FROM public.trend_indicator;

    TRUNCATE staging.stg_prediction_output;
    INSERT INTO staging.stg_prediction_output SELECT * FROM public.prediction_output;
END;
$$;
CREATE OR REPLACE FUNCTION dw.refresh_dimensions()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO dw.dim_date (
        date_key, full_date, day_of_month, month_number, month_name,
        quarter_number, year_number, week_of_year,
        weekday_number, weekday_name, is_weekend
    )
    SELECT
        TO_CHAR(d, 'YYYYMMDD')::INT,
        d::DATE,
        EXTRACT(DAY FROM d)::INT,
        EXTRACT(MONTH FROM d)::INT,
        TRIM(TO_CHAR(d, 'Month')),
        EXTRACT(QUARTER FROM d)::INT,
        EXTRACT(YEAR FROM d)::INT,
        EXTRACT(WEEK FROM d)::INT,
        EXTRACT(DOW FROM d)::INT,
        TRIM(TO_CHAR(d, 'Day')),
        CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END
    FROM generate_series('2025-01-01'::DATE, '2027-12-31'::DATE, INTERVAL '1 day') AS d
    ON CONFLICT (date_key) DO NOTHING;

    INSERT INTO dw.dim_department (
        department_id, department_name, department_description
    )
    SELECT department_id, department_name, department_description
    FROM staging.stg_department
    ON CONFLICT (department_id)
    DO UPDATE SET
        department_name = EXCLUDED.department_name,
        department_description = EXCLUDED.department_description;

    INSERT INTO dw.dim_role (
        role_id, role_name, role_family, seniority_level
    )
    SELECT role_id, role_name, role_family, seniority_level
    FROM staging.stg_role
    ON CONFLICT (role_id)
    DO UPDATE SET
        role_name = EXCLUDED.role_name,
        role_family = EXCLUDED.role_family,
        seniority_level = EXCLUDED.seniority_level;

    INSERT INTO dw.dim_skill (
        skill_id, skill_name, category
    )
    SELECT skill_id, skill_name, category
    FROM staging.stg_skill
    ON CONFLICT (skill_id)
    DO UPDATE SET
        skill_name = EXCLUDED.skill_name,
        category = EXCLUDED.category;

    INSERT INTO dw.dim_project (
        project_id, project_name, description, manager_id,
        planned_budget, actual_cost, start_date, end_date,
        deadline, status, priority
    )
    SELECT
        project_id, project_name, description, manager_id,
        planned_budget, actual_cost, start_date, end_date,
        deadline, status, priority
    FROM staging.stg_project
    ON CONFLICT (project_id)
    DO UPDATE SET
        project_name = EXCLUDED.project_name,
        description = EXCLUDED.description,
        manager_id = EXCLUDED.manager_id,
        planned_budget = EXCLUDED.planned_budget,
        actual_cost = EXCLUDED.actual_cost,
        start_date = EXCLUDED.start_date,
        end_date = EXCLUDED.end_date,
        deadline = EXCLUDED.deadline,
        status = EXCLUDED.status,
        priority = EXCLUDED.priority;

    INSERT INTO dw.dim_employee (
        employee_id, full_name, email, department_key, role_key,
        manager_id, total_hours_per_week, rewarding_indicator,
        join_date, employment_status
    )
    SELECT
        e.employee_id,
        e.full_name,
        e.email,
        dd.department_key,
        dr.role_key,
        e.manager_id,
        e.total_hours_per_week,
        e.rewarding_indicator,
        e.join_date,
        e.employment_status
    FROM staging.stg_employee e
    LEFT JOIN dw.dim_department dd ON e.department_id = dd.department_id
    LEFT JOIN dw.dim_role dr ON e.role_id = dr.role_id
    ON CONFLICT (employee_id)
    DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        department_key = EXCLUDED.department_key,
        role_key = EXCLUDED.role_key,
        manager_id = EXCLUDED.manager_id,
        total_hours_per_week = EXCLUDED.total_hours_per_week,
        rewarding_indicator = EXCLUDED.rewarding_indicator,
        join_date = EXCLUDED.join_date,
        employment_status = EXCLUDED.employment_status;

    INSERT INTO dw.dim_task (
        task_id, project_key, owner_employee_id, task_name,
        description, status, progress_percent, estimated_hours,
        actual_hours, priority, start_date, deadline, completed_at
    )
    SELECT
        t.task_id,
        dp.project_key,
        t.owner_employee_id,
        t.task_name,
        t.description,
        t.status,
        t.progress_percent,
        t.estimated_hours,
        t.actual_hours,
        t.priority,
        t.start_date,
        t.deadline,
        t.completed_at
    FROM staging.stg_task t
    LEFT JOIN dw.dim_project dp ON t.project_id = dp.project_id
    ON CONFLICT (task_id)
    DO UPDATE SET
        project_key = EXCLUDED.project_key,
        owner_employee_id = EXCLUDED.owner_employee_id,
        task_name = EXCLUDED.task_name,
        description = EXCLUDED.description,
        status = EXCLUDED.status,
        progress_percent = EXCLUDED.progress_percent,
        estimated_hours = EXCLUDED.estimated_hours,
        actual_hours = EXCLUDED.actual_hours,
        priority = EXCLUDED.priority,
        start_date = EXCLUDED.start_date,
        deadline = EXCLUDED.deadline,
        completed_at = EXCLUDED.completed_at;
END;
$$;
CREATE OR REPLACE FUNCTION dw.refresh_facts()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
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

    INSERT INTO dw.fact_time_log (
        date_key, employee_key, project_key, task_key, hours_logged, is_overtime
    )
    SELECT dd.date_key, de.employee_key, dp.project_key, dt.task_key,
           tl.hours_logged, tl.is_overtime
    FROM staging.stg_time_log tl
    LEFT JOIN dw.dim_date dd ON tl.log_date = dd.full_date
    LEFT JOIN dw.dim_employee de ON tl.employee_id = de.employee_id
    LEFT JOIN dw.dim_project dp ON tl.project_id = dp.project_id
    LEFT JOIN dw.dim_task dt ON tl.task_id = dt.task_id;

    INSERT INTO dw.fact_task_progress (
        date_key, task_key, project_key, changed_by_employee_key,
        progress_percent, old_status, new_status
    )
    SELECT dd.date_key, dt.task_key, dp.project_key, de.employee_key,
           tph.progress_percent, tph.old_status, tph.new_status
    FROM staging.stg_task_progress_history tph
    LEFT JOIN dw.dim_date dd ON tph.change_date::DATE = dd.full_date
    LEFT JOIN dw.dim_task dt ON tph.task_id = dt.task_id
    LEFT JOIN dw.dim_project dp ON dt.project_key = dp.project_key
    LEFT JOIN dw.dim_employee de ON tph.changed_by = de.employee_id;

    INSERT INTO dw.fact_employee_skill (
        employee_key, skill_key, department_key, role_key,
        proficiency_score, years_experience, skill_level
    )
    SELECT de.employee_key, ds.skill_key, de.department_key, de.role_key,
           es.proficiency_score, es.years_experience, es.skill_level
    FROM staging.stg_employee_skill es
    LEFT JOIN dw.dim_employee de ON es.employee_id = de.employee_id
    LEFT JOIN dw.dim_skill ds ON es.skill_id = ds.skill_id;

    INSERT INTO dw.fact_project_requirement (
        project_key, skill_key, importance_weight, required_count, required_level
    )
    SELECT dp.project_key, ds.skill_key, prs.importance_weight,
           prs.required_count, prs.required_level
    FROM staging.stg_project_required_skill prs
    LEFT JOIN dw.dim_project dp ON prs.project_id = dp.project_id
    LEFT JOIN dw.dim_skill ds ON prs.skill_id = ds.skill_id;

    INSERT INTO dw.fact_utilization (
        date_key, employee_key, available_hours, logged_hours,
        utilization_rate, overload_flag, underutilized_flag
    )
    SELECT dd.date_key, de.employee_key, um.available_hours,
           um.logged_hours, um.utilization_rate,
           um.overload_flag, um.underutilized_flag
    FROM staging.stg_utilization_measure um
    LEFT JOIN dw.dim_date dd ON um.measure_date = dd.full_date
    LEFT JOIN dw.dim_employee de ON um.employee_id = de.employee_id;

    INSERT INTO dw.fact_quality_review (
        date_key, project_key, task_key, reviewer_employee_key,
        reviewed_employee_key, quality_score, productivity_score,
        defects_found, rework_required
    )
    SELECT dd.date_key, dp.project_key, dt.task_key,
           reviewer.employee_key, reviewed.employee_key,
           qr.quality_score, qr.productivity_score,
           qr.defects_found, qr.rework_required
    FROM staging.stg_quality_review qr
    LEFT JOIN dw.dim_date dd ON qr.review_date::DATE = dd.full_date
    LEFT JOIN dw.dim_project dp ON qr.project_id = dp.project_id
    LEFT JOIN dw.dim_task dt ON qr.task_id = dt.task_id
    LEFT JOIN dw.dim_employee reviewer ON qr.reviewer_id = reviewer.employee_id
    LEFT JOIN dw.dim_employee reviewed ON qr.reviewed_employee_id = reviewed.employee_id;

    INSERT INTO dw.fact_alert (
        date_key, project_key, task_key, employee_key,
        alert_type, severity, status, alert_count
    )
    SELECT dd.date_key, dp.project_key, dt.task_key, de.employee_key,
           a.alert_type, a.severity, a.status, 1
    FROM staging.stg_alert a
    LEFT JOIN dw.dim_date dd ON a.alert_date::DATE = dd.full_date
    LEFT JOIN dw.dim_project dp ON a.project_id = dp.project_id
    LEFT JOIN dw.dim_task dt ON a.task_id = dt.task_id
    LEFT JOIN dw.dim_employee de ON a.employee_id = de.employee_id;

    INSERT INTO dw.fact_prediction (
        date_key, employee_key, project_key, task_key,
        prediction_type, predicted_value, confidence_score,
        target_date, model_version
    )
    SELECT dd.date_key, de.employee_key, dp.project_key, dt.task_key,
           p.prediction_type, p.predicted_value, p.confidence_score,
           p.target_date, p.model_version
    FROM staging.stg_prediction_output p
    LEFT JOIN dw.dim_date dd ON p.generated_at::DATE = dd.full_date
    LEFT JOIN dw.dim_employee de
        ON p.entity_type = 'employee'
       AND p.entity_id = de.employee_id::TEXT
    LEFT JOIN dw.dim_project dp
        ON p.entity_type = 'project'
       AND p.entity_id = dp.project_id::TEXT
    LEFT JOIN dw.dim_task dt
        ON p.entity_type = 'task'
       AND p.entity_id = dt.task_id::TEXT;

    INSERT INTO dw.fact_monitoring_indicator (
        date_key, project_key, employee_key,
        indicator_name, indicator_value, threshold_value, status
    )
    SELECT dd.date_key, dp.project_key, de.employee_key,
           mi.indicator_name, mi.indicator_value,
           mi.threshold_value, mi.status
    FROM staging.stg_monitoring_indicator mi
    LEFT JOIN dw.dim_date dd ON mi.indicator_date = dd.full_date
    LEFT JOIN dw.dim_project dp ON mi.project_id = dp.project_id
    LEFT JOIN dw.dim_employee de ON mi.employee_id = de.employee_id;

    INSERT INTO dw.fact_trend_indicator (
        date_key, entity_type, entity_id, metric_name,
        metric_value, trend_direction, trend_percent
    )
    SELECT dd.date_key, ti.entity_type, ti.entity_id,
           ti.metric_name, ti.metric_value,
           ti.trend_direction, ti.trend_percent
    FROM staging.stg_trend_indicator ti
    LEFT JOIN dw.dim_date dd ON ti.trend_date = dd.full_date;
END;
$$;
CREATE OR REPLACE FUNCTION dw.refresh_dw()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM dw.refresh_staging();
    PERFORM dw.refresh_dimensions();
    PERFORM dw.refresh_facts();
END;
$$;
