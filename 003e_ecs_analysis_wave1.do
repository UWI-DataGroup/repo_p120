** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            04-FEB-2020
    //  algorithm task			        implementing the Framingham CVD risk score.

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
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120

    ** Close any open log file and open a new log file
    capture log close
    *log using "`logpath'\ecs_analysis_wave1_002", replace

** HEADER -----------------------------------------------------

* TODO Give the following descriptions
* TODO      Brief Framingham background
* TODO      Age etc restrictions for the implementation
* TODO      Consider a brief regression of CVD risk score

**---------------------------------------
** PART ONE
** TABLE OF CVD RISK SCORES BY STRATIFIERS
**---------------------------------------

* ----------------------
** STEP 1. Load Data
** Dataset prepared in 003d_ecs_analysis_wave1.do
** USE FRAMINGHAM RISK SCORE
* ----------------------
use "`datapath'/version03/02-working/wave1_cvdrisk_prepared", clear
rename fram_risk10 risk10

** -------------------------------------------------------------------------------------------------------------------- 
** Prepare Risk categories  
** -------------------------------------------------------------------------------------------------------------------- 
** CVD risk categories
gen risk10_cat = . 
replace risk10_cat = 1 if risk10<0.1
replace risk10_cat = 2 if risk10>=0.1 & risk10<0.2
replace risk10_cat = 3 if risk10>=0.2 & risk10<.
label define _risk10_cat 1 "low" 2 "intermediate" 3 "high" 
label values risk10_cat _risk10_cat 

** Excess risk
gen excess = risk10 - fram_optrisk10 


** -------------------------------------------------------------------------------------------------------------------- 
* Exclusions for Framingham: 
*   applicable to those 30-74 years, without previously diagnosed CVD
** -------------------------------------------------------------------------------------------------------------------- 
replace risk10_cat=.z if partage>74 & partage<.
replace risk10_cat=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace risk10=.z if partage>74 & partage<.
replace risk10=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace fram_optrisk10=.z if partage>74 & partage<.
replace fram_optrisk10=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace excess=.z if partage>74 & partage<.
replace excess=.z if mi==1 | stroke==1 | angina==1 | chd==1

** -------------------------------------------------------------------------------------------------------------------- 
** Mean CVD risk score
* Age, Sex, education, occupation, heavy drinking, daily fruit and veg, obesity
** -------------------------------------------------------------------------------------------------------------------- 
**continuous risk score
mean risk10 
mean risk10, over(age_gr2)
mean risk10, over(gender)
mean risk10, over(educ)
mean risk10, over(occ)
mean risk10, over(binge)
mean risk10, over(inactive)
mean risk10, over(ob) 

** risk categories
prop risk10_cat
prop risk10_cat, over(age_gr2)
prop risk10_cat, over(gender)
prop risk10_cat, over(educ)
prop risk10_cat, over(occ)
prop risk10_cat, over(binge)
prop risk10_cat, over(inactive)
prop risk10_cat, over(ob)

** Mean optimal risk
mean fram_optrisk10
mean fram_optrisk10, over(age_gr2)
mean fram_optrisk10, over(gender)
mean fram_optrisk10, over(educ)
mean fram_optrisk10, over(occ)
mean fram_optrisk10, over(binge)
mean fram_optrisk10, over(inactive)
mean fram_optrisk10, over(ob)

** Excess risk (compared to optimal risk) + 95% CI  
mean excess 
mean excess, over(age_gr2)
mean excess, over(gender)
mean excess, over(educ)
mean excess, over(occ)
mean excess, over(binge)
mean excess, over(inactive)
mean excess, over(ob) 

**Risk categories overall and by site, including missing and excluded data
tab risk10_cat siteid, col miss

