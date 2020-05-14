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

** -------------------------------------------------------------------------------------------------------------------- 
* Exclusions for Framingham: 
*   applicable to those 30-74 years, without previously diagnosed CVD
** -------------------------------------------------------------------------------------------------------------------- 
replace risk10_cat=.z if partage>74 & partage<.
replace risk10_cat=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace risk10=.z if partage>74 & partage<.
replace risk10=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace nolabrisk10cat=.z if partage>74 & partage<.
replace nolabrisk10cat=.z if mi==1 | stroke==1 | angina==1 | chd==1
replace nolabrisk10=.z if partage>74 & partage<.
replace nolabrisk10=.z if mi==1 | stroke==1 | angina==1 | chd==1


**convert mean risk scores to percentages rather than proportions for presentation:
gen risk10perc = risk10*100
drop risk10 
rename risk10perc risk10 

gen nolabrisk10perc = nolabrisk10*100
drop nolabrisk10 
rename nolabrisk10perc nolabrisk10 

** -------------------------------------------------------------------------------------------------------------------- 
** Mean CVD risk score (UNADJUSTED)
* Age, Sex, education, occupation, heavy drinking, daily fruit and veg, obesity
** -------------------------------------------------------------------------------------------------------------------- 
**continuous risk score (based on lab algorithm)
mean risk10 
mean risk10, over(age_gr2)
mean risk10, over(gender)
mean risk10, over(educ)
mean risk10, over(occ)
mean risk10, over(binge)
mean risk10, over(inactive)
mean risk10, over(ob) 

**continuous risk score (based on non-lab algorithm)
mean nolabrisk10 
mean nolabrisk10, over(age_gr2)
mean nolabrisk10, over(gender)
mean nolabrisk10, over(educ)
mean nolabrisk10, over(occ)
mean nolabrisk10, over(binge)
mean nolabrisk10, over(inactive)
mean nolabrisk10, over(ob) 

** risk categories (based on lab algorithm)
prop risk10_cat
prop risk10_cat, over(age_gr2)
prop risk10_cat, over(gender)
prop risk10_cat, over(educ)
prop risk10_cat, over(occ)
prop risk10_cat, over(binge)
prop risk10_cat, over(inactive)
prop risk10_cat, over(ob)


** risk categories (based on non-lab algorithm)
prop nolabrisk10cat
prop nolabrisk10cat, over(age_gr2)
prop nolabrisk10cat, over(gender)
prop nolabrisk10cat, over(educ)
prop nolabrisk10cat, over(occ)
prop nolabrisk10cat, over(binge)
prop nolabrisk10cat, over(inactive)
prop nolabrisk10cat, over(ob)


**Risk categories overall and by site, including missing and excluded data
tab risk10_cat siteid, col miss
tab nolabrisk10cat siteid, col miss

** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 1: Mean CVD risk score and CVD risk categorization calculated using general algorithm and adjusted by age and gender; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, obesity
** -------------------------------------------------------------------------------------------------------------------- 

*OVERALL
        **continuous risk score
        adjmean risk10, by(age_gr2) adjust(gender)
        adjmean risk10, by(gender) adjust(partage)
        adjmean risk10, by(educ) adjust(gender partage)
        adjmean risk10, by(occ) adjust(gender partage)
        adjmean risk10, by(binge) adjust(gender partage)
        adjmean risk10, by(inactive) adjust(gender partage) 
        adjmean risk10, by(ob) adjust(gender partage)


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
            label variable high "high Fram CVD risk"
            label values high noyes



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


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 2: Mean CVD risk score and CVD risk categorization calculated using simplified algorithm and adjusted by age and gender; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, obesity
** -------------------------------------------------------------------------------------------------------------------- 

