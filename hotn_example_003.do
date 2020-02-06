** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_003.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        implamenting the Framingham CVD risk score.

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
    ** Aggregated data path
    local outputpath "X:/The University of the West Indies/DataGroup - DG_Projects/PROJECT_p120"


    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_analysis_hotn_003", replace
** HEADER -----------------------------------------------------

* TODO Explore Confidence Limit calculations (or other measure of uncertainty)

*! ---------------------------------------
*! PART TWO
*! BAR CHART OF CVD RISK SCORE BY ED
*! ---------------------------------------

* ----------------------
*! STEP 1. Load Data
*! Dataset prepared in ecs_analysis_001.do
*! USE FRAMINGHAM RISK SCORE
* ----------------------
use "`datapath'/version02/2-working/hotn_cvdrisk_prepared", clear
rename fram_risk10 risk10

** -------------------------------------------------------------------------------------------------------------------- 
*! Set post-stratification weight 
** -------------------------------------------------------------------------------------------------------------------- 
gen unweighted = 1 
** wps_b2010
** wfinal1_ad
svyset ed [pweight=wps_b2010], strata(region) 

** -------------------------------------------------------------------------------------------------------------------- 
*! Prepare Risk categories  
** -------------------------------------------------------------------------------------------------------------------- 
** CVD risk categories
gen risk10_cat = . 
replace risk10_cat = 1 if risk10<0.1
replace risk10_cat = 2 if risk10>=0.1 & risk10<0.2
replace risk10_cat = 3 if risk10>=0.2 & risk10<.
label define _risk10_cat 1 "low" 2 "intermediate" 3 "high" 
label values risk10_cat _risk10_cat 
replace risk10 = risk10 * 100 

