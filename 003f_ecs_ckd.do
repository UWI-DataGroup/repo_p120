cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		003f_ecs_ckd.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Chronic Kidney Disease
	**  Analyst:		Kern Rocke
	**	Date Created:	03/05/2021
	**	Date Modified:  04/05/2021
	**  Algorithm Task: Creating CKD variables for analysis

    ** General algorithm set-up
    version 13
    clear all
    macro drop _all
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)

*-------------------------------------------------------------------------------
** Dataset to encrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local datapath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

** Logfiles to unencrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local logpath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local logpath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local logpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

**Aggregated output path

*WINDOWS OS - Ian & Christina (Data Group) 
*local outputpath "The University of the West Indies/DataGroup - PROJECT_p120"

*WINDOWS OS - Kern & Stephanie
*local outputpath "X:/The UWI - Cave Hill Campus/DataGroup - PROJECT_p120"

*MAC OS - Kern
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"	
	
*-------------------------------------------------------------------------------

**Do file path
local dopath "/Volumes/Secomba/kernrocke/Boxcryptor/OneDrive - The UWI - Cave Hill Campus/Github Repositories/repo_p120"


*Open log file to store results
*log using "`logpath'/version03/3-output/ecs_ckd.log",  replace

*-------------------------------------------------------------------------------

*Load in data from encrypted location
use "`datapath'/version03/02-working/survey_wave1_weighted.dta", clear
	
*-------------------------------------------------------------------------------

*Merge in CKD variables

merge 1:1 key using "`datapath'/version03/01-input/cdrc_ckd.dta", nogenerate

*-------------------------------------------------------------------------------

*Remove participants with missing creatinine information
keep if creatinine != .


*Create eGFR using CKD-EPI equation
gen egfr = . 
replace egfr = 163*(creatinine /0.9)^-1.209*(0.993)^partage if gender==1 & creatinine >0.9 & creatinine !=.
replace egfr = 163*(creatinine /0.9)^-0.411*(0.993)^partage if gender==1 & creatinine <=0.9 & creatinine !=.
replace egfr = 166*(creatinine /0.7)^-1.209*(0.993)^partage if gender==2 & creatinine >0.7 & creatinine !=.
replace egfr = 166*(creatinine /0.7)^-0.329*(0.993)^partage if gender==2 & creatinine <=0.7 & creatinine !=.
label var egfr"Estimated Glomerular Filtration Rate"

mean egfr, over(siteid)


**MDRD
gen gfr_MDRD=.
replace gfr_MDRD = 175*(creatinine^-1.154)*partage^-0.203 * 1.210 * 0.742 if gender==2 & creatinine !=.
replace gfr_MDRD = 175*(creatinine^-1.154)*partage^-0.203 * 1.210  if gender==1 & creatinine !=.
label var gfr_MDRD "MDRD"

mean gfr_MDRD, over(siteid)


*Low renal function
gen low_renal = .
replace low_renal = 0 if egfr>=60 & egfr!=.
replace low_renal = 1 if egfr<60 & egfr!=.
label var low_renal "Low Renal Function"
label define low_renal 0"Normal" 1"Low Renal Function"
label value low_renal low_renal

tab low_renal siteid, col nofreq


*Microalbuminuria
gen micro = . 
replace micro = 0 if URINE_MICROALBUMIN <30
replace micro = 1 if URINE_MICROALBUMIN>= 30 & URINE_MICROALBUMIN!=.
label var micro "Microalbuminuria"
label define micro 0"Normal" 1"Microalbuminuria"
label value micro micro

*Chronic Kideny Disease
gen ckd =. 
replace ckd = 0 if low_renal == 0 
replace ckd = 1 if low_renal == 1 | micro == 1
label var ckd "Chronic Kidney Disease"
label define ckd 0"Normal" 1"CKD"
label value ckd ckd

proportion ckd, over(siteid) percent



*Create BMI groups
gen bmi = weight/((height/100)^2)
gen bmi_cat =.
replace bmi_cat = 1 if bmi>=18.5 & bmi<25.0
replace bmi_cat = 2 if bmi<18.5
replace bmi_cat = 3 if bmi>=25.0 & bmi<30.0
replace bmi_cat = 4 if bmi>30

