drop table cohort;
create table cohort as (
with cohort as (
select distinct on (admissions.subject_id) admissions.*, patients.gender, icustays.stay_id, icustays.intime, icustays.outtime, icustays.los from diagnoses_icd
join admissions
using (hadm_id)
join icustays
using (hadm_id)
join patients on admissions.subject_id = patients.subject_id
where icd_code in ('43301', '43311', '43321', '43331', '43381', '43391')
or icd_code ilike '434%'
-- or icd_code ilike 'I62%'
or icd_code ilike 'I63%'
order by admissions.subject_id, intime asc
),
tpa as (
select * from inputevents
where itemid = 221319
),
tmb as (
select * from procedures_icd join
d_icd_procedures using (icd_code)
where icd_code = '3974'
or icd_code ilike '03CG%'
),
aspirin_pred as (
select *, starttime - intime as med_time 
from cohort
join prescriptions using (hadm_id)
where (drug ilike '%aspirin%'
or drug ilike '%clopidogrel%')
and dose_val_rx = '300'
and starttime - intime > interval '24' hour
),
inpatient_stroke as (
select distinct on (stay_id) stay_id, med_time from aspirin_pred
order by stay_id, starttime
)
select cohort.*, case when age > 89 then 89 else age end as age, case when med_time is not null then 1 else 0 end as inpatient_stroke
from cohort
join age using (hadm_id)
left join inpatient_stroke on cohort.stay_id = inpatient_stroke.stay_id
where hadm_id not in (select distinct hadm_id from tpa)
and hadm_id not in (SELECT DISTINCT hadm_id from tmb)
and (edregtime is null) or (intime - edregtime <= interval '8' hour) -- only include "pure" stroke cases
and med_time is null -- exclude inpatient_stroke
-- and hadm_id not in (SELECT DISTINCT hadm_id from aspirin)
-- and hadm_id not in (SELECT DISTINCT hadm_id from aspirin_pred)
and age >= 18
order by subject_id
)
-- need to exclude patients whose icu_intime is 24 hours later than the edregtime