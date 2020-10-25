USE sakila;

SELECT max(rental_date) FROM rental;

-- films, Actors been in more than 1 film (view)	, rental_rate, rented_last_month, 
-- Finding ttl number of rentals for all time
SELECT f.film_id, f.rental_rate, special_features, COUNT(r.rental_id) AS ttl_rentals FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
RIGHT JOIN film f ON f.film_id = i.film_id
GROUP BY f.film_id
ORDER BY f.film_id ASC
LIMIT 5000;

-- Number of actors been in more than 5 films
SELECT actor_id, COUNT(*) AS num_of_films FROM film_actor
GROUP BY actor_id
HAVING num_of_films > 5
ORDER BY num_of_films DESC;

-- Experience table
CREATE OR REPLACE VIEW actor_experience AS
SELECT actor_id, COUNT(*) AS num_of_films FROM film_actor
GROUP BY actor_id
ORDER BY num_of_films DESC;

-- view check
SELECT * FROM actor_experience;

-- "Experience Table" Creation
WITH cte_act AS (SELECT * FROM actor_experience)
SELECT f.film_id, sum(act.num_of_films) AS film_experience FROM cte_act act
JOIN film_actor fa ON fa.actor_id = act.actor_id
RIGHT JOIN film f ON f.film_id = fa.film_id
GROUP BY f.film_id
ORDER BY film_experience DESC;

-- result check using film_id = 508 (film_experience = 440)
SELECT actor_id, film_id FROM film_actor 
WHERE film_id = 508;

-- creating monthly breakdown of rentals
SELECT f.film_id, COUNT(r.rental_id) AS ttl_rentals, 
CONVERT(r.rental_date, date) AS date_of_rental,
DATE_FORMAT(CONVERT(r.rental_date, date), '%m') AS month_of_rental,
DATE_FORMAT(CONVERT(r.rental_date, date), '%Y') AS year_of_rental
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
RIGHT JOIN film f ON f.film_id = i.film_id
GROUP BY f.film_id;

-- create view "monthly_rentals"
CREATE OR REPLACE VIEW monthly_rentals AS
SELECT f.film_id, COUNT(r.rental_id) AS ttl_rentals, 
CONVERT(r.rental_date, date) AS date_of_rental,
DATE_FORMAT(CONVERT(r.rental_date, date), '%m') AS month_of_rental,
DATE_FORMAT(CONVERT(r.rental_date, date), '%Y') AS year_of_rental
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
RIGHT JOIN film f ON f.film_id = i.film_id
GROUP BY f.film_id
;

-- "monthly_rentals" view check
SELECT * FROM monthly_rentals; 

-- Creating last month table
WITH cte_monthly_rentals AS (
SELECT film_id, lag(ttl_rental,1) OVER (PARTITION BY month_of_rental) AS last_month FROM monthly_rentals)
SELECT * FROM cte_monthly_rentals;
