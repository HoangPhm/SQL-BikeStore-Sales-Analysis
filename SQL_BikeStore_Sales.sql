--Query 1
select c.category_name, 
		round(sum(o.quantity * o.list_price * (1 - o.discount)),2) as total_revenue
from categories c
join products p on c.category_id = p.category_id
join order_items o on o.product_id = p.product_id
group by c.category_name
order by total_revenue desc

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

--Query 4
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

--Query 5
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

--Query 6
select s.store_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from stores s
join orders o on o.store_id = s.store_id
join order_items oi on oi.order_id = o.order_id
group by s.store_name
order by total_revenue desc

--Query 7
select st.staff_id,
		concat(st.first_name, ' ', st.last_name) as Full_name, 
		round(sum(oi.quantity * oi.list_price * (1 - oi.discount)),2) as total_revenue
from staffs st
join orders o on o.staff_id = st.staff_id
join order_items oi on oi.order_id = o.order_id
group by st.staff_id, st.first_name, st.last_name
order by total_revenue desc

--Query 8
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

--Query 9
select s.store_name,
	   round(sum(oi.quantity * oi.list_price * (1 - oi.discount)), 2) as total_revenue,
	   round(
		sum(oi.quantity * oi.list_price * (1 - oi.discount)) / count(distinct o.order_id),2) as Avg_order_value
from stores s
join orders o on o.store_id = s.store_id
join order_items oi on oi.order_id = o.order_id
group by s.store_name 
order by Avg_order_value desc

--Query 10
select city, count(customer_id) as number_of_customers
from customers
group by city
order by number_of_customers desc

--Query 11
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

--Query 12
select st.store_name,
count(product_id) as out_of_stock
from stocks s
join stores st on st.store_id = s.store_id
where quantity = 0
group by st.store_name
order by out_of_stock desc
