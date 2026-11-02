-- ============================================================
-- prc_transfer_employee.sql
-- Move an employee to another department.
-- Demonstrates:
--   * implicit cursor with UPDATE
--   * SQL%ROWCOUNT / SQL%FOUND / SQL%NOTFOUND
--   * validation against the parent DEPARTMENTS table
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_transfer_employee (
  p_emp_id      IN employees.emp_id%TYPE,
  p_new_dept_id IN departments.dept_id%TYPE
)
IS
  v_exists NUMBER;
BEGIN
  -- Check the destination department first.
  SELECT COUNT(*)
  INTO   v_exists
  FROM   departments
  WHERE  dept_id = p_new_dept_id;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20060,
      'prc_transfer_employee: target department ' || p_new_dept_id ||
      ' does not exist');
  END IF;

  -- Implicit cursor: the UPDATE statement itself.
  UPDATE employees
  SET    dept_id = p_new_dept_id
  WHERE  emp_id  = p_emp_id;

  IF SQL%NOTFOUND THEN                -- no row matched the employee id
    RAISE_APPLICATION_ERROR(-20061,
      'prc_transfer_employee: employee ' || p_emp_id || ' not found');
  END IF;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Transferred employee ' || p_emp_id ||
                         ' to dept ' || p_new_dept_id ||
                         ' (rows: ' || SQL%ROWCOUNT || ')');
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE BETWEEN -20099 AND -20000 THEN
      RAISE;                            -- keep our own error code/message
    ELSE
      RAISE_APPLICATION_ERROR(-20062,
        'prc_transfer_employee failed: ' || SQLERRM);
    END IF;
END prc_transfer_employee;
/
SHOW ERRORS;
