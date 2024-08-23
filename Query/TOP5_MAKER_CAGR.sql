/*TOP 10 States with the highest CAGR from 2022 to 2024*/

WITH StateSales AS (
    SELECT
        s.state,
        d.fiscal_year,
        SUM(s.total_vehicles_sold) AS total_vehicles
    FROM 
        state s
    JOIN
        dim_date d
    ON 
        s.date = d.date
    WHERE
        d.fiscal_year IN ('2022', '2024')
    GROUP BY
        s.state, d.fiscal_year
),
CAGR_Calculation AS (
    SELECT
        state,
        (POWER(
            SUM(CASE WHEN fiscal_year = '2024' THEN total_vehicles ELSE 0 END) /
            NULLIF(SUM(CASE WHEN fiscal_year = '2022' THEN total_vehicles ELSE 0 END), 0), 
            1.0 / 2
        ) - 1) * 100 AS CAGR
    FROM 
        StateSales
    GROUP BY
        state
)

SELECT
    state,
    CAGR
FROM 
    CAGR_Calculation
WHERE 
	CAGR_Calculation IS NOT NULL
ORDER BY 
    CAGR DESC
LIMIT 10