** -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part2-Inequality")
    b.delete_sheet("Part2-Inequality")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part2-Inequality)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Table 2-1. Inequality in CVD risk score for women and men by place of residence (Enumeration District, Parish)", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel B5 = "Participant Group", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel C5 = "Inequality Measure", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel D5 = "Enumeration District", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel E5 = "Parish", bold font("Calibri", 10) vcenter hcenter txtwrap

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Row titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B6 = "Women", bold font("Calibri", 10) vcenter  
putexcel C6 = "Difference (D)", bold font("Calibri", 10) vcenter  
putexcel C7 = "Mean Absolute Deviation (MD)", bold font("Calibri", 10) vcenter  
putexcel C8 = "Relative Ratio (RR)", bold font("Calibri", 10) vcenter  
putexcel C9 = "Index of Disparity (ID)", bold font("Calibri", 10) vcenter  
putexcel B10 = "Men", bold font("Calibri", 10) vcenter  
putexcel C10 = "Difference (D)", bold font("Calibri", 10) vcenter  
putexcel C11 = "Mean Absolute Deviation (MD)", bold font("Calibri", 10) vcenter  
putexcel C12 = "Relative Ratio (RR)", bold font("Calibri", 10) vcenter  
putexcel C13 = "Index of Disparity (ID)", bold font("Calibri", 10) vcenter  
putexcel B14 = "Women and Men", bold font("Calibri", 10) vcenter  
putexcel C14 = "Difference (D)", bold font("Calibri", 10) vcenter  
putexcel C15 = "Mean Absolute Deviation (MD)", bold font("Calibri", 10) vcenter  
putexcel C16 = "Relative Ratio (RR)", bold font("Calibri", 10) vcenter  
putexcel C17 = "Index of Disparity (ID)", bold font("Calibri", 10) vcenter  
** Images
putexcel A28 = "Figure 2-1. CVD risk score by Place of Residence", font("Calibri", 14) vcenter  
putexcel B29 = "A. By ED. Women and Men combined", font("Calibri", 12) vcenter bold  
putexcel D29 = "B. By ED. Women only", font("Calibri", 12) vcenter bold  
putexcel G29 = "C. By ED. Men only", font("Calibri", 12) vcenter bold  
putexcel B54 = "D. By Parish. Women and Men combined", font("Calibri", 12) vcenter bold  
putexcel D54 = "E. By Parish. Women only", font("Calibri", 12) vcenter bold  
putexcel G54 = "F. By Parish. Men only", font("Calibri", 12) vcenter bold  
** -------------------------------------------------------------------------------------------------------------------- 
*! Inequality metrics by ED
*! SIMPLE MEASURES: ABSOLUTE DIFFERENCE (D) and RELATIVE RATIO (RR)
*! COMPLEX MEASURES: MEAN ABSOLUTE DIFFERENCE (MD) and the INDEX OF DISPARITY (ID)
** -------------------------------------------------------------------------------------------------------------------- 
local col = "D" 
foreach var in ed parish {
    ** WOMEN / by ED
    preserve
        keep if sex == 1
        collapse (mean) risk10, by(`var')
        ** SIMPLE ABSOLUTE
        egen rmin = min(risk10)
        egen rmax = max(risk10) 
        gen d = rmax - rmin
        ** SIMPLE RELATIVE
        gen rr = rmax / rmin
        ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
        gen J =  _N-1
        gen rdiff = abs(rmin - risk10)
        egen md = sum(rdiff/J)
        ** COMPLEX RELATIVE. Index of Disparity
        gen id = (md / rmin) * 100
        sca sc_d = d 
        sca sc_md = md 
        sca sc_rr = rr 
        sca sc_id = id 
        drop J rmin rdiff 
        putexcel `col'6 = sc_d, font("Calibri", 10) vcenter hcenter nformat("0.0") 
        putexcel `col'7 = sc_md, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'8 = sc_rr, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'9 = sc_id, font("Calibri", 10) vcenter hcenter nformat("0.00") 
    restore
    ** MEN
    preserve
        keep if sex == 2
        collapse (mean) risk10, by(`var')
        ** SIMPLE ABSOLUTE
        egen rmin = min(risk10)
        egen rmax = max(risk10) 
        gen d = rmax - rmin
        ** SIMPLE RELATIVE
        gen rr = rmax / rmin
        ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
        gen J =  _N-1
        gen rdiff = abs(rmin - risk10)
        egen md = sum(rdiff/J)
        ** COMPLEX RELATIVE. Index of Disparity
        gen id = (md / rmin) * 100
        sca sc_d = d 
        sca sc_md = md 
        sca sc_rr = rr 
        sca sc_id = id 
        drop J rmin rdiff 
        putexcel `col'10 = d, font("Calibri", 10) vcenter hcenter nformat("0.0") 
        putexcel `col'11 = md, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'12 = rr, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'13 = id, font("Calibri", 10) vcenter hcenter nformat("0.00") 
    restore
    ** WOMEN and MEN
    preserve
        collapse (mean) risk10, by(`var')
        ** SIMPLE ABSOLUTE
        egen rmin = min(risk10)
        egen rmax = max(risk10) 
        gen d = rmax - rmin
        ** SIMPLE RELATIVE
        gen rr = rmax / rmin
        ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
        gen J =  _N-1
        gen rdiff = abs(rmin - risk10)
        egen md = sum(rdiff/J)
        ** COMPLEX RELATIVE. Index of Disparity
        gen id = (md / rmin) * 100
        sca sc_d = d 
        sca sc_md = md 
        sca sc_rr = rr 
        sca sc_id = id 
        drop J rmin rdiff 
        putexcel `col'14 = d, font("Calibri", 10) vcenter hcenter nformat("0.0") 
        putexcel `col'15 = md, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'16 = rr, font("Calibri", 10) vcenter hcenter nformat("0.00") 
        putexcel `col'17 = id, font("Calibri", 10) vcenter hcenter nformat("0.00") 
    restore
    local col = "E"
    }

** -------------------------------------------------------------------------------------------------------------------- 
*! Table borders and shading
** -------------------------------------------------------------------------------------------------------------------- 
putexcel (B5:E5), border(top, medium) 
putexcel (B5:E5), border(bottom) 
putexcel (B5:B17), border(left, medium)
putexcel (C5:C17), border(right)
putexcel (E5:E17), border(right, medium)
putexcel (B10:E10), border(top)
putexcel (B14:E14), border(top)
putexcel (B17:E17), border(bottom, medium)
putexcel (B5:E5), fpattern(solid, "220 220 220")
putexcel (B19:I19), fpattern(solid, "220 220 220")
putexcel (B26:I26), fpattern(solid, "198 219 239")

** -------------------------------------------------------------------------------------------------------------------- 
*! Write footnotes
** -------------------------------------------------------------------------------------------------------------------- 


** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part2-Inequality")
    b.set_sheet_gridlines("Part2-Inequality", "off")
    b.set_column_width(2,2,20)  //make row-title column widest
    b.set_column_width(3,3,25)  //make row-title column widest
    b.set_column_width(4,4,15)  //make ED column widest
    b.set_column_width(5,5,15)  //make ED column widest
    b.set_row_height(1,1,35)    //make title row bigger
    b.set_row_height(5,5,50)    //make Header row bigger
    b.set_row_height(19,19,30)  //Interpretation title
    b.set_row_height(20,20,80)  //interpretation
    b.set_row_height(21,21,50)  //interpretation
    b.set_row_height(22,22,50)  //interpretation
    b.set_row_height(23,23,50)  //interpretation
    b.set_row_height(24,24,50)  //interpretation
    b.set_row_height(25,25,50)  //interpretation
    b.set_row_height(26,26,50)  //interpretation
    b.close_book()
end

*/

** -------------------------------------------------------------------------------------------------------------------- 
*! Ordered bar chart formatting 
** -------------------------------------------------------------------------------------------------------------------- 
** Generate codes for ED work 
#delimit ; 
label define _ed    2 "ed 2" 12 "ed 12" 25 "ed 25" 37 "ed 37"
                    51 "ed 51" 63 "ed 63" 74 "ed 74" 86 "ed 86"
                    101 "ed 101" 111 "ed 111" 120 "ed 120" 132 "ed 132"
                    149 "ed 149" 159 "ed 159" 172 "ed 172" 193 "ed 193"
                    206 "ed 206" 217 "ed 217" 229 "ed 229" 244 "ed 244"
                    258 "ed 258" 270 "ed 270" 282 "ed 282" 298 "ed 298"
                    310 "ed 310" 322 "ed 322" 334 "ed 334" 340 "ed 340"
                    354 "ed 354" 368 "ed 368" 381 "ed 381" 395 "ed 395"
                    405 "ed 405" 431 "ed 431" 445 "ed 445" 459 "ed 459"
                    472 "ed 472" 485 "ed 485" 500 "ed 500" 509 "ed 509"
                    520 "ed 520" 533 "ed 533" 546 "ed 546" 562 "ed 562"
                    579 "ed 579"
                    ;
#delimit cr 
label values ed _ed 

** WOMEN and MEN 
#delimit ;
		gr hbar risk10 ,
	
		over(ed, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 153 41")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":7.32}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_all)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_all.png", replace width(250)
putexcel B31 = image("`outputpath'/05_Outputs/fram_orderedbar_all.png")



** WOMEN only 
#delimit ;
		gr hbar risk10 if sex==1,
	
		over(ed, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 196 79")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":7.40}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_women)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_women.png", replace width(250)
