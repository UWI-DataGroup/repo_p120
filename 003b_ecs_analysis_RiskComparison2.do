** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Christina Howitt
    //  algorithm task			        paper 1 supplementary analyses: comparison of demographics in responders vs non-responders
    //                                  

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 120

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"
     ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120
    ** GRAPHS to project output folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p120\05_Outputs"

    ** Close any open log file and open a new log file
    capture log close
    *log using "`logpath'\ecs_analysis_RiskComparison2, replace

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

** -------------------------------------------------------------------------------------------------------------------- 
** DATA PREPARATION     
** -------------------------------------------------------------------------------------------------------------------- 
* We want to limit comparison to participants with all risk scores.   
* We will also apply the Framingham age range (30-74 years) and exclude those with previously diagnosed CVD

foreach x in frrisk10 frsim10 frcat frsimcat WHO_nolab WHO_gen WHObmi_cat WHOgen_cat ascvd10 ascvd_cat {
        replace `x'=.z if partage>74 & partage<.
        replace `x'=.z if mi==1 | stroke==1 | angina==1 | chd==1 
}

*create variable to determine if participant meets exclusion criteria
gen exc = 0
replace exc = 1 if partage>74 & partage<.
replace exc = 1 if mi==1 | stroke==1 | angina==1 | chd==1 
tab exc

*SUPPLEMENTARY TABLE TO summarize demographics
mean partage
prop gender
prop educ
prop occ

** This drops those who were not included in risk score comparison analysis due to meeting exclusion criteria and missing data
drop if partage>74 & partage<.
drop if mi==1 | stroke==1 | angina==1 | chd==1
drop if race==.
drop if tchol==. | hdl==. | sbp==. | diab==. | smoke==. | sbptreat==.
drop if bmi==.
drop if WHObmi_cat ==.

codebook key /// confirmed 1777 particpants


*SUPPLEMENTARY TABLE TO summarize demographics
mean partage
prop gender
prop educ
prop occ