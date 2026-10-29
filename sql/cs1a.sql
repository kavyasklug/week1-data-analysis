--q1:Total sales, profit and margin by year
select
	strftime('%Y', "Order Date") as year,
    sum(Sales) as total_sales,
    sum(Profit) as total_profit,
    round(sum(Profit)* 100.0/ sum(Sales), 2) as profit_margin_percent
from superstore_cleaned
group by strftime('%Y', "Order Date")
order by year ASC;


--q2:Revenue per month across all four years
select 
	strftime('%Y-%m', "Order Date") as order_month,
	round(sum(Sales),2) as month_revenue
from superstore_cleaned 
group by strftime('%Y-%m', "Order Date")
order by order_month asc;


--q3:Top 5 customers by total spend
select "Customer Name",
	round(sum(Sales),3) as total_spend
from superstore_cleaned
group by "Customer Name"
order by total_spend DESC
limit 5;


--q4:Profit by region and category
select Region, Category,
    round(sum(Profit), 2) as total_profit
from superstore_cleaned
group by Region, Category
order by Region, Category;


--q5:Sub-categories with negative total profit
select "Sub-Category",
	round(sum(Profit),3) as total_profit
from superstore_cleaned
group by "Sub-Category"
having sum(Profit)<0
order by total_profit desc;


--q6:Average discount on loss-making vs profitable orders
select case when Profit<0 then 'loss making'
	else 'profitable' end as order_type,
	round(avg(Discount),3) as avg_discount
from superstore_cleaned
group by CASE
	when Profit<0 then 'loss making'
	else 'profitable'
end;


--q7:Average days from order to ship by ship mode
select "Ship Mode",
	round(avg(julianday("Ship Date")-julianday("Order Date")),2) as avg_shippingdays
from superstore_cleaned
group by "Ship Mode";


--q8:Each customer's first order date and number of orders
select "Customer Name",
	min("Order Date") as first_order,
	count(distinct "Order ID") as number_of_orders
from superstore_cleaned
group by "Customer Name"
order by first_order asc;