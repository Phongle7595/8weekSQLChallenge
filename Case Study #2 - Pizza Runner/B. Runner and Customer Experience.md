# Case Study 2: Pizza Runner

## Solution
### B. Runner and Customer Experience

[View the complete syntax code](https://github.com/Phongle7595/8weekSQLChallenge/blob/1cb2cfae130b98afa25687fd677b0eccee39a2ca/Case%20Study%20%232%20-%20Pizza%20Runner/Pizza%20Runner%20SQL%20Code/3.%20B.%20Runner%20and%20Customer%20Experience).

***

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SET DATEFIRST 5

SELECT DATEPART(WEEK, registration_date) AS Register_week, MIN(registration_date) AS Week_Start, Count(DISTINCT runner_id) AS #_signed_up
FROM pizza_runner.runners
Group By DATEPART(WEEK, registration_date)
````

#### Answer:
| Register_week | Week_Start | #-signed_up |
| ------------- | ---------- | ----------- |
| 1             | 2021-01-01 | 2           |
| 2             | 2021-01-08 | 1           |
| 3             | 2021-01-15 | 1           |



***

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
WITH time_to_arrive AS
(
SELECT c.order_id, c.order_time, r.pickup_time, r.runner_id, DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS Arrival_Time
FROM #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
)
SELECT runner_id, AVG(Arrival_Time) AS Average_time
From time_to_arrive
Group by runner_id
````

#### Answer:
| runner_id | Average_time | 
| --------- | ------------ |
| 1         | 15           | 
| 2         | 24           | 
| 3         | 10           | 


***

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
WITH relationship AS
(
SELECT c.order_id, COUNT(c.order_id) AS #_of_pizza, c.order_time, r.pickup_time, DATEDIFF(Minute, c.order_time, r.pickup_time) AS prep_time
FROM #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
Group by c.order_id, c.order_time, r.pickup_time
)
SELECT #_of_pizza, AVG(prep_time) AS AVG_prep_time
FROM relationship
Group by #_of_pizza
````

#### Answer:
| #-of_pizza | AVG_prep_time | 
| ---------- | ------------- |
| 1          | 12            | 
| 2          | 18            | 
| 3          | 30            | 


***

### 4. What was the average distance travelled for each customer?

````sql
SELECT c.customer_id, AVG(r.distance) AS avg_distance
FROM #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
Group by c.customer_id
````

#### Answer:
| customer_id  | avg_distance | 
| ------------ | ------------ |
| 101          | 20           |
| 102          | 16.733333333 |
| 103          | 23.4         |
| 104          | 10           |
| 105          | 25           |


***

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT MAX(duration) - MIN(duration) AS diff_delivery_time
FROM #runner_orders_cleaned
WHERE distance <> 0
````

#### Answer:
| diff_delivery_time |
| 30                 |

***

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
WITH avg_speed AS
(
SELECT r.runner_id, ROUND(((r.distance / r.duration)*60), 0) AS Speed
FROM #customer_orders_cleaned AS c
	JOIN #runner_orders_cleaned AS r
	ON c.order_id = r.order_id
WHERE r.distance <> 0
GROUP BY r.runner_id, ROUND(((r.distance / r.duration)*60), 0)
)
SELECT runner_id, AVG(Speed) AS Average_speed
FROM avg_speed
Group by runner_id
````

#### Answer:
| runner_id | Average_speed |
| --------- | ------------- |
| 1         | 45.5          |
| 2         | 63            |
| 3         | 40            |

***

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS 'Success_%'
FROM #runner_orders_cleaned
GROUP BY runner_id;
````

#### Answer:
| runner_id | Success_% |
| --------- | --------- |
| 1         | 100       |
| 2         | 75        |
| 3         | 50        |



