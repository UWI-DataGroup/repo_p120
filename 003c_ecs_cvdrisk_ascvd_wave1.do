** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_ascvd.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    // 	date last modified	            04-Feb-2020
    //  algorithm task			        implementing the ASCVD CVD risk score to ECHORN wave 1 data.

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
    log using "`logpath'\ecs_cvdrisk_ascvd_wave1", replace
** HEADER -----------------------------------------------------

** REFERENCE
** Lloyd-Jones DM, Braun LT, Ndumele CE, Smith SC Jr, Sperling LS, Virani SS, Blumenthal RS. 
** Use of risk assessment tools to guide decision-making in the primary prevention of atherosclerotic 
** cardiovascular disease: a special report from the American Heart Association and American College of 
** Cardiology; JACC Nov 2018, 25711; DOI:10.1016/j.jacc.2018.11.005
**
** BACKGROUND
** We use the Pooled Cohort Equations to estimate the 10-year primary risk of ASCVD 
** (atherosclerotic cardiovascular disease) among patients without pre-existing cardiovascular disease
** who are between 40 and 79 years of age (REF 1).
** Patients are considered to be at "elevated" risk if the Pooled Cohort Equations predicted risk is ≥ 7.5%. 
** In many ways, the Pooled Cohort Equations have been proposed to replace the Framingham Risk 10-year CVD calculation, 
** which was recommended for use in the NCEP ATP III guidelines for high blood cholesterol in adults.3
**
** Current guidelines for the treatment of cholesterol to reduce cardiovascular risk 
** recommend that the following four groups of patients will benefit from moderate- or high-intensity statin therapy:2
**
** 1. Individuals with clinical ASCVD
** 2. Individuals with primary elevations of LDL ≥ 190 mg/dL
** 3. Individuals 40 to 75 years of age with diabetes and an LDL 70 to 189 mg/dL without clinical ASCVD
** 4. Individuals without clinical ASCVD or diabetes who are 40 to 75 years of age with LDL 70 to 189 mg/dL and a 10-year ASCVD risk of 7.5% or higher
** As shown above, among patients who do not otherwise have a compelling indication for statin therapy, 
** the Pooled Cohort Equations can be used to estimate primary cardiovascular risk and potential benefit from statin therapy.
**
** WHAT IS ASCVD?
** ASCVD stands for atherosclerotic cardiovascular disease, defined as a nonfatal myocardial infarction 
** (heart attack), coronary heart disease death, or stroke. 
** The purpose of the Pooled Cohort Equations is to estimate the risk of ASCVD within a 10-year period 
** among patients who have never had one of these events in the past.
** 
** IMPACT OF RACE ON THE POOLED COHORT EQUATIONS
** The Pooled Cohort Equations were developed and validated among Caucasian and African American men and women 
** who did not have clinical ASCVD. There are inadequate data in other racial groups, such as Hispanics, Asians, 
** and American-Indian populations. Given the lack of data, current guidelines suggest to use the 
** "Caucasian" race to estimate 10-year ASCVD risk with the knowledge that further research is needed to stratify 
** these patients' risk. Compared to Caucasians, the risk of ASCVD is generally lower among Hispanic and Asian 
** populations and generally higher among American-Indian populations.
**
** (REF 1)
** 2013 ACC/AHA Guideline on the Assessment of Cardiovascular Risk. doi: 10.1161/​01.cir.0000437741.48606.98.



** --------------------------------------------
** PART 1. Prepare your Input Variables 
** --------------------------------------------

** (model set-up 1) SET YOUR DATASET 
local PATH ""`datapath'/version03/02-working/survey_wave1_weighted""
use `PATH', clear

gen ascvd_age = partage 

** (model set-up 2) SET THE SEX VARIABLE (male=0, female=1)
gen ascvd_sex = . 
replace ascvd_sex = 0 if gender==1
replace ascvd_sex = 1 if gender==2
label define _sex 1 "female" 0 "male",modify 
label values ascvd_sex _sex 
label var ascvd_sex "Participant sex (0=male, 1=female)"

** (model set-up 3) SET RACE / ETHNICITY VARIABLE
** This particular parametrization fits: 
**      African-American model if race = "black"
**      White-American model if race = any other race/ethnicity  
gen ascvd_race = .
replace ascvd_race = 1 if D4B==1
replace ascvd_race = 2 if D4B<1
label define _race 1 "AA" 2 "WH", modify
label values ascvd_race _race   

** Risk factor calculations - systolic blood pressure and diastolic blood presure
gen ascvd_sbp = bp_systolic
label variable ascvd_sbp "Average Systolic blood pressure"

