** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham_wave1.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON AND CHRISTINA HOWITT
    // 	date last modified	            04-FEB-2020
    //  algorithm task			        implementing the Framingham CVD risk score.

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
    log using "`logpath'\ecs_cvdrisk_framingham_wave1", replace

** ------------------------------------------------------------
** FRAMINGHAM CVD RISK SCORE 
** BACKGROUND
** ------------------------------------------------------------
** 
** CARDIOVASCULAR DISEASE
** (10-year risk)
** Based on D’Agostino, Vasan, Pencina, Wolf, Cobain, Massaro, Kannel. 
** ‘A General Cardiovascular Risk Profile for Use in Primary Care: The Framingham Heart Study’
**
** OUTCOME
** CVD - coronary death, myocardial infarction, coronary insufficiency, angina, 
** ischemic stroke, hemorrhagic stroke, transient ischemic attack, peripheral artery disease, heart failure
** 
** DURATION OF FOLLOW-UP
** Maximum of 12 years, 10-year risk prediction
** 
** POPULATION OF INTEREST
** Individuals 30 to 74 years old and without CVD at the baseline examination
** 
** PREDICTORS
** Age
** Diabetes
** Smoking
** Treated and untreated Systolic Blood Pressure
** Total cholesterol
** HDL cholesterol
** BMI replacing lipids in a simpler model
**
** CALCULATION DETAILS
** The score is continuous, stratified by sex (m/f) and whether lipid profile is available (n/y).
** With lipids, the choice of sex tweaks the implemented model, as follows:
**
** Women: 1 - 0.95012 ^ exp(sum(beta*x) - 26.1931)
**   Men: 1 - 0.88936 ^ exp(sum(beta*x) - 23.9802)
** 
** A simpler varient of the model is possible, if lipid profile does not exist
** which uses BMI instead
**
** Women: 1 - 0.94833 ^ exp(sum(beta*x) - 26.0145)
**   Men: 1 - 0.88431 ^ exp(sum(beta*x) - 23.9388)
**
** For all 4 models, the SBP beta coefficient changes depending 
** on whether the person is being treated for hypertension
** 
** COEFFICIENTS (W/LIPIDS)
** Men (10-year Baseline Survival: So(10) = 0.88936)
** Variable	                    Beta**	p-value	Hazard Ratio	95% CI
** Log of Age	                3.06117	<.0001	21.35	(14.03, 32.48)
** Log of Total Cholesterol	    1.12370	<.0001	3.08	(2.05, 4.62)
** Log of HDL Cholesterol	   -0.93263	<.0001	0.40	(0.30, 0.52)
** Log of SBP if not treated    1.93303	<.0001	6.91	(3.91, 12.20)
** Log of SBP if treated	    1.99881	<.0001	7.38	(4.22, 12.92)
** Smoking	                    0.65451	<.0001	1.92	(1.65, 2.24)
** Diabetes	                    0.57367	<.0001	1.78	(1.43, 2.20)
** 
** Women* (10-year Baseline Survival: So(10) = 0.95012)
** Variable	                       Beta**	p-value	Hazard Ratio	95% CI
** Log of Age	                    2.32888	<.0001	10.27	(5.65, 18.64)
** Log of Total Cholesterol	        1.20904	<.0001	3.35	(2.00, 5.62)
** Log of HDL Cholesterol	       -0.70833	<.0001	0.49	(0.351, 0.691)
** Log of SBP if not treated	    2.76157	<.0001	15.82	(7.86, 31.87)
** Log of SBP if treated	        2.82263	<.0001	16.82	(8.46, 33.46)
** Smoking	                        0.52873	<.0001	1.70	(1.40, 2.06)
** Diabetes	                        0.69154	<.0001	2.00	(1.49, 2.67)
** 
** COEFFICIENTS (NO LIPIDS)
** Men* (10-year Baseline Survival: So(10) = 0.88431)
** Variable	                    Beta**	p-value	Hazard Ratio	95% CI
** Log of Age	                3.11296	<.0001	22.49	(14.80, 34.16)
** Log of Body Mass Index	    0.79277	<.0066	2.21	(1.25, 3.91)
** Log of SBP if not treated	1.85508	<.0001	6.39	(3.61, 11.33)
** Log of SBP if treated	    1.92672	<.0001	6.87	(3.90, 12.08)
** Smoking	                    0.70953	<.0001	2.03	(1.75, 2.37)
** Diabetes	                    0.53160	<.0001	1.70	(1.37, 2.11)
** 
** Women* (10-year Baseline Survival: So(10) = 0.94833)
** Variable	                    Beta**	p-value	Hazard Ratio	95% CI
** Log of Age	                2.72107	<.0001	15.20	(8.59, 26.87)
** Log of Body Mass Index	    0.51125	<.0609	1.67	(0.98, 2.85)
** Log of SBP if not treated	2.81291	<.0001	16.66	(8.27, 33.54)
** Log of SBP if treated	    2.88267	<.0001	17.86	(8.97, 35.57)
** Smoking	                    0.61868	<.0001	1.86	(1.53, 2.25)
** Diabetes	                    0.77763	<.0001	2.18	(1.63, 2.91)
** ------------------------------------------------------------


