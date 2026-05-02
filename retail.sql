create table customers(
	customer_id integer primary key,
	first_name varchar(50),
	last_name varchar(50),
	phone varchar(20),
	email varchar(100),
	street varchar(100),
	city varchar(50),
	state varchar(100),
	zip_code varchar(50)
);


CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY,
    store_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(20)
);


create table staffs(
	staff_id integer primary key,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(50),
	phone varchar(50),
	active varchar(10),
	store_id integer,
	manager_id varchar(10)
);


create table orders(
	order_id integer primary key,
	customer_id integer,
	order_status varchar(50),
	order_date date,
	required_date date,
	shipped_date varchar(20),
	store_id integer,
	staff_id integer,
	foreign key (customer_id) references customers(customer_id)
);


CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100)
);


CREATE TABLE brands (
    brand_id INTEGER PRIMARY KEY,
    brand_name VARCHAR(100)
);


CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    brand_id INTEGER,
    category_id INTEGER,
    model_year INTEGER,
    list_price NUMERIC(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);


CREATE TABLE order_items (
    order_id INTEGER,
    item_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    list_price NUMERIC(10,2),
    discount NUMERIC(5,2),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE stocks (
    store_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (store_id, product_id)
);


-- 1) Store-wise and Region-wise sales analysis

-- 1.1) Store-wise sales analysis

create view store_wise_sales_analysis as
select 
	  s.store_id,
	  s.store_name,
	  sum(oi.quantity * oi.list_price * (1-oi.discount)) as total_sales
from stores s
join orders o on s.store_id = o.store_id
join order_items oi on o.order_id = oi.order_id
group by s.store_id, s.store_name;

select * from store_wise_sales_analysis;


-- 1.2) Region-wise sales analysis (state-based)

create view region_wise_sales_analysis as
select 
	  s.state, 
	  sum(oi.quantity * oi.list_price * (1-oi.discount)) as state_sales
from stores s
join orders o on s.store_id = o.store_id
join order_items oi on o.order_id = oi.order_id
group by s.state;

select * from region_wise_sales_analysis;




-- 2) Product-wise sales and inventory trends

-- 2.1) Product-wise sales 

create view product_wise_sales as
select 
	  p.product_id,
	  p.product_name,
	  sum(oi.quantity) as total_sold,
	  sum(oi.quantity * oi.list_price * (1-oi.discount)) as total_sales_value
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
order by total_sales_value desc;

select * from product_wise_sales;


-- 2.2) Product inventory trends

create view product_inventory_trends as
SELECT 
	  p.product_id, 
	  p.product_name, 
	  sum(s.quantity) as total_stock
FROM products p
JOIN stocks s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
order by total_stock desc;

select * from product_inventory_trends;


-- 3) Staff performance reports

create view staff_performance_report as
select 
	  s.staff_id,
	  s.first_name,
	  s.last_name,
	  count(distinct oi.order_id) as orders_handeled,
	  sum(oi.quantity * oi.list_price * (1-oi.discount)) as total_sales_value
from staffs s
join orders o on s.store_id = o.store_id
join order_items oi on o.order_id = oi.order_id
group by s.staff_id
order by total_sales_value desc;

select * from staff_performance_report;
	  


-- 4) Customer orders and order frequency

SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  COUNT(DISTINCT o.order_id) AS orders_count,
  AVG(EXTRACT(EPOCH FROM o.order_date)::BIGINT) AS avg_order_date_epoch
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;




-- o Revenue and discount analysissis


















































