WITH RG22 AS (
    SELECT 
        SUM(
            CASE
                WHEN vechile_category = '2-Wheelers' THEN electric_vehicles_sold * 85000.00
                WHEN vechile_category = '4-Wheelers' THEN electric_vehicles_sold * 1500000.00
                ELSE 0
            END
        ) AS total_revenue_22
    FROM
        state
	JOIN
		dim_date
	ON
		state.date = dim_date.date
    WHERE
       fiscal_year = '2022'
),

RG23 AS (
    SELECT 
        SUM(
            CASE
                WHEN vechile_category = '2-Wheelers' THEN electric_vehicles_sold * 85000.00
                WHEN vechile_category = '4-Wheelers' THEN electric_vehicles_sold * 1500000.00
                ELSE 0
            END
        ) AS total_revenue_23
    FROM
        state
    JOIN
		dim_date
	ON
		state.date = dim_date.date
    WHERE
       fiscal_year = '2023'
),

RG24 AS (
    SELECT 
        SUM(
            CASE
                WHEN vechile_category = '2-Wheelers' THEN electric_vehicles_sold * 85000.00
                WHEN vechile_category = '4-Wheelers' THEN electric_vehicles_sold * 1500000.00
                ELSE 0
            END
        ) AS total_revenue_24
    FROM
        state
    JOIN
		dim_date
	ON
		state.date = dim_date.date
    WHERE
       fiscal_year = '2024'
),

RevenueGrowth AS (
    SELECT
        RG22.total_revenue_22,
        RG23.total_revenue_23,
        RG24.total_revenue_24,
        COALESCE(
            ((RG24.total_revenue_24 - RG22.total_revenue_22) / NULLIF(RG22.total_revenue_22, 0)) * 100.0,
            0
        ) 
	AS growth22_24,
        COALESCE(
            ((RG24.total_revenue_24 - RG23.total_revenue_23) / NULLIF(RG23.total_revenue_23, 0)) * 100.0,
            0
        ) AS growth23_24
    FROM
        RG22,
        RG23,
        RG24 
)

SELECT 
    total_revenue_22,
    total_revenue_23,
    total_revenue_24,
    growth22_24,
    growth23_24
FROM
    RevenueGrowth;