** -------------------------------------------------------------------------------------------------------------------- 
** Mean CVD risk score adjusted by age and gender
* Age, Sex, education, occupation, heavy drinking, daily fruit and veg, obesity
** -------------------------------------------------------------------------------------------------------------------- 
**OVERALL
        **continuous risk score
        adjmean risk10, by(age_gr2) adjust(gender)
        adjmean risk10, by(gender) adjust(partage)
        adjmean risk10, by(educ) adjust(gender partage)
        adjmean risk10, by(occ) adjust(gender partage)
        adjmean risk10, by(binge) adjust(gender partage)
        adjmean risk10, by(inactive) adjust(gender partage) 
        adjmean risk10, by(ob) adjust(gender partage)

        ** Mean optimal risk
        adjmean fram_optrisk10, by(age_gr2) adjust(gender)
        adjmean fram_optrisk10, by(gender) adjust(partage) 
        adjmean fram_optrisk10, by(educ) adjust(gender partage)  
        adjmean fram_optrisk10, by(occ) adjust(gender partage)
        adjmean fram_optrisk10, by(binge) adjust(gender partage)
        adjmean fram_optrisk10, by(inactive) adjust(gender partage)
        adjmean fram_optrisk10, by(ob) adjust(gender partage)

        **mean excess risk
        adjmean excess, by(age_gr2) adjust(gender)
        adjmean excess, by(gender) adjust(partage)
        adjmean excess, by(educ) adjust(gender partage)
        adjmean excess, by(occ) adjust(gender partage) 
        adjmean excess, by(binge) adjust(gender partage)
        adjmean excess, by(inactive) adjust(gender partage)
        adjmean excess, by(ob) adjust(gender partage)

        ** risk categories
            *create 0/1 variables for each category
            tab risk10_cat, miss

                    /*
                    risk10_cat |      Freq.     Percent        Cum.
                    -------------+-----------------------------------
                            low |        817       27.59       27.59
                    intermediate |        478       16.14       43.74
                            high |        409       13.81       57.55
                            . |        871       29.42       86.96
                            .z |        386       13.04      100.00
                    -------------+-----------------------------------
                        Total |      2,961      100.00               */

            gen low=.
            replace low=0 if risk10_cat==2 | risk10_cat==3
            replace low=1 if risk10_cat==1
            replace low=.z if risk10_cat==.z
            label variable low "low Fram CVD risk"
            label define noyes 0 "No" 1 "Yes"
            label values low noyes

            gen inter=.
            replace inter=0 if risk10_cat==1 | risk10_cat==3
            replace inter=1 if risk10_cat==2
            replace inter=.z if risk10_cat==.z
            label variable inter "intermediate Fram CVD risk"
            label values inter noyes

            gen high=.
            replace high=0 if risk10_cat==1 | risk10_cat==2
            replace high=1 if risk10_cat==3
            replace high=.z if risk10_cat==.z
            label variable high "intermediate Fram CVD risk"
            label values high noyes

                    /**check logistic regression and adjprop are the same
                    adjprop low, by(age_gr2) adjust(gender)
                    logistic low i.age_gr2 i.gender
                    margin gender  */

        adjprop low, by(age_gr2) adjust(gender)
        adjprop low, by(gender) adjust(partage)
        adjprop low, by(educ) adjust(gender partage)
        adjprop low, by(occ) adjust(gender partage)
        adjprop low, by(binge) adjust(gender partage)
        adjprop low, by(inactive) adjust(gender partage)
        adjprop low, by(ob) adjust(gender partage)

        adjprop inter, by(age_gr2) adjust(gender)
        adjprop inter, by(gender) adjust(partage)
        adjprop inter, by(educ) adjust(gender partage)
        adjprop inter, by(occ) adjust(gender partage)
        adjprop inter, by(binge) adjust(gender partage)
        adjprop inter, by(inactive) adjust(gender partage)
        adjprop inter, by(ob) adjust(gender partage)

        adjprop high, by(age_gr2) adjust(gender)
        adjprop high, by(gender) adjust(partage)
        adjprop high, by(educ) adjust(gender partage)
        adjprop high, by(occ) adjust(gender partage)
        adjprop high, by(binge) adjust(gender partage)
        adjprop high, by(inactive) adjust(gender partage)
        adjprop high, by(ob) adjust(gender partage)

