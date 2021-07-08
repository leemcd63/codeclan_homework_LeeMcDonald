/* MVP

Question 1.
Are there any pay_details records lacking both a local_account_no and iban number? */

SELECT 
	COUNT(*) AS total_missing
FROM pay_details
WHERE local_account_no IS NULL 
AND iban IS NULL;

/* Question 2.
Get a table of employees first_name, last_name and country, 
ordered alphabetically first by country and then by last_name (put any NULLs last). */

SELECT 
	first_name,
	last_name,
	country
FROM employees
ORDER BY country, last_name;

/* Question 3.
Find the details of the top ten highest paid employees in the corporation. */

SELECT
	*
FROM employees
ORDER BY salary DESC NULLS LAST
LIMIT 10;

/* Question 4.
Find the first_name, last_name and salary of the lowest paid employee in Hungary. */

SELECT 
	first_name,
	last_name,
	salary
FROM employees 
WHERE country = 'Hungary'
ORDER BY salary ASC NULLS LAST 
LIMIT 1;

/* Question 5.
Find all the details of any employees with a ‘yahoo’ email address? */

SELECT 
	*
FROM employees 
WHERE email ILIKE '%yahoo%';

/* Question 6.
Obtain a count by department of the employees who started work with the corporation in 2003. */

SELECT 
	department,
	COUNT(id) AS num_employees
FROM employees 
WHERE start_date BETWEEN '2003-01-01' AND '2003-12-31'
GROUP BY department;

/* Question 7.
Obtain a table showing department, fte_hours and the number of employees 
in each department who work each fte_hours pattern. Order the table alphabetically 
by department, and then in ascending order of fte_hours. 

Hint
You need to GROUP BY two columns here. */

SELECT 
	department,
	fte_hours,
	COUNT(id) AS employee_count
FROM employees
GROUP BY department, fte_hours
ORDER BY department, fte_hours ASC;

/* Question 8.
Provide a breakdown of the numbers of employees enrolled, not enrolled, and 
with unknown enrollment status in the corporation pension scheme. */

SELECT 
	pension_enrol,
	COUNT(id) AS employee_count
FROM employees 
GROUP BY pension_enrol;

/* Question 9.
What is the maximum salary among those employees in the ‘Engineering’ 
department who work 1.0 full-time equivalent hours (fte_hours)? */

SELECT 
	MAX(salary) AS highest_salary_engineering
FROM employees 
WHERE department = 'Engineering' AND fte_hours = 1;

/* Question 10.
Get a table of country, number of employees in that country, and the average 
salary of employees in that country for any countries in which more than 30 employees 
are based. Order the table by average salary descending. */

SELECT 
	country,
	COUNT(id) AS employee_count,
	ROUND(AVG(salary), 2) AS average_salary
FROM employees 
GROUP BY country
HAVING SUM(id) > 30
ORDER BY average_salary DESC NULLS LAST;

/* Question 11.
Return a table containing each employees first_name, last_name, full-time equivalent 
hours (fte_hours), salary, and a new column effective_yearly_salary which should contain 
fte_hours multiplied by salary. */

SELECT 
	first_name,
	last_name,
	fte_hours,
	salary,
	fte_hours * salary AS effective_yearly_salary
FROM employees;

/* Question 12.
Find the first name and last name of all employees who lack a local_tax_code. */

SELECT 
	e.first_name,
	e.last_name,
	pd.local_tax_code 
FROM employees AS e INNER JOIN pay_details AS pd 
	ON e.pay_detail_id = pd.id 
WHERE pd.local_tax_code IS NULL;

/* Question 13.
The expected_profit of an employee is defined as (48 * 35 * charge_cost - salary) * fte_hours, 
where charge_cost depends upon the team to which the employee belongs. Get a table showing 
expected_profit for each employee. */

SELECT
	e.first_name,
	e.last_name,
	(48 * 35 * CAST(t.charge_cost AS INT) - e.salary) AS expected_profit
FROM employees AS e INNER JOIN teams AS t 
	ON e.team_id = t.id;
	
/* Question 14.
Obtain a table showing any departments in which there are two or more employees lacking a stored 
first name. Order the table in descending order of the number of employees lacking a first name, 
and then in alphabetical order by department. */

SELECT 
	department,
	COUNT(id) AS spawforth_count
FROM employees
WHERE first_name IS NULL
GROUP BY department
ORDER BY spawforth_count DESC, department ASC; 

/* Question 15.
[Bit Tougher] Return a table of those employee first_names shared by more than one employee, 
together with a count of the number of times each first_name occurs. Omit employees without a 
stored first_name from the table. Order the table descending by count, and then alphabetically by 
first_name. */

SELECT 
	first_name,
	COUNT(DISTINCT(id)) AS name_count
FROM employees
WHERE first_name IS NOT NULL
GROUP BY first_name
HAVING COUNT(DISTINCT(id)) > 1
ORDER BY name_count DESC, first_name ASC;

