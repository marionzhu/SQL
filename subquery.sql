-- NESTED QUERY
-- List all movies with more than 5 views using a nested query which is a powerful tool to implement selection conditions.
SELECT *
FROM movies
WHERE movie_id IN  -- Select movie IDs from the inner query
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5)

-- List all customer information for customers who rented more than 10 movies.
SELECT *
FROM customers
WHERE customer_id IN            -- Select all customers with more than 10 movie rentals
	(SELECT customer_id
	FROM renting
	GROUP BY customer_id
	HAVING count(*) >10);

-- Report a list of movies with rating above average.
SELECT title -- Report the movie titles of all movies with average rating higher than the total average
FROM movies
WHERE movie_id IN
	(SELECT movie_id
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) > 
		(SELECT AVG(rating)
		 FROM renting));





-- CORRELATED NESTED QUERIES
-- A new advertising campaign is going to focus on customers who rented fewer than 5 movies. 
-- Use a correlated query to extract all customer information for the customers of interest.
SELECT *
FROM customers as c
WHERE 5> 
	(SELECT count(*)
	FROM renting as r
	WHERE r.customer_id = c.customer_id);

-- Report a list of customers with minimum rating smaller than 4.
SELECT *
FROM customers as c
WHERE 4> -- Select all customers with a minimum rating smaller than 4 
	(SELECT MIN(rating)
	FROM renting AS r
	WHERE r.customer_id = c.customer_id);

-- report all movies with more than 5 ratings and all movies with an average rating higher than 8
SELECT *
FROM movies as m
WHERE 5 <  -- Select all movies with more than 5 ratings
	(SELECT count(rating)
	FROM renting as r
	WHERE m.movie_id = r.movie_id);

SELECT *
FROM movies AS m
WHERE 8< -- Select all movies with an average rating higher than 8
	(SELECT AVG(rating)
	FROM renting AS r
	WHERE r.movie_id = m.movie_id);




-- QUERRY WITH EXISTS
-- Make a list of customers who gave at least one rating.
SELECT *
FROM customers AS c -- Select all customers with at least one rating
WHERE exists
	(SELECT *
	FROM renting AS r
	WHERE rating IS NOT NULL 
	AND r.customer_id = c.customer_id);

-- same question we can write in a nested query
SELECT *
FROM customers
	WHERE customer_id IN
	(SELECT c.customer_id
	FROM customers AS c
	LEFT JOIN renting AS r
		ON c.customer_id = r.customer_id
	GROUP BY c.customer_id
	HAVING count(rating) >=1) 


--  report a list of actors who play in comedies and then, the number of actors for each nationality playing in comedies.
-- Create a list of all actors who play in a Comedy. 
SELECT *
FROM actors as a
WHERE exists
	(SELECT *
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy')


SELECT a.nationality, count(*) -- Report the nationality and the number of actors for each nationality
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP BY a.nationality;



-- UNION AND INTERSECT

