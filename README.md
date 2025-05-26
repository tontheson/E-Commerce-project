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
## V. Requirements
- Access to Google BigQuery
- Basic to intermediate SQL knowledge
## VI. Explore Data set
### Query 01: Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
- SQL query:
<pre>
SELECT
  format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
  SUM(totals.visits) AS visits,
  SUM(totals.pageviews) AS pageviews,
  SUM(totals.transactions) AS transactions,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;</pre>
- Result:
<pre>
| month   | visits | pageviews | transactions |
|---------|--------|-----------|--------------|
| 201701  | 64694  | 257708    | 713          |
| 201702  | 62192  | 233373    | 733          |
| 201703  | 69931  | 259522    | 993          |
</pre>
### Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
- SQL query:
<pre>SELECT
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;</pre>
- Result (Top 10):
<pre>
| source                   | total_visits | total_no_of_bou   | bounce_rate  |
|--------------------------|--------------|-------------------|--------------|
| google                   | 38400        | 19798             | 51,55729167  |
| (direct)                 | 19891        | 8606              | 43,2657986   |
| youtube.com              | 6351         | 4238              | 66,72964887  |
| analytics.google.com     | 1972         | 1064              | 53,95537525  |
| Partners                 | 1788         | 936               | 52,34899329  |
| m.facebook.com           | 669          | 430               | 64,27503737  |
| google.com               | 368          | 183               | 49,72826087  |
| dfa                      | 302          | 124               | 41,05960265  |
| sites.google.com         | 230          | 97                | 42,17391304  |
| facebook.com             | 191          | 102               | 53,40314136  |
</pre>
### Query 03: Revenue by traffic source by week, by month in June 2017
- SQL query:
<pre>
with 
month_data as(
  SELECT
    "Month" as time_type,
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  WHERE p.productRevenue is not null
  GROUP BY 1,2,3
  order by revenue DESC
),

week_data as(
  SELECT
    "Week" as time_type,
    format_date("%Y%W", parse_date("%Y%m%d", date)) as week,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  WHERE p.productRevenue is not null
  GROUP BY 1,2,3
  order by revenue DESC
)

select * from month_data
union all
select * from week_data
order by time_type;</pre>
- Result (top 30):
<pre>| time_type   |   month | source            |   revenue |
|:------------|--------:|:------------------|----------:|
| Month       |  201706 | mail.google.com   |   2563.13 |
| Month       |  201706 | mail.aol.com      |     64.85 |
| Month       |  201706 | sites.google.com  |     39.17 |
| Month       |  201706 | l.facebook.com    |     12.48 |
| Month       |  201706 | chat.google.com   |     74.03 |
| Month       |  201706 | bing              |     13.98 |
| Month       |  201706 | (direct)          |  97333.6  |
| Month       |  201706 | dealspotr.com     |     72.95 |
| Month       |  201706 | groups.google.com |    101.96 |
| Month       |  201706 | phandroid.com     |     52.95 |
| Month       |  201706 | google.com        |     23.99 |
| Month       |  201706 | search.myway.com  |    105.94 |
| Month       |  201706 | dfa               |   8862.23 |
| Month       |  201706 | google            |  18757.2  |
| Month       |  201706 | yahoo             |     20.39 |
| Month       |  201706 | youtube.com       |     16.99 |
| Week        |  201724 | mail.google.com   |   2486.86 |
| Week        |  201725 | mail.google.com   |     76.27 |
| Week        |  201724 | dealspotr.com     |     72.95 |
| Week        |  201726 | (direct)          |  14914.8  |
| Week        |  201725 | (direct)          |  27295.3  |
| Week        |  201722 | (direct)          |   6888.9  |
| Week        |  201725 | sites.google.com  |     25.19 |
| Week        |  201725 | groups.google.com |     38.59 |
| Week        |  201726 | dfa               |   3704.74 |
| Week        |  201723 | youtube.com       |     16.99 |
| Week        |  201726 | yahoo             |     20.39 |
| Week        |  201723 | chat.google.com   |     74.03 |
</pre>
### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
- SQL query
<pre>
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;
</pre>
- Result:
<pre>
| month  | avg_pageviews_per_user  | avg_pageviews_per_session  |
|--------|-------------------------|----------------------------|
| 201706 | 94.020501               | 316.865589                 |
| 201707 | 124.237552              | 334.056560                 |
</pre>
### Query 05: Average number of transactions per user that made a purchase in July 2017
- SQL query
<pre>
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;
</pre>
- Result:
<pre>
| month  | Avg_total_transactions_per_user |
|--------|---------------------------------|
| 201707 | 4.16390041493776                |
</pre>
### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
- SQL query:
<pre>
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    ((sum(product.productRevenue)/sum(totals.visits))/power(10,6)) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
  and totals.transactions>=1
