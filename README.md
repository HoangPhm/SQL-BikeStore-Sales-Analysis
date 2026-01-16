# SQL-BikeStore-Sales-Analysis
**Overview**

This project involves analyzing a relational database for a bike store chain to help the business owner make data-driven decisions.

**Objectives:**
- Sales Analysis: identifying top-selling products and seasonal trends.
- Customer Insights: segmenting customers based on purchasing behavior (RFM).
- Inventory Management: detecting low-stock items and dead stock.

**Tools:**
- SQL Server (T-SQL)
- Key Concepts: JOINS, CTEs, Window Functions, Aggregate Functions.

**Dataset:**

"BikeStores" from https://www.sqlservertutorial.net


**Database Diagram:**

<img width="742" height="602" alt="image" src="https://github.com/user-attachments/assets/ff5cfe93-e231-4d8b-b490-4a833102632c" />

____________
## 📊 Business Problems & Solutions

### Category 1: Sales Trends & Performance
**1. Which cities have the highest customer concentration?**
*   **Business Goal:** Identify location hotspots for potential marketing campaigns.
  
### 🚀 Queries

```sql
SELECT city, COUNT(customer_id) as number_of_customers
FROM customers
GROUP BY city
ORDER BY number_of_customers DESC;
```
### Result
<img width="296" height="382" alt="image" src="https://github.com/user-attachments/assets/b7b5893a-5038-425d-b244-baa8200bed38" />

**2. Which product categories (e.g., Mountain Bikes, Road Bikes) drive the most revenue?**

### 🚀 Queries

``sql
select c.category_name, 
		round(sum(o.quantity * o.list_price * (1 - o.discount)),2) as total_revenue
from categories c
inner join products p on c.category_id = p.category_id
inner join order_items o on o.product_id = p.product_id
group by c.category_name
order by c.category_name desc
``
### Result

<img width="254" height="198" alt="image" src="https://github.com/user-attachments/assets/a729853d-4b5f-4fc9-a407-434a12897c41" />
