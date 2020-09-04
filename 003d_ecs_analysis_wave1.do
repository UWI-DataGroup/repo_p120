** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			        implementing the Framingham and ACC/AHA CVD risk scores.

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\ecs_analysis_wave1_001", replace

** HEADER -----------------------------------------------------

** Load ECHORN wave 1 dataset
local PATH ""`datapath'/version03/02-working/survey_wave1_weighted""
use `PATH', clear

***************************************************************
*   PART 1: PREPARE SOCIAL DETERMINANTS, RISK FACTOR, AND DISEASE VARIABLES
***************************************************************

* AGE GROUPS
* AGE IN 10 YEAR BANDS (40-49, 50-59, 60-69, 70+)
gen age_gr2 =.
replace age_gr2= 1 if partage >=40 & partage <50
replace age_gr2= 2 if partage >=50 & partage <60
replace age_gr2= 3 if partage >=60 & partage <70
replace age_gr2= 4 if partage >=70 & partage <.
label variable age_gr2 "Age in 10 yr bands"
label define age_gr2 1 "40-49 years" 2 "50-59 years" 3 "60-69 years" 4 "70+ years"
label values age_gr2 age_gr2

** GENDER indicators
gen female = (gender==2) if !missing(gender)
gen male = (gender==1) if !missing(gender)

** AGE indicators
drop agegr
gen age40 = (age_gr2==1) if !missing(age_gr2)
gen age50 = (age_gr2==2) if !missing(age_gr2)
gen age60 = (age_gr2==3) if !missing(age_gr2)
gen age70 = (age_gr2==4) if !missing(age_gr2)


** EDUCATION
**GROUPED AS FOLLOWS: 1) less than high school; 2) high school graduate; 3) associates degree or some college; 4) College degree    

gen educ=.
replace educ=1 if D13==0 | D13==1 | D13==2
replace educ=2 if D13==3
replace educ=3 if D13==4 | D13==5
replace educ=4 if D13==6 | D13==7 | D13==8 | D13==9
label variable educ "Education categories"
label define educ 1 "less than high school" 2 "high school graduate" 3 "associates degree/some college" 4 "college degree"
label values educ educ
gen primary_plus  = (educ==1)
gen second = (educ==2)
gen second_plus = (educ==3)
gen tertiary = (educ==4) 

** OCCUPATION: grouped as skilled, semi-skilled, and unskilled labour
gen prof = (Major_Category_Code==1|Major_Category_Code==2|Major_Category_Code==3)
label variable prof "professional occupation"
gen semi_prof = (Major_Category_Code==4|Major_Category_Code==5|Major_Category_Code==6|Major_Category_Code==7|Major_Category_Code==8)
label variable semi_prof "semi-professional occupation"
gen non_prof = (Major_Category_Code==9)
label variable non_prof "non-professional occupation"
gen occ=.
replace occ=1 if (Major_Category_Code==1|Major_Category_Code==2|Major_Category_Code==3)
replace occ=2 if (Major_Category_Code==4|Major_Category_Code==5|Major_Category_Code==6|Major_Category_Code==7|Major_Category_Code==8)
replace occ=3 if (Major_Category_Code==9)
label variable occ "occupational group"
label define occ 1 "Professional" 2 "Semi-professional" 3 "Non-professional"
label values occ occ 



** PLACE OF RESIDENCE: NEIGHBORHOOD CHARACTERISTICS (JACKSON HEART STUDY THIRD YEAR QUESTIONNAIRE)
** NOTES: CLARK ET AL ONLY USE ONE VARIABLE (PERCEIVED NEIGHBORHOOD SAFETY); WILL USE THAT ON IT'S OWN, BUT WILL ALSO CREATE A SCALE USING OTHER QUESTIONS.

** Perceived safety: from Clark et al: Participants who agreed or strongly agreed were categorized as perceiving their neighborhood as safe; those who disagreed 
** or strongly disagreed were categorized as perceiving their neighborhood as unsafe.
generate percsafe=.
replace percsafe=0 if SE17==1 | SE17==2
replace percsafe=1 if SE17==3 | SE17==4
label variable percsafe "Perceived neighborhood safety"
label define percsafe 0 "Unsafe" 1 "Safe"
label values percsafe percsafe  

