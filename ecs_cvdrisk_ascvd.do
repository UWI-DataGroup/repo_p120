** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_ascvd.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        implamenting the ASCVD CVD risk score.

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
    log using "`logpath'\ecs_cvdrisk_ascvd", replace
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
local PATH ""`datapath'/version01/1-input/hotn_v41RPAQ""
use `PATH', clear

gen ascvd_age = agey 

** (model set-up 2) SET THE SEX VARIABLE (male=0, female=1)
gen ascvd_sex = sex 
replace ascvd_sex = 0 if sex==2
replace ascvd_sex = 1 if sex==1
label define _sex 1 "female" 0 "male",modify 
label values ascvd_sex _sex 
label var ascvd_sex "Participant sex (0=male, 1=female)"

** Risk factor calculations - systolic blood pressure and diastolic blood presure
gen ascvd_sbp = ( sbp2 + sbp3 ) / 2 
label variable ascvd_sbp "Average Systolic blood pressure"

** Convert TCHOL	 mmol/l --> mg/dL
** Reference for conversion. NIH --> https://www.ncbi.nlm.nih.gov/books/NBK83505/
gen ascvd_tchol = tchol * 38.67
label var ascvd_tchol "Total cholesterol (mg/dL)"

** Convert HDL	 mmol/l --> mg/dL
** Reference for conversion. NIH --> https://www.ncbi.nlm.nih.gov/books/NBK83505/
gen ascvd_hdl = hdl * 38.67
label var ascvd_hdl "HDL (mg/dL)"

** SBP treatment 
gen ascvd_sbptreat = .
replace ascvd_sbptreat = 0 if hyper==2 | (hyper==1 & hyperm==2) | (hyper==1 & hyperm==.z)
replace ascvd_sbptreat = 1 if hyperm==1
label define _sbptreat 0 "no" 1 "yes"

** Recode diabetes and Smoking (0=no, 1=yes)
recode diab 2 = 0
gen ascvd_diab = diab
recode smoke 2 = 0
gen ascvd_smoke = smoke 

** Keep only what is needed
keep pid ed ascvd_*

** --------------------------------------------
** PART 2. Setting your CVD model inputs 
** --------------------------------------------
tempvar risk risk10 optrisk female age sbp chol hdl smoke diab trhtn 

** Model Terms

** Sex
gen `female' = ascvd_sex

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
keep pid ed `female' `age' `sbp' `chol' `hdl' `smoke' `diab' `trhtn' 

** --------------------------------------------
** PART 3. Calculate Risk
** --------------------------------------------

gen `risk' = . 
#delimit ; 
replace `risk' =    ln(`age')*17.114 + ln(`sbp')*27.82 + ln(`chol')*0.940 + 
                    ln(`hdl')*-18.92 + 0.691 * `smoke' + 0.874 * `diab' +
                    ln(`age') * ln(`hdl') * 4.475 +
                    ln(`age') * ln(`sbp') * -6.087 if `female' == 1 & `trhtn' == 0;

replace `risk' =    ln(`age')*17.114 + ln(`sbp')*29.291 + ln(`chol')*0.940 + 
                    ln(`hdl')*-18.92 + 0.691 * `smoke' + 0.874 * `diab' +
                    ln(`age') * ln(`hdl') * 4.475 +
                    ln(`age') * ln(`sbp') * -6.432 if `female' == 1 & `trhtn' == 1;



