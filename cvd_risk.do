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
*   DATA MANAGEMENT
*********************************************************************************************************************************************************
**Not applicable responses are coded as "999" (legitimate skip). Not ideal for some tabulations where we do not want to include these in the demnominator. 

*List all numeric variables
*findname, type(numeric)

*recode all numeric variables
foreach x in partage  GH62     GH188    GH274    HC66A    RPH57    HB53     D33D     D97 ///
GH1      GH63     GH189    GH275    HC66B    RPH58    HB54     D33E     NU1  ///
GH2      GH65     GH190    GH277A   HC66C    RPH59    HB55     D33F     NU4  ///
GH3      GH66     GH191    GH277B   HC66D    RPH60    HB56     D33G     NU5  ///
GH4      GH67     GH192    GH277C   HC66E    RPH61    HB57M    D33H     NU7  ///
GH5      GH69     GH193C   GH277D   HC66F    RPH62    HB57W    D33I     NU8 ///
GH6      GH70     GH213    GH278    HC66G    RPH63    HB58     D33Z     NU9 ///
GH7      GH71     GH214    GH279    HC66Z    RPH64    HB59     D35      NU10 ///
GH8      GH73     GH216    GH281    HC68     RPH65    HB60     D36W     NU12 ///
GH9      GH74     GH218    GH282    HC71     RPH66    HB61     D36M     NU13 ///
GH10     GH75     GH219    GH284    HC72     RPH67    HB62     D36A     NU14 ///
GH11     GH77     GH220    GH285    HC73     RPH69A   HB63     D37W     NU16 ///
GH12     GH78     GH221    GH286    HC75     RPH69B   HB64     D37M     NU18 ///
GH13     GH79     GH222    HC1      HC76     RPH69C   HB65     D37A     NU19 ///
GH15     GH81     GH223    HC2      HC79     RPH69D   HB66     D38W     NU20 ///
GH16     GH82     GH224    HC3      HC80     RPH69E   HB67     D38M     NU21 ///
GH18     GH83     GH225    HC5      HC83     RPH70    HB68     D38A     NU22 ///
GH19     GH85     GH226    HC6      HC84     RPH71    HB69     D43      NU23 ///
GH20     GH86     GH227    HC7A     HC87     RPH72    HB70     D44A     NU24 ///
GH22     GH87     GH228    HC7B     HC88     RPH74    HB71     D44B     NU25 ///
GH23     GH89     GH231    HC7C     HC91     RPH75A   HB72     D44C     NU26 ///
GH25     GH90     GH232    HC7D     HC92     RPH75B   HB73     D44D     NU27 ///
GH26     GH91     GH233A   HC7E     HC95     RPH75C   HB74     D44E     NU28 ///
GH31     GH93     GH233B   HC7F     HC96     RPH75D   HB75     D44F     NU29 ///
GH32     GH94     GH233C   HC7G     HC99     RPH75E   HB76     D44G     NU31 ///
GH35     GH95     GH233D   HC7H     HC100    RPH76    HB77     D44H     NU33 ///
GH37     GH97     GH234    HC8A     HC103    RPH77    HB78     D45      NU34 ///
GH13AB   GH98     GH235    HC8B     HC104    RPH78    HB79     D46      NU35 ///
GH24A    GH99     GH236A   HC8C     HC107    RPH79    HB80     D47      NU37 ///
GH24B    GH101    GH236B   HC8D     HC108    RPH81    HB81     D48      NU38 ///
GH24C    GH102    GH236C   HC9      HC109    RPH82    HB82     D49      NU40 ///
GH24D    GH103    GH236D   HC10     HC110A   RPH83    HB83     D50      NU41 ///
GH24E    GH105    GH236E   HC11     HC110B   RPH84    HB84     D51      NU43 ///
siteid   GH106    GH236F   HC12     HC110C   RPH85    HB85     D52      NU44 ///
date     GH107    GH236G   HC13     HC110D   RPH86    HB86     D53A     NU45 ///
gender   GH109    GH236H   HC14     HC110E   RPH87    HB87     D53B     NU46 ///
GH13AA   GH110    GH236I   HC15     HC111    RPH88    HB89     D53C     NU47 ///
GH13AC   GH111    GH236J   HC16     RPH1     RPH89    HB90     D53D     NU48 ///
GH13AD   GH113    GH236K   HC17     RPH2     RPH90    HB91     D53E     NU49 ///
GH13AE   GH114    GH236L   HC18     RPH3     RPH91    HB92     D53F     NU50 ///
GH13AF   GH115    GH237A   HC19     RPH4     RPH92    HB93     D54A     NU51 ///
GH13AG   GH117    GH237B   HC35     RPH6     RPH93    HB94     D54B     NU52 ///
GH13AH   GH118    GH237C   HC36     RPH5     RPH94    HB95     D54C     NU53 ///
GH13AI   GH119    GH237D   HC37     RPH7     RPH95    HB96     D54D     NU54 ///
GH13AJ   GH121    GH237E   HC41A    RPH8     RPH96    HB97     D54E     NU55 ///
GH13AK   GH122    GH237F   HC41B    RPH9     RPH97    SE1      D55      NU56 ///
GH13AL   GH123    GH237G   HC41C    RPH10A   RPH98    SE2      D56A     NU57 ///
GH13AM   GH125    GH237H   HC41D    RPH10B   RPH100   SE3      D56B     NU58 ///
GH13AN   GH126    GH237I   HC41E    RPH10C   RPH101   SE4      D56C     NU59 ///
GH13AO   GH127    GH237J   HC41F    RPH10D   RPH102   SE5      D56D     NU60 ///
GH17     GH129    GH237K   HC41G    RPH10E   RPH103   SE6      D56E     NU61 ///
GH21     GH130    GH238A   HC41Z    RPH10F   HB1      SE7      D56F     NU62 ///
GH24     GH131    GH238B   HC44     RPH10G   HB2      SE8      D57A     NU63 ///
GH27     GH133    GH238C   HC45A    RPH10H   HB3      SE9      D57B     NU64 ///
GH28     GH134    GH238D   HC45B    RPH10I   HB4      SE10     D57C     NU65 ///
GH29A    GH135    GH238E   HC45C    RPH10J   HB5      SE11     D57D     NU66 ///
GH29B    GH137    GH238F   HC45D    RPH10K   HB6      SE12     D57E     NU67 ///
GH29C    GH138    GH238G   HC45E    RPH10L   HB7      SE13     D58      NU68 ///
GH29D    GH139    GH238H   HC45F    RPH10M   HB8      SE14     D59      NU69 ///
GH29E    GH141    GH238I   HC45Z    RPH10N   HB9      SE15     D60      NU70 ///
GH30     GH142    GH238J   HC46C    RPH10O   HB10     SE16     D61      NU71 ///
GH33     GH143    GH238K   HC46D    RPH11    HB11     SE17     D62      NU72 ///
GH34     GH146    GH238L   HC46E    RPH12    HB12     SE18     D63      NU73 ///
GH36     GH147    GH238M   HC46Z    RPH13    HB13     SE19     D64A     NU74 ///
GH38A    GH148    GH239A   HC48     RPH14    HB14     SE20     D64B     NU75 ///
GH38B    GH150    GH239B   HC49     RPH15    HB15     SE21     D64C     NU76 ///
GH38C    GH151    GH239C   HC50A    RPH16    HB16     SE22     D64D     NU77 ///
GH38D    GH152    GH239D   HC50B    RPH17    HB17     SE23     D64E     NU78 ///
GH38E    GH154    GH239E   HC50C    RPH18    HB18     SE24     D64F     NU79 ///
GH38F    GH155    GH239F   HC50D    RPH19    HB19     SE25     D64G     NU80 ///
GH38G    GH156    GH239G   HC50E    RPH20    HB20     SE26     D64H     NU81 ///
GH38H    GH157    GH239H   HC50F    RPH21    HB21     D1       D64I     NU82 ///
GH38I    GH158    GH239I   HC50G    RPH22    HB22     D3       D64J     NU83 ///
GH38J    GH159    GH239J   HC50H    RPH23    HB23     D4A      D64K     NU84 ///
GH38K    GH160    GH240    HC50I    RPH24    HB24     D4B      D64L     NU85 ///
GH38L    GH161A   GH241    HC50J    RPH25    HB25     D4C      D65      NU86 ///
GH38M    GH161B   GH242    HC50Z    RPH26    HB26     D4D      D66      NU87 ///
GH38N    GH161C   GH243    HC51A    RPH27    HB27     D4E      D67      NU88 ///
GH38O    GH161D   GH244    HC51B    RPH28    HB28     D4F      D68      NU89 ///
GH38P    GH161E   GH245    HC51C    RPH29    HB29     D4G      D69      NU90 ///
GH38Q    GH161F   GH246    HC51D    RPH30A   HB30     D4H      D70      NU91 ///
GH38R    GH161Z   GH247    HC51E    RPH30B   HB31     D4I      D71      NU92 ///
GH38S    GH163    GH248    HC51F    RPH30C   HB32              D72      NU93 ///
GH38T    GH164    GH249    HC51G    RPH30D   HB33              D74      NU94 ///
GH38U    GH165    GH250    HC52     RPH30E   HB34     D6       D75      NU95 ///
GH38V    GH166    GH251    HC53A    RPH30F   HB35     D7       D76      NU96 ///
GH38W    GH167    GH252    HC53B    RPH30G   HB36     D8       D78      NU97 ///
GH39FA   GH168    GH253    HC53C    RPH30H   HB37A    D9       D79      NU98 ///
GH39FB   GH169    GH254    HC53D    RPH30I   HB37B    D10      D81      NU99A ///
GH39FZ   GH170A   GH255    HC53Y    RPH32    HB37C    D11      D82      NU99B ///
GH39FC   GH170B   GH256A   HC54     RPH33A   HB37D    D12      D83      NU99C ///
GH39MA   GH170C   GH256B   HC55     RPH33B   HB37E    D13      D83tt    NU100 ///
GH39MB   GH170D   GH256C   HC56     RPH33C   HB37F    D14      D84      NU101 /// 
GH39MZ   GH170E   GH256D   HC57A    RPH33D   HB38     D16      D85      NU102 ///
GH41     GH170Z   GH256E   HC57B    RPH33E   HB39     D17      D86      NU104A ///
GH42     GH172    GH256Z   HC57C    RPH33F   HB40     D18      D87      NU104B ///
GH43     GH173    GH258    HC57D    RPH33G   HB41     D19      D88      NU104C ///
GH45     GH174    GH259    HC57E    RPH33H   HB42     D20      D89      NU104D ///
GH46     GH175    GH261    HC57F    RPH33I   HB43     D21      D90      NU104E ///
GH47     GH176    GH263A   HC57G    RPH33J   HB44     D22      D91A     NU104F ///
GH49     GH177    GH263B   HC57Z    RPH33K   HB45     D23      D91B     NU104G ///
GH50     GH178    GH263C   HC59     RPH49    HB46     D24      D91C     NU105 ///
GH51     GH179    GH263D   HC62     RPH50    HB47     D25      D92      NU106 ///
GH53     GH180    GH264    HC63     RPH51    HB48     D28      D93A     NU107 ///
GH54     GH182    GH265    HC65A    RPH52    HB49     D30      D93B      ///
GH55     GH183    GH267    HC65B    RPH53    HB50     D31      D93C ///
GH57     GH184    GH269    HC65C    RPH54    HB51A    D32      D93D ///
GH58     GH184C   GH270    HC65D    RPH55    HB51B    D33A     D94 ///
GH59     GH185    GH271    HC65E    RPH56M   HB51C    D33B     D95 ///
GH61     GH187    GH273    HC65F    RPH56Y   HB52     D33C     D96 ///
 {
  qui recode `x' 999=.z
}

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
histogram D7, by(siteid) width(1)
