** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_WHO2019.do
    //  project:				        ECHORN (P-ECS)
    //  analysts:				       	Christina Howitt
    // 	date last modified	            12-Oct-2020
    //  algorithm task			        implementing the WHO CVD risk score to ECHORN wave 1 data.

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_cvdrisk_WHO_wave1", replace

** HEADER -----------------------------------------------------
** REFERENCE
** WHO CVD Risk Chart Working Group, 2019. World Health Organization cardiovascular disease risk charts: revised models to estimate risk in 21 global regions. 
** Lancet Glob. Health 7, e1332–e1345. https://doi.org/10.1016/S2214-109X(19)30318-3

** WHO risk charts indicate 10-year risk of a fatal or non-fatal major cardiovascular event
** (myocardial infarction or stroke), according to age, sex, blood pressure, smoking
** status, total blood cholesterol and presence or absence of diabetes mellitus for 21 regions.
**
** There are two sets of charts. One set can be used in settings where blood cholesterol can
** be measured. The other set is for settings in which blood cholesterol cannot be measured (in which case, BMI is used).
** Both sets are available according to the 21 WHO epidemiological sub-regions.
** Each chart can only be used in countries of the specific WHO epidemiological sub-region

** Here we implement Risk Charts for the Caribbean, with and without cholesterol. 

** Note: the 2007 iteration of the WHO CVD risk charts categorised participants into 5 risk categories, but did not give a mean
** 10-yr risk score. The latest version added an estimate of mean 10 yr risk.


** --------------------------------------------
** PART 1. Prepare your Input Variables 
** --------------------------------------------

** (model set-up 1) SET YOUR DATASET 
use "`datapath'/version03/02-working/survey_wave1_weighted", clear 

** SEX (0=female, 1=male)
gen sex_m1_f0=.
replace sex_m1_f0 =0 if gender==2
replace sex_m1_f0 =1 if gender==1
sort sex_m1_f0
by sex_m1_f0: sum gender
label define sex_m1_f0 0 "women" 1 "men", modify
label values sex_m1_f0 sex_m1_f0

** WHO-defined age groups for risk score (5 year bands)
generate age5=.
replace age5=1 if partage<45
replace age5=2 if partage>=45 & partage<50
replace age5=3 if partage>=50 & partage<55
replace age5=4 if partage>=55 & partage<60
replace age5=5 if partage>=60 & partage<65
replace age5=6 if partage>=65 & partage<70
replace age5=7 if partage>=70 & partage<75
label define age5 1 "40-44" 2 "45-49" 3 "50-54" 4 "55-59" 5 "60-64" 6 "65-69" 7 "70-74"
label values age5 age5 
sort age5 
by age5: sum partage

