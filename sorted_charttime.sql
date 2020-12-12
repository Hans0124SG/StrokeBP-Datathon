SELECT hadm_id, subject_id, itemid, charttime, value,
         label, ROW_NUMBER() OVER(PARTITION BY hadm_id, label
                                        ORDER BY charttime ASC) AS rk
  FROM labevents
  JOIN d_labitems
    USING (itemid)
    WHERE hadm_id IS NOT NULL AND
          label IN ('Creatinine', 'Glucose', 'Triglycerides', 'Cholesterol, LDL, Calculated') ORDER BY charttime