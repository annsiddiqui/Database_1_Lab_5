/*
Name: Qurrat-al-Ain Siddiqui (Ann Siddiqui)
Date: November 27th, 2018
Date Submitted: Monday, December 10th, 2018
Course: COMP 2521-001
Lab 4: Advanced Queries - OUTER JOINS (and INNER) and Sub-queries
Instructor: Shoba Ittyipe
*/

/* Excercise 1 */

--1, 2
/* #1: Creating the script */
/* #2: Creating a stored procedure to add an author into the
database as follows: */
DROP PROCEDURE add_author;
     delimiter $$
     CREATE PROCEDURE add_author
     (
        IN id CHAR(11),
        IN last VARCHAR(40),
        IN first VARCHAR(20)
)
BEGIN
INSERT INTO author (au_id, au_lname, au_fname)
VALUES (id, last, first);
     END$$
delimiter ;

--3
/* Calling the procedure */
CALL add_author('300', 'Collins', 'Suzanne');
CALL add_author('400', 'Ittyipe', 'Shoba');

--4
/* Writing a SELECT statement to retrieve the rows inserted. */
SELECT *
FROM author;

--5
/* Creating a stored procedure to add titles in db */
DROP PROCEDURE add_title;
    delimiter $$
    CREATE PROCEDURE add_title
    (
       IN tit_id CHAR(6),
       IN tit_name VARCHAR(80),
       IN publisher CHAR(4)
    )
    BEGIN
    INSERT INTO title (title_id, title, pub_id)
            VALUES (tit_id, tit_name, publisher);
    ENDS$$
    delimiter ;

--6
/* Calling the procedure */
CALL add_title ("123", "About Life", "0877");
CALL add_title ("789", "Udacity", "1389");

--7
/* Writing a SELECT statement to retrieve the rows inserted.
For simplicity sake, only the NOT NULL fields are populated. */
SELECT *
FROM author
WHERE phone IS NOT NULL;

--8
/* Creating a function find_title() to return the title_id
when name of title is provided. */
DROP FUNCTION find_title;
delimiter $$
CREATE FUNCTION find_title(titleName CHAR(80))
        RETURNS char(6)
     BEGIN
       DECLARE id CHAR(6);
       SELECT title_id
       INTO id
       FROM title WHERE title = titleName;
       return id;
     END$$
     delimiter ;

--9
/* Execute the statement by following statement. */
SELECT find_title ("About Life") as id;

--10
/* Now, we want to create a record in the AUTHOR_TITLE table using a
stored procedure. Study the table to see what this contains.
Retrieve the records from this table and order it by title_id and
au_ord and observe the data on this table. */
SELECT *
FROM author_title
ORDER BY title_id;

--11
/* Now, create a procedure addAuthorTitle to add a record into this
table. Make use of the above function to find the title_id of the
title, given the title’s name. */
DROP PROCEDURE addAuthorTitle;
delimiter $$
CREATE PROCEDURE addAuthorTitle(
IN auNbr CHAR(11),
IN titleName VARCHAR(80),
IN ordering DECIMAL(3,0),
IN royalty decimal(6,2))
BEGIN
  DECLARE aid INT;
  INSERT INTO author_title (au_id, title_id, au_ord, royaltyshare)
    VALUES (auNbr, find_title(titleName), ordering, royalty);
ENDS$$
delimiter ;

--12
/* Calling above procedure with following statements */
CALL addAuthorTitle(300, "About Life", 1, 0.6);
CALL addAuthorTitle(400, "About Life", 2, 0.4);

--13
/* Writing a SELECT statement to retrieve the author last name,
first name and the title’s name, the author order and the
royalty share of each individual author for the title “About Life”. */
SELECT s1.au_lname, s1.au_fname, s2.title, s3.royaltyshare, s3.au_ord
FROM author s1, title s2, author_title s3
WHERE s3.title_id = s2.title_id
AND s2.title LIKE "About Life"
GROUP BY (s1.au_lname);

--14
/* The following is an example to show OUT variables inside
stored procedures: */
DROP PROCEDURE add_author_check;
     delimiter $$
     CREATE PROCEDURE add_author_check
     (
        IN id CHAR(11),
        IN last VARCHAR(40),
        IN first VARCHAR(20),
        IN a VARCHAR(50),
        OUT b VARCHAR(20)
     )
     BEGIN
     IF a LIKE 'Justin Beiber%' THEN
        SET b = 'Invalid Entry!';
     ELSE
INSERT INTO author (au_id, au_lname, au_fname, address) VALUES (id, last, first, a);
     END IF;
     END$$
     delimiter ;

--15
/* Calling above procedure with following statement: */
CALL add_author_check('11', 'Gomez', 'Selena', 'Justin Beiber', @just);

--16
/* View only the variable of the outcome of above code */
select @just;


/* Excercise 2 */

--1,2
/* #1: Add a CREATE TABLE statement to create a table book_price_audit with columns
a. title_id         char(6)
b. type             char(12)
c. old_price        numeric(6,2)
d. new_price        numeric(6,2) */
/* #2: Do not define a primary key. A primary key is usually not defined for a table
that is simply used to log or transfer data.*/
CREATE TABLE book_price_audit
  (title_id char(6) NOT NULL,
  type char(12),
  old_price numeric(6,2),
  new_price numeric(6,2)
) ENGINE INNODB;


--3, 4, 5, 6, 7, 8
/* #3: * Trigger syntax */

/* #4: Create a trigger on the TITLE table to insert a row in the
BOOK_PRICE_AUDIT table whenever a price is increased by 10% or more.*/

/* #5: Name the trigger audit_book_price_BUR. From the naming convention,
try and understand the operation, level and timing of the trigger.
Thus, it is to be defined as a before update row trigger. */

