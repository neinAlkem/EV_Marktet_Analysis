SELECT 
	state, 
	SUM(electric_vehicles_sold) AS total_vehicles_sold,
	SUM(total_vehicles_sold) AS total_vehicles_sold,
	SUM(electric_vehicles_sold) * 100 / SUM(total_vehicles_sold) as penetration_rate
FROM 
    state
JOIN
    dim_date
ON
    state.date = dim_date.date
WHERE
	fiscal_year = '2024'
GROUP BY
	state
ORDER BY
	penetration_rate DESC
LIMIT 5

SELECT 
    state, 
    SUM(state.electric_vehicles_sold) * 100.0 / SUM(state.total_vehicles_sold) AS penetration_rate
FROM 
    state
JOIN
    dim_date
ON
    state.date = dim_date.date
WHERE
    dim_date.fiscal_year = '2024'
    AND state.vechile_category = '2-Wheelers'
GROUP BY
    state  -- Replace with the actual column name for the state
ORDER BY
    penetration_rate DESC
LIMIT 5;

