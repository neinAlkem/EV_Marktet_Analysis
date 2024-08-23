WITH PenetrationRate AS (
    SELECT
        state,
        SUM(electric_vehicles_sold) AS total_ev_sold,
        SUM(total_vehicles_sold) AS total_vehicles_sold,
        (SUM(electric_vehicles_sold) * 1.0 / SUM(total_vehicles_sold)) * 100 AS penetration_rate
    FROM
        state
    WHERE
        EXTRACT(YEAR FROM date) = 2024
    GROUP BY
        state
),
	
StateSales AS (
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
        d.fiscal_year IN ('2023', '2024')
    GROUP BY
        s.state, d.fiscal_year
),

CAGR_Calculation AS (
    SELECT
        state,
        COALESCE(
            (POWER(
                SUM(CASE WHEN fiscal_year = '2024' THEN total_vehicles ELSE 0 END) /
                NULLIF(SUM(CASE WHEN fiscal_year = '2023' THEN total_vehicles ELSE 0 END), 0), 
                1.0 / 1
            ) - 1) * 100,
            0
        ) AS CAGR
    FROM 
        StateSales
    GROUP BY
        state
),

totalSales24 AS (
    SELECT
        state,
        SUM(electric_vehicles_sold) AS sum_total_ev_sold
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
)

SELECT
    pr.state,
    pr.penetration_rate,
    ts24.sum_total_ev_sold,
    ROUND(
        COALESCE(
            ts24.sum_total_ev_sold * POWER((1 + c.CAGR / 100), 6),
            0
        ), 
        0
    ) AS Projection_2030
FROM  
    PenetrationRate pr
JOIN 
    totalSales24 ts24
ON
    pr.state = ts24.state
JOIN 
    CAGR_Calculation c
ON
    pr.state = c.state
ORDER BY
    Projection_2030 DESC
LIMIT 10;
