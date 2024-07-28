-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders
;


 -- Calculate the total revenue generated from pizza sales.

SELECT 
    Round(sum(order_details.quantity*pizzas.price), 2 ) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id ;


-- Identify the highest-priced pizza.


SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1
;


-- Identify the most common pizza size ordered.

SELECT 
    quantity , count(order_detail_id)
FROM
    order_details
GROUP BY quantity
;


SELECT 
    pizzas.size,
    COUNT(order_details.order_detail_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5
;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY quantity DESC
;


-- Determine the distribution of orders by hour of the day.



SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Num_of_orders_hourly
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category, count(pizza_types.name) AS Num_of_pizza_in_particular_category_different_size
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    group by category
;


SELECT 
    pizza_types.category,
    COUNT(pizza_types.name) AS Num_of_pizza_in_particular_category
FROM
    pizza_types
GROUP BY category
;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

#SELECT order_date , count(order_details.quantity)



SELECT 
    ROUND(AVG(Num_of_orders_daily), 0) AS avg_orders_daily
FROM
    (SELECT 
        orders.order_date date,
            SUM(order_details.quantity) AS Num_of_orders_daily
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY date) AS order_quantity;
    
    
    -- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
    
    
    -- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
    
    
 -- Analyze the cumulative revenue generated over time.

select order_date , sum(revenue) over(order by order_date) as cumulative_revenue
from 
(SELECT 
    orders.order_date,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY orders.order_date
ORDER BY order_date )as sales;    
    
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category , name , revenue 
from
(select category , name ,
 revenue , rank() 
 over (partition by category order by revenue desc) as rn 
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name
ORDER BY pizza_types.category ) as a) as b
where rn  <= 3;    
    
