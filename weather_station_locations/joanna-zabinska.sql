--a)Jaka by³a i w jakim kraju mia³a miejsce najwy¿sza dzienna amplituda temperatury?

--aplituda = maxtemp - mintemp

select "STATE/COUNTRY ID","name",max(dzienna_amplituda)
from (
select sta, "Date" date , maxtemp, mintemp, wslc."STATE/COUNTRY ID", wslc."name", maxtemp - mintemp dzienna_amplituda 
from summary_of_weather_csv sowc 
join weather_station_locations_csv wslc 
on sta = wban
) as t
where dzienna_amplituda is not null
group by "STATE/COUNTRY ID","name"
order by max(dzienna_amplituda) desc
;

--b)Z czym silniej skorelowana jest œrednia dzienna temperatura dla stacji – szerokoœci¹
--(lattitude) czy d³ugoœci¹ (longtitude) geograficzn¹?

select corr(meantemp, latitude) korelacja_z_lat,corr(meantemp, longitude) korelacja_z_long
from(
select meantemp, wslc.latitude, wslc.longitude
from summary_of_weather_csv sowc 
join weather_station_locations_csv wslc 
on sta = wban) as t
;

--ODP: silniej skorelowana jest z szerokoœci¹

--c)Poka¿ obserwacje, w których suma opadów atmosferycznych (precipitation) przekroczy³a
--sumê opadów z ostatnich 5 obserwacji na danej stacji.
--wybieram kolumne precip bo ma opady w mm
--T jest to Trace czyli w meteorologii œlad oznacza iloœæ opadów, 
--takich jak deszcz lub œnieg, która jest wiêksza od zera, 
--ale jest zbyt ma³a, aby zmierzyæ j¹ za pomoc¹ standardowych jednostek lub metod pomiaru.

with cte as
(
select sta,"Date","name", 	
case
	when precip ='T' then '0'
	else precip
	end as precip1,
	RANK() over (partition by "name" order by "Date"::date desc) ranking
from summary_of_weather_csv sowc 
join weather_station_locations_csv wslc 
on sta = wslc.wban
),
cte2 as 
(
select *, sum(precip1::float) over (partition by "name") suma_z_5 from cte 
where ranking between 1 and 5
)

select sta,"name", suma_z_5 from cte2 
where precip1::float > suma_z_5
group by sta,"name", suma_z_5;


--d)Uszereguj stany/pañstwa wed³ug od najni¿szej temperatury zanotowanej tam w okresie
--obserwacji u¿ywaj¹c do tego funkcji okna

select * from (
select wban, wslc."name", wslc."STATE/COUNTRY ID", "Date", mintemp,
row_number() over (partition by "STATE/COUNTRY ID" order by mintemp, "name", "Date") rank_1
from summary_of_weather_csv sowc 
join weather_station_locations_csv wslc 
on sta = wban
) as da
where rank_1 = 1
order by mintemp
;

--e)BONUS: czy gdzieœ mogliœmy doœwiadczyæ lipcowych opadów œniegu?

select distinct sta, wslc."name", wslc."STATE/COUNTRY ID", "Date", snowfall 
from summary_of_weather_csv sowc 
join weather_station_locations_csv wslc 
on sta = wban
where snowfall != '0' and snowfall != '' and "Date" like '%-7-%'
;
