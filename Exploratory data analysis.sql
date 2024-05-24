-- Summarizing and aggragating numeric data
-- Division
-- Compute the average revenue per employee for Fortune 500 companies by sector.

SELECT sector, 
       avg(revenues/employees::numeric) AS avg_rev_employee -- cast integer to numeric 
  FROM fortune500
 GROUP BY sector
 ORDER BY avg_rev_employee;



-- compute unanswered question rate in stackoverflow
 -- Divide unanswered_count by question_count
SELECT unanswered_count/question_count::numeric AS computed_pct, 
       unanswered_pct
  FROM stackoverflow
 -- Select rows where question_count is not 0
 WHERE question_count != 0 
 LIMIT 10 ;



-- Summarize numeric columns
-- summarize profits columns of fortune500
-- Select sector and summary measures of fortune500 profits
SELECT MIN(profits),
       MAX(profits),
       AVG(profits),
       STDDEV(profits),
       sector
FROM fortune500
GROUP BY sector
 -- Order by the average profits
ORDER BY AVG;



-- what is the standard deviation across tags in the maximum number of Stack Overflow questions per day? 
-- What about the mean, min, and max of the maximums as well?
-- Compute standard deviation of maximum values
SELECT MIN(maxval),
	   -- min
       MAX(maxval),
       -- max
       AVG(maxval),
       -- avg
       STDDEV(maxval)
  -- Subquery to compute max of question_count by tag
  FROM (SELECT MAX(question_count) AS maxval
          FROM stackoverflow
         -- Compute max by...
         GROUP BY tag) AS max_results; -- alias for subquery



-- TRUNCATE
-- Use trunc() to truncate employees to the 100,000s (5 zeros).
-- Count the number of observations with each truncated value.
-- Truncate employees
SELECT trunc(employees, -5) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;

-- Repeat step 1 for companies with < 100,000 employees (most common).
-- This time, truncate employees to the 10,000s place.
-- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       Count(*)
  FROM fortune500
 -- Limit to which companies?
 WHERE employees < 100000
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;



-- GENERATE SERIES



