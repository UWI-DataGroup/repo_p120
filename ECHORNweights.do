**  DO-FILE METADATA
//  algorithm name						ECHORNweights
//  project:							ECHORN CVD risk analysis
//  analysts:							Christina HOWITT
//	date last modified		            22-July-2019

** General algorithm set-up
version 15
clear all
macro drop _all
set more 1
set linesize 80

** Set working directories: this is for DATASET and LOGFILE import and export
** DATASETS to encrypted SharePoint folder
local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p120"
** LOGFILES to unencrypted OneDrive folder
local logpath X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p120

** Close any open log fileand open a new log file
capture log close
cap log using "`logpath'\echorn_weights_001", replace

***************************************************************************************************************************************************
** PROPORTIONS OF MEN IN 10 YEAR AGE GROUPS IN B'DOS, T'DAD, USVI, AND PR
***************************************************************************************************************************************************
**import dataset (men)
import excel "`datapath'\version02\1-input\wpp2019men.xlsx", sheet("Sheet1") firstrow clear

**label as men
gen gender=1

**get rid of unneccessary variables
drop Index Variant Notes Type Parentcode I J K L M N O P
rename Referencedateasof1July year

**generate numbers of men in 10 yr groups
gen grp1 = Q + R
label variable grp1 "Number aged 40-49 (1000s)"
gen grp2 = S + T
label variable grp2 "Number aged 50-59 (1000s)"
gen grp3 = U + V
label variable grp3 "Number aged 60-69 (1000s)"
gen grp4 = W + X + Y + Z + AA + AB + AC 
label variable grp4 "Number aged 70+ (1000s)"

save "`datapath'\version02\1-input\WPPmen.dta", replace 

***************************************************************************************************************************************************
** PROPORTIONS OF WOMEN IN 10 YEAR AGE GROUPS IN B'DOS, T'DAD, USVI, AND PR
***************************************************************************************************************************************************
**import dataset (men)
import excel "`datapath'\version02\1-input\wpp2019women.xlsx", sheet("Sheet1") firstrow clear

**label as women
gen gender=2

**get rid of unneccessary variables
drop Index Variant Notes Type Parentcode I J K L M N O P
rename Referencedateasof1July year

**generate numbers of women in 10 yr groups
gen grp1 = Q + R
label variable grp1 "Number aged 40-49 (1000s)"
gen grp2 = S + T
label variable grp2 "Number aged 50-59 (1000s)"
gen grp3 = U + V
label variable grp3 "Number aged 60-69 (1000s)"
gen grp4 = W + X + Y + Z + AA + AB + AC 
label variable grp4 "Number aged 70+ (1000s)"

save "`datapath'\version02\1-input\WPPwomen.dta", replace 

***************************************************************************************************************************************************
** combine men and women
***************************************************************************************************************************************************
append using "`datapath'\version02\1-input\WPPmen.dta"
drop Q R S T U V W X Y Z AA AB AC
label define gender 1 "Men" 2 "Women"
label values gender gender

*generate total population by gender
egen popgender = rowtotal (grp1 grp2 grp3 grp4)
label variable popgender "Total population 40+"
sort Countrycode year gender

tempfile pop40

preserve
    collapse (sum) popgender, by (Countrycode year)
    rename popgender totpop 
    save `pop40', replace
restore

merge m:1 Countrycode year using `pop40'
drop _merge

*generate proportions in each age group
gen prop40 = grp1/totpop
gen prop50 = grp2/totpop
gen prop60 = grp3/totpop
gen prop70 = grp4/totpop
label variable prop40 "prop aged 40-49"
label variable prop50 "prop aged 50-59"
label variable prop60 "prop aged 60-69"
label variable prop70 "prop aged 70+"

drop grp1 grp2 grp3 grp4 popgender

rename Countrycode cid





*************************************************************************************************************************************
**  GENERATE WEIGHTS
*************************************************************************************************************************************
label define cid 52 "Barbados" 630 "Puerto Rico" 780 "Trinidad" 850 "USVI"
label values cid cid
drop Regionsubregioncountryorar

reshape long prop, i (cid year gender) j (agegr)
rename prop prPOP
label variable prPOP "Proportion population"
label variable totpop "total population"
label variable cid "country ID"


