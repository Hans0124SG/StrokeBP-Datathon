drop table eicu_cohort;
create table eicu_cohort as (
with cohort as (
select * from patient
where apacheadmissiondx = 'CVA, cerebrovascular accident/stroke'
),
clean_diagnosis as (
select patientunitstayid
    , max(case when diagnosisstring ILIKE '%ischemic stroke%' and diagnosisPriority = 'Primary' THEN 1 ELSE 0 END) AS is_primary
	, max(case when diagnosisstring ILIKE '%ischemic stroke%' then 1 else 0 end) as ais
	, max(case when diagnosisstring ilike '%hemorrhagic stroke%' then 1 else 0 end) as hs
	from diagnosis
	join cohort using (patientunitstayid)
	group by patientunitstayid
),
clean_treatment as (
select distinct patientunitstayid from treatment
	where treatmentstring ILIKE '%neurologic|ICH/ cerebral infarct|thrombolytics|mechanical thrombolysis%' or treatmentstring ILIKE '%thrombolytics%'
),
clean_medication as (
SELECT patientunitstayid
FROM medication
WHERE drugname ILIKE '%alteplase%'
)
select cohort.*, basic_demographics.hosp_mortality, basic_demographics.icu_los_hours, clean_diagnosis.is_primary,
	case when basic_demographics.age in ('> 89', '>89') then 89 else CAST (basic_demographics.age AS integer) end as correct_age from cohort
join clean_diagnosis using (patientunitstayid)
join basic_demographics using (patientunitstayid)
where ais - hs = 1
and basic_demographics.age <> '<18'
and unitvisitnumber = 1
and patientunitstayid not in (select * from clean_treatment)
and patientunitstayid not in (select * from clean_medication)
)