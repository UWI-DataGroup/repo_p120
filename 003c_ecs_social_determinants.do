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
use "`datapath'/version03/02-working/wave1_framingham_allcvdrisk_prepared", clear

*create dichotomous variable for high risk
gen highrisk = (frsimcat==3) if !missing(frsimcat)

**---------------------------------------------------------------------------------------------------------------------
** PART TWO
** REGRESSION: PROGRESS+ SOCIAL DETERMINANTS AND CVD RISK
**---------------------------------------------------------------------------------------------------------------------

** REGRESSIONS: UNIVARIATE, THEN WITH FRAMINGHAM COMPONENTS
** SOCIAL frsimcat
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

regress frsim10 partage sbp bmi i.smoke i.diab i.gender i.sbptreat hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion ///
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
regress frsimcat partage sbp bmi i.smoke i.diab i.gender i.sbptreat i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week
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

regress frsim10 partage i.gender // R-squared=0.4701; for every 1 yr increase in age, CVD risk increases by 1.05 percentage points (95%CI 1.00-1.10); CVD risk is 9.44 pp lower in women vs men (-10.4, -8.5)
regress frsim10 partage i.gender hood_score // R-squared=0.4725; neighborhood characteristics not assoc. with CVD risk
regress frsim10 partage i.gender i.percsafe  // R-squared=0.4703; neighborhood characteristics not assoc. with CVD risk
regress frsim10 partage i.gender i.race // R-squared=0.4713; compared with white people, CVD risk is on average 3.7 pp higher in East Indian people (1.2, 6.2) 
regress frsim10 partage i.gender i.occ // R-squared=0.4590; compared with professionals, CVD risk is on average 2.2 pp higher in non-professionals (0.80, 3.77)
regress frsim10 partage i.gender i.D10 // R-squared=0.4724; compared with non-transsexual or transgender people, CVD risk is on average 2.86 pp higher in gender non-conforming people (6.58, 19.76)
regress frsim10 partage i.gender i.religious // R-squared=0.4759. Religiousness not assoc with CVD risk
regress frsim10 partage i.gender i.spirit // R-squared=0.4737. Spirituality not assoc with CVD risk
regress frsim10 partage i.gender i.D16 // R-squared=0.4783. Compared with those who never attend religious ceremonies, CVD risk is on average 2.21 pp lower in people who attend more than once per week (-3.66, -0.78)
regress frsim10 partage i.gender i.educ // R-squared=0.4803. College degree: -4.57 (-5.84, -3.30), vs less than high school
regress frsim10 partage i.gender D7 // R-squared=0.4703. Self-rated income not assoc with CVD risk
regress frsim10 partage i.gender promis // R-squared=0.4735. Unit increase in social support scale: -0.82 change in CVD risk (-1.51, -0.13)
regress frsim10 partage i.gender emotion // R-squared=0.4701. Emotional support not assoc with CVD risk
regress frsim10 partage i.gender i.D12 // R-squared=0.4755. Relationship status not assoc with CVD risk
regress frsim10 partage i.gender i.SE25 // R-squared=0.4718. Experience of violence from partner not assoc with CVD risk
regress frsim10 partage i.gender i.SE26 // R-squared=0.4712. Experience of violence from someone other than partner not assoc with CVD risk
regress frsim10 partage i.gender i.D11 // R-squared=0.4794. Compared with heterosexuals, people who were not sure or questioning sexuality had an increased CVD of 5.16 pp on average (no difference for gay, lesbian or bisexual)

regress frsim10 partage i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 // R-squared=0.4892. The only variable whose association with CVD risk remains is education
regress frsim10 partage i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week