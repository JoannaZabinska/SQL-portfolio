select distinct a.fips
into county_id
from primary_results_csv_poprawna a
join primary_results_csv b on a.fips = b.fips

select
--		fips,
--		area_name,
--		state_abbreviation,
--		population_2014,
		percentile_disc(array[0.25, 0.5, 0.75]) within group (order by hispanic_or_latino_pct_2014
)
from primary_results_csv_poprawna a
join county_id b on a.fips = b.fips;

--przedzia³y {2.1,4.0,9.6}
select a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when hispanic_or_latino_pct_2014
 < 2 then '< 2'
			when hispanic_or_latino_pct_2014
 between 2 and 4 then '2 - 4'
			 when hispanic_or_latino_pct_2014
 between 4 and 10 then '4 - 10'
			 else '>10'
		end hispanic_or_latino_pct_2014
		from primary_results_csv_poprawna a
		join county_id b on a.fips = b.fips;

with cte as (
select  a.state,
		a.state_abbreviation,
		a.county,
		a.fips,
		a.party,
		sum(votes) over (partition by a.state, a.state_abbreviation, a.county, a.fips) sum_total,
		sum(votes) over (partition by a.state, a.state_abbreviation, a.county, a.fips, party) sum_party,
		case when sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips) = 0
		then 0
		else sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips, party)/
		sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips)
		end votes_pct
from primary_results_csv a
join county_id b on a.fips = b.fips
)
select distinct a.*
into Results6
from cte a
where votes_pct > 0.02
order by state, county, party;
 
drop table Results6;
drop table hispanic_or_latino_pct_2014

;

select
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
case when hispanic_or_latino_pct_2014
 < 2 then '< 2'
			when hispanic_or_latino_pct_2014
 between 2 and 4 then '2 - 4'
			 when hispanic_or_latino_pct_2014
 between 4 and 10 then '4 - 10'
			 else '>10'
		end Var,--hispanic_or_latino_pct_2014
			 b.party,
			 b.sum_total,
			 b.sum_party,
			 b.votes_pct,
		case when party = 'Republican' then 1 else 0 end Party_Republican,
		case when party = 'Democrat' then 1 else 0 end Party_Democrat
into temporary table hispanic_or_latino_pct_2014

		from primary_results_csv_poprawna a
join Results6 b on a.fips = b.fips;

drop table Information_Value_temp;

with cte as(
select Var,
		count(*) Liczba,
		sum(Party_Republican) Party_Republican,
		 sum(Party_Democrat) Party_Democrat
from hispanic_or_latino_pct_2014
group by Var
)
, 
cte2 as ( 
	select a.*,
		Party_Republican::float/sum(Party_Republican::float) over () as Distribution_Rep,
		Party_Democrat::float/sum(Party_Democrat::float) over () as Distribution_Dem
from cte a
)
,
cte3 as (
select *,
		ln(Distribution_Dem::float/ Distribution_Rep) as WOE,
		Distribution_Dem::float - Distribution_Rep as  "D_Dem - D_Rep",
		(Distribution_Dem::float - Distribution_Rep) * ln(Distribution_Dem::float/ Distribution_Rep)  as inf_val_czastkowe
from cte2
)
select sum(inf_val_czastkowe) inf_val from cte3
;