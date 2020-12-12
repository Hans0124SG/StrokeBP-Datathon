select * from eicu_cohort
left join eicu_bp using (patientunitstayid)
left join eicu_labs_gcs using (patientunitstayid)
left join eicu_meds using (patientunitstayid)