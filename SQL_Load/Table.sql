/* Selecting the 3 top and bottom makers according to 2023 and 2024 fiscal year */
	
(
    SELECT maker, SUM(electric_vehicles_sold) AS total_electric_vehicles_sold
    FROM makers
    JOIN dim_date
    ON makers.date = dim_date.date
    WHERE
        vehicle_category = '2-Wheelers'
        AND (fiscal_year = '2023' OR fiscal_year = '2024')
    GROUP BY maker
    ORDER BY total_electric_vehicles_sold DESC
    LIMIT 3
)
UNION ALL
(
    SELECT maker, SUM(electric_vehicles_sold) AS total_electric_vehicles_sold
    FROM makers
    JOIN dim_date
    ON makers.date = dim_date.date
    WHERE
        vehicle_category = '2-Wheelers'
        AND (fiscal_year = '2023' OR fiscal_year = '2024')
    GROUP BY maker
    ORDER BY total_electric_vehicles_sold ASC
    LIMIT 3
);




