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
-- Summarize the distribution of the number of questions with the tag "dropbox" on Stack Overflow per day by binning the data.
-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), 
       -- keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower 
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;



 -- CORRELATION
 -- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;



-- MEAN AND MEDIAN
-- Compute the mean (avg()) and median assets of Fortune 500 companies by sector.
SELECT sector,
       -- Select the mean of assets with the avg function
       avg(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 GROUP BY sector
 ORDER BY mean;



-- CREATE TEMPORARY TABLES
-- Find the Fortune 500 companies that have profits in the top 20% for their sector (compared to other Fortune 500 companies).
-- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

SELECT title, profit80.sector, 
       fortune500.profits, profits/pct80 AS ratio 
  FROM fortune500 
       LEFT JOIN profit80
       ON profit80.sector=fortune500.sector
 WHERE profits > pct80;



-- The Stack Overflow data contains daily question counts through 2018-09-25 for all tags, but each tag has a different starting date in the data.
-- Find out how many questions had each tag on the first date for which data for the tag is available, 
-- as well as how many questions had the tag on the last day. Also, compute the difference between these two values.

-- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
-- Select tag (Remember the table name!) and mindate
SELECT startdates.tag, 
       mindate, 
       -- Select question count on the min and max days
	   so_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       -- Compute the change in question_count (max- min)
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       -- Join startdates to stackoverflow with alias so_min
       INNER JOIN stackoverflow AS so_min
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       INNER JOIN stackoverflow AS so_max
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';


