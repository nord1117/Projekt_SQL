# Výzkumný projekt: Životní úroveň v ČR (SQL)

## Úvod do projektu
V tomto projektu se zabývám dostupností základních potravin široké veřejnosti v České republice. Porovnávám průměrné příjmy obyvatel s cenami potravin za srovnatelné období.

## Datové podklady
V projektu jsem pracovala s datovými sadami:
* czechia_payroll (Informace o mzdách v různých odvětvích)
* czechia_price (Informace o cenách vybraných potravin)
* economies (HDP, GINI koeficient a populace států)

 ## Tvorba finálních tabulek
Pro analýzu jsem v databázi vytvořila dvě hlavní finální tabulky:
1. `t_tana_silberova_projekt_SQL_primary_final` – sjednocená data mezd a cen potravin za ČR na totožné porovnatelné období (společné roky 2006–2018). Data o mzdách byla očištěna (použit pouze kód 5958 pro průměrnou mzdu a kód 200 pro přepočtené počty).
2. `t_tana_silberova_projekt_SQL_secondary_final` – dodatečná ekonomická data o dalších evropských státech ve stejném období.

## Odpovědi na výzkumné otázky

### Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? **Odpověď**:
Mzdy v průběhu let nerostou ve všech odvětvích. V datech existují roky, kdy v určitých oborech průměrná mzda meziročně klesla. Kritický rok 2013: Tento rok byl pro poklesy mezd nejvýraznější. Mzdy klesly hned v několika odvětvích najednou (např. ve Stavebnictví, Informačních činnostech, nebo ve Výrobě a rozvodu elektřiny). Největší propad: K největšímu propadu došlo v roce 2013 v Peněžnictví a pojišťovnictví, kde průměrná mzda klesla o 4 484 Kč oproti roku 2012. Dlouhodobý pokles: Odvětví Těžba a dobývání zaznamenalo poklesy opakovaně v letech 2009, 2013, 2014 a 2016.

### Otázka 2:Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? **Odpověď**:
Prvním srovnatelným obdobím je rok 2006 (průměrná mzda 19 536 Kč) a posledním kompletním srovnatelným obdobím je rok 2018 (průměrná mzda 32 043 Kč). Chléb: V roce 2006 stál kilogram chleba 16,12 Kč a z průměrné mzdy bylo možné koupit 1 211 kg. V roce 2018 stál chléb 24,24 Kč, ale díky vyšší mzdě si občan mohl koupit 1 321 kg (o 110 kg více). Mléko: V roce 2006 stál litr mléka 14,44 Kč, což odpovídalo 1 353 litrům. V roce 2018 stála jednotka 19,82 Kč a z výplaty bylo možné pořídit 1 616 litrů (o 263 litrů více). Závěr: Kupní síla obyvatel se u těchto základních potravin v průběhu let zvýšila.

### Otázka 3:Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? **Odpověď**:
Kategorie potravin, která zdražuje nejpomaleji, je Cukr krystalový. V průměru u něj docházelo k meziročnímu poklesu ceny o 1,92 %. Druhým nejvýhodnějším artiklem byla Rajská jablka červená kulatá s průměrným meziročním poklesem o 0,74 %. Naopak nejrychleji ze všech sledovaných potravin zdražovaly Papriky (průměrný meziroční nárůst o 7,29 %) a Máslo (nárůst o 6,67 %). 

### Otázka 4:Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?  **Odpověď**:
V celém sledovaném období neexistuje rok, ve kterém byl meziroční nárůst cen potravin o více než 10 % vyšší než růst mezd. Nejvýraznější rozdíl: K největšímu rozevření nůžek v neprospěch občanů došlo v roce 2013, kdy průměrné mzdy klesly o 0,13 %, zatímco ceny potravin mírně vzrostly o 0,30 %. Rozdíl však činil pouhých 0,43 %. Dlouhodobý trend: Data ukazují, že ve většině let růst mezd spolehlivě překonával tempo zdražování potravin (např. v letech 2017 a 2018 rostly mzdy o 6 až 8 % rychleji než ceny jídla).

### Otázka 5:Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem? **Odpověď**:
Výška HDP má vliv na změny ve mzdách, ale tento vliv se projevuje s ročním až dvouletým zpožděním. Výrazný růst HDP v roce 2015 (5,39 %) nastartoval masivní růst mezd až v letech 2017 (6,74 %) a 2018 (8,16 %). Podobně hospodářský pokles v roce 2009 (-4,66 %) utlumil růst mezd až v následujících letech 2010 a 2011. Na ceny potravin nemá výška HDP přímý zásadní vliv, ceny potravin vykazovaly stabilní a nezávislý vývoj.
