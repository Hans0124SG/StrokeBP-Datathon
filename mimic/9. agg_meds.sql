drop table agg_meds;
create table agg_meds as (
with temp as (
select cohort.intime, cohort.stay_id, meds.* from cohort
join meds using (hadm_id)
where starttime - intime <= interval '6' hour
)
select subject_id, hadm_id, stay_id
, max(antiplatelets) as antiplatelets
, max(anticoag) as anticoag
, max(antihypertensive_non_iv) as antihypertensive_non_iv
from temp
group by 1,2,3
)