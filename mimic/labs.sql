create table labs as (
with glu as (
	select distinct on (hadm_id) hadm_id, glucose as first_glu from chemistry
where glucose is not null
order by hadm_id, charttime asc)
, cre as (
	select distinct on (hadm_id) hadm_id, creatinine as first_cre from chemistry
where creatinine is not null
order by hadm_id, charttime asc)
select * from cohort 
left join glu using (hadm_id)
left join cre using (hadm_id)
)