/* #6: Code the trigger on TITLE as follows:
        delimiter $$
        CREATE TRIGGER audit_book_price_BUR
        BEFORE UPDATE
        ON title
        FOR EACH ROW
        BEGIN
           IF (new.price / old.price >= 1.1) THEN
              INSERT INTO book_price_audit
VALUES(new.title_id, new.type, old.price, new.price); END IF;
        END$$
        delimiter ;
*/

/* #7: It is always good to drop a trigger before you create one using the
statement below:
    drop trigger audit_book_price_BUR;
*/

/* #8: The insert statement in the trigger

insert into book_price_audit
values (new.title_id, new.type, old.price, new.price);

is coded within the body of the trigger. A trigger operates internally
on tables in the database and no COMMIT is required. */
drop trigger audit_book_price_BUR;

delimiter $$
        CREATE TRIGGER audit_book_price_BUR
        BEFORE UPDATE
        ON title
        FOR EACH ROW
        BEGIN
           IF (new.price / old.price >= 1.1) THEN
              INSERT INTO book_price_audit
VALUES(new.title_id, new.type, old.price, new.price); END IF;
        END$$
        delimiter ;

--9, 10, 11
/*
#9: If no error is returned from the database server,
then the trigger has been successfully complied and stored in the database.

#10: This trigger will be executed whenever a user increases a
book price by more than 10%. The DBMS will fire the trigger.

#11: Change the price of the title of PC8888 from $20.00 to $21.00
(less than 10%) and the price of the title BU1032 from $19.99 to $25.00
(10% or more).
*/

UPDATE title
SET price= 21
WHERE title_id='PC8888';

UPDATE title
SET price= 25
WHERE title_id='BU1032';

--12
/* Using SQL, display the data in the BOOK_PRICE_AUDIT table to
verify that one audit record has been written. */
SELECT *
FROM book_price_audit;

/* Exercise 3 */

--1
/* Code the trigger on BOOK_PRICE_AUDIT as follows: */
create trigger generate_audit_nbr_BIR before insert
on BOOK_PRICE_AUDIT
        for each row
        BEGIN
           /* Find the current sequence number */
           /* Set the new number.
        END;
/* Therefore, the insert statement on TITLE table written in Exercise 1 now has
to be changed to
insert into book_price_audit (title_id, type, old_price, new_price) values
(new.title_id, new.type,
old.price, new.price);
Drop the old trigger on TITLE and create a new one applying the change.  */

drop trigger generate_audit_nbr_BIR;

delimiter $$
CREATE TRIGGER generate_audit_nbr_BIR
BEFORE INSERT
ON book_price_audit
  FOR EACH ROW
  BEGIN
    DECLARE nextnum INT;
    DECLARE rows INT;
  END$$
  delimiter ;


--2
/* #2: Now using SQL, change three prices of titles, two of them increase
by 10% or more and one by less than 10%. Then use SQL to examine the
BOOK_PRICE_AUDIT table. Observe the generated sequence in the audit_nbr column.*/

DROP PROCEDURE add_title;
  delimiter $$
  CREATE PROCEDURE add_title
  (
    IN tit_id CHAR(6),
    IN tit_name VARCHAR (80),
    IN publisher CHAR (4)
  )
  BEGIN
    INSERT INTO book_price_audit(title_id, type, old_price, new_price)
    values (new.title_id, new.type, old.price, new.price);
  END$$
delimiter ;

UPDATE title
SET price = price * 1.1
WHERE title_id = "BU1032";

UPDATE title
SET price = price * 1.1
WHERE title_id = "BU1738";

UPDATE title
SET price = price * 0.90
WHERE title_id = "BU1621";

/* Exercise 4 */

--1, 2
/* #1, #2: ALTER TABLE commands.
It is wise to re-run the statement once
again to ensure that the total_income is now becomes up-to-date. */
UPDATE title;
SET total_income = price * ytd_sales;

--3
/* #3: Examine the table to ensure that values for the total_income
field have been reset to newly computed values adhering to the updates
which were done earlier to the price column.

Code a SELECT statement to display the price, ytd_sales and total_income
for the records with title_id equal to BU1111 or MC2222.*/
SELECT total_income, price, ytd_sales, title_id
FROM title
WHERE title_id = "BU1111"
OR title_id = "MC2222";

--4
/* #4: Ideally, the total_income should get computed when either the price
or the ytd_sales change in order to maintain consistent data. To do this,
drop the old trigger on TITLE and create a new one applying the change.
Include code (you can modify the earlier code) to update the total_income
column when either the price or the ytd_sales columns change. */
drop trigger audit_book_price_BUR;

delimiter $$
  CREATE TRIGGER audit_book_price_BUR
  BEFORE UPDATE
  ON title
  FOR EACH ROW
  BEGIN
    IF(new.price / old.price >= 1.1) THEN
    INSERT INTO book_price_audit
    VALUES(new.title_id, new.type, old.price, new.price); END IF;
  END$$
delimiter ;

--5
/* #5: For the book MC2222, change the year-to-date sales from 2032 to 4000
and for the book BU1111, change the price from $11.95 to $21.99. */
UPDATE title
SET ytd_sales = 4000
WHERE title_id = "MC2222";

UPDATE title
SET ytd_sales = 21.99
WHERE title_id = "BU1111";

--6
/* #6: Code a SELECT statement to display the price, ytd_sales and
total_income for the records with title_id equal to BU1111 or MC2222 to
view the change.*/
SELECT total_income, price, ytd_sales, title_id
FROM titles
WHERE title_id = "BU1111"
OR title_id = "MC2222";

/* Enabling & Disabling a Trigger */
alter trigger <trigger_name> enable;
alter trigger <trigger_name> disable;
--ALTER TRIGGER can also be used to enable a trigger.
