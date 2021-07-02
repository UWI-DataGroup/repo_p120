cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		ecs_active_neighbourhood.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Active Commuting and Perceived Neighbourhood
	**  Analyst:		Kern Rocke
	**	Date Created:	17/08/2020
	**	Date Modified:  03/06/2021
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

egen id = seq()

*Merge in ECHORN GPAQ analysis
merge 1:1 key using "`datapath'/version03/01-input/GPAQ_Files_CDRC_041921/gpaq_clean.dta", nogenerate
/*merge 1:1 id using "`datapath'/version03/01-input/echorn_walkscore.dta", nogenerate
sort walkscore
replace walkscore = "" in 1/1383
replace walkscore = "" in 2961
destring walkscore, replace
sort key
*/

*Create BMI variable
gen bmi = weight/((height/100)^2)

*Perceived Social Environment Scales

*Neighbourhood Social Cohesion
ssc install vreverse, replace
vreverse SE14, gen(SE14_reverse)
vreverse SE16, gen(SE16_reverse)
egen social_cohesion = rowtotal(SE12 SE13 SE14_reverse SE15 SE16_reverse SE17)
replace social_cohesion = . if SE12==. & SE13==. & SE14_reverse==. & SE15==. & SE16_reverse==. & SE17==.

*Neighbourhood Violence
egen violence = rowtotal(SE21 SE22 SE23 SE24)
replace violence =. if SE21==. & SE22==. & SE23==. & SE24==.

*Neighbourhood Disorder
egen disorder =rowtotal(SE18 SE19 SE20)
replace disorder =. if SE18==. & SE19==. & SE20==. 

*Car Ownership
gen car = .
replace car = 1 if D96 == 0
replace car = 0 if D96>0 & D96 !=.

*Diabetes variable
gen dia = . 
replace dia = 1 if glucose >=126 & glucose !=.
replace dia = 0 if glucose<126
replace dia = 1 if Diabetes == 1
replace dia = 0 if Diabetes == 0

*Hypertension variable
gen htn = .
replace htn = 0 if bp_diastolic < 90 | bp_systolic < 140
replace htn = 1 if bp_diastolic >= 90 & bp_systolic >= 140 & bp_diastolic !=. & bp_systolic!=.
replace htn = 1 if Hypertension == 1
label var htn "Hypertension"
label define htn 0"No" 1"Hypertension"
label value htn htn

*Obesity
gen obese = .
replace obese = 1 if bmi>=30 & bmi!=.
replace obese = 0 if bmi<30

*Resident Status
gen residential = .
replace residential = 1 if D75 == 0 
replace residential = 2 if D75 == 1
replace residential = 3 if D75 == 2 | D75 == 3 | D75 == 4

*Education
gen educ=.
replace educ=1 if D13==0 | D13==1 | D13==2
replace educ=2 if D13==3
replace educ=3 if D13==4 | D13==5
replace educ=4 if D13==6 | D13==7 | D13==8 | D13==9
label variable educ "Education categories"
label define educ 1 "less than high school" 2 "high school graduate" 3 "associates degree/some college" 4 "college degree"
label values educ educ 

*Active Commuting variables
gen commute_day = p9
label var commute_day "Active Commuting (day)"

gen commute_wk = p9*p8
label var commute_wk "Active Commuting (week)"

cls
*Model 2 - Adjusting for Model 1, country site 
cls

tobit commute_wk social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit commute_wk disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit commute_wk violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)



cls

tobit total_physical_activity social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit total_physical_activity disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit total_physical_activity violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)


cls

gen inactive1 = .
replace inactive1 = 1 if physically_active == 0
replace inactive1 = 0 if physically_active == 1

cls
logistic inactive1 social_cohesion gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)
logistic inactive1 disorder gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)
logistic inactive1 violence gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)

/*
nbreg walk_wk social_cohesion c.walkscore##car gender partage i.siteid bmi, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk disorder c.walkscore##car gender partage i.siteid bmi, irr vce(cluster siteid) nolog cformat(%9.3f)
nbreg walk_wk violence c.walkscore##car gender partage i.siteid bmi, irr vce(cluster siteid) nolog cformat(%9.3f)


SLEEP

*preserve
cls
gen sleep_cat = . 
replace sleep_cat= 1 if GH242<=6
replace sleep_cat= 2 if GH242>=9
replace sleep_cat= 0 if GH242==7 | GH242==8
label var sleep_cat "Sleep Categories"
label define sleep_cat 0"Normal" 1"Low" 2"High"
label value sleep_cat sleep_cat
xtile social_cat = social_cohesion, nq(3)
xtile disorder_cat = disorder, nq(3)
xtile violence_cat = violence, nq(3)


cls
tab sleep_cat
oneway social_cohesion sleep_cat, tab
oneway disorder sleep_cat, tab
oneway violence sleep_cat, tab


*mlogit sleep_cat social_cohesion disorder violence i.gender partage bmi i.siteid htn dia physically_active, nolog base(0) rrr vce(cluster siteid)

mlogit sleep_cat ib3.social_cat i.disorder_cat i.violence_cat i.gender partage bmi i.siteid htn dia physically_active, nolog base(0) rrr vce(cluster siteid)

*restore
