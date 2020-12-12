drop table cohort;
create table cohort as (
with cohort as (
select distinct on (admissions.subject_id, hadm_id) admissions.*, patients.gender, icustays.stay_id, icustays.intime, icustays.outtime, icustays.los from diagnoses_icd
join admissions
using (hadm_id)
join icustays
using (hadm_id)
join patients on admissions.subject_id = patients.subject_id
where icd_code in ('43301', '43311', '43321', '43331', '43381', '43391')
or icd_code ilike '434%'
-- or icd_code ilike 'I62%'
or icd_code ilike 'I63%'
order by admissions.subject_id, hadm_id, intime asc
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
aspirin as (
select *, charttime - admittime as med_time 
from cohort
join emar using (hadm_id)
where (medication ilike '%aspirin%'
or medication ilike '%clopidogrel%')
and charttime - admittime  > interval '24' hour
),
aspirin_pred as (
select *, starttime - admittime as med_time 
from cohort
join prescriptions using (hadm_id)
where (drug ilike '%aspirin%'
or drug ilike '%clopidogrel%')
and dose_val_rx = '300'
and starttime - admittime > interval '24' hour
)
select cohort.*, case when age > 89 then 89 else age end as age
from cohort
join age using (hadm_id)
where hadm_id not in (select distinct hadm_id from tpa)
and hadm_id not in (SELECT DISTINCT hadm_id from tmb)
and hadm_id not in (SELECT DISTINCT hadm_id from aspirin)
and hadm_id not in (SELECT DISTINCT hadm_id from aspirin_pred)
and age >= 18
order by subject_id
)