** CREATE NEIGHBORHOOD ATTRIBUTE SCORE (based on SE12-17)
**Positive attributes:
    foreach x in SE12 SE13 SE14 SE15 SE17 {
        generate `x'_score=.
        replace `x'_score = -2 if `x'==1
        replace `x'_score = -1 if `x'==2
        replace `x'_score = 1 if `x'==3
        replace `x'_score = 2 if `x'==4
    order `x', before(`x'_score)
}

**Negative attribute
generate SE16_score=.
replace SE12_score=2 if SE12==1
replace SE12_score=1 if SE12==2
replace SE12_score=-1 if SE12==3
replace SE12_score=-2 if SE12==4

**CREATE PROBLEMS WITH NEIGHBORHOOD SCORE (SE18-24)
foreach x in SE18 SE19 SE20 SE21 SE22 SE23 SE24 {
    generate `x'_score=.
    replace `x'_score=0 if `x'==0
    replace `x'_score=-1 if `x'==1
    replace `x'_score=-2 if `x'==2
    replace `x'_score=-3 if `x'==3
}

egen hood_score=rowmean(SE12_score SE13_score SE14_score SE15_score SE17_score SE16_score SE18_score SE19_score SE20_score SE21_score SE22_score SE23_score SE24_score)
histogram hood_score



** DESCRIPTION OF RACE/ETHNICITY 

/*There are multiple questions for race/ethnicity (D4A-I), each with a yes/no option. One of these options is mixed or multi-racial. Suggesting that these be summarised into 
1 variable. If multiple race categories are selected, these will be recoded into 'mixed' category. The exception is people who self identified as Black/African and Caribbean 
- they will be categorised as Black/Afro-Caribbean */

egen mixrace=rowtotal(D4A D4B D4C D4D D4E D4F D4G D4H D4I) 
order mixrace, after(D4I)

gen race=.
replace race=1 if D4A==1
replace race=2 if D4B==1
replace race=2 if D4C==1
replace race=3 if D4D==1
replace race=4 if D4E==1
replace race=5 if D4F==1
replace race=6 if D4G==1
replace race=7 if D4H==1
replace race=8 if D4I==1
replace race=6 if mixrace>1
replace race=2 if D4B==1 & D4C==1
replace race=6 if mixrace>2
order race, after(mixrace)
label variable race "race(self-identified)"
label define race 1 "White" 2 "Black/Afro-Caribbean" 3 "Asian" 4 "East Indian" 5 "Hispanic/Latino" 6 "Mixed" 7 "Other" 8 "Puerto Rican/Boricua"
label values race race 
*list D4A D4B D4C D4D D4E D4F D4G D4H D4I race if mixrace>1 & _n<200 

**   DESCRIPTION OF RELIGION IN ECHORN DATASET
*current religious denomination
tab D14 siteid, col miss /// not going to use this one

*to what extent do you consider yourself a religious person
tab D18 siteid, col miss // recode so numbers reflect extent of religiousness
gen religious=.
replace religious=0 if D18==4
replace religious=1 if D18==3
replace religious=2 if D18==2
replace religious=3 if D18==1
label variable religious "Self-reported religiousness"
label define religious 0 "not religious" 1 "slightly religious" 2 "Moderately religious" 3 " Very religious"
label values religious religious 


*to what extent do you consider yourself a spiritual person
tab D19 siteid, col miss
gen spirit=. // recode so numbers reflect extent of religiousness
replace spirit=0 if D19==4
replace spirit=1 if D19==3
replace spirit=2 if D19==2
replace spirit=3 if D19==1
label variable spirit "Self-reported spirituality"
label define spirit 0 "not spritual" 1 "slightly spritual" 2 "Moderately spritual" 3 " Very spritual"
label values spirit spirit 

*How often do you go to religious services (excluding for funerals and weddings)?
tab D16 siteid, col miss

** PERCEIVED LEVEL OF INCOME RELATIVE TO REST OF POPULATION
* Look at this figure with steps numbered 1 at the bottom to 10 at the top. If top of the ladder represents the richest people of this island and the bottom represents 
* the poorest people of this island, on what number step would you place yourself? */
tab D7 siteid, col miss
histogram D7, by(siteid) width(1)

