/*Comparing the Penetration Rate between Delhi and Karnataka*/

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

/*Total Penetration Rate From 2022 to 20224*/

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
	PR22.state,
	(penetration_rate_2024 - penetration_rate_2022) as penetration_rate_change
FROM
	 PenetrationRate2022 PR22
JOIN
	PenetrationRate2024 PR24
ON
	PR22.state = PR24.state
ORDER BY
		penetration_rate_change DESC

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

/*Top 5 Maker Quaterly Rate*/
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

/*Projected 2030 Selling Rate*/
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

/*Monthly EV Sales*/
SELECT 
	EXTRACT(YEAR FROM(date)) as year, 
	EXTRACT(MONTH FROM(date)) as months,
	SUM(electric_vehicles_sold) as total_ev_sales
FROM
	state
GROUP BY
	year,months
ORDER BY 
		total_ev_sales DESC

/*Yearly Revenue Growth*/
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

-- top 5 states selling ev for each two and four wheelers
-- 4-Wheelers Query
(
    SELECT 
        state, 
		vechile_category,
        SUM(state.electric_vehicles_sold) AS total_electric_vehicles_sold,
        SUM(state.total_vehicles_sold) AS total_vehicles_sold,
        SUM(state.electric_vehicles_sold) * 100.0 / SUM(state.total_vehicles_sold) AS penetration_rate
    FROM 
        state
    JOIN
        dim_date
    ON
        state.date = dim_date.date
    WHERE
        dim_date.fiscal_year = '2024'
        AND state.vechile_category = '4-Wheelers'
    GROUP BY
        state,vechile_category
    ORDER BY
        penetration_rate DESC
    LIMIT 5
)

UNION ALL

-- 2-Wheelers Query
(
    SELECT 
        state, 
		vechile_category,
        SUM(state.electric_vehicles_sold) AS total_electric_vehicles_sold,
        SUM(state.total_vehicles_sold) AS total_vehicles_sold,
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
        state,vechile_category
    ORDER BY
        penetration_rate DESC
    LIMIT 5
);


--Best and Worst Maker Selling

-- Top 3 Maker

SELECT 
	maker,
	SUM(electric_vehicles_sold) as total_ev_sold
FROM
	makers
JOIN
	dim_date 
ON
	makers.date = dim_date.date
WHERE 
	fiscal_year in ('2023', '2024')
	AND
	vehicle_category = '2-Wheelers'
GROUP BY
	maker
ORDER BY
	total_ev_sold DESC
LIMIT 3

-- Worst 3 Maker

SELECT 
	maker,
	SUM(electric_vehicles_sold) as total_ev_sold
FROM
	makers
JOIN
	dim_date 
ON
	makers.date = dim_date.date
WHERE 
	fiscal_year in ('2023', '2024')
	AND
	vehicle_category = '2-Wheelers'
GROUP BY
	maker
ORDER BY
	total_ev_sold ASC
LIMIT 3
	







