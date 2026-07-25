CREATE TABLE t_tana_silberova_projekt_SQL_primary_final AS
WITH mzdy AS (
    -- Tady si připravíme roční průměrné mzdy podle odvětví
    SELECT 
        payroll_year AS rok,
        industry_branch_code AS odvetvi_kod,
        ib.name AS odvetvi_nazev,
        AVG(value) AS prumerna_mzda
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch ib 
        ON cp.industry_branch_code = ib.code
    WHERE value_type_code = 5958  -- Pouze průměrná mzda
      AND calculation_code = 200  -- Přepočtené počty zaměstnanců
    GROUP BY payroll_year, industry_branch_code, ib.name
),
ceny AS (
    -- Tady si připravíme roční průměrné ceny potravin za celou ČR
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok,
        category_code AS potravina_kod,
        cpc.name AS potravina_nazev,
        AVG(value) AS prumerna_cena
    FROM czechia_price cp
    LEFT JOIN czechia_price_category cpc 
        ON cp.category_code = cpc.code
    GROUP BY EXTRACT(YEAR FROM date_from), category_code, cpc.name
)
-- Tady obě připravené části spojíme přes společný rok
SELECT 
    m.rok,
    m.odvetvi_kod,
    m.odvetvi_nazev,
    m.prumerna_mzda,
    c.potravina_kod,
    c.potravina_nazev,
    c.prumerna_cena
FROM mzdy m
JOIN ceny c ON m.rok = c.rok;


CREATE TABLE t_tana_silberova_projekt_SQL_secondary_final AS
SELECT 
    e.year AS rok,
    c.country AS stat,
    c.population AS populace_celkova,
    e.gdp AS hdp,
    e.gini AS gini_koeficient,
    e.taxes AS dana_zatez
FROM countries c
JOIN economies e ON c.country = e.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2000 AND 2021;

-- Otázka 1 (Porovnání mezd v odvětvích)
WITH rocni_mzdy AS (
    SELECT DISTINCT
        rok,
        odvetvi_nazev,
        prumerna_mzda
    FROM t_tana_silberova_projekt_SQL_primary_final
    WHERE odvetvi_nazev IS NOT NULL
),
rozdily_mezd AS (
    SELECT 
        rok,
        odvetvi_nazev,
        prumerna_mzda,
        LAG(prumerna_mzda) OVER (PARTITION BY odvetvi_nazev ORDER BY rok) AS mzda_minuly_rok
    FROM rocni_mzdy
)
SELECT 
    rok,
    odvetvi_nazev,
    ROUND(prumerna_mzda) AS mzda_v_kc,
    ROUND(prumerna_mzda - mzda_minuly_rok) AS mezirocni_rozdil_kc
FROM rozdily_mezd
WHERE mzda_minuly_rok IS NOT NULL
  AND (prumerna_mzda - mzda_minuly_rok) < 0
ORDER BY odvetvi_nazev, rok;



--Otázka 2 (Nákup chleba a mléka 2006 vs. 2018)
WITH mzdy_celkove AS (
    -- Vytáhneme celkovou průměrnou mzdu za celou ČR pro roky 2006 a 2018
    SELECT rok, prumerna_mzda
    FROM t_tana_silberova_projekt_SQL_primary_final
    WHERE odvetvi_nazev IS NULL
      AND rok IN (2006, 2018)
    GROUP BY rok, prumerna_mzda
),
ceny_potravin AS (
    -- Vytáhneme ceny chleba a mléka pro roky 2006 a 2018
    SELECT rok, potravina_kod, potravina_nazev, prumerna_cena
    FROM t_tana_silberova_projekt_SQL_primary_final
    WHERE potravina_kod IN ('111301', '114201')
      AND rok IN (2006, 2018)
    GROUP BY rok, potravina_kod, potravina_nazev, prumerna_cena
    )
-- Spojíme to dohromady a spočítáme množství (mzda děleno cena)
SELECT 
    m.rok,
    ROUND(m.prumerna_mzda::numeric) AS prumerna_mzda_kc,
    c.potravina_nazev,
    ROUND(c.prumerna_cena::numeric, 2) AS cena_za_jednotku_kc,
    FLOOR(m.prumerna_mzda / c.prumerna_cena) AS koupitelne_mnozstvi
FROM mzdy_celkove m
JOIN ceny_potravin c ON m.rok = c.rok
ORDER BY c.potravina_nazev, m.rok;



--Otázka 3 (Nejpomaleji zdražující potravina – Cukr)
WITH rocni_ceny AS (
    SELECT DISTINCT
        rok,
        potravina_nazev,
        prumerna_cena
    FROM t_tana_silberova_projekt_SQL_primary_final
),
mezirocni_zmeny AS (
    SELECT 
        rok,
        potravina_nazev,
        prumerna_cena,
        LAG(prumerna_cena) OVER (PARTITION BY potravina_nazev ORDER BY rok) AS cena_minuly_rok
    FROM rocni_ceny
),
procentni_rust AS (
SELECT 
        potravina_nazev,
        -- Spočítáme procentuální změnu oproti minulému roku
        ((prumerna_cena - cena_minuly_rok) / cena_minuly_rok) * 100 AS zmena_procenta
    FROM mezirocni_zmeny
    WHERE cena_minuly_rok IS NOT NULL
)
SELECT 
    potravina_nazev,
    ROUND(AVG(zmena_procenta)::numeric, 2) AS prumerny_rocni_rust_procenta
