-- Database: TCC

----------------Generating Final Database----------------

-------------------Tables in this code-------------------

--public."Acordos_inicial"
--public."Base_Shannon"
--public."Depara_ISO"
--public."Dados_WB1"
--public."Dados_WB2"
--public."Living_Planet"
--public."Temperature"
--public.vdem

--------------------------CODE--------------------------


WITH Shannon as (
select A.*, B."alpha-3" from public."Base_Shannon" A
LEFT JOIN public."Depara_ISO" B
	ON A."countrycode" = B."alpha-2"
)

,LPI_REGIONS_DEPARA AS (
select 
*,
CASE
	WHEN "region" = 'Europe'  THEN 'Europe and Central Asia'
	WHEN "region" = 'Africa'  THEN 'Africa'
	WHEN "region" = 'Oceania' THEN 'Asia and Pacific'
	WHEN "sub-region" = 'Latin America and the Caribbean' THEN 'Latin America and the Caribbean'
	WHEN "sub-region" = 'Central Asia' THEN 'Europe and Central Asia'
	WHEN "region" = 'Asia' and "sub-region" not like 'Central Asia' THEN 'Europe and Central Asia'
	WHEN "sub-region" = 'Northern America' THEN 'North America'
	end as LPI_REGIONS
from  public."Depara_ISO"
)


, ACORDOS_ASSINADOS AS (
select distinct D.*, X."alpha-2", X."name", X."alpha-3" from (
select "N_Pais", "year", SUM("FLAG_CLAUSULA") over(partition by "N_Pais", "year") as soma FROM (
select * from 
(select *, ROW_NUMBER () OVER (partition by "N_Pais", "N_Pergunta" ORDER BY "year") as ordem from  (
SELECT * FROM public."Acordos_inicial" where "FLAG_CLAUSULA" = 1) z) A WHERE "ordem" = 1
) B ) D
LEFT JOIN public."Depara_ISO" X
	ON X."countrycode" = D."N_Pais"
)


, Base_almost as (
select 
"Country_Name",
"Country_Code",
"Time",
"GDP",
"Exports",
"Imports",
"CO2_GDP",
"CO2_percapita",
"Shannon_index",
 case
			when "assinadas" is null then 0
			else "assinadas"
			end as F_assinadas
from (
select *, SUM("soma") over(partition by "Country_Code" order by "Time") as Assinadas from (
select A."Country_Name", A."Country_Code", A."Time", A."GDP", A."Exports", A."Imports", A."CO2_GDP", A."CO2_percapita", B."soma", Z."Shannon_index"
from public."Dados_WB1" A
LEFT JOIN ACORDOS_ASSINADOS B
ON A."Country_Code" = B."alpha-3" and A."Time" = B."year"
LEFT JOIN Shannon Z
ON A."Country_Code" = Z."alpha-3" and A."Time" = Z."year"
) C ) D
order by "Country_Name"
)

, BASE_LPI AS (
select A.*, B."alpha-3", B.LPI_REGIONS from public."Living_Planet" A
LEFT JOIN LPI_REGIONS_DEPARA B
ON A."Entity" = B.LPI_REGIONS
)



select a.*,
b."Forest_area",
b."Land_area",
b."Mobile_cell",
b."Population",
c."Living Planet index",
c.LPI_REGIONS,
d."v2x_polyarchy",
d."v2x_libdem",
d."v2x_partidem"
from Base_almost a
LEFT JOIN public."Dados_WB2" b
on a."Country_Code" = b."Country_Code" and a."Time" = b."Time"
LEFT JOIN BASE_LPI c
on a."Country_Code" = C."alpha-3" and a."Time" = c."Year"
LEFT JOIN public."vdem" d
on a."Country_Code" = d."country_text_id" and a."Time" = d."year"
where a."Country_Name" not in ('Moldova','Bosnia','Albania','Haiti')
and a."Time" >= 2000  
and a."Time" <= 2016

--Total 69 Countries
--Time window 2000-2016

