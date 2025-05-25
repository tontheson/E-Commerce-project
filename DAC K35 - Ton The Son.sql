---Query01
SELECT
  SUBSTR(date, 1, 6) AS month,
  SUM(IFNULL(totals.visits,0)) AS visits, --- dùng ifnull để tránh sai lỗi khi tính tổng trường dữ liệu có thể chứa NULL
  SUM(IFNULL(totals.pageviews,0)) AS pageviews,
  SUM(IFNULL(totals.transactions,0)) AS transactions

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _table_suffix between '20170101' AND '20170331'
GROUP BY month
ORDER BY month;

--k cần dùng ifnull, thì nếu null thì sum nó cũng sẽ k tính
SELECT
  format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
  SUM(totals.visits) AS visits,
  SUM(totals.pageviews) AS pageviews,
  SUM(totals.transactions) AS transactions,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;

--mình có thể xài format_date để lấy dạng month theo cách mình muốn

---Query02
SELECT
  source,
  total_visits,
  total_no_of_bounces,
  ROUND(total_no_of_bounces/total_visits*100, 3) AS bounce_rate
FROM (
  SELECT  
  trafficSource.source AS source,
  SUM(IFNULL(totals.visits,0)) AS total_visits,
  SUM(IFNULL(totals.bounces,0)) AS total_no_of_bounces
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _table_suffix BETWEEN '20170701' AND '20170731'
  GROUP BY source)
ORDER BY total_visits DESC; --- dùng order ở select ngoài, nếu dùng trong subquery k có ý nghĩa và tiêu tốn tài nguyên.

--có thể viết ngắn gọn lại như thế này
SELECT
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;

---Query03
--- tính doanh thu theo source, theo week
SELECT
  'Week' AS time_type, 
  FORMAT_DATE('%G%V', PARSE_DATE('%Y%m%d', date)) AS time,
  trafficSource.source AS source,
  SUM(IFNULL(product.productRevenue/1000000, 0)) AS revenue
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST (hits) AS hits,
  UNNEST (hits.product) AS product
WHERE _table_suffix BETWEEN '20170601' AND '20170630'
GROUP BY time, source
UNION ALL
--- tính doanh thu theo source, theo month
SELECT
  'Month' AS time_type, 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time,
  trafficSource.source AS source,
  SUM(IFNULL(product.productRevenue/1000000, 0)) AS revenue
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST (hits) AS hits,
  UNNEST (hits.product) AS product
WHERE _table_suffix BETWEEN '20170601' AND '20170630'
GROUP BY time, source
ORDER BY revenue DESC;

-->
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
select * from week_data;
order by time_type
--nên order by time_type, để month vs week đc xếp thành các cụm riêng biệt


---Query04
WITH pageviews_purchase AS (
  SELECT
    LEFT(date, 6) AS month,
    ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId), 3) AS avg_pageviews_purchase

  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product

  WHERE 1 = 1
    AND _table_suffix BETWEEN '20170601' AND '20170731'
    AND totals.transactions >= 1
    AND product.productRevenue IS NOT NULL

  GROUP BY month
  ),
pageviews_non_purchase AS (
  SELECT
    LEFT(date, 6) AS month,
    ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId), 3) AS avg_pageviews_non_purchase

  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product

  WHERE 1 = 1
    AND _table_suffix BETWEEN '20170601' AND '20170731'
    AND totals.transactions IS NULL
    AND product.productRevenue IS NULL

  GROUP BY month
  )
SELECT
  pageviews_purchase.month,
  avg_pageviews_purchase,
  avg_pageviews_non_purchase
FROM pageviews_purchase
INNER JOIN pageviews_non_purchase
ON pageviews_purchase.month = pageviews_non_purchase.month;

-->
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

--câu 4 này lưu ý là mình nên dùng full join/left join, bởi vì trong câu này, phạm vi chỉ từ tháng 6-7, nên chắc chắc sẽ có pur và nonpur của cả 2 tháng
--mình inner join thì vô tình nó sẽ ra đúng. nhưng nếu đề bài là 1 khoảng thời gian dài hơn, 2-3 năm chẳng hạn, thì có tháng chỉ có nonpur mà k có pur
--thì khi đó inner join nó sẽ làm mình bị mất data, thay vì hiện số của nonpur và pur thì nó để trống


