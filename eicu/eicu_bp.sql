drop table eicu_bp;
create table eicu_bp as (
with raw_bp as (
select * from eicu_cohort join
pivoted_vital using (patientunitstayid)
where chartoffset <= 6*60
)
select patientunitstayid,
min(nibp_mean) as min_nibp,
max(nibp_mean) as max_nibp,
avg(nibp_mean) as avg_nibp,
min(ibp_mean) as min_ibp,
max(ibp_mean) as max_ibp,
avg(ibp_mean) as avg_ibp,
min(nibp_systolic) as min_nibp_systolic,
max(nibp_systolic) as max_nibp_systolic,
avg(nibp_systolic) as avg_nibp_systolic,
min(ibp_systolic) as min_ibp_systolic,
max(ibp_systolic) as max_ibp_systolic,
avg(ibp_systolic) as avg_ibp_systolic
from raw_bp
group by patientunitstayid
)