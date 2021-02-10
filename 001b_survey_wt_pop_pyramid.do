
clear
capture log close
cls


**  GENERAL DO-FILE COMMENTS
**  Program:		001b_survey_wt_pop_pyramid.do
**  Project:      	ECHORN (P-ECS)
**	Sub-Project:	Survey Weight Estimation
**  Analyst:		Kern Rocke
**	Date Created:	01/10/2021
**	Date Modified: 	09/02/2021
**  Algorithm Task: Desing of Population Pyramids (Unadjusted & Survey Weight Adjusted)


** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150


*Setting working directory (Select the appropriate datapath for your system)

*-------------------------------------------------------------------------------
*WINDOWS OS (Ian; Christina; Data Group work stations)
*local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS (Alternative - Kern; Stephanie)
*local datapath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS 
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/DataGroup - repo_data/data_p120"

*-------------------------------------------------------------------------------

/*
This do file will do the following
1) Using IDB population estimates create reference population proportions of ECHORN study sites
2) Develop survey weights using sample and reference population estimates
3) Compare and contrast unadjusted population pyramids
*/

*US Census Population Estimates for Trinidad, Barbados, Puerto Rico, USVI (IDB estimates)
{
*-------------------------------------------------------------------------------
*Barbados
import delimited "`datapath'/version02/1-input/BB_US.csv", clear

gen age = real(regexs(1)) if regexm(agegroupyearsofage,"([0-9]+)")
drop agegroupyearsofage
gen agegrp = .
replace agegr = 40 if age>=40 & age<50 & age!=.
replace agegr = 50 if age>=50 & age<60 & age!=.
replace agegr = 60 if age>=60 & age<70 & age!=.
replace agegr = 70 if age>=70 & age!=.

rename malepopulation pop1
rename femalepopulation pop2
tabstat pop1 pop2, stat(sum)

keep if agegr !=.


reshape long pop, i(age) j(gender)
collapse (sum) pop, by(agegrp gender)
drop if agegr == .
gen totpop = .
replace totpop = 143013 if gender == 1
replace totpop = 152865 if gender == 2

gen pop_us = .
replace pop_us = pop/totpop 
gen cid = 52

*Save dataset
save "`datapath'/version02/1-input/BB_US.dta", replace

*-------------------------------------------------------------------------------
*Trinidad
import delimited "`datapath'/version02/1-input/TT_US.csv", clear

gen age = real(regexs(1)) if regexm(agegroupyearsofage,"([0-9]+)")
drop agegroupyearsofage
gen agegrp = .
replace agegr = 40 if age>=40 & age<50 & age!=.
replace agegr = 50 if age>=50 & age<60 & age!=.
replace agegr = 60 if age>=60 & age<70 & age!=.
replace agegr = 70 if age>=70 & age!=.

rename malepopulation pop1
rename femalepopulation pop2
tabstat pop1 pop2, stat(sum)

keep if agegr !=.

reshape long pop, i(age) j(gender)
collapse (sum) pop, by(agegrp gender)
drop if agegr == .
gen totpop = .
replace totpop = 624387 if gender == 1
replace totpop = 609458 if gender == 2

gen pop_us = .
replace pop_us = pop/totpop 
gen cid = 780

*Save dataset
save "`datapath'/version02/1-input/TT_US.dta", replace

*-------------------------------------------------------------------------------
*Puerto Rico
import delimited "`datapath'/version02/1-input/PR_US.csv", clear

gen age = real(regexs(1)) if regexm(agegroupyearsofage,"([0-9]+)")
drop agegroupyearsofage
gen agegrp = .
replace agegr = 40 if age>=40 & age<50 & age!=.
replace agegr = 50 if age>=50 & age<60 & age!=.
replace agegr = 60 if age>=60 & age<70 & age!=.
replace agegr = 70 if age>=70 & age!=.

rename malepopulation pop1
rename femalepopulation pop2
tabstat pop1 pop2, stat(sum)

keep if agegr !=.

reshape long pop, i(age) j(gender)
collapse (sum) pop, by(agegrp gender)
drop if agegr == .
gen totpop = .
replace totpop = 1656173 if gender == 1
replace totpop = 1816685 if gender == 2

gen pop_us = .
replace pop_us = pop/totpop 
gen cid = 630

*Save dataset
save "`datapath'/version02/1-input/PR_US.dta", replace

*-------------------------------------------------------------------------------
*USVI
import delimited "`datapath'/version02/1-input/USVI_US.csv", clear

gen age = real(regexs(1)) if regexm(agegroupyearsofage,"([0-9]+)")
drop agegroupyearsofage
gen agegrp = .
replace agegr = 40 if age>=40 & age<50 & age!=.
replace agegr = 50 if age>=50 & age<60 & age!=.
replace agegr = 60 if age>=60 & age<70 & age!=.
replace agegr = 70 if age>=70 & age!=.

rename malepopulation pop1
rename femalepopulation pop2
tabstat pop1 pop2, stat(sum)

keep if agegr !=.

reshape long pop, i(age) j(gender)
collapse (sum) pop, by(agegrp gender)
drop if agegr == .
gen totpop = .
replace totpop = 51531 if gender == 1
replace totpop = 56181 if gender == 2

gen pop_us = .
replace pop_us = pop/totpop 
gen cid = 850

*Save dataset
save "`datapath'/version02/1-input/USVI_US.dta", replace

*-------------------------------------------------------------------------------
*Add PR data 
append using "`datapath'/version02/1-input/PR_US.dta"

*Add TT data
append using "`datapath'/version02/1-input/TT_US.dta"

*Add BB data
append using "`datapath'/version02/1-input/BB_US.dta"

*Minor cleaning
sort cid agegr gender
keep pop_us cid
egen id = seq()
order id 

*Save data
save "`datapath'/version02/1-input/combine_US.dta", replace

*Clear output and dataset for further output
cls
clear

}




