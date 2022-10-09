# Case Study 2: Pizza Runner

## Solution
### A. Pizza Metrics

[View the complete syntax code](https://github.com/Phongle7595/8weekSQLChallenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Pizza%20Runner%20SQL%20Code/2.%20%20A.%20Pizza%20Metrics.sql).

***

### 1. How many pizzas were ordered?

````sql
Select COUNT(*) AS number_of_pizzas_ordered
From #customer_orders_cleaned
````

#### Answer:
| number_of_pizzas_ordered |
| ------------------------ |
| 14                       |



***

### 2. How many unique customer orders were made?

````sql
Select 
	COUNT(DISTINCT order_id) AS unique_customer_order
From #customer_orders_cleaned
````

#### Answer:
| unique_customer_order |
| --------------------- |
| 10                    |


***

### 3. How many successful orders were delivered by each runner?

````sql
Select
	runner_id, COUNT(DISTINCT order_id) as successful_orders
From #runner_orders_cleaned
Where distance <> 0
Group by runner_id
````

#### Answer:
| runner_id | successful_orders | 
| --------- | ----------------- |
| 1         | 4                 | 
| 2         | 3                 | 
| 3         | 1                 | 


***

### 4. How many of each type of pizza was delivered?

````sql
Select n.pizza_name, COUNT(c.pizza_id) AS number_delivered
From #customer_orders_cleaned AS c
	Join #runner_orders_cleaned AS r
	on c.order_id = r.order_id
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Where r.distance <> 0
Group by n.pizza_name
````

#### Answer:
| pizza_name  | number_delivered | 
| ----------- | ----------- |
| Meatlovers  | 9           |
| Vegetairan  | 3           |


***

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
- There are two ways of getting the answer

````sql
Select c.customer_id, n.pizza_name, COUNT(c.pizza_id) as Amount
From #customer_orders_cleaned AS c
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Group by c.customer_id, n.pizza_name
Order by c.customer_id
````

#### Answer:
| customer_id | pizza_name | Amount |
| ----------- | ---------- |------------  |
| 101         | Meatlovers       |  2   |
| 101         | Vegetarian      |  1   |
| 102         | Meatlovers        |  2   |
| 102         | Vegetarian        |  1   |
| 103         | Meatlovers        |  3   |
| 103         | Vegetarian        |  1   |
| 104         | Meatlovers        |  3   |
| 105         | Vegetarian       |  1   |

- The 2nd way to get the answer uses SUM and CASE WHEN. I think this gives a better answer visually.

````sql
Select c.customer_id, 
	SUM(Case When c.pizza_id = 1 then 1
			else 0 end) AS Meatlovers,
	SUM(Case When c.pizza_id = 2 then 1
			else 0 end) AS Vegetarian
From #customer_orders_cleaned AS c
	Join pizza_runner.pizza_names AS n
	on c.pizza_id = n.pizza_id
Group by c.customer_id
````
#### Answer:
| customer_id | Meatlovers | Vegetarian |
| ----------- | ---------- |------------  |
| 101         | 2      |  1   |
| 102         | 2      |  1   |
| 103         | 3      |  1   |
| 104         | 3      |  0   |
| 105         | 0      |  1   |

***

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
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
````

#### Answer:
| max_delivered |
| ------------- | 
| 3             |

***

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
Select c.customer_id, 
	SUM(CASE WHEN c.exclusions <> ' ' or c.extras <> ' ' THEN 1 ELSE 0 END) AS at_least_1_change,
	SUM(CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 ELSE 0 END) AS no_changes
From #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
Group by c.customer_id
````

#### Answer:
| customer_id | at_least_1_change |no_change |
| ----------- | ----------------  |--------- |
| 101         |  0                | 2        | 
| 102         |  0                | 3        | 
| 103         |  3                | 0        | 
| 104         |  2                | 1        | 
| 105         |  1                | 0        | 


***

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
Select SUM(CASE WHEN c.exclusions <> ' ' AND c.extras <> ' ' THEN 1 ELSE 0 END) AS With_exclusions_extras
From #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
````

#### Answer:
| With_exclusions_extras |
| ----------- |
| 1           |


***

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day, 
  COUNT(order_id) AS total_ordered
FROM #customer_orders_cleaned
GROUP BY DATEPART(HOUR, order_time);
````

#### Answer:
| hour_of_day | total_ordered | 
| ----------- | ------------- |
| 11          | 1             |
| 13          | 3             |
| 18          | 3             |
| 19          | 1             |
| 21          | 3             |
| 23          | 3             |

- Use DATEPART to get INT of the HOUR

***

### 10. What was the volume of orders for each day of the week?

````sql
Select DATENAME(WEEKDAY, order_time) AS Day_of_week, COUNT(order_id) AS Total_ordered
FROM #customer_orders_cleaned
Group by DATENAME(WEEKDAY, order_time)
Order by COUNT(order_id)
````

#### Answer:
| Day_of_week | Total_ordered | 
| ----------- | ------------- |
| Friday      | 1             |
| Thrusday    | 3             |
| Wednesday   | 5             |
| Saturday    | 5             |



