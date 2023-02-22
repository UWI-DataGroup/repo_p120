**  DO-FILE METADATA
//  algorithm name						ecs_progress_rf
//  project:							ECHORN CVD analysis
//  analysts:							Christina HOWITT
//	date last modified		                  22-July-2019

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
cap log using "`logpath'\ecs_progress_rf", replace

**Open dataset
use "`datapath'\version02\2-working\survey_wave1_weighted", clear 

/*********************************************************************************************************************************************************
*   DESCRIPTION OF GENDER IN ECHORN DATASET 
*********************************************************************************************************************************************************
tab gender siteid, col miss

/*           |                    Site
    Gender | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
-----------+--------------------------------------------+----------
      Male |       140        262        306        320 |     1,028 
           |     39.66      33.98      30.36      38.60 |     34.72 
-----------+--------------------------------------------+----------
    Female |       213        509        702        509 |     1,933 
           |     60.34      66.02      69.64      61.40 |     65.28 
-----------+--------------------------------------------+----------
     Total |       353        771      1,008        829 |     2,961 
           |    100.00     100.00     100.00     100.00 |    100.00 */

**any transgender?
tab D10 siteid, col miss

/*
  Are you transgender |                    Site
      or transsexual? | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
----------------------+--------------------------------------------+----------
                   No |       190        742        621        555 |     2,108 
                      |     53.82      96.24      61.61      66.95 |     71.19 
----------------------+--------------------------------------------+----------
  Yes, Male to Female |         7          3         22         10 |        42 
                      |      1.98       0.39       2.18       1.21 |      1.42 
----------------------+--------------------------------------------+----------
  Yes, Female to Male |         3          2         14         13 |        32 
                      |      0.85       0.26       1.39       1.57 |      1.08 
----------------------+--------------------------------------------+----------
Yes, Gender non-confo |         2          4          3          4 |        13 
                      |      0.57       0.52       0.30       0.48 |      0.44 
----------------------+--------------------------------------------+----------
Not sure what this qu |        20         10         83        166 |       279 
                      |      5.67       1.30       8.23      20.02 |      9.42 
----------------------+--------------------------------------------+----------
                    . |       131         10        265         81 |       487 
                      |     37.11       1.30      26.29       9.77 |     16.45 
----------------------+--------------------------------------------+----------
                Total |       353        771      1,008        829 |     2,961 
                      |    100.00     100.00     100.00     100.00 |    100.00    */


*********************************************************************************************************************************************************
*   DESCRIPTION OF AGE IN ECHORN DATASET
*********************************************************************************************************************************************************
codebook partage // range: 40-91; mean (SD): 57.3 (10.3); median (IQR): 57 (49-64) No missing
codebook partage if siteid==1  // range: 40-81; mean (SD): 57.1 (9.4); median (IQR): 57 (50-65)
codebook partage if siteid==2 // range: 40-91; mean (SD): 58.3 (10.6); median (IQR): 57 (51-65)
codebook partage if siteid==3 // range: 40-88; mean (SD): 57.4 (10.4); median (IQR): 57 (50-65)
codebook partage if siteid==4 // range: 40-87; mean (SD): 56.2 (10.4); median (IQR): 55 (48-63)

*********************************************************************************************************************************************************
*   DESCRIPTION OF 'PLACE' IN ECHORN DATASET
*********************************************************************************************************************************************************
**USVI: In what neighborhood do you currently reside?
tab D73US if siteid==1, miss 

**Puerto Rico: In what neighborhood do you currently reside?
tab D73US if siteid==2, miss

**Barbados: In what neighborhood do you currently reside? Specify address or parish.
tab D73BB, miss   

**Trinidad: In what district do you live? For example, St Augustine
tab D73TT, miss 


