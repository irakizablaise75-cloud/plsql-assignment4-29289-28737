-- ============================================================
-- 01_create_tables.sql
-- Employee Management - tables, relationships, constraints
-- Run this script FIRST.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Drop existing objects in child-to-parent order so the script can
-- be re-run safely. "table or view does not exist" is ignored.
BEGIN
  FOR t IN (SELECT table_name
            FROM   user_tables
            WHERE  table_name IN ('SALARY_AUDIT', 'EMPLOYEES', 'DEPARTMENTS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_salary_audit';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN          -- sequence does not exist
      RAISE;
    END IF;
END;
/

-- ---------- Parent table: DEPARTMENTS ----------
CREATE TABLE departments (
  dept_id     NUMBER(4)      CONSTRAINT pk_departments PRIMARY KEY,
  dept_name   VARCHAR2(50)   CONSTRAINT nn_dept_name NOT NULL,
  location    VARCHAR2(50)   DEFAULT 'Kigali',
  CONSTRAINT uq_dept_name UNIQUE (dept_name)
);

-- ---------- Child table: EMPLOYEES ----------
CREATE TABLE employees (
  emp_id      NUMBER(6)      CONSTRAINT pk_employees PRIMARY KEY,
  first_name  VARCHAR2(30)   CONSTRAINT nn_first_name NOT NULL,
  last_name   VARCHAR2(30)   CONSTRAINT nn_last_name  NOT NULL,
  email       VARCHAR2(60)   CONSTRAINT uq_emp_email UNIQUE,
  hire_date   DATE           DEFAULT SYSDATE,
  job_title   VARCHAR2(40),
  salary      NUMBER(10,2)   CONSTRAINT chk_salary_pos CHECK (salary > 0),
  dept_id     NUMBER(4),
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id)
             REFERENCES departments(dept_id)
);

-- ---------- Audit table: SALARY_AUDIT ----------
-- One row for every salary change made by the procedures.
CREATE TABLE salary_audit (
  audit_id    NUMBER(8)      CONSTRAINT pk_salary_audit PRIMARY KEY,
  emp_id      NUMBER(6)      CONSTRAINT nn_audit_emp NOT NULL,
  old_salary  NUMBER(10,2),
  new_salary  NUMBER(10,2),
  change_date DATE           DEFAULT SYSDATE,
  changed_by  VARCHAR2(30)   DEFAULT USER,
  CONSTRAINT fk_audit_emp FOREIGN KEY (emp_id)
             REFERENCES employees(emp_id)
);

-- Sequence used to generate SALARY_AUDIT primary keys.
CREATE SEQUENCE seq_salary_audit START WITH 1 INCREMENT BY 1 NOCACHE;

-- Helpful indexes for the foreign-key lookups used by the procedures.
CREATE INDEX idx_emp_dept   ON employees(dept_id);
CREATE INDEX idx_audit_emp  ON salary_audit(emp_id);


