-- TIME LOG
CREATE TABLE dw.fact_time_log (
    time_log_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    task_key INT REFERENCES dw.dim_task(task_key),
    hours_logged NUMERIC(5,2),
    is_overtime BOOLEAN
);

-- TASK PROGRESS
CREATE TABLE dw.fact_task_progress (
    task_progress_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    task_key INT REFERENCES dw.dim_task(task_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    changed_by_employee_key INT REFERENCES dw.dim_employee(employee_key),
    progress_percent NUMERIC(5,2),
    old_status VARCHAR(50),
    new_status VARCHAR(50)
);

-- EMPLOYEE SKILL
CREATE TABLE dw.fact_employee_skill (
    employee_skill_fact_id SERIAL PRIMARY KEY,
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    skill_key INT REFERENCES dw.dim_skill(skill_key),
    department_key INT REFERENCES dw.dim_department(department_key),
    role_key INT REFERENCES dw.dim_role(role_key),
    proficiency_score NUMERIC(5,2),
    years_experience NUMERIC(4,1),
    skill_level VARCHAR(50)
);

-- PROJECT REQUIREMENT
CREATE TABLE dw.fact_project_requirement (
    project_requirement_fact_id SERIAL PRIMARY KEY,
    project_key INT REFERENCES dw.dim_project(project_key),
    skill_key INT REFERENCES dw.dim_skill(skill_key),
    importance_weight NUMERIC(5,2),
    required_count INT,
    required_level VARCHAR(50)
);

-- UTILIZATION
CREATE TABLE dw.fact_utilization (
    utilization_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    available_hours NUMERIC(5,2),
    logged_hours NUMERIC(5,2),
    utilization_rate NUMERIC(5,2),
    overload_flag BOOLEAN,
    underutilized_flag BOOLEAN
);

-- QUALITY REVIEW
CREATE TABLE dw.fact_quality_review (
    quality_review_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    task_key INT REFERENCES dw.dim_task(task_key),
    reviewer_employee_key INT REFERENCES dw.dim_employee(employee_key),
    reviewed_employee_key INT REFERENCES dw.dim_employee(employee_key),
    quality_score NUMERIC(5,2),
    productivity_score NUMERIC(5,2),
    defects_found INT,
    rework_required BOOLEAN
);

-- ALERT
CREATE TABLE dw.fact_alert (
    alert_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    task_key INT REFERENCES dw.dim_task(task_key),
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    alert_type VARCHAR(50),
    severity VARCHAR(50),
    status VARCHAR(50),
    alert_count INT DEFAULT 1
);

-- PREDICTION (FIXED)
CREATE TABLE dw.fact_prediction (
    prediction_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    task_key INT REFERENCES dw.dim_task(task_key),
    prediction_type VARCHAR(100),
    predicted_value NUMERIC(10,2),
    confidence_score NUMERIC(5,2),
    target_date DATE,
    model_version VARCHAR(50)
);

-- MONITORING
CREATE TABLE dw.fact_monitoring_indicator (
    monitoring_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    project_key INT REFERENCES dw.dim_project(project_key),
    employee_key INT REFERENCES dw.dim_employee(employee_key),
    indicator_name VARCHAR(100),
    indicator_value NUMERIC(10,2),
    threshold_value NUMERIC(10,2),
    status VARCHAR(50)
);

-- TREND
CREATE TABLE dw.fact_trend_indicator (
    trend_fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw.dim_date(date_key),
    entity_type VARCHAR(50),
    entity_id VARCHAR(100),
    metric_name VARCHAR(100),
    metric_value NUMERIC(10,2),
    trend_direction VARCHAR(20),
    trend_percent NUMERIC(5,2)
);