/* Question 16.
[Tough] Find the proportion of employees in each department who are grade 1. 

Hints
Think of the desired proportion for a given department as the number of employees 
in that department who are grade 1, divided by the total number of employees in that department.

You can write an expression in a SELECT statement, e.g. grade = 1. This would result in BOOLEAN values.

If you could convert BOOLEAN to INTEGER 1 and 0, you could sum them. The CAST() function lets 
you convert data types.

In SQL, an INTEGER divided by an INTEGER yields an INTEGER. To get a REAL value, you need to 
convert the top, bottom or both sides of the division to REAL. */


SELECT 
	department,
	COUNT(id) AS count_employees,
	SUM(CAST(grade = 1 AS INT)) AS count_grade_one,
	SUM(CAST(grade = 1 AS INT)) / CAST(COUNT(id) AS REAL) AS proportion_grade_one
FROM employees
GROUP BY department;

/* Question 17.
[Tough] Get a list of the id, first_name, last_name, department, salary and fte_hours of employees 
in the largest department. Add two extra columns showing the ratio of each employee’s salary to that 
department’s average salary, and each employee’s fte_hours to that department’s average fte_hours.

[Extension - how could you generalise your query to be able to handle the fact that two or more 
departments may be tied in their counts of employees. In that case, we probably don’t want to 
arbitrarily return details for employees in just one of these departments]. 

Hints:
Writing a CTE to calculate the name, average salary and average fte_hours of the largest department 
is an efficient way to do this. 

Another solution might involve combining a subquery with window functions.*/


-- USING CTE (horrible)

WITH top_dept_averages AS (
	SELECT 
		department,
		AVG(salary) AS average_salary,
		AVG(fte_hours) AS average_fte
	FROM employees
	GROUP BY department
	ORDER BY COUNT(id) DESC
	LIMIT 1
)
SELECT
	e.id,
	e.first_name,
	e.last_name,
	e.department,
	e.salary,
	e.fte_hours,
	ROUND(e.salary / tda.average_salary, 2) AS salary_ratio,
	ROUND(e.fte_hours / tda.average_fte, 2) AS fte_ratio
FROM employees AS e INNER JOIN top_dept_averages AS tda
ON e.department = tda.department;

-- USING WINDOW FUNCTIONS AND SUBQUERY (beautiful)

SELECT 
	id,
	first_name,
	last_name,
	department,
	salary,
	fte_hours,
	ROUND(salary / (AVG(salary) OVER ()), 2) AS salary_ratio,
	ROUND(fte_hours / (AVG(fte_hours) OVER ()), 2) AS fte_ratio
FROM employees
WHERE department = (
	SELECT 
		department
	FROM employees
	GROUP BY department
	ORDER BY COUNT(id) DESC
	LIMIT 1
)

/* Question 18.
Have a look again at your table for MVP question 8. It will likely contain a blank cell 
for the row relating to employees with ‘unknown’ pension enrollment status. This is ambiguous: 
it would be better if this cell contained ‘unknown’ or something similar. Can you find a way to do 
this, perhaps using a combination of COALESCE() and CAST(), or a CASE statement?

Hints:
COALESCE() lets you substitute a chosen value for NULLs in a column, e.g. 
COALESCE(text_column, 'unknown') would substitute 'unknown' for every NULL in text_column. 
The substituted value has to match the data type of the column otherwise PostgreSQL will return an error. 

CAST() let’s you change the data type of a column, e.g. CAST(boolean_column AS VARCHAR) will turn 
TRUE values in boolean_column into text 'true', FALSE to text 'false', and will leave NULLs as NULL */

SELECT 
	COALESCE(CAST(pension_enrol AS VARCHAR), 'unknown') AS enrolled_in_pension,
	COUNT(id) AS employee_count
FROM employees 
GROUP BY pension_enrol;

/* Question 19.
Find the first name, last name, email address and start date of all the employees who are members
of the ‘Equality and Diversity’ committee. Order the member employees by their length of service 
in the company, longest first .*/

SELECT
	e.first_name,
	e.last_name,
	e.email,
	e.start_date,
	c.name AS committee
FROM employees AS e INNER JOIN employees_committees AS ec
	ON e.id = ec.employee_id 
	INNER JOIN committees AS c
	ON ec.committee_id = c.id 
WHERE c.name = 'Equality and Diversity'
ORDER BY e.start_date ASC NULLS LAST;

/* Question 20.
[Tough!] Use a CASE() operator to group employees who are members of committees into salary_class 
of 'low' (salary < 40000) or 'high' (salary >= 40000). A NULL salary should lead to 'none' in 
salary_class. Count the number of committee members in each salary_class.

Hints:
You likely want to count DISTINCT() employees in each salary_class 

You will need to GROUP BY salary_class */

WITH employee_classes AS (
	SELECT 
		e.id,
		CASE
			WHEN e.salary < 40000 THEN 'Low'
			WHEN e.salary >= 40000 THEN 'High'
			ELSE 'None'
		END salary_class
	FROM employees AS e INNER JOIN employees_committees AS ec 
		ON e.id = ec.employee_id
)
SELECT
	salary_class,
	COUNT(DISTINCT(id)) AS employee_count
FROM employee_classes
GROUP BY salary_class;




