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
    log using "`logpath'\ecs_analysis_wave1_003", replace

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
use "`datapath'/version03/02-working/wave1_framingham_cvdrisk", clear

**---------------------------------------------------------------------------------------------------------------------
** PART TWO
** REGRESSION: PROGRESS+ SOCIAL DETERMINANTS AND CVD RISK
**---------------------------------------------------------------------------------------------------------------------

** REGRESSIONS: UNIVARIATE, THEN WITH FRAMINGHAM COMPONENTS
** SOCIAL DETERMINANTS
regress nolabrisk10 hood_score
        regress nolabrisk10 hood_score i.siteid 
                regress nolabrisk10 hood_score fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid 

regress nolabrisk10 i.percsafe
        regress nolabrisk10 i.percsafe i.siteid // **
                regress nolabrisk10 i.percsafe fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid 

regress nolabrisk10 i.race
        regress nolabrisk10 i.race i.siteid
                regress nolabrisk10 i.race fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid 

regress nolabrisk10 i.occ
        regress nolabrisk10 i.occ i.siteid
                regress nolabrisk10 i.occ fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid 

regress nolabrisk10 i.D10
        regress nolabrisk10 i.D10 i.siteid
                regress nolabrisk10 i.D10 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid // compared with non-transsexual or transgender people, CVD risk is on average 5.4 pp (95%CI: 2.36, 8.5) higher in gender non-conforming people 

regress nolabrisk10 i.religious
        regress nolabrisk10 i.religious i.siteid
                regress nolabrisk10 i.religious fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 i.spirit
        regress nolabrisk10 i.spirit i.siteid
                regress nolabrisk10 i.spirit fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid // compared with non-spiritual people, those who were slightly or moderately spiritual had on average a 1.5 (0.3, 2.7) and 1.2 (0.04, 2.3)pp higher CVD risk

regress nolabrisk10 i.D16
        regress nolabrisk10 i.D16 i.siteid
                regress nolabrisk10 i.D16 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid //  Compared with those who never attend religious ceremonies, CVD risk is on average 0.1 pp lower in people who attend more than once per week (-3.66, -0.78)

regress nolabrisk10 i.educ
        regress nolabrisk10 i.educ i.siteid
                regress nolabrisk10 i.educ fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid 

regress nolabrisk10 D7
        regress nolabrisk10 D7 i.siteid
                regress nolabrisk10 i.D7 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 promis
        regress nolabrisk10 promis i.siteid
                regress nolabrisk10 promis fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 emotion
        regress nolabrisk10 emotion i.siteid // **
                regress nolabrisk10 emotion fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 i.D12
        regress nolabrisk10 i.D12 i.siteid
                regress nolabrisk10 i.D12 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 i.SE25
        regress nolabrisk10 i.SE25 i.siteid // **
                regress nolabrisk10 i.SE25 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 i.SE26
        regress nolabrisk10 i.SE26 i.siteid // **
                regress nolabrisk10 i.SE26 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 foodsec
        regress nolabrisk10 foodsec i.siteid // **
                regress nolabrisk10 foodsec fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.siteid

regress nolabrisk10 partage fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion ///
i.D12 i.SE25 i.SE26 i.D11 foodsec i.siteid 
*semiprofessional occupation, very religious, slightly, moderately and very spritual

**BEHAVIOURS
regress nolabrisk10 i.inactive 
        regress nolabrisk10 i.inactive fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat  // *

regress nolabrisk10 i.binge 
        regress nolabrisk10 i.binge fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat

regress nolabrisk10 veges_and_fruit_per_week 
        regress nolabrisk10 veges_and_fruit_per_week fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat


** BEHAVIOURS AND SOCIAL DETERMINANTS
regress nolabrisk10 partage fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week
*inactivity, single women, very spiritual, moderately spiritual, very religious



** SOCIAL DETERMINANTS AND DIABETES
logistic fram_diab hood_score
        logistic fram_diab hood_score fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat // *
logistic fram_diab i.percsafe
        logistic fram_diab i.percsafe fram_age fram_sbp bmi i.fram_smoke  i.gender i.fram_sbptreat
logistic fram_diab i.race
        logistic fram_diab i.race fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat // *
logistic fram_diab i.occ
        logistic fram_diab i.occ fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab i.D10
        logistic fram_diab i.D10 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat  
logistic fram_diab i.religious
        logistic fram_diab i.religious fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat 
logistic fram_diab i.spirit
        logistic fram_diab i.spirit fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat 
logistic fram_diab i.D16
        logistic fram_diab i.D16 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat 
logistic fram_diab i.educ
        logistic fram_diab i.educ fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat // *
logistic fram_diab D7
        logistic fram_diab i.D7 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab promis
        logistic fram_diab promis fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab emotion
       logistic fram_diab emotion fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab i.D12
        logistic fram_diab i.D12 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat 
logistic fram_diab i.SE25
        logistic fram_diab i.SE25 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab i.SE26
        logistic fram_diab i.SE26 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat
logistic fram_diab i.D11
        logistic fram_diab i.D11 fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat // *

logistic fram_diab partage fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week
* hood_score, east indian, college degree, 

logistic fram_diab i.inactive 
        logistic fram_diab i.inactive fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat

