**  DO-FILE METADATA
//  algorithm name						cvd_risk
//  project:							ECHORN CVD analysis
//  analysts:							Christina HOWITT
//	date last modified		            21-May-2019

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
cap log using "`logpath'\cvd_risk_001", replace

**Open dataset
use "`datapath'\version02\1-input\survey_wave1.dta", clear 

*********************************************************************************************************************************************************
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
codebook partage // range: 40-91; mean (SD): 57.3 (10.3); median (IQR): 57 (49-64)
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

**How do others classify your race/ethnicity?
tab D6 siteid, col miss
tab D6 race

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