*********************************************************************************************************************************************************
*   DESCRIPTION OF EDUCATION IN ECHORN DATASET
*********************************************************************************************************************************************************
*numlabel, add mask("#",) // why won't this work? Looked in variables manager for numerical codes instead. Values are labelled 0-9
tab D13, miss
/*
What is the highest year of school that |
                         you COMPLETED? |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
No schooling, or less than 1 year of sc |         37        1.25        1.25
Nursery, kindergarten, and elementary ( |        415       14.02       15.27
High school (grades 9 thru 12, no degre |        570       19.25       34.52
   High school graduate (or equivalent) |        675       22.80       57.31
 Some college (1 to 4 years, no degree) |        369       12.46       69.77
Associate's degree (including occupatio |        244        8.24       78.01    (An associate degree is an undergraduate degree awarded, primarily in the United States, after a course of post-secondary study lasting two or three years. It is a level of qualification between a high school diploma or GED and a bachelor's degree.)
   Bachelor's degree (BA, BS, AB, etc.) |        330       11.14       89.16
Master's degree (MA, MS, MENG, MSW, etc |        138        4.66       93.82
Professional school degree (MD, DDC, JD |         29        0.98       94.80    (Professional school programs help prepare students for careers in specific fields. Examples include medical, law, pharmacy, business, library, and social work schools. The length of these programs vary. Professional degrees are often required by law before an individual can begin a certain working in a particular occupation.)
      Doctorate degree (PhD, EdD, etc.) |         20        0.68       95.47
                                      . |        134        4.53      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,961      100.00                 

Need to develop a reduced categorisation. Suggesting the following: 1) less than high school; 2) high school graduate; 3) associates degree or some college; 4) College degree    
*/

gen educ=.
replace educ=1 if D13==0 | D13==1 | D13==2
replace educ=2 if D13==3
replace educ=3 if D13==4 | D13==5
replace educ=4 if D13==6 | D13==7 | D13==8 | D13==9
label variable educ "Education categories"
label define educ 1 "less than high school" 2 "high school graduate" 3 "associates degree/some college" 4 "college degree"
label values educ educ 

tab educ, miss
tab educ siteid, col miss

/*
                      |                    Site
 Education categories | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
----------------------+--------------------------------------------+----------
less than high school |       127        107        402        386 |     1,022 
                      |     35.98      13.88      39.88      46.56 |     34.52 
----------------------+--------------------------------------------+----------
 high school graduate |        64        149        298        164 |       675 
                      |     18.13      19.33      29.56      19.78 |     22.80 
----------------------+--------------------------------------------+----------
associates degree or  |        80        219        155        159 |       613 
                      |     22.66      28.40      15.38      19.18 |     20.70 
----------------------+--------------------------------------------+----------
       college degree |        73        294         62         88 |       517 
                      |     20.68      38.13       6.15      10.62 |     17.46 
----------------------+--------------------------------------------+----------
                    . |         9          2         91         32 |       134 
                      |      2.55       0.26       9.03       3.86 |      4.53 
----------------------+--------------------------------------------+----------
                Total |       353        771      1,008        829 |     2,961 
                      |    100.00     100.00     100.00     100.00 |    100.00    */




*********************************************************************************************************************************************************
*   DESCRIPTION OF OCCUPATION IN ECHORN DATASET
*********************************************************************************************************************************************************
** Work status over the past week
tab D20, miss 
tab D20 siteid, col miss
/*
What were you doing |
during the past week? |                    Site
            Were you: | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
----------------------+--------------------------------------------+----------
              Working |       237        327        470        464 |     1,498 
                      |     67.14      42.41      46.63      55.97 |     50.59 
----------------------+--------------------------------------------+----------
Not working but have  |        19         27         69         61 |       176 
                      |      5.38       3.50       6.85       7.36 |      5.94 
----------------------+--------------------------------------------+----------
          Not working |        74        379        380        265 |     1,098 
                      |     20.96      49.16      37.70      31.97 |     37.08 
----------------------+--------------------------------------------+----------
     Looking for work |        19         32         39         19 |       109 
                      |      5.38       4.15       3.87       2.29 |      3.68 
----------------------+--------------------------------------------+----------
                    . |         4          6         50         20 |        80 
                      |      1.13       0.78       4.96       2.41 |      2.70 
----------------------+--------------------------------------------+----------
                Total |       353        771      1,008        829 |     2,961 
                      |    100.00     100.00     100.00     100.00 |    100.00    */


**What is the main reason you did not work last week?
tab D21 siteid, col miss 

**Main occupation
codebook D27  // this is a free text variable with some spanish and some english 

*********************************************************************************************************************************************************
*   DESCRIPTION OF RACE/ETHNICITY IN ECHORN DATASET
*********************************************************************************************************************************************************
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
list D4A D4B D4C D4D D4E D4F D4G D4H D4I race if mixrace>1 & _n<200 

