# SQL-BikeStore-Sales-Analysis
## 📑 Overview

This project involves analyzing a relational database for a bike store chain to help the business owner make data-driven decisions.

## 🎯 Objectives:
- Sales Analysis: identifying top-selling products and seasonal trends.
- Customer Insights: segmenting customers based on purchasing behavior (RFM).
- Inventory Management: detecting low-stock items and dead stock.

## 🛠️ Tools:
- SQL Server (T-SQL)
- Key Concepts: JOINS, CTEs, Window Functions, Aggregate Functions.

## 📂 Dataset:

"BikeStores" from https://www.sqlservertutorial.net


## Database Diagram:

<img width="742" height="602" alt="image" src="https://github.com/user-attachments/assets/ff5cfe93-e231-4d8b-b490-4a833102632c" />

____________
# 📊 Business Problems & Solutions

## **❓ 1. Which cities have the highest customer concentration?**
*   **Business Goal:** Identify location hotspots for potential marketing campaigns. The result is cities ranked from highest to lowest based on the number of customers
  
**🚀 Queries**
```sql
SELECT city, COUNT(customer_id) as number_of_customers
FROM customers
GROUP BY city
ORDER BY number_of_customers DESC;
```
**Result**

<img width="296" height="382" alt="image" src="https://github.com/user-attachments/assets/b7b5893a-5038-425d-b244-baa8200bed38" />

**💡 Key Insight:**
Customer density is highest in New York State, specifically in the NYC suburbs (Mount Vernon, Scarsdale, Floral Park).

Strategic Recommendation: Since Mount Vernon and Scarsdale are wealthy areas, we should tailor marketing campaigns in these cities to feature higher-end "Premium" bikes rather than budget models.

## **❓ 2. Which product categories (e.g., Mountain Bikes, Road Bikes) drive the most revenue?**
*   **Business Goal:** Identify and understand product demand

**🚀 Queries**

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

**💡 Key Insight:**
"Mountain Bikes" account for 35% of total revenue, making them our most important category. We should prioritize keeping these in stock over "Children Bicycles," which have high volume but low profit margins.

## **❓ 3. Which specific products are our "Best Sellers" by quantity sold?**
*	**Business Goal:** Identify popular items
  
**🚀 Queries**
```sql
select p.product_name, sum(o.quantity) as total_sold_quantity
from products p
inner join order_items o on o.product_id = p.product_id
group by p.product_name
order by total_sold_quantity desc
```
**Result**

<img width="469" height="541" alt="image" src="https://github.com/user-attachments/assets/237ab263-87c0-48fc-bdcc-9332c384f435" />

**💡 Key Insight:**
While **Electra** dominates the top 4 spots, the product types reveal that our best-sellers are exclusively "Cruiser" and "Comfort" bikes aimed at casual riders

Strategic Recommendation: Since distinct "Girl's" and "Women's" models appear frequently in the top 20, we should target marketing campaigns toward families and female demographics, rather than just male-dominated competitive cycling.

## **❓ 4. Which brands contribute the most to our total sales volume?**
*	**Business Goal:** identify brands that sold the most 

**🚀 Queries**
```sql
select b.brand_name, sum(o.quantity) total_sold
from brands b
inner join products p on p.brand_id = b.brand_id
inner join order_items o on o.product_id = p.product_id
group by b.brand_name
order by total_sold desc
```
**Result**

<img width="194" height="226" alt="image" src="https://github.com/user-attachments/assets/93f6654e-2f46-4fe8-ad8b-9e802b9f7aee" />


## **❓ 5. How do our three stores rank in terms of total revenue generated?**
**🚀 Queries**
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

<img width="235" height="120" alt="image" src="https://github.com/user-attachments/assets/788bbbdf-0fd1-4b7c-900b-e755c685e2fa" />

**💡 Key Insight:**
Baldwin Bikes drives ~68% of the company's total revenue. It generates more sales than the other two locations combined.

