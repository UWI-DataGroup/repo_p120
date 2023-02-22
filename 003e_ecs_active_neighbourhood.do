cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		ecs_active_neighbourhood.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Active Commuting and Perceived Neighbourhood
	**  Analyst:		Kern Rocke
	**	Date Created:	17/08/2020
	**	Date Modified:  13/07/2021
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
gen under = .
replace under = 0 if bmi_cat==1
replace under = 1 if bmi_cat==2
prtest under if commute_wk!=., by(gender) 
tab bmi_cat gender if commute_wk!=., chi2
gen  over= .
replace over = 0 if bmi_cat==1
replace over = 1 if bmi_cat==2
drop over
gen  over= .
replace over = 0 if bmi_cat==1
replace over = 1 if bmi_cat==3

*Perceived Social Environment Scales

*Neighbourhood Social Cohesion
*ssc install vreverse, replace
vreverse SE14, gen(SE14_reverse)
vreverse SE16, gen(SE16_reverse)
egen social_cohesion = rowtotal(SE12 SE13 SE14_reverse SE15 SE16_reverse SE17)
replace social_cohesion = . if SE12==. & SE13==. & SE14_reverse==. & SE15==. & SE16_reverse==. & SE17==.
label var social_cohesion "Neighborhood Social Cohesion"
xtile social_cat = social_cohesion, nq(3)
label var social_cat "Social Cohesion Categories"
label define social_cat 1"Low" 2"Medium" 3"High"
label value social_cat social_cat

*Neighbourhood Violence
egen violence = rowtotal(SE21 SE22 SE23 SE24)
replace violence =. if SE21==. & SE22==. & SE23==. & SE24==.
label var violence "Neighborhood Violence"
xtile violence_cat = violence, nq(3)
recode violence_cat (2=3)
label var violence_cat "Violence Categories"
label define violence_cat 1"Low" 3"High"
label value violence_cat violence_cat

*Neighbourhood Disorder
egen disorder =rowtotal(SE18 SE19 SE20)
replace disorder =. if SE18==. & SE19==. & SE20==. 
label var disorder "Neighborhood Disorder"
xtile disorder_cat = disorder, nq(3)
recode disorder_cat (2=3)
label var disorder_cat "Disorder Categories"
label define disorder_cat 1"Low" 3"High"
label value disorder_cat disorder_cat
*-------------------------------------------------------
*Creating binary Perceived Social Neighborhood Environment (PSNE)

foreach x in SE12 SE13 SE14_reverse SE15 SE16_reverse SE17{
	gen `x'_cat = .
	replace `x'_cat = 0 if `x'==1
	replace `x'_cat = 1 if `x'==2 | `x'==3 | `x'==4
}

foreach x in SE18 SE19 SE20 SE21 SE22 SE23 SE24{
	gen `x'_cat = . 
	replace `x'_cat = 0 if `x'==0
	replace `x'_cat = 1 if `x'==1 | `x'==2 | `x'==3
	label define `x'_cat 0"No problem" 1"Problem"
	label value `x'_cat `x'_cat
}
*-------------------------------------------------------

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
label var obese "Obesity"
label define obese 0"Non-obese" 1"Obese"
label value obese obese

*BMI Categories
gen bmi_cat = .
replace bmi_cat = 0 if bmi>=18.50 & bmi<25
replace bmi_cat = 1 if bmi<18.50
replace bmi_cat = 2 if bmi>=25 & bmi!=.
label var bmi_cat "BMI categories"
label define bmi_cat 0"Normal" 1"Underweight" 2"Overweight/Obese"
label value bmi_cat bmi_cat

*Resident Status
gen residential = .
replace residential = 1 if D75 == 0 
replace residential = 2 if D75 == 1
replace residential = 3 if D75 == 2 | D75 == 3 | D75 == 4
label var residential "Residential status"

