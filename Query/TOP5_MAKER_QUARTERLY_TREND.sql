WITH Q1Sold as(
	select maker,
	SUM(electric_vehicles_sold) as total_ev_salesQ1
from
	makers
join
	dim_date
on
	makers.date = dim_date.date
where
	vehicle_category = '4-Wheelers'
	and
	quarter = 'Q1'
group by
	maker
),

Q2Sold as(
		select maker,
	SUM(electric_vehicles_sold) as total_ev_salesQ2
from
	makers
join
	dim_date
on
	makers.date = dim_date.date
where
	vehicle_category = '4-Wheelers'
	and
	quarter = 'Q2'
group by
	maker
),

Q3Sold as(
		select maker,
	SUM(electric_vehicles_sold) as total_ev_salesQ3
from
	makers
join
	dim_date
on
	makers.date = dim_date.date
where
	vehicle_category = '4-Wheelers'
	and
	quarter = 'Q3'
group by
	maker
)

SELECT 
    q1.maker, 
    q1.total_ev_salesQ1, 
    q2.total_ev_salesQ2, 
    q3.total_ev_salesQ3,
	(q1.total_ev_salesQ1 + q2.total_ev_salesQ2 + q3.total_ev_salesQ3) as total_ev_sales
FROM 
    Q1Sold q1
LEFT JOIN 
    Q2Sold q2 ON q1.maker = q2.maker
LEFT JOIN 
    Q3Sold q3 ON q1.maker = q3.maker
order by
	total_ev_sales DESC
limit 5