FROM procentni_rust
GROUP BY potravina_nazev
ORDER BY prumerny_rocni_rust_procenta ASC; -- Seřadí od nejmenšího růstu po největší




--Otázka 4 (Rok, kdy ceny utekly mzdám o 10 %)
WITH mezirocni_mzdy AS (
    SELECT 
        rok,
        prumerna_mzda,
        LAG(prumerna_mzda) OVER (ORDER BY rok) AS mzda_minuly_rok
    FROM t_tana_silberova_projekt_SQL_primary_final
    WHERE odvetvi_nazev IS NULL
    GROUP BY rok, prumerna_mzda
),
rust_mezd AS (
    SELECT 
        rok,
        ((prumerna_mzda - mzda_minuly_rok) / mzda_minuly_rok) * 100 AS rust_mezd_procenta
    FROM mezirocni_mzdy
    WHERE mzda_minuly_rok IS NOT NULL
),
mezirocni_ceny AS (
    SELECT 
        rok,
        potravina_kod,
        prumerna_cena,
        LAG(prumerna_cena) OVER (PARTITION BY potravina_kod ORDER BY rok) AS cena_minuly_rok
    FROM t_tana_silberova_projekt_SQL_primary_final
),
rust_cen_potravin AS (
    SELECT 
        rok,
        AVG(((prumerna_cena - cena_minuly_rok) / cena_minuly_rok) * 100) AS rust_cen_procenta
    FROM mezirocni_ceny
    WHERE cena_minuly_rok IS NOT NULL
    GROUP BY rok
)
SELECT 
    rm.rok,
    ROUND(rm.rust_mezd_procenta::numeric, 2) AS mezirocni_rust_mezd_pct,
    ROUND(rc.rust_cen_procenta::numeric, 2) AS mezirocni_rust_cen_pct,
    ROUND((rc.rust_cen_procenta - rm.rust_mezd_procenta)::numeric, 2) AS rozdil_v_procentech
FROM rust_mezd rm
JOIN rust_cen_potravin rc ON rm.rok = rc.rok
ORDER BY rozdil_v_procentech DESC; -- Seřadí od roku, kdy ceny nejvíc utekly mzdám



--Otázka 5 (Vliv HDP na mzdy a ceny)
WITH hdp_cr AS (
    -- Vytáhneme meziroční vývoj HDP pro Českou republiku z druhé tabulky
    SELECT 
        rok,
        hdp,
        LAG(hdp) OVER (ORDER BY rok) AS hdp_minuly_rok
    FROM t_tana_silberova_projekt_SQL_secondary_final
    WHERE stat = 'Czech Republic'
),
zmena_hdp AS (
    SELECT 
        rok,
        ((hdp - hdp_minuly_rok) / hdp_minuly_rok) * 100 AS zmena_hdp_pct
    FROM hdp_cr
    WHERE hdp_minuly_rok IS NOT NULL
    ),
mzdy_ceny AS (
    -- Vezmeme připravené meziroční změny mezd a cen (podobně jako v otázce 4)
    SELECT 
        rok,
        AVG(prumerna_mzda) AS mzda,
        LAG(AVG(prumerna_mzda)) OVER (ORDER BY rok) AS mzda_minuly_rok
    FROM t_tana_silberova_projekt_SQL_primary_final
    WHERE odvetvi_nazev IS NULL
    GROUP BY rok
),
zmena_mezd AS (
    SELECT 
        rok,
        ((mzda - mzda_minuly_rok) / mzda_minuly_rok) * 100 AS zmena_mezd_pct
    FROM mzdy_ceny
    WHERE mzda_minuly_rok IS NOT NULL
),
ceny_potravin AS (
    SELECT 
        rok,
        potravina_kod,
        prumerna_cena,
        LAG(prumerna_cena) OVER (PARTITION BY potravina_kod ORDER BY rok) AS cena_minuly_rok
    FROM t_tana_silberova_projekt_SQL_primary_final
),
zmena_cen AS (
    SELECT 
        rok,
        AVG(((prumerna_cena - cena_minuly_rok) / cena_minuly_rok) * 100) AS zmena_cen_pct
    FROM ceny_potravin
    WHERE cena_minuly_rok IS NOT NULL
     GROUP BY rok
)
-- Spojíme všechna procenta vedle sebe podle roku
SELECT 
    h.rok,
    ROUND(h.zmena_hdp_pct::numeric, 2) AS mezirocni_zmena_HDP_pct,
    ROUND(m.zmena_mezd_pct::numeric, 2) AS mezirocni_zmena_mezd_pct,
    ROUND(c.zmena_cen_pct::numeric, 2) AS mezirocni_zmena_cen_potravin_pct
FROM zmena_hdp h
JOIN zmena_mezd m ON h.rok = m.rok
JOIN zmena_cen c ON h.rok = c.rok
ORDER BY h.rok;