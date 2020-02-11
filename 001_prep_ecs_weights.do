**  DO-FILE METADATA
//  algorithm name						ecs_weights_001
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
cap log using "`logpath'\ecs_weights_001", replace

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

***Save population proportions dataset
save "`datapath'\version02\2-working\ECHORN_popprops", replace



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
**BARBADOS
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

**PUERTO RICO
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

**T'DAD
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

**USVI
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
gen un =. 
replace un=prPOP/(percsample/100)
drop totpop prPOP percsample
reshape wide un, i (cid gender agegr) j (year)

*add in weight based on US census bureau 2015
gen UScb2015=.

**BARBADOS
*men
replace UScb2015 = 2.333 if cid==52 & gender==1 & agegr==40 
replace UScb2015 = 1.655 if cid==52 & gender==1 & agegr==50 
replace UScb2015 = 0.995 if cid==52 & gender==1 & agegr==60 
replace UScb2015 = 1.164 if cid==52 & gender==1 & agegr==70 
*women
replace UScb2015 = 0.96 if cid==52 & gender==2 & agegr==40 
replace UScb2015 = 0.642 if cid==52 & gender==2 & agegr==50 
replace UScb2015 = 0.630 if cid==52 & gender==2 & agegr==60 
replace UScb2015 = 1.000 if cid==52 & gender==2 & agegr==70 

**PUERTO RICO
*men
replace UScb2015 = 1.535 if cid==630 & gender==1 & agegr==40 
replace UScb2015 = 0.996 if cid==630 & gender==1 & agegr==50 
replace UScb2015 = 1.222 if cid==630 & gender==1 & agegr==60 
replace UScb2015 = 2.038 if cid==630 & gender==1 & agegr==70 
*women
replace UScb2015 = 0.985 if cid==630 & gender==2 & agegr==40 
replace UScb2015 = 0.589 if cid==630 & gender==2 & agegr==50 
replace UScb2015 = 0.727 if cid==630 & gender==2 & agegr==60 
replace UScb2015 = 1.341 if cid==630 & gender==2 & agegr==70 

**T'DAD
*men
replace UScb2015 = 1.432 if cid==780 & gender==1 & agegr==40 
replace UScb2015 = 1.250 if cid==780 & gender==1 & agegr==50 
replace UScb2015 = 1.161 if cid==780 & gender==1 & agegr==60 
replace UScb2015 = 1.203 if cid==780 & gender==1 & agegr==70 
*women
replace UScb2015 = 0.817 if cid==780 & gender==2 & agegr==40 
replace UScb2015 = 0.792 if cid==780 & gender==2 & agegr==50 
replace UScb2015 = 0.693 if cid==780 & gender==2 & agegr==60 
replace UScb2015 = 1.258 if cid==780 & gender==2 & agegr==70 

**USVI
*men
replace UScb2015 = 1.385 if cid==850 & gender==1 & agegr==40 
replace UScb2015 = 0.864 if cid==850 & gender==1 & agegr==50 
replace UScb2015 = 1.062 if cid==850 & gender==1 & agegr==60 
replace UScb2015 = 2.314 if cid==850 & gender==1 & agegr==70 
*women
replace UScb2015 = 0.850 if cid==850 & gender==2 & agegr==40 
replace UScb2015 = 0.745 if cid==850 & gender==2 & agegr==50 
replace UScb2015 = 0.791 if cid==850 & gender==2 & agegr==60 
replace UScb2015 = 1.595 if cid==850 & gender==2 & agegr==70
*/

*add in weight based on US census bureau 2010
gen UScb2010=.

**BARBADOS
*men
replace UScb2010 = 2.602 if cid==52 & gender==1 & agegr==40 
replace UScb2010 = 1.621 if cid==52 & gender==1 & agegr==50 
replace UScb2010 = 0.799 if cid==52 & gender==1 & agegr==60 
replace UScb2010 = 1.123 if cid==52 & gender==1 & agegr==70 
*women
replace UScb2010 = 1.083 if cid==52 & gender==2 & agegr==40 
replace UScb2010 = 0.652 if cid==52 & gender==2 & agegr==50 
replace UScb2010 = 0.521 if cid==52 & gender==2 & agegr==60 
replace UScb2010 = 0.993 if cid==52 & gender==2 & agegr==70 

