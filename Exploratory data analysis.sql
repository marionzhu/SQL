-- COALESCE AND SELFJOIN
-- In the fortune500 data, industry contains some missing values. 
-- Use coalesce() to use the value of sector as the industry when industry is NULL. Then find the most common industry.
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       count(*) 
  FROM fortune500 
 GROUP BY industry2
 ORDER BY count(*) desc  
 LIMIT 1;

-- You previously joined the company and fortune500 tables to find out which companies are in both tables. 
-- Now, also include companies from company that are subsidiaries of Fortune 500 companies as well.
-- To include subsidiaries, you will need to join company to itself to associate a subsidiary with its parent company's information. 
-- To do this self-join, use two different aliases for company.
SELECT company_original.name, title, rank
  -- Start with original company information
  FROM company AS company_original
       -- Join to another copy of company with parent
       -- company information
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       -- Join to fortune500, only keep rows that match
       INNER JOIN fortune500 
       -- Use parent ticker if there is one, 
       -- otherwise original ticker
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 -- For clarity, order by rank
 ORDER BY rank; 




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




-- Compute the correlations between each pair of profits, profits_change, and revenues_change from the Fortune 500 data.
DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       ROUND(profits::numeric,2) AS profits,
       ROUND(profits_change::numeric,2) AS profits_change,
       ROUND(revenues_change::numeric,2) AS revenues_change
  FROM correlations;



-- exploring catagorical data and unstructured text
-- CASE AND SPACE 
-- TRIM/ LTRIM/ RTRIM
-- Trim digits 0-9, #, /, ., and spaces from the beginning and end of street.
 SELECT distinct street,
       -- Trim off unwanted characters from street
       trim(street, '0123456789 #/.') AS cleaned_street
  FROM evanston311
 ORDER BY street;




--Use ILIKE to count rows in evanston311 where the description contains 'trash' or 'garbage' regardless of case.
SELECT  Count(*)
  FROM evanston311
 -- Where description includes trash or garbage
 WHERE description ilike '%trash%'
  OR description ilike '%garbage%';
  

-- Count rows where the description includes 'trash' or 'garbage' but the category does not.
SELECT Count(*)
  FROM evanston311 
 -- description contains trash or garbage (any case)
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
 -- category does not contain Trash or Garbage
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%';





-- SPLITTING AND CONCATENATING TEXT
-- -- Concatenate house_num, a space, and street
-- and trim spaces from the start of the result
SELECT LTRIM(CONCAT(house_num, ' ', street)) AS address
  FROM evanston311;

-- Use split_part() to select the first word in street; alias the result as street_name.
-- Also select the count of each value of street_name.

-- Select the first word of the street value
SELECT SPLIT_PART(street, ' ', 1) AS street_name, 
       count(*)
  FROM evanston311
 GROUP BY street_name
 ORDER BY count DESC
 LIMIT 20;


 -- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN LEFT(description, 50) || '...'
       -- otherwise just select description
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description LIKE 'I %'
 ORDER BY description;





 -- MULTIPLE TRASFORMATION
 -- Create recode with a standardized column; use split_part() and then rtrim() to remove any remaining whitespace on the result of split_part().
 -- Fill in the command below with the name of the temp table
DROP TABLE IF EXISTS recode;

-- Create and name the temporary table
CREATE TEMP TABLE recode AS
-- Write the select query to generate the table 
-- with distinct values of category and standardized values
  SELECT DISTINCT category, 
         RTRIM(SPLIT_PART(category, '-', 1)) AS standardized
    -- What table are you selecting the above values from?
    FROM evanston311;

-- Look at a few values before the next step
SELECT DISTINCT standardized 
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';

-- Update to group trash cart values
UPDATE recode 
   SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';

-- Update to group snow removal values
UPDATE recode 
   SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';
    
-- Examine effect of updates
SELECT DISTINCT standardized 
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';

-- Update to group unused/inactive values
UPDATE recode 
   SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart',
  '(DO NOT USE) Water Bill', 
  'DO NOT USE Trash',
  'NO LONGER IN USE');

-- Examine effect of updates
SELECT DISTINCT standardized 
  FROM recode
 ORDER BY standardized;

 -- Select the recoded categories and the count of each
SELECT recode.standardized, count(*)
-- From the original table and table with recoded values
  FROM evanston311
       LEFT JOIN recode 
       -- What column do they have in common?
       ON evanston311.category = recode.category 
 -- What do you need to group by to count?
 GROUP BY recode.standardized
 -- Display the most common val values first
 ORDER BY count(*) DESC;




 -- Create a table with indicator variables
 -- Create a temp table indicators from evanston311 with three columns: id, email, and phone.
-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the indicators temp table
CREATE TEMP TABLE indicators AS
  -- Select id
  SELECT id, 
         -- Create the email indicator (find @)
         CAST (description LIKE '%@%' AS integer) AS email,
         -- Create the phone indicator
         CAST (description LIKE '%___-___-____%' AS integer) AS phone 
    -- What table contains the data? 
    FROM evanston311;

-- Inspect the contents of the new temp table
SELECT *
  FROM indicators;


-- Select the column you'll group by
SELECT priority,
       -- Compute the proportion of rows with each indicator
       SUM(email)/COUNT(*)::numeric AS email_prop, 
       SUM(phone)/COUNT(*)::numeric AS phone_prop
  -- Tables to select from
  FROM evanston311
       -- Joining condition
       LEFT JOIN indicators
       ON evanston311.id= indicators.id
 -- What are you grouping by?
 GROUP BY priority;


 

