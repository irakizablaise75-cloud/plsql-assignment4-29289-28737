# Screenshot Capture Guide

This assignment requires one image per test case to demonstrate that the SQL scripts were executed successfully and produced the expected output. The repository currently stores the captured screenshots as `T1.png` to `T9.png` and `E.png` in the project root, which is acceptable for submission and review.

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

## Expected Screenshot Files

### Success Cases
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

### Error Cases
| Screenshot | Test | Expected Outcome |
|---|---|---|
| `E.png` | Error scenario summary | The script shows exception handling and validation messages |

## Notes for a Clean Submission
- Run the success test file before the error file so the database state matches the expected sequence.
- Ensure every screenshot is readable and not cropped too tightly.
- Keep output labels visible to help the lecturer easily verify the logic.
- If a screenshot does not match the expected numbers or messages, re-run the full script order from the beginning.

## Final Submission Advice
The screenshots are an important part of the assignment because they prove that the project works as intended. A well-organized presentation with clearly labeled outputs helps the lecturer assess both the correctness of the implementation and the quality of the documentation.
