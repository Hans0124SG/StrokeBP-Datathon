create table agg_comorb as (
select subject_id, hadm_id, sum(atrial_fibrill) as afib,
sum(hyperlipidemia) as hyperlipidemia, sum(diabetes) as diabetes, sum(hypertension) as hypertension,
sum(cor_artery_d) as cor_art_d, sum(peri_vasc_d) as peri_vasc_d, sum(carotid_art_stentosis) as car_art_stent,
sum(smoking) as smoking, sum(trans_ischemic_atk) as tia
from comobidities
group by 1,2
)