-- ============================================================
-- prc_bulk_adjust_salaries.sql
-- Load all employees into collections, compute a capped raise,
-- then write the changes back with FORALL.
-- Demonstrates:
--   * BULK COLLECT into associative arrays (collections)
--   * FORALL bulk UPDATE
--   * SAVE EXCEPTIONS and SQL%BULK_EXCEPTIONS (ORA-24381)
-- ============================================================
CREATE OR REPLACE PROCEDURE prc_bulk_adjust_salaries (
  p_pct     IN  NUMBER,                 -- raise percentage
  p_cap     IN  NUMBER,                 -- maximum salary after the raise
  p_updated OUT NUMBER
)
IS
  -- Associative arrays hold the IDs and the new salaries.
  TYPE t_id_tab  IS TABLE OF employees.emp_id%TYPE  INDEX BY PLS_INTEGER;
  TYPE t_sal_tab IS TABLE OF employees.salary%TYPE  INDEX BY PLS_INTEGER;

  v_ids  t_id_tab;
  v_sals t_sal_tab;

  bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
BEGIN
  -- Validate inputs before touching any data.
  IF p_pct IS NULL THEN
    RAISE_APPLICATION_ERROR(-20043,
      'prc_bulk_adjust_salaries: percentage must not be NULL');
  END IF;

  IF p_cap IS NULL THEN
    RAISE_APPLICATION_ERROR(-20044,
      'prc_bulk_adjust_salaries: cap must not be NULL');
  END IF;

  IF p_cap <= 0 THEN
    RAISE_APPLICATION_ERROR(-20045,
      'prc_bulk_adjust_salaries: cap must be greater than zero');
  END IF;

  -- 1) Fetch every employee in one round trip (BULK COLLECT).
  SELECT emp_id, salary
  BULK   COLLECT INTO v_ids, v_sals
  FROM   employees;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20040,
      'prc_bulk_adjust_salaries: no employees to process');
  END IF;

  -- 2) Compute each new salary in PL/SQL, capped at p_cap.
  FOR i IN 1 .. v_ids.COUNT LOOP
    v_sals(i) := LEAST(ROUND(v_sals(i) * (1 + p_pct / 100), 2), p_cap);
  END LOOP;

  -- 3) Write every row back in one bulk operation.
  --    SAVE EXCEPTIONS lets the statement finish even if some rows fail.
  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE employees
    SET    salary = v_sals(i)
    WHERE  emp_id = v_ids(i);

  p_updated := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Bulk-updated ' || p_updated || ' employee(s).');
  COMMIT;
EXCEPTION
  WHEN bulk_errors THEN
    -- Report each failed row instead of hiding the problem.
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Bulk update hit ' ||
                         SQL%BULK_EXCEPTIONS.COUNT || ' error(s):');
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('  row ' ||
        SQL%BULK_EXCEPTIONS(i).ERROR_INDEX || ' -> ' ||
        SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
    END LOOP;
    RAISE_APPLICATION_ERROR(-20041,
      'prc_bulk_adjust_salaries: some rows failed (see output)');
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE BETWEEN -20099 AND -20000 THEN
      RAISE;                            -- keep our own error code/message
    ELSE
      RAISE_APPLICATION_ERROR(-20042,
        'prc_bulk_adjust_salaries failed: ' || SQLERRM);
    END IF;
END prc_bulk_adjust_salaries;
/
SHOW ERRORS;
