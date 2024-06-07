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

