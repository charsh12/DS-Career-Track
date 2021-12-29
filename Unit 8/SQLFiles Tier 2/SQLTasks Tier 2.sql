/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
select name from facilities where membercost > 0.0;

/* Q2: How many facilities do not charge a fee to members? */
select name from facilities where membercost = 0.0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

select facid, name, membercost, monthlymaintenance
  from facilities
  where  membercost < monthlymaintenance * 0.2
    AND membercost > 0.0;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
  FROM facilities
 WHERE facid between 1 and 5;

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
        case when monthlymaintenance > 100 THEN 'expensive'
            else 'cheap' end label
  FROM facilities ;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
  FROM members
 WHERE memid = (
                SELECt max(memid)
                  FROM members );

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT
      f.name,
      m.firstname||' '||m.surname AS MEMBER_NAME
  FROM members m
  INNER JOIN bookings b
    ON m.memid = b.memid
  INNER JOIN facilities f
    ON b.facid = f.facid
WHERE f.name like 'Tennis Court%'
 ORDER BY MEMBER_NAME;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT
      f.name as facilityname
     , m.firstname||' '||m.surname membername
     , case when m.memid = 0 then guestcost * slots
         else membercost * slots end  cost
  FROM members m
 INNER JOIN bookings b
    ON m.memid = b.memid
 INNER JOIN facilities f
    ON b.facid = f.facid
 WHERE STRFTIME('%Y-%m-%d', STARTTIME) ='2012-09-14'
  AND cost > 30
 order by cost desc ;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT
      f.name as facilityname
     , mb.membername
     , case when mb.memid = 0 then guestcost * slots
         else membercost * slots end  cost
  FROM (
           SELECT m.firstname || ' ' || m.surname membername
                , m.memid
                , b.facid
                , b.slots
           FROM members m
                    INNER JOIN bookings b
                               ON m.memid = b.memid
           WHERE STRFTIME('%Y-%m-%d', STARTTIME) = '2012-09-14'
       )mb
 INNER JOIN facilities f
    ON mb.facid = f.facid
  AND cost > 30
 order by cost desc;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
      f.name as facilityname
     , sum(case when b.memid = 0 then guestcost * slots
         else membercost * slots end ) total_cost
  FROM  bookings b
 INNER JOIN facilities f
    ON b.facid = f.facid
group by f.name
having total_cost < 1000
order by total_cost desc;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
select
        m.surname||','||m.firstname as mem_nm, r.surname||','||r.firstname as recomemenders_nm
  from members m
  left join members r
    on m.recommendedby  = r.memid
order by mem_nm , recomemenders_nm;


/* Q12: Find the facilities with their usage by member, but not guests */
select f.name
    , count(distinct m.memid) member_count
 from members m
 join bookings b
  on b.memid = m.memid
 join facilities f
   on f.facid = b.facid
 where m.memid != 0
 group by f.name;

/* Q13: Find the facilities usage by month, but not guests */
select f.name
    , strftime('%m', starttime) month
    , count(1)
 from members m
 join bookings b
  on b.memid = m.memid
 join facilities f
   on f.facid = b.facid
 where m.memid != 0
 group by f.name, month;
