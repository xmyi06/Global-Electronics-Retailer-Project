# Global-Electronics-Retailer-Project

## Background & Overview
The Global Electronics Retailer (GER) is a fictitious company selling 2,517 distinct electronics products under eight categories in eight countries. The dataset contains transactional, customer, product, sales, and exchange rate data.

## Project Purpose
I designed this project to transform raw data into actionable insights using data cleaning, exploratory data analysis, and visualization through MySQL and Power BI. My main objectives were to expand on these skills:
- Data-Driven Decision-Making: I recognized patterns in regional trends, income, top-selling products, demographics, and other business metrics useful for creating marketing strategies.
- Data Modeling: I built relationships among multiple tables in MySQL and Power BI.
- SQL: I wrote complex queries containing CTES, JOINs, window functions, aggregations, and filtering clauses. I used temporary tables to support my analysis.
- Power BI: I created interactive dashboards with filters, drill-through features, and measures using DAX.
- Storytelling: In this README, I translated my entire technical analysis into a high-level summary to display my stakeholder awareness and communication skills.

# Data Structure Overview
The Global Electronics Retailer database consists of 6 tables (customers, data_dictionary, exchange_rates, products, sales, and stores), with a total row count of 89,469 records. Using MySQL, all tables were inspected for data cleaning and content familiarization before proceeding with analysis. The records in data_dictionary and exchange_rates tables were supplemental and not included in the main analysis. 

The ERD (Entity Relationship Diagram) below visualizes the relationship between the 4 tables. 

![Picture of the Global Electronics Retailer ERD](<Global Electronics Retailer Project - ERD.png>)

Sales Table - Fact Table, Primary Key: order_num. Contains quantitative transactional data with cust_key, store_key, and prod_key as foreign keys.
Stores Table - Dimension Table, Primary Key: store_key. Contains information about store location, size (square feet), and open date. 
Customers Table - Dimension Table, Primary Key: cust_key. Contains information about customer demographics such as gender, location, and birthday.
Products Table - Dimension Table, Primary Key: prod_key. Contains quantitative data about products such as brand, category, subcategory, and measures such as unit price and unit cost.

The ERD was generated in MySQL. Preliminary data cleaning and an EDA were also performed in MySQL before moving on to data visualization in Power BI. View these files in the repository.

# Executive Summary
Audience: Chief Revenue Officer (CRO), Chief Operating Officer (COO), Head of Sales

*Note: On the Power BI dashboard, Regional Statistics include Washington, DC as a state.*

## Problem Statement
Recent data reveals a drastic decline in GER’s sales across all eight markets, likely due to a global external factor such as the COVID-19 pandemic. This downturn has significantly reduced revenue and market stability.

### Key Indicators:
- Total revenue fell from $18.3M in 2019 to $9.3M in 2020 (-49% YoY).
- Cumulative losses reached $9M by 2021, with no rebound thus far.
- The greatest losses were observed in Utah, Iowa, Oregon, Wyoming, and South Carolina.
- 19 states and Washington, DC experienced a negative % YoY change in 2020.

## Proposed Solution
Launch a 20% discount for the XD233, X2330, ED182, AND 31600 across online channels, targeting older customers who contribute to an ARPU of $2.05K and a UPT of 7.76. Invest in advertisements on high-traffic days (Tuesdays and Fridays), emphasizing the products’ reliability, durability, and convenience. Consider adding a bulk purchase discount. Complete further analysis on complementary goods such as monitors, keyboards, and mice that can also be promoted. Evaluate PC sales, customer retention, and online traffic into Q2 2020 and adjust the marketing strategy as needed.

## Detailed Insights - USA
- The US consistently held over 45% of GRE’s market share, exceeding 50% throughout the pandemic period and increasing to 62.25% by early Q1 2021.
- California, Texas, New York, Florida, and Pennsylvania are the highest contributing states to revenue.
- In Q4 2020*, the online channel generated a large portion of revenue – $131,130.20 (20.44% of total revenue).
- Most customers buying online products are ages 65-90, with most purchases being computers from Wide World Importers, Adventure Works, and The Phone Company.
- For this demographic, order volume is the highest on Tuesdays and Fridays, averaging 6.00 and 4.67 orders, respectively.
- Overall ARPU is $1.79K and UPT is 7.24. For ages 65-90, ARPU is $2.05K and UPT is 7.76, signaling that high-cost orders and bulk purchasing is a pattern for all demographics.

*Q4 2020 is used to aid decision-making because it is the most recent full quarter.

