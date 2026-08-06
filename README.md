# SQL-BikeStore-Sales-Analysis
# 📑 Overview

This project involves analyzing a relational database for a bike store chain to help the business owner make data-driven decisions.

## 🎯 Objectives:
- Sales Analysis: identifying top-selling products and seasonal trends.
- Customer Insights: segmenting customers based on purchasing behavior (RFM).
- Inventory Management: detecting low-stock items and dead stock.

## Tools:
- SQL Server (T-SQL)
- Key Concepts: JOINS, CTEs, Window Functions, Aggregate Functions.

## Dataset:

"BikeStores" from https://www.sqlservertutorial.net


## Database Diagram:

<img width="742" height="602" alt="image" src="https://github.com/user-attachments/assets/ff5cfe93-e231-4d8b-b490-4a833102632c" />

____________
# 📊 Business Problems & Solutions
# Section 1: Sales & Product Performance
_understanding what sells, what drives revenue, and when_

## **1. Which product categories (e.g., Mountain Bikes, Road Bikes) drive the most revenue?**
*   **Business Goal:** Identify and understand product demand across categories

**Queries**

```sql
select c.category_name, 
		round(sum(o.quantity * o.list_price * (1 - o.discount)),2) as total_revenue
from categories c
inner join products p on c.category_id = p.category_id
inner join order_items o on o.product_id = p.product_id
group by c.category_name
order by c.category_name desc
```
**Result**

<img width="254" height="198" alt="image" src="https://github.com/user-attachments/assets/a729853d-4b5f-4fc9-a407-434a12897c41" />

**Key Insight:**

"Mountain Bikes" account for 35% of total revenue, making them our most important category. We should prioritize keeping these in stock over "Children Bicycles," which have high volume but low profit margins.
____________
## **2. Within each category which products are the best sellers?**
*	**Business Goal:** Knowing that "Mountain Bikes" sell well overall isn't enough, we need to know which specific models within each category to keep in stock
  
**Queries**
```sql
with ranked_products as (
	select c.category_name, p.product_name,
		   sum(oi.quantity) as total_count,
		   rank() over(partition by c.category_name order by sum(oi.quantity) desc) as rnk
	from products p
	join categories c on c.category_id = p.category_id
	join order_items oi on oi.product_id = p.product_id
	group by c.category_name, p.product_name
)

select * from ranked_products
```
**Result**

<img width="517" height="357" alt="image" src="https://github.com/user-attachments/assets/ece6ae67-feaf-417f-97af-93aaa04ffda7" />

**Key Insight:**


____________
## **3. Which brands contribute the most to our sales, and how concentrated is that contribute?**
*	**Business Goal:** a brand leading in volume doesn't tell us if we're dangerously dependent on one supplier

**Queries**
```sql
select b.brand_name, sum(oi.quantity) total_sold,
	   round(100.0 * sum(oi.quantity) / sum(sum(oi.quantity)) over(),2) pct_of_total
from brands b
join products p on p.brand_id = b.brand_id
join order_items oi on oi.product_id = p.product_id
group by b.brand_name
order by total_sold desc
```
**Result**

<img width="317" height="209" alt="image" src="https://github.com/user-attachments/assets/cf047214-a732-408b-87fd-93c27ec62f44" />

____________
## **4. What is our year-over-year revenue growth rate, and is the business accelerating or slowing down?**
*	**Business Goal:** raw yearly totals hide the real story, we need to know the rate of change, not just the number

**Queries**
```sql
with yearly as (
	select datepart(year, o.order_date) as yr, 
		   sum(oi.quantity * oi.list_price * (1-oi.discount)) as revenue
	from order_items oi
	join orders o on o.order_id = oi.order_id
	group by datepart(year, o.order_date)
)

select yr, revenue,
	   lag(revenue) over(order by yr) as prev_year_revenue,
	   round(100.0 * (revenue - lag(revenue) over(order by yr)) / lag(revenue) over(order by yr),2) as yoy_growth_pct
from yearly
```
**Result**

<img width="424" height="86" alt="image" src="https://github.com/user-attachments/assets/59d2982f-e948-4e24-8f16-e6482a2e73b6" />

____________
## **5. How has monthly revenue trended over time, and were there any months of unusually strong growth or sharp decline?**
*	**Business Goal:** track the business's growth trajectory month by month, and flag any specific month where revenue spiked or dropped sharply, so we can investigate the cause (promotion, stockout, seasonal event, etc.) rather than only seeing it in a yearly rollup

**Queries**
```sql
with monthly as (
    select datepart(year, o.order_date) as yr,
           datepart(month, o.order_date) as mo,
           round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue
    from order_items oi
    join orders o on o.order_id = oi.order_id
    group by datepart(year, o.order_date), datepart(month, o.order_date)
),
with_lag as (
    select yr, mo, revenue,
           lag(revenue) over (order by yr, mo) as prev_month_revenue
    from monthly
)
select yr, mo, revenue, prev_month_revenue,
       sum(revenue) over (order by yr, mo) as cumulative_revenue,
       round(100.0 * (revenue - prev_month_revenue) / prev_month_revenue, 2) as mom_growth_pct
from with_lag
order by yr, mo;
```
**Result**

