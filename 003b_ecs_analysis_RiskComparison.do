** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			        Description of CVD risk according to Framingham General, Fram simplified, ASCVD, WHO general
    //                                  and WHO simplified algorithms.

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
    ** GRAPHS to project output folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p120\05_Outputs\DASR_presentation"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_analysis_wave1_002", replace

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

** Create 0/1 variables for each risk category
** LOW CATEGORY
foreach x in frcat frsimcat WHObmi_cat WHOgen_cat ascvd_cat {
        gen `x'_low=`x' 
        replace `x'_low=0 if `x'==2 | `x'==3
}
                ** check code OK
                tab frcat_low, miss
                tab frsimcat_low, miss
                tab WHObmi_cat_low, miss
                tab WHOgen_cat_low, miss
                tab ascvd_cat_low, miss

** INTERMEDIATE CATEGORY
foreach x in frcat frsimcat WHObmi_cat WHOgen_cat ascvd_cat {
        gen `x'_int=`x'
        replace `x'_int=1 if `x'==2
        replace `x'_int=0 if `x'==1 | `x'==3
}         
                ** check code OK
                tab frcat_int, miss
                tab frsimcat_int, miss
                tab WHObmi_cat_int, miss
                tab WHOgen_cat_int, miss
                tab ascvd_cat_int, miss

** HIGH CATEGORY
foreach x in frcat frsimcat WHObmi_cat WHOgen_cat ascvd_cat {
        gen `x'_high=`x'
        replace `x'_high=1 if `x'==3
        replace `x'_high=0 if `x'==1 | `x'==2
}
                tab frcat_high, miss
                tab frsimcat_high, miss
                tab WHObmi_cat_high, miss
                tab WHOgen_cat_high, miss
                tab ascvd_cat_high, miss

** This section for making sure we are comparing the same participants
drop if partage>74 & partage<.
drop if mi==1 | stroke==1 | angina==1 | chd==1
drop if race==.
drop if tchol==. | hdl==. | sbp==. | diab==. | smoke==. | sbptreat==.
drop if bmi==.
drop if WHObmi_cat ==.

** -------------------------------------------------------------------------------------------------------------------- 
** Table 1: Baseline CVD risk factors (demographic, physical, and laboratory characteristics) of the ECHORN cohort
** --------------------------------------------------------------------------------------------------------------------
by gender, sort : summarize partage
by gender, sort : summarize sbp
by gender, sort : summarize bp_diastolic
tab sbptreat gender, col
by gender, sort : summarize bmi
by gender, sort : summarize tchol
by gender, sort : summarize hdl
tab smoke gender, col
tab diab gender, col
tab race gender, col

** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 2: Baseline 10-year CVD risk in the ECHORN cohort according to five different risk algorithms (all countries)
** -------------------------------------------------------------------------------------------------------------------- 
** Framingham general
mean frrisk10 
mean frrisk10, over(gender)
mean frrisk10, over(age_gr2)
** Framingham simplified
mean frsim10 
mean frsim10, over(gender)
mean frsim10, over(age_gr2) 
** AHA/ASCVD
mean ascvd10 
mean ascvd10, over(gender)
mean ascvd10, over(age_gr2)
** WHO general
mean WHO_gen 
mean WHO_gen, over(gender)
mean WHO_gen, over(age_gr2)
** WHO simplified
mean WHO_nolab  
mean WHO_nolab, over(gender)
mean WHO_nolab, over(age_gr2)

** -------------------------------------------------------------------------------------------------------------------- 
** ** Supplementary table 1: Risk categories using 5 different risk algorithms 
**          Stratified by Age and gender
** -------------------------------------------------------------------------------------------------------------------- 
** Framingham general
prop frcat
prop frcat, over(gender)
prop frcat, over(age_gr2)
** Framingham simplified
prop frsimcat
prop frsimcat, over(gender)
prop frsimcat, over(age_gr2)
** AHA/ASCVD
prop ascvd_cat
prop ascvd_cat, over(gender)
prop ascvd_cat, over(age_gr2)
** WHO general
prop WHOgen_cat
prop WHOgen_cat, over(gender)
prop WHOgen_cat, over(age_gr2)
** WHO simplified
prop WHObmi_cat
prop WHObmi_cat, over(gender)
prop WHObmi_cat, over(age_gr2)

