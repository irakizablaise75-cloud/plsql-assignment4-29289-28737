-- ============================================================
-- prc_raise_salary_by_dept.sql
-- Give every employee in a department a percentage raise and
-- write each change to SALARY_AUDIT.
-- Demonstrates:
--   * explicit cursor with OPEN / FETCH / CLOSE
--   * %ROWTYPE record anchored to the cursor
--   * UPDATE ... WHERE CURRENT OF
--   * SQL%FOUND / SQL%ROWCOUNT
--   * user-defined exception and RAISE_APPLICATION_ERROR
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_raise_salary_by_dept (
  p_dept_id IN  employees.dept_id%TYPE,
  p_pct     IN  NUMBER,                 -- 10 means +10%
  p_updated OUT NUMBER
)
IS
  CURSOR c_emps IS
    SELECT emp_id, salary
    FROM   employees
    WHERE  dept_id = p_dept_id
    FOR UPDATE OF salary;

  v_row      c_emps%ROWTYPE;            -- record anchored to the cursor
  v_new_sal  employees.salary%TYPE;
  v_count    NUMBER := 0;
  ex_bad_pct EXCEPTION;
BEGIN
  IF p_pct IS NULL OR p_pct <= 0 THEN
    RAISE ex_bad_pct;
  END IF;

  OPEN c_emps;
  LOOP
    FETCH c_emps INTO v_row;
    EXIT WHEN c_emps%NOTFOUND;

    v_new_sal := ROUND(v_row.salary * (1 + p_pct / 100), 2);

    UPDATE employees
    SET    salary = v_new_sal
    WHERE  CURRENT OF c_emps;

    IF SQL%FOUND THEN                   -- implicit cursor attribute
      INSERT INTO salary_audit (audit_id, emp_id, old_salary, new_salary)
      VALUES (seq_salary_audit.NEXTVAL, v_row.emp_id,
              v_row.salary, v_new_sal);

      v_count := v_count + SQL%ROWCOUNT;
    END IF;
  END LOOP;
  CLOSE c_emps;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20030,
      'prc_raise_salary_by_dept: no employees found in department ' ||
      p_dept_id);
  END IF;

  p_updated := v_count;
  DBMS_OUTPUT.PUT_LINE('Raised salaries for ' || v_count ||
                       ' employee(s) in dept ' || p_dept_id);
  COMMIT;
EXCEPTION
  WHEN ex_bad_pct THEN
    IF c_emps%ISOPEN THEN CLOSE c_emps; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20031,
      'prc_raise_salary_by_dept: percentage must be a positive number');
  WHEN OTHERS THEN
    IF c_emps%ISOPEN THEN CLOSE c_emps; END IF;
    ROLLBACK;
    IF SQLCODE BETWEEN -20099 AND -20000 THEN
      RAISE;                            -- keep our own error code/message
    ELSE
      RAISE_APPLICATION_ERROR(-20032,
        'prc_raise_salary_by_dept failed: ' || SQLERRM);
    END IF;
END prc_raise_salary_by_dept;
/
SHOW ERRORS;