<img width="554" height="724" alt="image" src="https://github.com/user-attachments/assets/f8da123f-2881-4fb7-a5bd-daff407eb0dd" />


**Key Insight:**

# Section 2: Store & Staff Performance
_We see that Baldwin dominates total revenue, but does that mean it's actually the best-run store?_
____________
## **6. How do our three stores rank in terms of total revenue?**

**Queries**
```sql
select s.store_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from stores s
inner join orders o on o.store_id = s.store_id
inner join order_items oi on oi.order_id = o.order_id
group by s.store_name
order by total_revenue desc
```
**Result**

<img width="239" height="92" alt="image" src="https://github.com/user-attachments/assets/20c24ee3-539d-47ae-9dd0-4580076dc8b2" />


____________
## **7. Given Baldwin's dominance, who are the staff members actually driving that revenue?**

**Queries**
```sql
select st.staff_id,
		concat(st.first_name, ' ', st.last_name) as Full_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from staffs st
inner join orders o on o.staff_id = st.staff_id
inner join order_items oi on oi.order_id = o.order_id
group by st.staff_id, st.first_name, st.last_name
order by total_revenue desc
```
**Result**

<img width="289" height="151" alt="image" src="https://github.com/user-attachments/assets/a35269d5-2b17-4d87-b595-2d718191fe82" />


**Key Insight:**

____________
## **8. Which staff member is the top performer within their own store — not just company-wide?**
*	**Business Goal:** A company-wide ranking always favors staff at the biggest store. We need to know who's excelling relative to their own store's scale.
**Queries**
```sql
--Which staff member is the top performer within their own store — not just company-wide?
with ranked_staff as (
	select st.staff_id, st.store_id, s.store_name,
			concat(st.first_name, ' ', st.last_name) as Full_name, 
			round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
	from staffs st
	join orders o on o.staff_id = st.staff_id
	join order_items oi on oi.order_id = o.order_id
	join stores s on s.store_id = st.store_id
	group by st.staff_id, st.store_id, s.store_name, st.first_name, st.last_name
	)

select staff_id, full_name, store_name, total_revenue, 
	   rank() over(partition by store_id order by total_revenue desc) as staff_rank
from ranked_staff
order by store_name, staff_rank 
```
**Result**

<img width="466" height="155" alt="image" src="https://github.com/user-attachments/assets/6c481bcc-6051-4ce6-a074-8e2d5bfb7c7d" />

____________
## **9. Revenue aside, which store actually converts the highest-value orders — and what does that mean for how we grow the smaller stores?**
**Average Order Value (AOV)** measures the average dollar amount spent each time a customer places an order.

**AOV = (Total Revenue) / (Number of Orders)**

By comparing AOV across stores, we can distinguish between locations that drive volume (many small sales) versus those that drive value (selling high-end premium bikes). This metric is essential for tailoring local marketing—deciding whether to push budget accessories or luxury mountain bikes.

**Queries**
```sql
select s.store_name,
	   round(sum(oi.quantity * oi.list_price * (1 - oi.discount)), 2) as total_revenue,
	   round(
		sum(oi.quantity * oi.list_price * (1 - oi.discount)) / count(distinct o.order_id),2) as Avg_order_value
from stores s
inner join orders o
	on o.store_id = s.store_id
inner join order_items oi
	on oi.order_id = o.order_id
group by s.store_name 
order by Avg_order_value desc
```
**Result**

<img width="359" height="119" alt="image" src="https://github.com/user-attachments/assets/725e6bf1-3f0a-49c5-8750-e07e1ce4d977" />

**Key Insight:**
AOV analysis reveals that **Rowlett Bikes** attracts the highest-spending clients, despite having the lowest total sales volume

There is a significant opportunity to grow revenue in Rowlett through traffic-driving marketing, as the store already excels at high-value conversions. Meanwhile, Baldwin remains the volume leader but could benefit from upselling strategies to increase its per-order value.

# Section 3: Customer & Inventory Insights


## 📈 Key Performance Indicators (KPIs)

After analyzing the data, I designed a summary report to track the health of the business. Here are the 3 critical areas:

### 1. Store Rankings (Revenue)
*Goal: Identify the strongest and weakest branches.*
| Rank | Store Name | Total Revenue | Status |
| :--- | :--- | :--- | :--- |
| 1 | Baldwin Bikes | ~$5,215,751 | **Top Performer** |
| 2 | Santa Cruz Bikes | ~$1,605,823 | Needs Marketing |
| 3 | Rowlett Bikes | $867,542 | Underperforming |

### 2. Staff Performance
*Goal: Reward top sellers.*
*   **Top Salesperson:** Marcelene Boyer ($2.6M Revenue)
*   **Insight:** The top 2 staff members generate more revenue than the bottom 6 combined.

### 3. Inventory Health (Stock)
*Goal: Avoid stockouts.*
*   **Total Items Out of Stock:** 25 distinct products.
*   **Critical Alert:** The "Baldwin" store is out of stock on high-demand "Road Bikes," potentially losing $50k/month in missed sales.