putexcel D31 = image("`outputpath'/05_Outputs/fram_orderedbar_women.png")

** MEN only 
#delimit ;
		gr hbar risk10 if sex==2,
	
		over(ed, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("236 112 20")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":14.23}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_men)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_men.png", replace width(250)
putexcel G31 = image("`outputpath'/05_Outputs/fram_orderedbar_men.png")


** BY PARISH

** WOMEN and MEN 
#delimit ;
		gr hbar risk10 ,
	
		over(parish, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 153 41")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)35,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(33 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(33 85 `"{fontface "Calibri Light":4.23}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_all_parish)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_all_parish.png", replace width(250)
putexcel B56 = image("`outputpath'/05_Outputs/fram_orderedbar_all_parish.png")



** WOMEN only 
#delimit ;
		gr hbar risk10 if sex==1,
	
		over(parish, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 196 79")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)35,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(33 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(33 85 `"{fontface "Calibri Light":4.39}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_women_parish)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_women_parish.png", replace width(250)
putexcel D56 = image("`outputpath'/05_Outputs/fram_orderedbar_women_parish.png")

** MEN only 
#delimit ;
		gr hbar risk10 if sex==2,
	
		over(parish, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("236 112 20")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)35,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(33 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(33 85 `"{fontface "Calibri Light":8.34}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_men_parish)
        ;
#delimit cr	
graph export "`outputpath'/05_Outputs/fram_orderedbar_men_parish.png", replace width(250)
putexcel G56 = image("`outputpath'/05_Outputs/fram_orderedbar_men_parish.png")


** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B19 = "Interpretation", font("Calibri", 12) bold vcenter  

** Results Box 1 
local text1 = "The distribution of 10-year CVD risk across the sampled Enumeration Districts (EDs) in Barbados was shifted higher among men compared to women. This generally higher CVD risk among men was accompanied by a 2-fold higher absolute inequality between EDs (whether using absolute difference or mean absolute deviation). The relative inequality between EDs, though, was roughly the same for women and men."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B20:I20) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 2 
local text1 = "Among women and men combined, the 10-year CVD risk across the sampled EDs in Barbados ranged from 9.3% to 25.3%, an absolute difference of 16 percentage points, and a relative difference of 2.7."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B21:I21) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 3 
local text1 = "Among women, the 10-year CVD risk ranged from 4.6% to 19.8%, an absolute difference of 15.2 percentage points, and a relative difference of 4.3."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B22:I22) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 4
local text1 = "Among men, the 10-year CVD risk ranged from 10.3% to 43.5%, an absolute difference of 33.2 percentage points, and a relative difference of 4.2."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B23:I23) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 5
local text1 = "The ordered bar charts for CVD risk by ED (Figure 2-1, A-C) visualize the risk inequality, with the 'slope' of ordered bars providing an informal indication of inequality size. This slope is formally measured using the mean absolute deviation, which confirms the doubled absolute inequality between EDs for men, compared to women. "
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B24:I24) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 6
local text1 = "The ordered bar charts for CVD risk by parish (Figure 2-1, D-F), tell a similar story to that seem among EDs, with a higher absolute inequality and similar relative inequality."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B25:I25) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 7
local text1a = "apply complex inequality measures for ordered stratifiers (Slope Index of inequality-SII and Relative Index of Inequality-RII)"
local text1b = "For ECHORN, compare across country"
local text1c = "ED-level information for Trinidad. Probably island-level information for USVI. Stratification for Puerto Rico?"
local text1d = "For Barbados, consider joining HotN + ECHORN baseline"
local text2 = "Potential Additional Work:   " + ustrunescape("\u25cf") + " `text1a'   " + ustrunescape("\u25cf") + "  `text1b'  " + ustrunescape("\u25cf") + " `text1c' " + ustrunescape("\u25cf") + " `text1d'   "
putexcel (B26:I26) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap italic bold

putexcel (B19:I19), border(top, medium)
putexcel (B19:I19), border(bottom) 
putexcel (B25:I25), border(bottom, medium)
putexcel (B26:I26), border(bottom, medium)
putexcel (B19:B26), border(left, medium)
putexcel (I19:I26), border(right, medium) 
