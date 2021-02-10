** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			                implementing the Framingham CVD risk score.

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 120

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"
     ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120"
    **Graph outputs to encrypted folder
     local outputpath  "X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120"
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_social_determinants", replace

** HEADER -----------------------------------------------------

**---------------------------------------
** PART ONE
** TABLE OF CVD RISK SCORES BY STRATIFIERS
**---------------------------------------

* ----------------------
** STEP 1. Load Data
** Dataset prepared in 003d_ecs_analysis_wave1.do
** USE FRAMINGHAM RISK SCORE
* ----------------------
use "`datapath'/version03/02-working/risk_comparison", clear 

rename partage age 

**---------------------------------------------------------------------------------------------------------------------
** PART TWO
** REGRESSION: PROGRESS+ SOCIAL DETERMINANTS AND CVD RISK
**---------------------------------------------------------------------------------------------------------------------

*/* REGRESSIONS: UNIVARIATE, THEN WITH FRAMINGHAM COMPONENTS
regress frsim10 hood_score
        regress frsim10 hood_score i.siteid 
                regress frsim10 hood_score age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.percsafe
        regress frsim10 i.percsafe i.siteid // **
                regress frsim10 i.percsafe age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  

regress frsim10 i.race
        regress frsim10 i.race i.siteid
                regress frsim10 i.race age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
regress frsim10 i.occ
        regress frsim10 i.occ i.siteid
                regress frsim10 i.occ age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.D10
        regress frsim10 i.D10 i.siteid
                regress frsim10 i.D10 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  // compared with non-transsexual or transgender people, CVD risk is on average 5.4 pp (95%CI: 2.36, 8.5) higher in gender non-conforming people 



regress frsim10 i.religious
        regress frsim10 i.religious i.siteid
                regress frsim10 i.religious age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.spirit
        regress frsim10 i.spirit i.siteid
                regress frsim10 i.spirit age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  // compared with non-spiritual people, those who were slightly or moderately spiritual had on average a 1.5 (0.3, 2.7) and 1.2 (0.04, 2.3)pp higher CVD risk

regress frsim10 i.D16
        regress frsim10 i.D16 i.siteid
                regress frsim10 i.D16 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  //  Compared with those who never attend religious ceremonies, CVD risk is on average 0.1 pp lower in people who attend more than once per week (-3.66, -0.78)


regress frsim10 i.educ
        regress frsim10 i.educ i.siteid
                regress frsim10 i.educ age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  

regress frsim10 D7
        regress frsim10 D7 i.siteid
                regress frsim10 i.D7 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 promis
        regress frsim10 promis i.siteid
                regress frsim10 promis age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 emotion // **
        regress frsim10 emotion i.siteid // **
                regress frsim10 emotion age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.D12
        regress frsim10 i.D12 i.siteid
                regress frsim10 i.D12 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.SE25
        regress frsim10 i.SE25 i.siteid // **
                regress frsim10 i.SE25 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 i.SE26
        regress frsim10 i.SE26 i.siteid // **
                regress frsim10 i.SE26 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 foodsec
        regress frsim10 foodsec i.siteid // **
                regress frsim10 foodsec age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsim10 age sbp bmi i.smoke i.diab i.gender i.sbptreat hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion ///
i.D12 i.SE25 i.SE26 i.D11 foodsec i.siteid 
*semiprofessional occupation, very religious, slightly, moderately and very spritual

** LOGISTIC REGRESSIONS WITH HIGH CVD RISK AS OUTCOME
logistic highrisk hood_score
        logistic highrisk hood_score age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.percsafe
        logistic highrisk i.percsafe age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.race
        logistic highrisk i.race age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.occ
        logistic highrisk i.occ age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.D10
        logistic highrisk i.D10 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.religious
        logistic highrisk i.religious age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.spirit
        logistic highrisk i.spirit age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.D16
        logistic highrisk i.D16 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.educ
        logistic highrisk i.educ age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk D7
        logistic highrisk i.D7 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk promis
        logistic highrisk promis age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk emotion
       logistic highrisk emotion age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.D12
        logistic highrisk i.D12 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  
logistic highrisk i.SE25
        logistic highrisk i.SE25 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.SE26
        logistic highrisk i.SE26 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk i.D11
        logistic highrisk i.D11 age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 
logistic highrisk hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion



**BEHAVIOURS
regress frsimcat i.inactive 
        regress frsimcat i.inactive age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid  // *

regress frsimcat i.binge 
        regress frsimcat i.binge age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

regress frsimcat veges_and_fruit_per_week 
        regress frsimcat veges_and_fruit_per_week age sbp bmi i.smoke i.diab i.gender i.sbptreat i.siteid 

** BEHAVIOURS AND SOCIAL DETERMINANTS
regress frsimcat age sbp bmi i.smoke i.diab i.gender i.sbptreat i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week
*inactivity, single women, very spiritual, moderately spiritual, very religious



** SOCIAL DETERMINANTS AND DIABETES
logistic diab hood_score
        logistic diab hood_score age sbp bmi i.smoke i.gender i.sbptreat // *
logistic diab i.percsafe
        logistic diab i.percsafe age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.race
        logistic diab i.race age sbp bmi i.smoke i.gender i.sbptreat // *
logistic diab i.occ
        logistic diab i.occ age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.D10
        logistic diab i.D10 age sbp bmi i.smoke i.gender i.sbptreat 
logistic diab i.religious
        logistic diab i.religious age sbp bmi i.smoke i.gender i.sbptreat 
logistic diab i.spirit
        logistic diab i.spirit age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.D16
        logistic diab i.D16 age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.educ
        logistic diab i.educ age sbp bmi i.smoke i.gender i.sbptreat // *
logistic diab D7
        logistic diab i.D7 age sbp bmi i.smoke i.gender i.sbptreat
logistic diab promis
        logistic diab promis age sbp bmi i.smoke i.gender i.sbptreat
logistic diab emotion
       logistic diab emotion age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.D12
        logistic diab i.D12 age sbp bmi i.smoke i.gender i.sbptreat 
logistic diab i.SE25
        logistic diab i.SE25 age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.SE26
        logistic diab i.SE26 age sbp bmi i.smoke i.gender i.sbptreat
logistic diab i.D11
        logistic diab i.D11 age sbp bmi i.smoke i.gender i.sbptreat // *

logistic diab age sbp bmi i.smoke i.gender i.sbptreat hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week
* hood_score, east indian, college degree, 

logistic diab i.inactive 
        logistic diab i.inactive age sbp bmi i.smoke i.gender i.sbptreat

logistic diab i.binge 
        logistic diab i.binge age sbp bmi i.smoke i.gender i.sbptreat

logistic diab veges_and_fruit_per_week 
        logistic diab veges_and_fruit_per_week age sbp bmi i.smoke i.gender i.sbptreat

**Merge with waist and hip circumference dataset
merge 1:1 key using "`datapath'\version03\02-working\20200603_waisthip.dta"
drop _merge


** SOCIAL DETERMINANTS
regress waist_circum_mean hood_score 
        regress waist_circum_mean hood_score age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean i.percsafe
        regress waist_circum_mean i.percsafe age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean i.race
        regress waist_circum_mean i.race age sbp bmi i.smoke i.diab i.gender i.sbptreat  // black, east indian, mixed
regress waist_circum_mean i.occ
        regress waist_circum_mean i.occ age sbp bmi i.smoke i.diab i.gender i.sbptreat  //semiprofessional, non-professional
regress waist_circum_mean i.D10
        regress waist_circum_mean i.D10 age sbp bmi i.smoke i.diab i.gender i.sbptreat  
regress waist_circum_mean i.religious
        regress waist_circum_mean i.religious age sbp bmi i.smoke i.diab i.gender i.sbptreat  // very religious
regress waist_circum_mean i.spirit
        regress waist_circum_mean i.spirit age sbp bmi i.smoke i.diab i.gender i.sbptreat  
regress waist_circum_mean i.D16
        regress waist_circum_mean i.D16 age sbp bmi i.smoke i.diab i.gender i.sbptreat  // every month
regress waist_circum_mean i.educ
        regress waist_circum_mean i.educ age sbp bmi i.smoke i.diab i.gender i.sbptreat  // all categories
regress waist_circum_mean D7
        regress waist_circum_mean i.D7 age sbp bmi i.smoke i.diab i.gender i.sbptreat  
regress waist_circum_mean promis
        regress waist_circum_mean promis age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean emotion
        regress waist_circum_mean emotion age sbp bmi i.smoke i.diab i.gender i.sbptreat // yes but really small effect
regress waist_circum_mean i.D12
        regress waist_circum_mean i.D12 age sbp bmi i.smoke i.diab i.gender i.sbptreat  // divorced or separated
regress waist_circum_mean i.SE25
        regress waist_circum_mean i.SE25 age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean i.SE26
        regress waist_circum_mean i.SE26 age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean veges_and_fruit_per_week 
        regress waist_circum_mean veges_and_fruit_per_week age sbp bmi i.smoke i.diab i.gender i.sbptreat 
regress waist_circum_mean foodsec
        regress waist_circum_mean foodsec age sbp bmi i.smoke i.diab i.gender i.sbptreat 
*/

