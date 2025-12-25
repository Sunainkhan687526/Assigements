Create Database FirstProject;

select * from df_orders;

-------------------------------------------------------------
-- First Query find top 10 high revenue generating products
-------------------------------------------------------------

select top 10 product_id,
		sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc;

------------------------------------------------
-- find top 5 selling products in each reagion
------------------------------------------------

with cte as (
select region,
		product_id,
		sum(sale_price) as sales
from df_orders
group by product_id, region)
select * from (
select *, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;

--------------------------------------------------------------------------------------------
-- find month over month growth comparision for 2022 or 2023 sales eg: jan 2022 vs jan 2023
--------------------------------------------------------------------------------------------

select distinct year(order_date) from df_orders

with cte as(
select year(order_date) as order_year ,
month(order_date) as order_month,
round(sum(sale_price), 3) as sales
from df_orders
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--------------------------------------------------
-- for each category which month had highest sale
--------------------------------------------------

with cte as(
select category,
format(order_date, 'yyyyMM') as order_year_month, 
sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
-- order by category,  format(order_date, 'yyyyMM')
)
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


----------------------------------------------------------------------------
--  Which sub category had highest growth by profit in 2023 compare to 2022
----------------------------------------------------------------------------
select * from df_orders


with cte as(
select sub_category,
year(order_date) as order_year ,
round(sum(sale_price), 3) as sales
from df_orders
group by sub_category,year(order_date)
)
, cte2 as (
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc



