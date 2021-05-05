
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		ecs_active_neighbourhood.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Active Commuting and Perceived Neighbourhood
	**  Analyst:		Kern Rocke
	**	Date Created:	17/08/2020
	**	Date Modified:  22/09/2020
	**  Algorithm Task: Analyzing relationship between perceived neighbourhood and active commuting.

    ** General algorithm set-up
    version 13
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
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

** Logfiles to unencrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local logpath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local logpath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local logpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

**Aggregated output path

*WINDOWS OS - Ian & Christina (Data Group) 
*local outputpath "The University of the West Indies/DataGroup - PROJECT_p120"

*WINDOWS OS - Kern & Stephanie
*local outputpath "X:/The UWI - Cave Hill Campus/DataGroup - PROJECT_p120"

*MAC OS - Kern
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"	
	
*-------------------------------------------------------------------------------

**Do file path

local dopath "/Volumes/Secomba/kernrocke/Boxcryptor/OneDrive - The UWI - Cave Hill Campus/Github Repositories/repo_p120"

** PhD path
local phdpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p145"

*Open log file to store results
*log using "`logpath'/version03/3-output/ecs_active_neighbourhood.log",  replace

*-------------------------------------------------------------------------------

*Load in data from encrypted location
use "`datapath'/version03/02-working/survey_wave1_weighted.dta", clear
	
*-------------------------------------------------------------------------------

*Create physical activity variables from GPAQ
do "`dopath'/p_activity_algorithm.do"

*Merge in CVD risk data
merge 1:1 key using "`datapath'/version03/02-working/who_reduced.dta", nogenerate
merge 1:1 key using "`datapath'/version03/02-working/ascvd_reduced.dta", nogenerate
merge 1:1 key using "`datapath'/version03/02-working/risk_comparison.dta", nogenerate
merge 1:1 key using "`datapath'/version03/02-working/wave1_framingham_cvdrisk_prepared.dta", nogenerate
merge 1:1 key using "`phdpath'/version01/2-working/Walkability/Barbados/walkability_ECHORN_participants.dta", nogenerate

/*Keep neccessary variables needed for analysis
keep key siteid gender partage educ D7 D96 bp_diastolic bp_systolic///
	 totMETmin mpdT mpwT TMET inactive MET_grp///
	 SE12 SE13 SE14 SE15 SE16 SE17 SE18 SE19 SE20 SE21 SE22 SE23 SE24 ///
	 nolabrisk10 nolabrisk10ca bmi ow ob ob4 percsafe hood_score ///
	 primary_plus second_plus tertiary prof semi_prof non_prof occ*/
	 
*-------------------------------------------------------------------------------
*Create hypertnesion variable
gen htn = .
replace htn = 0 if bp_diastolic < 90 & bp_systolic < 140
replace htn = 1 if bp_diastolic >= 90 & bp_systolic >= 140
label var htn "Hypertension"
label define htn 0"No" 1"Hypertension"
label value htn htn

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
cls
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {
regress mpwT i.SE_`x' i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob, vce(robust) 
}

regress TMET hood_score i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob 
regress TMET percsafe  i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob


**Logistic Regression (Physicaal Inactivity - inactive)

* Perceived Neighbourhood Characteristics and Physical inactivity
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {
logistic inactive i.SE_`x' i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob, vce(robust) 
}

logistic inactive hood_score i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob, vce(robust) 
logistic inactive percsafe i.siteid i.gender partage i.educ bmi D96 D7 nolabrisk10 htn ob, vce(robust) 

*-------------------------------------------------------------------------------

*Regression Models (Table 4)

**Linear & Logistic Regression (Healhth Outcomes and Perceived Neighbour Charactertistics)
*Obesity
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 hood_score percsafe {
logistic ob i.SE_`x' i.siteid i.gender partage i.educ D96 D7, vce(robust) 
}


*Hypertension
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 hood_score percsafe {
logistic htn i.SE_`x' i.siteid i.gender partage i.educ D96 D7, vce(robust) 
}

*Diabetes
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 hood_score percsafe {
logistic dia i.SE_`x' i.siteid i.gender partage i.educ D96 D7, vce(robust) 
}

*CVD Risk
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 hood_score percsafe {
regress nolabrisk10 i.SE_`x' i.siteid i.gender partage i.educ D96 D7, vce(robust) 
}

*-------------------------------------------------------------------------------

*Close log file
log close

*--------------------------END--------------------------------------------------






gen bmi = weight/((height/100)^2)

gen walk_day = .
replace walk_day = (HB12*60) if HB11==1
replace walk_day = HB12 if HB11==2
replace walk_day = . if walk_day>120 | walk_day == .

gen walk_wk = . 
replace walk_wk = walk_day*HB10
replace walk_wk = . if HB10==.z

egen mvpa_wk = rowtotal(mpwVR mpwMR)
replace mvpa_wk = . if mpwMR == . & mpwVR == .

egen totalpa_wk = rowtotal(walk_wk mpwMR mpwVR mpwVW mpwMW)
replace totalpa_wk = . if totalpa_wk == 0

ssc install vreverse, replace
vreverse SE14, gen(SE14_reverse)
vreverse SE16, gen(SE16_reverse)
egen social_cohesion = rowtotal(SE12 SE13 SE14_reverse SE15 SE16_reverse SE17)
replace social_cohesion = . if SE12==. & SE13==. & SE14_reverse==. & SE15==. & SE16_reverse==. & SE17==.


egen violence = rowtotal(SE21 SE22 SE23 SE24)
replace violence =. if SE21==. & SE22==. & SE23==. & SE24==.
egen disorder =rowtotal(SE18 SE19 SE20)
replace disorder =. if SE18==. & SE19==. & SE20==. 

gen car = .
replace car = 1 if D96 == 0
replace car = 0 if D96>0 & D96 !=.

gen dia = . 
replace dia = 1 if glucose >=126 & glucose !=.
replace dia = 0 if glucose<126
replace dia = 1 if Diabetes == 1
replace dia = 0 if Diabetes == 0

gen htn = .
replace htn = 0 if bp_diastolic < 90 | bp_systolic < 140
replace htn = 1 if bp_diastolic >= 90 & bp_systolic >= 140 & bp_diastolic !=. & bp_systolic!=.
replace htn = 1 if Hypertension == 1


label var htn "Hypertension"
label define htn 0"No" 1"Hypertension"
label value htn htn

gen obese = .
replace obese = 1 if bmi>=30 & bmi!=.
replace obese = 0 if bmi<30

gen residential = .
replace residential = 1 if D75 == 0 
replace residential = 2 if D75 == 1
replace residential = 3 if D75 == 2 | D75 == 3 | D75 == 4

gen educ=.
replace educ=1 if D13==0 | D13==1 | D13==2
replace educ=2 if D13==3
replace educ=3 if D13==4 | D13==5
replace educ=4 if D13==6 | D13==7 | D13==8 | D13==9
label variable educ "Education categories"
label define educ 1 "less than high school" 2 "high school graduate" 3 "associates degree/some college" 4 "college degree"
label values educ educ 


cls
foreach y of numlist 1 2 3 4 {
regress totalpa_wk social_cohesion disorder violence i.gender partage i.educ i.car bmi i.dia i.htn if siteid == `y', cformat(%9.1f)
}




cls
foreach y of numlist 1 2 3 4 {
logistic inactive social_cohesion disorder violence i.gender partage i.educ i.car bmi i.dia i.htn if siteid == `y', cformat(%9.2f)
}



cls
foreach x in walk_wk mvpa_wk totalpa_wk{
mixed `x' social_cohesion disorder violence i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, vce(cluster siteid) cformat(%9.1f) nolog
}


meqrlogit inactive social_cohesion disorder violence i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, cformat(%9.2f) nolog or




cls
mixed walk_wk social_cohesion disorder violence i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, vce(cluster siteid) nolog
estimates store combine

mixed walk_wk social_cohesion i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, vce(cluster siteid) nolog
estimates store social
mixed walk_wk violence i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, vce(cluster siteid) nolog
estimates store violence
mixed walk_wk disorder i.gender partage i.educ i.car bmi i.dia i.htn || siteid:, vce(cluster siteid) nolog
estimates store disorder 

estimates stats social violence disorder combine


cls
regress walk_wk social_cohesion disorder violence i.gender partage i.educ i.car i.obese i.dia i.htn siteid, vce(cluster siteid)
estimates store combine

regress walk_wk social_cohesion i.gender partage i.educ i.car i.obese i.dia i.htn siteid, vce(cluster siteid)
estimates store social
regress walk_wk violence i.gender partage i.educ i.car i.obese i.dia i.htn siteid, vce(cluster siteid)
estimates store violence
regress walk_wk disorder i.gender partage i.educ i.car i.obese i.dia i.htn siteid, vce(cluster siteid)
estimates store disorder 

estimates stats social violence disorder combine



cls
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {
gen SE_`x'_new = SE_`x'
replace SE_`x'_new = SE_`x'*100
oneway SE_`x'_new siteid, tab

}


cls
foreach x of numlist 12 13 14 15 16 17 18 19 20 21 22 23 24 {

mean SE_`x'_new, over(siteid) cformat(%9.1f)

oneway SE_`x'_new siteid, tab
}


*walk_wk mpwMR mpwVR mvpa_wk mpwVW mpwMW
egen totalpa_wk = rowtotal(walk_wk mpwMR mpwVR mpwVW mpwMW)
replace totalpa_wk = . if totalpa_wk == 0


cls
foreach x in walk_wk mpwMR mpwVR mvpa_wk totalpa_wk {
	*mean `x', over(siteid) cformat(%9.1f)
	oneway `x' siteid
}


cls
foreach x in walk_wk mvpa_wk totalpa_wk {
	foreach y of numlist 1 2 3 4 {
		
regress `x' social_cohesion i.gender partage i.educ i.car bmi i.dia i.htn if siteid == `y', cformat(%9.1f)
regress `x' disorder i.gender partage i.educ i.car bmi i.dia i.htn if siteid == `y', cformat(%9.1f)
regress `x' violence i.gender partage i.educ i.car bmi i.dia i.htn if siteid == `y', cformat(%9.1f)
	}
}







cls

*Model 0 - Unadjusted
nbreg walk_wk social_cohesion , irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk disorder , irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk violence , irr vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 1 - Adjusting for Sociodemographics and lifestyle characteristics
nbreg walk_wk social_cohesion i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk disorder i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk violence i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 2 - Adjusting for Model 1, country site and neighbourhood walkability
nbreg walk_wk social_cohesion walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk disorder walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk violence walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)

cls

*Model 0 - Unadjusted
nbreg totMETmin social_cohesion , irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin disorder , irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin violence , irr vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 1 - Adjusting for Sociodemographics and lifestyle characteristics
nbreg totMETmin social_cohesion i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin disorder i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin violence i.gender partage htn dia D96 bmi i.educ i.residential, irr vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 2 - Adjusting for Model 1, country site and neighbourhood walkability
nbreg totMETmin social_cohesion walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin disorder walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg totMETmin violence walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid, irr vce(cluster siteid) nolog cformat(%9.3f)


cls

*Model 0 - Unadjusted
logistic inactive social_cohesion ,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive disorder ,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive violence ,  vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 1 - Adjusting for Sociodemographics and lifestyle characteristics
logistic inactive social_cohesion i.gender partage htn dia D96 bmi i.educ i.residential,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive disorder i.gender partage htn dia D96 bmi i.educ i.residential,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive violence i.gender partage htn dia D96 bmi i.educ i.residential,  vce(cluster siteid) nolog cformat(%9.3f)

cls
*Model 2 - Adjusting for Model 1, country site and neighbourhood walkability
logistic inactive social_cohesion walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive disorder walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid,  vce(cluster siteid) nolog cformat(%9.3f)
logistic inactive violence walk_score i.gender partage htn dia D96 bmi i.educ i.residential i.siteid,  vce(cluster siteid) nolog cformat(%9.3f)
