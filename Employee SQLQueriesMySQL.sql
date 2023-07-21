CREATE database employeeInfo;
USE employeeInfo;
CREATE TABLE Employee (
EmpID int NOT NULL,
EmpName Varchar(30),
Gender Char,
Salary int,
City Char(20) );

INSERT INTO Employee
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura');

CREATE TABLE EmployeeDetail (
EmpID int NOT NULL,
Project Varchar(30),
EmpPosition Char(20),
DOJ date );

INSERT INTO EmployeeDetail
VALUES
(1, 'P1', 'Executive', "2019-01-26"),
(2, 'P2', 'Executive', "2020-05-04"),
(3, 'P1', 'Lead', "2021-10-21"),
(4, 'P3', 'Manager', "2019-11-29"),
(5, 'P2', 'Manager', "2020-08-01");

-- To see all the records of the schema.
SELECT * from employee;
SELECT * from employeeDetail;

-- Q1(a): Find the list of employees whose salary ranges between 2L to 3L.
SELECT * 
FROM employee
WHERE salary BETWEEN '200000' AND '300000';

-- Q1(b): Write a query to retrieve the list of employees from the same city.
SELECT E1.EmpName, E1.City 
FROM employee E1, employee E2
WHERE E1.city = E2.city AND E1.empid != E2.empid;

-- Q1(c): Query to find the null values in the Employee table.
SELECT * 
FROM Employee
WHERE EmpID is Null;

-- Q2(a): Query to find the cumulative sum of employee’s salary.
SELECT empId,empname, salary, SUM(SALARY) OVER (ORDER BY empID) 
AS cumulative_sum  
FROM employee;

-- Q2(b): What’s the male and female employees ratio.

SELECT gender,
COUNT(*) 
FROM Employee
GROUP BY GENDER;

-- Q2(c): Write a query to fetch 50% records from the Employee table.
SELECT * 
FROM employee WHERE empid <= (SELECT COUNT(*)/2 FROM employee);

-- Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’
-- i.e 12345 will be 123XX

SELECT empname, salary, CONCAT(LEFT(SALARY, LENGTH(Salary)-2),"XX") as MaskedSalary 
FROM employee;
SELECT  REPLACE(RIGHT(salary,2),'00','XX') 
FROM employee;

-- Q4: Write a query to fetch even and odd rows from Employee table.

SELECT * FROM employee
WHERE empid%2 = 0;

SELECT * FROM employee
WHERE empid%2 != 0;

SELECT * FROM employee
WHERE MOD(empid,2) = 0;

SELECT * FROM employee
WHERE MOD(empid,2) != 0;

-- using Window function

SELECT * FROM
(SELECT * , row_number()OVER (ORDER BY EmpID) as rn 
FROM employee) A
WHERE rn %2 =0;

SELECT * FROM
(SELECT * , row_number()OVER (ORDER BY EmpID) as rn 
FROM employee) A
WHERE rn %2 !=0;


-- Q5(a): Write a query to find all the Employee names whose name:

-- Begin with ‘A’
-- Contains ‘A’ alphabet at second place
-- Contains ‘Y’ alphabet at second last place
-- Ends with ‘L’ and contains 4 alphabets
-- Begins with ‘V’ and ends with ‘A’
SELECT * from employee
WHERE EmpName LIKE 'A%';
SELECT * from employee
WHERE EmpName LIKE '_A%';
SELECT * from employee
WHERE EmpName LIKE '%Y_';
SELECT * from employee
WHERE EmpName LIKE '----%L';
SELECT * from employee
WHERE EmpName LIKE 'V%A';

-- Q5(b): Write a query to find the list of Employee names which is:
-- starting with vowels (a, e, i, o, or u), without duplicates
--  ending with vowels (a, e, i, o, or u), without duplicates
-- starting & ending with vowels (a, e, i, o, or u), without duplicates


SELECT DISTINCT EmpName from employee
WHERE EmpName LIKE 'a%' or EmpName LIKE 'i%' or EmpName LIKE 'o%'or EmpName LIKE 'u%';