/* from ECHORN BARBADOS sample: 
age_grp	male	% respondents
40-49	Male	7.1
50-59	Male	9.1
60-69	Male	9.2
70+	    Male	4.9
40-49	Female	17.4
50-59	Female	25.2
60-69	Female	17.7
70+	    Female	9.4   */


gen percsample=.
*men
replace percsample = 7.1 if cid==52 & gender==1 & agegr==40 
replace percsample = 9.1 if cid==52 & gender==1 & agegr==50 
replace percsample = 9.2 if cid==52 & gender==1 & agegr==60 
replace percsample = 4.9 if cid==52 & gender==1 & agegr==70 
*women
replace percsample = 17.4 if cid==52 & gender==2 & agegr==40 
replace percsample = 25.2 if cid==52 & gender==2 & agegr==50 
replace percsample = 17.7 if cid==52 & gender==2 & agegr==60 
replace percsample = 9.4 if cid==52 & gender==2 & agegr==70 


/* From ECHORN PR sample
age_grp	male	% respondents
40-49	Male	7.9
50-59	Male	12.2
60-69	Male	8.8
70+	    Male	5.1
40-49	Female	13.6
50-59	Female	24.1
60-69	Female	17.8
70+	    Female	10.5 */

*men
replace percsample = 7.9 if cid==630 & gender==1 & agegr==40 
replace percsample = 12.2 if cid==630 & gender==1 & agegr==50 
replace percsample = 8.8 if cid==630 & gender==1 & agegr==60 
replace percsample = 5.1 if cid==630 & gender==1 & agegr==70 
*women
replace percsample = 13.3 if cid==630 & gender==2 & agegr==40 
replace percsample = 24.1 if cid==630 & gender==2 & agegr==50 
replace percsample = 17.8 if cid==630 & gender==2 & agegr==60 
replace percsample = 10.5 if cid==630 & gender==2 & agegr==70 


/* From ECHORN T'DAD sample
age_grp	male	% respondents
40-49	Male	11.2
50-59	Male	13.9
60-69	Male	8.7
70+	    Male	4.8
40-49	Female	17.9
50-59	Female	21.4
60-69	Female	15.4
70+	    Female	6.8   */

*men
replace percsample = 11.2 if cid==780 & gender==1 & agegr==40 
replace percsample = 13.9 if cid==780 & gender==1 & agegr==50 
replace percsample = 8.7 if cid==780 & gender==1 & agegr==60 
replace percsample = 4.8 if cid==780 & gender==1 & agegr==70 
*women
replace percsample = 17.9 if cid==780 & gender==2 & agegr==40 
replace percsample = 21.4 if cid==780 & gender==2 & agegr==50 
replace percsample = 15.4 if cid==780 & gender==2 & agegr==60 
replace percsample = 6.8 if cid==780 & gender==2 & agegr==70 



/* From ECHORN USVI sample
age_grp	male	% respondents
40-49	Male	8.8
50-59	Male	15.9
60-69	Male	11.1
70+	    Male	4.0
40-49	Female	16.2
50-59	Female	20.1
60-69	Female	17.3
70+	    Female	6.8   */

*men
replace percsample = 8.8 if cid==850 & gender==1 & agegr==40 
replace percsample = 15.9 if cid==850 & gender==1 & agegr==50 
replace percsample = 11.1 if cid==850 & gender==1 & agegr==60 
replace percsample = 4.0 if cid==850 & gender==1 & agegr==70 
*women
replace percsample = 16.2 if cid==850 & gender==2 & agegr==40 
replace percsample = 20.1 if cid==850 & gender==2 & agegr==50 
replace percsample = 17.3 if cid==850 & gender==2 & agegr==60 
replace percsample = 6.8 if cid==850 & gender==2 & agegr==70


**GENERATE WEIGHT 
gen wt =. 
replace wt=prPOP/(percsample/100)
drop totpop prPOP percsample
reshape wide wt, i (cid gender agegr) j (year)

*changing names and coding to match ECHORN data file
rename cid siteid
recode siteid 850=1 630=2 52=3 780=4
label define siteid 1 "USVI" 2 "PR" 3 "Bdos" 4 "Tdad"
label values siteid siteid
recode agegr 40=1 50=2 60=3 70=4
label define agegr 1 "40-49" 2 "50-59" 3 "60-69" 4 "70+"
label values agegr agegr


***Save weights data file
save "`datapath'\version02\2-working\ECHORN_weights", replace

