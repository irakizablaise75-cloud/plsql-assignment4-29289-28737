-- ============================================================
-- prc_hire_employee.sql
-- Insert one new employee from a user-defined PL/SQL record.
-- Demonstrates:
--   * user-defined record (TYPE ... IS RECORD)
--   * INSERT through an implicit cursor
--   * SQL%ROWCOUNT
--   * DUP_VAL_ON_INDEX and generic exception handling
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_hire_employee (
  p_emp_id     IN  employees.emp_id%TYPE,
  p_first_name IN  employees.first_name%TYPE,
  p_last_name  IN  employees.last_name%TYPE,
  p_email      IN  employees.email%TYPE,
  p_job_title  IN  employees.job_title%TYPE,
  p_salary     IN  employees.salary%TYPE,
  p_dept_id    IN  employees.dept_id%TYPE,
  p_rows_added OUT NUMBER
)
IS
  -- User-defined record that mirrors one new employee row.
  TYPE t_emp_rec IS RECORD (
    emp_id     employees.emp_id%TYPE,
    first_name employees.first_name%TYPE,
    last_name  employees.last_name%TYPE,
    email      employees.email%TYPE,
    hire_date  employees.hire_date%TYPE,
    job_title  employees.job_title%TYPE,
    salary     employees.salary%TYPE,
    dept_id    employees.dept_id%TYPE
  );

  v_emp t_emp_rec;
BEGIN
  IF p_salary IS NULL OR p_salary <= 0 THEN
    RAISE_APPLICATION_ERROR(-20022,
      'prc_hire_employee: salary must be a positive number');
  END IF;

  -- Populate the record.
  v_emp.emp_id     := p_emp_id;
  v_emp.first_name := p_first_name;
  v_emp.last_name  := p_last_name;
  v_emp.email      := p_email;
  v_emp.hire_date  := SYSDATE;
  v_emp.job_title  := p_job_title;
  v_emp.salary     := p_salary;
  v_emp.dept_id    := p_dept_id;

  INSERT INTO employees (emp_id, first_name, last_name, email,
                         hire_date, job_title, salary, dept_id)
  VALUES (v_emp.emp_id, v_emp.first_name, v_emp.last_name, v_emp.email,
          v_emp.hire_date, v_emp.job_title, v_emp.salary, v_emp.dept_id);

  -- Implicit cursor attribute: number of rows inserted.
  p_rows_added := SQL%ROWCOUNT;

  DBMS_OUTPUT.PUT_LINE('Hired ' || v_emp.first_name || ' ' ||
                       v_emp.last_name || ' (rows added: ' ||
                       p_rows_added || ')');
  COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    p_rows_added := 0;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20020,
      'prc_hire_employee: employee ID or email already exists');
  WHEN OTHERS THEN
    p_rows_added := 0;
    ROLLBACK;
    IF SQLCODE BETWEEN -20099 AND -20000 THEN
      RAISE;                          -- keep our own error code/message
    ELSE
      RAISE_APPLICATION_ERROR(-20021,
        'prc_hire_employee failed: ' || SQLERRM);
    END IF;
END prc_hire_employee;
/
SHOW ERRORS;
