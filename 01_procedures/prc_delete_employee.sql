-- ============================================================
-- prc_delete_employee.sql
-- Delete an employee and that employee's salary-audit history.
-- Demonstrates:
--   * implicit cursors with DELETE
--   * SQL%ROWCOUNT / SQL%FOUND / SQL%NOTFOUND
--   * meaningful not-found error
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_delete_employee (
  p_emp_id        IN  employees.emp_id%TYPE,
  p_deleted       OUT NUMBER,
  p_audit_deleted OUT NUMBER
)
IS
BEGIN
  -- Delete child audit rows first (implicit cursor DELETE).
  DELETE FROM salary_audit
  WHERE  emp_id = p_emp_id;

  p_audit_deleted := SQL%ROWCOUNT;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Deleted ' || p_audit_deleted ||
                         ' audit row(s) for employee ' || p_emp_id);
  END IF;

  -- Delete the employee (implicit cursor DELETE).
  DELETE FROM employees
  WHERE  emp_id = p_emp_id;

  p_deleted := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20070,
      'prc_delete_employee: employee ' || p_emp_id || ' not found');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Deleted employee ' || p_emp_id ||
                       ' (rows deleted: ' || p_deleted || ')');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE BETWEEN -20099 AND -20000 THEN
      RAISE;                            -- keep our own error code/message
    ELSE
      RAISE_APPLICATION_ERROR(-20071,
        'prc_delete_employee failed: ' || SQLERRM);
    END IF;
END prc_delete_employee;
/
SHOW ERRORS;
