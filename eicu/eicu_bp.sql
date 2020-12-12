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
avg(ibp_mean) as avg_ibp
from raw_bp
group by patientunitstayid
)