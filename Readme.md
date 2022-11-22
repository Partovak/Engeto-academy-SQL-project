SQL PROJECT
---
---
Komentář k projektu a odpovědi na zadané otázky:

Primární tabulka (t_pavel_potsch_project_sql_primary_final) shrnuje informace o průměrných mzdách pro každé odvětví (jakož i průměr mezd v celé ekonomice) v letech 2000 - 2021 a průměrné ceny vybraných potravin pro roky 2006 - 2018. Pro další zpracování byla použita data udávající počet zaměstnaných osob (calculation code = 100), nikoli přepočet na plné úvazky (calculation code = 200).
Dále proběhlo zprůměrování dat na roční bázi (původní měření byla prováděna čtvrtletně), které bylo provedeno i u cen potravin.

Sekundární tabulka (t_pavel_potsch_project_sql_secondary_final) nám zobrazuje přehled evropských států s jejich DPH,  Giniho indexem (který popisuje příjmovou nerovnost ve společnosti) a velikostí populace. 
Pro porovnání dostupnosti potravin v ČR a v ostatních zemích Evropy nám ovšem chybí dodatečná data, v dostupných datových souborech se tyto informace nenacházejí. 


Q No. 1:
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Mezi lety 2000 - 2021 se vyskytují odvětví, kde platy zaznamenávají v některých odvětvích určitý pokles. Zatímco na začátku sledovaného období mzdy ve všech odvětvích rostou, po příchodu recese na přelomu dekád můžeme vidět výraznější propad mezd, přičemž některé obory jsou tímto poklesem zasaženy více než jiné. Týká se to zejména oblasti Ubytování, stravování, pohostinství, Činností v oblasti nemovitostí, Vzdělávání a odvětví Kulturní, zábavní a rekreační činnost.
Podobná situace se pak opakuje v letech 2020 a 2021 v době covidové pandemie.
Z výsledného přehledu stojí také za zmínku odvětví Těžba a dobývání, které mezi lety 2013 - 2016 zažívalo obtížnější období.


Q No. 2:
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
První rok, za který máme k dispozici data pro mzdy i ceny potravin, je rok 2006. V tomto roce bylo možné si za tehdy průměrnou mzdu 18902 Kč koupit 1309 litrů polotučného mléka a 1173 kg konzumního kmínového chleba.
O dvanáct let později, v r. 2018, na tom byli občané ČR o něco lépe. Průměrná mzda se vyšplhala na 30998 Kč a bylo možné za ni pořídit o téměř 20% více mléka a o 9% více chleba, v absolutních číslech tedy 1564 l mléka a 1279 kg chleba.


Q No. 3:
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
Při zjišťování odpovědi na tuto otázku jsem vycházel z dat za období 2006 - 2018. Přitom položka 212101 - Jakostní víno bílé - nebyla do přehledu zahrnuta, jelikož se v datech objevuje až od r. 2015.
Výsledná tabulka nám ukazuje, že u dvou položek - Cukr krystalový a Rajská jalka kulatá červená cena dokonce poklesla, a to o 27,5% u cukru a 23% u rajčat. Další kategorie vybraných potravin pak zdražovaly, 
přičemž nejpomaleji pak Banány žluté (7,36% celkově za dané období).


Q No. 4:
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Pro zjednodušení postupu a větší přehlednost byly vytvořeny dvě Views, jejichž výstupy jsou procentuální meziroční změny porovnávaných veličin - ceny potravin (perc_YoY_FP_change) a mezd (perc_YoY_PR_change). Tyto hodnoty pak byly porovnány navzájem mezi sebou (v_payroll_vs_prices_change_comparison).
Daná hypotéza se nepotvrdila, nejblíže k tomuto stavu měl rok 2013, kdy cena potravin vystoupala nahoru o pět procent, přičemž mzdy zůstaly téměř stejné jako předchozí rok.


Q No. 5:
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
Z tabulky t_GDP_food_price_payroll_comparison je patrné, že zvýšení růstu HDP v jednom roce koreluje s růstem platů v roce následujícím (nikoliv v tomtéž roce).
Naproti tomu vztah mezi růstem HDP a růstem cen potravin z tabulky patrný není a faktory, které ovlivňují jejich pohyb, je potřeba hledat jinde. 

Použité tabulky databáze:
czechia_payroll
czechia_payroll_industry_branch
czechia_price
czechia_price_category
countries
economies