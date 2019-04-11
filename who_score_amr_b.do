** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					who_score_amr_b.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	    26-MAR-2019
    //  algorithm task			    WHO CVD risk score. Americas. Region B.

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\who_score_amr_b", replace
** HEADER -----------------------------------------------------

*******************************************************************************
** BACKGROUND
*******************************************************************************
** WHO risk charts indicate 10-year risk of a fatal or non-fatal major cardiovascular event
** (myocardial infarction or stroke), according to age, sex, blood pressure, smoking
** status, total blood cholesterol and presence or absence of diabetes mellitus for 14 WHO
** epidemiological sub-regions.
**
** There are two sets of charts. One set can be used in settings where blood cholesterol can
** be measured. The other set is for settings in which blood cholesterol cannot be measured.
** Both sets are available according to the 14 WHO epidemiological sub-regions.
** Each chart can only be used in countries of the specific WHO epidemiological sub-region,
** e.g. The charts for South East Asia sub-region B (SEAR B) can only be used in Indonesia,
** Sri Lanka and Thailand.
**
** Different charts exist for Americas country groupings:
** AMR	A	Canada, Cuba, United States of America
** AMR	B	Antigua and Barbuda, Argentina, Bahamas, Barbados, Belize, Brazil, Chile, Colombia, Costa Rica, Dominica,
**			Dominican Republic, El Salvador, Grenada, Guyana, Honduras, Jamaica, Mexico, Panama, Paraguay,
**			Saint Kitts and Newis, Saint Lucia, Saint Vincent and the Grenadines, Suriname, Trinidad and Tobago,
**			Uruguay, Venezuela
** AMR	D	Bolivia, Ecuador, Guatemala, Haiti, Nicaragua, Peru
**
** Here we implement Risk Charts for AMR-B, assuming the availability of cholesterol.

*******************************************************************************
** 26-MAR-2019
** NOTE
*******************************************************************************
** This DO file was built to construct the WHO risk charts
** Once the various risk cells have been allocated, I think (to be confirmed) that the WHO
** risk score is categorical - groups of % risk - rather than an exact % score
** There are FIVE risk categories:
** 			category 1 -->  <10% ten-year risk
** 			category 2 -->  10 - <20% ten-year risk
** 			category 3 -->  20 - <30% ten-year risk
** 			category 4 -->  30 - <40% ten-year risk
** 			category 5 -->  >=40% ten-year risk
** For more details see: Collins (2016) - whoishRisk (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5345772/)
*******************************************************************************


** Health of the Nation as example
use "`datapath'/version01/1-input/hotn_v41RPAQ", clear

** Tabulate basic information on the required variables
codebook sex agey smoke smoke_daily sbp1 sbp2 sbp3 tchol fplas, compact

** Set as survey dataset
svyset ed [pweight=wfinal1_ad], strata(region)

**************************************************************
** 001. 	PREPARING VARIABLES REQUIRED FOR RISK SCORE
**************************************************************

** SEX (0=female, 1=male)
gen sex_m1_f0=.
replace sex_m1_f0 =1 if sex==2
replace sex_m1_f0 =0 if sex==1
sort sex_m1_f0
by sex_m1_f0: sum sex
label define sex_m1_f0 0 "women" 1 "men", modify
label values sex_m1_f0 sex_m1_f0

** WHO-defined age groups for risk score
generate age4=.
replace age4=40 if agey<50
replace age4=50 if agey>=50 & agey<60
replace age4=60 if agey>=60 & agey<70
replace age4=70 if agey>=70 & agey<99
sort age4
by age4: sum agey

** Cholesterol groups
gen chol_mm=.
replace chol_mm=4 if tchol <5
replace chol_mm=5 if tchol >=5 & tchol <6
replace chol_mm=6 if tchol >=6 & tchol <7
replace chol_mm=7 if tchol >=7 & tchol <8
replace chol_mm=8 if tchol >=8 & tchol <15
sort chol_mm
by chol_mm: sum tchol

** Current smoker (0=NO, 1=YES)
** NOTE: WHO definition also includes those that have quit in past 12 months
gen smoker_y1_n0=.
replace smoker_y1_n0 = 1 if smoke==1
replace smoker_y1_n0 = 0 if smoke==2
sort smoker_y1_n0
by smoker_y1_n0: sum smoke

** Systolic Blood Pressure
gen sbp23=(sbp2+sbp3)/2
sum sbp*
gen sys = .
replace sys = 120 if sbp23<140
replace sys = 140 if sbp23>=140 & sbp23<160
replace sys = 160 if sbp23>=160 & sbp23<180
replace sys = 180 if sbp23>=180 & sbp23<400
sort sys
by sys: sum sbp23


** Diabetes (Self Report AND Fasting Plasma)
** LAB DEFINITION
gen diab_lab1 = 0
replace diab_lab1 = 1 if (fplas>=7.0 & fplas<.)
replace diab_lab1=. if fplas==.
label define diab_lab1 0 "no" 1 "yes",modify
label values diab_lab1 diab_lab1
label var diab_lab1 "Laboratory confirmed diabetes (Fasting plasma Glucose>=7.0mmol/l)"
** DIABETES DEFINITION
** 12 women are self-report but are gestational diabetes (1 of these women comes back into diabetes definition due to fplas>=7)
replace diab = 0 if diab==1 & sex==1 & diabp==1
gen dm_y1_n0 = 0
replace dm_y1_n0 = 1 if diab_lab1==1 | diab==1
replace dm_y1_n0 = . if diab_lab1==. & diab==.
replace dm_y1_n0 = . if diab_lab1==. & diab==2
replace dm_y1_n0 = . if diab_lab1==0 & diab==.
label define dm_y1_n0 0 "no" 1 "yes",modify
label values dm_y1_n0 dm_y1_n0
label var dm_y1_n0 "Diabetes (yes/no). Self-report and lab confirmed"
svy: tab dm_y1_n0 sex_m1_f0, percent ci col


