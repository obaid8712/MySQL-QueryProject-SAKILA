-- Start to use sakila database
USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT UPPER(first_name),UPPER(last_name) FROM actor ;
-- Disable Safe Update mood
SET SQL_SAFE_UPDATES=0;
-- 1b. Display the first and last name of each actor in a single column in upper case letters.
-- Name the column Actor Name.
ALTER TABLE actor DROP COLUMN actor_name;
ALTER TABLE actor ADD actor_name VARCHAR(90);
UPDATE actor SET actor_name=CONCAT(UPPER(`first_name`)," " , UPPER(`last_name`));
SELECT * FROM actor;
-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id,first_name,last_name FROM actor WHERE first_name LIKE "%Joe%";
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id,first_name,last_name FROM actor WHERE last_name LIKE "%GEN%";
-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_id,first_name,last_name FROM actor WHERE last_name LIKE "%LI%"
ORDER BY last_name,first_name;
-- 2d. display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id,country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
-- 3a. create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor ADD description BLOB;
SELECT * FROM actor;
-- Binary Large OBjects(BLOB)
-- Holds a variable length string (VARCHAR)
-- 3b. Delete the description column
ALTER TABLE actor DROP COLUMN description;
SELECT * FROM actor;
-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name FROM actor;
SELECT COUNT(last_name) FROM actor;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name FROM actor GROUP BY last_name HAVING COUNT(last_name)>1;
-- SELECT COUNT(last_name) FROM actor GROUP BY last_name HAVING COUNT(last_name)>1;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
-- SELECT * FROM actor WHERE last_name ='WILLIAMS' AND first_name ='GROUCHO';
SELECT * FROM actor WHERE first_name ='GROUCHO';
UPDATE actor SET first_name='HARPO' WHERE last_name ='WILLIAMS' AND first_name ='GROUCHO';
SELECT * FROM actor WHERE last_name ='WILLIAMS';
-- 4d. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE actor SET first_name='GROUCHO' WHERE last_name ='WILLIAMS' AND first_name ='HARPO';
SELECT * FROM actor WHERE last_name ='WILLIAMS';
-- 5a. locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address ;

select * from information_schema.columns 
where table_name = 'address' and table_schema = 'sakila';

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member
SELECT staff.first_name,staff.last_name,address.address
FROM staff
INNER JOIN address ON staff.address_id=address.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005
-- SELECT * FROM payment;
-- SELECT * FROM staff;
-- WHERE payment.payment_date like '2005-08%'
-- WHERE payment.payment_date BETWEEN '1/8/2005' AND '31/8/2005'
SELECT staff.first_name,staff.last_name,SUM(payment.amount)
FROM payment
LEFT JOIN staff ON payment.staff_id=staff.staff_id WHERE payment.payment_date BETWEEN '2005-08-01' AND '2005-09-01'
GROUP BY payment.staff_id;
-- 6c. List each film and the number of actors who are listed for that film
-- SELECT * FROM film;
-- SELECT * FROM film_actor WHERE film_id=25;
SELECT film.title,COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system
-- SELECT * FROM film;
-- SELECT * FROM inventory;
SELECT film.title,COUNT(inventory.film_id)
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
WHERE film.title='Hunchback Impossible';
-- GROUP BY film.title;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- SELECT * FROM payment;
-- SELECT * FROM customer;
SELECT customer.first_name,customer.last_name,SUM(payment.amount)
FROM payment
INNER JOIN customer ON payment.customer_id=customer.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- SELECT * FROM language;
-- SELECT * FROM film;
SELECT film.title
	FROM film
    WHERE language_id 
	IN (
		SELECT language_id
        FROM language
        WHERE name = "English" 
        )
	AND film.title LIKE "Q%"
    OR film.title LIKE "K%";
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
  SELECT film_id
  FROM film
  WHERE title = 'Alone Trip'
  )
);
-- 7c the names and email addresses of all Canadian customers. Use joins to retrieve this information
-- SELECT * FROM country;
-- SELECT * FROM customer;
-- SELECT * FROM address;
-- SELECT * FROM city WHERE country_id=20;

SELECT customer.first_name,customer.last_name,customer.email 
FROM customer
INNER JOIN address ON customer.address_id=address.address_id
INNER JOIN city ON address.city_id=city.city_id
INNER JOIN country ON city.country_id=country.country_id
WHERE country='Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- SELECT * FROM category;
-- SELECT * FROM film_category;
-- SELECT * FROM film_text;

SELECT film_text.title,category.name
FROM film_text
INNER JOIN film_category ON film_text.film_id=film_category.film_id
INNER JOIN category ON film_category.category_id=category.category_id
WHERE name='Family';

-- 7e. Display the most frequently rented movies in descending order.
-- SELECT * FROM film_text;
-- SELECT * FROM inventory;
-- SELECT * FROM rental WHERE inventory_id=130;
-- SELECT film_text.title,(rental.inventory_id)
SELECT film_text.title,COUNT(film_text.title)
FROM film_text
INNER JOIN inventory ON film_text.film_id=inventory.film_id
INNER JOIN rental ON inventory.inventory_id=rental.inventory_id
GROUP BY film_text.title
ORDER BY COUNT(film_text.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in
-- SELECT * FROM store;
-- SELECT * FROM address; 
-- SELECT * FROM staff;
-- SELECT * FROM payment;

SELECT address.address,SUM(payment.amount)
FROM address
INNER JOIN store ON address.address_id=store.address_id
INNER JOIN staff ON store.store_id=staff.store_id
INNER JOIN payment ON staff.staff_id=payment.staff_id
GROUP BY address.address;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- SELECT * FROM store;
-- SELECT * FROM address;
-- SELECT * FROM city;
-- SELECT * FROM country;

SELECT store.store_id,address.address,city.city,country.country
FROM store
INNER JOIN address ON store.address_id=address.address_id
INNER JOIN city ON address.city_id=city.city_id
INNER JOIN country ON city.country_id=country.country_id; 




