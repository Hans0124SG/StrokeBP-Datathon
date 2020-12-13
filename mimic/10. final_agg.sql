select * from cohort 
left join bp on cohort.stay_id = bp.stay_id
left join flgcs on cohort.hadm_id = flgcs.hadm_id
left join agg_comorb on agg_comorb.hadm_id = cohort.hadm_id
left join agg_iv_meds on agg_iv_meds.hadm_id = cohort.hadm_id
left join agg_meds on agg_meds.hadm_id = cohort.hadm_id
left join labs on labs.hadm_id = cohort.hadm_id