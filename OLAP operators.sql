-- CUBE
-- Create a table with the total number of male and female customers from each country.
SELECT country, -- Extract information of a pivot table of gender and country for the number of customers
	   gender,
	   count(*)
FROM customers
GROUP BY CUBE (country, gender)
ORDER BY country;


--  List the number of movies for different genres and release years.
SELECT year_of_release,
       genre,
       count(*)
FROM movies
GROUP BY CUBE (year_of_release, genre) 
ORDER BY year_of_release;



-- Prepare a table for a report about the national preferences of the customers from MovieNow comparing the average rating of movies across countries and genres.
SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating -- Calculate the average rating 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY CUBE(c.country, m.genre); -- For all aggregation levels of country and genre



-- ROLLUP
-- Count the total number of customers, the number of customers for each country, and the number of female and male customers for each country
SELECT country,
       gender,
	   COUNT(*)
FROM customers
GROUP BY ROLLUP (country, gender)
ORDER BY country, gender ; -- Order the result by country and gender

-- calculate the average ratings and the number of ratings for each country and genre, as well as an aggregation over all genres for each country and the overall average and total number.
-- Group by each county and genre with OLAP extension
SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating, 
	COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY ROLLUP(C.country, m.genre)
ORDER BY c.country, m.genre;




-- GROUPING SETS
-- Count the number of actors in the table actors from each country, the number of male and female actors and the total number of actors.
SELECT 
	nationality, -- Select nationality of the actors
    gender, -- Select gender of the actors
    count(*) -- Count the number of actors
FROM actors
GROUP BY GROUPING SETS ((nationality), (gender), ()); -- Use the correct GROUPING SETS operation

-- Now you will investigate the average rating of customers aggregated by country and gender.
SELECT 
	c.country, 
    c.gender,
	AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY GROUPING SETS((country, gender)); -- Group by country and gender with GROUPING SETS

-- Report all information that is included in a pivot table for country and gender in one SQL table.
SELECT 
	c.country, 
    c.gender,
	AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
-- Report all info from a Pivot table for country and gender
GROUP BY GROUPING SETS ((country, gender), (country), (gender), ());


-- You just saw that customers have no clear preference for more recent movies over older ones. Now the management considers investing money in movies of the best rated genres.
SELECT m.genre, -- For each genre, calculate:
	   avg(r.rating) AS avg_rating, -- The average rating and use the alias avg_rating
	   count(r.rating) AS n_rating, -- The number of ratings and use the alias n_rating
	   count(r.renting_id) AS n_rentals,     -- The number of movie rentals and use the alias n_rentals
	   COUNT(distinct r.movie_id) AS n_movies -- The number of distinct movies and use the alias n_movies
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 3)
AND r.date_renting >= '2018-01-01'
GROUP BY m.genre;

-- For each combination of the actors' nationality and gender, calculate the average rating, the number of ratings, the number of movie rentals, and the number of actors.
SELECT a.nationality,
       a.gender,
	   avg(r.rating) AS avg_rating, -- The average rating
	   COUNT(r.rating) AS n_rating, -- The number of ratings
	   COUNT(*) AS n_rentals, -- The number of movie rentals
	   COUNT(distinct a.actor_id) AS n_actors -- The number of actors
FROM renting AS r
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >=4 )
AND r.date_renting >= '2018-04-01'
GROUP BY a.nationality, a.gender; -- Report results for each combination of the actors' nationality and gender

-- Provide results for all aggregation levels represented in a pivot table.
SELECT a.nationality,
       a.gender,
	   AVG(r.rating) AS avg_rating,
	   COUNT(r.rating) AS n_rating,
	   COUNT(*) AS n_rentals,
	   COUNT(DISTINCT a.actor_id) AS n_actors
FROM renting AS r
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 4)
AND r.date_renting >= '2018-04-01'
GROUP BY CUBE(a.nationality,a.gender); -- Provide results for all aggregation levels represented in a pivot table

