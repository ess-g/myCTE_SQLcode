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

select category_name, total_product_count, MAX(average_price) as max_avg_price 
from  avg_price_per_cat_cte
group by category_name, total_product_count
order by max_avg_price DESC





