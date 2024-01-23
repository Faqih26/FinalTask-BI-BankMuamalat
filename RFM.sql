with b as (
SELECT 
	CustomerID,
    sum(revenue) as monetaryvalue,
    count(CustomerID) as frequency,
    (select max(order_date) FROM rakamin.table_master) as max_date,
	abs(datediff(max(order_date) ,(select max(order_date) FROM rakamin.table_master))) as recency
 FROM rakamin.table_master
 group by CustomerID
 ) 
 , c as (
 SELECT 
 *,
 NTILE(5) OVER (order by recency desc) rfm_recency,
 NTILE(5) OVER (order by frequency) rfm_frequency,
 NTILE(5) OVER (order by monetaryvalue) rfm_monetary
 FROM b
 )
 , rfm2 as(
 select 
 *,
    concat( cast(rfm_recency as char),'-',cast(rfm_frequency as char),'-', cast(rfm_monetary as char))rfm_cell_string
from c
)
select 
 CustomerID,monetaryvalue, frequency,recency, rfm_recency, rfm_frequency,rfm_monetary,rfm_cell_string,
    case 
  WHEN rfm_cell_string IN ('5-5-5', '5-5-4', '5-4-4', '5-4-5', '4-5-4', '4-5-5', '4-4-5') THEN 'Champion'
  WHEN rfm_cell_string IN ('5-4-3', '4-4-4', '4-3-5', '3-5-5', '3-5-4', '3-4-5', '3-4-4', '3-3-5') THEN 'Loyal'
  WHEN rfm_cell_string IN ('5-5-3', '5-5-1', '5-5-2', '5-4-1', '5-4-2', '5-3-3', '5-3-2', '5-3-1', 
       '4-5-2', '4-5-1', '4-4-2', '4-4-1', '4-3-1', '4-5-3', '4-3-3', '4-3-2', 
       '4-2-3', '3-5-3', '3-5-2', '3-5-1', '3-4-2', '3-4-1', '3-3-3', '3-2-3') THEN 'Potential Loyalist'
  WHEN rfm_cell_string IN ('5-1-2', '5-1-1', '4-2-2', '4-2-1', '4-1-2', '4-1-1', '3-1-1') THEN 'New Costumer'
  WHEN rfm_cell_string IN ('5-2-5', '5-2-4', '5-2-3', '5-2-2', '5-2-1', '5-1-5', '5-1-4', '5-1-3', 
       '4-2-5', '4-2-4', '4-1-3', '4-1-4', '4-1-5', '3-1-5', '3-1-4', '3-1-3') THEN 'Promising'
  WHEN rfm_cell_string IN ('5-3-5', '5-3-4', '4-4-3', '4-3-4', '3-4-3', '3-3-4', '3-2-5', '3-2-4') THEN 'Needs Attention'
  WHEN rfm_cell_string IN ('3-3-1', '3-2-1', '3-1-2', '2-2-1', '2-1-3', '2-3-1', '2-4-1', '2-5-1') THEN 'About To Sleep'
  WHEN rfm_cell_string IN ('2-5-5', '2-5-4', '2-4-5', '2-4-4', '2-5-3', '2-5-2', '2-4-3', '2-4-2', 
       '2-3-5', '2-3-4', '2-2-5', '2-2-4', '1-5-3', '1-5-2', '1-4-5', '1-4-3', 
       '1-4-2', '1-3-5', '1-3-4', '1-3-3', '1-2-5', '1-2-4') THEN 'At Risk'
  WHEN rfm_cell_string IN ('1-5-5', '1-5-4', '1-4-4', '2-1-4', '2-1-5', '1-1-5', '1-1-4', '1-1-3') THEN 'Cannot Lose Them'
  WHEN rfm_cell_string IN ('3-3-2', '3-2-2', '2-3-3', '2-3-2', '2-2-3', '2-2-2', '1-3-2', '1-2-3', 
       '1-2-2', '2-1-2', '2-1-1') THEN 'Hibernating Costumer'
  WHEN rfm_cell_string IN ('1-1-1', '1-1-2', '1-2-1', '1-3-1', '1-4-1', '1-5-1') THEN 'Lost Costumer'
 end rfm_segment
from rfm2