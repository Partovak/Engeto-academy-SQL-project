-- Primární tabulka:

CREATE OR REPLACE VIEW v_prep_payroll AS (
	SELECT 	payroll_year, 
			round(avg(value), 2) AS average_payroll, 
			industry_branch_code
	FROM czechia_payroll cp
	WHERE value_type_code = 5958 AND calculation_code = 100
	GROUP BY payroll_year, industry_branch_code 
	ORDER BY payroll_year
);


CREATE OR REPLACE VIEW  v_prep_price AS (
	SELECT 	category_code AS food_category_code, 
			YEAR (date_from) AS Year, 
			round(avg(value), 2)  AS average_food_price
	FROM czechia_price cp 
	WHERE region_code IS NULL 
	GROUP BY YEAR (date_from),  category_code
);



CREATE OR REPLACE TABLE t_pavel_potsch_project_SQL_primary_final AS
SELECT 	vppay.payroll_year, 
		vppay.average_payroll, 
		vppay.industry_branch_code, 
		vpp.food_category_code, 
		vpp.average_food_price
FROM v_prep_payroll vppay
LEFT JOIN v_prep_price vpp ON vppay.payroll_year = vpp.YEAR;

SELECT * FROM t_pavel_potsch_project_sql_primary_final
ORDER BY payroll_year DESC , industry_branch_code;


-- Sekundární tabulka:

CREATE OR REPLACE TABLE t_pavel_potsch_project_SQL_secondary_final AS 
SELECT 	country, 
		`year`, 
		gdp, 
		gini, 
		population 
FROM economies e 
WHERE `year` > 1999 AND country IN (
	SELECT country
	FROM countries c 
	WHERE continent = 'Europe'
	)
ORDER BY country, `year`;	

SELECT * FROM t_pavel_potsch_project_sql_secondary_final;
