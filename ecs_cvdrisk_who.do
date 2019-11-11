** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_who.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            6-NOV-2019
    //  algorithm task			        WHO CVD risk score. Americas = Region B.

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
    log using "`logpath'\ecs_cvdrisk_who",  replace
** HEADER -----------------------------------------------------

*******************************************************************************
** BACKGROUND
*******************************************************************************
** WHO risk charts indicate 10-year risk of a fatal or non-fatal major cardiovascular event
** (myocardial infarction or stroke), according to age, sex, blood pressure, smoking
** status, total blood cholesterol and presence or absence of diabetes mellitus for 14 WHO
** epidemiological sub-regions.
**
** There are two sets of charts. One set can be used in settings where blood cholesterol can
** be measured. The other set is for settings in which blood cholesterol cannot be measured.
** Both sets are available according to the 14 WHO epidemiological sub-regions.
** Each chart can only be used in countries of the specific WHO epidemiological sub-region,
** e.g. The charts for South East Asia sub-region B (SEAR B) can only be used in Indonesia,
** Sri Lanka and Thailand.
**
** Different charts exist for Americas country groupings:
** AMR	A	Canada, Cuba, United States of America
** AMR	B	Antigua and Barbuda, Argentina, Bahamas, Barbados, Belize, Brazil, Chile, Colombia, Costa Rica, Dominica,
**			Dominican Republic, El Salvador, Grenada, Guyana, Honduras, Jamaica, Mexico, Panama, Paraguay,
**			Saint Kitts and Newis, Saint Lucia, Saint Vincent and the Grenadines, Suriname, Trinidad and Tobago,
**			Uruguay, Venezuela
** AMR	D	Bolivia, Ecuador, Guatemala, Haiti, Nicaragua, Peru
**
** Here we are mainly interested in Risk Charts for AMR-B, assuming the availability of cholesterol.
**
*******************************************************************************
** NOTE
*******************************************************************************
** This DO file was built to construct the WHO risk charts
** Once the various risk cells have been allocated, I think (to be confirmed) that the WHO
** risk score is categorical - groups of % risk - rather than an exact % score
** There are FIVE risk categories:
** 			category 1 -->  <10% ten-year risk
** 			category 2 -->  10 - <20% ten-year risk
** 			category 3 -->  20 - <30% ten-year risk
** 			category 4 -->  30 - <40% ten-year risk
** 			category 5 -->  >=40% ten-year risk
** For more details see: Collins (2016) - whoishRisk (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5345772/)
*******************************************************************************

** --------------------------------------------
** STEP 1. LOAD up and prepare the Reference Dataset
** --------------------------------------------
import excel "`datapath'\version02\1-input\Revised_Dataset_1_WHO_ISH_Scores.xlsx", sheet("Revised_Dataset_1_WHO_ISH_Score") firstrow clear

** Diabetes (0=not diabetic, 1=diabetic)
label define _dm 0 "not diabetic" 1 "diabetic",modify 
label values dm _dm 
label var dm "Diabetes (0=not diabetic, 1=diabetic)"

** Gender
recode gdr 1=0 0=1 
label define _gdr 1 "female" 0 "male",modify 
label values gdr _gdr 
label var gdr "Gender (1=female, 0=male)"

** Smoking (0=non-smoker, 1=smoker)
label define _smk 0 "non-smoker" 1 "smoker",modify 
label values smk _smk 
label var smk "Gender (0=non-smoker, 1=smoker)"

** Age (40, 50, 60, 70)
label define _age 40 "19-50" 50 "50-69" 60 "60-69" 70 "70-99",modify 
label values age _age 
label var age "Age in years in 4 categories (40, 50, 60, 70)"

** SBP (120, 140, 160, 180)
label define _sbp 120 "<140" 140 "140-159" 160 "160-179" 180 "180-250",modify 
label values sbp _sbp 
label var sbp "Systolic blood pressure in 4 categories (120, 140, 160, 180)"

** Total Cholesterol in mmol/L (4, 5, 6, 7, 8)
label define _chl 4 "<5 mmol/L" 5 "5 to <6 mmol/L" 6 "6 to <7 mmol/L" 7 "7 to <8 mmol/L" 8 "8+ mmol/L",modify 
label values chl _chl 
label var chl "Total cholesterol in 5 categories (4, 5, 6, 7, 8)"

** UNIQUE IDENTIFIER FOR GROUPING
** This in in the order: AGE-GDR-DM-SMK-SBP-CHL
label var refv "Unique Reference Value for WHO CVD risk"
format refv %15.0f

** Label the categories for all regions
label define _region 1 "<10%" 2 "10% to <20%" 3 "20% to <30%" 4 "30% to <40%" 5 ">=40%"
foreach var in AFR_D AFR_E AMR_A AMR_B AMR_D EMR_B EMR_D EUR_A EUR_B EUR_C SEAR_B SEAR_D WPR_B WPR_A {
    rename `var' t`var'
    gen `var' = .
    replace `var' = 1 if t`var'=="<10%"
    replace `var' = 2 if t`var'=="10% to <20%"
    replace `var' = 3 if t`var'=="20% to <30%"
    replace `var' = 4 if t`var'=="30% to <40%"
    replace `var' = 5 if t`var'==">=40%"
    label values `var' _region 
    drop t`var'
}

