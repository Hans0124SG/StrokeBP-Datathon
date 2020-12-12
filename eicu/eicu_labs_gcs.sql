create table eicu_labs_gcs as (
with glu as (
	select distinct on (patientunitstayid) patientunitstayid, glucose from pivoted_lab
where glucose is not null
order by patientunitstayid, chartoffset asc
),
cre as (
	select distinct on (patientunitstayid) patientunitstayid, creatinine from pivoted_lab
where creatinine is not null
order by patientunitstayid, chartoffset asc
),
gcss as (
	select distinct on (patientunitstayid) patientunitstayid, gcs from pivoted_gcs
where gcs is not null
order by patientunitstayid, chartoffset asc
)
select * from eicu_cohort 
left join glu using (patientunitstayid)
left join cre using (patientunitstayid)
left join gcss using (patientunitstayid)
)