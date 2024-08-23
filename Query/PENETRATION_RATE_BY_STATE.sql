/*Comparing the penetration_rate between Delhi and Karnataka*/

WITH PenetrationRate2024 AS (
    SELECT
        state,
        SUM(electric_vehicles_sold) AS total_ev_sold_2024,
        SUM(total_vehicles_sold) AS total_vehicles_sold_2024,
        (SUM(electric_vehicles_sold) * 1.0 / SUM(total_vehicles_sold)) * 100 AS penetration_rate_2024
    FROM
        state
    JOIN
        dim_date
    ON
        state.date = dim_date.date
    WHERE
        dim_date.fiscal_year = '2024'
    GROUP BY
        state
)

SELECT 
    state, 
    total_ev_sold_2024, 
    total_vehicles_sold_2024, 
    penetration_rate_2024
FROM 
    PenetrationRate2024
WHERE 
    state IN ('Delhi', 'Karnataka');