**PUERTO RICO
*men
replace UScb2010 = 1.694 if cid==630 & gender==1 & agegr==40 
replace UScb2010 = 1.017 if cid==630 & gender==1 & agegr==50 
replace UScb2010 = 1.194 if cid==630 & gender==1 & agegr==60 
replace UScb2010 = 1.811 if cid==630 & gender==1 & agegr==70 
*women
replace UScb2010 = 1.108 if cid==630 & gender==2 & agegr==40 
replace UScb2010 = 0.605 if cid==630 & gender==2 & agegr==50 
replace UScb2010 = 0.702 if cid==630 & gender==2 & agegr==60 
replace UScb2010 = 1.174 if cid==630 & gender==2 & agegr==70 

**T'DAD
*men
replace UScb2010 = 1.738 if cid==780 & gender==1 & agegr==40 
replace UScb2010 = 1.126 if cid==780 & gender==1 & agegr==50 
replace UScb2010 = 1.013 if cid==780 & gender==1 & agegr==60 
replace UScb2010 = 1.081 if cid==780 & gender==1 & agegr==70 
*women
replace UScb2010 = 1.030 if cid==780 & gender==2 & agegr==40 
replace UScb2010 = 0.720 if cid==780 & gender==2 & agegr==50 
replace UScb2010 = 0.611 if cid==780 & gender==2 & agegr==60 
replace UScb2010 = 1.135 if cid==780 & gender==2 & agegr==70 

**USVI
*men
replace UScb2010 = 1.883 if cid==850 & gender==1 & agegr==40 
replace UScb2010 = 1.021 if cid==850 & gender==1 & agegr==50 
replace UScb2010 = 1.328 if cid==850 & gender==1 & agegr==60 
replace UScb2010 = 2.054 if cid==850 & gender==1 & agegr==70 
*women
replace UScb2010 = 1.144 if cid==850 & gender==2 & agegr==40 
replace UScb2010 = 0.908 if cid==850 & gender==2 & agegr==50 
replace UScb2010 = 0.918 if cid==850 & gender==2 & agegr==60 
replace UScb2010 = 1.433 if cid==850 & gender==2 & agegr==70


label variable UScb2010 "US census bureau 2010"
label variable UScb2015 "US census bureau 2015"

***************************************************************************************************************************
*changing names and coding to match ECHORN data file
rename cid siteid
recode siteid 850=1 630=2 52=3 780=4
label define siteid 1 "USVI" 2 "PR" 3 "Bdos" 4 "Tdad"
label values siteid siteid
recode agegr 40=1 50=2 60=3 70=4
label define agegr 1 "40-49" 2 "50-59" 3 "60-69" 4 "70+"
label values agegr agegr

***Save UN weights dataset
save "`datapath'\version02\2-working\ECHORN_weights", replace

 
/*************************************************************************************************************************************
**  CREATE WEIGHTS BASED ON US CENSUS BUREAU INTERNATIONAL DATABASE
*************************************************************************************************************************************
import excel "`datapath'\version02\1-input\US2010_2015.xls", sheet("Sheet1") firstrow clear
gen siteid=.
replace siteid=1 if Country=="Virgin Islands, U.S."
replace siteid=2 if Country=="Puerto Rico"
replace siteid=3 if Country=="Barbados"
replace siteid=4 if Country=="Trinidad and Tobago"
label define siteid 1 "USVI" 2 "PR" 3 "Bdos" 4 "Tdad"
label values siteid siteid
*get rid of unnecessary variables
drop PercentBothSexes PercentMale PercentFemale SexRatio Country
order siteid, before(Year)
*sort out age
encode Age, gen(Age5)
drop Age
