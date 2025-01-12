CREATE TABLE sales_ata (
    Date DATE,
    Day TEXT,
    Month TEXT,
    Year TEXT,
    Customer_Age TEXT,
    Age_Group TEXT,
    Customer_Gender TEXT,
    Country TEXT,
    State TEXT,
    Product_Category TEXT,
    Sub_Category TEXT,
    Product TEXT,
    Order_Quantity TEXT,
    Unit_Cost TEXT,
    Unit_Price TEXT,
    Profit TEXT,
    Cost TEXT,
    Revenue TEXT
);

CREATE TABLE sales_staging1 (LIKE sales_ata);

INSERT INTO sales_staging1
SELECT * FROM sales_ata;

-- duplicate

SELECT  Date, Day, Month, Year, Customer_Age, 
		Age_Group, Customer_Gender, Country, State, 
		Product_Category, Sub_Category, Product, Order_Quantity, 
		Unit_Cost, Unit_Price, Profit, Cost, Revenue, COUNT(*)
FROM sales_staging1
GROUP BY Date, Day, Month, Year, Customer_Age, 
		Age_Group, Customer_Gender, Country, State, 
		Product_Category, Sub_Category, Product, Order_Quantity, 
		Unit_Cost, Unit_Price, Profit, Cost, Revenue
HAVING COUNT(*)> 1;

SELECT * FROM sales_staging1 
WHERE Date = '8/12/2015'
 AND  Day = '12'
 AND  Month = 'August'
 AND  Year = '2015'
 AND  Customer_Age ='57'
 AND  Age_Group = 'Adults (35-64)'
 AND  Customer_Gender ='F'
 AND  Country = 'United States'
 AND  State = 'California'
 AND  Product_Category = 'Accessories'
 AND  Sub_Category = 'Bottles and Cages'
 AND  Product = 'Water Bottle - 30 oz.'
 AND  Order_Quantity = '9'
 AND  Unit_Cost = '2'
 AND  Unit_Price = '5'
 AND  Profit = '26'
 AND  Cost = '18'
 AND  Revenue = '44';

 -- SO THERE IS A DUPLICATE
 -- DELETE

CREATE TABLE sales_cleaned (
    date DATE,
    day TEXT,
    month TEXT,
    year TEXT,
    customer_age TEXT,
    age_group TEXT,
    customer_gender TEXT,
    country TEXT,
    state TEXT,
    product_category TEXT,
    sub_category TEXT,
    product TEXT,
    order_quantity TEXT,
    unit_cost TEXT,
    unit_price TEXT,
    profit TEXT,
    cost TEXT,
    revenue TEXT,
	row_num INT
);

INSERT INTO sales_cleaned
    SELECT  *,
            ROW_NUMBER() OVER (
            PARTITION BY Date, Day, Month, Year, Customer_Age, Age_Group, Customer_Gender, Country, 
                         State, Product_Category, Sub_Category, Product, Order_Quantity, Unit_Cost, 
                         Unit_Price, Profit, Cost, Revenue
        ) AS row_num
FROM sales_staging;		

SELECT * FROM sales_cleaned ORDER BY row_num DESC;

DELETE FROM sales_cleaned 
WHERE row_num > 1;

-- DROP row_num

ALTER TABLE sales_cleaned
DROP COLUMN row_num;

-- FIND NULLS 

SELECT * FROM sales_cleaned 
WHERE date IS NULL
   OR day IS NULL
   OR month IS NULL
   OR year IS NULL
   OR customer_age IS NULL
   OR age_group IS NULL
   OR customer_gender IS NULL
   OR country IS NULL
   OR state IS NULL
   OR product_category IS NULL
   OR sub_category IS NULL
   OR product IS NULL
   OR order_quantity IS NULL
   OR unit_cost IS NULL
   OR unit_price IS NULL
   OR profit IS NULL
   OR cost IS NULL
   OR revenue IS NULL;

-- NO NULLS 

SELECT * FROM sales_cleaned;
SELECT * FROM sales_staging1;

-- STANDARDIZE DATA AMD DATATYPE

SELECT * FROM sales_cleaned;

ALTER TABLE sales_cleaned
ALTER COLUMN day TYPE INTEGER USING day::INTEGER;

ALTER TABLE sales_cleaned
ALTER COLUMN month TYPE VARCHAR(20) USING month::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN year TYPE VARCHAR(4) USING year::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN customer_age TYPE INTEGER USING customer_age::INTEGER;

ALTER TABLE sales_cleaned
ALTER COLUMN age_group TYPE VARCHAR(50) USING age_group::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN customer_gender TYPE VARCHAR(1) USING customer_gender::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN country TYPE VARCHAR(100) USING country::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN state TYPE VARCHAR(100) USING state::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN product_category TYPE VARCHAR(100) USING product_category::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN sub_category TYPE VARCHAR(100) USING sub_category::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN product TYPE VARCHAR(200) USING product::VARCHAR;

