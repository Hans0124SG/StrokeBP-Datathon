drop table eicu_meds;
create table eicu_meds as (
WITH medication_agg_drug AS (
SELECT patientunitstayid,
    MAX(CASE WHEN (drugName ILIKE '%nitroprusside%'
                   OR drugName ILIKE '%Hydralazine%'
                   OR drugName ILIKE '%Nicardipine%'
                   OR drugName ILIKE '%labetalol%'
                   OR drugName ILIKE '%esmolol%')
                   THEN 1
                   ELSE 0 END) AS antihypertensive_iv_tight_control,
    MAX(CASE WHEN (drugName ILIKE '%atenolol%'
                   OR drugName ILIKE '%metoprolol%'
                   OR drugName ILIKE '%Dilitazem%'
                   OR drugName ILIKE '%Verapamil%'
                   OR drugName ILIKE '%furosemide%')
                   THEN 1
                   ELSE 0 END) AS antihypertensive_iv_non_tight_control,
    MAX(CASE WHEN (drugName ILIKE '%Heparin%' 
                   OR drughiclseqno in (39654, 9545, 2807, 33442, 8643, 33314, 2808, 2810))
                   THEN 1 ELSE 0 END) AS heparin_iv,
    MAX(CASE WHEN ((drugName ILIKE '%Phenylephrine%' OR drughiclseqno in (37028, 35517, 35587, 2087))
                   OR (drugName ILIKE '%Norepinephrine%' OR drughiclseqno in (37410, 36346, 2051))
                   OR (drugName ILIKE '%Dopamine%' OR drughiclseqno in (2060, 2059))
                   OR (drugName ILIKE '%Dobutamine%' OR drughiclseqno in (8777, 40))
                   OR (drugName ILIKE '%Vasopressin%' OR drughiclseqno in (38884, 38883, 2839)))
                   THEN 1
                   ELSE 0 END) AS inotropes,
    MAX(CASE WHEN (drugName ILIKE '%clopidogrel%'
               OR drugName ILIKE '%ticagrelor%'
               OR drugName ILIKE '%prasugrel%'
               OR drugName ILIKE '%Dipyridamole%'
               OR drugName ILIKE '%aspirin%') THEN 1 ELSE 0 END) AS antiplatelets,
    MAX(CASE WHEN (drugName ILIKE '%Warfarin%'
               OR drugName ILIKE '%Apixaban%'
               OR drugName ILIKE '%Dabigatran%'
               OR drugName ILIKE '%Rivaroxaban%'
               OR drugName ILIKE '%Edoxaban%') THEN 1 ELSE 0 END) AS anticoag,
    MAX(CASE WHEN (drugName ILIKE '%captopril%'
                   OR drugName ILIKE '%enalapril%'
                   OR drugName ILIKE '%lisinopril%'
                   OR drugName ILIKE '%Benazapril%'
                   OR drugName ILIKE '%candesartan%'
                   OR drugName ILIKE '%losartan%'
                   OR drugName ILIKE '%telmisartan%'
                   OR drugName ILIKE '%valsartan%'
                   OR drugName ILIKE '%bisoprolol%'
                   OR drugName ILIKE '%carvedilol%'
                   OR drugName ILIKE '%propanolol%'
                   OR drugName ILIKE '%Timolol%'
                   OR drugName ILIKE '%amlodipine%'
                   OR drugName ILIKE '%nifedipine%'
                   OR drugName ILIKE '%Nimodipine%'
                   OR drugName ILIKE '%Fosinopril%'
                   OR drugName ILIKE '%Moexipril%'
                   OR drugName ILIKE '%Perindopril%'
                   OR drugName ILIKE '%Quinapril%'
                   OR drugName ILIKE '%Ramipril%'
                   OR drugName ILIKE '%Trandolapril%'
                   OR drugName ILIKE '%hydrochlorothiazide%'
                   ) THEN 1 ELSE 0 END) AS antihypertensive_non_iv
FROM medication
WHERE drugOrderCancelled = 'No' AND (drugStartOffset > 0 AND drugStartOffset < 6*60)
GROUP BY patientunitstayid)
SELECT medication_agg_drug.* FROM medication_agg_drug
join eicu_cohort using (patientunitstayid)
)