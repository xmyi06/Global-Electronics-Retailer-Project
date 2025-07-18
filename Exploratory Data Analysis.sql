-- Calculates the total revenue.
SELECT SUM(unit_price*quantity) AS total_revenue
FROM stg_products p
JOIN stg_sales s ON p.prod_key = s.prod_key;

-- Calculates the YTD revenue.
WITH Total_Revenue AS
(
SELECT order_date, SUM(unit_price*quantity) AS total_revenue
FROM stg_products p
JOIN stg_sales s ON p.prod_key = s.prod_key
GROUP BY order_date
)
SELECT SUM(total_revenue) FROM Total_Revenue
WHERE order_date BETWEEN '2020-02-20' AND '2021-02-20';

-- Calcuates the total orders.
SELECT COUNT(DISTINCT order_num) AS total_orders
FROM stg_products p
JOIN stg_sales s ON p.prod_key = s.prod_key;

-- Calculates each currency's percentage of total revenue, highest to lowest.
WITH Currency_Total_Revenue AS
(
SELECT currency, SUM(unit_price*quantity) AS total_revenue
FROM stg_products p
JOIN stg_sales s ON p.prod_key = s.prod_key
GROUP BY currency
)
SELECT currency, CONCAT(ROUND(total_revenue / (SELECT SUM(total_revenue) FROM Currency_Total_Revenue) * 100,2), '%') AS pct_of_revenue
FROM Currency_Total_Revenue
GROUP BY currency
ORDER BY 2 DESC;

-- Calculates quarterly revenue for the US where applicable (Q1-Q4 for years 2016-2021). Created a temporary table for easier data manipulation.
CREATE TEMPORARY TABLE temp_us_qt_revenue AS
WITH US_Monthly_Revenue AS
(
SELECT 
	EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    (unit_price * quantity) AS total_revenue
FROM stg_sales s
JOIN stg_products p ON s.prod_key = p.prod_key
JOIN stg_customers c ON s.cust_key = c.cust_key
WHERE c.country = 'United States'
ORDER BY year, month
)
SELECT 
	year,
    CONCAT('Q', CEILING(month/3.0)) AS quarter,
    SUM(total_revenue) AS quarterly_revenue
FROM US_Monthly_Revenue
GROUP BY year, quarter
ORDER BY year, quarter;

SELECT * FROM temp_us_qt_revenue;

SELECT
	year,
    quarterly_revenue,
    LAG(quarterly_revenue, 4) OVER(ORDER BY year, quarter) AS prev_year_qtr_revenue,
    (quarterly_revenue - LAG(quarterly_revenue, 4) OVER(ORDER BY year, quarter)) / NULLIF(LAG(quarterly_revenue, 4) OVER(ORDER BY year, quarter),0) AS yoy_quaterly_revenue_change
 FROM temp_us_qt_revenue;

-- Calculates % YoY change over quarters for the US.
WITH Qtr_Comparison AS
(
SELECT
	year,
    quarter,
    quarterly_revenue,
    LAG(quarterly_revenue, 4) OVER(ORDER BY year, quarter) AS prev_year_qtr_revenue,
    ((quarterly_revenue - LAG(quarterly_revenue, 4) OVER (ORDER BY year, quarter)) / NULLIF(LAG(quarterly_revenue, 4) OVER(ORDER BY year, quarter),0)) AS yoy_qtr_change
FROM temp_us_qt_revenue
)
SELECT
	year,
    quarter, 
    prev_year_qtr_revenue,
  CONCAT(ROUND(yoy_qtr_change * 100, 2),'%') AS pct_yoy_qtr_change
FROM Qtr_Comparison
WHERE prev_year_qtr_revenue IS NOT NULL;

-- Used previous logic to calculate quarterly orders for the US. 
CREATE TEMPORARY TABLE temp_us_qt_orders AS
WITH Monthly_Orders AS
(
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(*) AS orders
FROM stg_sales s
JOIN stg_products p ON p.prod_key = s.prod_key
JOIN stg_customers c ON c.cust_key = s.cust_key
WHERE c.country = 'United States'
GROUP BY year, month
)
SELECT
	year, 
    CONCAT('Q', CEILING(month/3.0)) AS quarter,
    SUM(orders) AS quarterly_orders
FROM Monthly_Orders
GROUP BY year, quarter
ORDER BY year, quarter;

SELECT * FROM temp_us_qt_orders;

SELECT	
	year,
	quarter,
    quarterly_orders,
    LAG(quarterly_orders, 4) OVER(ORDER BY year, quarter) AS prev_yr_qtr_ct,
   ((quarterly_orders - LAG(quarterly_orders, 4) OVER (ORDER BY year, quarter)) / NULLIF(LAG(quarterly_orders, 4) OVER(ORDER BY year, quarter), 0)) AS yoy_qtr_change
FROM temp_qt;

-- Calculates average % YoY growth for the US.
WITH Qtr_Comparison_US AS (
SELECT	
	year,
	quarter,
    quarterly_orders,
    LAG(quarterly_orders, 4) OVER(ORDER BY year, quarter) AS prev_yr_qtr_ct,
    (quarterly_orders - LAG(quarterly_orders, 4) OVER (ORDER BY year, quarter)) / NULLIF(LAG(quarterly_orders, 4) OVER(ORDER BY year, quarter), 0) AS yoy_qtr_change
FROM temp_qt
) 
SELECT
	quarter,
	CONCAT(ROUND(AVG(yoy_qtr_change) * 100,2),'%') AS avg_yoy_growth
FROM Qtr_Comparison
WHERE yoy_qtr_change IS NOT NULL
GROUP BY quarter;

-- Calculates AOV per month for the US.
WITH AOV_US AS 
(
SELECT
	EXTRACT(year FROM  order_date) AS year,
    EXTRACT(month FROM order_date) AS month,
    SUM(unit_price * quantity) AS total_revenue,
	COUNT(DISTINCT order_num) AS total_orders
FROM stg_sales s
JOIN stg_products p ON p.prod_key = s.prod_key
JOIN stg_customers c ON c.cust_key = s.cust_key
WHERE c.country = 'United States'
GROUP BY year, month
)
SELECT *, total_revenue / total_orders AS aov
FROM AOV_US
ORDER BY year, month;
