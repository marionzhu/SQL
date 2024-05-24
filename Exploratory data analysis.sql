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