** SOCIAL SUPPORT
*  DESCRIPTION OF EMOTIONAL SUPPORT IN ECHORN DATASET (SE1 - SE4; PROMIS EMOTIONAL SUPPORT)
*I have someone who will listen to me when I need to talk.
tab SE1 siteid, col miss
*I have someone to confide in or talk to about myself or my problems.
tab SE2 siteid, col miss
*I have someone who makes me feel appreciated.
tab SE3 siteid, col miss
*I have someone to talk with when I have a bad day.
tab SE4 siteid, col miss
**create emotional support score
egen promis=rowmean(SE1 SE2 SE3 SE4)
label variable promis "PROMIS emotional support score"
codebook promis

** DESCRIPTION OF SOCIAL SUPPORT IN ECHORN DATASET (SE7 - SE11; Jackson heart study social support)

*How many close friends do you have (people you feel at ease with, can talk to about private matters, and can call on for help)?
codebook SE7 if siteid==1 // USVI: Range: 0-55; missing: 8 (2%); median (IQR): 3 (2,5)
codebook SE7 if siteid==2 // PR: Range: 0-90; missing: 7 (1%); median (IQR): 3 (2,5) 
codebook SE7 if siteid==3 //Bds: Range: 0-58; missing: 51 (5%); median (IQR): 3 (1,5)
codebook SE7 if siteid==4 //T'dad: Range: 0,90; missing: 21 (2%); median (IQR): 3 (2,5)

*How many relatives do you have that you feel close to?
codebook SE8 if siteid==1 // USVI: Range: 0-80; missing: 3 (1%); median (IQR): 5 (2,8)
codebook SE8 if siteid==2 // PR: Range: 0-50; missing: 6 (1%); median (IQR): 3 (2,5)  
codebook SE8 if siteid==3 //Bds: Range: 0-75; missing: 61 (6%); median (IQR): 4 (3,7)
codebook SE8 if siteid==4 //T'dad: Range: 0-90; missing: 16 (2%); median (IQR): 4 (2,6)  

*How many of these friends or relatives do you see at least once per month?
codebook SE9 if siteid==1 // USVI: Range: 0-88; missing: 6 (2%); median (IQR): 3 (2,5) 
codebook SE9 if siteid==2 // PR: Range: 0-91; missing: 6 (1%); median (IQR): 5 (3,8)  
codebook SE9 if siteid==3 //Bds: Range:0-70; missing: 55 (5%); median (IQR): 4 (2,6)
codebook SE9 if siteid==4 //T'dad: Range: 0-55; missing: 26 (3%); median (IQR): 4 (2,6) 

*Do you belong to any social, recreational, work, church, or other community groups? (for example, PTA, neighborhood watch, etc.)?
tab SE10 siteid, col miss

/*  Do you |
 belong to |
       any |
   social, |
recreation |
 al, work, |
church, or |
     other |
 community |                    Site
         g | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
-----------+--------------------------------------------+----------
        No |       162        399        406        423 |     1,390 
           |     45.89      51.75      40.28      51.03 |     46.94 
-----------+--------------------------------------------+----------
       Yes |       188        371        565        401 |     1,525 
           |     53.26      48.12      56.05      48.37 |     51.50 
-----------+--------------------------------------------+----------
         . |         3          1         37          5 |        46 
           |      0.85       0.13       3.67       0.60 |      1.55 
-----------+--------------------------------------------+----------
     Total |       353        771      1,008        829 |     2,961 
           |    100.00     100.00     100.00     100.00 |    100.00  */

*What is the total number of groups to which you belong?
recode SE11 .z=0 
codebook SE11 if siteid==1 // USVI: Range: 0-20; missing: 5 (1%); median (IQR): 1 (0,2) 
codebook SE11 if siteid==2 // PR: Range: 0-20; missing: 3 (0%); median (IQR): 0 (0,1)
codebook SE11 if siteid==3 //Bds: Range: 0-20; missing: 6 (1%); median (IQR): 0 (0,1) 
codebook SE11 if siteid==4 //T'dad: Range: 0-19; missing: 9; median (IQR): 0 (0,2)

**create total score
egen emotion=rowmean(SE7 SE8 SE9 SE10 SE11)
label variable emotion "JHS emotional support scale"
codebook emotion 

***********************************************************************************************
*   MENTAL HEALTH
***********************************************************************************************
** Depression score 
egen depress=rowtotal(GH248 GH249)
label variable depress "PHQ-2 Depression score"