** Label the region CVD risk category variables
label var AFR_D "Africa region D"
label var AFR_E "Africa region E"
label var AMR_A "Americas region A"
label var AMR_B "Americas region B"
label var AMR_D "Americas region D"
label var EMR_B "Eastern Mediterranean region B"
label var EMR_D "Eastern Mediterranean region D"
label var EUR_A "European region D"
label var EUR_B "European region D"
label var EUR_C "European region D"
label var SEAR_B "South East Asian region B"
label var SEAR_D "South East Asian region D"
label var WPR_A "Western Pacific region A"
label var WPR_B "Western Pacific region B"

rename dm who_diab 
rename gdr who_sex 
rename smk who_smoke 
rename age who_age 
rename sbp who_sbp
rename chl who_tchol 

label data "WHO CVD risk: reference dataset" 
local PATH_OUT1 ""`datapath'/version02/2-working/who_cvdrisk_reference""
save `PATH_OUT1', replace


** --------------------------------------------
** STEP 2. Merge YOUR data with the reference data, to assign a risk score to each individual
** --------------------------------------------

** SET YOUR DATASET 
local PATH ""`datapath'/version01/1-input/hotn_v41RPAQ""
use `PATH', clear

** AGE
gen who_age = . 
replace who_age = 40 if agey<50 
replace who_age = 50 if agey>=50 & agey<60 
replace who_age = 60 if agey>=60 & agey<70
replace who_age = 70 if agey>=70
label values who_age _age 
label var who_age "Age in years in 4 categories (40, 50, 60, 70)"
rename agey cwho_age 

** SEX (male=0, female=1)
gen who_sex = sex 
replace who_sex = 0 if sex==2
replace who_sex = 1 if sex==1
label define _sex 1 "female" 0 "male",modify 
label values who_sex _sex 
label var who_sex "Participant sex (0=male, 1=female)"

** Systolic blood pressure 
gen cwho_sbp = ( sbp2 + sbp3 ) / 2 
gen who_sbp = .
replace who_sbp = 120 if cwho_sbp < 120 
replace who_sbp = 140 if cwho_sbp >=120 & cwho_sbp < 140
replace who_sbp = 160 if cwho_sbp >=140 & cwho_sbp < 160
replace who_sbp = 180 if cwho_sbp >=160 & cwho_sbp < .
label values who_sbp _sbp 
label var who_sbp "Systolic blood pressure in 4 categories (120, 140, 160, 180)"
label variable cwho_sbp "Average Systolic blood pressure"

** Convert TCHOL	 mmol/l --> mg/dL
** Reference for conversion. NIH --> https://www.ncbi.nlm.nih.gov/books/NBK83505/
gen cwho_tchol = tchol 
label var cwho_tchol "Total cholesterol (mg/dL)"
gen who_tchol = .
replace who_tchol = 4 if cwho_tchol < 4 
replace who_tchol = 5 if cwho_tchol >=4 & cwho_tchol < 5 
replace who_tchol = 6 if cwho_tchol >=5 & cwho_tchol < 6
replace who_tchol = 7 if cwho_tchol >=6 & cwho_tchol < 7 
replace who_tchol = 8 if cwho_tchol >=8 & cwho_tchol < .
replace who_tchol = 0 if cwho_tchol == .
label values who_tchol _chl 
label var who_tchol "Total cholesterol in 5 categories (4, 5, 6, 7, 8)"

** Recode diabetes and Smoking (0=no, 1=yes)
recode diab 2 = 0
gen who_diab = diab
label values who_diab _dm 
label var who_diab "Diabetes (0=not diabetic, 1=diabetic)"

recode smoke 2 = 0
gen who_smoke = smoke 
label values who_smoke _smk 
label var who_smoke "Gender (0=non-smoker, 1=smoker)"

** Keep only what is needed
keep pid ed who_* cwho_*
drop who_inactiverpaq

** CREATE HOTN UNIQUE IDENTIFIER FOR CVD RISK
** This in in the order: AGE-GDR-DM-SMK-SBP-CHL
gen str2 agestr = string(who_age)
gen str1 gdrstr = string(who_sex) 
gen str1 dmstr = string(who_diab)
gen str1 smkstr = string(who_smoke) 
gen str3 sbpstr = string(who_sbp) 
gen str1 chlstr = string(who_tchol) 
gen str12 refstr = agestr + gdrstr + dmstr + smkstr + sbpstr + chlstr
gen long refv = real(refstr)
format refv %15.0f
label var refv "Unique Reference Value for WHO CVD risk"

** MERGE HotN WITH WHO CVD RISK reference dataset 
keep if who_age<. & who_sex<. & who_diab<. & who_smoke<. & who_sbp<. & who_tchol<.
drop *str 
count
merge m:m refv using `PATH_OUT1'
drop AFR* EMR* EUR* SEAR* WPR* _merge 

** Save the dataset for further work 
label data "HotN data and WHO 10-year CVD risk score: Nov-2019" 
local PATH_OUT ""`datapath'/version02/2-working/who_cvdrisk""
save `PATH_OUT', replace

