-- ============================================================
-- fn_find_employee_by_name.sql
-- Return the emp_id of the employee with a given last name.
-- Demonstrates:
--   * NO_DATA_FOUND and TOO_MANY_ROWS predefined exceptions
--   * RAISE_APPLICATION_ERROR with clear messages
-- ============================================================
CREATE OR REPLACE FUNCTION fn_find_employee_by_name (
  p_last_name IN employees.last_name%TYPE
) RETURN NUMBER
IS
  v_emp_id employees.emp_id%TYPE;
BEGIN
  SELECT emp_id
  INTO   v_emp_id
  FROM   employees
  WHERE  UPPER(last_name) = UPPER(p_last_name);

  RETURN v_emp_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20013,
      'fn_find_employee_by_name: no employee named ' || p_last_name);
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20014,
      'fn_find_employee_by_name: more than one employee named ' ||
      p_last_name || ' - please search by a unique key');
END fn_find_employee_by_name;
/
SHOW ERRORS;