*Using WPP code developed by CHowitt
{
***************************************************************************************************************************************************
** PROPORTIONS OF MEN IN 10 YEAR AGE GROUPS IN B'DOS, T'DAD, USVI, AND PR
***************************************************************************************************************************************************
**import dataset (men)
import excel "`datapath'/version02/1-input/wpp2019men.xlsx", sheet("Sheet1") firstrow clear

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

save "`datapath'/version02/1-input/WPPmen.dta", replace 

***************************************************************************************************************************************************
** PROPORTIONS OF WOMEN IN 10 YEAR AGE GROUPS IN B'DOS, T'DAD, USVI, AND PR
***************************************************************************************************************************************************
**import dataset (men)
import excel "`datapath'/version02/1-input/wpp2019women.xlsx", sheet("Sheet1") firstrow clear

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

save "`datapath'/version02/1-input/WPPwomen.dta", replace 

***************************************************************************************************************************************************
** combine men and women
***************************************************************************************************************************************************
append using "`datapath'/version02/1-input/WPPmen.dta"
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

*drop grp1 grp2 grp3 grp4 popgender

rename Countrycode cid

keep if year ==2015
keep if cid == 780

***Save population proportions dataset
save "`datapath'/version02/2-working/ECHORN_popprops", replace

*-------------------------------------------------------------------------------

*Load in Sample ECHORN data for population estimates
use "`datapath'/version03/2-working/survey_wave1_weighted1.dta", clear

keep key siteid gender partage agegr
gen pop = 1
collapse (sum) pop, by(agegr gender siteid)


gen sp1 = .
replace sp1 = 353 if siteid == 1
replace sp1 = 771 if siteid == 2
replace sp1 = 1008 if siteid == 3
replace sp1 = 829 if siteid == 4

sort siteid agegr

replace agegr = 40 if agegr == 1
replace agegr = 50 if agegr == 2
replace agegr = 60 if agegr == 3
replace agegr = 70 if agegr == 4

gen cid =.
replace cid = 52 if siteid ==3
replace cid = 850 if siteid ==1
replace cid = 780 if siteid ==4
replace cid = 630 if siteid ==2
*-------------------------------------------------------------------------------
*Percentage of sample population respondents

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

*-------------------------------------------------------------------------------
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

*-------------------------------------------------------------------------------
/*
gen cid = .
replace cid = 850 if siteid == 1
replace cid = 630 if siteid == 2
replace cid = 52 if siteid == 3
replace cid = 780 if siteid == 4
*/


gen pop_WPP = .
*USVI
*men
replace pop_WPP = .11754808 if cid==850 & gender==1 & agegr==40
replace pop_WPP = .1339497 if cid==850 & gender==1 & agegr==50
replace pop_WPP = .11821376 if cid==850 & gender==1 & agegr==60
replace pop_WPP = .09310281 if cid==850 & gender==1 & agegr==70
*women
replace pop_WPP = .13341346 if cid==850 & gender==2 & agegr==40
replace pop_WPP = .14779955 if cid==850 & gender==2 & agegr==50
replace pop_WPP = .13823964 if cid==850 & gender==2 & agegr==60
replace pop_WPP = .11773299 if cid==850 & gender==2 & agegr==70

*Puerto Rico
*men
replace pop_WPP = .13288461 if cid==630 & gender==1 & agegr==40 
replace pop_WPP = .12149896 if cid==630 & gender==1 & agegr==50 
replace pop_WPP = .09618288 if cid==630 & gender==1 & agegr==60 
replace pop_WPP = .09519945 if cid==630 & gender==1 & agegr==70 
*women
replace pop_WPP = .15094931 if cid==630 & gender==2 & agegr==40 
replace pop_WPP = .14482258 if cid==630 & gender==2 & agegr==50 
replace pop_WPP = .12307657 if cid==630 & gender==2 & agegr==60 
replace pop_WPP = .13538566 if cid==630 & gender==2 & agegr==70 

*Barbados
*men
replace pop_WPP = .14062333 if cid==52 & gender==1 & agegr==40 
replace pop_WPP = .13616697 if cid==52 & gender==1 & agegr==50 
replace pop_WPP = .09670778 if cid==52 & gender==1 & agegr==60 
replace pop_WPP = .0876367 if cid==52 & gender==1 & agegr==70 
*women
replace pop_WPP = .1517534 if cid==52 & gender==2 & agegr==40 
replace pop_WPP = .15509385 if cid==52 & gender==2 & agegr==50 
replace pop_WPP = .11050158 if cid==52 & gender==2 & agegr==60 
replace pop_WPP = .12151646 if cid==52 & gender==2 & agegr==70 

*Trinidad
*men
replace pop_WPP = .15850355 if cid==780 & gender==1 & agegr==40 
replace pop_WPP = .15787436 if cid==780 & gender==1 & agegr==50 
replace pop_WPP = .10095318 if cid==780 & gender==1 & agegr==60 
replace pop_WPP = .06294725 if cid==780 & gender==1 & agegr==70 
*women
replace pop_WPP = .16190077 if cid==780 & gender==2 & agegr==40 
replace pop_WPP = .16318627 if cid==780 & gender==2 & agegr==50 
replace pop_WPP = .10851603 if cid==780 & gender==2 & agegr==60 
replace pop_WPP = .08611855 if cid==780 & gender==2 & agegr==70 


*Age Group Labels
label define agegr 40"40-49" 50"50-59" 60"60-69" 70"70+", modify
label value agegr agegr

*Minor cleaning
sort cid agegr gender
egen id = seq()
order id 

*Merge in US census bureau estimates (IDB)
merge 1:1 id using "`datapath'/version02/1-input/combine_US.dta", nogenerate

*Remove ID
drop id

/*
gen pop_ecs = pop/sp1
gen weight = pop_us/pop_ecs*/
}
*-------------------------------------------------------------------------------
*Creating Unadjusted Population Pyramids for ECHORN Study sites
{
*USVI
preserve
keep if siteid == 1

reshape wide pop pop_us pop_WPP percsample UScb2015 UScb2010, i(agegr) j(gender)
gen pop1_per = pop1/sp1 // Sample Male
gen pop2_per = pop2/sp1 // Sample Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Unadjusted", c(black))
	name(USVI_unadjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Puerto Rico
preserve
keep if siteid == 2

reshape wide pop pop_us pop_WPP percsample UScb2015 UScb2010, i(agegr) j(gender)
gen pop1_per = pop1/sp1 // Sample Male
gen pop2_per = pop2/sp1 // Sample Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Unadjusted", c(black))
	name(PR_unadjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Barbados
preserve
keep if siteid == 3

reshape wide pop pop_us pop_WPP percsample UScb2015 UScb2010, i(agegr) j(gender)
gen pop1_per = pop1/sp1 // Sample Male
gen pop2_per = pop2/sp1 // Sample Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Unadjusted", c(black))
	name(BB_unadjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Trinidad
preserve
keep if siteid == 4

reshape wide pop pop_us pop_WPP percsample UScb2015 UScb2010, i(agegr) j(gender)
gen pop1_per = pop1/sp1 // Sample Male
gen pop2_per = pop2/sp1 // Sample Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Unadjusted", c(black))
	name(TT_unadjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore
}
*-------------------------------------------------------------------------------
*Survey Weighted Analysis

*Set dataset as complex survey using previously derived weights
svyset _n [pweight=weight], vce(linearized) singleunit(missing)
svy linearized : total pop, over(siteid agegr gender)

*Using population estimates produced above create new variable with new estimates
gen pop_adjust = .
*USVI
replace pop_adjust = 45.13627 if cid == 850 & gender == 1 & agegr == 40
replace pop_adjust = 46.79146 if cid == 850 & gender == 2 & agegr == 40
replace pop_adjust = 50.93843 if cid == 850 & gender == 1 & agegr == 50
replace pop_adjust = 51.05151 if cid == 850 & gender == 2 & agegr == 50
replace pop_adjust = 43.67032 if cid == 850 & gender == 1 & agegr == 60
replace pop_adjust = 46.67207 if cid == 850 & gender == 2 & agegr == 60
replace pop_adjust = 34.29233 if cid == 850 & gender == 1 & agegr == 70
replace pop_adjust = 36.93302 if cid == 850 & gender == 2 & agegr == 70
*Puerto Rico
replace pop_adjust = 98.03386 if cid == 630 & gender == 1 & agegr == 40
replace pop_adjust = 98.80188 if cid == 630 & gender == 2 & agegr == 40
replace pop_adjust = 97.99755 if cid == 630 & gender == 1 & agegr == 50
replace pop_adjust = 104.6938 if cid == 630 & gender == 2 & agegr == 50
replace pop_adjust = 87.20049 if cid == 630 & gender == 1 & agegr == 60
replace pop_adjust = 95.31247 if cid == 630 & gender == 2 & agegr == 60
replace pop_adjust = 83.59821 if cid == 630 & gender == 1 & agegr == 70
replace pop_adjust = 103.6252 if cid == 630 & gender == 2 & agegr == 70
*Barbados
replace pop_adjust = 164.3877 if cid == 52 & gender == 1 & agegr == 40
replace pop_adjust = 156.2 if cid == 52 & gender == 2 & agegr == 40
replace pop_adjust = 150.1713 if cid == 52 & gender == 1 & agegr == 50
replace pop_adjust = 150.14 if cid == 52 & gender == 2 & agegr == 50
replace pop_adjust = 91.28971 if cid == 52 & gender == 1 & agegr == 60
replace pop_adjust = 102.3133 if cid == 52 & gender == 2 & agegr == 60
replace pop_adjust = 56.01997 if cid == 52 & gender == 1 & agegr == 70
replace pop_adjust = 86.14472 if cid == 52 & gender == 2 & agegr == 70
*Trinidad
replace pop_adjust = 111.7421 if cid == 780 & gender == 1 & agegr == 40
replace pop_adjust = 105.1916 if cid == 780 & gender == 2 & agegr == 40
replace pop_adjust = 121.1303 if cid == 780 & gender == 1 & agegr == 50
replace pop_adjust = 121.158 if cid == 780 & gender == 2 & agegr == 50
replace pop_adjust = 70.65898 if cid == 780 & gender == 1 & agegr == 60
replace pop_adjust = 76.31678 if cid == 780 & gender == 2 & agegr == 60
replace pop_adjust = 40.633 if cid == 780 & gender == 1 & agegr == 70
replace pop_adjust = 60.85918 if cid == 780 & gender == 2 & agegr == 70


*-------------------------------------------------------------------------------
*Creating Survey Weight adjusted Population Pyramids for ECHORN Study sites
{
*USVI
preserve
keep if siteid == 1

reshape wide pop pop_adjust pop_us pop_WPP percsample UScb2015 ///
		UScb2010, i(agegr) j(gender)
		
gen pop1_per = pop_adjust1/sp1 // Adjusted Male
gen pop2_per = pop_adjust2/sp1 // Adjusted Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Survey Weight Adjusted", c(black))
	name(USVI_adjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Puerto Rico
preserve
keep if siteid == 2

reshape wide pop pop_adjust pop_us pop_WPP percsample UScb2015 ///
		UScb2010, i(agegr) j(gender)
		
gen pop1_per = pop_adjust1/sp1 // Adjusted Male
gen pop2_per = pop_adjust2/sp1 // Adjusted Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Survey Weight Adjusted", c(black))
	name(PR_adjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Barbados
preserve
keep if siteid == 3

reshape wide pop pop_adjust pop_us pop_WPP percsample UScb2015 ///
		UScb2010, i(agegr) j(gender)
		
gen pop1_per = pop_adjust1/sp1 // Adjusted Male
gen pop2_per = pop_adjust2/sp1 // Adjusted Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Survey Weight Adjusted", c(black))
	name(BB_adjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Trinidad
preserve
keep if siteid == 4

reshape wide pop pop_adjust pop_us pop_WPP percsample UScb2015 ///
		UScb2010, i(agegr) j(gender)
		
gen pop1_per = pop_adjust1/sp1 // Adjusted Male
gen pop2_per = pop_adjust2/sp1 // Adjusted Female


replace pop2_per = -pop2_per
replace pop_WPP2 = -pop_WPP2
replace pop_us2 = -pop_us2

gen zero = 0

/*
replace percsample2 = -percsample2
replace UScb20152 = -UScb20152
replace UScb20102 = -UScb20102*/

#delimit ;
	twoway 
	/// women
	(bar pop2_per agegr, horizontal lw(thin) lc(gs11) fc("27 158 119") fintensity(30) barwidth(10) lcolor(gs4) lwidth(vthin)) ||
	/// men 
	(bar pop1_per agegr, horizontal lw(thin) lc(gs11) fc("217 95 2") fintensity(30) barwidth(10) lcolor(gs4)lwidth(vthin)) ||
	/// US Census Estimates
	(connect agegr pop_us1, symbol(T) mc(gs0) lc(gs0))
	(connect agegr pop_us2, symbol(T) mc(gs0) lc(gs0))

	(sc agegr zero, mlabel(agegr) mlabcolor(black) msymbol(i))
	, 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(fcolor(gs16) lcolor(black) lwidth(thin) lpattern(solid)) ysize(3)

	title("Survey Weight Adjusted", c(black))
	name(TT_adjusted, replace)
	xtitle("Percentage of Residents within 10-year Age Groups", size(small)) ytitle("")
	plotregion(style(none))
	ysca(noline) ylabel(none)
	xsca(noline titlegap(0.5))
	xlabel( 0.05 "5" 0.10 "10" 0.15 "15" 0.20 "20" 0 "0" -0.05 "5" -0.10 "10" -0.15 "15" -0.20 "20", tlength(0) 
	nogrid )
	legend(size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(4)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2 3 )
	lab(1 "Females") 
	lab(2 "Males")
	lab(3 "US Census 2015")
	);
#delimit cr

restore

*-------------------------------------------------------------------------------
}

*Combine unadjusted and adjusted graphs
{
*USVI
#delimit;
graph combine USVI_unadjusted USVI_adjusted, 
			name(USVI) title(" US Virgin Islands", c(black))
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) ysize(3)
			plotregion(style(none))
			
			caption("Source: Adult ECHORN (Wave 1), US 2015 Census Bureau (Survey Weights), 2015 US Census (IDB Estimates)", span size(vsmall))
	;
#delimit cr

*Export graph to encrypted location
graph export "`datapath'/version02/3-output/USVI_ECS_pyramid.png", as(png) replace
			
*Puerto Rico
#delimit;
graph combine PR_unadjusted PR_adjusted, 
			name(PR) title("Puerto Rico", c(black))
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) ysize(3)
			plotregion(style(none))
			
			caption("Source: Adult ECHORN (Wave 1), US 2015 Census Bureau (Survey Weights), 2015 US Census (IDB Estimates)", span size(vsmall))
	;
#delimit cr

*Export graph to encrypted location
graph export "`datapath'/version02/3-output/PR_ECS_pyramid.png", as(png) replace

*Barbados
#delimit;
graph combine BB_unadjusted BB_adjusted, 
			name(BB) title("Barbados", c(black))
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) ysize(3)
			plotregion(style(none))
			
			caption("Source: Adult ECHORN (Wave 1), US 2015 Census Bureau (Survey Weights), 2015 US Census (IDB Estimates)", span size(vsmall))
	;
#delimit cr

*Export graph to encrypted location
graph export "`datapath'/version02/3-output/BB_ECS_pyramid.png", as(png) replace

*Trinidad
#delimit;
graph combine TT_unadjusted TT_adjusted, 
			name(TT, replace) title("Trinidad and Tobago", c(black))
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) ysize(3)		
			plotregion(style(none))
			
			caption("Source: Adult ECHORN (Wave 1), US 2015 Census Bureau (Survey Weights), 2015 US Census (IDB Estimates)", span size(vsmall))
	;
#delimit cr

*Export graph to encrypted location
graph export "`datapath'/version02/3-output/TT_ECS_pyramid.png", as(png) replace
}


*Remove old graphs
graph drop USVI_unadjusted USVI_adjusted PR_unadjusted PR_adjusted ///
			BB_unadjusted BB_adjusted TT_unadjusted TT_adjusted
*-------------------------------------------------------------------------------

***************************END**************************************************
