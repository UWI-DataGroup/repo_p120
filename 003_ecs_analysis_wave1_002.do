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
    set linesize 80

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
** Dataset prepared in ecs_analyssi_001.do
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
** Mean CVD risk score
* Age, Sex, education, occupation, heavy drinking, daily fruit and veg, obesity
** -------------------------------------------------------------------------------------------------------------------- 
mean risk10 

