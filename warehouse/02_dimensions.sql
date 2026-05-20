-- ============================================
-- LOAD / REFRESH DIMENSIONS USING UPSERT
-- Safe to run repeatedly,dimensions should not blindly insert duplicates for every refresh.
-- ============================================

-- DIM_DATE
INSERT INTO dw.dim_date (
    date_key,
    full_date,
    day_of_month,
    month_number,
    month_name,
    quarter_number,
    year_number,
    week_of_year,
    weekday_number,
    weekday_name,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT,
    d::DATE,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    TRIM(TO_CHAR(d, 'Month'))::VARCHAR(20),
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(WEEK FROM d)::INT,
    EXTRACT(DOW FROM d)::INT,
    TRIM(TO_CHAR(d, 'Day'))::VARCHAR(20),
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END
FROM generate_series('2025-01-01'::DATE, '2027-12-31'::DATE, INTERVAL '1 day') AS d
ON CONFLICT (date_key)
DO NOTHING;


-- DIM_DEPARTMENT
INSERT INTO dw.dim_department (
    department_id,
    department_name,
    department_description
)
SELECT
    department_id,
    department_name,
    department_description
FROM staging.stg_department
ON CONFLICT (department_id)
DO UPDATE SET
    department_name = EXCLUDED.department_name,
    department_description = EXCLUDED.department_description;


-- DIM_ROLE
INSERT INTO dw.dim_role (
    role_id,
    role_name,
    role_family,
    seniority_level
)
SELECT
    role_id,
    role_name,
    role_family,
    seniority_level
FROM staging.stg_role
ON CONFLICT (role_id)
DO UPDATE SET
    role_name = EXCLUDED.role_name,
    role_family = EXCLUDED.role_family,
    seniority_level = EXCLUDED.seniority_level;


-- DIM_SKILL
INSERT INTO dw.dim_skill (
    skill_id,
    skill_name,
    category
)
SELECT
    skill_id,
    skill_name,
    category
FROM staging.stg_skill
ON CONFLICT (skill_id)
DO UPDATE SET
    skill_name = EXCLUDED.skill_name,
    category = EXCLUDED.category;


-- DIM_PROJECT
INSERT INTO dw.dim_project (
    project_id,
    project_name,
    description,
    manager_id,
    planned_budget,
    actual_cost,
    start_date,
    end_date,
    deadline,
    status,
    priority
)
SELECT
    project_id,
    project_name,
    description,
    manager_id,
    planned_budget,
    actual_cost,
    start_date,
    end_date,
    deadline,
    status,
    priority
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


-- DIM_EMPLOYEE
INSERT INTO dw.dim_employee (
    employee_id,
    full_name,
    email,
    department_key,
    role_key,
    manager_id,
    total_hours_per_week,
    rewarding_indicator,
    join_date,
    employment_status
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
LEFT JOIN dw.dim_department dd
    ON e.department_id = dd.department_id
LEFT JOIN dw.dim_role dr
    ON e.role_id = dr.role_id
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


-- DIM_TASK
INSERT INTO dw.dim_task (
    task_id,
    project_key,
    owner_employee_id,
    task_name,
    description,
    status,
    progress_percent,
    estimated_hours,
    actual_hours,
    priority,
    start_date,
    deadline,
    completed_at
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
LEFT JOIN dw.dim_project dp
    ON t.project_id = dp.project_id
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