*Education
gen educ=.
replace educ=1 if D13==0 | D13==1 | D13==2
replace educ=2 if D13==3
replace educ=3 if D13==4 | D13==5
replace educ=4 if D13==6 | D13==7 | D13==8 | D13==9
label variable educ "Education categories"
label define educ 1 "less than high school" 2 "high school graduate" 3 "associates degree/some college" 4 "college degree"
label values educ educ 

*Income
gen income = .
replace income = 1 if D36W == 1 | D36M == 1 | D36A == 1 
replace income = 2 if D36W == 2 | D36M == 2 | D36A == 2 
replace income = 3 if D36W == 3 | D36M == 3 | D36A == 3
replace income = 4 if D36W == 4 | D36M == 4 | D36A == 4
replace income = 5 if D36W == 5 | D36M == 5 | D36A == 5
replace income = 5 if D36W == 6 | D36M == 6 | D36A == 6    

replace income = 1 if D37W == 1 | D37M == 1 | D37A == 1 
replace income = 2 if D37W == 2 | D37M == 2 | D37A == 2 
replace income = 3 if D37W == 3 | D37M == 3 | D37A == 3
replace income = 4 if D37W == 4 | D37M == 4 | D37A == 4
replace income = 4 if D37W == 5 | D37M == 5 | D37A == 5
replace income = 5 if D37W == 6 | D37M == 6 | D37A == 6 
replace income = 5 if D37W == 7 | D37M == 7 | D37A == 7   

replace income = 1 if D38W == 1 | D38M == 1 | D38A == 1 
replace income = 2 if D38W == 2 | D38M == 2 | D38A == 2 
replace income = 3 if D38W == 3 | D38M == 3 | D38A == 3 
replace income = 4 if D38W == 4 | D38M == 4 | D38A == 4 
replace income = 5 if D38W == 5 | D38M == 5 | D38A == 5 

label var income "Income Categories"
label define income 1"Low" 2"Low-middle" 3"Middle" 4"High-middle" 5"High"
label value income income
*--------------------------------------------------------------------------
*Active Commuting variables
gen commute_day = p9
label var commute_day "Active Commuting (day)"

gen commute_wk = p9*p8
label var commute_wk "Active Commuting (week)"

gen APA = .
replace APA = 0 if commute_wk==0
replace APA = 1 if commute_wk>0 & commute_wk!=.
label var APA "Engaging in Active Commuting"
label define APA 0"Zero active commuting" 1"Engaging in active commuting"
label value APA APA

gen commute_cat = . 
replace commute_cat = 0 if commute_wk==0
replace commute_cat = 1 if commute_wk >0 & commute_wk<150
replace commute_cat = 2 if commute_wk>=150 & commute_wk!=.
label var commute_cat "Active Commuting Categories"
label define commute_cat 0"Inactive" 1"Insufficiently Active" 2"Active"
label value commute_cat commute_cat

*---------------------------------------------------------------------------
gen rec_vig_wk = p11*p12
label var rec_vig_wk "Recreational Weekly Vigorous PA"
gen rec_mod_wk = p14*p15
label var rec_mod_wk "Recreational Weekly Moderate PA"
egen rec_wk = rowtotal(rec_vig_wk rec_mod_wk)
label var rec_wk "Overall weekly recreational PA"

*--------------------------------------------------------------------------
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

cls
*Table 1
tab gender 

proportion agegr if commute_wk !=., cformat(%9.1f)
proportion educ if commute_wk !=., cformat(%9.1f)
proportion income if commute_wk !=., cformat(%9.1f)
proportion residential if commute_wk !=., cformat(%9.1f)
proportion car if commute_wk !=., cformat(%9.1f)
proportion bmi_cat if commute_wk !=., cformat(%9.1f)
proportion siteid if commute_wk !=., cformat(%9.1f)

proportion agegr if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion educ if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion income if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion residential if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion car if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion bmi_cat if commute_wk !=., over(gender) percent cformat(%9.1f)
proportion siteid if commute_wk !=., over(gender) percent cformat(%9.1f)


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Table 2

*Social Cohesion social_cohesion

