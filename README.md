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
___________
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
order by total_revenue desc
```
**Result**

<img width="251" height="178" alt="image" src="https://github.com/user-attachments/assets/eff1c53f-128f-44f0-9433-3872178f7afb" />

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
**Result** (showing 3 representative categories: Mountain Bikes, Road Bikes, Cruisers Bicycles)

Category - Mountain Bikes

<img width="497" height="119" alt="image" src="https://github.com/user-attachments/assets/a32f86da-dcac-41aa-98f0-0a563819bd1f" />

Category - Road Bikes

<img width="479" height="121" alt="image" src="https://github.com/user-attachments/assets/5586ec88-5446-425f-9304-76f1904f3858" />

Category - Cruisers Bicycles

<img width="564" height="126" alt="image" src="https://github.com/user-attachments/assets/a6e965ce-3958-48ae-9317-6c23ce676573" />


**Key Insight:**

Top sellers within each category are dominated almost entirely by a single brand:
- Trek for Road Bikes
- Electra for Cruisers Bicycles
- Mountain Bikes is the exception with Surly, Trek, and Heller all in top 5

There's also a striking volume gap: Mountain Bikes and Cruisers bestsellers each sell 130–170 units, while Road Bikes model tops out at just 43 (roughly a quarter of the volume). 

Since Road Bikes were flagged as a high-revenue category (as seen in Question 1), Road Bikes likely carry a much higher price point per unit than Cruisers or Mountain Bikes, worth confirming against list price data

This suggests Road Bikes and Cruiser/Mountain Bikes may need different inventory strategies --> lower stock depth but higher price protection for Road Bikes, versus higher-volume restocking for Cruisers and Mountain Bikes.

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

**Key Insight:**

Elektra and Trek together account for ~63% of all units sold, more than the rest combined. This lines up directly with what we saw in Question 2, where Elektra swept Cruisers and Trek dominated Road Bikes

The tail is long and thin: the bottom 5 brands (Pure Cycles, Haro, Heller, Ritchey, Strider) together make up just 13.9% of volume, with Strider barely registering at 0.35% --> risk between supplier - concentration

Worth investigating further: is this concentration driven by genuine customer preference, or by these two brands simply having more SKUs/shelf space than the others? If it's the latter, there may be untapped demand for underrepresented brands that isn't being given a fair chance to sell

____________
## **4. What is our year-over-year revenue growth rate, and is the business accelerating or slowing down?**
*	**Business Goal:** to know the rate of change, not just the raw number

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

**Key Insight:**

A strong +42% increase from 2016 to 2017, followed by a -47% drop from 2017 to 2018. Rather than a steady growth, the business swung from acceleration to contraction within a year

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

The cumulative revenue curve confirms what Q4 hinted at: 
- growth was strong throughout 2016–2017 (swings between -39% and +42% month to month), but the real story is in early 2018 (April 2018) hit $817,921.86, the single highest month in the dataset, growing +124.71% over March.

But right after that, the data falls off a cliff: 
- May 2018 appears to be missing entirely (the table jumps from month 4 straight to month 6), and from June 2018 onward, monthly revenue collapses to near-zero ($189 to $11K, versus $150K–$800K in every prior month). This pattern, a sharp and total drop rather than a gradual decline --> strongly suggests incomplete data for the second half of 2018, not a genuine business collapse.

This directly explains the -47% YoY drop from Q4: it isn't a real annual decline, it's an artifact of comparing a full year (2017) against a partial year (2018) that effectively stops being populated after April.


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

**Key Insight:**

Baldwin Bikes drives 68% of the company's total revenue, more than the other two combined.
The company is over-reliant on the NY market. 

Rowlett (Texas) generates only 16% of what Baldwin generates --> worth investigating whether this is a location, staffing or marketing issue
____________
## **7. Who are the staff members actually driving the most revenue?**
*	**Business Goal:** Identify top-performing salespeople company-wide, as a baseline before digging deeper into store-level performance

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

Marcelene Boyer ($2.62M) and Venita Daniel ($2.59M) together generate more than the remaining 7 staff combined.

There's also a sharp cliff after rank 2: revenue drops from ~$2.6M (Boyer, Daniel) to under $900K for the next 4 staff (Serrano, Copeland, Vargas, Terrell) (~roughly a 3x gap). Since Baldwin alone drives ~68% of company revenue (Q6), it's likely that Boyer and Daniel are simply staffed at Baldwin, and this ranking mostly reflects store size, not individual sales skill.
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

**Key Insight:**

The result confirms the assumption from Question 7:
- Boyer and Daniel are both from Baldwin store, so their company-wide lead partly reflects store size, not just individual skill.

Genna Serrano (Santa Cruz) and Kali Vargas (Rowlett) are each #1 in their own store, but would be invisible in a flat company-wide ranking --> worth factoring into how performance is recognized or rewarded.

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
___________
## **10. Which cities have the highest customer concentration, and where should we focus local marketing?**

**Queries**
```sql
select city, count(customer_id) as number_of_customers
from customers
group by city
order by number_of_customers desc
```

**Result**

<img width="283" height="363" alt="image" src="https://github.com/user-attachments/assets/57f78f32-2b47-4bc7-a52e-a1bc1383840d" />

**Key Insight:**

Customer density is highest in New York State, specifically NYC suburbs (Mount Vernon, Scarsdale, Floral Park)
___________
## **11.Beyond simple top spenders, which customers are our most valuable and loyal — and which ones are at risk of churning?**
*	**Business Goal:** Knowing who spent the most historically doesn't tell us who to retain. We need to separate loyal repeat buyers from one-time high spenders who may never return

**Queries**
```sql
with rfm_base as (
	--CTE 1: calculate raw Recency, Frequency, Monetary
	select c.customer_id, 
			datediff(day, max(o.order_date), (select max(order_date) from orders)) as recency,
			count(distinct o.order_id) as frequency,
			round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as monetary
	from customers c 
	join orders o on o.customer_id = c.customer_id
	join order_items oi	on oi.order_id = o.order_id
	group by c.customer_id
),
rfm_scored as (
	-- CTE 2: use result from CTE 1 to compute quartiles
	select customer_id, recency, frequency, monetary,
		   ntile(4) over(order by recency desc) r_score,
		   ntile(4) over(order by frequency asc) f_score,
		   ntile(4) over(order by monetary asc) m_score
	from rfm_base
)

