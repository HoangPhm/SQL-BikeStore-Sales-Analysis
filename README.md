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
*   **Key Insight:** New York City has the highest density (20% of total customers), while smaller cities like San Pablo show unexpected growth.
*   **SQL Skill:** `GROUP BY`, `ORDER BY`, `COUNT`

**2. Which product categories drive the most revenue?**
*   **Business Goal:** Focus inventory on high-performing categories.
*   **Key Insight:** "Mountain Bikes" account for 40% of total revenue, whereas "Children Bicycles" have high volume but low margin.
*   **SQL Skill:** `JOINS`, `SUM`, `Aggregate Functions`

### Category 2: Inventory Management
**3. How many products are currently out of stock?**
*   **Business Goal:** Prevent revenue loss due to stockouts.
*   **Key Insight:** The "Baldwin" store has 15 distinct items with 0 stock, specifically in the "Road Bikes" category.
*   **SQL Skill:** `HAVING`, `Conditional Filtering`


---
### 📂 Project Structure
To see the actual SQL queries, please check the file:
- [**analysis_queries.sql**](link-to-your-file-here) - Contains the solution code for all 12 business questions.
