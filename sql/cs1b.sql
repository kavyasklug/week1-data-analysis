-- b1: Orders and revenue per month for delivered orders
select
    strftime('%Y-%m',o.order_purchase_timestamp) as order_month,
    count(distinct o.order_id) as total_orders,
    round(sum(oi.price),2) as total_revenue
from olist_orders o
join olist_order_items oi
    on o.order_id=oi.order_id
where o.order_status='delivered'
group by strftime('%Y-%m',o.order_purchase_timestamp)
order by order_month;


--b2: Top 10 product categories by revenue
select case
     when pct.product_category_name_english is not null then pct.product_category_name_english
	 when p.product_category_name is not null then p.product_category_name
     else 'unknown'
    end as category_name,
    round(sum(oi.price),2) as total_revenue
from olist_order_items oi
join olist_products p
    on oi.product_id=p.product_id
left join product_category_translation pct
    on p.product_category_name=pct.product_category_name
join olist_orders o
    on oi.order_id=o.order_id
where o.order_status='delivered'
group by
    case
        when pct.product_category_name_english is not null then pct.product_category_name_english
        when p.product_category_name is not null then p.product_category_name
        else 'unknown'
    end
order by total_revenue desc
limit 10;


--b3:Share of orders paid by each payment type
with order_payment_types as (
    select distinct
        order_id, payment_type from olist_order_payments
)
select
    payment_type, count(distinct order_id) as total_orders,
    round(
        count(distinct order_id)*100.0/
        (select count(distinct order_id) from order_payment_types), 2
    ) as percentage
from order_payment_types
group by payment_type
order by percentage desc;


--b4: Average delivery days and % late (delivered after estimated date) by customer state
select c.customer_state,
    round(avg(
        julianday(o.order_delivered_customer_date)-
        julianday(o.order_purchase_timestamp)),2) as avg_delivery_days,
    round(sum(case
                when o.order_delivered_customer_date>o.order_estimated_delivery_date then 1 else 0
            end)*100.0/count(*),2) as late_order_percentage
from olist_orders o
join olist_customers c
    on o.customer_id=c.customer_id
where o.order_status='delivered' and o.order_delivered_customer_date is not null
group by c.customer_state
order by late_order_percentage desc;



--b5:Average review score for late vs on-time orders
select case
        when o.order_delivered_customer_date>o.order_estimated_delivery_date then 'late' else 'on-time'
    end as delivery_status,
    count(distinct o.order_id) as total_orders,
    round(avg(r.review_score),2) as avg_review_score
from olist_orders o
join olist_order_reviews r
    on o.order_id=r.order_id
where o.order_status='delivered'
    and o.order_delivered_customer_date is not null
group by case
        when o.order_delivered_customer_date>o.order_estimated_delivery_date then 'late' else 'on-time'
    end
order by avg_review_score desc;



--b6:Sellers with more than 100 orders and their average review score
select oi.seller_id,
    count(distinct oi.order_id) as total_orders,
    round(avg(r.review_score),2) as avg_review_score
from olist_order_items oi
join olist_orders o
    on oi.order_id=o.order_id
join olist_order_reviews r
    on o.order_id=r.order_id
where o.order_status='delivered'
group by oi.seller_id
having count(distinct oi.order_id)>100
order by avg_review_score desc;


--b7:Month-on-month revenue growth %
with monthly_revenue as (
    select strftime('%Y-%m',o.order_purchase_timestamp) as month,
      sum(oi.price) as revenue
    from olist_orders o
    join olist_order_items oi on o.order_id=oi.order_id
    where o.order_status='delivered'
    group by month
)
select
    month, round(revenue,2) as revenue,
    round(lag(revenue) over (order by month),2) as previous_revenue,
    round((revenue-lag(revenue) over (order by month))*100.0/ lag(revenue) over (order by month),2) as growth_percentage
from monthly_revenue
order by month;



--b8: Top 3 categories by revenue within each state
with category_revenue as (
    select c.customer_state, p.product_category_name as category_name,
        sum(oi.price) as revenue
    from olist_orders o
    join olist_customers c on o.customer_id=c.customer_id
    join olist_order_items oi on o.order_id=oi.order_id
    join olist_products p on oi.product_id=p.product_id
    where o.order_status='delivered'
    group by c.customer_state,p.product_category_name),
ranked_categories as (
    select customer_state, category_name,revenue,
        rank() over (
            partition by customer_state
            order by revenue desc) as category_rank from category_revenue)
select customer_state, category_name, round(revenue,2) as total_revenue, category_rank
from ranked_categories
where category_rank<=3
order by customer_state,category_rank;