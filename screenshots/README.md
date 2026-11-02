# Screenshot Capture Guide

**Group Assignment IV - Records and Collections in Oracle PL/SQL**

| Student | Full Name | Student ID |
|---|---|---|
| Student 1 | Irakiza Blaise | 29289 |
| Student 2 | Ishimwe Zacharie | 28737 |

This assignment requires one image per test case to demonstrate that the SQL scripts were executed successfully and produced the expected output. The repository stores the captured screenshots in the `screenshots/` folder as `T1.png` to `T9.png` and `E.png`, which matches the repository structure required by the assignment and keeps the project organized for presentation.

## Required Output Evidence
The screenshots should clearly show:
- the executed PL/SQL block or script
- the `DBMS_OUTPUT` result
- the relevant prompt labels such as `T4:` or `E8:`
- the final output that confirms the expected behavior

## Recommended Execution Order

1. `00_schema/01_create_tables.sql`
2. `00_schema/02_insert_sample_data.sql`
3. All files in `01_procedures/`
4. All files in `02_functions/`
5. `03_tests/test_success_cases.sql`
6. `03_tests/test_error_cases.sql`

> Use `SET SERVEROUTPUT ON SIZE UNLIMITED;` before running the scripts so output is visible.

## SQL Developer Capture Steps
1. Connect to the Oracle database.
2. Open the relevant test script in the SQL Worksheet.
3. Press **F5 (Run Script)**, not **F9**.
4. Expand the **Script Output** panel.
5. Capture the full screen or the output panel.
6. Save the screenshot with the correct test name.

## What Each Screenshot Is Supposed To Do

### Success Cases

**`T1.png` - `fn_get_annual_salary`**
This screenshot proves that the annual salary function works. It should show the employee name, monthly salary, and the calculated annual salary (monthly salary x 12) so the lecturer can confirm the function returns the correct total.

**`T2.png` - Years of service + department total**
This screenshot proves that the years-of-service function and department total salary function work. It should show how many years an employee has worked for the company and the total salary paid to a department.

**`T3.png` - Employee lookup by name**
This screenshot proves that the employee lookup function returns the correct record. It should show the employee's first name, last name, job title, salary, and department for the searched name.

**`T4.png` - Hire employee**
This screenshot proves that a new employee can be inserted safely. It should show the success message, the new employee ID, and the number of rows added by the insert.

**`T5.png` - Department raise + audit**
This screenshot proves that a department salary raise is applied and recorded. It should show the updated salaries and the new rows written to the `salary_audit` table (old salary, new salary, and change date).

**`T6.png` - Bulk adjustment**
This screenshot proves that bulk processing works. It should show the bulk adjustment message and the count of employees whose salaries were updated using `BULK COLLECT` and `FORALL`.

**`T7.png` - Department roster report**
This screenshot proves that the roster report prints correctly. It should show the department name, the list of employees in that department, and the total employee count.

**`T8.png` - Transfer employee**
This screenshot proves that an employee can be moved between departments. It should show the employee ID, the old department, the new department, and the message confirming the transfer.

**`T9.png` - Delete employee**
This screenshot proves that an employee can be deleted only when valid. It should show the deletion message and the remaining employee count after the delete.

### Error Cases

**`E.png` - Error scenario summary**
This screenshot proves that the error handling works. It should show each invalid operation being rejected with a clear validation message (for example duplicate ID, unknown department, invalid salary, or missing employee) and confirm that no bad data was saved.

### Summary Table
| Screenshot | Test | Expected Output |
|---|---|---|
| `T1.png` | `fn_get_annual_salary` | Salary and annual total display correctly |
| `T2.png` | Years of service + department total | Years worked and department total appear correctly |
| `T3.png` | Employee lookup by name | Employee record is returned correctly |
| `T4.png` | Hire employee | New employee is inserted and rows added is shown |
| `T5.png` | Department raise + audit | Salary rise is applied and audit records are shown |
| `T6.png` | Bulk adjustment | Bulk update message and row count are visible |
| `T7.png` | Department roster report | Department roster and total employee count are printed |
| `T8.png` | Transfer employee | Employee transfer updates department correctly |
| `T9.png` | Delete employee | Employee deletion and remaining count are shown |
| `E.png` | Error scenario summary | The script shows exception handling and validation messages |

## Notes for a Clean Submission
- Run the success test file before the error file so the database state matches the expected sequence.
- Ensure every screenshot is readable and not cropped too tightly.
- Keep output labels visible to help the lecturer easily verify the logic.
- If a screenshot does not match the expected numbers or messages, re-run the full script order from the beginning.

## Final Submission Advice
The screenshots are an important part of the assignment because they prove that the project works as intended. A well-organized presentation with clearly labeled outputs helps the lecturer assess both the correctness of the implementation and the quality of the documentation.
