SELECT subject_id, hadm_id, starttime,
    MAX(CASE WHEN (drug ILIKE '%clopidogrel%'
               OR drug ILIKE '%ticagrelor%'
               OR drug ILIKE '%prasugrel%'
               OR drug ILIKE '%Dipyridamole%'
               OR drug ILIKE '%aspirin%') THEN 1 ELSE 0 END) AS antiplatelets,
    MAX(CASE WHEN (drug ILIKE '%Warfarin%'
               OR drug ILIKE '%Apixaban%'
               OR drug ILIKE '%Dabigatran%'
               OR drug ILIKE '%Rivaroxaban%'
               OR drug ILIKE '%Edoxaban%') THEN 1 ELSE 0 END) AS anticoag,
    MAX(CASE WHEN (drug ILIKE '%captopril%'
                   OR drug ILIKE '%enalapril%'
                   OR drug ILIKE '%lisinopril%'
                   OR drug ILIKE '%Benazapril%'
                   OR drug ILIKE '%candesartan%'
                   OR drug ILIKE '%losartan%'
                   OR drug ILIKE '%telmisartan%'
                   OR drug ILIKE '%valsartan%'
                   OR drug ILIKE '%bisoprolol%'
                   OR drug ILIKE '%carvedilol%'
                   OR drug ILIKE '%propanolol%'
                   OR drug ILIKE '%Timolol%'
                   OR drug ILIKE '%amlodipine%'
                   OR drug ILIKE '%nifedipine%'
                   OR drug ILIKE '%Nimodipine%'
                   OR drug ILIKE '%Fosinopril%'
                   OR drug ILIKE '%Moexipril%'
                   OR drug ILIKE '%Perindopril%'
                   OR drug ILIKE '%Quinapril%'
                   OR drug ILIKE '%Ramipril%'
                   OR drug ILIKE '%Trandolapril%'
                   OR drug ILIKE '%hydrochlorothiazide%'
                   ) THEN 1 ELSE 0 END) AS antihypertensive_non_iv
FROM prescriptions
WHERE starttime IS NOT NULL
GROUP BY subject_id, hadm_id, starttime