logistic fram_diab i.binge 
        logistic fram_diab i.binge fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat

logistic fram_diab veges_and_fruit_per_week 
        logistic fram_diab veges_and_fruit_per_week fram_age fram_sbp bmi i.fram_smoke i.gender i.fram_sbptreat

**Merge with waist and hip circumference dataset
merge 1:1 key using "`datapath'\version03\02-working\20200603_waisthip.dta"
drop _merge


** SOCIAL DETERMINANTS
regress waist_circum_mean hood_score 
        regress waist_circum_mean hood_score fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat 
regress waist_circum_mean i.percsafe
        regress waist_circum_mean i.percsafe fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat
regress waist_circum_mean i.race
        regress waist_circum_mean i.race fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // black, east indian, mixed
regress waist_circum_mean i.occ
        regress waist_circum_mean i.occ fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat //semiprofessional, non-professional
regress waist_circum_mean i.D10
        regress waist_circum_mean i.D10 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat 
regress waist_circum_mean i.religious
        regress waist_circum_mean i.religious fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // very religious
regress waist_circum_mean i.spirit
        regress waist_circum_mean i.spirit fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat 
regress waist_circum_mean i.D16
        regress waist_circum_mean i.D16 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // every month
regress waist_circum_mean i.educ
        regress waist_circum_mean i.educ fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // all categories
regress waist_circum_mean D7
        regress waist_circum_mean i.D7 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat 
regress waist_circum_mean promis
        regress waist_circum_mean promis fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat
regress waist_circum_mean emotion
        regress waist_circum_mean emotion fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // yes but really small effect
regress waist_circum_mean i.D12
        regress waist_circum_mean i.D12 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat // divorced or separated
regress waist_circum_mean i.SE25
        regress waist_circum_mean i.SE25 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat
regress waist_circum_mean i.SE26
        regress waist_circum_mean i.SE26 fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat
regress waist_circum_mean veges_and_fruit_per_week 
        regress waist_circum_mean veges_and_fruit_per_week fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat
regress waist_circum_mean foodsec
        regress waist_circum_mean foodsec fram_age fram_sbp bmi i.fram_smoke i.fram_diab i.gender i.fram_sbptreat

regress nolabrisk10 partage i.gender // R-squared=0.4701; for every 1 yr increase in age, CVD risk increases by 1.05 percentage points (95%CI 1.00-1.10); CVD risk is 9.44 pp lower in women vs men (-10.4, -8.5)
regress nolabrisk10 partage i.gender hood_score // R-squared=0.4725; neighborhood characteristics not assoc. with CVD risk
regress nolabrisk10 partage i.gender i.percsafe  // R-squared=0.4703; neighborhood characteristics not assoc. with CVD risk
regress nolabrisk10 partage i.gender i.race // R-squared=0.4713; compared with white people, CVD risk is on average 3.7 pp higher in East Indian people (1.2, 6.2) 
regress nolabrisk10 partage i.gender i.occ // R-squared=0.4590; compared with professionals, CVD risk is on average 2.2 pp higher in non-professionals (0.80, 3.77)
regress nolabrisk10 partage i.gender i.D10 // R-squared=0.4724; compared with non-transsexual or transgender people, CVD risk is on average 2.86 pp higher in gender non-conforming people (6.58, 19.76)
regress nolabrisk10 partage i.gender i.religious // R-squared=0.4759. Religiousness not assoc with CVD risk
regress nolabrisk10 partage i.gender i.spirit // R-squared=0.4737. Spirituality not assoc with CVD risk
regress nolabrisk10 partage i.gender i.D16 // R-squared=0.4783. Compared with those who never attend religious ceremonies, CVD risk is on average 2.21 pp lower in people who attend more than once per week (-3.66, -0.78)
regress nolabrisk10 partage i.gender i.educ // R-squared=0.4803. College degree: -4.57 (-5.84, -3.30), vs less than high school
regress nolabrisk10 partage i.gender D7 // R-squared=0.4703. Self-rated income not assoc with CVD risk
regress nolabrisk10 partage i.gender promis // R-squared=0.4735. Unit increase in social support scale: -0.82 change in CVD risk (-1.51, -0.13)
regress nolabrisk10 partage i.gender emotion // R-squared=0.4701. Emotional support not assoc with CVD risk
regress nolabrisk10 partage i.gender i.D12 // R-squared=0.4755. Relationship status not assoc with CVD risk
regress nolabrisk10 partage i.gender i.SE25 // R-squared=0.4718. Experience of violence from partner not assoc with CVD risk
regress nolabrisk10 partage i.gender i.SE26 // R-squared=0.4712. Experience of violence from someone other than partner not assoc with CVD risk
regress nolabrisk10 partage i.gender i.D11 // R-squared=0.4794. Compared with heterosexuals, people who were not sure or questioning sexuality had an increased CVD of 5.16 pp on average (no difference for gay, lesbian or bisexual)

regress nolabrisk10 partage i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 // R-squared=0.4892. The only variable whose association with CVD risk remains is education
regress nolabrisk10 partage i.gender hood_score i.race i.occ i.D10 i.religious i.spirit i.D16 i.educ D7 promis emotion i.D12 i.SE25 i.SE26 i.D11 i.inactive i.binge veges_and_fruit_per_week