**Social determinants of CVD risk with different scores
*framingham simplified
regress frsim10 hood_score age gender
regress frsim10 i.percsafe age gender
regress frsim10 i.race age gender 
regress frsim10 i.occ age gender
        tab D10
        codebook D10
                gen trans=.
                replace trans=0 if D10==0
                replace trans=1 if D10==2 | D10==3
regress frsim10 i.trans age gender
tab religious
regress frsim10 i.religious age gender
regress frsim10 i.spirit age gender
tab D16
codebook D16
regress frsim10 D16 age gender
                gen relfreq=.
                replace relfreq=1 if D16==1 | D16==2
                replace relfreq=2 if D16==3 | D16==4
                replace relfreq=3 if D16==5 | D16==6
regress frsim10 i.relfreq age gender
regress frsim10 i.educ age gender
tab D7
regress frsim10 D7 age gender
regress frsim10 promis age gender
regress frsim10 emotion age gender
regress frsim10 i.D12 age gender
codebook D12
                gen relstat=.
                replace relstat=1 if D12==1 | D12==2
                replace relstat=2 if D12==3
                replace relstat=3 if D12==4
                replace relstat=4 if D12==5 | D12==6
                replace relstat=5 if D12==7 | relstat==8
                replace relstat=6 if D12==9