*-----------------------------------------------------------------
**CREATE INDICATOR VARIABLES FOR EACH STRATIFIER
*-----------------------------------------------------------------
** COUNTRY indicators
gen usvi = (siteid==1) if !missing(siteid)
gen pr = (siteid==2) if !missing(siteid)
gen bb = (siteid==3) if !missing(siteid)
gen tt = (siteid==4) if !missing(siteid)

** AGE indicators
gen age40 = (age_gr2==1) if !missing(age_gr2)
gen age50 = (age_gr2==2) if !missing(age_gr2)
gen age60 = (age_gr2==3) if !missing(age_gr2)
gen age70 = (age_gr2==4) if !missing(age_gr2)

** EDUCATION
gen educ1 = (educ==1) if !missing(educ)
gen educ2 = (educ==2) if !missing(educ)
gen educ3 = (educ==3) if !missing(educ)
gen educ4 = (educ==4) if !missing(educ)

** GENDER and OCCUPATION indicators already exist

**SAVE DATASET 
save "`datapath'/version03/02-working/risk_comparison", replace


** -------------------------------------------------------------------------------------------------------------------- 
** FIGURE 1: BAR CHART of FRAMINGHAM GENERAL AND SIMPLIFIED versus ASCVD risk score categorizations
** -------------------------------------------------------------------------------------------------------------------- 
                **********************************************************************************************
                ** STEP 1: CREATE DATASETS THAT CONTAIN THE PREVALENCE OF EACH RISK CATEGORY FOR A SINGLE SCORE
                **********************************************************************************************
                gen indicator2=.
                tempfile s18 s19 s20 s21 s22 s23 s24 s25 s26 s27 s28 s29 s30 s31 s32 low_risk high_risk int_risk

                **PREVALENCE OF HIGH RISK
                preserve
                    collapse (mean) frsimcat_high, by(indicator2)
                    replace indicator2=1
                    rename frsimcat_high high  
                    save `s18', replace
                restore

                preserve
                    collapse (mean) frcat_high, by(indicator2)
                    replace indicator2=2
                    rename frcat_high high 
                    save `s19', replace
                restore

                preserve
                    collapse (mean) ascvd_cat_high, by(indicator2)
                    replace indicator2=3 
                    rename ascvd_cat_high high 
                    save `s20', replace
                restore

                preserve
                    collapse (mean) WHOgen_cat_high, by(indicator2)
                    replace indicator2=4
                    rename WHOgen_cat_high high  
                    save `s21', replace
                restore

                preserve
                    collapse (mean) WHObmi_cat_high, by(indicator2)
                    replace indicator2=5 
                    rename WHObmi_cat_high high 
                    save `s22', replace
                restore


                **PREVALENCE OF INTERMEDIATE RISK
                preserve
                    collapse (mean) frsimcat_int, by(indicator2)
                    replace indicator2=1
                    rename frsimcat_int inter
                    save `s23', replace   
                restore

                preserve
                    collapse (mean) frcat_int, by(indicator2)
                    replace indicator2=2
                    rename frcat_int inter 
                    save `s24', replace 
                restore

                preserve
                    collapse (mean) ascvd_cat_int, by(indicator2)
                    replace indicator2=3 
                    rename ascvd_cat_int inter 
                    save `s25', replace 
                restore

                preserve
                    collapse (mean) WHOgen_cat_int, by(indicator2)
                    replace indicator2=4
                    rename WHOgen_cat_int inter 
                    save `s26', replace 
                restore

                preserve
                    collapse (mean) WHObmi_cat_int, by(indicator2)
                    replace indicator2=5 
                    rename WHObmi_cat_int inter 
                    save `s27', replace 
                restore

                **PREVALENCE OF LOW RISK
                preserve
                    collapse (mean) frsimcat_low, by(indicator2)
                    replace indicator2=1
                    rename frsimcat_low low 
                    save `s28', replace 
                restore

                preserve
                    collapse (mean) frcat_low, by(indicator2)
                    replace indicator2=2
                    rename frcat_low low
                    save `s29', replace  
                restore

                preserve
                    collapse (mean) ascvd_cat_low, by(indicator2)
                    replace indicator2=3 
                    rename ascvd_cat_low low 
                    save `s30', replace
                restore

                preserve
                    collapse (mean) WHOgen_cat_low, by(indicator2)
                    replace indicator2=4
                    rename WHOgen_cat_low low
                    save `s31', replace   
                restore

                preserve
                    collapse (mean) WHObmi_cat_low, by(indicator2)
                    replace indicator2=5 
                    rename WHObmi_cat_low low 
                    save `s32', replace
                restore

                **********************************************************************************************
                ** STEP 2: COMBINE DATASETS FROM STEP 1 BY RISK CATEGORY
                **********************************************************************************************
                *CREATE DATASET THAT COMBINES PREVALENCE OF HIGH RISK FOR ALL SCORES
                use `s18', clear
                append using `s19'
                append using `s20'
                append using `s21'
                append using `s22'
                save `high_risk', replace 

                *CREATE DATASET THAT COMBINES PREVALENCE OF INTERMEDIATE RISK FOR ALL SCORES
                use `s23', clear 
                append using `s24'
                append using `s25'
                append using `s26'
                append using `s27'
                save `int_risk', replace

                *CREATE DATASET THAT COMBINES PREVALENCE OF LOW RISK FOR ALL SCORES
                use `s28', clear 
                append using `s29'
                append using `s30'
                append using `s31'
                append using `s32'
                save `low_risk', replace

                **********************************************************************************************
                ** STEP 3: COMBINE RISK CATEGORY DATASETS TO CREATE DATASET THAT CAN BE USED FOR BARCHART
                **********************************************************************************************
                *MERGE DATASETS
                use `low_risk', clear 
                merge 1:1 indicator2 using `int_risk'
                drop _merge 
                merge 1:1 indicator2 using `high_risk'
                drop _merge

                **********************************************************************************************
                ** STEP 4: PLOT BAR CHART
                **********************************************************************************************
                            label define indicator2 1 "Framingham non-lab" 2 "Framingham lab" 3 "AHA/ASCVD" 4 "WHO lab" 5 "WHO non-lab"
                            label values indicator2 indicator2
                            replace low=low*100
                            replace inter=inter*100
                            replace high=high*100


                            #delimit ;

                                    graph hbar high inter low, stack 
                                                    name(risk_score_categories)
                                                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
                                                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                                                    ysize(3)
                                            
                                                    
                                                    over(indicator2, gap(5)) 
                                                    blabel(none, format(%9.0f) pos(outside) size(medsmall))
                                            
                                                    bar(1, bc("240 59 32") blw(vthin) blc("240 59 32"))
                                                    bar(2, bc("254 178 76") blw(vthin) blc("254 178 76"))
                                                    bar(3, bc("255 237 160") blw(vthin) blc("255 237 160"))
                                                            
                                                    
                                                    ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
                                                    ytitle("10-yr CVD Risk Categories (%)", margin(t=3) size(medsmall))
                                                    ymtick(0(10)100)

                                                    legend(size(small) position(12) bm(t=0 b=5 l=0 r=0) colf cols(3)
                                                            region(lstyle(none) fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1)) 
                                                            lab(1 "high risk")
                                                            lab(2 "intermediate risk")
                                                            lab(3 "low risk") )		
                                                    saving(risk_score_categories, replace)
                                                    ;

                                            #delimit cr

                            graph export "`outputpath'/cvdrisk_categories.png", replace  

