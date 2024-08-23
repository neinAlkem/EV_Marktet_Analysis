SELECT 
	EXTRACT(YEAR FROM(date)) as year, 
	EXTRACT(MONTH FROM(date)) as months,
	SUM(electric_vehicles_sold) as total_ev_sales
FROM
	state
GROUP BY
	year