group by month;
</pre>
- Result:
<pre>
| month  | avg_revenue_by_user_per_visit |
|--------|-------------------------------|
| 201707 | 43.856598348051243            |
</pre>
### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered
- SQL query:
<pre>
With henley_buyer AS (--- xác định những người mua Henley trong tháng 7/2017
  SELECT
    DISTINCT fullVisitorId
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST (hits) AS hits,
    UNNEST (hits.product) AS product
  WHERE 1 = 1
    AND _table_suffix BETWEEN '20170701' AND '20170731'
    AND totals.transactions >= 1
    AND product.productRevenue IS NOT NULL
    AND product.v2ProductName = "YouTube Men's Vintage Henley"
  )

SELECT --- xác định những sản phẩm khác họ đã mua
  product.v2ProductName AS other_purchased_products,
  SUM(product.productQuantity) AS quantity
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS raw_data,
  UNNEST (hits) AS hits,
  UNNEST (hits.product) AS product
INNER JOIN henley_buyer
ON raw_data.fullVisitorId = henley_buyer.fullVisitorId
WHERE 1 = 1
  AND _table_suffix BETWEEN '20170701' AND '20170731'
  AND totals.transactions >= 1
  AND product.productRevenue IS NOT NULL
  AND product.v2ProductName != "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC;
</pre>
- Result (Top 20):
<pre>
| other_purchased_products                                  | quantity |
|-----------------------------------------------------------|----------|
| Google Sunglasses                                         | 20       |
| Google Women's Vintage Hero Tee Black                     | 7        |
| SPF-15 Slim & Slender Lip Balm                            | 6        |
| Google Women's Short Sleeve Hero Tee Red Heather          | 4        |
| YouTube Men's Fleece Hoodie Black                         | 3        |
| Google Men's Short Sleeve Badge Tee Charcoal              | 3        |
| Crunch Noise Dog Toy                                      | 2        |
| Android Women's Fleece Hoodie                             | 2        |
| YouTube Twill Cap                                         | 2        |
| Google Doodle Decal                                       | 2        |
| Android Wool Heather Cap Heather/Black                    | 2        |
| 22 oz YouTube Bottle Infuser                              | 2        |
| Red Shine 15 oz Mug                                       | 2        |
| Google Men's Short Sleeve Hero Tee Charcoal               | 2        |
| Android Men's Vintage Henley                              | 2        |
| Recycled Mouse Pad                                        | 2        |
| Google Men's 100% Cotton Short Sleeve Hero Tee Red        | 1        |
| YouTube Women's Short Sleeve Hero Tee Charcoal            | 1        |
| Google Men's Performance Full Zip Jacket Black            | 1        |
| Google Slim Utility Travel Bag                            | 1        |
</pre>
### Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.
- SQL query:
<pre>
with product_data as(
select
    format_date('%Y%m', parse_date('%Y%m%d',date)) as month,
    count(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) as num_product_view,
    count(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) as num_add_to_cart,
    count(CASE WHEN eCommerceAction.action_type = '6' and product.productRevenue is not null THEN product.v2ProductName END) as num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,UNNEST(hits) as hits
,UNNEST (hits.product) as product
where _table_suffix between '20170101' and '20170331'
and eCommerceAction.action_type in ('2','3','6')
group by month
order by month
)

select
    *,
    round(num_add_to_cart/num_product_view * 100, 2) as add_to_cart_rate,
    round(num_purchase/num_product_view * 100, 2) as purchase_rate
from product_data;
</pre>
- Result:
<pre>
| month  | num_product_view | num_add_to_cart  | num_purchase  | add_to_cart_rate | purchase_rate  |
|--------|------------------|------------------|---------------|------------------|----------------|
| 201701 | 25787            | 7342             | 2143          | 28.47            | 8.31           |
| 201702 | 21489            | 7360             | 2060          | 34.25            | 9.59           |
| 201703 | 23549            | 8782             | 2977          | 37.29            | 12.64          |
</pre>
## VII. Contributing
  Contributions are welcome! Please open an issue first to discuss potential improvements or submit a pull request.
## VIII. Contact
For any questions or suggestions, please contact:
- Ton The Son
- Email: tontheson@gmail.com
- LinkedIn: https://www.linkedin.com/in/tontheson/
