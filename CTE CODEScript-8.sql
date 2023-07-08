--1 Using the Invoice Table, Show Average Total per Country--

SELECT BillingCountry, ROUND(AVG(Total),2) as total_per_country
FROM Invoice
Group By BillingCountry 
ORDER BY 2 DESC


--2 Create a table with the following columns 
--InvoiceId
--BillingCountry
--Total, Avg_Total_for_Planet


SELECT * FROM invoice

--TRADITIONAL-- The output GROUPS the unique country with the TOTAL/SUM of ALL invoices in that unique country--
--In other words, The SUM column makes sense, and the Total column remains in its per invoice form/which is unecessary--
SELECT InvoiceId, BillingCountry,Total,
SUM(Total) 
FROM Invoice 
GROUP BY BillingCountry 


--OPEN BRACKETS--GIMME ERRTANG--The output pulls in ALL invoices/countries PLUS the values of EACH INVOICE/PER COUNTRY--
--AND the SUM of ALL invoices for ALL the countries (hence the same value)-- 
SELECT InvoiceId, BillingCountry,Total,
SUM(Total) OVER() AS totalpercountry
FROM Invoice 

--WINDOW FUNCTION WITH A PARTITION--GIMME ERRTANG but PERTAINING to my SPECIFICATION--  
--Similar to open brackets = The output pulls in ALL invoices/countries PLUS the values of EACH INVOICE/PER COUNTRY--
--AND the SUM of ALL of these invoices but LIMITED TO what falls WITHIN my specification ONLY (in this case to a specific country)--
SELECT InvoiceId, BillingCountry,Total,
SUM(Total) OVER(PARTITION BY BillingCountry) AS Total_Per_Country
FROM Invoice 


Select * FROM invoice
--Create a table with the following columns:
--InvoiceID,BillingCountry

WITH cte AS 
(
SELECT InvoiceId, BillingCountry,Total,
MAX(Total) OVER(PARTITION BY BillingCountry) AS MaxPerCountry
FROM Invoice 
)
SELECT *, MaxPerCountry
FROM cte


 --Create a table showing the **BillingCountry & the **Average difference from the **Average per Country--

WITH cte AS
(
SELECT BillingCountry, Total,
AVG(Total) OVER(PARTITION BY BillingCountry) AS AVGPerCountry
FROM invoice
)
SELECT  *,Total - AVGPerCountry AS thedifference,
AVG(AVGPerCountry-Total) OVER(PARTITION BY billingCountry) AS AVGoftheAVG
FROM cte 