** --------------------------------------------
** PART 1. Prepare your Input Variables 
** --------------------------------------------

** (model set-up 1) SET YOUR DATASET 
local PATH ""`datapath'/version03/02-working/survey_wave1_weighted""
use `PATH', clear

** VARIABLE preparation 
** SEX should be                    --> male=1, female=0
** All other categorical variables  -->  0=negative 1=positive

** Systolic blood pressure
gen sbp = bp_systolic
drop bp_systolic

** SBP treatment 
tab Hypertension  // coded as 1=yes; .=no
gen sbptreat = Hypertension
recode sbptreat .=0
tab sbptreat
label define _sbptreat 0 "no" 1 "yes"

** IN CONTRAST TO HOTN, ALL LAB MEASUREMENTS ARE GIVEN IN mg/dL, SO NO NEED TO CONVERT. 
*Renaming to match risk calculation do-file
rename TOTAL_CHOLESTEROL tchol_mg
rename hdl hdl_mg


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
gen diab=diabstat
replace diab=1 if diabfpg==1

**Current tobacco smoking
gen smoke=.
replace smoke=0 if HB26==0 | HB26==.z 
replace smoke=1 if HB26==1
label variable smoke "current regular smoker"
label define smoke 0 "Non-smoker" 1 "Current regular smoker"
label values smoke smoke
tab smoke siteid, miss col 

**BMI
*convert height in cm to height in m
gen heightm = height/100
drop height
rename heightm height
label variable height "height in m"
gen bmi=weight/(height*height)


** Keep only what is needed
keep key gender partage sbp sbptreat smoke diab hdl_mg tchol_mg bp_diastolic bmi

** --------------------------------------------
** PART 2. Setting your CVD model inputs 
** --------------------------------------------
tempvar risk bmirisk risk10 bmirisk10 optrisk female age sbp chol hdl smoke diab trhtn bmi 

** (model set-up 2) SET THE SEX VARIABLE (male=0, female=1)
gen fram_sex = . 
replace fram_sex = 0 if gender==1
replace fram_sex = 1 if gender==2
label define _sex 1 "female" 0 "male",modify 
label values fram_sex _sex 
label var fram_sex "Participant sex (0=male, 1=female)"
gen `female' = fram_sex

** (model set-up 3) SET THE AGE VARIABLE (in years)
gen fram_age = partage 
label var fram_age "Participant age (in years)" 
gen `age' = fram_age

** (model set-up 4) SET SYSTOLIC BLOOD PRESSURE (mmHg)
gen fram_sbp = sbp 
label var fram_sbp "Participant SBP (mmHg)" 
gen `sbp' = fram_sbp 

** (model set-up 5) SET TREATMENT FOR HYP W/ ANTIHYPERTENSIVE MEDICATION (no=0, yes=1)
gen fram_sbptreat = sbptreat 
label values fram_sbptreat _sbptreat
label var fram_sbptreat "Treated for SBP (no=0, yes=1)" 
gen `trhtn' = fram_sbptreat 

** (model set-up 6) SET SMOKING STATUS (smoker=1, non-smoker=0)
gen fram_smoke = smoke 
label define _smoke 0 "no" 1 "yes"
label values fram_smoke _smoke
label var fram_smoke "Smoker (no=0, yes=1)" 
gen `smoke' = fram_smoke 

** (model set-up 7) SET DIABETES STATUS (diabetic=1, non-diabetic=0)
gen fram_diab = . 
replace fram_diab = 0 if diab == 0
replace fram_diab = 1 if diab == 1
label values fram_diab _diab
label var fram_diab "Diabetic (no=0, yes=1)" 
gen `diab' = fram_diab 

** (model set-up 8) SET HIGH DENSITY LIPOPROTEIN LEVEL (HDL, mg/dL)
gen fram_hdl = hdl_mg 
label var fram_hdl "High density lipoprotein (mg/dL)" 
gen `hdl' = fram_hdl 

** (model set-up 9) SET CHOLESTEROL LEVEL (mg/dL)
gen fram_tchol = tchol_mg 
label var fram_tchol "Total cholesterol (mg/dL)" 
gen `chol' = fram_tchol 

** (model set-up 10) SET OPTIMAL RISK OUTPUT (yes / no)
gen optimal_sbp = 110
gen optimal_tchol = 160
gen optimal_hdl = 60
label var optimal_sbp "Optimal systolic blood pressure"
label var optimal_tchol "Optimal total cholesterol"
label var optimal_hdl "Optimal high density lipoprotein"

