-- DATABASE ROLE AND ACCESS CONTROL
-- Create a data scientist role
CREATE ROLE data_scientist;

-- Create a role called marta that has one attribute: the ability to login (LOGIN).
CREATE ROLE Marta LOGIN;

-- Create a role called admin with the ability to create databases (CREATEDB) and to create roles (CREATEROLE).
CREATE ROLE admin WITH CREATEDB CREATEROLE;

-- GRANT privileges and ALTER attributes
-- Grant the data_scientist role update and insert privileges on the long_reviews view.
GRANT UPDATE, INSERT ON long_reviews TO data_scientist;

-- Alter Marta's role to give her the provided password.
ALTER ROLE marta WITH PASSWORD 's3cur3p@ssw0rd';

-- Add a user role to a group role
-- Add Marta to the data scientist group
GRANT data_scientist TO Marta;

-- Remove Marta from the data scientist group
REVOKE data_scientist FROM Marta;





-- DATABASE SCHEMAS AND NORMALIZATION
-- Add foreign keys
-- In the constraint called sales_book, set book_id as a foreign key.
-- In the constraint called sales_time, set time_id as a foreign key.
-- In the constraint called sales_store, set store_id as a foreign key.
-- Add the book_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_book
    FOREIGN KEY (book_id) REFERENCES dim_book_star (book_id);
    
-- Add the time_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_time
    FOREIGN KEY (time_id) REFERENCES dim_time_star (time_id);
    
-- Add the store_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_store
    FOREIGN KEY (store_id) REFERENCES dim_store_star (store_id);

-- Extending the book dimension
-- Create dim_author with a column for author.
-- Insert all the distinct authors from dim_book_star into dim_author
-- Alter dim_author to have a primary key called author_id.
-- Output all the columns of dim_author.
-- Create a new table for dim_author with an author column
CREATE TABLE dim_author (
    author varchar(256)  NOT NULL
);

-- Insert authors 
INSERT INTO dim_author
SELECT DISTINCT author FROM dim_book_star;

-- Add a primary key 
ALTER TABLE dim_author ADD COLUMN author_id SERIAL PRIMARY KEY;

-- Output the new table
SELECT * FROM dim_author;


-- Querying the star schema
-- find the total sales amout for each store
-- Output each state and their total sales_amount
SELECT dim_store_star.state, SUM(fact_booksales.sales_amount)
FROM fact_booksales
	-- Join to get book information
    JOIN dim_book_star ON fact_booksales.book_id = dim_book_star.book_id
	-- Join to get store information
    JOIN dim_store_star ON fact_booksales.store_id = dim_store_star.store_id
-- Get all books with in the novel genre
WHERE  
    dim_book_star.genre = 'novel'
-- Group results by state
GROUP BY
    dim_store_star.state;

-- Querying the snowflake schema
-- find the total sales amout for each store
-- Output each state and their total sales_amount
SELECT dim_state_sf.state, SUM(fact_booksales.sales_amount)
FROM fact_booksales
    -- Joins for genre
    JOIN dim_book_sf on fact_booksales.book_id = dim_book_sf.book_id
    JOIN dim_genre_sf on dim_book_sf.genre_id = dim_genre_sf.genre_id
    -- Joins for state 
    JOIN dim_store_sf on dim_store_sf.store_id = fact_booksales.store_id 
    JOIN dim_city_sf on dim_store_sf.city_id = dim_city_sf.city_id
	JOIN dim_state_sf on  dim_state_sf.state_id = dim_city_sf.state_id
-- Get all books with in the novel genre and group the results by state
WHERE  
    dim_genre_sf.genre = 'novel'
GROUP BY
    dim_state_sf.state;


-- Extending the snowflake schema
-- Add a continent_id column to dim_country_sf with a default value of 1. Note thatNOT NULL DEFAULT(1) constrains a value from being null and defaults its value to 1.
-- Make that new column a foreign key reference to dim_continent_sf's continent_id.
-- Add a continent_id column with default value of 1
ALTER TABLE dim_country_sf
ADD continent_id int NOT NULL DEFAULT(1);

-- Add the foreign key constraint
ALTER TABLE dim_country_sf ADD CONSTRAINT country_continent
   FOREIGN KEY (continent_id) REFERENCES dim_continent_sf(continent_id);
   
-- Output updated table
SELECT * FROM dim_country_sf;





-- TABLE PARTITIONING
-- Create a new table film_descriptions containing 2 fields: film_id, which is of type INT, and long_description, which is of type TEXT.
-- Occupy the new table with values from the film table.
-- Drop the field long_description from the film table.
-- Join the two resulting tables to view the original table.

-- Create a new table called film_descriptions
CREATE TABLE film_descriptions (
    film_id INT,
    long_description TEXT
);

-- Copy the descriptions from the film table
INSERT INTO film_descriptions
SELECT film_id, long_description FROM film;
    
-- Drop the descriptions from the original table
ALTER TABLE film DROP COLUMN long_description;

-- Join to view the original table
SELECT * FROM film_descriptions 
JOIN film USING(film_id);


-- horizontal partitioning
-- Create the table film_partitioned, partitioned on the field release_year.
-- Create three partitions: one for each release year: 2017, 2018, and 2019. Call the partition for 2019 film_2019, etc.
-- Occupy the new table, film_partitioned, with the three fields required from the film table.

-- Create a new table called film_partitioned
CREATE TABLE film_partitioned (
  film_id INT,
  title TEXT NOT NULL,
  release_year TEXT
)
PARTITION BY LIST (release_year);

-- Create the partitions for 2019, 2018, and 2017
CREATE TABLE film_2019
	PARTITION OF film_partitioned FOR VALUES IN ('2019');

CREATE TABLE film_2018
	PARTITION OF film_partitioned FOR VALUES IN ('2018');

CREATE TABLE film_2017
	PARTITION OF film_partitioned FOR VALUES IN ('2017');

-- Insert the data into film_partitioned
INSERT INTO film_partitioned
SELECT film_id, title, release_year FROM film;

-- View film_partitioned
SELECT * FROM film_partitioned;