**looking at "other race"
codebook race // 39 "other"
list D5 if race==7  // 24/39 have classified themselves as other - Bajan! Can these be recoded to Black/Afro-Caribbean? Some of the others look possible to recode also (e.g. Afro-Caribbean, Black)

tab race siteid, col miss
/*
race(self-identified |                    Site
                   ) | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
---------------------+--------------------------------------------+----------
               White |        31        133          3          3 |       170 
                     |      8.78      17.25       0.30       0.36 |      5.74 
---------------------+--------------------------------------------+----------
Black/Afro-Caribbean |       230        105        855        296 |     1,486 
                     |     65.16      13.62      84.82      35.71 |     50.19 
---------------------+--------------------------------------------+----------
               Asian |         0          0          0          1 |         1 
                     |      0.00       0.00       0.00       0.12 |      0.03 
---------------------+--------------------------------------------+----------
         East Indian |         7          0          5        199 |       211 
                     |      1.98       0.00       0.50      24.00 |      7.13 
---------------------+--------------------------------------------+----------
     Hispanic/Latino |        21        149          0          2 |       172 
                     |      5.95      19.33       0.00       0.24 |      5.81 
---------------------+--------------------------------------------+----------
               Mixed |        28        189         32        232 |       481 
                     |      7.93      24.51       3.17      27.99 |     16.24 
---------------------+--------------------------------------------+----------
               Other |         5          4         27          3 |        39 
                     |      1.42       0.52       2.68       0.36 |      1.32 
---------------------+--------------------------------------------+----------
Puerto Rican/Boricua |         2        168          0          0 |       170 
                     |      0.57      21.79       0.00       0.00 |      5.74 
---------------------+--------------------------------------------+----------
                   . |        29         23         86         93 |       231 
                     |      8.22       2.98       8.53      11.22 |      7.80 
---------------------+--------------------------------------------+----------
               Total |       353        771      1,008        829 |     2,961 
                     |    100.00     100.00     100.00     100.00 |    100.00    */


**How do others classify your race/ethnicity?
tab D6 siteid, col miss


*********************************************************************************************************************************************************
*   DESCRIPTION OF RELIGION IN ECHORN DATASET
*********************************************************************************************************************************************************
*current religious denomination
tab D14 siteid, col miss

*to what extent do you consider yourself a religious person
tab D18 siteid, col miss

*to what extent do you consider yourself a spiritual person
tab D19 siteid, col miss

*How often do you go to religious services (excluding for funerals and weddings)?
tab D16 siteid, col miss


*********************************************************************************************************************************************************
*   DESCRIPTION OF INCOME IN ECHORN DATASET
*********************************************************************************************************************************************************
*US sites (annual, monthly, weekly)
tab D36A if siteid==1 | siteid==2, miss
tab D36M if siteid==1 | siteid==2, miss
tab D36W if siteid==1 | siteid==2, miss

*Barbados (annual, monthly, weekly)
tab D38A if siteid==3, miss
tab D38M if siteid==3, miss
tab D38W if siteid==3, miss

*Trinidad (annual, monthly, weekly)
tab D37A if siteid==4, miss
tab D37M if siteid==4, miss
tab D37W if siteid==4, miss

/*Assets: Suppose you needed money and you cashed in all of your (and your partner's) checking and savings accounts, cars,etc. If you added up what you get, about how 
much would it amount to? What is your best estimate based on this list. */
*US sites
tab D58, miss 
*Trinidad
tab D59, miss
*Barbados
tab D60, miss

*If you now subtracted out any debt that you have (credit card debt, unpaid loans including car loans, home mortgage), about how much would you have left?
tab D61 siteid, col miss  

/*Look at this figure with steps numbered 1 at the bottom to 10 at the top. If the ladder represents the richest people of this island and the bottom represents 
the poorest people of this island, on what number step would you place yourself? */
*histogram D7, by(siteid) width(1)


*********************************************************************************************************************************************************
*   DESCRIPTION OF EMOTIONAL SUPPORT IN ECHORN DATASET (SE1 - SE4)
*********************************************************************************************************************************************************
*I have someone who will listen to me when I need to talk.
tab SE1 siteid, col miss
*I have someone to confide in or talk to about myself or my problems.
tab SE2 siteid, col miss
*I have someone who makes me feel appreciated.
tab SE3 siteid, col miss
*I have someone to talk with when I have a bad day.
tab SE4 siteid, col miss

