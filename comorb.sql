select subject_id, 
hadm_id, 
icd_code,
CASE WHEN icd_code ILIKE 'I48%' OR icd_code ILIKE '427.31%' 
       THEN 1 ELSE 0 END AS atrial_fibrill,
CASE WHEN icd_code ILIKE 'E785%' OR icd_code ILIKE '2724%' 
       THEN 1 ELSE 0 END AS hyperlipidemia,
CASE WHEN icd_code ILIKE 'E08%' OR icd_code ILIKE 'E09%' OR icd_code ILIKE 'E10%'
       OR icd_code ILIKE 'E11%' OR icd_code ILIKE 'E12%' OR icd_code ILIKE 'E13%'
       OR icd_code ILIKE '250%' 
       THEN 1 ELSE 0 END AS diabetes,
CASE WHEN icd_code ILIKE 'I10%' OR icd_code ILIKE 'I15%' OR icd_code ILIKE 'I16%'
       OR icd_code ILIKE '401%' OR icd_code ILIKE '405%' THEN 1 ELSE 0 END AS hypertension,
CASE WHEN icd_code ILIKE 'I20%' OR icd_code ILIKE 'I21%' OR icd_code ILIKE 'I22%'
       OR icd_code ILIKE 'I23%' OR icd_code ILIKE 'I24%' OR icd_code ILIKE 'I25%'
       OR icd_code ILIKE '410%' OR icd_code ILIKE '411%' OR icd_code ILIKE '412%' 
       OR icd_code ILIKE '413%' OR icd_code ILIKE '414%' 
       THEN 1 ELSE 0 END AS cor_artery_d,
CASE WHEN icd_code ILIKE 'I702%' OR icd_code ILIKE 'I703%' OR icd_code ILIKE 'I704%'
       OR icd_code ILIKE 'I705%' OR icd_code ILIKE 'I706%' OR icd_code ILIKE 'I707%' 
       OR icd_code ILIKE 'I708%' OR icd_code ILIKE 'I709%' OR icd_code ILIKE 'I998%' 
       OR icd_code ILIKE 'I739%' 
       OR icd_code ILIKE '4402%' OR icd_code ILIKE '4438%' OR icd_code ILIKE '4439%' 
       OR icd_code ILIKE '4440%' OR icd_code ILIKE '44422%' OR icd_code ILIKE '44481%' 
       THEN 1 ELSE 0 END AS peri_vasc_d,
CASE WHEN icd_code ILIKE 'I652%' OR icd_code ILIKE '43310%' 
       THEN 1 ELSE 0 END AS carotid_art_stentosis,
CASE WHEN icd_code ILIKE 'Z87891%' OR icd_code ILIKE 'F17%' OR icd_code ILIKE 'Z720%' 
       OR icd_code ILIKE '3051%' 
       THEN 1 ELSE 0 END AS smoking,
CASE WHEN icd_code ILIKE 'Z87891%' OR icd_code ILIKE '4359%' OR icd_code ILIKE 'G459%' 
       THEN 1 ELSE 0 END AS trans_ischemic_atk  
FROM diagnoses_icd