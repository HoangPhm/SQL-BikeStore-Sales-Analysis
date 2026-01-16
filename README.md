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

**Database Diagram:**

<img width="742" height="602" alt="image" src="https://github.com/user-attachments/assets/ff5cfe93-e231-4d8b-b490-4a833102632c" />

____________
## 📊 Business Problems & Solutions

### Category 1: Sales Trends & Performance
**1. Which cities have the highest customer concentration?**
*   **Business Goal:** Identify location hotspots for potential marketing campaigns.
*   
### 🚀 Queries

```sql
SELECT city, COUNT(customer_id) as number_of_customers
FROM customers
GROUP BY city
ORDER BY number_of_customers DESC;

