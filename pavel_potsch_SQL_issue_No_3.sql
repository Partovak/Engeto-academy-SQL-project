-- Q No 3:
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?


CREATE OR REPLACE VIEW v_food_price_increase AS
WITH food_price_2006 AS (
	SELECT DISTINCT food_category_code, 
					average_food_price AS average_food_price_2006
	FROM t_pavel_potsch_project_sql_primary_final tpp
	WHERE payroll_year = 2006), 
	food_price_2018 AS (
	SELECT DISTINCT food_category_code, 
					average_food_price AS average_food_price_2018
	FROM t_pavel_potsch_project_sql_primary_final tpp2
	WHERE payroll_year = 2018)
SELECT 
		food_price_2006.food_category_code, 
		food_price_2006.average_food_price_2006, 
		food_price_2018.average_food_price_2018,
		round(((average_food_price_2018/average_food_price_2006-1)*100), 2) AS `price_increase[%]`
	FROM food_price_2006
	JOIN food_price_2018
	ON food_price_2006.food_category_code = food_price_2018.food_category_code
ORDER BY food_category_code;
	
SELECT * FROM v_food_price_increase 

SELECT 	cpc.name, 
		vfpi.average_food_price_2006,
		vfpi.average_food_price_2018, 
		vfpi.`price_increase[%]`
FROM v_food_price_increase vfpi
JOIN czechia_price_category cpc ON cpc.code = vfpi.food_category_code
ORDER BY `price_increase[%]`
LIMIT 3;