** *-------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 3: Odds of high cardiovascular disease risk (using 5 different calculators) by selected social determinant of health
** -------------------------------------------------------------------------------------------------------------------- 
use "`datapath'/version03/02-working/risk_comparison", clear

** Prepare food security categories. There is an inconsistency in how the data was collected. See ECHORN_SURVEY_QUESTIONTREE for details. Should have been scored 0-8, 
** but was scored 0-9. 
gen fsec_cat=.
replace fsec_cat=1 if foodsec2==0
replace fsec_cat=2 if foodsec2 >= 1 & foodsec2 < 4
replace fsec_cat=3 if foodsec2 >= 4 & foodsec2 < .
    * check
    codebook foodsec2 if fsec_cat==1
    codebook foodsec2 if fsec_cat==2
    codebook foodsec2 if fsec_cat==3
label variable fsec_cat "Food security categories"
label define fsec_cat 1 "food secure" 2 "mild food insecurity" 3 "moderate/severe food insecurity" 
label values fsec_cat fsec_cat
** for table
tab fsec_cat


** income categories: split into tertiles
xtile inc3 = D7, nq(3)
codebook D7 if inc3==1
codebook D7 if inc3==2
codebook D7 if inc3==3
** for table
tab inc3

* education
tab educ

** REGRESSION WITH HIGH RISK AS OUTCOME; SDoH as predictor; age and gender controlled
** Framingham simplified
logistic frsimcat_high i.fsec_cat partage gender
logistic frsimcat_high i.inc3 partage gender
logistic frsimcat_high i.educ partage gender
logistic frsimcat_high i.occ partage gender

