select distinct a.fips
into county_id
from primary_results_csv_poprawna a
join primary_results_csv b on a.fips = b.fips

select
--		fips,
--		area_name,
--		state_abbreviation,
--		population_2014,
		percentile_disc(array[0.25, 0.5, 0.75]) within group (order by black_or_aa_pct_2014)
from primary_results_csv_poprawna a
join county_id b on a.fips = b.fips;

--przedziały 1, 3, 13
select a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when black_or_aa_pct_2014 < 1 then '< 1'
			 when black_or_aa_pct_2014 between 1 and 3 then '1 - 3'
			 when black_or_aa_pct_2014 between 3 and 13 then '3 - 13'
			 else '> 13'
		end black_or_aa_pct_2014
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
into Results2
from cte a
where votes_pct > 0.5
order by state, county, party;
 
drop table Results2;
drop table black_or_aa_pct_2014;

select
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when black_or_aa_pct_2014 < 1 then '< 1'
			 when black_or_aa_pct_2014 between 1 and 3 then '1 - 3'
			 when black_or_aa_pct_2014 between 3 and 13 then '3 - 13'
			 else '> 13'
			 end Var,--black_or_aa_pct_2014,
			 b.party,
			 b.sum_total,
			 b.sum_party,
			 b.votes_pct,
		case when party = 'Republican' then 1 else 0 end Party_Republican,
		case when party = 'Democrat' then 1 else 0 end Party_Democrat
--into temporary table black_or_aa_pct_2014
		from primary_results_csv_poprawna a
join Results2 b on a.fips = b.fips;

drop table Information_Value_temp;

with cte as(
select Var,
		count(*) Liczba,
		sum(Party_Republican) Party_Republican,
		 sum(Party_Democrat) Party_Democrat
from black_or_aa_pct_2014
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
select * from Information_Value_temp;