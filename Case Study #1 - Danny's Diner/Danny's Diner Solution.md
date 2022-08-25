# Case Study 1: Danny's Diner

## Solution

[View the complete syntax code](https://github.com/Phongle7595/8weekSQLChallenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Danny's%20Diner.sql).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
Select
	s.customer_id,
	SUM(m.price) AS Total_Sales
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Group by s.customer_id
````

- Use **SUM** to find Total_sales for each customer.
- Use **JOIN** to merge sales and meny tables.

#### Answer:
| Customer_id | Total_Sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |



***

### 2. How many days has each customer visited the restaurant?

````sql
Select customer_id, COUNT(distinct(order_date)) AS visits
From dannys_diner.sales
Group by customer_id
````

- Use **DISTINCT** with **COUNT** to find unique number of visits for each customer.

#### Answer:
| Customer_id | visits |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |


***

### 3. What was the first item from the menu purchased by each customer?

````sql
With roworder_sales AS
(
Select
	customer_id, 
    order_date, 
    product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rankorder
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
)
Select
	customer_id,
	product_name
From roworder_sales
Where rankorder = 1
Group by customer_id, product_name
````
- Create a temp table to get a new rank column based on order_date. Tried using **ROW_NUMBER** with partition but it did not sort by the original order, same with **RANK**
- Use **DENSE_RANK** for the rankorder column and conditioned to show only rank = 1.

#### Answer:
| Customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first order is curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
Select
	Top 1 m.product_name, 
	Count(s.product_id) AS most_purchased
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Group by m.product_name
Order by most_purchased DESC
````
- Use **COUNT** to get the number of products purchased and sorted by descending order.
- Use **TOP** to filter to the highest number.


#### Answer:
| product_name  | most_purchased | 
| ----------- | ----------- |
| ramen       | 8|


- Most purchased item on the menu is ramen which is 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
With popular AS
(
Select
	s.customer_id, m.product_name, Count(m.product_id) AS amount_ordered,
	Rank() over(partition by customer_id Order by Count(m.product_id)DESC ) AS ranking
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Group by s.customer_id, m.product_name
)
Select
	customer_id, product_name, amount_ordered
From
	popular
Where 
	ranking = 1
````
- Create a temp table and use **DENSE_RANK** to add a partitioned ranking column for each item counted.

#### Answer:
| customer_id | product_name | amount_ordered |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen while customer B savours all items on the menu. 

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
with Orderank AS
(
Select
	s.customer_id, 
    s.order_date, 
    m.product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rankorder
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
	Join dannys_diner.members AS mm
	On s.customer_id = mm.customer_id
Where mm.join_date <= s.order_date
)
Select
	customer_id, order_date, product_name
From
	Orderank
Where rankorder = 1
````
- create temp table and partition customer_id by order_date. 
- Filtered order date to be on or after join date

#### Answer:
| customer_id | order_date |product_name |
| ----------- | ----------  |----------  |
| A           |  2021-01-07 |curry |
| B           |  2021-01-11 |sushi |

After becoming a member 
- Customer A's first order was curry.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
with Orderank AS
(
Select
	s.customer_id, 
    s.order_date, 
    m.product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rankorder
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
	Join dannys_diner.members AS mm
	On s.customer_id = mm.customer_id
Where mm.join_date > s.order_date
)
Select
	customer_id, order_date, product_name
From
	Orderank
Where rankorder = 1
````
- Same as question 6, just changing the <= sign to a > sign

#### Answer:
| customer_id | order_date |product_name |
| ----------- | ----------  |---------- |
| A           |  2021-01-01 |sushi | 
| A           |  2021-01-01 |curry | 
| B           |  2021-01-04 |curry |

Before becoming a member 
- Customer A’s last order was sushi and curry.
- Customer B’s last order wassushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
Select s.customer_id, count(distinct s.product_id) AS Total_Items, Sum(m.Price) AS Total_Amount
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
	Join dannys_diner.members AS mm
	On s.customer_id = mm.customer_id
Where mm.join_date > s.order_date
Group by s.customer_id

````
- Join all three tables. Filter order_date before join date. 
- Use **COUNT** **DISTINCT** on product_id to get total items and **SUM** on price to get total amount

#### Answer:
| customer_id |Items | Total_Amount |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

Before becoming a member
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
With Item_points AS
(
Select *, Case When	
	product_id = 1 Then price * 20
	Else price * 10
	End
	AS Points
From 
	dannys_diner.menu
)
Select s.customer_id, SUM(p.Points) AS Total_Points

From dannys_diner.sales AS s
	Join Item_points AS p
	On s.product_id = p.product_id
Group by s.customer_id
````
- Use Case When to make a new column that mutiple price by 10 and if the product_id is 1 (sushi) then multiply by 20
- Use **SUM** to get total points

#### Answer:
| customer_id | Total_Points | 
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for customer A, B and C are 860, 940 and 360 respectivly.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
With dates AS
(
Select *, 
	DATEADD(day, 6, join_date) AS valid_date,
	EOMONTH('2021-01-31') AS last_date

From dannys_diner.members
)
Select s.customer_id,
	SUM( CASE WHEN
			m.product_id = 1 Then m.price * 20
			When s.order_date between d.join_date and d.valid_date Then m.price*20
			Else m.price*10
			End) AS Points

From dates AS d
	join dannys_diner.sales AS s
	ON d.customer_id = s.customer_id
	join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Where s.order_date < d.last_date
Group by s.customer_id
````
- Create a temp table to add 2 new columns. Use **DATEADD** to find the valid_date (add 6 days to the join_date) and use **EOMONTH** to find the last_day of Jan 2021
- Any amount spent before join_date is 10 points per $ and 20 points for sushi
- From join_date to valid_date, every $ spent is 20 points.
- From after valid_date to last_day, back to the original promotion of $1 = 10 points and sushi = 20 points/1$

#### Answer:
| Customer_id | Points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A and B are 1,370 and 820 respectivly.

***

##Bonus Question

## Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
Select s.customer_id, s.order_date, m.product_name, m.price, 
	Case 
		When mm.join_date > s.order_date Then 'N'
		When mm.join_date <= s.order_date Then 'Y'
		Else 'N'
		End
		As member
From dannys_diner.sales AS s
	Left Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
	Left Join dannys_diner.members AS mm
	On s.customer_id = mm.customer_id
 ````
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***
