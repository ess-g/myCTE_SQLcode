-- 1. Per employee, how much revenue has each employee 
-- realized from DVD rentals,
-- and how many transactions have each employee handled?

SELECT 
    staff_id, 
    COUNT(*) as transactions,
    SUM(amount) as revenue  
FROM payment
GROUP BY 1;

-- 2. Figure out the average replacement -----------------------------------------**CORRECT #2**---------------------------------------------------------
-- cost of our movies, by rating.

SELECT 
    rating, 
    ROUND(AVG(replacement_cost), 2) as avg_replcaement_cost
FROM film
GROUP BY 1;

-- 3. Get the customer ID's of the top 5 customers, -----------------------------------------**CORRECT #3**---------------------------------------------------------
-- by money spent.

SELECT 
    customer_id,
    SUM(amount)
FROM payment
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 4. Return the customer IDs of customers who have spent -----------------------------------------**CORRECT #4**---------------------------------------------------------
-- at least $110 with the staff member who has an ID of 2.

SELECT 
    staff_id,
    customer_id,
    SUM(amount) AS customer_spending
FROM payment 
WHERE staff_id = 2
GROUP BY staff_id, customer_id
HAVING SUM(amount) > 110;

-- 5. Find the names and the payment amounts for customers -----------------------------------------**CORRECT #5**---------------------------------------------------------
-- with a lifetime purchase amount of greater than $150.

SELECT 
    c.first_name||' '||c.last_name AS name,
    SUM (amount)
FROM customer c
JOIN payment p 
ON c.customer_id = p.customer_id  
GROUP BY 1
HAVING SUM (amount) > 150
ORDER BY 2 DESC;

-- 6. Which store has served the most customers? ----///////------*******HALF-INCORRECT #6--HALF-INCORRECT #6--HALF-INCORRECT #6--HALF-INCORRECT#6----//////////------***********

SELECT 
    store_id,
    COUNT(customer_id)
FROM customer
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- alternate solution

WITH cte AS 
(
SELECT 
    store_id,
    COUNT(customer_id) cust_count
FROM customer
GROUP BY 1
ORDER BY 2 DESC
)
SELECT *
FROM cte
WHERE cust_count = (SELECT 
                        max(cust_count)
                    FROM cte);


-- 7. Which store has made the most money from renting dvds?-----------------------------------------**CORRECT #7**---------------------------------------------------------

SELECT 
    store_id,
    SUM (amount) AS total_money