** Framingham general
logistic frcat_high i.fsec_cat partage gender
logistic frcat_high i.inc3 partage gender
logistic frcat_high i.educ partage gender
logistic frcat_high i.occ partage gender

** ASCVD
logistic ascvd_cat_high i.fsec_cat partage gender
logistic ascvd_cat_high i.inc3 partage gender
logistic ascvd_cat_high i.educ partage gender
logistic ascvd_cat_high i.occ partage gender

** WHO general
logistic WHOgen_cat_high i.fsec_cat partage gender
logistic WHOgen_cat_high i.inc3 partage gender
logistic WHOgen_cat_high i.educ partage gender
logistic WHOgen_cat_high i.occ partage gender

** WHO simplified
logistic WHObmi_cat_high i.fsec_cat partage gender
logistic WHObmi_cat_high i.inc3 partage gender
logistic WHObmi_cat_high i.educ partage gender
logistic WHObmi_cat_high i.occ partage gender


/*This format for the table showing: "Baseline 10-year CVD risk categorization in the ECHORN cohort according to five different risk algorithms (all countries) 
  stratified by key social determinants of health" removed on 13th August 2021. There is a need to control for at least age and gender 

**Perceived income relative to rest of population
mean D7, over(frsimcat)
mean D7, over(frcat)
mean D7, over(ascvd_cat)
mean D7, over(WHOgen_cat)
mean D7, over(WHObmi_cat)

** Mean food security score 
mean foodsec2, over(frsimcat)
mean foodsec2, over(frcat)
mean foodsec2, over(ascvd_cat)
mean foodsec2, over(WHOgen_cat)
mean foodsec2, over(WHObmi_cat)

**education
tab educ frsimcat, row chi2
tab educ frcat, row chi2
tab educ ascvd_cat, row chi2
tab educ WHOgen_cat, row chi2
tab educ WHObmi_cat, row chi2

*occupation
tab occ frsimcat, row chi2
tab occ frcat, row chi2
tab occ ascvd_cat, row chi2
tab occ WHOgen_cat, row chi2
tab occ WHObmi_cat, row chi2


local c_date = c(current_date)
local date_string = subinstr("`c_date'", " ", "", .)
save "`datapath'\version01\2-working\test_`date_string'", replace

** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 4: Agreement between high risk category of different risk algorithms
** -------------------------------------------------------------------------------------------------------------------- 

tab frcat_high frsimcat_high
kapci frcat_high frsimcat_high 
tab frcat_high ascvd_cat_high
kapci frcat_high ascvd_cat_high
tab frcat_high WHOgen_cat_high
kapci frcat_high WHOgen_cat_high
tab frcat_high WHObmi_cat_high
kapci frcat_high WHObmi_cat_high
tab frsimcat_high ascvd_cat_high
kapci frsimcat_high ascvd_cat_high
tab frsimcat_high WHOgen_cat_high
kapci frsimcat_high WHOgen_cat_high
tab frsimcat_high WHObmi_cat_high
kapci frsimcat_high WHObmi_cat_high
tab ascvd_cat_high WHOgen_cat_high
kapci ascvd_cat_high WHOgen_cat_high
tab ascvd_cat_high WHObmi_cat_high
kapci ascvd_cat_high WHObmi_cat_high
tab WHOgen_cat_high WHObmi_cat_high
kapci WHOgen_cat_high WHObmi_cat_high


** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 4: Correlation between mean 10-year risk of different risk algorithms
** -------------------------------------------------------------------------------------------------------------------- 
pwcorr frrisk10 frsim10 WHO_nolab WHO_gen ascvd10

