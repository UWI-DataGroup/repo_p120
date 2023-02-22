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
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80


** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"
     ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120
    ** GRAPHS to project output folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p120\05_Outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_analysis_activecommute", replace

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
use "`datapath'/version03/02-working/survey_wave1_weighted", clear
*-------------------------------------------------------------------------------

*Create BMI variable
gen bmi = weight/((height/100)^2)

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
										*------------------------------------------------------------------------------------------------------
										* ACTIVITY AT WORK: Questions HB1 - HB8
										*------------------------------------------------------------------------------------------------------
										*VIGOROUS WORK ACTIVITY (HB1-HB4)
										tab HB1, miss 
										/*
										Does your work |
												involve |
										vigorous/strenu |
										ous-intensity |
										activity that |
											causes larg |      Freq.     Percent        Cum.
										----------------+-----------------------------------
													No |      2,429       82.03       82.03
													Yes |        491       16.58       98.62
													. |         41        1.38      100.00
										----------------+-----------------------------------
												Total |      2,961      100.00                */

										tab HB2, miss
										/*
											In a |
										 typical |
										week, on |
										how many |
									 days do you |
											  do |
										vigorous/st |
										renuous-int |
										ensity ac |      Freq.     Percent        Cum.
										------------+-----------------------------------
												0 |         14        0.47        0.47
												1 |         21        0.71        1.18
												2 |         59        1.99        3.17
												3 |         89        3.01        6.18
												4 |         55        1.86        8.04
												5 |        136        4.59       12.63
												6 |         55        1.86       14.49
												7 |         49        1.65       16.14
												. |      2,483       83.86      100.00
										------------+-----------------------------------
											Total |      2,961      100.00             */

										* If answered "no" to HB1, then HB2 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
										recode HB2 0=.z
										list HB2 if HB1==.
										replace HB2=.z if HB1==0 | HB1==.
										tab HB2, miss

										*HB3 asks people to select hours or minutes, then HB4 asks for time spent doing vig activity in the units selected on a typical day
										tab HB3, miss
										tab HB4, miss 
										codebook HB4 if HB3==1  // the range of hours of vig PA at a typical day at work is 0-52. 
										codebook HB4 if HB3==2  // the range of minutes of vig PA at a typical day at work is 0-90

										*Calculating min per day for vigorous work
										gen mpdVW=.
										replace mpdVW=(HB4*60) if HB3==1
										replace mpdVW=HB4 if HB3==2
										replace mpdVW=.a if HB4>16 & HB4<. & HB3==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses
										codebook mpdVW 
										label variable mpdVW "vigorous work (min/day)"

										*Calculating min per week for vigorous work
										gen mpwVW=mpdVW*HB2 
										replace mpwVW=.z if HB2==.z
										label variable mpwVW "vigorous work (min/week)"

										*Calculating MET-min per week for vigorous work (assuming MET value of 8 for vigorous work)
										gen VWMET=mpwVW*8
										replace VWMET=.z if HB2==.z
										label variable VWMET "MET-min per week from vigorous work"
										*histogram VWMET, by(siteid)
										table siteid, stat(median VWMET)

										*MODERATE WORK ACTIVITY (HB5 - HB8)
										tab HB5, miss 
										/*
										Does your work |
												involve |
										moderate-intens |
										ity activity |
											that causes |
										small increase |      Freq.     Percent        Cum.
										----------------+-----------------------------------
													No |      1,609       54.34       54.34
													Yes |      1,313       44.34       98.68
													. |         39        1.32      100.00
										----------------+-----------------------------------
												Total |      2,961      100.00                */

										tab HB6, miss 

										/*    In a |
											typical |
										week, on |
										how many |
										days do you |
										do moderate |
										intensity |
										activities |
												a |      Freq.     Percent        Cum.
										------------+-----------------------------------
												0 |         19        0.64        0.64
												1 |         54        1.82        2.47
												2 |        140        4.73        7.19
												3 |        236        7.97       15.16
												4 |        139        4.69       19.86
												5 |        376       12.70       32.56
												6 |        133        4.49       37.05
												7 |        195        6.59       43.63
												. |      1,669       56.37      100.00
										------------+-----------------------------------
											Total |      2,961      100.00                */

										* If answered "no" to HB5, then HB6 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
										recode HB6 0=.z
										list HB6 if HB5==.
										replace HB6=.z if HB5==0 | HB5==.
										tab HB6, miss

										*HB7 asks people to select hours or minutes, then HB8 asks for time spent doing moderate activity in the units selected on a typical day
										tab HB7, miss
										tab HB8, miss 
										codebook HB8 if HB7==1  // the range of hours of moderate PA at a typical day at work is 0-55
										codebook HB8 if HB7==2  // the range of minutes of moderate PA at a typical day at work is 0-90

										*Calculating min per day for moderate-intensity work
										gen mpdMW=.
										replace mpdMW=(HB8*60) if HB7==1
										replace mpdMW=HB8 if HB7==2
										replace mpdMW=.a if HB8>16 & HB8<. & HB7==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses
										codebook mpdMW 
										label variable mpdMW "Moderate work (min/day)"

										*Calculating min per week for moderate intensity work
										gen mpwMW=mpdMW*HB6  
										replace mpwMW=.z if HB6==.z 
										label variable mpwMW "Moderate work (min/week)"

										*Calculating MET-min per week for moderate intensity work (assuming MET value of 4 for moderate work)
										gen MWMET=mpwMW*4
										replace MWMET=.z if HB6==.z 
										label variable MWMET "MET-min per week from moderate work"
										*histogram MWMET, by(siteid)
										table siteid, stat(median MWMET) 

										*------------------------------------------------------------------------------------------------------
										* ACTIVITY DURING ACTIVE TRANSPORT: Questions HB9 - HB12
										*------------------------------------------------------------------------------------------------------
										tab HB9, miss 

										/* Do you walk or |
										use a bicycle |
										(pedal cycle) |
										for at least 10 |
												minutes |
											continuous |      Freq.     Percent        Cum.
										----------------+-----------------------------------
													No |      1,648       55.66       55.66
												   Yes |      1,283       43.33       98.99
													. |         30        1.01      100.00
										----------------+-----------------------------------
												Total |      2,961      100.00                */

										tab HB10, miss 

										/*     In a |
											typical |
										week, on |
										how many |
										days do you |
											walk or |
										bicycle for |
										at least 10 |
												mi |      Freq.     Percent        Cum.
										------------+-----------------------------------
												0 |         11        0.37        0.37
												1 |         33        1.11        1.49
												2 |        126        4.26        5.74
												3 |        203        6.86       12.60
												4 |        136        4.59       17.19
												5 |        362       12.23       29.42
												6 |         87        2.94       32.35
												7 |        309       10.44       42.79
												. |      1,694       57.21      100.00
										------------+-----------------------------------
											Total |      2,961      100.00            */


										/* If answered "no" to HB9, then HB10 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
										recode HB10 0=.z
										list HB10 if HB9==.
										replace HB10=.z if HB9==0 | HB9==.
										tab HB10, miss
										*/

										replace HB10 = 0 if HB9 == 0
										tab HB10, miss 

										*HB11 asks people to select hours or minutes, then HB12 asks for time spent in active transport in the units selected on a typical day
										tab HB11, miss
										tab HB12, miss 
										codebook HB12 if HB11==1  // the range of hours spent in active transport is 1-60. 
										codebook HB12 if HB11==2  // the range of minutes spent in active transport is 0-90.

										*Calculating min per day for active transport
										gen mpdT=.
										replace mpdT=(HB12*60) if HB11==1
										replace mpdT=HB12 if HB11==2
										replace mpdT=.a if HB12>16 & HB12<. & HB11==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses
										codebook mpdT 

										*Calculating min per week for active transport
										gen mpwT=mpdT*HB10 
										replace mpwT=0 if HB9==0

										label var mpdT "Active Commuting (min per day)"
										label var mpwT "Active Commuting (min per week)"

										*Calculating MET-min per week for active transport (assuming MET value of 4 for active transport)
										gen TMET=mpwT*4
										replace TMET=.z if HB10==.z 
										label variable TMET "MET-min per week from active transport"
										*histogram TMET, by(siteid)
										table siteid, stat(median TMET)


										*------------------------------------------------------------------------------------------------------
										* RECREATIONAL ACTIVITY: Questions HB13 - HB20
										*------------------------------------------------------------------------------------------------------
										**VIGOROUS ACTIVITY (questions HB13-HB16)
										tab HB13, miss 

										/*Do you do any |
										vigorous/strenu |
										ous-intensity |
										sports, fitness |
										or recreational |
													(l |      Freq.     Percent        Cum.
										----------------+-----------------------------------
													No |      2,395       80.88       80.88
													Yes |        518       17.49       98.38
													. |         48        1.62      100.00
										----------------+-----------------------------------
												Total |      2,961      100.00            */

										tab HB14, miss

										/*    In a |
											typical |
										week, on |
										how many |
										days do you |
												do |
										vigorous/st |
										renuous-int |
										ensity sp |      Freq.     Percent        Cum.
										------------+-----------------------------------
												0 |         14        0.47        0.47
												1 |         59        1.99        2.47
												2 |        101        3.41        5.88
												3 |        150        5.07       10.94
												4 |         78        2.63       13.58
												5 |         77        2.60       16.18
												6 |         19        0.64       16.82
												7 |          9        0.30       17.12
												. |      2,454       82.88      100.00
										------------+-----------------------------------
											Total |      2,961      100.00             */



										* If answered "no" to HB13, then HB14 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
										recode HB14 0=.z
										list HB14 if HB13==.
										replace HB14=.z if HB13==0 | HB13==.
										tab HB14, miss 


										*HB15 asks people to select hours or minutes, then HB16 asks for time spent in vigorous recreational activity in the units selected on a typical day
										tab HB15, miss
										tab HB16, miss 
										codebook HB16 if HB15==1  // the range of hours spent in vigorous recreational activity is 1-60. 
										codebook HB16 if HB15==2  // the range of minutes spent in vigorous recreational activity is 0-90.

										*Calculating min per day for vigorous recreational activity
										gen mpdVR=.
										replace mpdVR=(HB16*60) if HB15==1
										replace mpdVR=HB16 if HB15==2
										replace mpdVR=.a if HB16>16 & HB16<. & HB15==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses
										codebook mpdVR
										label variable mpdVR "Vigorous Recreational activity (min/day)"

										*Calculating min per week for vigorous recreational activity
										gen mpwVR=mpdVR*HB14
										replace mpwVR=.z if HB14==.z 
										label variable mpwVR "Vigorous Recreational activity (min/week)"

										*Calculating MET-min per week for vigorous recreational activity (assuming MET value of 8 for vigorous recreational activity)
										gen VRMET=mpwVR*8
										replace VRMET=.z if HB14==.z 
										label variable VRMET "MET-min per week from vigorous recreational activity"
										*histogram VRMET, by(siteid)
										table siteid, stat(median VRMET)

										*MODERATE RECREATIONAL ACTIVITY (questions HB17 - HB20)
										tab HB17, miss

										/*Do you do any |
										moderate-intens |
											ity sports, |
											fitness or |
										recreational |
										(leisure) ac |      Freq.     Percent        Cum.
										----------------+-----------------------------------
													No |      1,849       62.45       62.45
													Yes |      1,066       36.00       98.45
													. |         46        1.55      100.00
										----------------+-----------------------------------
												Total |      2,961      100.00            */

										tab HB18, miss

										/* In a |
											typical |
										week, on |
										how many |
										days do you |
										do moderate |
										intensity |
											sports, |
											fitn |      Freq.     Percent        Cum.
										------------+-----------------------------------
												0 |         40        1.35        1.35
												1 |         81        2.74        4.09
												2 |        222        7.50       11.58
												3 |        306       10.33       21.92
												4 |        151        5.10       27.02
												5 |        162        5.47       32.49
												6 |         40        1.35       33.84
												7 |         50        1.69       35.53
												. |      1,909       64.47      100.00
										------------+-----------------------------------
											Total |      2,961      100.00               */


										* If answered "no" to HB17, then HB18 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
										recode HB18 0=.z
										list HB18 if HB17==.
										replace HB18=.z if HB17==0 | HB17==.
										tab HB18, miss 

										*HB19 asks people to select hours or minutes, then HB20 asks for time spent in moderate recreational activity in the units selected on a typical day
										tab HB19, miss
										tab HB20, miss 
										codebook HB20 if HB19==1  // the range of hours spent in moderate recreational activity is 0-7. 
										codebook HB20 if HB19==2  // the range of minutes spent in moderate recreational activity is 0-7. 
										*It's strange that the hours and minutes values all fall between 1 and 7. Can we check whether options for days of the week were given in error? The data dictionary says it was a free text response

										*Calculating min per day for moderate recreational activity
										gen mpdMR=.
										replace mpdMR=(HB20*60) if HB19==1
										replace mpdMR=HB20 if HB19==2
										replace mpdMR=.a if HB20>16 & HB20<. & HB19==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses
										codebook mpdMR
										label variable mpdMR "moderate recreational activity (min/day)"

										*Calculating min per week for moderate recreational activity
										gen mpwMR=mpdMR*HB18
										replace mpwMR=.z if HB18==.z 
										label variable mpwMR "moderate recreational activity (min/week)"

										*Calculating MET-min per week for moderate recreational activity (assuming MET value of 4 for moderate recreational activity)
										gen MRMET=mpwMR*4
										replace MRMET=.z if HB18==.z 
										label variable MRMET "MET-min per week from moderate recreational activity"
										*histogram MRMET, by(siteid)
										table siteid, stat(median MRMET) 

										*------------------------------------------------------------------------------------------------------
										* TOTAL MET MINUTES PER WEEK AND INACTIVITY PREVALENCE
										*------------------------------------------------------------------------------------------------------
										/* GPAQ analysis guide states that if either of the following conditions are met, the respondent should be removed from all analyses, resulting in the same denominator across 
										all domains and analyses: 
										1) More than 16 hours reported in ANY sub-domain
										2) Inconsistent answers (e.g. 0 days reported, but values >0 in corresponding time variables)
										*/

										generate PAclean=1
										replace PAclean=0 if mpdVW==.a | mpdMW==.a | mpdT==.a | mpdVR==.a | mpdMR==.a 
										replace PAclean=0 if HB1==0 & HB2>=1 & HB2<=7 
										replace PAclean=0 if HB5==0 & HB6>=1 & HB6<=7 
										replace PAclean=0 if HB9==0 & HB10>=1 & HB10<=7
										replace PAclean=0 if HB13==0 & HB14>=1 & HB14<=7  
										replace PAclean=0 if HB17==0 & HB18>=1 & HB18<=7  


										*TOTAL MET MINUTES PER WEEK FROM ALL DOMAINS
										egen totMETmin=rowtotal(VWMET MWMET TMET VRMET MRMET)
										replace totMETmin=. if PAclean==0
										gen inactive=.
										replace inactive=1 if totMETmin<600
										replace inactive=0 if totMETmin>=600 & totMETmin<.
										label variable inactive "inactive WHO recommendations"
										label define inactive 0 "active" 1 "inactive"
										label values inactive inactive 
										tab inactive siteid, col miss 
										tab inactive siteid if gender==1, col miss
										tab inactive siteid if gender==2, col miss

