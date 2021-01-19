
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		ecs_active_neighbourhood.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Active Commuting and Perceived Neighbourhood
	**  Analyst:		Kern Rocke
	**	Date Created:	17/08/2020
	**	Date Modified:  10/09/2020
	**  Algorithm Task: Analyzing relationship between perceived neighbourhood and active commuting.

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)

*-------------------------------------------------------------------------------
** Dataset to encrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local datapath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/DataGroup - repo_data/data_p120"

*-------------------------------------------------------------------------------

** Logfiles to unencrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local logpath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local logpath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local logpath "/Volumes/Secomba/kernrocke/Boxcryptor/DataGroup - repo_data/data_p120"

*-------------------------------------------------------------------------------

**Aggregated output path

*WINDOWS OS - Ian & Christina (Data Group) 
*local outputpath "The University of the West Indies/DataGroup - PROJECT_p120"

*WINDOWS OS - Kern & Stephanie
*local outputpath "X:/The UWI - Cave Hill Campus/DataGroup - PROJECT_p120"

*MAC OS - Kern
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/DataGroup - repo_data/data_p120"	
	
*-------------------------------------------------------------------------------

*Open log file to store results
log using "`logpath'/version03/3-output/ecs_active_neighbourhood.log",  replace

*-------------------------------------------------------------------------------

*Load in data from encrypted location
use "`datapath'/version03/2-working/survey_wave1_weighted.dta", clear
	
*-------------------------------------------------------------------------------

*Merge data from end result of 003d_ecs_analysis_wave1.do
merge 1:1 key "`datapath'/version03/02-working/wave1_framingham_cvdrisk_prepared", nogenerate

*Keep neccessary variables needed for analysis
keep key siteid gender partage educ D7 D96 bp_diastolic bp_systolic///
	 totMETmin mpdT mpwT TMET inactive MET_grp///
	 SE12 SE13 SE14 SE15 SE16 SE17 SE18 SE19 SE20 SE21 SE22 SE23 SE24 ///
	 nolabrisk10 nolabrisk10ca bmi ow ob ob4 percsafe hood_score ///
	 primary_plus second_plus tertiary prof semi_prof non_prof occ
	 
*-------------------------------------------------------------------------------

*Create tertiles for active commuting

xtile TMET_3 = TMET, nq(3)
label var TMET_3 "Active Commuting in Tertiles"

*-------------------------------------------------------------------------------

*Perceived Neighbourhood Characteristics (Jackson Heart Study)

foreach x of numlist 12 13 15 17 {
gen SE_`x' = .
replace SE_`x' = 1 if SE`x' == 1 | SE`x' == 2
replace SE_`x' = 0 if SE`x' == 3 | SE`x' == 4

label define SE_`x' 0"Positive" 1"Negative"
label value SE_`x' SE_`x'

}

foreach x of numlist 14 16 {
gen SE_`x' = .
replace SE_`x' = 0 if SE`x' == 1 | SE`x' == 2
replace SE_`x' = 1 if SE`x' == 3 | SE`x' == 4

label define SE_`x' 0"Positive" 1"Negative"
label value SE_`x' SE_`x'

}

foreach x of numlist 18 19 20 21 22 23 24{
gen SE_`x' = .
replace SE_`x' = 0 if SE`x' == 0
replace SE_`x' = 1 if SE`x' == 1
replace SE_`x' = 1 if SE`x' == 2 | SE`x' == 3

label define SE_`x' 0"No problem" 1"Problem"
label value SE_`x' SE_`x'

}

*Labelling perceived neighbourhood variables

label var SE_12 "I live in a close knit neighbourhood"
label var SE_13 "People around this neighbourhood are willling to help their neighbours"
label var SE_14 "People in my neighbourhood generally don't get along with each other"
label var SE_15 "People in this neighbourhood can be trusted"
label var SE_16 "People in this neighbourhood do not share my values"
label var SE_17 "I feel safe from crime in this neighbourhood"
label var SE_18 "Excessive noise problem"
label var SE_19 "Heavy traffic or speeding car problem"
label var SE_20 "Trash or litter problem"
label var SE_21 "Violence problem"
label var SE_22 "Gang activity problem"
label var SE_23 "Robbery problem"
label var SE_24 "Sexual assault problem"

*Re-label variables

label define SE_12 0"live in close knit neighbourhood" 1"Don't live in close knit neighbourhood", modify
label value SE_12 SE_12

label define SE_13 0"Willing helping neighbours" 1"Non-willing helpful neighbours", modify
label value SE_13 SE_13

label define SE_14 0"People get along in the neighbourhood" 1"People don't get along in the neighbourhood", modify
label value SE_14 SE_14

label define SE_15 0"People can be trusted" 1"People can't be trusted", modify
label value SE_15 SE_15

label define SE_16 0"People share my values" 1"People do not share my values", modify
label value SE_16 SE_16

label define SE_17 0"Feel safe from crime" 1"Do not feel safe from crime", modify
label value SE_17 SE_17

label define SE_18 0"No problem" 1"Excessive noise problem", modify
label value SE_18 SE_18

label define SE_19 0"No problem" 1"Heavy traffic or speeding car problem", modify
label value SE_19 SE_19

label define SE_20 0"No problem" 1"Trash or litter problem", modify
label value SE_20 SE_20

label define SE_21 0"No problem" 1"Violence problem", modify
label value SE_21 SE_21

label define SE_22 0"No problem" 1"Gang activity problem", modify
label value SE_22 SE_22

label define SE_23 0"No problem" 1"Robbery problem", modify
label value SE_23 SE_23

label define SE_24 0"No problem" 1"Sexual assault problem", modify
label value SE_24 SE_24

*-------------------------------------------------------------------------------

*Physical activity and active communting estimates (Table 1)
oneway mpdT siteid, tab
oneway mpwT siteid, tab
oneway TMET siteid, tab
tab siteid inactive, chi2 row
tab siteid TMET_3, chi2 row

*-------------------------------------------------------------------------------

*Active Commuting and Socio-demographic and Lifestyle characteristics (Table 2)
oneway partage TMET_3, tab
oneway bmi TMET_3, tab
oneway nolabrisk10 TMET_3, tab
oneway hood_score TMET_3, tab
oneway D96 TMET_3, tab

tab TMET_3 gender, chi2 row
tab TMET_3 percsafe, chi2 row
tab TMET_3 educ, chi2 row
tab TMET_3 D7, chi2 row
tab TMET_3 dia, chi2 row
tab TMET_3 ow, chi2 row
tab TMET_3 ob, chi2 row

*-------------------------------------------------------------------------------

*Regression Models (Table 3)

**Linear Regression (Active Commuting - TMET)

* Perceived Neighbourhood Characteristics and Active Commuting
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {
regress TMET i.SE_`x' i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10, vce(robust) 
}

regress TMET hood_score i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 
regress TMET percsafe  i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 


**Logistic Regression (Physicaal Inactivity - inactive)

* Perceived Neighbourhood Characteristics and Physical inactivity
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {
logistic inactive i.SE_`x' i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10, vce(robust) 
}

logistic inactive hood_score i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10, vce(robust) 
logistic inactive percsafe i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10, vce(robust) 

*-------------------------------------------------------------------------------

*Close log file
log close

*--------------------------END--------------------------------------------------
