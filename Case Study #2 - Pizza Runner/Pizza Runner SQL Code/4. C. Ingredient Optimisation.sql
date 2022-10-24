--C. Ingredient Optimisation
--1. What are the standard ingredients for each pizza?

Select n.pizza_name,
	STRING_AGG(t.topping_name,', ') ingredients
From #pizza_names AS n
Join #pizza_recipes AS r
	ON n.pizza_id = r.pizza_id
Join #pizza_toppings AS t
	ON r.toppings = t.topping_id
Group by n.pizza_name

--2. What was the most commonly added extra?

With customer_cte AS (
	Select distinct order_id, extras
	From #customer_orders_split)
Select t.topping_id, t.topping_name, COUNT(c.extras) AS added
From customer_cte AS c
Join #pizza_toppings AS t
	On c.extras = t.topping_id
Group by t.topping_id, t.topping_name
-- had to use cross apply string split to split extras into different rows then converting it into INT in data processing

--3. What was the most common exclusion?

With customer_cte AS (
	Select distinct order_id, exclusions
	From #customer_orders_split)
Select t.topping_id, t.topping_name, COUNT(c.exclusions) AS exclusions
From customer_cte AS c
Join #pizza_toppings AS t
	On c.exclusions = t.topping_id
Group by t.topping_id, t.topping_name

--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