-- ANOTHER METHOD

SELECT * from employee
WHERE LOWER(EmpName) REGEXP '^[aeiou]';

SELECT * from employee
WHERE LOWER(EmpName) REGEXP '[aeiou]$';

SELECT * from employee
WHERE LOWER(EmpName) REGEXP '^[aeiou].*[aeiou]$';

-- 	Q6. Find Nth highest salary from employee table with and without using the
-- TOP/LIMIT keywords.
-- 2nd highest salary 

WITH cte AS
(SELECT *, row_number() OVER (order  by salary desc ) as rn
 FROM employee )
select * from cte where rn =2;

-- Q7(a): Write a query to find and remove duplicate records from a table.
CREATE TABLE EmployeeDup (
EmpID int NOT NULL,
EmpName Varchar(30),
Gender Char,
Salary int,
City Char(20) );
INSERT INTO EmployeeDup
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura');

SELECT EmpId,COUNT(*) from employeeDup
GROUP BY EmpID
HAVING COUNT(EmpID)> 1;

-- DOESN'T works in MySQL
DELETE from EmployeeDup 
WHERE EmpID IN 
(SELECT EmpId from employeeDup
GROUP BY EmpID
HAVING COUNT(*)> 1);


-- USING WINDOW function

SELECT *, ROW_NUMBER() OVER (PARTITION BY EmpId ORDER BY EmpId) as rn  from employeeDup;

-- Deleting duplicates using window function 

 DELETE FROM employeeDup
WHERE EmpId IN (
    SELECT EmpId 
    FROM (
        SELECT EmpId ,
            ROW_NUMBER() OVER (PARTITION BY EmpId  ORDER BY EmpId ) as row_num
        FROM
           employeeDup
    ) AS ranked
    WHERE row_num > 1
);

 DELETE  from EmployeeDup 
 where EmpID In(
 SELECT EmpID FROM 
 (SELECT EmpId ,ROW_NUMBER() OVER (PARTITION BY EmpId  ORDER BY EmpId ) as rn 
 FROM EmployeeDup) A
 where rn >1);

-- -- Q7(b): Query to retrieve the list of employees working in same project.

select * from employee;
select * from employeedetail;

WITH cte as
(SELECT e.empid,e.empname, ed.project from employee e 
INNER JOIN  employeedetail ed
ON e.empid = ed.empid)
SELECT c1.EmpName, c2.EmpName, c2.Project from cte c1, cte c2
WHERE c1.project = c2.project AND c1.empid != c2.empid AND c1.EmpID < c2.EmpId;

-- Q8: Show the employee with the highest salary for each project

-- using aggregate function
SELECT ed.project , MAX(e.salary ) as projectSal
FROM employee e
INNER JOIN employeedetail ed ON E.EMPID = ED.EMPID
GROUP BY e.empid , e.empname, ed.project
ORDER BY projectSal DESC ;

 -- using row_number()
 
 WITH cte_sal AS (
  SELECT e.empid, e.empname, ed.project, ed.Empposition, e.salary,
   ROW_NUMBER() OVER (PARTITION BY ed.project ORDER BY e.salary DESC) AS rn
  FROM employee e
  INNER JOIN employeedetail ed ON e.EMPID = ed.EMPID
)
SELECT *
FROM cte_sal
WHERE rn = 1;

-- Query to find the total count of employees joined each year

  SELECT EXTRACT(YEAR FROM ed.DOJ)  as DOJYEAR, COUNT(*) EmpCount
  FROM employeedetail ed
  GROUP BY DOJYEAR;
  
 -- Q10: Create 3 groups based on salary col, salary less than 1L is low, between 1 -
-- 2L is medium and above 2L is High

SELECT EmpName, salary,
CASE 
  WHEN salary < 100000 THEN 'Low'
  WHEN salary BETWEEN 100000 AND 200000 THEN 'Medium'
else 'High' 
end as Salary_Category
from employee;






