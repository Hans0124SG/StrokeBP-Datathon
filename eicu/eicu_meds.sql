drop table eicu_meds;
create table eicu_meds as (
with antihtx as (
	select patientunitstayid
	, max(norepinephrine) as norepinephrine
	, max(dopamine) as dopamine
	, max(dobutamine) as dobutamine
	, max(heparin) as heparin
	, max(epinephrine) as epinephrine
	, max(vasopressin) as vasopressin
	, max(phenylephrine) as phenylephrine
	from pivoted_med
	where chartoffset < 6*60
	group by patientunitstayid
)
select * from eicu_cohort 
left join antihtx using (patientunitstayid)
)