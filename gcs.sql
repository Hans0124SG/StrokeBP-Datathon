create table flgcs as (
with raw_gcs as (
select cohort.hadm_id, cohort.admittime, gcs.*
-- 	(charttime - admittime) as gcs_time
from cohort
join icustays
on cohort.hadm_id = icustays.hadm_id
join gcs
on icustays.stay_id = "gcs".stay_id
),
first_gcs as (
select distinct on (subject_id, hadm_id) subject_id, hadm_id, gcs as first_gcs
from raw_gcs
order by subject_id, hadm_id, charttime asc 
),
last_gcs as (
select distinct on (subject_id, hadm_id) subject_id, hadm_id, gcs as last_gcs
from raw_gcs
order by subject_id, hadm_id, charttime desc 
)
select first_gcs.subject_id, hadm_id, first_gcs, last_gcs, last_gcs - first_gcs as gcs_change from first_gcs
full outer join last_gcs
using (hadm_id)
)