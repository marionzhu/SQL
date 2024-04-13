-- table partitioning
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

