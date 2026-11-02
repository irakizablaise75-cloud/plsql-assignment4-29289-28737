-- ============================================================
-- 02_insert_sample_data.sql
-- Sample data for the Employee Management application.
-- Run this script AFTER 01_create_tables.sql.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- ---------- Departments ----------
INSERT INTO departments (dept_id, dept_name, location) VALUES (10, 'Finance',         'Kigali');
INSERT INTO departments (dept_id, dept_name, location) VALUES (20, 'IT',              'Kigali');
INSERT INTO departments (dept_id, dept_name, location) VALUES (30, 'Human Resources', 'Musanze');
INSERT INTO departments (dept_id, dept_name, location) VALUES (40, 'Sales',           'Huye');

-- ---------- Employees ----------
INSERT INTO employees VALUES (1001, 'Alice',   'Umutoni',     'alice.u@corp.rw',   DATE '2019-02-15', 'Accountant',       650000, 10);
INSERT INTO employees VALUES (1002, 'Eric',    'Mugisha',     'eric.m@corp.rw',    DATE '2020-06-01', 'Finance Manager',  980000, 10);
INSERT INTO employees VALUES (1003, 'Claude',  'Niyonzima',   'claude.n@corp.rw',  DATE '2021-09-10', 'Developer',        720000, 20);
INSERT INTO employees VALUES (1004, 'Diane',   'Ingabire',    'diane.i@corp.rw',   DATE '2018-11-20', 'IT Manager',      1100000, 20);
INSERT INTO employees VALUES (1005, 'Frank',   'Habimana',    'frank.h@corp.rw',   DATE '2022-03-05', 'Developer',        680000, 20);
INSERT INTO employees VALUES (1006, 'Grace',   'Uwase',       'grace.u@corp.rw',   DATE '2017-07-25', 'HR Officer',       600000, 30);
INSERT INTO employees VALUES (1007, 'Henry',   'Nkurunziza',  'henry.n@corp.rw',   DATE '2023-01-12', 'Sales Rep',        500000, 40);
INSERT INTO employees VALUES (1008, 'Irene',   'Mukamana',    'irene.m@corp.rw',   DATE '2016-04-30', 'Sales Manager',    900000, 40);

COMMIT;


