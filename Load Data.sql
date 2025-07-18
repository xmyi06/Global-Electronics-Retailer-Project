SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 9.2/Uploads/Sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE customers
(
cust_key INT PRIMARY KEY,
gender CHAR(50),
name VARCHAR(50),
city VARCHAR(50),
state_code VARCHAR(50),
state VARCHAR(50),
zip_code VARCHAR(50),
country VARCHAR(100),
continent CHAR(50),
birthday DATE
)
;

CREATE TABLE products
(
prod_key INT PRIMARY KEY,
prod_name VARCHAR(100),
brand VARCHAR(100),
color VARCHAR(20),
unit_cost DECIMAL(10,2),
unit_price DECIMAL(10,2),
subcategory_key INT,
subcategory VARCHAR(100),
category_key INT,
category VARCHAR(100)
)
;

ALTER TABLE order_num
ADD PRIMARY KEY (store_key);


CREATE TABLE sales
(
order_num INT,
line_item INT,
order_date DATE,
delivery_date DATE, 
PRIMARY KEY (order_num, line_item),
cust_key INT REFERENCES customers(cust_key),
store_key INT REFERENCES stores(store_key),
prod_key INT REFERENCES products(prod_key),
quantity INT,
currency CHAR(5)
)
;

select * FROM exchange_rates;

CREATE TABLE stores
(
store_key INT PRIMARY KEY,
country VARCHAR(50),
state VARCHAR(50),
square_meters INT,
open_date DATE
)
;

CREATE TABLE exchange_rates
(date DATE,
currency CHAR(5),
exchange_rate DOUBLE
)
;

WITH row_ct AS
(
SELECT 'customers' AS 'Table', COUNT(*) AS 'Total Rows' FROM customers
UNION ALL
SELECT 'data_dictionary', COUNT(*) FROM data_dictionary
UNION ALL
SELECT 'exchange_rates', COUNT(*) FROM exchange_rates
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'stores', COUNT(*) FROM stores
)
SELECT *
FROM row_ct;