regress frsim10 i.relstat age gender 
tab SE25
regress frsim10 i.SE25 age gender
regress frsim10 i.SE26 age gender
regress frsim10 i.D11 age gender

regress frsim10 age i.gender hood_score i.race i.occ i.trans i.religious i.relfreq i.educ D7 promis emotion i.relstat i.SE25 i.SE26 i.D11  

*framingham general 
regress frrisk10 age gender
regress frrisk10 hood_score age gender
regress frrisk10 i.percsafe age gender
regress frrisk10 i.race age gender 
regress frrisk10 i.occ age gender
regress frrisk10 i.trans age gender
regress frrisk10 i.religious age gender
regress frrisk10 i.spirit age gender
regress frrisk10 i.relfreq age gender
regress frrisk10 i.educ age gender
regress frrisk10 D7 age gender
regress frrisk10 promis age gender
regress frrisk10 emotion age gender
regress frrisk10 i.relstat age gender 
regress frrisk10 i.SE25 age gender
regress frrisk10 i.SE26 age gender
regress frrisk10 i.D11 age gender

regress frrisk10 age i.gender hood_score i.race i.occ i.trans i.religious i.relfreq i.educ D7 promis emotion i.relstat i.SE25 i.SE26 i.D11



*AHA/ASCVD 
regress ascvd10 age gender
regress ascvd10 hood_score age gender
regress ascvd10 i.percsafe age gender
regress ascvd10 i.race age gender 
regress ascvd10 i.occ age gender
regress ascvd10 i.trans age gender
regress ascvd10 i.religious age gender
regress ascvd10 i.spirit age gender
regress ascvd10 i.relfreq age gender
regress ascvd10 i.educ age gender
regress ascvd10 D7 age gender
regress ascvd10 promis age gender
regress ascvd10 emotion age gender
regress ascvd10 i.relstat age gender 
regress ascvd10 i.SE25 age gender
regress ascvd10 i.SE26 age gender
regress ascvd10 i.D11 age gender
regress ascvd10 age i.gender hood_score i.race i.occ i.trans i.religious i.relfreq i.educ D7 promis emotion i.relstat i.SE25 i.SE26 i.D11



