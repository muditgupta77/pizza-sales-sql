create database pizza_sales;
use pizza_sales;
show tables;
select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;
desc pizzas;
desc pizza_types;
desc orders;
desc order_details;

-- 1. retrive the total number of orders placed

select count(order_id) as "total orders" from orders;

select count(order_details_id) as "total orders by customer" from order_details;

--  2. calculate the total revenue generated from pizza sales

select round(sum(pizzas.price*order_details.quantity),2) as "revenue"
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id;

-- 3. identify the highest priced pizza

select pizza_types.name,pizzas.price
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- 4.identify the most common pizza size ordered

select pizzas.size,sum(order_details.quantity) as "total quantity"
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size
order by 2 desc
limit 1;

-- 5.  list the top 5 most ordered  pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS 'total'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY 2 DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

select category,sum(order_details.quantity) as "quantity" from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by 2 desc;

-- 7. Determine the distribution of orders by hour of the day.

select * from orders;
select hour(time) as hour, count(order_id) as order_id from orders
group by hour(time);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

select category,count(order_details.quantity) as "total distribution" from pizza_types 
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by 2;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as avg_pizza_ordered_per_day from
(select orders.date,sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.date) as quantity;

-- 10. top 3 most ordered pizza types based on revenue

select pizza_types.name,sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 12 Analyze the cumulative revenue generated over time

select date,
sum(revenue) over (order by date) as cum_revenue
from
(select orders.date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.date) as Sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as ranking
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by  pizza_types.category, pizza_types.name) as a) as b
where ranking <= 3;
