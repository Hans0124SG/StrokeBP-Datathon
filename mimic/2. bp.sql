drop table bp;
create table bp as (
with raw_bp as (
select cohort.hadm_id, cohort.intime, vitalsign.*, (charttime - cohort.intime) as bp_time from cohort
join vitalsign
on cohort.stay_id = vitalsign.stay_id
where (charttime - cohort.intime) <= interval '6' hour
)
select subject_id, hadm_id, stay_id,
min(mbp) as min_mbp,
max(mbp) as max_mbp,
avg(mbp) as avg_mbp,
min(mbp_ni) as min_mbp_ni,
max(mbp_ni) as max_mbp_ni,
avg(mbp_ni) as avg_mbp_ni,
min(sbp) as min_sbp,
max(sbp) as max_sbp,
avg(sbp) as avg_sbp,
min(sbp_ni) as min_sbp_ni,
max(sbp_ni) as max_sbp_ni,
avg(sbp_ni) as avg_sbp_ni
from raw_bp
group by 1,2,3
)