**BY SITE
**continuous risk score
        adjmean risk10, by(siteid) adjust(partage gender)
        adjmean excess, by(siteid) adjust(partage gender)

 **continuous risk score by site
        **USVI
        adjmean risk10 if siteid==1, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==1, by(gender) adjust(partage)
        adjmean risk10 if siteid==1, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==1, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==1, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==1, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==1, by(ob) adjust(gender partage)  

        **PR
        adjmean risk10 if siteid==2, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==2, by(gender) adjust(partage)
        adjmean risk10 if siteid==2, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==2, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==2, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==2, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==2, by(ob) adjust(gender partage)      

        **BARBADOS
        adjmean risk10 if siteid==3, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==3, by(gender) adjust(partage)
        adjmean risk10 if siteid==3, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==3, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==3, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==3, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==3, by(ob) adjust(gender partage) 

        **TRINIDAD
        adjmean risk10 if siteid==4, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==4, by(gender) adjust(partage)
        adjmean risk10 if siteid==4, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==4, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==4, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==4, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==4, by(ob) adjust(gender partage) 

    **continuous excess risk by site
        **USVI
        adjmean excess if siteid==1, by(age_gr2) adjust(gender)
        adjmean excess if siteid==1, by(gender) adjust(partage)
        adjmean excess if siteid==1, by(educ) adjust(gender partage)
        adjmean excess if siteid==1, by(occ) adjust(gender partage)
        adjmean excess if siteid==1, by(binge) adjust(gender partage)
        adjmean excess if siteid==1, by(inactive) adjust(gender partage) 
        adjmean excess if siteid==1, by(ob) adjust(gender partage)  

        **PR
        adjmean excess if siteid==2, by(age_gr2) adjust(gender)
        adjmean excess if siteid==2, by(gender) adjust(partage)
        adjmean excess if siteid==2, by(educ) adjust(gender partage)
        adjmean excess if siteid==2, by(occ) adjust(gender partage)
        adjmean excess if siteid==2, by(binge) adjust(gender partage)
        adjmean excess if siteid==2, by(inactive) adjust(gender partage) 
        adjmean excess if siteid==2, by(ob) adjust(gender partage)      

        **BARBADOS
        adjmean excess if siteid==3, by(age_gr2) adjust(gender)
        adjmean excess if siteid==3, by(gender) adjust(partage)
        adjmean excess if siteid==3, by(educ) adjust(gender partage)
        adjmean excess if siteid==3, by(occ) adjust(gender partage)
        adjmean excess if siteid==3, by(binge) adjust(gender partage)
        adjmean excess if siteid==3, by(inactive) adjust(gender partage) 
        adjmean excess if siteid==3, by(ob) adjust(gender partage) 

        **TRINIDAD
        adjmean excess if siteid==4, by(age_gr2) adjust(gender)
        adjmean excess if siteid==4, by(gender) adjust(partage)
        adjmean excess if siteid==4, by(educ) adjust(gender partage)
        adjmean excess if siteid==4, by(occ) adjust(gender partage)
        adjmean excess if siteid==4, by(binge) adjust(gender partage)
        adjmean excess if siteid==4, by(inactive) adjust(gender partage) 
        adjmean excess if siteid==4, by(ob) adjust(gender partage)     



**BY SITE
** risk categories
        adjprop low, by(siteid) adjust(partage gender)
        adjprop low if siteid==1, by(age_gr2) adjust(gender)
        adjprop low if siteid==2, by(age_gr2) adjust(gender)
        adjprop low if siteid==3, by(age_gr2) adjust(gender)
        adjprop low if siteid==4, by(age_gr2) adjust(gender)

        adjprop inter, by(siteid) adjust(partage gender)
        adjprop inter if siteid==1, by(age_gr2) adjust(gender)
        adjprop inter if siteid==2, by(age_gr2) adjust(gender)
        adjprop inter if siteid==3, by(age_gr2) adjust(gender)
        adjprop inter if siteid==4, by(age_gr2) adjust(gender)

        adjprop high, by(siteid) adjust(partage gender)
        adjprop high if siteid==1, by(age_gr2) adjust(gender)
        adjprop high if siteid==2, by(age_gr2) adjust(gender)
        adjprop high if siteid==3, by(age_gr2) adjust(gender)
        adjprop high if siteid==4, by(age_gr2) adjust(gender)