*---------------------------------------------------------------------------

rename mpdT commute_day
replace commute_day = . if PAclean==0
rename mpwT commute_wk
replace commute_wk = . if PAclean==0

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

egen rec_wk = rowtotal(mpwVR mpwMR)
replace rec_wk = . if PAclean == 0
label var rec_wk "Overall weekly recreational PA (min/week)"

/*--------------------------------------------------------------------------
* Tobit regression models: Outcome - active commuting (min/week), predictors - PNSE characteristics
*--------------------------------------------------------------------------
histogram commute_wk
codebook commute_wk

tab social_cat, miss 
tobit commute_wk i.social_cat, vce(cluster siteid) cformat(%9.1f) 
tobit commute_wk i.social_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high social cohesion associated with increased time spent in active transport
tobit commute_wk social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // increased social cohesion score associated with increased time spent in active transport

tab violence_cat, miss 
tobit commute_wk i.violence_cat, vce(cluster siteid) cformat(%9.1f) 
tobit commute_wk i.violence_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
tobit commute_wk violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 

tab disorder_cat, miss 
tobit commute_wk i.disorder_cat, vce(cluster siteid) cformat(%9.1f) 
tobit commute_wk i.disorder_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
tobit commute_wk disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 


*--------------------------------------------------------------------------
* Tobit regression models: Outcome - total PA (MEtmin per week), predictors - PNSE characteristics
*--------------------------------------------------------------------------

tobit totMETmin i.social_cat, vce(cluster siteid) cformat(%9.1f) 
tobit totMETmin i.social_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
tobit totMETmin social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 

tobit totMETmin i.violence_cat, vce(cluster siteid) cformat(%9.1f) 
tobit totMETmin i.violence_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
tobit totMETmin violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // increased violence score associated with increased PA (???)

tobit totMETmin i.disorder_cat, vce(cluster siteid) cformat(%9.1f) 
tobit totMETmin i.disorder_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high disorder associated with increased PA???
tobit totMETmin disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // increased disorder associated with increased PA???


*--------------------------------------------------------------------------
* Tobit regression models: Outcome - recreational PA (min/week), predictors - PNSE characteristics
*--------------------------------------------------------------------------

tobit rec_wk i.social_cat, vce(cluster siteid) cformat(%9.1f) 
tobit rec_wk i.social_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
tobit rec_wk social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 

tobit rec_wk i.violence_cat, vce(cluster siteid) cformat(%9.1f) 
tobit rec_wk i.violence_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high violence associated with increased activity
tobit rec_wk violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high violence associated with increased activity

tobit rec_wk i.disorder_cat, vce(cluster siteid) cformat(%9.1f) 
tobit rec_wk i.disorder_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high disorder associated with increased activity
tobit rec_wk disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) // high disorder associated with increased activity


*--------------------------------------------------------------------------
* Logistic regression models: Outcome - active commuting (none/some), predictors - PNSE characteristics
*--------------------------------------------------------------------------

tab APA, miss
logistic APA i.social_cat, vce(cluster siteid) cformat(%9.2f) 
logistic APA i.social_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.2f) // high social cohesion associated with increased odds of active transport
logistic APA social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.2f)

logistic APA i.disorder_cat, vce(cluster siteid) cformat(%9.1f)
logistic APA i.disorder_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
logistic APA disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 

logistic APA i.violence_cat, vce(cluster siteid) cformat(%9.1f) // high violence score associated with reduced odds of active commuting
logistic APA i.violence_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
logistic APA violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f)

*--------------------------------------------------------------------------
* Logistic regression models: Outcome - WHO inactivity, predictors - PNSE characteristics
*--------------------------------------------------------------------------

tab inactive, miss
logistic inactive i.social_cat, vce(cluster siteid) cformat(%9.2f) 
logistic inactive i.social_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.2f) 
logistic inactive social_cohesion gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f) // increased social cohesion score associated with decreased odds of being inactive (would need to invert)

logistic inactive i.disorder_cat, vce(cluster siteid) cformat(%9.1f)
logistic inactive i.disorder_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
logistic inactive disorder gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)

logistic inactive i.violence_cat, vce(cluster siteid) cformat(%9.1f) 
logistic inactive i.violence_cat gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) cformat(%9.1f) 
logistic inactive violence gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f) 

*/
*--------------------------------------------------------------------------
* Multinomial regression models: Outcome - active commuting (none/insufficiently active/active), predictors - PNSE characteristics
*--------------------------------------------------------------------------
tab commute_cat social_cat, row

