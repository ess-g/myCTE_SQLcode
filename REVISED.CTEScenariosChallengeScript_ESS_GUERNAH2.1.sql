---CTE (Common table expression) Scenarios Challenge---

--Part 1 ---You have a database containing the following columns
--product_id --product_name --product_category --unit_price

select * from categories;
select * from products;

--Write a CTE that: Calculates THE AVERAGE PRICE PER CATEGORY-- AND returns a table with the following:
--category = the category_name
--number of products in the category = the count of product_id
--average price for that category = the AVG unit_price

with avg_price_per_cat_cte as (
select c.category_name, count(p.product_id) as total_product_count,ROUND(cast(AVG(p.unit_price)as numeric),2) as average_price
from categories c 
join products p on c.category_id = p.category_id 
group by c.category_name
order by total_product_count desc)

---Part 2 ---Use the CTE in a query that determines:
--the category with the MAX AVERAGE PRICE = MAX(AVG)
--And the category name = category_name
--And the COUNT of products in that category = the count of product_id

select category_name, MAX(average_price)
from avg_price_per_cat_cte
group by category

--RESULT combining Part i and part ii---
with avg_price_per_cat_cte as (
select c.category_name, count(p.product_id) as total_product_count,ROUND(cast(AVG(p.unit_price)as numeric),2) as average_price
from categories c 
join products p on c.category_id = p.category_id 
group by c.category_name
order by total_product_count desc)

select * 
from  avg_price_per_cat_cte
where Average_price = (select MAX(average_price) from avg_price_per_cat_cte)









---SCRIPT FROM DENNIS / EOD RECAPS---
-- what is the total $ spent by gmail users in each city?
-- no subquery needed  
SELECT i.BillingCity, sum(i.Total)
FROM Invoice i 
JOIN Customer c ON c.CustomerId = i.CustomerId 
WHERE c.Email LIKE "%gmail%"
GROUP BY i.BillingCity
--
-- what is total $ spent in cities where at least one person uses gmail? 
-- need a subquery to get the list of cities with gmail users 
SELECT i.BillingCity, sum(i.Total)
FROM invoice i
WHERE i.BillingCity IN(
SELECT DISTINCT City  FROM Customer c2  -- this subquery gives us a list OF cities
WHERE Email LIKE "%gmail%" )
GROUP BY BillingCity;
-- 


-- what is the average number of tracks on an album for each genre? 
-- need a subquery to get count of tracks, 
-- then we can get the average of the counts 

SELECT o.Name, avg(o.track_count)
FROM 
(SELECT g.name, a.title, count(t.TrackId) AS track_count
FROM Album a 
JOIN track t ON t.AlbumId = a.AlbumId 
JOIN Genre g ON g.GenreId = t.GenreId 
GROUP BY a.title) AS o 
GROUP BY o.Name
--

--What city has spent the most money at our store? 
SELECT BillingCity, sum(Total)
FROM invoice
GROUP BY BillingCity
ORDER BY sum(Total) DESC 
LIMIT 1
-- not bad, but assumes there will be no tie for 1st place
--
SELECT BillingCity, max(Total)
FROM (SELECT BillingCity, sum(Total) AS total
FROM invoice 
GROUP BY BillingCity
)
-- Good, but still doesn't work for a tie-for-most-money spent

--What city has spent the most money at our store? 

SELECT BillingCity, Total 
FROM (SELECT BillingCity, sum(Total) AS total
FROM invoice 
GROUP BY BillingCity
ORDER BY sum(Total) DESC
)
WHERE total =  
(SELECT max(total) FROM (SELECT sum(total) AS total 
 FROM invoice GROUP BY BillingCity))
-- aha!  Wait. This is getting confusing.  
-- what we need is a way to name a query and reuse it 
 

 -- let's use a CTE instead of subqueries
WITH total_by_city AS (
SELECT BillingCity, sum(Total) AS total
FROM invoice 
GROUP BY BillingCity
ORDER BY sum(Total) DESC
)
SELECT  BillingCity, total
FROM total_by_city
WHERE total=(SELECT max(total) FROM total_by_city)

---

-- what is the average number of tracks on an album for each genre? 
WITH track_count_albums AS (
SELECT g.name, a.title, count(t.TrackId) AS track_count
FROM Album a 
JOIN track t ON t.AlbumId = a.AlbumId 
JOIN Genre g ON g.GenreId = t.GenreId 
GROUP BY a.title
)
SELECT name, avg(track_count) 
FROM track_count_albums
GROUP BY name

-- 
--What’s the largest amount of money spent by an individual for each city in our database?
--Return City, Person, total $ spent 

 WITH customer_total AS (
 SELECT c.City, c.lastname, sum(i.total) AS total_purchases
 FROM customer c 
 JOIN invoice i ON i.CustomerId=c.CustomerId
 GROUP BY i.CustomerId
 )
 SELECT city, lastname, max(total_purchases)
 FROM customer_total
 GROUP BY city 
 ------------------------------------------------------------
 
 -- what artist in each genre has the most albums? 
-- for this one we had to use 2 CTEs 
 
WITH album_genres AS (
SELECT DISTINCT ar.name, a.Title, g.name AS genre_name
FROM Track t
JOIN genre g ON g.GenreId = t.GenreId
JOIN album a ON a.AlbumId  = t.AlbumId 
JOIN artist ar ON ar.ArtistId = a.ArtistId 
),
-- now we need a second CTE.  
-- It uses the first CTE to get artist, album, genre table
-- Notice we put a comma at the end of the first CTE
-- and we don't use the term WITH this time around.  
-- we just define the CTE 
-- here it is: 

artist_album_count AS (
SELECT name, genre_name, count(DISTINCT title) AS album_count 
FROM album_genres
GROUP BY name, genre_name
)
-- OK now let's do the main query using the result of the second CTE  
SELECT genre_name, name, max(album_count) AS albums
FROM artist_album_count 
GROUP BY genre_name







