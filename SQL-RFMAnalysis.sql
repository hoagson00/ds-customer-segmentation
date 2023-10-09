--  select * from sales;
-- select * from customer;
-- select * from [segment scores];

--------- RFM Calculate ---------
WITH RFM_Base
as
(
select s.Customer_ID as CustomerID,
		c.Customer_Name as CustomerName,
		datediff (DAY, MAX(s.Order_Date), convert (DATE, GETDATE())) as Recency_Value,
		count (distinct s.Order_ID) as Frequency_Value,
		round (sum (s.Sales), 2) as Monetary_Value
from sales as s
INNER JOIN customer as c on s.Customer_ID = c.Customer_ID
group by s.Customer_ID, c.Customer_Name
)
--select * from RFM_Base
, RFM_Score
as
(
select *,
	ntile(5) over (order by Recency_Value DESC) as R_Score,
	ntile(5) over (order by Frequency_Value DESC) as F_Score,
	ntile(5) over (order by Monetary_Value DESC) as M_Score
	from RFM_Base
)
--select * from RFM_Score
, RFM_Final
as
(
select *,
	concat (R_Score, F_Score, M_Score) as RFM_Overall
	from RFM_Score
)
--select * from RFM_Final
select f.*, sg.Segment
from RFM_Final f
JOIN [segment scores] sg on f.RFM_Overall = sg.Scores;
