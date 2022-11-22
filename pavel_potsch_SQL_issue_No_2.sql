-- Q No 2:
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT 	tpp.payroll_year, 
		tpp.average_payroll, 
		cpc.name, 
		tpp.average_food_price, 
		round(average_payroll / average_food_price) AS affordable_amount
	FROM t_pavel_potsch_project_SQL_primary_final tpp
	JOIN czechia_price_category cpc ON tpp.food_category_code = cpc.code 
	WHERE industry_branch_code IS NULL AND food_category_code IN (114201, 111301) AND payroll_year IN (2006, 2018);