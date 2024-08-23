WITH PenetrationRate2022 AS (
    SELECT
        state,
        SUM(electric_vehicles_sold) AS total_ev_sold_2022,
        SUM(total_vehicles_sold) AS total_vehicles_sold_2022,
        (SUM(electric_vehicles_sold) * 1.0 / SUM(total_vehicles_sold)) * 100 AS penetration_rate_2022
    FROM
        state
 	JOIN
		dim_date
	ON
		state.date = dim_date.date
	WHERE
		fiscal_year = '2022'
	GROUP BY
		state,
		fiscal_year
),

PenetrationRate2024 AS (
    SELECT
        state,
        SUM(electric_vehicles_sold) AS total_ev_sold_2022,
        SUM(total_vehicles_sold) AS total_vehicles_sold_2022,
        (SUM(electric_vehicles_sold) * 1.0 / SUM(total_vehicles_sold)) * 100 AS penetration_rate_2024
    FROM
        state
 	JOIN
		dim_date
	ON
		state.date = dim_date.date
	WHERE
		fiscal_year = '2024'
	GROUP BY
		state,
		fiscal_year
)


SELECT
	PR22.state
FROM
	 PenetrationRate2022 PR22
JOIN
	PenetrationRate2024 PR24
ON
	PR22.state = PR24.state
WHERE
	penetration_rate_2024 > penetration_rate_2022