label var bmi "BMI"
label var bmi_cat "BMI Categories"
label define bmi_cat 1"Normal" 2"Underweight" 3"Overweight" 4"Obese"
label value bmi_cat bmi_cat

oneway egfr bmi_cat, tab


*Merge in CVD Risk (US)
merge 1:1 key using "`datapath'/version03/02-working/ascvd_reduced.dta", nogenerate
drop if gender == .

*Regression Modelling - Multi-Level modelling will be used considering clustering by country

*Modelling the relationship between renal function/ckd and cardiovascular risk

*Unadjusted model
mixed egfr ascvd10 || siteid:, nolog
melogit ckd ascvd10 || siteid:, nolog

/*
Variable modelling

Variables will be added to an empty model using forward stepwise inclusion. 

A variable will be retained if the model showed an improved fit. This will be determined using AIC.


*/

*Merge in survey weights
gen svy_weight = . 
replace svy_weight= 1.456009 if siteid==1 & gender==1 & agegr==1
replace svy_weight= 0.9096148 if siteid==1 & gender==1 & agegr==2
replace svy_weight= 1.119752 if siteid==1 & gender==1 & agegr==3
replace svy_weight= 2.449452 if siteid==1 & gender==1 & agegr==4
replace svy_weight= 0.8209028 if siteid==1 & gender==2 & agegr==1
replace svy_weight= 0.7190354 if siteid==1 & gender==2 & agegr==2
replace svy_weight= 0.765116 if siteid==1 & gender==2 & agegr==3
replace svy_weight= 1.538876 if siteid==1 & gender==2 & agegr==4
replace svy_weight= 1.607113 if siteid==2 & gender==1 & agegr==1
replace svy_weight= 1.042527 if siteid==2 & gender==1 & agegr==2
replace svy_weight= 1.28236 if siteid==2 & gender==1 & agegr==3
replace svy_weight= 2.143544 if siteid==2 & gender==1 & agegr==4
replace svy_weight= 0.9409702 if siteid==2 & gender==2 & agegr==1
replace svy_weight= 0.5628699 if siteid==2 & gender==2 & agegr==2
replace svy_weight= 0.6957114 if siteid==2 & gender==2 & agegr==3
replace svy_weight= 1.279323 if siteid==2 & gender==2 & agegr==4
replace svy_weight= 2.283163 if siteid==3 & gender==1 & agegr==1
replace svy_weight= 1.632297 if siteid==3 & gender==1 & agegr==2
replace svy_weight= 0.9816098 if siteid==3 & gender==1 & agegr==3
replace svy_weight= 1.143265 if siteid==3 & gender==1 & agegr==4
replace svy_weight= 0.8925712 if siteid==3 & gender==2 & agegr==1
replace svy_weight= 0.5911024 if siteid==3 & gender==2 & agegr==2
replace svy_weight= 0.574794 if siteid==3 & gender==2 & agegr==3
replace svy_weight= 0.9067865 if siteid==3 & gender==2 & agegr==4
replace svy_weight= 1.201528 if siteid==4 & gender==1 & agegr==1
replace svy_weight= 1.053307 if siteid==4 & gender==1 & agegr==2
replace svy_weight= 0.9813747 if siteid==4 & gender==1 & agegr==3
replace svy_weight= 1.015825 if siteid==4 & gender==1 & agegr==4
replace svy_weight= 0.7107543 if siteid==4 & gender==2 & agegr==1
replace svy_weight= 0.6845082 if siteid==4 & gender==2 & agegr==2
replace svy_weight= 0.5962248 if siteid==4 & gender==2 & agegr==3
replace svy_weight= 1.086771 if siteid==4 & gender==2 & agegr==4


*Survey weighted prevalence estimated
proportion ckd [pweight = svy_weight], over(siteid) percent

*-------------------------------------------------------------------------------

/*
Table 1- Country level sociodemographic and clinical characteristics
Demographics - Sex, age, education
Clinical - BP chol trig glucose HBA1C htn dia CVD risk

Table 2 - Renal Function Characteristics
Serum Creatinine, Urinary creatinine, Urinary albumin, eGFR, CKD classification, Microalbuminuria

Table 3- Logistic Regression of CKD and cardiovascular predictors
*/
*-------------------------------------------------------------------------------