*********************************************************************************************************************************************************
*   DESCRIPTION OF SOCIAL SUPPORT IN ECHORN DATASET (SE7 - SE11)
*********************************************************************************************************************************************************
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


*********************************************************************************************************************************************************
*   DESCRIPTION OF PHYSICAL ACTIVITY IN ECHORN DATASET
*********************************************************************************************************************************************************
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
gen mpwT=mpdT*HB10 
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
tab inactive siteid, col miss 
tab inactive siteid if gender==1, col miss
tab inactive siteid if gender==2, col miss


/*inactive |
       WHO |
recommenda |                    Site
     tions | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
-----------+--------------------------------------------+----------
    active |       160        273        555        429 |     1,417 
           |     45.33      35.41      55.06      51.75 |     47.86 
-----------+--------------------------------------------+----------
  inactive |       189        493        449        393 |     1,524 
           |     53.54      63.94      44.54      47.41 |     51.47 
-----------+--------------------------------------------+----------
         . |         4          5          4          7 |        20 
           |      1.13       0.65       0.40       0.84 |      0.68 
-----------+--------------------------------------------+----------
     Total |       353        771      1,008        829 |     2,961 
           |    100.00     100.00     100.00     100.00 |    100.00 */

tab inactive gender if siteid==3 & partage>=45 & partage<65, col miss // comparing to HotN RPAQ out of interest in 45-64 age group (inactive men: 35%; women: 63%) 

 /*inactive|
       WHO |
recommenda |        Gender
     tions |      Male     Female |     Total
-----------+----------------------+----------
    active |       117        230 |       347 
           |     63.24      52.39 |     55.61 
-----------+----------------------+----------
  inactive |        67        208 |       275 
           |     36.22      47.38 |     44.07 
-----------+----------------------+----------
         . |         1          1 |         2 
           |      0.54       0.23 |      0.32 
-----------+----------------------+----------
     Total |       185        439 |       624 
           |    100.00     100.00 |    100.00  */



*********************************************************************************************************************************************************
*   DESCRIPTION OF BINGE DRINKING IN ECHORN DATASET 
*********************************************************************************************************************************************************
*(Ask of Men Only) Considering all types of alcoholic beverages, how many times during the past 30 days did you have five or more drinks on an occasion?
codebook HB57M 
*(Ask of Women Only) Considering all types of alcoholic beverages, how many times during the past 30 days did you have four or more drinks on an occasion?
codebook HB57W
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
tab binge siteid, col miss 
*men
tab binge siteid if gender==1, col miss
*women
tab binge siteid if gender==2, col miss

*********************************************************************************************************************************************************
*   DESCRIPTION OF CURRENT TOBACCO SMOKING IN ECHORN DATASET 
*********************************************************************************************************************************************************
tab HB26 siteid, col miss 
gen csmoke=.
replace csmoke=0 if HB26==0 | HB26==.z 
replace csmoke=1 if HB26==1
label variable csmoke "current regular smoker"
label define csmoke 0 "Non-smoker" 1 "Current regular smoker"
label values csmoke csmoke
tab csmoke siteid, miss col 

/*
      current regular |                    Site
               smoker | US Virgin  Puerto Ri   Barbados  Trinidad  |     Total
----------------------+--------------------------------------------+----------
           Non-smoker |       319        676        923        730 |     2,648 
                      |     90.37      87.68      91.57      88.06 |     89.43 
----------------------+--------------------------------------------+----------
Current regular smoke |        17         92         38         83 |       230 
                      |      4.82      11.93       3.77      10.01 |      7.77 
----------------------+--------------------------------------------+----------
                    . |        17          3         47         16 |        83 
                      |      4.82       0.39       4.66       1.93 |      2.80 
----------------------+--------------------------------------------+----------
                Total |       353        771      1,008        829 |     2,961 
                      |    100.00     100.00     100.00     100.00 |    100.00  */

                      

********************************************************************************************************************
* Missing report by variable
********************************************************************************************************************