*WHO general 
regress WHO_gen age gender
regress WHO_gen hood_score age gender
regress WHO_gen i.percsafe age gender
regress WHO_gen i.race age gender 
regress WHO_gen i.occ age gender
regress WHO_gen i.trans age gender
regress WHO_gen i.religious age gender
regress WHO_gen i.spirit age gender
regress WHO_gen i.relfreq age gender
regress WHO_gen i.educ age gender
regress WHO_gen D7 age gender
regress WHO_gen promis age gender
regress WHO_gen emotion age gender
regress WHO_gen i.relstat age gender 
regress WHO_gen i.SE25 age gender
regress WHO_gen i.SE26 age gender
regress WHO_gen i.D11 age gender
regress WHO_gen age i.gender hood_score i.race i.occ i.trans i.religious i.relfreq i.educ D7 promis emotion i.relstat i.SE25 i.SE26 i.D11


*WHO simplified 
regress WHO_nolab age gender
regress WHO_nolab hood_score age gender
regress WHO_nolab i.percsafe age gender
regress WHO_nolab i.race age gender 
regress WHO_nolab i.occ age gender
regress WHO_nolab i.trans age gender
regress WHO_nolab i.religious age gender
regress WHO_nolab i.spirit age gender
regress WHO_nolab i.relfreq age gender
regress WHO_nolab i.educ age gender
regress WHO_nolab D7 age gender
regress WHO_nolab promis age gender
regress WHO_nolab emotion age gender
regress WHO_nolab i.relstat age gender 
regress WHO_nolab i.SE25 age gender
regress WHO_nolab i.SE26 age gender
regress WHO_nolab i.D11 age gender
regress WHO_nolab age i.gender hood_score i.race i.occ i.trans i.religious i.relfreq i.educ D7 promis emotion i.relstat i.SE25 i.SE26 i.D11

/*

** High risk characteristics
*fram gen
logistic frcat_high age gender hood_score race occ trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11 foodsec
estat gof
logistic frcat_high age gender hood_score race trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11
estat gof
logistic frcat_high age gender race trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11
estat gof
logistic frcat_high age gender race trans religious relfreq educ promis emotion relstat SE25 SE26 D11
logistic frcat_high age gender race religious relfreq educ promis emotion relstat SE25 SE26 D11
logistic frcat_high age gender race relfreq educ promis emotion relstat SE25 SE26 D11
logistic frcat_high age gender race relfreq educ promis emotion relstat SE25 D11
logistic frcat_high age gender race relfreq educ emotion relstat SE25 D11

logistic frcat_high age gender race relfreq educ relstat SE25 D11

logistic frcat_high age gender race relfreq educ relstat D11

logistic frcat_high age gender relfreq educ relstat D11

logistic frcat_high age gender relfreq relstat D11

logistic frcat_high age gender relstat D11



*fram sim

logistic frsimcat_high age gender hood_score race occ trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11

logistic frsimcat_high age gender hood_score race occ trans religious relfreq educ promis emotion relstat SE25 SE26 D11

logistic frsimcat_high age gender hood_score race occ trans religious relfreq educ promis emotion SE25 SE26 D11

logistic frsimcat_high age gender hood_score race trans religious relfreq educ promis emotion SE25 SE26 D11

logistic frsimcat_high age gender hood_score race religious relfreq educ D11

logistic frsimcat_high age gender relfreq educ D11

logistic frsimcat_high age gender educ D11

logistic frsimcat_high age gender D11

logistic frsimcat_high age gender

**ASCVD
logistic ascvd_cat_high age gender hood_score race occ trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11

logistic ascvd_cat_high age gender hood_score race occ trans relfreq educ D7 promis emotion relstat SE25 SE26 D11

logistic ascvd_cat_high age gender race occ trans relfreq educ D7 promis emotion relstat SE25 SE26 D11

logistic ascvd_cat_high age gender race occ relfreq educ D7 promis emotion relstat SE25 SE26 D11



logistic ascvd_cat_high age gender race occ trans relfreq educ promis emotion relstat SE25 SE26 D11


**WHO gen
logistic WHOgen_cat_high age gender hood_score race occ trans religious relfreq educ D7 promis emotion relstat SE25 SE26 D11
