drop table iv_meds;
create table iv_meds as (
SELECT subject_id, hadm_id, STARTTIME AS iv_starttime,
    MAX(CASE WHEN medication ILIKE '%Heparin%' THEN 1 ELSE 0 END) AS heparin_iv,
    MAX(CASE WHEN (medication ILIKE '%atenolol%'
               OR medication ILIKE '%metoprolol%'
               OR medication ILIKE '%Dilitazem%'
               OR medication ILIKE '%Verapamil%'
               OR medication ILIKE '%furosemide%') THEN 1 ELSE 0 END) AS antihypertensive_iv_non_tight_control,
	MAX(CASE WHEN (medication ILIKE '%labetalol%'
               OR medication ILIKE '%esmolol%'
               OR medication ILIKE '%Nicardipine%'
               OR medication ILIKE '%nitroprusside%'
               OR medication ILIKE '%Hydralazine%') THEN 1 ELSE 0 END) AS antihypertensive_iv_tight_control,
	MAX(CASE WHEN itemid in (222315, 221749, 221906, 221662, 221653) THEN 1 ELSE 0 END) AS inotropes
FROM inputevents
JOIN (SELECT ITEMID, LABEL AS medication FROM d_items) iv_med_names USING (ITEMID)
WHERE starttime IS NOT NULL AND hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, STARTTIME
)