---Query05
SELECT 
  LEFT(date, 6) AS month,
  ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId), 3) AS Avg_total_transactions_per_user
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST (hits) AS hits,
  UNNEST (hits.product) AS product
WHERE 1 = 1
  AND _table_suffix BETWEEN '20170701' AND '20170731'
  AND totals.transactions >=1
  AND product.productRevenue IS NOT NULL
--- Chỗ này em hơi lấn cấn, nếu 1 người phát sinh giao dịch (transactions >= 1) là mặc đinh có doanh thu thì liệu có cần đến điều kiên thứ 2 không?
--do cơ chế ghi nhận record của bảng này nó vậy, nên mình mới gần ràng 2 đk để thống nhất vs nhau cho dễ lấy
--khi đi làm thì DE, IT, sẽ confirm logic cho mình, chứ mình k tự quyết định lấy đk như thế nào mới đúng
GROUP BY month;

-->
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;

---Query06
SELECT
  LEFT(date,6) AS month,
  ROUND(SUM(product.productRevenue)/(COUNT(totals.visits)*1000000), 2) AS avg_revenue_by_user_per_visit
  --- nếu UNNEST hits với 3 product, khi đó totals.visits có được đếm 3 lần? (sai lệch dữ liệu)
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST (hits) AS hits,
  UNNEST(hits.product) AS product
WHERE _table_suffix BETWEEN '20170701' AND '20170731'
  AND totals.transactions IS NOT NULL
  AND product.productRevenue IS NOT NULL
GROUP BY month;
-->
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    ((sum(product.productRevenue)/sum(totals.visits))/power(10,6)) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
  and totals.transactions>=1
group by month;


---Query07
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

--correct

---Query08
WITH raw_data AS (
  SELECT
    -- product.v2ProductName AS product_name,
    LEFT(date,6) AS month,
    COUNT(CASE WHEN hits.eCommerceAction.action_type = '2' THEN 1 END) AS num_product_view,
    COUNT(CASE WHEN hits.eCommerceAction.action_type = '3' THEN 1 END) AS num_addtocart,
    COUNT(CASE WHEN hits.eCommerceAction.action_type = '6' THEN 1 END) AS num_purchase
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product
  WHERE 1 = 1
    AND _table_suffix BETWEEN '20170101' AND '20170331'
  GROUP BY month
  ORDER BY month
  )
SELECT
  -- product_name,
  month,
  num_product_view,
  num_addtocart,
  num_purchase,
  ROUND(num_addtocart/num_product_view*100, 2) AS add_to_cart_rate,
  ROUND(num_purchase/num_product_view*100, 2) AS purchase_rate
FROM raw_data;
--- kết quả khác so với đáp án
--do thiếu đk ở phần num_purchase
--khi làm thì mình nên tách ra thành từng part nhỏ để dễ dàng control logic lấy data
--chứ ghi gộp count(case when) như trên tới lúc sai là k biết sai ở chỗ nào
--mình chỉ nên ghi count(case when) khi mình thực sự nắm chắc data mình đang xử lý

--bài yêu cầu tính số sản phầm, mình nên count productName hay productSKU thì sẽ hợp lý hơn là count action_type
--k nên xài inner join, nếu table1 có 10 record,table2 có 5 record,table3 có 1 record, thì sau khi inner join, output chỉ ra 1 record

--Cách 1:dùng CTE
with
product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null   --phải thêm điều kiện này để đảm bảo có revenue
  group by 1
)

select
    pv.*,
    num_addtocart,
    num_purchase,
    round(num_addtocart*100/num_product_view,2) as add_to_cart_rate,
    round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;

--bài này k nên inner join, vì nếu như bảng purchase k có data thì sẽ k mapping đc vs bảng productview, từ đó kết quả sẽ k có luôn, mình nên dùng left join
--lấy số product_view làm gốc, nên mình sẽ left join ra 2 bảng còn lại

--Cách 2: bài này mình có thể dùng count(case when) hoặc sum(case when)

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


-- good--