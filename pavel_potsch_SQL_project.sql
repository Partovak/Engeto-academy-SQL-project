CREATE OR REPLACE VIEW v_prep_payroll AS (
SELECT payroll_year, round(avg(value), 2) AS average_payroll, industry_branch_code
FROM czechia_payroll cp
WHERE value_type_code = 5958 AND calculation_code = 100
GROUP BY payroll_year, industry_branch_code 
ORDER BY payroll_year
);


CREATE OR REPLACE VIEW  v_prep_price AS (
SELECT category_code AS food_category_code, YEAR (date_from) AS Year, round(avg(value), 2)  AS average_food_price
FROM czechia_price cp 
WHERE region_code IS NULL 
GROUP BY YEAR (date_from),  category_code
);



CREATE OR REPLACE TABLE t_pavel_potsch_project_SQL_primary_final AS
SELECT vppay.payroll_year, vppay.average_payroll, vppay.industry_branch_code, vpp.food_category_code, vpp.average_food_price
FROM v_prep_payroll vppay
LEFT JOIN v_prep_price vpp ON vppay.payroll_year = vpp.YEAR;

SELECT * FROM t_pavel_potsch_project_sql_primary_final;

-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_payroll_increase AS 
	WITH distinct_values_table AS (
		SELECT DISTINCT payroll_year, industry_branch_code, average_payroll
		FROM t_pavel_potsch_project_sql_primary_final 
		WHERE industry_branch_code IS NOT NULL
	)
	SELECT *, lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS previous_years_payroll,
		round(average_payroll-(lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year)), 2) AS YoY_payroll_increase,
		round(((average_payroll/lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year)-1)*100),2) AS Perc_YoY_increase
	FROM distinct_values_table
	ORDER BY industry_branch_code, payroll_year;

SELECT * FROM v_payroll_increase;

SELECT vpi.industry_branch_code, cpib.name, vpi.payroll_year AS Year_of_payroll_decrease, vpi.Perc_YoY_increase AS `YoY_Decrease_[%]`
FROM v_payroll_increase vpi
JOIN czechia_payroll_industry_branch cpib  ON cpib.code = vpi.industry_branch_code
WHERE vpi.Perc_YoY_increase < 0
ORDER BY vpi.industry_branch_code, vpi.payroll_year;


-- 2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT 	tpp.payroll_year, 
		tpp.average_payroll, 
		cpc.name, 
		tpp.average_food_price, 
		round(average_payroll / average_food_price) AS affordable_amount
	FROM t_pavel_potsch_project_SQL_primary_final tpp
	JOIN czechia_price_category cpc ON tpp.food_category_code = cpc.code 
	WHERE industry_branch_code IS NULL AND food_category_code IN (114201, 111301) AND payroll_year IN (2006, 2018);

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- Položka 212101 - Jakostní víno bílé nebyla do přehledu zahrnuta, jelikož se v datevh objevuje až od r. 2015

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
	food_price_2006.food_category_code, food_price_2006.average_food_price_2006, food_price_2018.average_food_price_2018,
	round(((average_food_price_2018/average_food_price_2006-1)*100), 2) AS `price_increase[%]`
	FROM food_price_2006
	JOIN food_price_2018
	ON food_price_2006.food_category_code = food_price_2018.food_category_code
ORDER BY food_category_code
	
SELECT * FROM v_food_price_increase 

SELECT cpc.name, vfpi.average_food_price_2006, vfpi.average_food_price_2018, vfpi.`price_increase[%]`
FROM v_food_price_increase vfpi
JOIN czechia_price_category cpc ON cpc.code = vfpi.food_category_code
ORDER BY `price_increase[%]`
LIMIT 3;

-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Pro zjednodušení postupu a větší přehlednost byly vytvořeny dvě View, jejichž výstupy jsou procentuální meziroční změny porovnávaných veličin - ceny potravin (perc_YoY_FP_change) a mezd (perc_YoY_PR_change)
-- Tato hypotéza se nepotvrdila, nejblíže k tomuto stavu měl rok 2013, kdy cena potravin vystoupala nahoru o pět procent, přičemž mzdy zůstaly prakticky stejné jako předchozí rok


		
CREATE OR REPLACE VIEW v_payroll_change AS 
	WITH distinct_years AS (
		SELECT DISTINCT payroll_year, average_payroll
		FROM t_pavel_potsch_project_sql_primary_final 
		WHERE industry_branch_code IS NULL
	)
	SELECT *, lag(average_payroll, 1) OVER (ORDER BY payroll_year) AS previous_years_payroll,
			round(((average_payroll/lag(average_payroll, 1) OVER (ORDER BY payroll_year)-1)*100),2) AS perc_YoY_PR_change
	FROM distinct_years
	ORDER BY payroll_year+;
	
	
SELECT * FROM t_pavel_potsch_project_sql_primary_final;

-- tvorba druhé tabulky pro jídlo
CREATE OR REPLACE VIEW v_price_change AS 
WITH t_food_price AS (
	SELECT payroll_year, sum(average_food_price) AS food_price
	FROM t_pavel_potsch_project_sql_primary_final 
	WHERE average_food_price IS NOT NULL AND industry_branch_code IS NULL 
	GROUP BY payroll_year;
)
SELECT *, 
		lag(food_price, 1) OVER (ORDER BY payroll_year) AS previous_years_food_price,
		round(((food_price/lag(food_price, 1) OVER (ORDER BY payroll_year)-1)*100),2) AS perc_YoY_FP_change
FROM t_food_price;

SELECT * FROM v_price_change;
SELECT * FROM v_payroll_change;

-- Final assessment:

CREATE OR REPLACE VIEW v_payroll_vs_prices_change_comparison AS 
SELECT vprc.payroll_year, 
vprc.perc_YoY_FP_change, 
vpac.perc_YoY_PR_change,
vprc.perc_YoY_FP_change-vpac.perc_YoY_PR_change AS difference,
IF (vprc.perc_YoY_FP_change-vpac.perc_YoY_PR_change > 10, 1, 0) AS Year_of_powerty
FROM v_price_change vprc
JOIN v_payroll_change vpac ON vprc.payroll_year = vpac.payroll_year;

SELECT *
FROM v_payroll_vs_prices_change_comparison;
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

WITH GDP_change AS (
SELECT `year`, 
		GDP,
		lag(GDP, 1) OVER (ORDER BY `year`) AS previous_year_GDP,
		round(((GDP/lag(GDP, 1) OVER (ORDER BY `year`)-1)*100),2) AS GDP_growth
		FROM economies e
		WHERE country = 'Czech republic' AND `year` >= 1998
 )
SELECT GDP_change.`year`, 
		GDP_change.GDP, GDP_change.GDP_growth,
		lag(GDP_growth, 1) OVER (ORDER BY `year`) AS previous_Y_GDP_growth
FROM GDP_change
ORDER BY YEAR ASC;

