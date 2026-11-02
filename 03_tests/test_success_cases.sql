-- ============================================================
-- test_success_cases.sql
-- Successful execution of every procedure and function.
-- Run AFTER the schema, sample data, procedures, and functions.
-- Capture the output of each block for the screenshots folder.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ============================================================
PROMPT Setup: remove any leftover test employee 1009
PROMPT ============================================================
BEGIN
  DELETE FROM salary_audit WHERE emp_id = 1009;
  DELETE FROM employees   WHERE emp_id = 1009;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Cleanup complete: employee 1009 cleared.');
END;
/

PROMPT ============================================================
PROMPT T1: fn_get_annual_salary called from SQL
PROMPT ============================================================
SELECT emp_id, salary, fn_get_annual_salary(emp_id) AS annual_salary
FROM   employees
WHERE  emp_id = 1001;

PROMPT ============================================================
PROMPT T2: fn_years_of_service and fn_dept_total_salary from PL/SQL
PROMPT ============================================================
BEGIN
  DBMS_OUTPUT.PUT_LINE('Years of service (1006): ' ||
                       fn_years_of_service(1006));
  DBMS_OUTPUT.PUT_LINE('Total salary dept 20   : ' ||
                       fn_dept_total_salary(20));
END;
/

PROMPT ============================================================
PROMPT T3: fn_find_employee_by_name (unique match)
PROMPT ============================================================
BEGIN
  DBMS_OUTPUT.PUT_LINE('Umutoni -> emp_id ' ||
                       fn_find_employee_by_name('Umutoni'));
END;
/

PROMPT ============================================================
PROMPT T4: prc_hire_employee (record + SQL%ROWCOUNT)
PROMPT ============================================================
DECLARE
  v_added NUMBER;
BEGIN
  prc_hire_employee(
    p_emp_id     => 1009,
    p_first_name => 'John',
    p_last_name  => 'Kagabo',
    p_email      => 'john.k@corp.rw',
    p_job_title  => 'Analyst',
    p_salary     => 640000,
    p_dept_id    => 10,
    p_rows_added => v_added);

  DBMS_OUTPUT.PUT_LINE('Rows added returned: ' || v_added);
END;
/

PROMPT ============================================================
PROMPT T5: prc_raise_salary_by_dept (explicit cursor + audit)
PROMPT ============================================================
DECLARE
  v_n NUMBER;
BEGIN
  prc_raise_salary_by_dept(p_dept_id => 20,
                           p_pct     => 10,
                           p_updated => v_n);

  DBMS_OUTPUT.PUT_LINE('Employees updated: ' || v_n);
END;
/

SELECT emp_id, old_salary, new_salary
FROM   salary_audit
ORDER  BY audit_id;

PROMPT ============================================================
PROMPT T6: prc_bulk_adjust_salaries (BULK COLLECT + FORALL)
PROMPT ============================================================
DECLARE
  v_n NUMBER;
BEGIN
  -- 5% raise, capped at 1,200,000.
  prc_bulk_adjust_salaries(p_pct     => 5,
                           p_cap     => 1200000,
                           p_updated => v_n);

  DBMS_OUTPUT.PUT_LINE('Bulk updated rows: ' || v_n);
END;
/

PROMPT ============================================================
PROMPT T7: prc_dept_roster_report (%ROWTYPE + nested table)
PROMPT ============================================================
BEGIN
  prc_dept_roster_report(20);
END;
/

PROMPT ============================================================
PROMPT T8: prc_transfer_employee (implicit cursor UPDATE)
PROMPT ============================================================
BEGIN
  prc_transfer_employee(p_emp_id      => 1009,
                        p_new_dept_id => 30);
END;
/

SELECT emp_id, first_name, dept_id
FROM   employees
WHERE  emp_id = 1009;

PROMPT ============================================================
PROMPT T9: prc_delete_employee (implicit cursor DELETE)
PROMPT ============================================================
DECLARE
  v_deleted NUMBER;
  v_audit   NUMBER;
BEGIN
  prc_delete_employee(p_emp_id        => 1009,
                      p_deleted       => v_deleted,
                      p_audit_deleted => v_audit);

  DBMS_OUTPUT.PUT_LINE('Deleted employees: ' || v_deleted ||
                       ', audit rows: ' || v_audit);
END;
/

SELECT COUNT(*) AS remaining_1009
FROM   employees
WHERE  emp_id = 1009;
