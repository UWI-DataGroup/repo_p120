** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        implamenting the Framingham CVD risk score.

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
    log using "`logpath'\ecs_analysis_hotn_001", replace
** HEADER -----------------------------------------------------

** Framingham General cardiovascular Risk Profile -- applied to HotN
local PATH ""`datapath'/version02/2-working/framingham_cvdrisk""
use `PATH', clear

** Load CORE HotN dataset
local PATH ""`datapath'/version01/1-input/hotn_v41RPAQ""
use `PATH', clear

** -------------------------------------------------------------------------------------------------------------------- 
** Full survey weighting 
** -------------------------------------------------------------------------------------------------------------------- 
svyset ed [pweight=wfinal1_ad], strata(region) 

* THREE AGE GROUPS
* AGE IN 3 BANDS (25-44, 45-64, 65+)
gen age_gr2 =.
replace age_gr2= 1 if agey >=25 & agey <45
replace age_gr2= 2 if agey >=45 & agey <65
replace age_gr2= 3 if agey >=65 & agey <.
label variable age_gr2 "Age in 3 bands"
label define age_gr2 1 "25 - <45 years" 2 "45 - <65 years" 3 "65 and over years"
label values age_gr2 age_gr2
order age_gr2, after(agey)

** SEX indicators
gen female = (sex==1) if !missing(sex)
gen male = (sex==2) if !missing(sex)

** AGE indicators
gen age25 = (age_gr2==1) if !missing(age_gr2)
gen age45 = (age_gr2==2) if !missing(age_gr2)
gen age65 = (age_gr2==3) if !missing(age_gr2)


** EDUCATION
gen primary_plus  = (educ==1|educ==2|educ==3|educ==5)
gen second_plus   = (educ==4|educ==6)
gen tertiary      = (educ==7|educ==8|educ==9)

** OCCUPATION
gen prof = (occg==1|occg==2)
gen semi_prof = (occg==3|occg==4|occg==5|occg==6|occg==7)
gen non_prof = (occg==8|occg==9)

* % with 1 or more heavy episodic drinking events in past 30 days
** Number of days in past 30 days when you had at least 5(men)/4(women) alcoholic drinks
replace alc_30d_limit = 0 if alc_30d==.z
gen binge=0
replace binge = 1 if alc_30d_limit>0 & alc_30d_limit<.
replace binge = . if alc_30d_limit>=. & alc_30d_limit<=.b
label variable binge "heavy episodic alcohol consumption"
label define binge 0 "no binge drinking" 1 "binge drinking"
label values binge binge

**servings of fruit consumed per week and then per day
gen fruitserv_wk = fruit* fruit_s
gen fruitserv_day = fruitserv_wk/7
**servings of veg consumed per week and then per day
gen vegserv_week = veg* veg_s
gen vegserv_day = vegserv_week/7
**combined daily servings of fruit and veg (change in this version for purpose of cluster: 0=adequate; 1=adequate)
egen servings = rowtotal (fruitserv_day vegserv_day)
gen fv5 = 1
replace fv5 =0 if servings >=5 & servings <.
replace fv5 =. if fruit==.b | fruit_s ==.b | veg==.b | veg_s==.b
drop fruitserv_wk fruitserv_day

** Physically inactive
** who_inactiverpaq

**BMI
gen ht = height/100
gen bmi = weight/(ht*ht)
label var ht "height in m"
label var bmi "Body mass index"
**overeight
gen ow = 0
replace ow = 1 if bmi >=25 & bmi <.
replace ow =. if height ==. | weight ==.
label variable ow "overweight"
label define ow 0 "no" 1 "yes"
label values ow ow
**obese
gen ob=0
replace ob = 1 if bmi >=30 & bmi <.
replace ob =. if height ==. | weight ==.
tab ob, miss
label define ob 0 "not obese" 1 "obese"
label variable ob "obesity"
label values ob ob
**obesity categories
gen ob4 = 0
replace ob4 = 1 if bmi>=25
replace ob4 = 2 if bmi>=30
replace ob4 = 3 if bmi>=35
replace ob4 = 4 if bmi>=40
replace ob4 = . if weight==. | height==.
label variable ob4 "obesity category"
label define ob4 0 "not obese" 1 "bmi: 25-<30" 2 "bmi: 30-<35" 3 "bmi:35-<40" 4 "bmi: >40"
label values ob4 ob4

#delimit ; 
keep pid ed parish region wfinal1_ad wps_b2010 agey age_gr2 age25 age45 age65 sex female male 
        binge fv5 bmi ow ob ob4 primary_plus second_plus tertiary prof semi_prof non_prof mi stroke angina; 
#delimit cr 

** Merge with framingham risk dataset 
merge 1:1 pid using "`datapath'/version02/2-working/framingham_cvdrisk"
rename risk10 fram_risk10 
rename optrisk10 fram_optrisk10 
drop _merge 

** Merge with ASCVD risk dataset 
merge 1:1 pid using "`datapath'/version02/2-working/ascvd_cvdrisk"
rename risk10 ascvd_risk10 
rename optrisk10 ascvd_optrisk10 
drop _merge

** Merge with WHO risk dataset 
merge 1:1 pid using "`datapath'/version02/2-working/who_cvdrisk_sample"

drop optimal_tchol optimal_hdl _merge
keep pid ed parish region wfinal1_ad wps_b2010 sex fram_sex female male agey fram_age age_gr2 age25 age45 age65 ///
         binge fv5 bmi ow ob ob4 fram_sbp fram_sbptreat fram_smoke fram_diab fram_tchol         ///
         primary_plus second_plus tertiary prof semi_prof non_prof                              ///
         fram_risk10 fram_optrisk10 ascvd_risk10 ascvd_optrisk10 AMR_*                          ///
         mi stroke angina

order pid ed parish region wfinal1_ad wps_b2010 sex fram_sex female male agey fram_age age_gr2 age25 age45 age65 ///
         binge fv5 bmi ow ob ob4 fram_sbp fram_sbptreat fram_smoke fram_diab fram_tchol         ///
         primary_plus second_plus tertiary prof semi_prof non_prof                              ///
         fram_risk10 fram_optrisk10 ascvd_risk10 ascvd_optrisk10 AMR_*                          ///
         mi stroke angina

label var female "Female (1=yes, 0=no)"
label var male "Male (1=yes, 0=no)"
label var age25 "Age (1 = 25-44, 0 otherwise)"
label var age45 "Age (1 = 45-64, 0 otherwise)"
label var age65 "Age (1 = 65+, 0 otherwise)"
label var fv5 "5 portions of fruit + veg / day"
label var fram_risk10 "10-year CVD risk: Framingham risk score"
label var fram_optrisk10 "Optimal 10-year CVD risk: Framingham risk score"
label var ascvd_risk10 "10-year CVD risk: ASCVD risk score"
label var ascvd_optrisk10 "Optimal 10-year CVD risk: ASCVD risk score"
label var AMR_A "10-year CVD risk: WHO risk score"

** Save the prepared HotN dataset
label data "HotN (version 4.1): Prepared dataset for CVD risk analysis"
save "`datapath'/version02/2-working/hotn_cvdrisk_prepared", replace
