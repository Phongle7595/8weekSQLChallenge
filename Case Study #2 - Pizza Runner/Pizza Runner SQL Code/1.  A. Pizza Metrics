--Case Study Questions

--A. Pizza Metrics
--1. How many pizzas were ordered?

Select COUNT(*) AS number_of_pizzas_ordered
From #customer_orders_cleaned

--2. How many unique customer orders were made?

Select 
	COUNT(DISTINCT order_id) AS unique_customer_order
From #customer_orders_cleaned

--3. How many successful orders were delivered by each runner?

Select
	runner_id, COUNT(DISTINCT order_id) as successful_orders
From #runner_orders_cleaned
Where distance <> 0
Group by runner_id

--4. How many of each type of pizza was delivered?

Select n.pizza_name, COUNT(c.pizza_id) AS number_delivered
From #customer_orders_cleaned AS c
	Join #runner_orders_cleaned AS r
	on c.order_id = r.order_id
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Where r.distance <> 0
Group by n.pizza_name

--5. How many Vegetarian and Meatlovers were ordered by each customer?
--2 ways of getting the answer
Select c.customer_id, n.pizza_name, COUNT(c.pizza_id) as Amount
From #customer_orders_cleaned AS c
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Group by c.customer_id, n.pizza_name
Order by c.customer_id

--I think this makes it easier to read visually
Select c.customer_id, 
	SUM(Case When c.pizza_id = 1 then 1
			else 0 end) AS Meatlovers,
	SUM(Case When c.pizza_id = 2 then 1
			else 0 end) AS Vegetarian
From #customer_orders_cleaned AS c
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Group by c.customer_id

--6. What was the maximum number of pizzas delivered in a single order?

With amount_delivered AS
(
Select c.order_id, COUNT(c.pizza_id) AS pizza_delivered
From #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
Group by c.order_id
)
Select MAX(pizza_delivered) AS max_delivered
From amount_delivered

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

Select c.customer_id, 
	SUM(CASE WHEN c.exclusions <> ' ' or c.extras <> ' ' THEN 1 ELSE 0 END) AS at_least_1_change,
	SUM(CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 ELSE 0 END) AS no_changes
From #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
Group by c.customer_id

--8. How many pizzas were delivered that had both exclusions and extras?

Select SUM(CASE WHEN c.exclusions <> ' ' AND c.extras <> ' ' THEN 1 ELSE 0 END) AS With_exclusions_extras
From #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0

--9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day, 
  COUNT(order_id) AS total_ordered
FROM #customer_orders_cleaned
GROUP BY DATEPART(HOUR, order_time);

--Note: Use DATEPART to get the INT of the HOUR

--10. What was the volume of orders for each day of the week?

Select DATENAME(WEEKDAY, order_time) AS Day_of_week, COUNT(order_id) AS Total_ordered
FROM #customer_orders_cleaned
Group by DATENAME(WEEKDAY, order_time)
Order by COUNT(order_id)