**************************************************************
** 002. 	KEEP MINIMAL DATASET REQUIRED FOR RISK SCORE
**		GENERATE 'RISK CELLS' INDICATOR (1 to 640)
**************************************************************
** There are 640 cells in the WHO risk chart, each one representing a unique grouping of the 5 variables
** sex(2)  x  dm(2)  x  smoker(2)  x  age(4)  x  sys(4)  x  chol(5)
** 2 x 2 x 2 x 4 x 4 x 5  =  640 cells

** Restrict dataset to required variables
keep sex_m1_f0 age4 chol_mm smoker_y1_n0 sys dm_y1_n0 wfinal1_ad region ed agey stroke angina mi hf
** Restrict dataset to those with complete information
keep if sex_m1_f0<. & age4<. & chol_mm<. & smoker_y1_n0<. & sys<. & dm_y1_n0<.

** Generate rectangular matrix of values, running from 1 to 640
fillin dm_y1_n0 sex_m1_f0 smoker_y1_n0 age4 sys chol_mm
** Generate indicator (1 to 640) representing the 640 individual cells in the WHO risk chart
egen wc = group(dm_y1_n0 sex_m1_f0 smoker_y1_n0 age4 sys chol_mm )
label var wc "WHO cells (1 to 640)"
** Sort and order
sort wc chol_mm sys age4 smoker_y1_n0 sex_m1_f0 dm_y1_n0
order wc chol_mm sys age4 smoker_y1_n0 sex_m1_f0 dm_y1_n0
** Count indicator --> from reversing the _fillin indicator
recode _fillin 1=0 0=1, gen(pcount)

