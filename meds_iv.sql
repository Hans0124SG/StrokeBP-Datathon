SELECT subject_id, hadm_id, STARTTIME AS iv_starttime,
    MAX(CASE WHEN medication ILIKE '%Heparin%' THEN 1 ELSE 0 END) AS heparin_iv,
    MAX(CASE WHEN (medication ILIKE '%atenolol%'
               OR medication ILIKE '%labetalol%'
               OR medication ILIKE '%metoprolol%'
               OR medication ILIKE '%esmolol%'
               OR medication ILIKE '%Nicardipine%'
               OR medication ILIKE '%Dilitazem%'
               OR medication ILIKE '%Verapamil%'
               OR medication ILIKE '%furosemide%'
               OR medication ILIKE '%nitroprusside%'
               OR medication ILIKE '%Hydralazine%') THEN 1 ELSE 0 END) AS antihypertensive_iv
FROM inputevents
JOIN (SELECT ITEMID, LABEL AS medication FROM d_items) iv_med_names USING (ITEMID)
WHERE starttime IS NOT NULL AND hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, STARTTIME