-- ============================================
-- CREATE DW SCHEMA
-- ============================================

CREATE SCHEMA IF NOT EXISTS dw;


-- ============================================
-- DIM_DATE
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_month INT,
    month_number INT,
    month_name VARCHAR(20),
    quarter_number INT,
    year_number INT,
    week_of_year INT,
    weekday_number INT,
    weekday_name VARCHAR(20),
    is_weekend BOOLEAN
);


-- ============================================
-- DIM_DEPARTMENT
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_department (
    department_key SERIAL PRIMARY KEY,
    department_id INT NOT NULL,
    department_name VARCHAR(100),
    department_description TEXT,

    CONSTRAINT uq_dim_department_source UNIQUE (department_id)
);


-- ============================================
-- DIM_ROLE
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_role (
    role_key SERIAL PRIMARY KEY,
    role_id INT NOT NULL,
    role_name VARCHAR(100),
    role_family VARCHAR(100),
    seniority_level VARCHAR(50),

    CONSTRAINT uq_dim_role_source UNIQUE (role_id)
);


-- ============================================
-- DIM_SKILL
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_skill (
    skill_key SERIAL PRIMARY KEY,
    skill_id INT NOT NULL,
    skill_name VARCHAR(100),
    category VARCHAR(100),

    CONSTRAINT uq_dim_skill_source UNIQUE (skill_id)
);


-- ============================================
-- DIM_PROJECT
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_project (
    project_key SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    project_name VARCHAR(150),
    description TEXT,
    manager_id INT,
    planned_budget NUMERIC(12, 2),
    actual_cost NUMERIC(12, 2),
    start_date DATE,
    end_date DATE,
    deadline DATE,
    status VARCHAR(50),
    priority VARCHAR(50),

    CONSTRAINT uq_dim_project_source UNIQUE (project_id)
);


-- ============================================
-- DIM_EMPLOYEE
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_employee (
    employee_key SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    full_name VARCHAR(150),
    email VARCHAR(150),
    department_key INT,
    role_key INT,
    manager_id INT,
    total_hours_per_week NUMERIC(5, 2),
    rewarding_indicator NUMERIC(5, 2),
    join_date DATE,
    employment_status VARCHAR(50),

    CONSTRAINT uq_dim_employee_source UNIQUE (employee_id),

    CONSTRAINT fk_dim_employee_department
        FOREIGN KEY (department_key)
        REFERENCES dw.dim_department(department_key),

    CONSTRAINT fk_dim_employee_role
        FOREIGN KEY (role_key)
        REFERENCES dw.dim_role(role_key)
);


-- ============================================
-- DIM_TASK
-- ============================================

CREATE TABLE IF NOT EXISTS dw.dim_task (
    task_key SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    project_key INT,
    owner_employee_id INT,
    task_name VARCHAR(150),
    description TEXT,
    status VARCHAR(50),
    progress_percent NUMERIC(5, 2),
    estimated_hours NUMERIC(8, 2),
    actual_hours NUMERIC(8, 2),
    priority VARCHAR(50),
    start_date DATE,
    deadline DATE,
    completed_at TIMESTAMP,

    CONSTRAINT uq_dim_task_source UNIQUE (task_id),

    CONSTRAINT fk_dim_task_project
        FOREIGN KEY (project_key)
        REFERENCES dw.dim_project(project_key)
);
