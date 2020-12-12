create table agg_iv_meds as (
with temp as (
select cohort.intime, cohort.stay_id, iv_meds.* from cohort
join iv_meds using (hadm_id)
where iv_starttime - intime <= interval '6' hour
)
select subject_id, hadm_id, stay_id
, sum(heparin_iv) as heparin_iv
, sum(antihypertensive_iv) as antihypertensive_iv
from temp
group by 1,2,3
)