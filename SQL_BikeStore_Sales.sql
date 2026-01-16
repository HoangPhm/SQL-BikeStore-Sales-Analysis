--Query 1
SELECT city, COUNT(customer_id) as number_of_customers
FROM customers
GROUP BY city
ORDER BY number_of_customers DESC;

--Q2
select c.category_name, 
		round(sum(o.quantity * o.list_price * (1 - o.discount)),2) as total_revenue
from categories c
inner join products p on c.category_id = p.category_id
inner join order_items o on o.product_id = p.product_id
group by c.category_name
order by c.category_name desc

--Q3
select p.product_name, sum(o.quantity) as total_sold_quantity
from products p
inner join order_items o on o.product_id = p.product_id
group by p.product_name
order by total_sold_quantity desc

--Q4
select b.brand_name, sum(o.quantity) total_sold
from brands b
inner join products p on p.brand_id = b.brand_id
inner join order_items o on o.product_id = p.product_id
group by b.brand_name
order by total_sold desc

--Q5
select s.store_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from stores s
inner join orders o on o.store_id = s.store_id
inner join order_items oi on oi.order_id = o.order_id
group by s.store_name
order by total_revenue desc

--Q6
select st.staff_id,
		concat(st.first_name, ' ', st.last_name) as Full_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from staffs st
inner join orders o on o.staff_id = st.staff_id
inner join order_items oi on oi.order_id = o.order_id
group by st.staff_id, st.first_name, st.last_name
order by total_revenue desc

--Q7
select st.store_name,
count(product_id) as out_of_stock
from stocks s
inner join stores st on st.store_id = s.store_id
where quantity = 0
group by st.store_name
order by out_of_stock desc

--Q8
select datepart(year, o.order_date) as Year, round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue_over_year
from order_items oi
inner join orders o on o.order_id = oi.order_id
group by datepart(year, o.order_date)

--Q9
select datepart(month, o.order_date) as Month, 
	   round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue_over_month
from order_items oi
inner join orders o on o.order_id = oi.order_id
group by datepart(month, o.order_date)
order by Month asc

--Q10
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

--Q11
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
