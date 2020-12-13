drop table agg_iv_meds;
create table agg_iv_meds as (
with temp as (
select cohort.intime, cohort.stay_id, iv_meds.* from cohort
join iv_meds using (hadm_id)
where iv_starttime - intime <= interval '6' hour
)
select subject_id, hadm_id, stay_id
, max(heparin_iv) as heparin_iv
, max(antihypertensive_iv_non_tight_control) as antihypertensive_iv_non_tight_control
, max(antihypertensive_iv_tight_control) as antihypertensive_iv_tight_control
, max(inotropes) as inotropes
from temp
group by 1,2,3
)