mlogit commute_cat i.social_cat, rrr vce(cluster siteid) cformat(%9.2f) 
mlogit commute_cat i.social_cat partage bmi i.educ i.residential car i.siteid if gender==1, rrr vce(cluster siteid) cformat(%9.2f) 
mlogit commute_cat i.social_cat partage bmi i.educ i.residential car i.siteid if gender==2, rrr vce(cluster siteid) cformat(%9.2f) 





/*
cls
*Model 2 - Adjusting for Model 1, country site 
cls

tobit commute_wk social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit commute_wk disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit commute_wk violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)

/*

cls

tobit total_physical_activity social_cohesion gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit total_physical_activity disorder gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)
tobit total_physical_activity violence gender partage bmi i.educ i.residential car i.siteid, vce(cluster siteid) nolog cformat(%9.1f) ll(0)


cls

gen inactive1 = .
replace inactive1 = 1 if physically_active == 0
replace inactive1 = 0 if physically_active == 1

cls
logistic inactive social_cohesion gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)
logistic inactive disorder gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)
logistic inactive violence gender partage bmi i.educ i.residential car i.siteid dia htn, vce(cluster siteid) cformat(%9.2f)

cls
*Table 1
tab gender if commute_wk!=.

proportion agegr if commute_wk!=., percent cformat(%9.1f)
proportion agegr if commute_wk!=., over(gender) percent cformat(%9.1f)


proportion siteid if commute_wk!=., percent cformat(%9.1f)
proportion siteid if commute_wk!=., over(gender) percent cformat(%9.1f)

proportion residential if commute_wk!=., percent cformat(%9.1f)
proportion residential if commute_wk!=., over(gender) percent cformat(%9.1f)


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





