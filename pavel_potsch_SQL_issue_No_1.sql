-- Q No 1:
-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_payroll_increase AS 
	WITH distinct_values_table AS (
		SELECT DISTINCT payroll_year, 
						industry_branch_code, 
						average_payroll
		FROM t_pavel_potsch_project_sql_primary_final 
		WHERE industry_branch_code IS NOT NULL
	)
	SELECT *, 
		lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS previous_years_payroll,
		round(average_payroll-(lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year)), 2) AS YoY_payroll_increase,
		round(((average_payroll/lag(average_payroll, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year)-1)*100),2) AS Perc_YoY_increase
	FROM distinct_values_table
	ORDER BY industry_branch_code, payroll_year;

SELECT * FROM v_payroll_increase;

-- Odvětví a roky, kdy mzdy v daném odvětví zaznamenaly pokles:

SELECT 	vpi.industry_branch_code, 
		cpib.name, 
		vpi.payroll_year AS Year_of_payroll_decrease, 
		vpi.Perc_YoY_increase AS `YoY_Decrease_[%]`
FROM v_payroll_increase vpi
JOIN czechia_payroll_industry_branch cpib  ON cpib.code = vpi.industry_branch_code
WHERE vpi.Perc_YoY_increase < 0
ORDER BY vpi.industry_branch_code, vpi.payroll_year;