FROM customer 
INNER JOIN  payment USING (customer_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- alternate solution

WITH money_per_store AS
(
SELECT 
    store_id,
    SUM (amount) AS total_money
FROM customer 
INNER JOIN  payment USING (customer_id)
GROUP BY 1
)
SELECT store_id, total_money 
FROM money_per_store 
WHERE total_money = (SELECT max(total_money)
                     FROM money_per_store);

-- 8. What is the name and email of the manager of the  store 
-- that has the customer with the highest 
-- lifetime purchase amount?

WITH spending_per_customer AS 
(
SELECT
p.customer_id,    
CONCAT(c.first_name,' ',c.last_name) AS name,
SUM(amount) AS amount_spent
FROM customer c 
JOIN payment p 
    ON c.customer_id = p.customer_id
GROUP BY p.customer_id, name
ORDER BY amount_spent DESC
)
,
max_amount_spent AS
(
SELECT MAX(amount_spent)
FROM spending_per_customer
)
,
best_customer_id AS
(
SELECT customer_id
FROM spending_per_customer
WHERE amount_spent = (SELECT *
                      FROM max_amount_spent)
)
SELECT 
    DISTINCT CONCAT(first_name,' ',last_name),
    email
FROM payment p
JOIN staff s 
    ON s.staff_id = p.staff_id
JOIN store st
    ON s.store_id = st.store_id
WHERE p.customer_id = (SELECT *
                       FROM best_customer_id)
                       
-- If you interpreted the question to mean "find the manager-----------------------------------------**CORRECT #8**---------------------------------------------------------
-- of the store where a customer has spent the most money?"
                       
WITH best_store AS
(
SELECT 
    store_id,
    SUM (amount) AS total_money
FROM customer 
INNER JOIN  payment USING (customer_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
) 
SELECT 
    staff.first_name||' '||staff.last_name,
    email
FROM staff
JOIN best_store USING (store_id);

 -- 9. On average, except for NC-17 films, 
 -- how much does each film rent for, by rating ---------------------------------------------**CORRECT #9**---------------------------------------------------------
 
SELECT 
    rating, 
    ROUND(AVG(rental_rate),2)
FROM film
GROUP BY rating 
HAVING rating != 'NC-17'
ORDER BY 2 DESC;

-- 10. Do NC-17 films rent for more or 
-- less than the average of other films?

WITH average_nc17_rental_rate AS
(
SELECT 
    ROUND(AVG (rental_rate),2) AS nc17_average_price
FROM film f
WHERE rating = 'NC-17'
)
,
comparison_of_averages AS
(
SELECT 
    ROUND(AVG (rental_rate),2) AS non_nc17_average_price,
    (SELECT * FROM average_nc17_rental_rate) AS nc17_average_price
FROM film f
WHERE rating != 'NC-17'
)
SELECT 
    non_nc17_average_price, 
    nc17_average_price, 
    CASE
        WHEN non_nc17_average_price > nc17_average_price 
            THEN 'NC-17 costs less on average'
        WHEN non_nc17_average_price < nc17_average_price 
            THEN 'NC-17 costs more on average'
        ELSE 'NC-17 films cost the same on average'     
    END AS comparison
FROM comparison_of_averages
    
-- Alternate solution depending on meaning of question 

SELECT 
    rating, 
    ROUND (AVG (rental_rate), 2) AS individual_rating_average,
    (SELECT ROUND(AVG(rental_rate),2) FROM film WHERE rating ='NC-17' ) AS NC_17_average,
    CASE 
        WHEN  AVG(rental_rate) > (SELECT AVG(rental_rate) FROM film WHERE rating !='NC-17' ) 
        THEN 'more than NC-17'
        WHEN  AVG(rental_rate) = (SELECT AVG(rental_rate) FROM film WHERE rating !='NC-17' )
        THEN 'equal'
        ELSE  'less than NC-17' 
    END AS NC_17_average_is
FROM film   WHERE rating !='NC-17' GROUP BY 1;

-- 11. When was the first movie rated R rented by each store? 
-- What was the title of the movie?

WITH stores_and_dates AS

(
SELECT 
    inventory.store_id,
    rental.rental_date AS rental_date,
    film.title
FROM film 
INNER JOIN inventory USING (film_id)
JOIN rental USING (inventory_id)
WHERE film.rating = 'R'
ORDER BY 1, 2
) 

,

mindates AS

(
SELECT 
    store_id, 
    MIN (rental_date) AS minimum_date
FROM stores_and_dates
GROUP BY 1
) 

SELECT 
    store_id,
    minimum_date,
    title
FROM mindates 
LEFT JOIN stores_and_dates USING (store_id)
WHERE mindates.minimum_date = stores_and_dates.rental_date;

--alternate solution 

SELECT film.title, film.rating, inventory.store_id, Min(rental.rental_date)
FROM rental
INNER JOIN inventory ON rental.inventory_id=inventory.inventory_id
INNER JOIN film ON inventory.film_id=film.film_id
WHERE film.rating='R'
GROUP BY 1,2,3
ORDER BY 4
LIMIT 2;


-- 12. Which store has made more money from all movies 
-- except those rated R and NC-17? How much money has each made?

WITH store_money AS
(
SELECT 
    inventory.store_id,
    film.rating,
    ROUND(SUM (payment.amount),2) AS revenue
FROM film
INNER JOIN inventory USING(film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN payment USING (rental_id)
WHERE rating NOT IN ('NC-17', 'R')
GROUP BY 1, 2
ORDER BY 1, 3
) 

SELECT store_id, SUM (revenue) AS total_revenue
FROM store_money
GROUP BY 1;

-- alternate solution

SELECT inventory.store_id, SUM(payment.amount)
FROM inventory
INNER JOIN film USING (film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN payment USING (rental_id)
WHERE film.rating NOT IN ('R', 'NC-17')
GROUP BY 1;



-- 13. What is the date of the first time each customer rented a movie from our store? 
-- What movie did they rent? How much did they pay for it?


SELECT 
    rental.customer_id, 
    mindate.minrental_date, 
    film.title, 
    film.rental_rate
FROM film 
INNER JOIN inventory ON film.film_id=inventory.film_id
INNER JOIN rental ON inventory.inventory_id=rental.inventory_id
INNER JOIN (SELECT 
                rental.customer_id, 
                MIN(rental.rental_date) AS minrental_date
            FROM rental
            GROUP BY 1
            ORDER BY 1) AS mindate ON mindate.minrental_date=rental.rental_date
ORDER BY 1;


-- 14. When is Academy Dinosaur due

SELECT 
    r.rental_id,
    f.title,
    r.rental_date :: date,
    f.rental_duration,
    r.rental_date :: date + f.rental_duration AS due_date
FROM rental r 
JOIN inventory i 
ON r.inventory_id = i.inventory_id 
JOIN film f 
ON i.film_id = f.film_id 
WHERE f.title = 'Academy Dinosaur' AND return_date IS NULL 