--Query 1
select c.category_name, 
		round(sum(o.quantity * o.list_price * (1 - o.discount)),2) as total_revenue
from categories c
inner join products p on c.category_id = p.category_id
inner join order_items o on o.product_id = p.product_id
group by c.category_name
order by c.category_name desc

--Query 2
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

--Query 3
select b.brand_name, sum(oi.quantity) total_sold,
	   round(100.0 * sum(oi.quantity) / sum(sum(oi.quantity)) over(),2) pct_of_total
from brands b
join products p on p.brand_id = b.brand_id
join order_items oi on oi.product_id = p.product_id
group by b.brand_name
order by total_sold desc

--Query 5
select s.store_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from stores s
inner join orders o on o.store_id = s.store_id
inner join order_items oi on oi.order_id = o.order_id
group by s.store_name
order by total_revenue desc

--Query 6
select st.staff_id,
		concat(st.first_name, ' ', st.last_name) as Full_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from staffs st
inner join orders o on o.staff_id = st.staff_id
inner join order_items oi on oi.order_id = o.order_id
group by st.staff_id, st.first_name, st.last_name
order by total_revenue desc

--Query 7
select st.store_name,
count(product_id) as out_of_stock
from stocks s
inner join stores st on st.store_id = s.store_id
where quantity = 0
group by st.store_name
order by out_of_stock desc

--Query 8
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

--Query 9
select datepart(month, o.order_date) as Month, 
	   round(sum(oi.quantity * oi.list_price * (1-oi.discount)),2) as revenue_over_month
from order_items oi
inner join orders o on o.order_id = oi.order_id
group by datepart(month, o.order_date)
order by Month asc

--Query 10
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

--Query 11
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