** Cholesterol groups
** first convert mg/dl to mmol/l (conversion factor for total chol: https://www.ncbi.nlm.nih.gov/books/NBK83505/)
gen tchol=TOTAL_CHOLESTEROL/38.67
gen chol_mm=.
replace chol_mm=1 if tchol <4
replace chol_mm=2 if tchol >=4 & tchol <5
replace chol_mm=3 if tchol >=5 & tchol <6
replace chol_mm=4 if tchol >=6 & tchol <7
replace chol_mm=5 if tchol >=7 & tchol <.
label define chol_mm 1 "<4" 2 "4-4.9" 3 "5-5.9" 4 "6-6.9" 5 ">=7"
label values chol_mm chol_mm 
sort chol_mm
by chol_mm: sum tchol

** Current smoker (0=NO, 1=YES)
gen smoker_y1_n0=.
replace smoker_y1_n0=0 if HB26==0 | HB26==.z 
replace smoker_y1_n0=1 if HB26==1
label variable smoker_y1_n0 "current regular smoker"
label define smoker_y1_n0 0 "Non-smoker" 1 "Current regular smoker"
label values smoker_y1_n0 smoker_y1_n0
tab smoker_y1_n0 siteid, miss col 
bysort smoker_y1_n0: sum smoke

** Systolic Blood Pressure
gen sys = .
replace sys = 1 if bp_systolic<120
replace sys = 2 if bp_systolic>=120 & bp_systolic<140
replace sys = 3 if bp_systolic>=140 & bp_systolic<159
replace sys = 4 if bp_systolic>=160 & bp_systolic<180
replace sys = 5 if bp_systolic>=180 & bp_systolic<.
label define sys 1 "<120" 2 "120-139" 3 "140-159" 4 "160-179" 5 ">180"
label values sys sys 
sort sys
by sys: sum bp_systolic

** Diabetes re-calculation to also include undiagnosed diabetes 
** DIABETES - previously doctor diagnosed
gen diabstat=0
replace diabstat=1 if GH184C==3
replace diabstat=. if GH184C==.
replace diabstat=0 if GH185==2
** DIABETES based on fasting plasma glucose (note: based on ADA criteria, i.e. FPG of 126 mg/dl or higher)
gen diabfpg=0
replace diabfpg=1 if glucose >= 126 & glucose<.
replace diabfpg=. if glucose==.
codebook glucose if diabfpg==0
codebook glucose if diabfpg==1
codebook glucose if diabfpg==.
lab var diabfpg "Diabetes based on fasting glucose"
lab def _diab 0 "not diabetes" 1 "diabetes", modify
** Diabetes - reported diagnosis plus newly diagnosed on fplas
gen dm_y1_n0=diabstat
replace dm_y1_n0=1 if diabfpg==1
label define dm_y1_n0 0 "no" 1 "yes",modify
label values dm_y1_n0 dm_y1_n0
label var dm_y1_n0 "Diabetes (yes/no). Self-report and lab confirmed"
tab dm_y1_n0 sex_m1_f0, col 
*save temporary file for later use
tempfile who_risk_001
save `who_risk_001'


**************************************************************
** 002. 	KEEP MINIMAL DATASET REQUIRED FOR RISK SCORE (WHO WITH CHOLESTEROL)
**		    GENERATE 'RISK CELLS' INDICATOR (1 to 1400)
**************************************************************
** There are 1400 cells in the WHO risk chart, each one representing a unique grouping of the 5 variables
** sex(2)  x  dm(2)  x  smoker(2)  x  age(7)  x  sys(5)  x  chol(5)
** 2 x 2 x 2 x 7 x 5 x 5  =  1400 cells

** Restrict dataset to required variables
keep key sex_m1_f0 age5 chol_mm smoker_y1_n0 sys dm_y1_n0 siteid partage 
** Restrict dataset to those with complete information
*keep if sex_m1_f0<. & age5<. & chol_mm<. & smoker_y1_n0<. & sys<. & dm_y1_n0<.

** Generate rectangular matrix of values, running from 1 to 1400
fillin dm_y1_n0 sex_m1_f0 smoker_y1_n0 age5 sys chol_mm
** Generate indicator (1 to 1400) representing the 1400 individual cells in the WHO risk chart
egen cellnum = group(dm_y1_n0 sex_m1_f0 smoker_y1_n0 age5 sys chol_mm )
label var cellnum "WHO cells (1 to 1400)"
** Sort and order
sort cellnum chol_mm sys age5 smoker_y1_n0 sex_m1_f0 dm_y1_n0
order key cellnum chol_mm sys age5 smoker_y1_n0 sex_m1_f0 dm_y1_n0


**************************************************************
** 003. 	MERGE WITH EXCEL SHEET THAT CONTAINS RISK ESTIMATES 
**          FOR CARIBBEAN REGION WITH CHOLESTEROL (TRANSCRIBED FROM PDF TABLES)
**************************************************************
** Save out an uncollapsed temporary file
tempfile who_risk_002
save `who_risk_002'
** combine with WHO risk estimates 
import excel "`datapath'\version03\01-input\WHO_CVD_risk(v2).xlsx", sheet("Sheet2") firstrow clear
merge 1:m cellnum using "`who_risk_002'"
drop _merge
order chol_mm, after(smoke)
order sys, after(chol_mm)
order age5, after (sys)

**get rid of empty risk categories
drop if _fillin==1

** this is the final version of the ECHORN dataset with 10-yr CVD risk according to WHO risk tables (with cholesterol measured). 
** save for final merge with with WHO no lab estimates
tempfile who_risk_003
rename risk WHO_gen 
save `who_risk_003'

**************************************************************
** 004. 	KEEP MINIMAL DATASET REQUIRED FOR RISK SCORE (WHO WITH NO LABS)
**		    GENERATE 'RISK CELLS' INDICATOR (1 to 700)
**************************************************************
use `who_risk_001', clear 

**PREVIOUS DIAGNOSIS MI, stroke, angina
rename GH29D mi
rename GH32 stroke
rename GH29B angina
rename GH29A chd
rename GH29C a_rtm
rename GH29E hf

** prepare BMI variable
gen heightm = height/100
gen bmi = weight/(heightm*heightm)
gen bmi_cat = .
replace bmi_cat=1 if bmi <20
replace bmi_cat=2 if bmi >= 20 & bmi <25
replace bmi_cat=3 if bmi >= 25 & bmi <30
replace bmi_cat=4 if bmi >= 30 & bmi <35
replace bmi_cat=5 if bmi >= 35
label define bmi_cat 1 "<20" 2 "20-24" 3 "25-29" 4 "30-35" 5 ">35"
label values bmi_cat bmi_cat 

** There are 700 cells in the WHO no labs risk chart, each one representing a unique grouping of the 5 variables
** sex(2)  x  smoker(2)  x  age(7)  x  sys(5)  x  BMI(5)
** 2 * 2 * 7 * 5 * 5  =  700 cells

** Restrict dataset to required variables
keep sex_m1_f0 age5 smoker_y1_n0 bmi_cat sys siteid partage mi stroke angina chd a_rtm hf key 
** Restrict dataset to those with complete information
keep if sex_m1_f0<. & age5<. & smoker_y1_n0<. & sys<. & bmi_cat<.

** Generate rectangular matrix of values, running from 1 to 1400
fillin sex_m1_f0 smoker_y1_n0 age5 sys bmi_cat 
** Generate indicator (1 to 1400) representing the 1400 individual cells in the WHO risk chart
egen cellnum = group(sex_m1_f0 smoker_y1_n0 age5 sys bmi_cat )
label var cellnum "WHO no lab cells (1 to 700)"
** Sort and order
sort cellnum bmi_cat sys age5 smoker_y1_n0 sex_m1_f0 
order key cellnum bmi_cat sys age5 smoker_y1_n0 sex_m1_f0 


**************************************************************
** 005. 	MERGE WITH EXCEL SHEET THAT CONTAINS RISK ESTIMATES 
**          FOR CARIBBEAN REGION WITH NO LABS 
**************************************************************
** Save out an uncollapsed temporary file
tempfile who_risk_004
save `who_risk_004'
** combine with WHO no lab risk estimates 
import excel "`datapath'\version03\01-input\WHO_CVD_risk(no_lab).xlsx", sheet("Sheet2") firstrow clear
merge 1:m cellnum using "`who_risk_004'"
drop _merge
order bmi_cat, after(smoke)
order sys, after(bmi_cat)
order age5, after (sys)

** get rid of empty risk categories
drop if _fillin == 1

** this is the final version of the ECHORN dataset with 10-yr CVD risk according to WHO risk tables (with cholesterol measured). 
** save for final merge with with WHO no lab estimates
tempfile who_risk_005
rename risk WHO_nolab
save `who_risk_005'

**************************************************************
** 006. 	MERGE WITH DATASET THAT CONTAINS RISK ESTIMATES WITH LABS
**************************************************************

merge 1:1 key using "`who_risk_003'"

** tidy up dataset before final version saved
drop cellnum sex _fillin _merge
order key, before(smoke)
order WHO_nolab, after(key)
order WHO_gen, before(WHO_nolab)

** CVD risk categories (changing intermediate category cut-off from 7.5 to 10)
gen WHOgen_cat = . 
replace WHOgen_cat = 1 if WHO_gen<10
replace WHOgen_cat = 2 if WHO_gen>=10 & WHO_gen<20
replace WHOgen_cat = 3 if WHO_gen>=20 & WHO_gen<.
label variable WHOgen_cat "10 yr risk categories"
label define WHOgen_cat 1 "low" 2 "intermediate" 3 "high" 
label values WHOgen_cat WHOgen_cat 

** CVD risk categories (changing intermediate category cut-off from 7.5 to 10)
gen WHObmi_cat = . 
replace WHObmi_cat = 1 if WHO_nolab<10
replace WHObmi_cat = 2 if WHO_nolab>=10 & WHO_nolab<20
replace WHObmi_cat = 3 if WHO_nolab>=20 & WHO_nolab<.
label variable WHObmi_cat "10 yr risk categories"
label define WHObmi_cat 1 "low" 2 "intermediate" 3 "high" 
label values WHObmi_cat WHObmi_cat 

** Save dataset for future use
save "`datapath'\version03\02-working\wave1_who_cvdrisk", replace

** Save reduced dataset for further work  
keep key WHO_gen WHO_nolab WHOgen_cat WHObmi_cat
label data "ECHORN and WHO 10-year CVD risk score: Oct-2020" 
save "`datapath'/version03/02-working/who_reduced", replace