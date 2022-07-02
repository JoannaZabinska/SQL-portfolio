select a.*
into temporary table Candidates_Results
from primary_results_csv a
join county_id b on a.fips = b.fips
;


drop table Candidates_Winners;
with winners as (
select a.fips,
		a.state,
		a.county,
		a.party,
		a.candidate,
		fraction_votes,
		row_number() over (partition by a.state, a.county, a.party order by fraction_votes desc) rn
from Candidates_Results a
)
select a.*
into temporary table Candidates_Winners
from winners a
where a.rn = 1
;


with cte as (
select a.*,
		case when white_pct_2014 < 78 then '< 78'
			 when white_pct_2014 between 78 and 91 then '78 - 91'
			 when white_pct_2014 between 91 and 96 then '91 - 96'
			 else '> 96'
			 end Var
from Candidates_Winners a
join primary_results_csv_poprawna b on a.fips = b.fips
)
, cte2 as (
select a.party,
		a.candidate,
		a.Var,
		count(*) Liczba_hrabstw
from cte a
group by a.party,
		a.candidate,
		a.Var
)
select a.*,
		sum(liczba_hrabstw) over (partition by party, var) liczba_hrabstw_w_grupie
from cte2 a
order by party, var, candidate