mean social_cohesion if commute_wk !=.
ttest social_cohesion if commute_wk !=., by(gender)
foreach x of varlist SE12_cat SE13_cat SE14_reverse_cat SE15_cat SE16_reverse_cat SE17_cat{
	
	proportion `x' if commute_wk !=., percent cformat(%9.1f)
	proportion `x' if commute_wk !=., over(gender) percent cformat(%9.1f)
}

*Disorder

mean disorder if commute_wk !=., cformat(%9.1f)
ttest disorder if commute_wk !=., by(gender) cformat(%9.1f)
foreach x of varlist SE18_cat SE19_cat SE20_cat {
	
	proportion `x' if commute_wk !=., percent cformat(%9.1f)
	proportion `x' if commute_wk !=., over(gender) percent cformat(%9.1f)
}

*Violence

mean violence if commute_wk !=., cformat(%9.1f)
ttest violence if commute_wk !=., by(gender) cformat(%9.1f)
foreach x of varlist SE21_cat SE22_cat SE23_cat SE24_cat {
	
	proportion `x' if commute_wk !=., percent cformat(%9.1f)
	proportion `x' if commute_wk !=., over(gender) percent cformat(%9.1f)
}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Table 3

mean commute_wk if commute_wk !=., cformat(%9.1f)
ttest commute_wk if commute_wk !=., by(gender) cformat(%9.1f)

mean rec_wk if commute_wk !=., cformat(%9.1f)
ttest rec_wk if commute_wk !=., by(gender) cformat(%9.1f)

proportion commute_cat if commute_wk !=., percent cformat(%9.1f)
proportion commute_cat if commute_wk !=., over(gender) percent cformat(%9.1f)

proportion inactive if commute_wk !=., percent cformat(%9.1f)
proportion inactive if commute_wk !=., over(gender) percent cformat(%9.1f)

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

* Time spent commuting - Tobit regression

***Unadjusted Models

*Overall (Both Male and Femle)
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x', vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}


*Male
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x' if gender == 1, vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}

*Female
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x' if gender == 2, vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}


***Multivariable Adjusted models 

*Overall (Both Male and Femle)
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x' gender partage i.educ bmi car i.residential totMETmin income siteid, vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}


*Male
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x' partage i.educ bmi car i.residential totMETmin income siteid if gender == 1, vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}

*Female
foreach x of varlist social_cat disorder_cat violence_cat {	
	tobit commute_wk i.`x' partage i.educ bmi car i.residential totMETmin income siteid if gender == 2, vce(cluster siteid) ll(0) nolog cformat(%9.1f)
}


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------



*Active Transport Categories - Multinomial logistic regression

***Unadjusted Models

*Overall (Both Male and Female)
foreach x of varlist social_cat disorder_cat violence_cat {	
	mlogit commute_cat i.`x', vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
}
*-------------------------------------------------------------------------------	
*Male
foreach x of varlist social_cat disorder_cat violence_cat {
	mlogit commute_cat i.`x' if gender == 1, vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
}
*-------------------------------------------------------------------------------		
*Female
foreach x of varlist social_cat disorder_cat violence_cat {
	mlogit commute_cat i.`x' if gender == 2, vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
	}
*-------------------------------------------------------------------------------	



***Multivariable Adjusted models - Table 4

*Overall (Both Male and Female)
foreach x of varlist social_cat disorder_cat violence_cat {	
	mlogit commute_cat i.`x' gender partage i.educ bmi car i.residential totMETmin income siteid, vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
}
*-------------------------------------------------------------------------------	
*Male
foreach x of varlist social_cat disorder_cat violence_cat {
	mlogit commute_cat i.`x' partage i.educ bmi car i.residential totMETmin income siteid if gender == 1, vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
}
*-------------------------------------------------------------------------------		
*Female
foreach x of varlist social_cat disorder_cat violence_cat {
	mlogit commute_cat i.`x' partage i.educ bmi car i.residential totMETmin income siteid if gender == 2, vce(cluster siteid) cformat(%9.2f) rrr base(0) nolog
	}
*-------------------------------------------------------------------------------	



/*
IGNORE

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





