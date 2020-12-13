drop table eicu_comorb;
create table eicu_comorb as (
with temp as (
SELECT
  patientunitstayid,
  max(CASE WHEN pasthistoryvalue ILIKE '%hypertension%' THEN 1 ELSE 0 END) AS Hypertension,
  max(CASE WHEN pasthistoryvalue ILIKE '%MI -%'
  OR pasthistoryvalue ILIKE '%CABG%'
  OR pasthistoryvalue ILIKE '%angina%'
  OR pasthistoryvalue ILIKE '%procedural coronary intervention%' THEN 1 ELSE 0 END) AS Ischemic_Heart_Disease,
    max(CASE WHEN pasthistoryvalue ILIKE '%peripheral vascular disease%' THEN 1 ELSE 0 END) AS Peripheral_vascular_disease,
    max(CASE WHEN pasthistoryvalue ILIKE '%atrial fibrillation%' THEN 1 ELSE 0 END) AS Atrial_fibrillation,
    max(CASE WHEN pasthistoryvalue ILIKE '%TIA(s)%' THEN 1 ELSE 0 END) AS Transient_ischemic_attack,
    max(CASE WHEN pasthistoryvalue ILIKE '%stroke%' THEN 1 ELSE 0 END) AS Previous_stroke
  FROM
  pasthistory
  GROUP BY patientunitstayid
),
hp as (
SELECT patientunitstayid, max(CASE WHEN icd9code ilike '%272.4%' OR diagnosisstring ilike '%hyperlipidemia%' THEN 1 ELSE 0 END) as hyperlipidemia
	FROM diagnosis
group by 1
)
select temp.*, diabetes, hyperlipidemia from temp
join apachepredvar
using (patientunitstayid)
join hp
using (patientunitstayid)
join eicu_cohort
using (patientunitstayid)
)