** Save out an uncollapsed temporary file. This temporary file is used when analysing
** Eventually, we would keep this as a permanent file for analysts
** Can allow the application of WHO risk scores to other world regions
tempfile who_risk_001
save `who_risk_001'


**************************************************************************************************************
** 003. 	PLOT the 640 risk cells (for reference purposes --> aids checking of code accuracy)
** 		REFERENCE FIGURES 1 (A/B)  (without diabetes --> if dm_y1_n0==0 --> FIG 1A)   (with diabetes --> if dm_y1_n0==1 --> FIG 1B)
**************************************************************************************************************
** Gen y-axis groups (age and SBP)
egen yax = group(age4 sys)
** Gen x-axis groups (sex smoker cholesterol)
egen xax = group(sex_m1_f0 smoker_y1_n0 chol)


#delimit ;
gen y0 = 0.5; gen y1 = 4.5; gen y2 = 8.5; gen y3 = 12.5; gen y4 = 16.5;
gen x0 = 1;   gen x1 = 6;   gen x2 = 11;  gen x3 = 16;   gen x4 = 21;
	gr twoway
		/// NO DIABETES (LOWER WHO CHART)
		  (sc yax xax if dm_y1_n0==1, msymbol(none) mlab(wc) mlabsize(vsmall) mc(gs0))
		  (line y0 xax, lp("l") lc(gs10)) (line y1 xax, lp("l") lc(gs10)) (line y2 xax, lp("l") lc(gs10)) (line y3 xax, lp("l") lc(gs10)) (line y4 xax, lp("l") lc(gs10))
		  (line yax x0, lp("l") lc(gs10)) (line yax x1, lp("l") lc(gs10)) (line yax x2, lp("l") lc(gs10)) (line yax x3, lp("l") lc(gs10)) (line yax x4, lp("l") lc(gs10))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			/// SBP TEXT
			text(1 21.5 "120", place(e) size(small)) text(2 21.5 "140", place(e) size(small))
			text(3 21.5 "160", place(e) size(small)) text(4 21.5 "180", place(e) size(small))
			text(5 21.5 "120", place(e) size(small)) text(6 21.5 "140", place(e) size(small))
			text(7 21.5 "160", place(e) size(small)) text(8 21.5 "180", place(e) size(small))
			text(9 21.5 "120", place(e) size(small)) text(10 21.5 "140", place(e) size(small))
			text(11 21.5 "160", place(e) size(small)) text(12 21.5 "180", place(e) size(small))
			text(13 21.5 "120", place(e) size(small)) text(14 21.5 "140", place(e) size(small))
			text(15 21.5 "160", place(e) size(small)) text(16 21.5 "180", place(e) size(small))

			/// AGE TEXT
			text(2.5 0 "40", place(e) size(small)) text(6.5 0 "50", place(e) size(small))
			text(10.5 0 "60", place(e) size(small)) text(14.5 0 "70", place(e) size(small))

			/// CHOLESTEROL TEXT
			text(0 1.2 "4", place(e) size(small)) text(0 2.2 "5", place(e) size(small))
			text(0 3.2 "6", place(e) size(small)) text(0 4.2 "7", place(e) size(small)) text(0 5.2 "8", place(e) size(small))
			text(0 6.2 "4", place(e) size(small)) text(0 7.2 "5", place(e) size(small))
			text(0 8.2 "6", place(e) size(small)) text(0 9.2 "7", place(e) size(small)) text(0 10.2 "8", place(e) size(small))
			text(0 11.4 "4", place(e) size(small)) text(0 12.4 "5", place(e) size(small))
			text(0 13.4 "6", place(e) size(small)) text(0 14.4 "7", place(e) size(small)) text(0 15.4 "8", place(e) size(small))
			text(0 16.4 "4", place(e) size(small)) text(0 17.4 "5", place(e) size(small))
			text(0 18.4 "6", place(e) size(small)) text(0 19.4 "7", place(e) size(small)) text(0 20.4 "8", place(e) size(small))

			/// SBP title
			text(9.5 24 "SBP (mm Hg)",  place(c) orient(rvertical) size(medsmall))
			/// AGE title
			text(9.5 -1 "Age (years)",  place(c) orient(vertical) size(medsmall))
			/// CHOLESTEROL title
			text(-1.5 10 "Cholesterol (mmol/L)", place(c) orient(horizontal) size(medsmall))

			/// SMOKER text
			text(17 3.5 "Non-smoker", place(c) size(small))
			text(17 8.5 "Smoker", place(c) size(small))
			text(17 13.5 "Non-smoker", place(c) size(small))
			text(17 18.5 "Smoker", place(c) size(small))

			/// SEX text
			text(19 6 "Male", place(c) size(medsmall))
			text(19 16 "Female", place(c) size(medsmall))

			xscale(off lw(vthin) range(-2(0.5)24))
			yscale(off lw(vthin) range(-2(0.5)19))
			legend(off)
			name(Fig1_RiskCells)
			;
#delimit cr



**************************************************************************************************************
** 004. 	GENERATE CVD risk categories
** 		There are 5 risk categories
** 			category 1 -->  <10% ten-year risk
** 			category 2 -->  10 - <20% ten-year risk
** 			category 3 -->  20 - <30% ten-year risk
** 			category 4 -->  30 - <40% ten-year risk
** 			category 5 -->  >=40% ten-year risk
**************************************************************************************************************

gen wr = .
label var wr "WHO risk categories (1 to 5)"

***************************************************************************************************
** WITHOUT DIABETES
***************************************************************************************************
#delimit ;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 1 if
			/// COLUMN 1
			/// WHO cells (1-20)
			wc==1 | wc==2 | wc==3 | wc==4 | wc==5 | wc==6 | wc==7 | wc==8 | wc==9 | wc==11 | wc==12 | wc==13 |
			/// WHO cells (21-20)
			wc==21 | wc==22 | wc==23 | wc==24 | wc==25 | wc==26 | wc==27 | wc==28 | wc==29 | wc==31 | wc==32 |
			/// WHO cells (41-60)
			wc==41 | wc==42 | wc==43 | wc==44 | wc==45 | wc==46 | wc==47 | wc==48 |
			/// WHO cells (61-80)
			wc==61 | wc==62 | wc==63 | wc==66 |
			/// COLUMN 2
			/// WHO cells (81-100)
			wc==81 | wc==82 | wc==83 | wc==84 | wc==85 | wc==86 | wc==87 | wc==88 | wc==91 |
			/// WHO cells (101-120)
			wc==101 | wc==102 | wc==103 | wc==104 | wc==106 | wc==107 | wc==108 |
			/// WHO cells (121-140)
			wc==121 | wc==122 | wc==123 | wc==126 |
			/// WHO cells (141-160)
			wc==141 |
			/// COLUMN 3
			/// WHO cells (161-180)
			wc==161 | wc==162 | wc==163 | wc==164 | wc==165 | wc==166 | wc==167 | wc==168 | wc==169 | wc==171 | wc==172 | wc==173 |
			/// WHO cells (181-200)
			wc==181 | wc==182 | wc==183 | wc==184 | wc==185 | wc==186 | wc==187 | wc==188 | wc==189 | wc==191 | wc==192  |
			/// WHO cells (201-220)
			wc==201 | wc==202 | wc==203 | wc==204 | wc==205 | wc==206 | wc==207 | wc==208 | wc==209 | wc==211 | wc==212  |
			/// WHO cells (221-240)
			wc==221 | wc==222 | wc==223 | wc==224 | wc==226 | wc==227  |
			/// COLUMN 4
			/// WHO cells (241-260)
			wc==241 | wc==242 | wc==243 | wc==244 | wc==245 | wc==246 | wc==247 | wc==248 | wc==251 |
			/// WHO cells (261-280)
			wc==261 | wc==262 | wc==263 | wc==264 | wc==266 | wc==267 | wc==268 |
			/// WHO cells (281-300)
			wc==281 | wc==282 | wc==283 | wc==284 | wc==286 | wc==287 |	wc==288 |
			/// WHO cells (301-320)
			wc==301 | wc==302
			;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 2 if
			/// COLUMN 1
			/// WHO cells (1-20)
			wc==10 | wc==14 | wc==16 |
			/// WHO cells (21-20)
			wc==30 | wc==33 | wc==34 | wc==36 |
			/// WHO cells (41-60)
			wc==49 | wc==50 | wc==51 | wc==52 | wc==53 |
			/// WHO cells (61-80)
			wc==64 | wc==65 | wc==67 | wc==68 | wc==69 | wc==71 | wc==72 |
			/// COLUMN 2
			/// WHO cells (81-100)
			wc==89 | wc==92 | wc==93 |
			/// WHO cells (101-120)
			wc==105 | wc==109 | wc==111 | wc==112 |
			/// WHO cells (121-140)
			wc==124 | wc==125 | wc==127 | wc==128 | wc==131 |
			/// WHO cells (141-160)
			wc==142 | wc==143 | wc==144 | wc==146 | wc==147 |
			/// COLUMN 3
			/// WHO cells (161-180)
			wc==170 | wc==174 |
			/// WHO cells (181-200)
			wc==190 | wc==193 | wc==194 |
			/// WHO cells (201-220)
			wc==210 | wc==213 | wc==214 |
			/// WHO cells (221-240)
			wc==225 | wc==228 | wc==229 | wc==230 | wc==231 | wc==232 | wc==233 |
			/// COLUMN 4
			/// WHO cells (241-260)
			wc==249 | wc==252 |
			/// WHO cells (261-280)
			wc==265 | wc==269 | wc==271 | wc==272 |
			/// WHO cells (281-300)
			wc==285 | wc==289 | wc==291 | wc==292 |
			/// WHO cells (301-320)
			wc==303 | wc==304 | wc==305 | wc==306 | wc==307 | wc==308 | wc==311
			;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 3 if
			/// COLUMN 1
			/// WHO cells (1-20)
			wc==17 |
			/// WHO cells (21-20)
			wc==37 |
			/// WHO cells (41-60)
			wc==54 | wc==56 |
			/// WHO cells (61-80)
			wc==70 | wc==73 | wc==74 | wc==76 |
			/// COLUMN 2
			/// WHO cells (81-100)
			wc==90 |
			/// WHO cells (101-120)
			wc==110 | wc==113 |
			/// WHO cells (121-140)
			wc==129 | wc==132 |
			/// WHO cells (141-160)
			wc==145 | wc==148 | wc==149 | wc==151 | wc==152 |
			/// COLUMN 3
			/// WHO cells (161-180)
			wc==175 | wc==176 | wc==177 |
			/// WHO cells (181-200)
			wc==195 | wc==196 | wc==197 |
			/// WHO cells (201-220)
			wc==215 | wc==216 | wc==217 |
			/// WHO cells (221-240)
			wc==234 | wc==235 | wc==236 | wc==237 |
			/// COLUMN 4
			/// WHO cells (241-260)
			wc==250 | wc==253 |
			/// WHO cells (261-280)
			wc==270 | wc==273 |
			/// WHO cells (281-300)
			wc==290 | wc==293 |
			/// WHO cells (301-320)
			wc==309 | wc==310 | wc==312 | wc==313
			;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 4 if
			/// COLUMN 1
			/// WHO cells (1-20)
			wc==15 | wc==18 |
			/// WHO cells (21-20)
			wc==35 | wc==38 |
			/// WHO cells (41-60)
			wc==55 | wc==57 |
			/// WHO cells (61-80)
			wc==75 | wc==77 |
			/// COLUMN 2
			/// WHO cells (81-100)
			wc==94 | wc==96 |
			/// WHO cells (101-120)
			wc==114 | wc==116 |
			/// WHO cells (121-140)
			wc==130 | wc==133 | wc==134 |
			/// WHO cells (141-160)
			wc==150 | wc==153 |
			/// COLUMN 3
			/// WHO cells (161-180)
			wc==178 |
			/// WHO cells (181-200)
			wc==198 |
			/// WHO cells (201-220)
			wc==218 |
			/// WHO cells (221-240)
			wc==238 |
			/// COLUMN 4
			/// WHO cells (241-260)
			wc==254 | wc==256 |
			/// WHO cells (261-280)
			wc==274 | wc==276 |
			/// WHO cells (281-300)
			wc==294 | wc==296 |
			/// WHO cells (301-320)
			wc==314 | wc==316
			;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 5 if wr==. & wc<=320;
#delimit cr


***************************************************************************************************
** WITHOUT DIABETES
** GRAPHIC to check coding accuracy of CVD risk groups: REFERENCE FIGURE 2
***************************************************************************************************
#delimit ;

gen yax3 = yax;
gen xax3 = xax;

replace yax3 = yax3+2 if yax3>=17 & yax3<=20;
replace yax3 = yax3+1.5 if yax3>=13 & yax3<=16;
replace yax3 = yax3+1 if yax3>=9 & yax3<=12;
replace yax3 = yax3+0.5 if yax3>=5 & yax3<=8;
replace xax3 = xax3+2 if xax3>=16 & xax3<=21;
replace xax3 = xax3+1.5 if xax3>=11 & xax3<=15;
replace xax3 = xax3+1 if xax3>=6 & xax3<=10;
replace xax3 = xax3+0.5 if xax3>=1 & xax3<=5;

	gr twoway
		/// NO DIABETES (LOWER WHO CHART)
		  (sc yax3 xax3 if dm_y1_n0==0 & wr==1, m(S) msize(*2.3) mfc(green*0.65) mlc(gs0) mlw(vthin))
		  (sc yax3 xax3 if dm_y1_n0==0 & wr==2, m(S) msize(*2.3) mfc(yellow) mlc(gs0) mlw(vthin))
		  (sc yax3 xax3 if dm_y1_n0==0 & wr==3, m(S) msize(*2.3) mfc(orange) mlc(gs0) mlw(vthin))
		  (sc yax3 xax3 if dm_y1_n0==0 & wr==4, m(S) msize(*2.3) mfc(red*0.65) mlc(gs0) mlw(vthin))
		  (sc yax3 xax3 if dm_y1_n0==0 & wr==5, m(S) msize(*2.3) mfc(red*1.25) mlc(gs0) mlw(vthin))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(5)

			/// SBP TEXT
			text(1 23 "120", place(e) size(small)) text(2 23 "140", place(e) size(small))
			text(3 23 "160", place(e) size(small)) text(4 23 "180", place(e) size(small))
			text(5.5 23 "120", place(e) size(small)) text(6.5 23 "140", place(e) size(small))
			text(7.5 23 "160", place(e) size(small)) text(8.5 23 "180", place(e) size(small))
			text(10 23 "120", place(e) size(small)) text(11 23 "140", place(e) size(small))
			text(12 23 "160", place(e) size(small)) text(13 23 "180", place(e) size(small))
			text(14.5 23 "120", place(e) size(small)) text(15.5 23 "140", place(e) size(small))
			text(16.5 23 "160", place(e) size(small)) text(17.5 23 "180", place(e) size(small))

			/// AGE TEXT
			text(2.5 -0.2 "40", place(e) size(small)) text(6.5 -0.2 "50", place(e) size(small))
			text(10.5 -0.2 "60", place(e) size(small)) text(14.5 -0.2 "70", place(e) size(small))

			/// CHOLESTEROL TEXT
			text(-0.25 1.2 "4", place(e) size(small)) text(-0.25 2.2 "5", place(e) size(small))
			text(-0.25 3.2 "6", place(e) size(small)) text(-0.25 4.2 "7", place(e) size(small)) text(-0.25 5.2 "8", place(e) size(small))

			text(-0.25 6.8 "4", place(e) size(small)) text(-0.25 7.8 "5", place(e) size(small))
			text(-0.25 8.8 "6", place(e) size(small)) text(-0.25 9.8 "7", place(e) size(small)) text(-0.25 10.8 "8", place(e) size(small))

			text(-0.25 12.2 "4", place(e) size(small)) text(-0.25 13.2 "5", place(e) size(small))
			text(-0.25 14.2 "6", place(e) size(small)) text(-0.25 15.2 "7", place(e) size(small)) text(-0.25 16.2 "8", place(e) size(small))

			text(-0.25 17.8 "4", place(e) size(small)) text(-0.25 18.8 "5", place(e) size(small))
			text(-0.25 19.8 "6", place(e) size(small)) text(-0.25 20.8 "7", place(e) size(small)) text(-0.25 21.8 "8", place(e) size(small))

			/// SBP title
			text(9.5 25.5 "SBP (mm Hg)",  place(c) orient(rvertical) size(medsmall))
			/// AGE title
			text(9.5 -1 "Age (years)",  place(c) orient(vertical) size(medsmall))
			/// CHOLESTEROL title
			text(-1.5 11 "Cholesterol (mmol/L)", place(c) orient(horizontal) size(medsmall))

			/// SMOKER text
			text(19 3.5 "Non-smoker", place(c) size(small))
			text(19 9 "Smoker", place(c) size(small))
			text(19 15 "Non-smoker", place(c) size(small))
			text(19 20.5 "Smoker", place(c) size(small))

			/// SEX text
			text(20.5 7 "Male", place(c) size(medsmall))
			text(20.5 17 "Female", place(c) size(medsmall))

			xscale(off lw(vthin) range(-2(0.5)26))
			yscale(off lw(vthin) range(-2(0.5)19))
			legend(off)
			name(Fig2_NoDiab)
			;
#delimit cr


***************************************************************************************************
** WITH DIABETES
***************************************************************************************************

#delimit ;
** AMR (Region B)   WITH DIABETES;
replace wr = 1 if
			/// COLUMN 1
			/// WHO cells (320-340)
			wc==321 | wc==322 | wc==323 | wc==324 | wc==325 | wc==326 | wc==327 | wc==328 | wc==329 | wc==331 |
			/// WHO cells (341-360)
			wc==341 | wc==342 | wc==343 | wc==344 | wc==346 |  wc==347 | wc==348 |
			/// WHO cells (361-380)
			wc==361 | wc==362 | wc==363 | wc==366 |
			/// WHO cells (381-400)

			/// COLUMN 2
			/// WHO cells (401-420)
			wc==401 | wc==402 | wc==403 | wc==404 | wc==406 | wc==407 |
			/// WHO cells (421-440)
			wc==421 | wc==422 | wc==423 | wc==426 |
			/// WHO cells (441-460)
			wc==441 |
			/// WHO cells (461-480)

			/// COLUMN 3
			/// WHO cells (481-500)
			wc==481 | wc==482 | wc==483 | wc==484 | wc==485 | wc==486 | wc==487 | wc==488 | wc==491 |
			/// WHO cells (501-520)
			wc==501 | wc==502 | wc==503 | wc==504 | wc==506 | wc==507 | wc==508 |
			/// WHO cells (521-540)
			wc==521 | wc==522 | wc==523 | wc==526 |
			/// WHO cells (541-560)
			wc==541 |

			/// COLUMN 4
			/// WHO cells (561-580)
			wc==561 | wc==562 | wc==563 | wc==564 | wc==566 | wc==567 |
			/// WHO cells (581-600)
			wc==581 | wc==582 | wc==583 | wc==586 |
			/// WHO cells (601-620)
			wc==601 | wc==602 | wc==603
			/// WHO cells (621-640)
			;
** AMR (Region B)   WITH DIABETES;
replace wr = 2 if
			/// COLUMN 1
			/// WHO cells (320-340)
			wc==332 | wc==333 |
			/// WHO cells (341-360)
			wc==345 | wc==349 | wc==351 | wc==352 |
			/// WHO cells (361-380)
			wc==364 | wc==365 | wc==367 | wc==368 |
			/// WHO cells (381-400)
			wc==381 | wc==382 | wc==383 | wc==386 |

			/// COLUMN 2
			/// WHO cells (401-420)
			wc==408 | wc==409 | wc==411 |
			/// WHO cells (421-440)
			wc==424 | wc==427 | wc==428 |
			/// WHO cells (441-460)
			wc==442 | wc==443 | wc==446 |
			/// WHO cells (461-480)
			wc==461 |

			/// COLUMN 3
			/// WHO cells (481-500)
			wc==489 | wc==492 |
			/// WHO cells (501-520)
			wc==505 | wc==509 | wc==511 | wc==512 |
			/// WHO cells (521-540)
			wc==524 | wc==525 | wc==527 | wc==528 |
			/// WHO cells (541-560)
			wc==542 | wc==543 | wc==544 | wc==546 | wc==547 |

			/// COLUMN 4
			/// WHO cells (561-580)
			wc==565 | wc==568 | wc==571 |
			/// WHO cells (581-600)
			wc==584 | wc==587 | wc==588 |
			/// WHO cells (601-620)
			wc==604 | wc==606 | wc==607 | wc==608 |
			/// WHO cells (621-640)
			wc==621 | wc==622
			;
** AMR (Region B)   WITH DIABETES;
replace wr = 3 if
			/// COLUMN 1
			/// WHO cells (320-340)
			wc==330 | wc==334 | wc==336 |
			/// WHO cells (341-360)
			wc==350 | wc==353 |
			/// WHO cells (361-380)
			wc==369 | wc==371 | wc==372 |
			/// WHO cells (381-400)
			wc==384 | wc==387 | wc==388 | wc==391 |

			/// COLUMN 2
			/// WHO cells (401-420)
			wc==405 | wc==412 |
			/// WHO cells (421-440)
			wc==425 | wc==429 | wc==431 |
			/// WHO cells (441-460)
			wc==444 | wc==447 | wc==448 |
			/// WHO cells (461-480)
			wc==462 | wc==463 | wc==466 |

			/// COLUMN 3
			/// WHO cells (481-500)
			wc==493 |
			/// WHO cells (501-520)
			wc==513 |
			/// WHO cells (521-540)
			wc==529 | wc==531 | wc==532 |
			/// WHO cells (541-560)
			wc==545 | wc==548 | wc==549 | wc==551 | wc==552 |

			/// COLUMN 4
			/// WHO cells (561-580)
			wc==569 | wc==572 |
			/// WHO cells (581-600)
			wc==585 | wc==589 | wc==591 | wc==592 |
			/// WHO cells (601-620)
			wc==605 | wc==609 | wc==611 | wc==612 |
			/// WHO cells (621-640)
			wc==623 | wc==624 | wc==626 | wc==627
			;
** AMR (Region B)   WITHOUT DIABETES;
replace wr = 4 if
			/// COLUMN 1
			/// WHO cells (320-340)
			/// WHO cells (341-360)
			wc==354 | wc==356 |
			/// WHO cells (361-380)
			wc==370 | wc==373 |
			/// WHO cells (381-400)
			wc==385 | wc==389 | wc==392 |

			/// COLUMN 2
			/// WHO cells (401-420)
			wc==413 |
			/// WHO cells (421-440)
			wc==432 |
			/// WHO cells (441-460)
			wc==445 | wc==449 | wc==451 |
			/// WHO cells (461-480)
			wc==464 | wc==467 |

			/// COLUMN 3
			/// WHO cells (481-500)
			wc==490 | wc==494 | wc==496 |
			/// WHO cells (501-520)
			wc==510 | wc==514 | wc==516 |
			/// WHO cells (521-540)
			wc==530 | wc==533 |
			/// WHO cells (541-560)
			wc==550 | wc==553 |

			/// COLUMN 4
			/// WHO cells (561-580)
			wc==570 |
			/// WHO cells (581-600)
			wc==590 |
			/// WHO cells (601-620)
			wc==610 |
			/// WHO cells (621-640)
			wc==625 | wc==628 | wc==631
			;
** AMR (Region B)   WITH DIABETES;
replace wr = 5 if wr==. & wc>320 & wc<=640;
#delimit cr


***************************************************************************************************
** WITH DIABETES
** GRAPHIC to check coding accuracy of CVD risk groups: REFERENCE FIGURE 3
***************************************************************************************************

#delimit ;

gen yax4 = yax;
gen xax4 = xax;
replace yax4 = yax4+2 if   yax4>=17 & yax4<=20;
replace yax4 = yax4+1.5 if yax4>=13 & yax4<=16;
replace yax4 = yax4+1 if   yax4>=9 &  yax4<=12;
replace yax4 = yax4+0.5 if yax4>=5 &  yax4<=8;
replace xax4 = xax4+2 if   xax4>=16 & xax4<=21;
replace xax4 = xax4+1.5 if xax4>=11 & xax4<=15;
replace xax4 = xax4+1 if   xax4>=6 &  xax4<=10;
replace xax4 = xax4+0.5 if xax4>=1 &  xax4<=5;

	gr twoway
		/// NO DIABETES (LOWER WHO CHART)
		  (sc yax4 xax4 if dm_y1_n0==1 & wr==1, m(S) msize(*2.3) mfc(green*0.65) mlc(gs0) mlw(vthin))
		  (sc yax4 xax4 if dm_y1_n0==1 & wr==2, m(S) msize(*2.3) mfc(yellow) mlc(gs0) mlw(vthin))
		  (sc yax4 xax4 if dm_y1_n0==1 & wr==3, m(S) msize(*2.3) mfc(orange) mlc(gs0) mlw(vthin))
		  (sc yax4 xax4 if dm_y1_n0==1 & wr==4, m(S) msize(*2.3) mfc(red*0.65) mlc(gs0) mlw(vthin))
		  (sc yax4 xax4 if dm_y1_n0==1 & wr==5, m(S) msize(*2.3) mfc(red*1.25) mlc(gs0) mlw(vthin))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(5)

			/// SBP TEXT
			text(1 23 "120", place(e) size(small)) text(2 23 "140", place(e) size(small))
			text(3 23 "160", place(e) size(small)) text(4 23 "180", place(e) size(small))
			text(5.5 23 "120", place(e) size(small)) text(6.5 23 "140", place(e) size(small))
			text(7.5 23 "160", place(e) size(small)) text(8.5 23 "180", place(e) size(small))
			text(10 23 "120", place(e) size(small)) text(11 23 "140", place(e) size(small))
			text(12 23 "160", place(e) size(small)) text(13 23 "180", place(e) size(small))
			text(14.5 23 "120", place(e) size(small)) text(15.5 23 "140", place(e) size(small))
			text(16.5 23 "160", place(e) size(small)) text(17.5 23 "180", place(e) size(small))

			/// AGE TEXT
			text(2.5 -0.2 "40", place(e) size(small)) text(6.5 -0.2 "50", place(e) size(small))
			text(10.5 -0.2 "60", place(e) size(small)) text(14.5 -0.2 "70", place(e) size(small))

			/// CHOLESTEROL TEXT
			text(-0.25 1.2 "4", place(e) size(small)) text(-0.25 2.2 "5", place(e) size(small))
			text(-0.25 3.2 "6", place(e) size(small)) text(-0.25 4.2 "7", place(e) size(small)) text(-0.25 5.2 "8", place(e) size(small))

			text(-0.25 6.8 "4", place(e) size(small)) text(-0.25 7.8 "5", place(e) size(small))
			text(-0.25 8.8 "6", place(e) size(small)) text(-0.25 9.8 "7", place(e) size(small)) text(-0.25 10.8 "8", place(e) size(small))

			text(-0.25 12.2 "4", place(e) size(small)) text(-0.25 13.2 "5", place(e) size(small))
			text(-0.25 14.2 "6", place(e) size(small)) text(-0.25 15.2 "7", place(e) size(small)) text(-0.25 16.2 "8", place(e) size(small))

			text(-0.25 17.8 "4", place(e) size(small)) text(-0.25 18.8 "5", place(e) size(small))
			text(-0.25 19.8 "6", place(e) size(small)) text(-0.25 20.8 "7", place(e) size(small)) text(-0.25 21.8 "8", place(e) size(small))

			/// SBP title
			text(9.5 25.5 "SBP (mm Hg)",  place(c) orient(rvertical) size(medsmall))
			/// AGE title
			text(9.5 -1 "Age (years)",  place(c) orient(vertical) size(medsmall))
			/// CHOLESTEROL title
			text(-1.5 11 "Cholesterol (mmol/L)", place(c) orient(horizontal) size(medsmall))

			/// SMOKER text
			text(19 3.5 "Non-smoker", place(c) size(small))
			text(19 9 "Smoker", place(c) size(small))
			text(19 15 "Non-smoker", place(c) size(small))
			text(19 20.5 "Smoker", place(c) size(small))

			/// SEX text
			text(20.5 7 "Male", place(c) size(medsmall))
			text(20.5 17 "Female", place(c) size(medsmall))

			xscale(off lw(vthin) range(-2(0.5)26))
			yscale(off lw(vthin) range(-2(0.5)19))
			legend(off)
			name(Fig3_Diab)
			;
#delimit cr




***************************************************************************************************
** 005.	WHO 10-YEAR CVD RISK in the HOTN SURVEY
** 		Tabulation and graphic
***************************************************************************************************


** Extra rows to create RISK MATRIX. Can drop for analysis and N will = 1234 - missing data (1,106)
drop if pcount==0

** Set as survey dataset
svyset ed [pweight=wfinal1_ad], strata(region)

** Age in 3-age groups (NU paper draft)
gen age3g = recode(agey,45,65,110)
recode age3g 45=1 65=2 110=3
label define age3g 1 "25-44" 2 "45-64" 3 "65+"
label values age3g age3g
label var age3g "Age in 3 groups (25-44, 45-64, 65+)"

** GROUP 10-year risk into 2 categories: 10% or greater risk of CVD
gen wr2 = .
replace wr2 = 0 if wr==1
replace wr2 = 1 if wr==2 | wr==3 | wr==4 | wr==5

** GROUP 10-year risk into 3 categories: 20% or greater risk of CVD
gen wr3 = .
replace wr3 = 0 if wr==1 | wr==2
replace wr3 = 1 if wr==3 | wr==4 | wr==5

** Tabulate 10-YEAR risk by age: 10% or greater risk of CVD
tab wr2 dm_y1_n0
** females
svy: tab age3g wr2 if sex==0, row perc ci
** males
svy: tab age3g wr2 if sex==1, row perc ci
** all
svy: tab age3g wr2 , row perc ci

** Tabulate 10-YEAR risk by age: 20% or greater risk of CVD
tab wr3 dm_y1_n0
** females
svy: tab age3g wr3 if sex==0, row perc ci
** males
svy: tab age3g wr3 if sex==1, row perc ci
** all
svy: tab age3g wr3 , row perc ci


** If you have prevalent CVD --> immediately high risk (MI / Stroke / Angina / HF)
gen wr_adj = wr
replace wr_adj = 5 if mi==1|stroke==1|angina==1|hf==1

** GROUP 10-year risk into 2 categories: 10% or greater risk of CVD
gen wr2_adj = .
replace wr2_adj = 0 if wr_adj==1
replace wr2_adj = 1 if wr_adj==2 | wr_adj==3 | wr_adj==4 | wr_adj==5

** GROUP 10-year risk into 3 categories: 20% or greater risk of CVD
gen wr3_adj = .
replace wr3_adj = 0 if wr_adj==1 | wr_adj==2
replace wr3_adj = 1 if wr_adj==3 | wr_adj==4 | wr_adj==5

** Tabulate 10-YEAR risk by age: 10% or greater risk of CVD
tab wr2_adj dm_y1_n0
** females
svy: tab age3g wr2_adj if sex==0, row perc ci
** males
svy: tab age3g wr2_adj if sex==1, row perc ci
** all
svy: tab age3g wr2_adj , row perc ci

** Tabulate 10-YEAR risk by age: 20% or greater risk of CVD
tab wr3_adj dm_y1_n0
** females
svy: tab age3g wr3_adj if sex==0, row perc ci
** males
svy: tab age3g wr3_adj if sex==1, row perc ci
** all
svy: tab age3g wr3_adj , row perc ci



***************************************************************************************************
** GRAPHIC: WITHOUT ADJUSTMENT FOR SELF-REPORTED --> MI, STROKE< ANGINA
***************************************************************************************************

** Preparing dataset for plotting STACKED BAR CHART of 10-year risk (WHO RISK IN 3 groups)
qui{
preserve
	tempfile svy1
	xcontract sex age3g wr3, zero saving(`svy1', replace)
	**use `svy1', clear
	svyset ed [pweight=wfinal1_ad], strata(region)
	svy: tab age3g wr3 , row percent ci
	parmby "svy: tab age3g wr3 , row percent ci", by(sex) norestore
	replace stderr=stderr/(estimate*(1-estimate))
	replace estimate=log(estimate/(1-estimate))
	drop t p min* max*
	parmcip
	gen estimate_2=exp(estimate)/(1+exp(estimate))
	gen min95_2=exp(min95)/(1+exp(min95))
	gen max95_2=exp(max95)/(1+exp(max95))
	merge using `svy1'
	sort wr3 sex age3g
	list wr3 sex age3g _freq estimate_2 min95_2 max95_2, sepby(sex)
	tempfile wr3_results_correct_CIs
	save `wr3_results_correct_CIs', replace
restore
}

** Preparing dataset for plotting STACKED BAR CHART of 10-year risk (WHO RISK IN 5 groups)
qui {
preserve
	tempfile svy1
	xcontract sex age3g wr, zero saving(`svy1', replace)
	**use `svy1', clear
	svyset ed [pweight=wfinal1_ad], strata(region)
	svy: tab age3g wr , row percent ci
	parmby "svy: tab age3g wr , row percent ci", by(sex) norestore
	replace stderr=stderr/(estimate*(1-estimate))
	replace estimate=log(estimate/(1-estimate))
	drop t p min* max*
	parmcip
	gen estimate_2=exp(estimate)/(1+exp(estimate))
	gen min95_2=exp(min95)/(1+exp(min95))
	gen max95_2=exp(max95)/(1+exp(max95))
	merge using `svy1'
	sort wr sex age3g
	list wr sex age3g _freq estimate_2 min95_2 max95_2, sepby(sex)
	tempfile wr_results_correct_CIs
	save `wr_results_correct_CIs', replace
restore
}

** STACKED BAR CHART (WHO RISK IN 5 groups)
preserve
	use `wr_results_correct_CIs', clear
	gen prev = estimate_2*100
	gen plo = min95_2*100
	gen phi = max95_2*100

	gen prev1 = prev if wr==1
	gen prev2 = prev if wr==2
	gen prev3 = prev if wr==3
	gen prev4 = prev if wr==4
	gen prev5 = prev if wr==5

	** WOMEN & MEN
	#delimit ;
	graph hbar (sum) prev1 prev2 prev3 prev4 prev5, stack
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(2.8)

		over(age3g, gap(15))
		over(sex, gap(60))
		blabel(none, format(%9.0f) pos(outside) size(medsmall))
		/// WR==1
		bar(1, bc(green*0.65) blw(vthin) blc(gs0))
		/// WR==2
		bar(2, bc(yellow) blw(vthin) blc(gs0))
		/// WR==3
		bar(3, bc(orange) blw(vthin) blc(gs0))
		/// WR==4
		bar(4, bc(red*0.65) blw(vthin) blc(gs0))
		/// WR==6
		bar(5, bc(red*1.25) blw(vthin) blc(gs0))

	   	ylab(0(10)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
	    ytitle("10-year risk of fatal or non-fatal CVD", margin(t=3) size(medium))

		legend(size(medsmall) position(12) bm(t=0 b=5 l=0 r=0) colf cols(5)
		region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
		lab(1 "<10%")
		lab(2 "10 to <20%")
		lab(3 "20 to <30%")
		lab(4 "30 to <40%")
		lab(5 ">=40%")
		)
		name(Fig4_WHORisk)
	;
	#delimit cr
restore




***************************************************************************************************
** GRAPHIC: WITH ADJUSTMENT FOR SELF-REPORTED --> MI, STROKE< ANGINA
***************************************************************************************************

** Preparing dataset for plotting STACKED BAR CHART of 10-year risk (WHO RISK IN 3 groups)
qui{
preserve
	tempfile svy1
	xcontract sex age3g wr3_adj, zero saving(`svy1', replace)
	**use `svy1', clear
	svyset ed [pweight=wfinal1_ad], strata(region)
	svy: tab age3g wr3_adj , row percent ci
	parmby "svy: tab age3g wr3_adj , row percent ci", by(sex) norestore
	replace stderr=stderr/(estimate*(1-estimate))
	replace estimate=log(estimate/(1-estimate))
	drop t p min* max*
	parmcip
	gen estimate_2=exp(estimate)/(1+exp(estimate))
	gen min95_2=exp(min95)/(1+exp(min95))
	gen max95_2=exp(max95)/(1+exp(max95))
	merge using `svy1'
	sort wr3_adj sex age3g
	list wr3_adj sex age3g _freq estimate_2 min95_2 max95_2, sepby(sex)
	tempfile wr3_adj_results_correct_CIs
	save `wr3_adj_results_correct_CIs', replace
restore
}

** Preparing dataset for plotting STACKED BAR CHART of 10-year risk (WHO RISK IN 5 groups)
qui {
preserve
	tempfile svy1
	xcontract sex age3g wr_adj, zero saving(`svy1', replace)
	**use `svy1', clear
	svyset ed [pweight=wfinal1_ad], strata(region)
	svy: tab age3g wr_adj , row percent ci
	parmby "svy: tab age3g wr_adj , row percent ci", by(sex) norestore
	replace stderr=stderr/(estimate*(1-estimate))
	replace estimate=log(estimate/(1-estimate))
	drop t p min* max*
	parmcip
	gen estimate_2=exp(estimate)/(1+exp(estimate))
	gen min95_2=exp(min95)/(1+exp(min95))
	gen max95_2=exp(max95)/(1+exp(max95))
	merge using `svy1'
	sort wr_adj sex age3g
	list wr_adj sex age3g _freq estimate_2 min95_2 max95_2, sepby(sex)
	tempfile wr_adj_results_correct_CIs
	save `wr_adj_results_correct_CIs', replace
restore
}

** STACKED BAR CHART (WHO RISK IN 5 groups)
preserve
	use `wr_adj_results_correct_CIs', clear
	gen prev = estimate_2*100
	gen plo = min95_2*100
	gen phi = max95_2*100

	gen prev1 = prev if wr_adj==1
	gen prev2 = prev if wr_adj==2
	gen prev3 = prev if wr_adj==3
	gen prev4 = prev if wr_adj==4
	gen prev5 = prev if wr_adj==5

	** WOMEN & MEN
	#delimit ;
	graph hbar (sum) prev1 prev2 prev3 prev4 prev5, stack
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(2.8)

		over(age3g, gap(15))
		over(sex, gap(60))
		blabel(none, format(%9.0f) pos(outside) size(medsmall))
		/// WR==1
		bar(1, bc(green*0.65) blw(vthin) blc(gs0))
		/// WR==2
		bar(2, bc(yellow) blw(vthin) blc(gs0))
		/// WR==3
		bar(3, bc(orange) blw(vthin) blc(gs0))
		/// WR==4
		bar(4, bc(red*0.65) blw(vthin) blc(gs0))
		/// WR==6
		bar(5, bc(red*1.25) blw(vthin) blc(gs0))

	   	ylab(0(10)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
	    ytitle("10-year risk of fatal or non-fatal CVD", margin(t=3) size(medium))

		legend(size(medsmall) position(12) bm(t=0 b=5 l=0 r=0) colf cols(5)
		region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
		lab(1 "<10%")
		lab(2 "10 to <20%")
		lab(3 "20 to <30%")
		lab(4 "30 to <40%")
		lab(5 ">=40%")
		)
		name(Fig5_WHORisk_Adj)
		;
		#delimit cr
restore