*OVERALL
        **continuous risk score
        adjmean nolabrisk10, by(age_gr2) adjust(gender)
        adjmean nolabrisk10, by(gender) adjust(partage)
        adjmean nolabrisk10, by(educ) adjust(gender partage)
        adjmean nolabrisk10, by(occ) adjust(gender partage)
        adjmean nolabrisk10, by(binge) adjust(gender partage)
        adjmean nolabrisk10, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10, by(ob) adjust(gender partage)


        ** risk categories
            *create 0/1 variables for each category
            gen nolab_low=.
            replace nolab_low=0 if nolabrisk10cat==2 | nolabrisk10cat==3
            replace nolab_low=1 if nolabrisk10cat==1
            replace nolab_low=.z if nolabrisk10cat==.z
            label variable nolab_low "low Fram CVD risk (no lab)"
            label values nolab_low noyes

            gen nolab_inter=.
            replace nolab_inter=0 if nolabrisk10cat==1 | nolabrisk10cat==3
            replace nolab_inter=1 if nolabrisk10cat==2
            replace nolab_inter=.z if nolabrisk10cat==.z
            label variable nolab_inter "intermediate Fram CVD risk (no lab)"
            label values nolab_inter noyes

            gen nolab_high=.
            replace nolab_high=0 if nolabrisk10cat==1 | risk10_cat==2
            replace nolab_high=1 if nolabrisk10cat==3
            replace nolab_high=.z if nolabrisk10cat==.z
            label variable nolab_high "high Fram CVD risk (no lab)"
            label values nolab_high noyes

        *summarize categories adjusted by age and/or gender
        adjprop nolab_low, by(age_gr2) adjust(gender)
        adjprop nolab_low, by(gender) adjust(partage)
        adjprop nolab_low, by(educ) adjust(gender partage)
        adjprop nolab_low, by(occ) adjust(gender partage)
        adjprop nolab_low, by(binge) adjust(gender partage)
        adjprop nolab_low, by(inactive) adjust(gender partage)
        adjprop nolab_low, by(ob) adjust(gender partage)

        adjprop nolab_inter, by(age_gr2) adjust(gender)
        adjprop nolab_inter, by(gender) adjust(partage)
        adjprop nolab_inter, by(educ) adjust(gender partage)
        adjprop nolab_inter, by(occ) adjust(gender partage)
        adjprop nolab_inter, by(binge) adjust(gender partage)
        adjprop nolab_inter, by(inactive) adjust(gender partage)
        adjprop nolab_inter, by(ob) adjust(gender partage)

        adjprop nolab_high, by(age_gr2) adjust(gender)
        adjprop nolab_high, by(gender) adjust(partage)
        adjprop nolab_high, by(educ) adjust(gender partage)
        adjprop nolab_high, by(occ) adjust(gender partage)
        adjprop nolab_high, by(binge) adjust(gender partage)
        adjprop nolab_high, by(inactive) adjust(gender partage)
        adjprop nolab_high, by(ob) adjust(gender partage)


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 3: Mean CVD risk score calculated using general algorithm and adjusted by age and gender by site; 
**          Stratified by Age, Sex, education, occupation, heavy drinking and obesity
** --------------------------------------------------------------------------------------------------------------------

**BY SITE
**continuous risk score
        adjmean risk10, by(siteid) adjust(partage gender)

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

  ** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 4: Mean CVD risk score calculated using simplified algorithm and adjusted by age and gender by site; 
**          Stratified by Age, Sex, education, occupation, heavy drinking and obesity
** --------------------------------------------------------------------------------------------------------------------

**BY SITE
**continuous risk score
        adjmean nolabrisk10, by(siteid) adjust(partage gender)

 **continuous risk score by site
        **USVI
        adjmean nolabrisk10 if siteid==1, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==1, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==1, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==1, by(ob) adjust(gender partage)  

        **PR
        adjmean nolabrisk10 if siteid==2, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==2, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==2, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==2, by(ob) adjust(gender partage)      

        **BARBADOS
        adjmean nolabrisk10 if siteid==3, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==3, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==3, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==3, by(ob) adjust(gender partage) 

        **TRINIDAD
        adjmean nolabrisk10 if siteid==4, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==4, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==4, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==4, by(ob) adjust(gender partage) 

   
 

** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 5: CVD risk categorization by site calculated using general algorithm and adjusted by age and gender; 
**          Stratified by Age 
** -------------------------------------------------------------------------------------------------------------------- 
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


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 6: CVD risk categorization by site calculated using simplified algorithm and adjusted by age and gender; 
**          Stratified by Age 
** -------------------------------------------------------------------------------------------------------------------- 
**BY SITE
** risk categories
        adjprop nolab_low, by(siteid) adjust(partage gender)
        adjprop nolab_low if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==4, by(age_gr2) adjust(gender)

        adjprop nolab_inter, by(siteid) adjust(partage gender)
        adjprop nolab_inter if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==4, by(age_gr2) adjust(gender)

        adjprop nolab_high, by(siteid) adjust(partage gender)
        adjprop nolab_high if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==4, by(age_gr2) adjust(gender)

/** -------------------------------------------------------------------------------------------------------------------- 
** Prevalence of diabetes, hypertension and obesity adjusted by age and gender
** -------------------------------------------------------------------------------------------------------------------- 
**HYPERTENSION: defined here as - SBP >= 140 or DBP >=90 or on medication
** Proportion >= SBP 140
gen sbp140 = 0
replace sbp140 = 1 if fram_sbp>=140
replace sbp140 = . if fram_sbp>=.
** Proportion >= DBP 90
gen dbp90 = 0
replace dbp90 = 1 if bp_diastolic>=90
replace dbp90 = . if bp_diastolic>=.
** Proportion >=SBP140 OR DBP>=90 OR ON MEDS
gen hyper = 0
replace hyper = 1 if sbp140==1 | dbp90==1 | fram_sbptreat==1
replace hyper = . if sbp140==. & dbp90==. & fram_sbptreat==.
label variable hyper "hypertension - diagnosed or by measurement"
label define hyper 0 "not hypertensive" 1 "hypertensive"
label values hyper hyper