** (model set-up 11) SET THE BMI VARIABLE (in kg/m2)
gen fram_bmi = bmi  
label var fram_bmi "Participant BMI (in kg/m2)" 
gen `bmi' = fram_bmi

** Keep Framingham variables only 
keep key fram_* optimal_* `female' `age' `sbp' `smoke' `diab' `trhtn' `bmi' `chol' `hdl'

** --------------------------------------------
** PART 3. Calculate Risk
** --------------------------------------------

gen `risk' = .
** (Men   / No HTN Treatment) then (Men   / HTN treatment) then
** (Women / No HTN Treatment) then (Women / HTN treatment)
#delimit ; 
replace `risk' =    ln(`age') * 3.06117 + ln(`sbp') * 1.93303 + ln(`chol') * 1.1237 + 
                    ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367 if `female' == 0 & `trhtn' == 0;
replace `risk' =    ln(`age') * 3.06117 + ln(`sbp') * 1.99881 + ln(`chol') * 1.1237 + 
                    ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367 if `female' == 0 & `trhtn' == 1;
replace `risk' =    ln(`age') * 2.32888 + ln(`sbp') * 2.76157 + ln(`chol') * 1.20904 + 
                    ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154 if `female' == 1 & `trhtn' == 0;
replace `risk' =    ln(`age') * 2.32888 + ln(`sbp') * 2.82263 + ln(`chol') * 1.20904 + 
                    ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154 if `female' == 1 & `trhtn' == 1;
#delimit cr                    
** Final 10-year CVD risk score
gen risk10 = .
replace risk10 = 1 - 0.88936^exp(`risk'- 23.9802) if `female' == 0	
replace risk10 = 1 - 0.95012^exp(`risk'- 26.1931) if `female' == 1
label variable risk10 "10yr risk, lab"
** Optimal 10-year CVD risk score 
gen `optrisk' =.
replace `optrisk' = ln(`age') * 3.06117 + ln(110) * 1.93303 + ln(160) * 1.1237 + ln(60) * -0.93263 if `female' == 0 
replace `optrisk' = ln(`age') * 2.32888 + ln(110) * 2.76157 + ln(160) * 1.20904 + ln(60) * -0.70833 if `female' == 1 
gen optrisk10 =.
replace optrisk10 = 1 - 0.88936^exp(`optrisk'- 23.9802) if `female' == 0
replace optrisk10 = 1 - 0.95012^exp(`optrisk'- 26.1931) if `female' == 1


** Test against the Framingham adofile
tempvar male
gen `male' = `female' 
recode `male' 1=0 0=1 
framingham , male(`male') age(`age') sbp(`sbp') trhtn(`trhtn') smoke(`smoke') diab(`diab')    ///
                 hdl(`hdl') chol(`chol') optimal suffix(_ado)



** CVD risk categories
gen risk10_cat = . 
replace risk10_cat = 1 if risk10<0.1
replace risk10_cat = 2 if risk10>=0.1 & risk10<0.2
replace risk10_cat = 3 if risk10>=0.2 & risk10<.
label variable risk10_cat "10yr risk categories, lab"
label define _risk10_cat 1 "low" 2 "intermediate" 3 "high" 
label values risk10_cat _risk10_cat 


*****************************************************************************
* RISK BASED ON BMI (NO LIPIDS)
*****************************************************************************
gen `bmirisk' = .
** (Men   / No HTN Treatment) then (Men   / HTN treatment) then
** (Women / No HTN Treatment) then (Women / HTN treatment)
#delimit ; 
replace `bmirisk' =   ln(`age') * 3.11296 + ln(`sbp') * 1.85508 + ln(`bmi') * 0.79277 + 
                     `smoke' * 0.70953 + `diab' * 0.53160 if `female' == 0 & `trhtn' == 0;
replace `bmirisk' =    ln(`age') * 3.11296 + ln(`sbp') * 1.92672 + ln(`bmi') * 0.79277 + 
                     `smoke' * 0.70953 + `diab' * 0.53160 if `female' == 0 & `trhtn' == 1;
replace `bmirisk' =    ln(`age') * 2.72107 + ln(`sbp') * 2.81291 + ln(`bmi') * 0.51125 + 
                     `smoke' * 0.61868 + `diab' * 0.77763 if `female' == 1 & `trhtn' == 0;
replace `bmirisk' =   ln(`age') * 2.72107 + ln(`sbp') * 2.88267 + ln(`bmi') * 0.51125 + 
                      `smoke' * 0.61868 + `diab' * 0.77763 if `female' == 1 & `trhtn' == 1;
#delimit cr

** Final 10-year CVD risk score (no labs)
gen bmirisk10 = .
replace bmirisk10 = 1 - 0.88431^exp(`bmirisk'- 23.9388) if `female' == 0	
replace bmirisk10 = 1 - 0.94833^exp(`bmirisk'- 26.0145) if `female' == 1
label variable bmirisk10 "10yr risk, no lab"

** CVD risk categories
gen bmirisk10_cat = . 
replace bmirisk10_cat = 1 if bmirisk10<0.1
replace bmirisk10_cat = 2 if bmirisk10>=0.1 & bmirisk10<0.2
replace bmirisk10_cat = 3 if bmirisk10>=0.2 & bmirisk10<.
label variable bmirisk10_cat "10 yr risk categories, no lab"
label define bmirisk10_cat 1 "low" 2 "intermediate" 3 "high" 
label values bmirisk10_cat _risk10_cat 


** Save the dataset for further work 
drop *_ado _*
label data "Wave 1 ECHORN data and Framingham 10-year CVD risk score: May-2020" 
save "`datapath'/version03/02-working/wave1_framingham_cvdrisk", replace