select customer_id, r_score + f_score + m_score as rfm_total,
	   case when r_score + f_score + m_score >= 10 then 'Champion'
			when r_score + f_score + m_score >= 7 then 'Loyal'
			else 'At risk' end as segment
from rfm_scored
order by rfm_total desc
```

**Result**

<img width="265" height="244" alt="image" src="https://github.com/user-attachments/assets/303d30b7-3668-4fcc-9b18-cf1eea547465" />
<img width="231" height="181" alt="image" src="https://github.com/user-attachments/assets/9d9f8f09-3369-4a10-b3b4-41e7f5eed873" />
<img width="222" height="107" alt="image" src="https://github.com/user-attachments/assets/eeff3cfe-3d0a-4b0a-bfb4-8c3337c11c13" />

number of customer in each segment:

<img width="189" height="83" alt="image" src="https://github.com/user-attachments/assets/6cd1d850-752c-47ea-97e4-a0ae1b28e675" />

**Key Insight:**

The RFM segmentation separates customers by more than just spend:
- Champions (score 10-12) are buying recently, frequently, and spending the most. These are the customers a simple top-spenders list would also catch. 
- Loyal customers (score 7-9) are buying consistently but haven't reached top-spend status yet, good candidates for upselling.
- At Risk customers (score ≤6) have a purchase history but have gone quiet or infrequent recently. These could still look like "good customers" under a simple total-spending ranking, but RFM flags them as needing re-engagement before they're lost.

____________
## **12. Given where our customers are concentrated, do we have enough stock in the right stores?**

**Queries**
```sql
select st.store_name,
count(product_id) as out_of_stock
from stocks s
inner join stores st on st.store_id = s.store_id
where quantity = 0
group by st.store_name
order by out_of_stock desc
```
**Result**

<img width="243" height="95" alt="image" src="https://github.com/user-attachments/assets/cae54f1c-b844-47c5-9b7e-45920fae9f0e" />

**Key Insight:**

A clear correlation between high sales and high stockouts.

We're likely over-holding safety stock in the lower-selling store while under-stocking the high-traffic one --> worth reallocating inventory toward Baldwin to avoid losing sales
____________
## 📈 Key Performance Indicators (KPIs)

After analyzing the data, I designed a summary report to track the health of the business. Here are the 3 critical areas:

## 1. Sales Analysis

**Goal:** Track what's selling and when, to guide inventory and marketing timing.

*	**Top Category:** Mountain Bikes (35% of total revenue)
*	**Best-Selling Model:** Surly Ice Cream Truck Frameset - 2016 (167 units, Mountain Bikes category)
*	**Peak Month:** April recorded $817,921.86 in revenue, the highest single month in the dataset (+124.71% over March)
*	**Data Quality Note:** Revenue reporting appears incomplete after April 2018 (monthly figures drop to near-zero from May onward); all 2018 YoY and seasonal comparisons should be treated as partial-year and re-validated once complete data is available.

## 2. Customer Insights (RFM Segmentation)

**Goal:** Distinguish loyal, high-value customers from one-time spenders at risk of churning.

* 	**Champions:** Customers scoring 10-12 — buying recently, frequently, and spending the most. These are the customers most likely to respond well to loyalty or referral programs.
* 	**Loyal**: Customers scoring 7-9 — consistent buyers who haven't reached top-spend status yet. Strong candidates for upselling.
* 	**At Risk:** Customers scoring ≤6 — have a purchase history but have gone quiet or infrequent recently. Priority targets for win-back campaigns before they're lost entirely.
* 	**Insight:** A simple "top spenders" list would have missed the At Risk group entirely — RFM is what makes this distinction visible.

## 3. Staff Performance
**Goal:** Reward top sellers.*

*   **Top Salesperson:** Marcelene Boyer ($2.6M Revenue)
*   **Insight:** The top 2 staff members generate more revenue than the bottom 6 combined.

## 4. Inventory Management

**Goal:** Avoid stockouts on high-demand items and prevent capital from being tied up in dead stock.

*	**Total Items Out of Stock:** 25 distinct products.
*	**Critical Alert:** Stockouts are concentrated at Baldwin Bikes — the highest-revenue store — meaning the business is likely losing sales at exactly the location with the most demand, while lower-selling stores may be holding excess safety stock that could be reallocated.
*	**Next Step:** This analysis currently only captures point-in-time stockouts. Extending it with a quarter-over-quarter sales trend (using LAG()) would help detect dead stock — slow-moving inventory tying up capital — which is a gap not yet covered here relative to the stated objective.