*ALCOHOL CONSUMPTION: % with 1 or more heavy episodic drinking events in past 30 days
*generate variable to describe prevalence of binge drinking in the past 30 days
gen binge=.
replace binge=1 if HB57M>=1 & HB57M<. 
replace binge=0 if HB57M==0 
replace binge=0 if HB57M==.z & gender==1  
replace binge=1 if HB57W>=1 & HB57W<. 
replace binge=0 if HB57W==0 
replace binge=0 if HB57W==.z & gender==2
*consistency checks: did people who never consumed an alcoholic drink in their life enter an age they started drinking alcohol or say that they currently drink alcohol?
list key if HB46==0 & HB47!=.z 
list key if HB46==0 & HB55!=.z 
*prevalence of binge drinking
label variable binge "at least 1 episode of binge drinking in past 30 days"
label define binge 0 "No binge drinking" 1 "Binge drinking"
label values binge binge 


**FRUIT AND VEG INTAKE: Can't calculate inadequate fruit and veg intake, as the number of days fruit and veg are eaten are collected, but portion size is not. Using days that ate fruit + days ate veg
egen fv=rowtotal(NU12 NU13) 
label variable fv "Days on which fruit and veg were eaten"
**food security
egen foodsec=rowmean( NU88 NU89 NU90 NU91 NU92 NU93 NU94 NU95 NU96)

** PHYSICAL INACTIVITY
    ** *********************************************************************************************************************************************************
    * Starting with looking at prevalence of inactivity according to WHO guidelines: 150 minutes of moderate intensity activity per week OR 75 minutes of vigorous intensity 
    * per week OR an equivalent combination, achieving at least 600 MET-minutes per week. 
    *********************************************************************************************************************************************************
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

                    *Calculating min per week for vigorous work
                    gen mpwVW=mpdVW*HB2 
                    replace mpwVW=.z if HB2==.z

                    *Calculating MET-min per week for vigorous work (assuming MET value of 8 for vigorous work)
                    gen VWMET=mpwVW*8
                    replace VWMET=.z if HB2==.z
                    label variable VWMET "MET-min per week from vigorous work"
                    *histogram VWMET, by(siteid)
                    table siteid, c(median VWMET)

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

                    *Calculating min per week for moderate intensity work
                    gen mpwMW=mpdMW*HB6  
                    replace mpwMW=.z if HB6==.z 

                    *Calculating MET-min per week for moderate intensity work (assuming MET value of 4 for moderate work)
                    gen MWMET=mpwMW*4
                    replace MWMET=.z if HB6==.z 
                    label variable MWMET "MET-min per week from moderate work"
                    *histogram MWMET, by(siteid)
                    table siteid, c(median MWMET) 

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


                    * If answered "no" to HB9, then HB10 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
                    recode HB10 0=.z
                    list HB10 if HB9==.
                    replace HB10=.z if HB9==0 | HB9==.
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
                    gen mpwT=mpdMW*HB10 
                    replace mpwT=.z if HB10==.z 

                    *Calculating MET-min per week for active transport (assuming MET value of 4 for active transport)
                    gen TMET=mpwT*4
                    replace TMET=.z if HB10==.z 
                    label variable TMET "MET-min per week from active transport"
                    *histogram TMET, by(siteid)
                    table siteid, c(median TMET)

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

                    *Calculating min per week for vigorous recreational activity
                    gen mpwVR=mpdVR*HB14
                    replace mpwVR=.z if HB14==.z 

                    *Calculating MET-min per week for vigorous recreational activity (assuming MET value of 8 for vigorous recreational activity)
                    gen VRMET=mpwVR*8
                    replace VRMET=.z if HB14==.z 
                    label variable VRMET "MET-min per week from vigorous recreational activity"
                    *histogram VRMET, by(siteid)
                    table siteid, c(median VRMET)

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

                    *Calculating min per week for moderate recreational activity
                    gen mpwMR=mpdMR*HB18
                    replace mpwMR=.z if HB18==.z 

                    *Calculating MET-min per week for moderate recreational activity (assuming MET value of 4 for moderate recreational activity)
                    gen MRMET=mpwMR*4
                    replace MRMET=.z if HB18==.z 
                    label variable MRMET "MET-min per week from moderate recreational activity"
                    *histogram MRMET, by(siteid)
                    table siteid, c(median MRMET) 

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



