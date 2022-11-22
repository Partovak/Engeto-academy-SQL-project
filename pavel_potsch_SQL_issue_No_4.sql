-- Q No 4:
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_payroll_change AS 
	WITH distinct_years AS (
		SELECT DISTINCT payroll_year, 
						average_payroll
		FROM t_pavel_potsch_project_sql_primary_final 
		WHERE industry_branch_code IS NULL
	)
	SELECT 	*, 
			lag(average_payroll, 1) OVER (ORDER BY payroll_year) AS previous_years_payroll,
			round(((average_payroll/lag(average_payroll, 1) OVER (ORDER BY payroll_year)-1)*100),2) AS perc_YoY_PR_change
	FROM distinct_years
	ORDER BY payroll_year;
	
SELECT * FROM v_payroll_change;

-- Druhá tabulka pro jídlo:

CREATE OR REPLACE VIEW v_price_change AS 
WITH t_food_price AS (
		SELECT 	payroll_year, 
				sum(average_food_price) AS food_price
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

-- Finální posouzení:

CREATE OR REPLACE VIEW v_payroll_vs_prices_change_comparison AS 
SELECT 	vprc.payroll_year, 
		vprc.perc_YoY_FP_change, 
		vpac.perc_YoY_PR_change,
		vprc.perc_YoY_FP_change-vpac.perc_YoY_PR_change AS difference,
		IF (vprc.perc_YoY_FP_change-vpac.perc_YoY_PR_change > 10, 1, 0) AS Year_of_powerty
FROM v_price_change vprc
JOIN v_payroll_change vpac ON vprc.payroll_year = vpac.payroll_year;

SELECT * FROM v_payroll_vs_prices_change_comparison;
