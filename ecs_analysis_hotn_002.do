** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
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
    log using "`logpath'\ecs_analysis_hotn_002", replace
** HEADER -----------------------------------------------------

* TODO Add interprepatation in Text Box
* TODO Start at H5 and Merge boxes H5 to H20 - then expand column width
* TODO Give the following descriptions
* TODO      Brief Framingham background
* TODO      Age etc restrictions for the implementation
* TODO      Consider a brief regression of CVD risk score

*! ---------------------------------------
*! PART ONE
*! TABLE OF CVD RISK SCORES BY STRATIFIERS
*! ---------------------------------------

* ----------------------
*! STEP 1. Load Data
*! Dataset prepared in ecs_analyssi_001.do
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

** Excess risk
gen excess = risk10 - fram_optrisk10 

** -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part1-CVD-risk")
    b.delete_sheet("Part1-CVD-risk")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part1-CVD-risk)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Table 1-1. CVD risk score by selected participant characteristics", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel C5 = "CVD risk score", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel C6 = "Mean (95% CI)", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel D5 = "CVD Low Risk", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel D6 = "(%)", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel E5 = "CVD Int. Risk", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel E6 = "(%)", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel F5 = "CVD High Risk", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel F6 = "(%)", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel G5 = "CVD Optimal Risk", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel G6 = "Mean", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel H5 = "CVD Excess Risk", bold font("Calibri", 10) vcenter hcenter txtwrap
putexcel H6 = "Mean Diff (95% CI)", bold font("Calibri", 10) vcenter hcenter txtwrap

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Row titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B7 = "Age (25 to 44)", bold font("Calibri", 10) vcenter  
putexcel B8 = "Age (45 to 64)", bold font("Calibri", 10) vcenter  
putexcel B9 = "Age (65+)", bold font("Calibri", 10) vcenter  
putexcel B10 = "Female", bold font("Calibri", 10) vcenter  
putexcel B11 = "Male", bold font("Calibri", 10) vcenter  
putexcel B12 = "Primary educated", bold font("Calibri", 10) vcenter  
putexcel B13 = "Secondary educated", bold font("Calibri", 10) vcenter  
putexcel B14 = "Tertiary educated", bold font("Calibri", 10) vcenter  
putexcel B15 = "Professional occupation", bold font("Calibri", 10) vcenter  
putexcel B16 = "Semi-professional occupation", bold font("Calibri", 10) vcenter  
putexcel B17 = "Non-professional occupation", bold font("Calibri", 10) vcenter  
putexcel B18 = "Heavy episodic drinking (yes)", bold font("Calibri", 10) vcenter  
putexcel B19 = "Inadequate F&V consumption (yes)", bold font("Calibri", 10) vcenter  
putexcel B20 = "Obesity (yes)", bold font("Calibri", 10) vcenter  

