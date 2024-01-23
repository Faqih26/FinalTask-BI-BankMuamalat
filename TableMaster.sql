use rakamin;
create or replace view table_master as 
SELECT 
	c.CustomerID,
    row_number() over(order by STR_TO_DATE(o.date,'%m/%d/%Y') asc) as order_id,
    concat(c.FirstName," ",c.LastName) as full_name,
    c.CustomerPhone,
    c.CustomerAddress,
	STR_TO_DATE(o.date,'%m/%d/%Y') as order_date,
	pc.CategoryName as category_name,
	p.ProdName as product_name,
	p.Price as product_price,
	quantity as order_qty,
	(Quantity * Price) as Revenue,
	CustomerEmail as cust_email,
	CustomerCity as cust_city
FROM rakamin.customers as c
inner join orders as o on c.CustomerID = o.CustomerID
inner join products as p on p.ProdNumber = o.ProdNumber
inner join productcategory as pc on pc.CategoryID = p.Category
