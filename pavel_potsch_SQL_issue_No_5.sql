-- Q No 5:
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_GDP_comparison AS 
WITH GDP_change AS (
	SELECT	`year`, 
			GDP,
			lag(GDP, 1) OVER (ORDER BY `year`) AS previous_year_GDP,
			round(((GDP/lag(GDP, 1) OVER (ORDER BY `year`)-1)*100),2) AS GDP_growth
	FROM economies e
	WHERE country = 'Czech republic' AND `year` >= 1998
 )
SELECT 	GDP_change.`year`, 
		GDP_change.GDP, 
		GDP_change.GDP_growth,
		lag(GDP_growth, 1) OVER (ORDER BY `year`) AS previous_Y_GDP_growth
FROM GDP_change;

SELECT * FROM v_gdp_comparison;

SELECT * 
FROM v_payroll_vs_prices_change_comparison;

CREATE TABLE IF NOT EXISTS t_GDP_food_price_payroll_comparison AS
SELECT gc.`year`, 
		gc.previous_Y_GDP_growth, 
		gc.GDP_growth,
		ppc.perc_YoY_FP_change AS food_price_change, 
		ppc.perc_YoY_PR_change AS payroll_change
FROM v_payroll_vs_prices_change_comparison ppc
JOIN v_gdp_comparison gc ON gc.`year` = ppc.payroll_year

SELECT * FROM t_GDP_food_price_payroll_comparison;
