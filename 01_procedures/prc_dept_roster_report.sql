-- ============================================================
-- prc_dept_roster_report.sql
-- Print a roster for one department.
-- Demonstrates:
--   * %ROWTYPE record for the department header
--   * nested table collection of employees%ROWTYPE records
--   * BULK COLLECT into a collection
--   * NO_DATA_FOUND handling
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_dept_roster_report (
  p_dept_id IN departments.dept_id%TYPE
)
IS
  -- Nested table of full employee records.
  TYPE t_emp_tab IS TABLE OF employees%ROWTYPE;
  v_emps t_emp_tab;
  v_dept departments%ROWTYPE;           -- %ROWTYPE record
BEGIN
  -- Fetch the department header (raises NO_DATA_FOUND if missing).
  SELECT *
  INTO   v_dept
  FROM   departments
  WHERE  dept_id = p_dept_id;

  -- Fetch all employees of the department in one call.
  SELECT *
  BULK   COLLECT INTO v_emps
  FROM   employees
  WHERE  dept_id = p_dept_id;

  DBMS_OUTPUT.PUT_LINE('=== Roster: ' || v_dept.dept_name ||
                       ' (' || v_dept.location || ') ===');

  IF v_emps.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  (no employees in this department)');
    RETURN;
  END IF;

  -- Iterate over the collection of records.
  FOR i IN 1 .. v_emps.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(
      '  ' || v_emps(i).emp_id || ' - ' ||
      RPAD(v_emps(i).first_name || ' ' || v_emps(i).last_name, 22) ||
      RPAD(v_emps(i).job_title, 18) ||
      'Salary: ' || TO_CHAR(v_emps(i).salary, 'FM999,999,990'));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('  Total employees: ' || v_emps.COUNT);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20050,
      'prc_dept_roster_report: department ' || p_dept_id ||
      ' does not exist');
END prc_dept_roster_report;
/
SHOW ERRORS;
