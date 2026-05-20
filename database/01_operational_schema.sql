-- =======================
-- DEPARTMENT
-- provided data
-- =======================
CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    department_description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
-- ======================
-- Updated
-- ROLE
-- provided data
-- ======================
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) UNIQUE NOT NULL,
    role_family VARCHAR(100),
    seniority_level VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);
-- ======================
-- EMPLOYEE
-- provided data
-- =======================
CREATE TABLE employee (
    employee_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(200),
    department_id INT REFERENCES department(department_id) ON DELETE SET NULL,
    role_id INT REFERENCES role(role_id) ON DELETE SET NULL,
    manager_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    total_hours_per_week NUMERIC(5,2) NOT NULL DEFAULT 40.00,
    rewarding_indicator VARCHAR(100),
    join_date DATE,
    employment_status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
-- ======
-- SKILL
-- ======
CREATE TABLE skill (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100)
);
-- ======================================
-- EMPLOYEE_SKILL
-- Company / Constella-enhanced
-- ======================================
CREATE TABLE employee_skill (
    employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
    skill_id INT REFERENCES skill(skill_id) ON DELETE CASCADE,
    skill_level VARCHAR(50),
    proficiency_score NUMERIC(5,2),
    years_experience NUMERIC(4,1),
    last_updated TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (employee_id, skill_id)
);
-- =====================
-- PROJECT
-- Company-provided data
-- =======================
CREATE TABLE project (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    description TEXT,
    manager_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    planned_budget NUMERIC(12,2),
    actual_cost NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    deadline DATE,
    status VARCHAR(50),
    priority VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
-- ============================================
-- PROJECT_REQUIRED_SKILL
-- team formation and skill gap analysis
-- ============================================
CREATE TABLE project_required_skill (
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    skill_id INT REFERENCES skill(skill_id) ON DELETE CASCADE,
    required_level VARCHAR(50),
    importance_weight NUMERIC(5,2),
    required_count INT DEFAULT 1,
    PRIMARY KEY (project_id, skill_id)
);
-- =========================
-- TASK
-- Generated data
-- ===========================
CREATE TABLE task (
    task_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    owner_employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    task_name VARCHAR(150) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    progress_percent NUMERIC(5,2) DEFAULT 0,
    estimated_hours NUMERIC(6,2),
    actual_hours NUMERIC(6,2),
    priority VARCHAR(50),
    start_date DATE,
    deadline DATE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
-- =====================================
-- TASK_ASSIGNMENT
-- Better replacement for employee_task
-- =====================================
CREATE TABLE task_assignment (
    assignment_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
    assignment_role VARCHAR(50), -- owner, contributor, reviewer
    allocation_percent NUMERIC(5,2),
    assigned_at TIMESTAMP DEFAULT NOW(),
    unassigned_at TIMESTAMP
);
-- =================================
-- TASK_SKILL
-- =================================
CREATE TABLE task_skill (
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    skill_id INT REFERENCES skill(skill_id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, skill_id)
);

-- =================================
-- TASK_DEPENDENCY
-- ==================================
CREATE TABLE task_dependency (
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    depends_on_task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    dependency_type VARCHAR(50),
    PRIMARY KEY (task_id, depends_on_task_id),
    CHECK (task_id <> depends_on_task_id)
);

-- ==================================
-- TASK_PROGRESS_HISTORY
-- Generated data
-- Needed for trend and KPI analysis
-- ==================================
CREATE TABLE task_progress_history (
    progress_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    progress_percent NUMERIC(5,2),
    changed_by UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    change_date TIMESTAMP DEFAULT NOW(),
    note TEXT
);
-- ========================
-- TIME_LOG
-- Generated data
-- ========================
CREATE TABLE time_log (
    time_log_id SERIAL PRIMARY KEY,
    employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    hours_logged NUMERIC(5,2) NOT NULL,
    work_type VARCHAR(50), -- development, review, testing, meeting
    is_overtime BOOLEAN DEFAULT FALSE,
    notes TEXT
);
-- =========================
-- QUALITY_REVIEW
-- Generated data
-- =========================
CREATE TABLE quality_review (
    review_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    reviewed_employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    review_date TIMESTAMP DEFAULT NOW(),
    quality_score NUMERIC(5,2),
    productivity_score NUMERIC(5,2),
    defects_found INT DEFAULT 0,
    rework_required BOOLEAN DEFAULT FALSE,
    comments TEXT
);
-- =========================
-- UTILIZATION_MEASURE
-- Generated data
-- =========================
CREATE TABLE utilization_measure (
    utilization_id SERIAL PRIMARY KEY,
    employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
    measure_date DATE NOT NULL,
    available_hours NUMERIC(5,2),
    logged_hours NUMERIC(5,2),
    utilization_rate NUMERIC(5,2),
    overload_flag BOOLEAN DEFAULT FALSE,
    underutilized_flag BOOLEAN DEFAULT FALSE
);
-- =========================
-- ALERT
-- Generated data
-- =========================
CREATE TABLE alert (
    alert_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES task(task_id) ON DELETE CASCADE,
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employee(employee_id) ON DELETE SET NULL,
    message TEXT NOT NULL,
    alert_type VARCHAR(50),
    severity VARCHAR(50),
    status VARCHAR(50) DEFAULT 'open',
    alert_date TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);
-- =========================
-- MONITORING_INDICATOR
-- Generated data
-- =========================
CREATE TABLE monitoring_indicator (
    indicator_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES project(project_id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employee(employee_id) ON DELETE CASCADE,
    indicator_name VARCHAR(100) NOT NULL,
    indicator_date DATE NOT NULL,
    indicator_value NUMERIC(10,2),
    threshold_value NUMERIC(10,2),
    status VARCHAR(50)
);
-- =========================
-- TREND_INDICATOR
-- Generated data
-- =========================
CREATE TABLE trend_indicator (
    trend_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL, -- employee, project, department
    entity_id VARCHAR(100) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    trend_date DATE NOT NULL,
    metric_value NUMERIC(10,2),
    trend_direction VARCHAR(20), -- up, down, stable
    trend_percent NUMERIC(5,2)
);
-- =========================
-- PREDICTION_OUTPUT
-- Generated data
-- =========================
CREATE TABLE prediction_output (
    prediction_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL, -- employee, task, project
    entity_id VARCHAR(100) NOT NULL,
    prediction_type VARCHAR(100) NOT NULL, -- delay_risk, burnout_risk, budget_overrun
    predicted_value NUMERIC(10,2),
    confidence_score NUMERIC(5,2),
    generated_at TIMESTAMP DEFAULT NOW(),
    target_date DATE,
    model_version VARCHAR(50)
);