/* Variable groups are as follows:
Description           Variable name
Gender                gender
Age                   partage 
Education             D13 (derived: educ)
Employment            D20
Race/ethnicity        D4A D4B D4C D4D D4E D4F D4G D4H D4I (derived: race)
Religion              D14 D16 D18 D19
Income                D36A D36M D36W D37A D37M D37W D38A D38M D38W
Emotional support     SE1 - SE4
Social support        SE7 - SE11
Physical activity     HB1 - HB20 (derived: inactive)
Binge drinking        HB57M HB57F (derived: binge)
              
*/

/*Create indicator variable for missing
foreach x in gender partage D13 educ D20 D4A D4B D4C D4D D4E D4F D4G D4H D4I race  D14 D16 D18 D19 D36A D36M D36W D37A D37M D37W D38A D38M D38W SE1 SE2 SE3 SE4 SE7 SE11 ///
HB1 HB2 HB3 HB4 HB5 HB6 HB7 HB8 HB9 HB10 HB11 HB12 HB13 HB14 HB15 HB16 HB17 HB18 HB19 HB20 HB57M HB57F binge {

  qui gen `x'miss=0
  qui replace `x'miss=1 if `x'==.
}

*/

*gender 
tab gender siteid, col nofreq miss 
*age
codebook partage 
*education
tab D13 siteid, col nofreq miss 
tab educ siteid, col nofreq miss 
*employment
tab D20 siteid, col nofreq miss 
*race
tab race siteid, col nofreq miss 
*religion 
tab D14, miss
tab D16, miss
tab D18, miss
tab D19, miss  // No .z for any of these
      preserve
            rename D14 RE1 
            rename D16 RE2 
            rename D18 RE3 
            rename D19 RE4 
            keep siteid key RE1 RE2 RE3 RE4 
            reshape long RE, i(key siteid) j(varnum)          
            tab RE siteid, col nofreq miss 
      restore
*income
      preserve 
            rename D36A inc1
            rename D36M inc2
            rename D36W inc3
            rename D37A inc4
            rename D37M inc5
            rename D37W inc6
            rename D38A inc7
            rename D38M inc8
            rename D38W inc9 
            keep siteid key inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9
            reshape long inc, i(key siteid) j(varnum) 
      restore
*emotional support
      preserve
            keep siteid key SE1 SE2 SE3 SE4 
            reshape long SE, i(key siteid) j(varnum)  
            tab SE siteid, col nofreq miss 
      restore 
*social support
      preserve  
            keep siteid key SE7 SE8 SE9 SE10 SE11
            reshape long SE, i(key siteid) j(varnum)
            tab SE siteid, col nofreq miss
      restore 
*physical activity
tab inactive siteid, col nofreq miss 
*binge drinking
tab binge siteid, col nofreq miss 


********************************************************************************************************************
* Application of different weights to self-reported diabetes
********************************************************************************************************************

*UN 2010
svyset siteid [pweight=un2010]
*USVI
svy: tab GH184 gender if siteid==1, miss perc col 
*PR
svy: tab GH184 gender if siteid==2, miss perc col 
*Barbados
svy: tab GH184 gender if siteid==3, miss perc col 
*Trinidad
svy: tab GH184 gender if siteid==4, miss perc col 
svyset, clear


*UN 2015
svyset siteid [pweight=un2015]
*USVI
svy: tab GH184 gender if siteid==1, miss perc col 
*PR
svy: tab GH184 gender if siteid==2, miss perc col 
*Barbados
svy: tab GH184 gender if siteid==3, miss perc col 
*Trinidad
svy: tab GH184 gender if siteid==4, miss perc col 
svyset, clear



*UScb 2010
svyset siteid [pweight=UScb2010]
*USVI
svy: tab GH184 gender if siteid==1, miss perc col 
*PR
svy: tab GH184 gender if siteid==2, miss perc col 
*Barbados
svy: tab GH184 gender if siteid==3, miss perc col 
*Trinidad
svy: tab GH184 gender if siteid==4, miss perc col 
svyset, clear


*UScb 2015
svyset siteid [pweight=UScb2015]
*USVI
svy: tab GH184 gender if siteid==1, miss perc col 
*PR
svy: tab GH184 gender if siteid==2, miss perc col 
*Barbados
svy: tab GH184 gender if siteid==3, miss perc col 
*Trinidad
svy: tab GH184 gender if siteid==4, miss perc col 
svyset, clear



save "`datapath'\version02\2-working\survey_wave1_weighted_RFs", replace 


