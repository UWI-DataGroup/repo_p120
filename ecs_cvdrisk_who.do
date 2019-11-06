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
    log using "`logpath'\ecs_cvdrisk_who", replace
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

** STEP 1. LOAD up and prepare the Reference Dataset

** STEP 2. Merge YOUR data with th reference data, to assign a risk score to each individual

** STEP 3. Plot the reference scores in the traditional HeatMap

