-- ============================================================
-- test_error_cases.sql
-- Each block deliberately triggers an exception.
-- The error is EXPECTED - that is the point of the test.
-- "PL/SQL procedure successfully completed" is also expected because
-- each test catches and prints its exception instead of letting it escape.
-- Run AFTER test_success_cases.sql so the data is in the
-- expected state.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ============================================================
PROMPT E1: NO_DATA_FOUND -> fn_get_annual_salary(9999)
PROMPT ============================================================
BEGIN
  DBMS_OUTPUT.PUT_LINE(fn_get_annual_salary(9999));
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E2: empty department -> fn_dept_total_salary(99)
PROMPT ============================================================
BEGIN
  DBMS_OUTPUT.PUT_LINE(fn_dept_total_salary(99));
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E3: TOO_MANY_ROWS -> duplicate last name
PROMPT ============================================================
PROMPT Setup below succeeds intentionally; the lookup should then fail.
-- Make the test repeatable.
BEGIN
  DELETE FROM salary_audit WHERE emp_id = 1099;
  DELETE FROM employees   WHERE emp_id = 1099;
  COMMIT;
END;
/

BEGIN
  INSERT INTO employees
    VALUES (1099, 'Paul', 'Niyonzima', 'paul.n@corp.rw', SYSDATE,
            'Developer', 500000, 20);
  COMMIT;
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(fn_find_employee_by_name('Niyonzima'));
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

-- Clean up the extra row.
DELETE FROM employees WHERE emp_id = 1099;
COMMIT;

PROMPT ============================================================
PROMPT E4: DUP_VAL_ON_INDEX -> hire an employee that already exists
PROMPT ============================================================
DECLARE
  v_added NUMBER;
BEGIN
  prc_hire_employee(
    p_emp_id     => 1001,
    p_first_name => 'Dup',
    p_last_name  => 'Licate',
    p_email      => 'dup@corp.rw',
    p_job_title  => 'X',
    p_salary     => 100000,
    p_dept_id    => 10,
    p_rows_added => v_added);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E5: bad percentage -> prc_raise_salary_by_dept(20, -5)
PROMPT ============================================================
DECLARE
  v_n NUMBER;
BEGIN
  prc_raise_salary_by_dept(p_dept_id => 20,
                           p_pct     => -5,
                           p_updated => v_n);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E6: invalid department -> prc_transfer_employee(1002, 999)
PROMPT ============================================================
BEGIN
  prc_transfer_employee(p_emp_id      => 1002,
                        p_new_dept_id => 999);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E7: employee not found -> prc_transfer_employee(7777, 10)
PROMPT ============================================================
BEGIN
  prc_transfer_employee(p_emp_id      => 7777,
                        p_new_dept_id => 10);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E8: bulk DML errors -> FORALL ... SAVE EXCEPTIONS (ORA-24381)
PROMPT ============================================================
-- A -100% raise produces salary 0, which violates chk_salary_pos.
DECLARE
  v_n NUMBER;
BEGIN
  prc_bulk_adjust_salaries(p_pct     => -100,
                           p_cap     => 1,
                           p_updated => v_n);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E9: department does not exist -> prc_dept_roster_report(999)
PROMPT ============================================================
BEGIN
  prc_dept_roster_report(999);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ============================================================
PROMPT E10: NULL cap -> prc_bulk_adjust_salaries(5, NULL)
PROMPT ============================================================
DECLARE
  v_n NUMBER;
BEGIN
  prc_bulk_adjust_salaries(p_pct     => 5,
                           p_cap     => NULL,
                           p_updated => v_n);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/