**OBESE/OVERWEIGHT
**BMI
gen ht = height/100
gen bmi = weight/(ht*ht)
label var ht "height in m"
label var bmi "Body mass index"

**overweight
gen ow = 0
replace ow = 1 if bmi >=25 & bmi <.
replace ow =. if height ==. | weight ==.
label variable ow "overweight"
label define ow 0 "no" 1 "yes"
label values ow ow
**obese
gen ob=0
replace ob = 1 if bmi >=30 & bmi <.
replace ob =. if height ==. | weight ==.
tab ob, miss
label define ob 0 "not obese" 1 "obese"
label variable ob "obesity"
label values ob ob
**obesity categories
gen ob4 = 0
replace ob4 = 1 if bmi>=25
replace ob4 = 2 if bmi>=30
replace ob4 = 3 if bmi>=35
replace ob4 = 4 if bmi>=40
replace ob4 = . if weight==. | height==.
label variable ob4 "obesity category"
label define ob4 0 "not obese" 1 "bmi: 25-<30" 2 "bmi: 30-<35" 3 "bmi:35-<40" 4 "bmi: >40"
label values ob4 ob4

**PREVIOUS DIAGNOSIS MI, stroke, angina
rename GH29D mi
rename GH32 stroke
rename GH29B angina
rename GH29A chd
rename GH29C a_rtm
rename GH29E hf


***************************************************************
*   PART 2: MERGE WITH RISK SCORE DATASET
***************************************************************

** Merge with framingham risk dataset 
merge 1:1 key using "`datapath'/version03/02-working/wave1_framingham_cvdrisk"
drop _merge 



**Missing variables by site
*age
codebook partage // no missing
*cholesterol
codebook fram_tchol
codebook fram_tchol if siteid==1
dis 108/353
codebook fram_tchol if siteid==2
dis 4/77
codebook fram_tchol if siteid==3
dis 331/1008
*HDL chol
codebook fram_hdl if siteid==1
dis 109/353
codebook fram_hdl if siteid==2
dis 4/771
codebook fram_hdl if siteid==3
dis 327/1008
codebook fram_hdl if siteid==4
dis 176/829
*SBP if untreated
codebook fram_sbp if siteid==1
dis 4/353
codebook fram_sbp if siteid==2
dis 5/771
codebook fram_sbp if siteid==3
dis 6/1008
codebook fram_sbp if siteid==4
dis 1/829
*self-reported treated for HTN
codebook fram_sbptreat // no missing
*smoking
codebook fram_smoke
codebook fram_smoke if siteid==1
dis 17/353
codebook fram_smoke if siteid==2
dis 3/771
codebook fram_smoke if siteid==3
dis 47/1008
codebook fram_smoke if siteid==4
dis 16/829

*drop optimal_tchol optimal_hdl age_gr
keep key siteid gender partage stroke chd angina a_rtm mi hf MET_grp predsugnc predssb fruit_per_week veges_week veges_and_fruit_per_week /// 
age_gr2 female male educ prof semi_prof non_prof binge inactive ht bmi ow ob ob4 fram_sbp fram_sbptreat fram_smoke                        ///
fram_diab fram_hdl fram_tchol fram_age risk10 risk10_cat optrisk10 fram_sex primary_plus second_plus tertiary prof semi_prof non_prof occ  /// 
bp_diastolic bmirisk10 bmirisk10_cat percsafe hood_score race religious spirit D16 D7 D10 D11 D12 SE25 SE26 promis emotion foodsec totMETmin depress

rename bmirisk10 nolabrisk10
rename bmirisk10_cat nolabrisk10cat

order key gender fram_sex female male partage fram_age age_gr2                              ///
         binge bmi ow ob ob4 fram_sbp fram_sbptreat fram_smoke fram_diab fram_tchol         ///
         primary_plus second_plus tertiary prof semi_prof non_prof depress                  ///
         risk10 nolabrisk10 risk10_cat nolabrisk10cat optrisk10 mi stroke angina            ///
          

label var female "Female (1=yes, 0=no)"
label var male "Male (1=yes, 0=no)"

** Save the prepared HotN dataset
label data "ECHORN wave 1 (version 03FEB2020): Prepared dataset for CVD risk analysis"
save "`datapath'/version03/02-working/wave1_framingham_cvdrisk_prepared", replace
