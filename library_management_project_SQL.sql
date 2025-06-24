-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
SELECT 
    *
FROM
    books;
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT 
    *
FROM
    books;

-- Task 2: Update an Existing Member's Address 
SELECT 
    *
FROM
    members;
UPDATE members 
SET 
    member_address = '125 Oak St'
WHERE
    member_id = 'C101';
SELECT 
    *
FROM
    members;

-
-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table .
SELECT 
    *
FROM
    issued_status;
delete from issued_status 
where issued_id='IS121'


-- Task 4 :  Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.


SELECT 
    *
FROM
    issued_status
WHERE
    issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book. 


SELECT 
    issued_emp_id, COUNT(*)
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_issued_count
as 
select b.isbn , b.book_title , count(ist.issued_emp_id) as total_book_issued_count
from books as b 
join issued_status as ist 
on b.isbn=ist.issued_book_isbn
group by b.isbn , b.book_title;

select * from book_issued_count;


-- Data Analysis & Findings

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books;
select isbn , book_title 
from books 
where category = 'classic'  and  rental_price > 4.0;
-- or 
SELECT isbn, book_title 
FROM books 
WHERE category IN ('classic', 'Children');


-- Task 8: Find Total Rental Income by Category:
SELECT * FROM books;

SELECT 
    b.category, SUM(b.rental_price), COUNT(*)
FROM
    books AS b
        JOIN
    issued_status AS ist
    ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;

 -- task 9 : List Members Who Registered in the Last 180 Days:
 SELECT * FROM `library-system-management`.members;

 insert into members(member_id, member_name, member_address, reg_date)
 values 
 ('C120','tony','125 Ota St','2025-06-14'),
 ('C121','andrew','555 Pine St','2025-05-14');
 

 SELECT *
FROM members
WHERE reg_date >= current_date - INTERVAL 180 DAY;

 
 
  --  task 10: List Employees with Their Branch Manager's Name and their branch details::
SELECT * FROM `library-system-management`.employees;
SELECT * FROM `library-system-management`.branch;


SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD :
SELECT * FROM books;

create table  costly_book
as 
select *
from books
where rental_price > 7.0;

select * from  costly_book ;


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM `library-system-management`.issued_status;
SELECT * FROM `library-system-management`.return_status;

SELECT  *
from issued_status as ist
left join return_status as rs
on rs.issued_id=ist.issued_id 
where rs.return_book_name is NULL ;


-- Advanced SQL Operations
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT  ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
     rs.return_date,
     CURRENT_DATE - ist.issued_date as over_dues
from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
join members as m 
on m.member_id = ist.issued_member_id
 left join return_status as rs 
on ist.issued_id=rs.issued_id 
where rs.return_date IS NULL 
and 
(CURRENT_DATE - ist.issued_date)>50
 order by ist.issued_member_id;
 
 
 -- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).
 

SELECT * FROM books;

SELECT * FROM `library-system-management`.issued_status;

UPDATE books 
set status='YES'
where isbn in (
  select ist.issued_book_isbn
  from issued_status as ist
  join return_status as rs 
  on rs.issued_id=ist.issued_id );

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch,
 -- showing the number of books issued, the number of books returned,
 -- and the total revenue generated from book rentals.
 create table branch_reports
 as 
 select bn.*,
 count(ist.issued_id) as number_of_books_issued,
 count(rs.return_id) as number_of_books_returned,
 sum(b.rental_price) as total_revenue_generated 
 from issued_status as ist 
 join books as b
 on b.isbn=ist.issued_book_isbn 
 join employees as e
 on e.emp_id=ist.issued_emp_id
join branch as bn
on e.branch_id=bn.branch_id
left join return_status as rs 
on ist.issued_id = rs.issued_id
group by 1
order by bn.branch_id , bn.manager_id;
 
 select * from  branch_reports;
 
 
--  Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing
--  members who have issued at least one book in the last 2 months.

 create table active_members 
as
SELECT * 
FROM members 
WHERE member_id IN (
    SELECT DISTINCT issued_member_id 
    FROM issued_status 
    WHERE issued_date >= CURDATE() - INTERVAL 2 MONTH
);

select * from active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branc



SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1,2 
order by no_book_issued desc
limit 3

