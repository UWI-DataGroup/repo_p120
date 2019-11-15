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

** -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part1")
    b.delete_sheet("Part1")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part1)

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
putexcel B18 = "Binge drinking (yes)", bold font("Calibri", 10) vcenter  
putexcel B19 = "5 portions F&V (yes)", bold font("Calibri", 10) vcenter  
putexcel B20 = "Obese (yes)", bold font("Calibri", 10) vcenter  

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
    }

** -------------------------------------------------------------------------------------------------------------------- 
*! Table borders and shading
** -------------------------------------------------------------------------------------------------------------------- 
putexcel (B5:F5), border(top, medium) 
putexcel (B6:F6), border(bottom) 
putexcel (H6:P6), border(bottom) 
putexcel (B5:B20), border(left, medium)
putexcel (B5:B20), border(right)
putexcel (C5:C20), border(right)
putexcel (F5:F20), border(right, medium)
putexcel (B20:F20), border(bottom, medium)
putexcel B5:F6, fpattern(solid, "220 220 220")
putexcel H5:P6, fpattern(solid, "220 220 220")

** -------------------------------------------------------------------------------------------------------------------- 
*! Write footnotes
** -------------------------------------------------------------------------------------------------------------------- 


** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part1")
    b.set_sheet_gridlines("Part1", "off")
    b.set_column_width(2,2,25)  //make row-title column widest
    b.set_column_width(3,3,20)  //make row-title column widest
    b.set_row_height(1,1,35)    //make title row bigger
    b.set_row_height(5,5,50)    //make title row bigger
    b.set_row_height(21,21,70)  //make footnote text fully show
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 
putexcel H5 = "Interpretation", font("Calibri", 12) bold vcenter  
putexcel (H7:P20) = "hello hello hello" , font("Calibri", 11) merge vcenter
putexcel (H5:P5), border(top, medium)
putexcel (H20:P20), border(bottom, medium)
putexcel (H5:H20), border(left, medium)
putexcel (P5:P20), border(right, medium) 

