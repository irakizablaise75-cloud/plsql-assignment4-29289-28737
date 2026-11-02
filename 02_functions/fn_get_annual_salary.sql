-- ============================================================
-- fn_get_annual_salary.sql
-- Return the annual salary (12 months) for one employee.
-- Demonstrates:
--   * parameters and local variables
--   * %TYPE anchoring
--   * NO_DATA_FOUND and RAISE_APPLICATION_ERROR
--   * callable from SQL and PL/SQL
-- ============================================================
CREATE OR REPLACE FUNCTION fn_get_annual_salary (
  p_emp_id IN employees.emp_id%TYPE
) RETURN NUMBER
IS
  v_monthly employees.salary%TYPE;
BEGIN
  SELECT salary
  INTO   v_monthly
  FROM   employees
  WHERE  emp_id = p_emp_id;

  RETURN v_monthly * 12;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20010,
      'fn_get_annual_salary: no employee with ID ' || p_emp_id);
END fn_get_annual_salary;
/
SHOW ERRORS;