** IN CONTRAST TO HOTN, ALL LAB MEASUREMENTS ARE GIVEN IN mg/dL, SO NO NEED TO CONVERT. 
*Renaming to match risk calculation do-file
rename TOTAL_CHOLESTEROL ascvd_tchol
rename hdl ascvd_hdl

** SBP treatment 
gen ascvd_sbptreat = .
replace ascvd_sbptreat = 0 if GH26!=1 | (GH26==1 & Hypertension!=1) 
replace ascvd_sbptreat = 1 if Hypertension==1
label define _sbptreat 0 "no" 1 "yes"


**Current tobacco smoking
gen ascvd_smoke=.
replace ascvd_smoke=0 if HB26==0 | HB26==.z 
replace ascvd_smoke=1 if HB26==1
label variable ascvd_smoke "current regular smoker"
label define ascvd_smoke 0 "Non-smoker" 1 "Current regular smoker"
label values ascvd_smoke ascvd_smoke

*diabetes: already coded as 0=no 1=yes; just rename
rename GH184 ascvd_diab

** Keep only what is needed
keep key ascvd_*

** --------------------------------------------
** PART 2. Setting your CVD model inputs 
** --------------------------------------------
tempvar risk risk10 optrisk female race age sbp chol hdl smoke diab trhtn 

** Model Terms

** Sex
gen `female' = ascvd_sex

** Race 
gen `race' = ascvd_race 

** Age (y)
gen `age' = ascvd_age

** Total Cholesterol (mg/dL)
gen `chol' = ascvd_tchol

** HDL-C (mg/dL)
gen `hdl' = ascvd_hdl

** Treated or untreated Systolic BP (mm Hg)
gen `sbp' = ascvd_sbp 

** Current Smoker (1=Yes, 0=No)
gen `smoke' = ascvd_smoke 

** Diabetes (1=Yes, 0=No)
gen `diab' = ascvd_diab

