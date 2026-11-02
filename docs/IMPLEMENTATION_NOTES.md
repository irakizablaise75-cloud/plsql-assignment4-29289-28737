# Implementation & Performance Notes

## Scenario
A small **Employee Management** system for a company with several
departments. It stores departments, employees, and a salary-change audit
trail, and exposes stored procedures and functions for common HR tasks:
hiring, salary raises, transfers, deletion, and reporting.

## Where each required concept is demonstrated
| Concept | File | Notes |
|---|---|---|
| User-defined record | `01_procedures/prc_hire_employee.sql` | `TYPE t_emp_rec IS RECORD (...)` holds one new hire |
| `%ROWTYPE` record | `prc_raise_salary_by_dept.sql`, `prc_dept_roster_report.sql` | `c_emps%ROWTYPE`, `departments%ROWTYPE`, `employees%ROWTYPE` |
| Associative array | `prc_bulk_adjust_salaries.sql`, `fn_dept_total_salary.sql` | `TABLE OF ... INDEX BY PLS_INTEGER` |
| Nested table | `prc_dept_roster_report.sql` | `TABLE OF employees%ROWTYPE` |
| Implicit cursor | `prc_transfer_employee.sql`, `prc_hire_employee.sql`, `prc_delete_employee.sql` | `SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND`; INSERT, UPDATE and DELETE |
| Explicit cursor | `prc_raise_salary_by_dept.sql`, `fn_dept_total_salary.sql` | `OPEN`/`FETCH`/`CLOSE` (with `BULK COLLECT` in the function) |
| BULK COLLECT | `prc_bulk_adjust_salaries.sql`, `prc_dept_roster_report.sql`, `fn_dept_total_salary.sql` | load many rows in one round trip |
| FORALL | `prc_bulk_adjust_salaries.sql` | bulk UPDATE with `SAVE EXCEPTIONS` |
| Stored procedures | `01_procedures/` | 6 procedures with IN/OUT params |
| Functions | `02_functions/` | 4 functions returning scalar values |
| Predefined exceptions | functions + `test_error_cases.sql` | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX` |
| User-defined exceptions | `fn_dept_total_salary.sql`, `prc_raise_salary_by_dept.sql` | `ex_empty_dept`, `ex_bad_pct` |
| `RAISE_APPLICATION_ERROR` | every procedure/function | codes -20010 .. -20071 |

## Error code reference
| Code | Raised by | Meaning |
|---|---|---|
| -20010 | `fn_get_annual_salary` | Employee not found |
| -20011 | `fn_years_of_service` | Employee not found |
| -20012 | `fn_dept_total_salary` | Department has no employees |
| -20013 | `fn_find_employee_by_name` | No employee with that last name |
| -20014 | `fn_find_employee_by_name` | More than one match |
| -20020 | `prc_hire_employee` | Duplicate employee ID or email |
| -20021 | `prc_hire_employee` | Other insert failure |
| -20022 | `prc_hire_employee` | Salary is NULL or not positive |
| -20030 | `prc_raise_salary_by_dept` | No employees in the department |
| -20031 | `prc_raise_salary_by_dept` | Percentage is NULL or not positive |
| -20032 | `prc_raise_salary_by_dept` | Other update failure |
| -20040 | `prc_bulk_adjust_salaries` | No employees to process |
| -20041 | `prc_bulk_adjust_salaries` | One or more bulk DML rows failed |
| -20042 | `prc_bulk_adjust_salaries` | Other bulk failure |
| -20043 / -20044 / -20045 | `prc_bulk_adjust_salaries` | NULL percentage / NULL cap / cap <= 0 |
| -20050 | `prc_dept_roster_report` | Department does not exist |
| -20060 | `prc_transfer_employee` | Target department does not exist |
| -20061 | `prc_transfer_employee` | Employee not found |
| -20062 | `prc_transfer_employee` | Other transfer failure |
| -20070 | `prc_delete_employee` | Employee not found |
| -20071 | `prc_delete_employee` | Other delete failure |

## Test coverage
| Test | Concept exercised |
|---|---|
| T1 | Function called from SQL (`fn_get_annual_salary`) |
| T2 | Two functions from an anonymous block |
| T3 | Unique-name lookup function |
| T4 | User-defined record + `SQL%ROWCOUNT` |
| T5 | Explicit cursor + audit insert |
| T6 | `BULK COLLECT` + `FORALL` |
| T7 | `%ROWTYPE` + nested table + `BULK COLLECT` |
| T8 | Implicit cursor `UPDATE` + `SQL%ROWCOUNT` |
| T9 | Implicit cursor `DELETE` + `SQL%ROWCOUNT` |
| E1 | `NO_DATA_FOUND` |
| E2 | User-defined exception |
| E3 | `TOO_MANY_ROWS` |
| E4 | `DUP_VAL_ON_INDEX` |
| E5 | User-defined exception + `RAISE_APPLICATION_ERROR` |
| E6 | Invalid parent key validation |
| E7 | `SQL%NOTFOUND` + `RAISE_APPLICATION_ERROR` |
| E8 | Bulk DML errors (`SQL%BULK_EXCEPTIONS`) |
| E9 | `NO_DATA_FOUND` in a procedure |
| E10 | Input validation (`NULL` cap) |

## Why bulk processing is faster
Row-by-row DML (a plain loop that runs one `UPDATE` per iteration) forces a
**context switch** between the PL/SQL engine and the SQL engine on every
single row. For N rows that is N switches.

`BULK COLLECT` and `FORALL` move all the rows across the PL/SQL <-> SQL
boundary in **one** switch each:
- `BULK COLLECT` fetches every selected row into collections in a single call.
- `FORALL` sends the whole array of DML statements to the SQL engine at once.

For large tables this cuts the context-switch overhead dramatically (often an
order of magnitude faster), at the cost of extra PGA memory to hold the
collections. For very large data sets you would add a `LIMIT` clause to
`BULK COLLECT` to process the rows in batches and cap memory use.

## Bulk DML error handling
`FORALL ... SAVE EXCEPTIONS` lets the bulk statement finish even if some rows
fail. Failed rows are reported through `SQL%BULK_EXCEPTIONS` (error index +
error code), which `prc_bulk_adjust_salaries` prints instead of silently
swallowing them (bound to ORA-24381 via `PRAGMA EXCEPTION_INIT`). Error test
`E8` demonstrates this by forcing a `chk_salary_pos` violation on every row.

## Exception-handling philosophy
Errors are never hidden. Each handler either re-raises with a clear
`RAISE_APPLICATION_ERROR` message (in the -20000 range) or prints the error
via `DBMS_OUTPUT`, and DML is rolled back on failure so the data stays
consistent.

## A note on time-based values
`fn_years_of_service` is computed from `SYSDATE`, so its result grows over
time. That is expected behaviour - years of service are not hardcoded.