ALTER TABLE sales_cleaned
ALTER COLUMN order_quantity TYPE INTEGER USING order_quantity::INTEGER;

ALTER TABLE sales_cleaned
ALTER COLUMN unit_cost TYPE NUMERIC(10, 2) USING unit_cost::NUMERIC;

ALTER TABLE sales_cleaned
ALTER COLUMN unit_price TYPE NUMERIC(10, 2) USING unit_price::NUMERIC;

ALTER TABLE sales_cleaned
ALTER COLUMN profit TYPE NUMERIC(10, 2) USING profit::NUMERIC;

ALTER TABLE sales_cleaned
ALTER COLUMN cost TYPE NUMERIC(10, 2) USING cost::NUMERIC;

ALTER TABLE sales_cleaned
ALTER COLUMN revenue TYPE NUMERIC(10, 2) USING revenue::NUMERIC;


UPDATE sales_cleaned
SET revenue = order_quantity * unit_price;

SELECT *
FROM sales_cleaned
WHERE cost<>order_quantity*unit_cost;

UPDATE sales_cleaned
SET profit = revenue - cost;

-- EXPLORATORY DATA ANALYSIS

SELECT * FROM sales_cleaned;

SELECT * ,
	   ROUND((freq/SUM(freq) OVER() )*100,2) AS percentage
FROM (SELECT customer_gender, COUNT(*) AS freq
        FROM sales_cleaned
        GROUP BY customer_gender
        ORDER BY freq DESC) AS t1;

SELECT *, ROUND((freq/SUM(freq) OVER() )*100,2) AS percentage
FROM (SELECT product_category, COUNT(*) AS freq
        FROM sales_cleaned
        GROUP BY product_category
        ORDER BY freq DESC) AS t2;

SELECT *, ROUND((freq/SUM(freq) OVER() )*100,2) AS percentage
FROM (SELECT product_category, customer_gender, COUNT(*) AS freq
        FROM sales_cleaned
        GROUP BY product_category, customer_gender
        ORDER BY freq DESC) AS t2;

SELECT *, 
       ROUND((freq / SUM(freq) OVER() )*100, 2) AS percentage
FROM (SELECT age_group,COUNT(*) AS freq -- represent total customer
	    FROM sales_cleaned
		GROUP BY age_group
		ORDER BY freq DESC) AS t3;


SELECT year, SUM(profit)
FROM sales_cleaned
GROUP BY year
ORDER BY year;

SELECT year, month, 
       SUM(revenue) AS total_revenue,
       LAG(SUM(revenue)) OVER(PARTITION BY year ORDER BY month) 
	   AS previous_month_revenue,
       ROUND((SUM(revenue) - LAG(SUM(revenue)) OVER(PARTITION BY year ORDER BY month)) / 
       NULLIF(LAG(SUM(revenue)) OVER(PARTITION BY year ORDER BY month), 0) * 100, 2) 
	   AS revenue_growth
FROM sales_cleaned
GROUP BY year, month
ORDER BY year, month;

SELECT product, 
       SUM(revenue) AS total_revenue,
       SUM(profit) AS total_profit,
       COUNT(*) AS total_orders
FROM sales_cleaned
GROUP BY product
ORDER BY total_profit ASC
LIMIT 10;


SELECT AVG(order_quantity) AS avg_order_quantity, 
       MIN(order_quantity) AS min_order_quantity, 
       MAX(order_quantity) AS max_order_quantity, 
       STDDEV(order_quantity) AS order_quantity_stddev
FROM sales_cleaned;

SELECT AVG(unit_cost) AS avg_unit_cost, 
       MIN(unit_cost) AS min_unit_cost, 
       MAX(unit_cost) AS max_unit_cost, 
       STDDEV(unit_cost) AS unit_cost_stddev
FROM sales_cleaned;

SELECT AVG(unit_price) AS avg_unit_price, 
       MIN(unit_price) AS min_unit_price, 
       MAX(unit_price) AS max_unit_price, 
       STDDEV(unit_price) AS unit_price_stddev
FROM sales_cleaned;	   
    
SELECT AVG(profit) AS avg_profit, 
       MIN(profit) AS min_profit, 
       MAX(profit) AS max_profit, 
       STDDEV(profit) AS profit_stddev
FROM sales_cleaned;


SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY unit_cost) AS Q1_unit_cost,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY unit_cost) AS Q2_unit_cost,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY unit_cost) AS Q3_unit_cost
FROM sales_cleaned;    

SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY unit_price) AS Q1_unit_price,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY unit_price) AS Q2_unit_price,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY unit_price) AS Q3_unit_price
FROM sales_cleaned;

SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY order_quantity) AS Q1_order_quantity,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY order_quantity) AS Q2_order_quantity,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY order_quantity) AS Q3_order_quantity
FROM sales_cleaned;

SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY profit) AS Q1_profit,
       	PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY profit) AS Q2_profit,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY profit) AS Q3_profit
FROM sales_cleaned;
