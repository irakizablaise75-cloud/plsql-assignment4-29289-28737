-- ============================================================
-- fn_years_of_service.sql
-- Return whole years an employee has worked (based on SYSDATE).
-- Demonstrates:
--   * date logic with MONTHS_BETWEEN / TRUNC
--   * NO_DATA_FOUND handling
-- NOTE: the result grows over time because it uses SYSDATE.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_years_of_service (
  p_emp_id IN employees.emp_id%TYPE
) RETURN NUMBER
IS
  v_hire_date employees.hire_date%TYPE;
  v_years     NUMBER;
BEGIN
  SELECT hire_date
  INTO   v_hire_date
  FROM   employees
  WHERE  emp_id = p_emp_id;

  v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12);
  RETURN v_years;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20011,
      'fn_years_of_service: employee ' || p_emp_id || ' not found');
END fn_years_of_service;
/
SHOW ERRORS;