** -------------------------------------------------------------------------------------------------------------------- 
*! Loop through Rows, inserting aggregated data summaries
*! Age, Sex, education, occupation, heavy drinking, daily fruit and veg, obesity
** -------------------------------------------------------------------------------------------------------------------- 
local row = 6
foreach var1 in age25 age45 age65 female male primary_plus second_plus tertiary prof semi_prof non_prof binge fv5 ob {
    local row = `row' + 1
    dis "STRATIFIER: " "`var1'" 

    /// continuous risk score
    qui svy, subpop(`var1'): mean risk10 
    matrix mean1 = e(b)*100
    scalar mean1 = mean1[1,1]

    /// 95% CI for continuous risk score
    matrix v=e(V)
    scalar v =v[1,1]
    scalar bound =  (sqrt(v)*invttail(e(df_r),0.5*(1-c(level)/100)))*100
    scalar ll = mean1 - bound
    scalar ul = mean1 + bound
    local pest = string(mean1, "%9.1f")
    local lls = string(ll, "%9.1f")
    local uls = string(ul, "%9.1f")
    local cvdr = "`pest' (`lls', `uls')"
    putexcel C`row' = "`cvdr'", font("Calibri", 10) vcenter hcenter

    /// risk categories
    qui svy, subpop(`var1'): prop risk10_cat
    matrix prop1 = e(b)*100
    putexcel D`row' = matrix(prop1), nformat("0.0") font("Calibri", 10) vcenter hcenter

    /// Mean optimal risk
    qui svy, subpop(`var1'): mean fram_optrisk10 
    matrix mean2 = e(b)*100
    scalar mean2 = mean2[1,1]    
    putexcel G`row' = mean2, nformat("0.0") font("Calibri", 10) vcenter hcenter

    /// Excess risk (compared to optimal risk) + 95% CI  
    qui svy, subpop(`var1'): mean excess 
    matrix mean3 = e(b)*100
    scalar mean3 = mean3[1,1]
    matrix v3=e(V)
    scalar v3 =v3[1,1]
    scalar bound3 =  (sqrt(v3)*invttail(e(df_r),0.5*(1-c(level)/100)))*100
    scalar ll3 = mean3 - bound3
    scalar ul3 = mean3 + bound3
    local pest3 = string(mean3, "%9.1f")
    local lls3 = string(ll3, "%9.1f")
    local uls3 = string(ul3, "%9.1f")
    local cvdr3 = "`pest3' (`lls3', `uls3')"
    putexcel H`row' = "`cvdr3'", font("Calibri", 10) vcenter hcenter
    }


** -------------------------------------------------------------------------------------------------------------------- 
*! Table borders and shading
** -------------------------------------------------------------------------------------------------------------------- 
putexcel (B5:H5), border(top, medium) 
putexcel (B6:H6), border(bottom) 

putexcel (B9:H9), border(bottom) 
putexcel (B11:H11), border(bottom) 
putexcel (B14:H14), border(bottom) 
putexcel (B17:H17), border(bottom) 
putexcel (B5:B20), border(left, medium)
putexcel (B5:B20), border(right)
putexcel (C5:C20), border(right)
putexcel (H5:H20), border(right, medium)
putexcel (B20:H20), border(bottom, medium)

putexcel B5:H6, fpattern(solid, "220 220 220")
putexcel B22:H22, fpattern(solid, "220 220 220")
putexcel B29:H29, fpattern(solid, "198 219 239")

** -------------------------------------------------------------------------------------------------------------------- 
*! Write footnotes
** -------------------------------------------------------------------------------------------------------------------- 


** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part1-CVD-risk")
    b.set_sheet_gridlines("Part1-CVD-risk", "off")
    b.set_column_width(2,2,30)  //make row-title column widest
    b.set_column_width(3,3,20)  //make row-title column widest
    b.set_column_width(7,7,10)  //make row-title column widest
    b.set_column_width(8,8,20)  //make row-title column widest
    b.set_row_height(1,1,35)    //make title row bigger
    b.set_row_height(5,5,50)    //make title row bigger
    b.set_row_height(22,22,30)  //Interpretation
    b.set_row_height(23,23,50)  //Interpretation text
    b.set_row_height(24,24,35)  //Interpretation text
    b.set_row_height(25,25,50)  //Interpretation text
    b.set_row_height(26,26,50)  //Interpretation text
    b.set_row_height(27,27,50)  //Interpretation text
    b.set_row_height(28,28,60)  //Interpretation text
    b.set_row_height(29,29,50)  //Interpretation text
    b.set_row_height(32,32,35)    //make title row bigger
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B22 = "Interpretation", font("Calibri", 12) bold vcenter  

** Results Box 1 
local text1 = "Using the Framingham 2008 CVD risk score, we present survey-weighted unadjusted mean CVD risk by selected participant characteristics, along with grouped risk (low risk, <10%; intermedicate risk, 10% to < 20%; high risk, 20% and higher)."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B23:H23) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 2 
local text1 = "As expected, CVD risk increased substantially with age."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B24:H24) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 3 
local text1 = "There was a large gender disparity, with CVD risk among men on average 8.6 percentage points higher than women, and more than double the sampled men had a high CVD risk (34% among men compared to 16.4% among women)."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B25:H25) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 4
local text1 = "There was a large apparent association with education (mean CVD risk of 26% among participants with primary education, 13% for those with secondary education, and 10% among those with tertiary education)."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B26:H26) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 5
local text1 = "This education effect was strongly related to improving education over time, and after adjusting for age differences among education categories, group CVD risk was 17% among primary educated, 16.5% among secondary educated, and 15% among tertiary educated."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B27:H27) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 6
local text1 = "The excess CVD risk - the difference between optimal and actual CVD risk - was highest among men, among the elderly, and among primary educated participants (unadjusted for age). Excess CVD risk was raised by more than 10 percentage points among participants reporting heavy episodic drinking, inadequate fruit and vegetable consumption, or obesity."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B28:H28) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 7
local text1a = "regression work on predictors of raised CVD risk"
local text1b = "figure of relative CVD risk inequality (in addition to figure 1-1, absolute inequality)"
local text2 = "Potential Additional Work:   " + ustrunescape("\u25cf") + " `text1a'   " + ustrunescape("\u25cf") + " `text1b' "
putexcel (B29:H29) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap italic bold

putexcel (B22:H22), border(top, medium)
putexcel (B22:H22), border(bottom) 
putexcel (B28:H28), border(bottom, medium)
putexcel (B29:H29), border(bottom, medium)
putexcel (B22:B29), border(left, medium)
putexcel (H22:H29), border(right, medium) 


