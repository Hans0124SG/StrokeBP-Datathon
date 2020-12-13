drop table agg_comorb;
create table agg_comorb as (
select subject_id, hadm_id, max(atrial_fibrill) as afib,
max(hyperlipidemia) as hyperlipidemia, max(diabetes) as diabetes, max(hypertension) as hypertension,
max(cor_artery_d) as cor_art_d, max(peri_vasc_d) as peri_vasc_d, max(carotid_art_stentosis) as car_art_stent,
max(smoking) as smoking, max(trans_ischemic_atk) as tia
from comobidities
group by 1,2
)