The company is over-reliant on the NY market (Baldwin). The Rowlett store (Texas) is significantly underperforming, generating only 16% of what Baldwin generates. We need to investigate if this is a location issue, a staffing issue, or a lack of local marketing in Texas.

## **❓ 6. Which staff members are the top performers in terms of revenue?**

**🚀 Queries**
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

<img width="290" height="180" alt="image" src="https://github.com/user-attachments/assets/b7266aa7-3194-47d2-a2ba-a3661a3b4bc0" />


## **❓ 7. How many products are currently out of stock (0 quantity) in each store?**

**🚀 Queries**
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

<img width="238" height="125" alt="image" src="https://github.com/user-attachments/assets/06c4ab5c-5491-41a4-ba1e-dbb416602b41" />

**💡 Key Insight:**
we can see the correlation here: high sales = high stockouts

we are likely holding too much Safety sock in low-selling store. We should reallocate that inventory to Baldwin to prevent losing sales in high-traffic location

## **❓ 8. How has revenue performed year-over-year (2016 vs 2017 vs 2018)?**

**🚀 Queries**
```sql
select datepart(year, o.order_date) as Year, round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue_over_year
from order_items oi
inner join orders o on o.order_id = oi.order_id
group by datepart(year, o.order_date)
```
**Result**

<img width="205" height="103" alt="image" src="https://github.com/user-attachments/assets/49189586-68da-4ead-a20c-f72357659640" />


## **❓ 9. Is there a seasonal trend? Which month usually generates the highest sales?**

**🚀 Queries**
```sql
select datepart(month, o.order_date) as Month, 
	   round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue_over_month
from order_items oi
inner join orders o on o.order_id = oi.order_id
group by datepart(month, o.order_date)
order by Month asc
```
**Result**

<img width="237" height="296" alt="image" src="https://github.com/user-attachments/assets/bb5634b7-64c2-4dc7-ae64-86c6b820a494" />


## **❓ 10. Who are our top VIP customers based on total spending?**

**🚀 Queries**
```sql
select c.customer_id, 
		concat(c.first_name, ' ', c.last_name) as Full_name,
		round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as total_spendings
from customers c 
inner join orders o 
	on o.customer_id = c.customer_id
inner join order_items oi
	on oi.order_id = o.order_id
group by c.customer_id, c.first_name, c.last_name
order by total_spendings desc
```
**Result**

<img width="342" height="462" alt="image" src="https://github.com/user-attachments/assets/398b54ee-454e-49b1-ac58-9e622a296114" />


## **❓ 11. What is the average order value (AOV) for each store?**

AOV = (Total Number of Orders) / (Total Revenue)

**🚀 Queries**
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



## 📈 Key Performance Indicators (KPIs)

After analyzing the data, I designed a summary report to track the health of the business. Here are the 3 critical areas:

### 1. 🏪 Store Rankings (Revenue)
*Goal: Identify the strongest and weakest branches.*
| Rank | Store Name | Total Revenue | Status |
| :--- | :--- | :--- | :--- |
| 1 | Baldwin Bikes | ~$5,215,751 | 🏆 Top Performer |
| 2 | Santa Cruz Bikes | ~$1,605,823 | ⚠️ Needs Marketing |
| 3 | Rowlett Bikes | $867,542 | 📉 Underperforming |

### 2. 🧑‍💼 Staff Performance
*Goal: Reward top sellers.*
*   **Top Salesperson:** Marcelene Boyer ($2.6M Revenue)
*   **Insight:** The top 2 staff members generate more revenue than the bottom 6 combined.

### 3. 📦 Inventory Health (Stock)
*Goal: Avoid stockouts.*
*   **Total Items Out of Stock:** 15 distinct products.
*   **Critical Alert:** The "Baldwin" store is out of stock on high-demand "Road Bikes," potentially losing $50k/month in missed sales.
