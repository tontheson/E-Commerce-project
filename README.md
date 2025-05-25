# [SQL] Explore Ecommerce Dataset
## I. Project Overview
  This repository contains SQL queries and analysis based on the Google Analytics Ecommerce dataset available on Google BigQuery. The project aims to provide insights into user behavior, website traffic, and transaction data to support decision-making in digital marketing and ecommerce strategies.
## II. Dataset Description
  The dataset used in this project is the Google Analytics sample dataset on BigQuery:
- ga_sessions: Detailed session-level data from August 1, 2017, including user interactions, traffic sources, geographic data, and ecommerce transactions.
  You can explore the dataset directly on [Google BigQuery's Public Datasets](https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801).
## III. Project Objectives
- Analyze user demographics and acquisition channels.
- Identify high-performing marketing channels and referral sources.
- Understand user session behavior, including bounce rates and session duration.
 -Evaluate ecommerce performance metrics like transactions, revenue, and conversion rates.
## IV. Project Objectives
- Analyze user demographics and acquisition channels.
- Identify high-performing marketing channels and referral sources.
- Understand user session behavior, including bounce rates and session duration.
- Evaluate ecommerce performance metrics like transactions, revenue, and conversion rates.
## Requirements
- Access to Google BigQuery
- Basic to intermediate SQL knowledge
## V. Explore Data set
#Query 01: Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
- SQL query
<pre> ```sql WITH get_1month_cohort AS ( SELECT CASE WHEN 1 = 1 THEN "201701" END AS month, COUNT(CASE WHEN hits.eCommerceAction.action_type = "2" AND product.isImpression IS NULL THEN fullVisitorId END) AS num_product_view, COUNT(CASE WHEN hits.eCommerceAction.action_type = "3" AND product.isImpression IS NULL THEN fullVisitorId END) AS num_addtocart, COUNT(CASE WHEN hits.eCommerceAction.action_type = "6" AND product.isImpression IS NULL THEN fullVisitorId END) AS num_purchase FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201701*`, UNNEST(hits) AS hits, UNNEST(hits.product) AS product ) ``` </pre>
## Contributing
  Contributions are welcome! Please open an issue first to discuss potential improvements or submit a pull request.
## Contact
For any questions or suggestions, please contact:
- Ton The Son
- Email: tontheson@gmail.com
- LinkedIn: https://www.linkedin.com/in/tontheson/
