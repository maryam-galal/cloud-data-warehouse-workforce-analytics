-- ============================================
-- USEFUL INDEXES
-- ============================================
CREATE INDEX idx_employee_department ON employee(department_id);
CREATE INDEX idx_employee_role ON employee(role_id);
CREATE INDEX idx_project_manager ON project(manager_id);
CREATE INDEX idx_task_project ON task(project_id);
CREATE INDEX idx_task_owner ON task(owner_employee_id);
CREATE INDEX idx_task_status ON task(status);
CREATE INDEX idx_time_log_employee ON time_log(employee_id);
CREATE INDEX idx_time_log_project ON time_log(project_id);
CREATE INDEX idx_time_log_date ON time_log(log_date);
CREATE INDEX idx_alert_project ON alert(project_id);
CREATE INDEX idx_alert_employee ON alert(employee_id);
CREATE INDEX idx_prediction_entity ON prediction_output(entity_type, entity_id);
CREATE INDEX idx_monitoring_indicator_date ON monitoring_indicator(indicator_date);
CREATE INDEX idx_utilization_employee_date ON utilization_measure(employee_id, measure_date);
