# E-Commerce-Sales-analysis

## Table of contents

- [Project Overview](#project-overview)
- [Data Preparation](#data-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Results and Findings](#results-and-findings)
- [Recommendations](#recommendations)
  
### Project Overview

This project involves analyzing retail sales data to gain insights into customer behavior, product performance, and revenue trends. The dataset was processed to ensure accuracy and completeness, uncovering patterns and relationships within the data. The final analysis highlights key metrics and trends, providing actionable insights for decision-making.

### Data Source 

`Sales 1(in).xlsx` is an Excel file  containing detailed sales data. It includes information such as dates, customer demographics, product details, and financial metrics like costs, revenues, and profits. This dataset serves as the foundation for analyzing sales performance, identifying trends, and uncovering insights into customer behavior and product success. 

### Tools

- Excel
- PostgreSQL
- PowerBI

### Data Preparation

Initially, we used Excel to perform the following tasks:

 1.Convert the file to `CSV`: For easier import into PostgreSQL.                                              
 2.Organize the data: To ensure it was structured properly for further analysis.                             
 3.Preliminary cleaning: Such as removing unnecessary columns or correcting simple data inconsistencies before importing.

 ### Data Cleaning

In the data cleaning phase, the following steps were performed:

 1.Missing Values: Identified and handled missing or incomplete entries.                                       
 2.Duplicate Records: Checked for and eliminated any duplicate entries to ensure each record was unique and accurate.                             
 3.Data Consistency: Standardized data formats (e.g., dates, numbers) to maintain uniformity across the dataset.                                          
 4.Data Transformation: Converted the data into a structured format suitable for analysis, ensuring all necessary transformations were applied.

 
 ### Exploratory Data Analysis
 
EDA focused on examining the sales data to identify important trends, measure key statistics, and gather insights on sales performance, customer demographics, and product profitability.

- What is the sales trend?
- How does revenue grow from one month to the next?
- Which products are contributing the most to revenue and profit?
- What is the sales distribution across different customer genders?
- How do sales differ by product category?
- What does the sales data tell us about different customer age groups?
- What is the total revenue for each year?
- What are the sales trends for different product categories over time?

### Data Analysis

This query calculates the total revenue for each month, compares it with the previous month's revenue, and shows the percentage growth. It helps track monthly revenue trends and measure how sales are growing over time.
```sql
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
```
This query calculates the distribution of sales by customer gender, showing the count of each gender and its percentage of the total sales. It helps analyze the gender breakdown of the customer base.
```sql
SELECT * ,
	   ROUND((freq/SUM(freq) OVER() )*100,2) AS percentage
FROM (SELECT customer_gender, COUNT(*) AS freq
        FROM sales_cleaned
        GROUP BY customer_gender
        ORDER BY freq DESC) AS t1;
```
### Results and Findings

- Sales peak in winter with December reaching the highest sales, followed by October and November.
- In summer, June sees the highest sales, followed by May.
- Sales experience a drop after June, reaching the lowest in July.
- Bikes are the top-selling product category.
- The largest buyer demographic is adults aged 35-64.
- Gender distribution is nearly equal: 52% male and 48% female.
- The highest revenue comes from USA and Australia.
- Products priced over $540 see a significant decrease in average order quantity, dropping to 1.47 items per order.
- The overall profit margin across all products and categories is 37.78%.

### Recommendations

- Maximize sales during peak seasons: Focus on boosting sales through targeted promotions in December, October, and November during the winter, as well as in June and May during the 
summer, to capitalize on the highest sales months.
- Target adults aged 35-64: Tailor marketing strategies to appeal to this key demographic.
- Leverage high-revenue regions: Strengthen marketing and promotions in the USA and Australia to further boost sales.
- Adjust pricing strategy: Reconsider pricing or offer discounts for products over $540 to encourage larger orders.
- Optimize for top products: Maintain or increase stock of popular products like Bikes to ensure sustained sales and profitability.

### Limitations
- Seasonal Variability: The sales trends may be influenced by seasonal factors, and the analysis does not account for specific external  events (e.g., holidays, local events) that may have impacted sales.                                               
- Product Pricing Impact: While pricing is correlated with order quantity, other factors such as customer behavior or competitor pricing are not considered.                                                      
- Limited Time Frame: The analysis is based on historical data within a specific period, so future trends may differ.             
- Outliers: There is some extreme values that effect our calculations.


