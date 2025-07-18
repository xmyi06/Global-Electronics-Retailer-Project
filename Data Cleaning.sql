-- =============================================
-- CUSTOMERS TABLE DATA CLEANING
-- =============================================

-- SECTION 1: Create Staging Table, Identify & Remove Duplicates

CREATE TABLE stg_customers
LIKE customers;

INSERT INTO stg_customers
SELECT * FROM customers;

WITH customers_duplicate AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY cust_key, gender, `name`, city, state_code, state, zip_code, country, continent, birthday) AS row_ct
FROM customers
)
SELECT *
FROM customers_duplicate
WHERE row_ct > 1;

-- SECTION 2: Standardize Data

-- Create ProperCase function for standardization and transferability.

DELIMITER $$ 
CREATE FUNCTION ProperCase(str VARCHAR(50)) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
DECLARE result VARCHAR(50);
DECLARE i INT DEFAULT 1;
DECLARE len INT;
DECLARE current_char CHAR(1);
DECLARE prev_char CHAR(1);

IF str IS NULL OR str = ''
THEN RETURN NULL;
END IF;

SET str = LOWER(TRIM(str));
SET len = CHAR_LENGTH(str);

SET result = UPPER(SUBSTRING(str, 1, 1));

WHILE i < len DO
SET i = i + 1;
SET current_char = SUBSTRING(str, i, 1);
SET prev_char = SUBSTRING(str, i-1, 1);

IF prev_char IN(' ', '', '.' '_') THEN
SET result = CONCAT(result, ' ', UPPER(current_char));
ELSE
SET result = CONCAT(result, current_char);
END IF;
END WHILE;

RETURN result;
END $$
DELIMITER ;

-- Test ProperCase function on different strings. Returns expected results.

SELECT ProperCase('san francisco') AS city;
SELECT ProperCase('San Francisco') AS city;
SELECT ProperCase('SAN FRANCISCO') AS city;

UPDATE stg_customers
SET city = ProperCase(city);

-- Verify ProperCase function usability.

SELECT city, ProperCase(city)
FROM stg_customers;

-- Identify cities containing "St". Change to "St.".

WITH st_cities AS
(
SELECT city, ProperCase(city)
FROM stg_customers
WHERE city LIKE 'St %'
)
UPDATE stg_customers
SET city = CONCAT(SUBSTRING(city, 1, 2), '.', '', SUBSTRING(city, 3))
WHERE city LIKE 'St %';

SELECT city
FROM stg_customers
WHERE city LIKE 'St.%';

-- Verify cities containing "ys" do not need an apostrophe ("y's"). Verify with Google Searches for each city.

SELECT DISTINCT city, country, zip_code
FROM stg_customers
WHERE city LIKE '%ys';

-- Identify cities containing "Dc." Change to "DC".

WITH dc_cities AS
(
SELECT DISTINCT
city,
country,
zip_code
FROM stg_customers
WHERE city LIKE '%Dc'
)
UPDATE stg_customers
SET city = CONCAT(SUBSTRING(city, 1, LENGTH(city)-2), 'DC')
WHERE city IN (SELECT city FROM dc_cities);

SELECT city
FROM stg_customers
WHERE city LIKE '%DC';

-- SECTION 3: Null/Blank Values

-- Return null/blank values.

SELECT * FROM stg_customers;
CREATE PROCEDURE null_summary()
SELECT
	SUM(cust_key IS NULL OR cust_key = '') AS null_cust_key,
    SUM(gender IS NULL OR gender = '') AS null_gender,
    SUM(`name` IS NULL OR `name` = '') AS null_name,
    SUM(city IS NULL OR city = '') AS null_city,
    SUM(state_code IS NULL OR state_code = '') AS null_state_code,
    SUM(state IS NULL OR state = '') AS null_state,
    SUM(zip_code IS NULL OR zip_code = '') AS null_zip_code,
    SUM(country IS NULL OR country = '') AS null_country,
    SUM(continent IS NULL OR continent = '') AS null_continent,
	SUM(birthday IS NULL) AS null_birthday

FROM stg_customers;

CALL null_summary();

# Verify reasonable ages. (Max: 90, Min: 23)

SELECT MAX(birthday), MIN(birthday)
FROM stg_customers;

-- =============================================
-- PRODUCTS TABLE DATA CLEANING
-- =============================================

-- SECTION 1: Create Staging Table, Identify & Remove Duplicates

CREATE TABLE stg_products
LIKE products;

INSERT INTO stg_products
SELECT * FROM products;

SELECT * FROM products;

-- Identify duplicate values. None found.

WITH products_duplicate AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY prod_key, prod_name, brand, color, unit_cost, unit_price, subcategory_key, subcategory, category_key, category) AS row_ct
FROM stg_products
)
SELECT *
FROM products_duplicate
WHERE row_ct > 1;

-- SECTION 2: Standardize Data

-- Change subcategory 'MP4&MP3' to 'MP4 & MP3' for readability.

SELECT DISTINCT subcategory
FROM stg_products;

SELECT DISTINCT subcategory, CONCAT(CONCAT(SUBSTRING(subcategory, 1, 3)), ' ','&', ' ', (CONCAT(SUBSTRING(subcategory, -3, 3))))
FROM stg_products
WHERE subcategory = 'MP4&MP3';

UPDATE stg_products
SET subcategory = CONCAT(CONCAT(SUBSTRING(subcategory, 1, 3)), ' ','&', ' ', (CONCAT(SUBSTRING(subcategory, -3, 3))))
WHERE subcategory = 'MP4&MP3';

-- Fix letter casing.

UPDATE stg_products
SET subcategory = ProperCase(subcategory)
WHERE subcategory = 'cell phones accessories';

UPDATE stg_products
SET subcategory = ProperCase(subcategory)
WHERE subcategory = 'cameras and camcorders';

UPDATE stg_products
SET subcategory = ProperCase(subcategory)
WHERE subcategory = 'cell phones';

SELECT subcategory, CONCAT('Smart ', ProperCase(SUBSTRING((subcategory), 7, 6)),' & PDAS')
FROM stg_products
WHERE subcategory = 'smart phones & pdas';

UPDATE stg_products 
SET subcategory = CONCAT('Smart ', ProperCase(SUBSTRING((subcategory), 7, 6)),' & PDAS')
WHERE subcategory = 'smart phones & pdas';

-- =============================================
-- SALES TABLE DATA CLEANING
-- =============================================

-- SECTION 1: Create Staging Table, Identify & Remove Duplicates

CREATE TABLE stg_sales
LIKE sales;

INSERT INTO stg_sales
SELECT * FROM sales;

WITH sales_duplicate AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY order_num, line_item, order_date, delivery_date, cust_key, store_key, prod_key, quantity, currency) AS row_ct
FROM sales
)
SELECT *
FROM sales_duplicate
WHERE row_ct > 1;

SELECT * FROM sales; 
SELECT DISTINCT currency FROM sales;

-- SECTION 2: Check Data

-- Verify reasonable order quantities. (Max: 10, Min: 1)

SELECT MAX(quantity), MIN(quantity)
FROM stg_sales;

-- Verify no irregular order/delivery dates.

SELECT order_date, delivery_date
FROM stg_sales
WHERE delivery_date < order_date AND
delivery_date IS NOT NULL;

SELECT COUNT(DISTINCT prod_name)
FROM stg_Products;

SELECT COUNT(DISTINCT category)
FROM stg_Products;

SELECT MAX(order_date)
FROM stg_sales;