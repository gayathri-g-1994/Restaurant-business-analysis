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

#Total quantity of items sold.
select avg(quantity) from order_items i
join orders o
on  o.order_id=i.order_id
where status='completed';




