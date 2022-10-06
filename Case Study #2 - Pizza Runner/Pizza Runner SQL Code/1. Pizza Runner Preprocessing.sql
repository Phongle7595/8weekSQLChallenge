----8weekSQLchallenge
--Case Study #2 - Pizza Runner

--Author: Phong Le
--Tool: MS SQL Server
CREATE SCHEMA pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" VARCHAR(50)
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" VARCHAR(50)
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" VARCHAR(50)
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

--Double checking that database is correct
Select *
From pizza_runner.runners

Select *
From pizza_runner.customer_orders

Select *
From pizza_runner.runner_orders

Select *
From pizza_runner.pizza_names

Select *
From pizza_runner.pizza_recipes

Select *
From pizza_runner.pizza_toppings

--Data Cleaning
--Fix customer_orders table using temp table with the Into and #. Removing nulls with ' '

SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	ELSE extras
	END AS extras,
	order_time
INTO #customer_orders_cleaned
FROM pizza_runner.customer_orders

--splitting row in exclusions and extras

WITH customer_orders_CTE (order_id, customer_id, pizza_id, exclusions, extras, order_time)  
AS  
(
    SELECT 
		order_id, customer_id, pizza_id, 
		trim(value) exclusions, extras, order_time 
    FROM #customer_orders_cleaned
    CROSS APPLY STRING_SPLIT(exclusions, ',')  
)  
SELECT 
	order_id, customer_id, pizza_id, 
	exclusions,trim(value) extras, order_time  
into #customer_orders_split
FROM customer_orders_CTE
CROSS APPLY STRING_SPLIT(extras, ',')
order by order_id, customer_id, pizza_id, exclusions, extras

--Fix runner_orders table with the same method.

SELECT order_id, runner_id,  
CASE
	WHEN pickup_time LIKE 'null' THEN ' '
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN ' '
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
	END AS distance,
CASE
	WHEN duration LIKE 'null' THEN ' '
	WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
	WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	ELSE cancellation
	END AS cancellation
INTO #runner_orders_cleaned
FROM pizza_runner.runner_orders


--Fixing pizza_recipes table
DROP TABLE IF EXISTS #pizza_recipes;
select 
	pizza_id, 
	trim(value) toppings
into #pizza_recipes
from 
	(
		select 
			pizza_id, 
			cast(toppings as varchar(max)) toppings
		from pizza_runner.pizza_recipes
	) a 
CROSS APPLY STRING_SPLIT(toppings, ',')
order by pizza_id;

--fixing pizza_toppings table
DROP TABLE IF EXISTS #pizza_toppings;
select 
	topping_id, 
	cast(topping_name as varchar(max)) topping_name
into #pizza_toppings
from pizza_runner.pizza_toppings;


-- Change data type in temp table #runner_orders_cleaned

ALTER TABLE #runner_orders_cleaned
ALTER COLUMN pickup_time DATETIME

ALTER TABLE #runner_orders_cleaned
ALTER COLUMN distance FLOAT

ALTER TABLE #runner_orders_cleaned
ALTER COLUMN duration INT

ALTER TABLE pizza_runner.pizza_names
ALTER COLUMN pizza_name VARCHAR(50)

ALTER TABLE #customer_orders_split
ALTER COLUMN exclusions INT

ALTER TABLE #customer_orders_split
ALTER COLUMN extras INT

Select *
From #customer_orders_cleaned
