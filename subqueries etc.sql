-- what is the total $ spent by gmail users in each city? 
SELECT i.BillingCity, sum(i.Total)
FROM Invoice i 
JOIN Customer c ON c.CustomerId = i.CustomerId 
WHERE c.Email LIKE "%gmail%"
GROUP BY i.BillingCity
--
-- what is total $ spent in cities where at least one person uses gmail? 
SELECT i.BillingCity, sum(i.Total)
FROM invoice i
WHERE i.BillingCity IN(
SELECT DISTINCT City  FROM Customer c2  -- this subquery gives us a list OF cities
WHERE Email LIKE "%gmail%" )
GROUP BY BillingCity;
-- 


-- what is the average number of tracks on an album for each genre? 
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

 
 