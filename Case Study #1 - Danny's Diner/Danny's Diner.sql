--8weekSQLchallenge
--Case Study #1 - Danny's Diner

--Author: Phong Le
--Tool: MS SQL Server

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

  CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  --Assigned each table to dannys_diner schema using Design in Object Explorer.

  --Double checking to make sure all tables are correct

  Select *
  From dannys_diner.sales

   Select *
  From dannys_diner.menu

   Select *
  From dannys_diner.members

--Case Study Questions

--1. What is the total amount each customer spent at the restaurant?
Select
	s.customer_id,
	SUM(m.price) AS Total_Sales
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Group by s.customer_id

--2. How many days has each customer visited the restaurant?
Select customer_id, COUNT(distinct(order_date)) AS visits
From dannys_diner.sales
Group by customer_id

--3. What was the first item from the menu purchased by each customer?
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

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

Select
	Top 1 m.product_name, 
	Count(s.product_id) AS most_purchased
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
Group by m.product_name
Order by most_purchased DESC

--5. Which item was the most popular for each customer?

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

--6. Which item was purchased first by the customer after they became a member?

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

--7. Which item was purchased just before the customer became a member?
--Same code as last question, just changing the <= sign to a > sign
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

--8. What is the total items and amount spent for each member before they became a member?

Select s.customer_id, count(distinct s.product_id) AS Total_Items, Sum(m.Price) AS Total_Amount
From dannys_diner.sales AS s
	Join dannys_diner.menu AS m
	ON s.product_id = m.product_id
	Join dannys_diner.members AS mm
	On s.customer_id = mm.customer_id
Where mm.join_date > s.order_date
Group by s.customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

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

--Bonus
--Join all things

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