** -------------------------------------------------------------------------------------------------------------------- 
*! Graphics
** -------------------------------------------------------------------------------------------------------------------- 

** Figure 1. Absolute excess
rename risk10 fram_risk10 

** Create summaries by a range of binary stratifiers
tempfile s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14
replace fram_risk10 = fram_risk10*100
replace fram_optrisk10 = fram_optrisk10*100
gen indicator = .
** AGE25
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(age25 indicator) 
    keep if age25==1 
    replace indicator = 1
    drop age25
    save `s1', replace
restore
** AGE45
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(age45 indicator) 
    keep if age45==1 
    replace indicator = 2
    drop age45
    save `s2', replace
restore
** AGE65
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(age65 indicator) 
    keep if age65==1 
    replace indicator = 3
    drop age65 
    save `s3', replace
restore
** FEMALE
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(female indicator) 
    keep if female==1 
    replace indicator = 4
    drop female
    save `s4', replace
restore
** MALE
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(male indicator) 
    keep if male==1 
    replace indicator = 5
    drop male
    save `s5', replace
restore
** PRIMARY EDUCATED 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(primary_plus indicator) 
    keep if primary_plus==1 
    replace indicator = 6
    drop primary_plus
    save `s6', replace
restore
** SECONDARY EDUCATED 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(second_plus indicator) 
    keep if second_plus==1 
    replace indicator = 7
    drop second_plus
    save `s7', replace
restore
** TERTIARY EDUCATED 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(tertiary indicator) 
    keep if tertiary==1 
    replace indicator = 8
    drop tertiary
    save `s8', replace
restore
** PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(prof indicator) 
    keep if prof==1 
    replace indicator = 9
    drop prof
    save `s9', replace
restore
** SEMI PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(semi_prof indicator) 
    keep if semi_prof==1 
    replace indicator = 10
    drop semi_prof
    save `s10', replace
restore
** NON PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(non_prof indicator) 
    keep if non_prof==1 
    replace indicator = 11
    drop non_prof
    save `s11', replace
restore
** BINGE DRINKING
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(binge indicator) 
    keep if binge==1 
    replace indicator = 12
    drop binge
    save `s12', replace
restore
** 5 PORTIONS F&V
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(fv5 indicator) 
    keep if fv5 ==1 
    replace indicator = 13
    drop fv5 
    save `s13', replace
restore
** OBESE
preserve
    collapse (mean) fram_risk10 fram_optrisk10, by(ob indicator) 
    keep if ob==1 
    replace indicator = 14
    drop ob
    save `s14', replace
restore

use `s1', clear
forval x = 2(1)14 {
    append using `s`x''
}

#delimit ;
label define _indicator 1 "Age 25 to 44"
                        2 "Age 45 to 64"
                        3 "Age 65+"
                        4 "Women"
                        5 "Men"
                        6 "Primary"
                        7 "Secondary"
                        8 "Tertiary"
                        9 "Professional"
                        10 "Semi prof."
                        11 "Non-prof."
                        12 "Heavy drinking"
                        13 "5 portions F&V"
                        14 "Obese";
#delimit cr
label values indicator _indicator

    #delimit ;
        gr twoway 
        (rspike fram_optrisk10 fram_risk10 indicator , hor lc(gs6) lw(0.25))
        (sc indicator fram_optrisk10   , msize(3) m(o) mlc(gs0) mfc("4 90 141") mlw(0.1))
        (sc indicator fram_risk10  , msize(3) m(o) mlc(gs0) mfc("116 169 207") mlw(0.1))

        ,

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        bgcolor(white) 
        ysize(10) xsize(6)
            
            xlab(0(10)40, labs(4) nogrid glc(gs16))
            ///xscale(off) 
            xscale(fill) 
            xtitle("", size(4) margin(l=2 r=2 t=5 b=2)) 
            xmtick(0(2.5)40, tl(1.5))
            
            ylab(1(1)14 
            ,
            labs(4) val nogrid glc(gs16) angle(0) format(%9.1f))
            yscale(fill reverse range(0(1)15)) 
            ytitle("", size(2.5) margin(l=2 r=5 t=2 b=2)) 

            legend(size(4) position(1) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
            region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
            order(2 3) 
            lab(2 "Optimal CVD Risk") lab(3 "Actual CVD risk")  
            )            
            name(equiplot1) 
            ;
    #delimit cr
graph export "`outputpath'/05_Outputs/excess_cvdrisk_equiplot.png", replace height(575) 
putexcel A32 = "Figure 1-1. Differences in Optimal and Actual CVD risk scores", font("Calibri", 14) vcenter
putexcel B33 = "A. Absolute Difference", font("Calibri", 12) vcenter bold  
putexcel B35 = image("`outputpath'/05_Outputs/excess_cvdrisk_equiplot.png")
