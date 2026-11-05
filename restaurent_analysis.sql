use restaurant_management;
#Total completed orders & revenue
desc orders;
with total_orders(tot_orders) as
(select count(*) 
from orders
where status='completed'),
tot_revenue(total_revenue) as
(select sum(item_price*quantity)  from order_items i
join orders o
on o.order_id=i.order_id
where status='completed')
SELECT
    tot_orders,
    total_revenue,
    total_revenue / NULLIF(tot_orders, 0) AS aov
FROM total_orders
CROSS JOIN tot_revenue;

#AOV
select avg(quantity) from order_items i
join orders o
on  o.order_id=i.order_id
where status='completed';

#TOP 5 CUSTOMERS
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(i.item_price * i.quantity) AS total_spending
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    JOIN order_items i
        ON i.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 5;

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(i.item_price * i.quantity) AS total_spending
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    JOIN order_items i
        ON i.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 5;



WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS revenue_month,
        SUM(i.item_price * i.quantity) AS month_revenue
    FROM orders o
    JOIN order_items i
        ON o.order_id = i.order_id
    WHERE o.status = 'completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),

prev_revenue AS (
    SELECT
        revenue_month,
        month_revenue,
        LAG(month_revenue, 1) OVER(
            ORDER BY revenue_month
        ) AS prev_revenue
    FROM monthly_revenue
)

SELECT
    revenue_month,
    month_revenue,
    prev_revenue,
    ROUND(
        (month_revenue - prev_revenue)
        / NULLIF(prev_revenue, 0) * 100,
        2
    ) AS growth_rate
FROM prev_revenue
ORDER BY revenue_month;

#daily revenue analysis
select count(distinct o.order_id) as total_orders,
order_date as revenue_date,
sum(i.item_price *i.quantity) as revenue,
sum(i.quantity) 
as total_quantity_sold 
from order_items i
join orders o
on o.order_id=i.order_id
where status='completed'
group by o.order_date
order by o.order_date asc;
select order_id,order_date,order_revenue,case when order_revenue>300 then  'high'
                                        when order_revenue>200 and order_revenue<300 then 'medium'
                                        else 'low'
                                        end as 'revenue_category'
from 
(
select o.order_id as order_id,o.order_date as order_date,
sum(item_price*quantity) as order_revenue
from
order_items i
join orders o on
o.order_id=i.order_id
where status='completed'
group by o.order_id,o.order_date)as revenue
order by order_date,order_id asc;










 