** SBP treatment (0=no, 1=yes) 
gen `trhtn' = ascvd_sbptreat 

** Keep Framingham variables only 
keep key ascvd_* `female' `race' `age' `sbp' `chol' `hdl' `smoke' `diab' `trhtn' 

** --------------------------------------------
** PART 3. Calculate Risk
** --------------------------------------------

gen `risk' = . 
#delimit ; 
** AA-FEMALE-SBP NOT TREATED;
replace `risk' =    ln(`age')*17.114 + ln(`sbp')*27.82 + ln(`chol')*0.940 + 
                    ln(`hdl')*-18.92 + 0.691 * `smoke' + 0.874 * `diab' +
                    ln(`age') * ln(`hdl') * 4.475 +
                    ln(`age') * ln(`sbp') * -6.087 if `race'==1 & `female' == 1 & `trhtn' == 0;

** AA-FEMALE-SBP TREATED;
replace `risk' =    ln(`age')*17.114 + ln(`sbp')*29.291 + ln(`chol')*0.940 + 
                    ln(`hdl')*-18.92 + 0.691 * `smoke' + 0.874 * `diab' +
                    ln(`age') * ln(`hdl') * 4.475 +
                    ln(`age') * ln(`sbp') * -6.432 if `race'==1 & `female' == 1 & `trhtn' == 1;

** AA-MALE-SBP NOT TREATED;
replace `risk' =    ln(`age')*2.469 + ln(`sbp')*1.809 + ln(`chol')*0.302 + 
                    ln(`hdl')*-0.307 + 0.549 * `smoke' + 0.645 * `diab' if `race'==1 & `female' == 0 & `trhtn' == 0;

** AA-MALE-SBP TREATED;
replace `risk' =    ln(`age')*2.469 + ln(`sbp')*1.916 + ln(`chol')*0.302 + 
                    ln(`hdl')*-0.307 + 0.549 * `smoke' + 0.645 * `diab' if `race'==1 & `female' == 0 & `trhtn' == 1;


** WH-FEMALE-SBP NOT TREATED;
replace `risk' =    ln(`age')*-29.799 + ln(`sbp')*1.957 + ln(`chol')*13.54 + 
                    ln(`hdl')*-13.578 + 7.574 * `smoke' + 0.661 * `diab' +
                    ln(`age') * ln(`age') * 4.884 +
                    ln(`age') * ln(`chol') * -3.114 +
                    ln(`age') * ln(`hdl') * 3.149 +
                    ln(`age') * `smoke' * -1.665 if `race'==2 & `female' == 1 & `trhtn' == 0;

** WH-FEMALE-SBP TREATED;
replace `risk' =    ln(`age')*-29.799 + ln(`sbp')*2.019 + ln(`chol')*13.54 + 
                    ln(`hdl')*-13.578 + 7.574 * `smoke' + 0.661 * `diab' +
                    ln(`age') * ln(`age') * 4.884 +
                    ln(`age') * ln(`chol') * -3.114 +
                    ln(`age') * ln(`hdl') * 3.149 +
                    ln(`age') * `smoke' * -1.665 if `race'==2 & `female' == 1 & `trhtn' == 1;

** WH-MALE-SBP NOT TREATED;
replace `risk' =    ln(`age')*12.344 + ln(`sbp')*1.764 + ln(`chol')*11.853 + 
                    ln(`hdl')*-7.990 + 7.837 * `smoke' + 0.658 * `diab' +
                    ln(`age') * ln(`chol') * -2.664 +
                    ln(`age') * ln(`hdl') * 1.769 +
                    ln(`age') * `smoke' * -1.795 if `race'==2 & `female' == 0 & `trhtn' == 0;

** WH-MALE-SBP TREATED;
replace `risk' =    ln(`age')*12.344 + ln(`sbp')*1.797 + ln(`chol')*11.853 + 
                    ln(`hdl')*-7.990 + 7.837 * `smoke' + 0.658 * `diab' +
                    ln(`age') * ln(`chol') * -2.664 +
                    ln(`age') * ln(`hdl') * 1.769 +
                    ln(`age') * `smoke' * -1.795 if `race'==2 & `female' == 0 & `trhtn' == 1;
#delimit cr 

** 10-year risk score
gen risk10 = .
replace risk10 = 1 - 0.8954 ^ exp(`risk' - 19.54) if `race'==1 & `female' == 0
replace risk10 = 1 - 0.9533 ^ exp(`risk' - 86.61) if `race'==1 & `female' == 1
replace risk10 = 1 - 0.9144 ^ exp(`risk' - 61.18) if `race'==2 & `female' == 0
replace risk10 = 1 - 0.9665 ^ exp(`risk' + 29.18) if `race'==2 & `female' == 1

label var risk10 "ASCVD: 10-year CVD risk"

** Optimal 10-year CVD risk score 
gen `optrisk' =.
#delimit ;
replace `optrisk' = ln(`age')*17.114 + ln(110)*27.82 + ln(170)*0.940 + 
                    ln(50)*-18.92 + 0.691 * 0 + 0.874 * 0 +
                    ln(`age') * ln(50) * 4.475 +
                    ln(`age') * ln(110) * -6.087 if `race'==1 & `female' == 1 ;

replace `optrisk' =    ln(`age')*2.469 + ln(110)*1.809 + ln(170)*0.302 + 
                    ln(50)*-0.307 + 0.549 * 0 + 0.645 * 0 if `race'==1 & `female' == 0 ;

replace `optrisk' =    ln(`age')*-29.799 + ln(110)*1.957 + ln(170)*13.54 + 
                    ln(50)*-13.578 + 7.574 * 0 + 0.661 * 0 +
                    ln(`age') * ln(`age') * 4.884 +
                    ln(`age') * ln(170) * -3.114 +
                    ln(`age') * ln(50) * 3.149 +
                    ln(`age') * 0 * -1.665 if `race'==2 & `female' == 1 ;

replace `optrisk' =    ln(`age')*12.344 + ln(110)*1.764 + ln(170)*11.853 + 
                    ln(50)*-7.990 + 7.837 * 0 + 0.658 * 0 +
                    ln(`age') * ln(170) * -2.664 +
                    ln(`age') * ln(50) * 1.769 +
                    ln(`age') * 0 * -1.795 if `race'==2 & `female' == 0 ;
#delimit cr 
** 10-year optimum risk score
gen optrisk10 = .
replace optrisk10 = 1 - 0.8954 ^ exp(`optrisk' - 19.54) if `race'==1 & `female' == 0
replace optrisk10 = 1 - 0.9533 ^ exp(`optrisk' - 86.61) if `race'==1 & `female' == 1
replace optrisk10 = 1 - 0.9144 ^ exp(`optrisk' - 61.18) if `race'==2 & `female' == 0
replace optrisk10 = 1 - 0.9665 ^ exp(`optrisk' + 29.18) if `race'==2 & `female' == 1

** Save the dataset for further work  
label data "Wave 1 ECHORN data and ASCVD 10-year CVD risk score: Nov-2019" 
save "`datapath'/version03/02-working/wave1_ascvd_cvdrisk", replace

/** Save reduced dataset for further work  (USED in ecs_analysis_hotn_004.DO)
keep pid risk10 optrisk10 
label data "HotN data and ASCVD 10-year CVD risk score: Nov-2019" 
save "`datapath'/version02/2-working/ascvd_cvdrisk_reduced", replace

