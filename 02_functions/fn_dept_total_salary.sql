-- ============================================================
-- fn_dept_total_salary.sql
-- Return the total monthly salary paid by one department.
-- Demonstrates:
--   * explicit cursor opened, fetched with BULK COLLECT, then closed
--   * associative-array collection inside a function
--   * user-defined exception for an empty department
-- ============================================================
CREATE OR REPLACE FUNCTION fn_dept_total_salary (
  p_dept_id IN departments.dept_id%TYPE
) RETURN NUMBER
IS
  CURSOR c_emps IS
    SELECT salary
    FROM   employees
    WHERE  dept_id = p_dept_id;

  -- Associative array that receives all salaries in one fetch.
  TYPE t_sal_tab IS TABLE OF employees.salary%TYPE INDEX BY PLS_INTEGER;
  v_sals        t_sal_tab;
  v_total       NUMBER := 0;
  ex_empty_dept EXCEPTION;
BEGIN
  OPEN c_emps;
  FETCH c_emps BULK COLLECT INTO v_sals;   -- explicit cursor + collection
  CLOSE c_emps;

  IF v_sals.COUNT = 0 THEN
    RAISE ex_empty_dept;
  END IF;

  FOR i IN 1 .. v_sals.COUNT LOOP
    v_total := v_total + NVL(v_sals(i), 0);
  END LOOP;

  RETURN v_total;
EXCEPTION
  WHEN ex_empty_dept THEN
    RAISE_APPLICATION_ERROR(-20012,
      'fn_dept_total_salary: department ' || p_dept_id ||
      ' has no employees (or does not exist)');
END fn_dept_total_salary;
/
SHOW ERRORS;
