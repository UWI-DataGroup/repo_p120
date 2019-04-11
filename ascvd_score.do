** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ascvd_score.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	    		26-MAR-2019
    //  algorithm task			    	ASCVD 10-year Risk Score. ACC/AHA Guidelines

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\ascvd_score", replace
** HEADER -----------------------------------------------------

** SOURCE	
** 			Goff DC Jr, Lloyd-Jones DM, Bennett G, Coady S, D’Agostino RB Sr,
**			Gibbons R, Greenland P, Lackland DT, Levy D, O’Donnell CJ, Robinson JG,
**			Schwartz JS, Shero ST, Smith SC Jr, Sorlie P, Stone NJ, Wilson PWF. 2013 ACC/
**			AHA guideline on the assessment of cardiovascular risk: a report of the American
**			College of Cardiology/American Heart Association Task Force on Practice
**			Guidelines. J Am Coll Cardiol 2014;63:2935–59.
**
**			Copies: This document is available on the World Wide Web sites of the American
**			College of Cardiology (www.cardiosource.org), and the American Heart Association
**			(http://my.americanheart.org).

** Health of the Nation as example
use "`datapath'/version01/1-input/hotn_v41RPAQ", clear

** Apply weighting
svyset ed [pweight=wfinal1_ad], strata(region)

** Risk factor calculations - systolic blood pressure and diastolic blood presure
gen avgsbp = ( sbp2 + sbp3 ) / 2 
label variable avgsbp "Average Systolic blood pressure"
gen avgdbp = ( dbp2 + dbp3 ) / 2 
label variable avgdbp "Average diastolic blood pressure"

** Convert TCHOL	 mmol/l --> mg/dL
gen tchol_mg = tchol * 38.67
label var tchol_mg "Total cholesterol (mg/dL)"

** Convert HDL	 mmol/l --> mg/dL
gen hdl_mg = hdl * 38.67
label var hdl_mg "HDL (mg/dL)"

** -----------------------------------------------------------
** Ten year survial - ASCVD equation
**
** Calculating the 10-year risk estimate for hard ASCVD can best be described in a series of steps. 
** (1) 	The natural log of age, total cholesterol, HDL-C, and systolic BP are first calculated \
** 		with systolic BP being either a treated or untreated value. 
** (2) 	Any appropriate interaction terms are then calculated. 
** (3)	These values are then multiplied by the coefficients from the equation (“Coefficient” column of Table A) 
**		for the specific race-sex group of the individual. The “Coefficient % Value” column in the table
**		provides the results of the multiplication for the risk profile described above.
** (4) 	The sum of the “Coefficient % Value” column is then calculated for the individual. 
**		For the profile shown in Table A, this value is shown as “Individual Sum” for each race and sex group.
** (5)	The estimated 10-year risk of a first hard ASCVD event is formally calculated as 
**		1 minus the survival rate at 10 years (“Baseline Survival” in Table A), raised to the
**		power of the exponent of the “Coefficient % Value” sum minus the race- and sex-specific 
**		overall mean “Coefficient % Value” sum; or, in equation form:
**
**		1 - S10^e(indXB - MeanXB)
** -----------------------------------------------------------


** -----------------------------------------------------------
** African Descent Women (sex==1)
** -----------------------------------------------------------

** Model Terms

** ln Age (y)
gen lnage = ln(agey)
gen coeflnage = (lnage)*(17.114) if sex == 1 

** Ln Total Cholesterol (mg/dL)
gen lntchol = ln(tchol_mg)
gen coeflntchol = (lntchol)*(0.940) if sex == 1 

** Ln HDL-C (mg/dL)
gen lnhdl = ln(hdl_mg)
gen coeflnhdl = (lnhdl)*(-18.92) if sex == 1 

** Ln Age x Ln HDL-C
gen interact1 = 0 
replace interact1 = 4.475 * lnage * lnhdl if sex == 1

** Ln Treated Systolic BP (mm Hg)
gen lnsbpt = ln(avgsbp)
gen coeflnsbpt = (lnsbpt)*(29.291) if sex == 1 & hyperm == 1

** Ln Untreated Systolic BP (mm Hg)
gen lnsbput = ln(avgsbp)
gen coeflnsbput = (lnsbput)*(27.82) if sex == 1 & (hyperm == 2 | hyperm==.z)

** Single variable for Ln SBP (treated or untreated as appropriate)
gen coeflnsbp = 0 
replace coeflnsbp = coeflnsbpt if sex==1 & hyperm == 1
replace coeflnsbp = coeflnsbput if sex==1 & (hyperm == 2 | hyperm==.z)

** Ln Age % Ln Treated Systolic BP
gen interact2 = 0
replace interact2 = -6.432 * lnage * lnsbpt if sex == 1 & hyperm==1

** Ln Age % Ln Untreated Systolic BP
gen interact3 = 0
replace interact3 = -6.087 * lnage * lnsbput if sex == 1 & (hyperm == 2 | hyperm==.z)

** Current Smoker (1=Yes, 0=No)
recode smoke 2 = 0
gen smokeeq = 0
replace smokeeq = 0.691 * smoke  if sex == 1 

** Diabetes (1=Yes, 0=No)
recode diab 2 = 0
gen diabeq = 0
replace diabeq = 0.874 * diab if sex == 1



** -----------------------------------------------------------
** African Descent Men (sex=2)
** -----------------------------------------------------------
replace coeflnage  = (lnage)*(2.469) if sex == 2
replace coeflntchol  = (lntchol)*(0.302) if sex == 2
replace coeflnhdl  = (lnhdl)*(-0.307) if sex == 2
replace coeflnsbpt  = (lnsbpt)*(1.916) if sex == 2 & hyperm == 1
replace coeflnsbput  = (lnsbput)*(1.809) if sex == 2 & (hyperm == 2 | hyperm==.z)
	replace coeflnsbp = coeflnsbpt if sex==2 & hyperm == 1
	replace coeflnsbp = coeflnsbput if sex==2 & (hyperm == 2 | hyperm==.z)
replace smokeeq = 0.549 * smoke if sex == 2
replace diabeq = 0.645 * diab if sex == 2

** Summation of the included terms for women or men
gen add = coeflnage + coeflntchol + coeflnhdl + coeflnsbp + smokeeq + diabeq + interact1 + interact2 + interact3 
label var add "Summation of individual score items"

** Sex-specific average summation
sum add if sex ==1
local meanf = r(mean)
dis `meanf'
sum add if sex ==2
local meanm = r(mean)
dis `meanm'

** 10-year risk score
gen tyr = 1 - 0.8954 ^ exp(add - `meanm') if sex == 2 		
replace tyr = 1 - 0.9533 ^ exp(add - `meanf') if sex == 1
replace tyr = tyr * 100
label var tyr "10-year CVD risk"

** DATA CHECK: review the component scores for first N=20 participants
qui {
	list pid sex tyr coeflnage coeflntchol coeflnhdl coeflnsbpt coeflnsbput coeflnsbp smokeeq diabeq in 1/20
	list pid sex tyr interact1 interact2 interact3  in 1/20
	}
sort tyr 

** Index plot (10-year score by participant ID number)
** Simple confirmation that calculated risk for all participants contained within 0 and 100 (!)
** Color coded by sex (1=female, 2=male)
gr twoway (scatter tyr pid if sex==1, mc(red)) (scatter tyr pid if sex==2, mc(blue)), legend(lab(1 "women") lab(2 "men"))


** Keep only what we need in a new dataset
keep pid sex agey tchol_mg hdl_mg avgsbp smoke diab add tyr mi stroke hf
order pid sex agey tchol_mg hdl_mg avgsbp smoke diab add tyr 
label data "ACC/AHA 10-year CVD risk in HOTN"
save "`datapath'/version01/2-working/cvd_risk_score.dta", replace

** Quintiles of 10-year risk
xtile tyr_q = tyr , n(5) 
table tyr_q, c(n tyr mean tyr sd tyr) format(%9.2f)

** Binary stratification. (<20%) and (>=20%)
gen tyr20 = 0
replace tyr20 = 1 if tyr>=20
replace tyr20 = . if mi==1 | stroke==1 | hf==1

** Brief tabulations to compare 
tab tyr20 sex, col
tab tyr20 sex, col miss
