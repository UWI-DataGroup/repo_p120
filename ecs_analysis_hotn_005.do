* HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_005.do
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
    log using "`logpath'\ecs_analysis_hotn_005", replace
** HEADER -----------------------------------------------------


*! ---------------------------------------
*! PART TWO
*! BAR CHART OF CVD RISK SCORE BY ED
*! ---------------------------------------

* ----------------------
*! STEP 1. Load Data
*! Dataset prepared in ecs_analysis_001.do
* ----------------------
use "`datapath'/version02/2-working/hotn_cvdrisk_prepared", clear

** -------------------------------------------------------------------------------------------------------------------- 
*! Set post-stratification weight 
** -------------------------------------------------------------------------------------------------------------------- 
gen unweighted = 1 
** wps_b2010
** wfinal1_ad
svyset ed [pweight=wps_b2010], strata(region) 

** -------------------------------------------------------------------------------------------------------------------- 
*! Equiplot ONE of FRAMINGHAM versus ASCVD risk scores 
*! Comparing mean scores in each ED
** -------------------------------------------------------------------------------------------------------------------- 

preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(ed sex) 
    keep if sex==1 
    replace fram_risk10 = fram_risk10*100
    replace ascvd_risk10 = ascvd_risk10*100
    gsort fram_risk10
    gen order1 = _n 

    ** WOMEN 
    #delimit ;
        gr twoway 
            (rspike fram_risk10 ascvd_risk10 order1 if sex==1 , hor lc(gs6) lw(0.25))
            (sc order1 fram_risk10  if sex==1, msize(3) m(o) mlc(gs0) mfc("84 39 143") mlw(0.1))
            (sc order1 ascvd_risk10 if sex==1, msize(3) m(o) mlc(gs0) mfc("158 154 200") mlw(0.1))

            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(6)
            
                xlab(0(10)45, labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(fill) 
                xtitle("", size(4) margin(l=2 r=2 t=5 b=2)) 
                xmtick(0(2.5)45, tl(1.5))
                
                ylab(0(5)45 
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.1f))
                yscale(off) 
                ytitle("", size(2.5) margin(l=2 r=5 t=2 b=2)) 

                legend(size(4) position(3) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(2 3) 
                lab(2 "Framingham") lab(3 "ASCVD")  
                )
                name(equiplot1w) 
                ;
        #delimit cr
        graph export "`outputpath'/05_Outputs/cvdrisk_equiplot01w.png", replace height(575) 
restore 

preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(ed sex) 
    keep if sex==2 
    replace fram_risk10 = fram_risk10*100
    replace ascvd_risk10 = ascvd_risk10*100
    gsort fram_risk10
    gen order1 = _n 
    
    ** MEN 
    #delimit ;
        gr twoway 
            (rspike fram_risk10 ascvd_risk10 order1 if sex==2 , hor lc(gs6) lw(0.25))
            (sc order1 fram_risk10  if sex==2, msize(3) m(o) mlc(gs0) mfc("166 54 3") mlw(0.1))
            (sc order1 ascvd_risk10 if sex==2, msize(3) m(o) mlc(gs0) mfc("253 141 60") mlw(0.1))

            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(6)
            
                xlab(0(10)45, labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(fill) 
                xtitle("", size(4) margin(l=2 r=2 t=5 b=2)) 
                xmtick(0(2.5)45, tl(1.5))
                
                ylab(0(5)45 
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.1f))
                yscale(off) 
                ytitle("", size(2.5) margin(l=2 r=5 t=2 b=2)) 

                legend(size(4) position(3) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(2 3) 
                lab(2 "Framingham") lab(3 "ASCVD")  
                )
                name(equiplot1m) 
                ;
        #delimit cr
        graph export "`outputpath'/05_Outputs/cvdrisk_equiplot01m.png", replace height(575) 
restore 

preserve
    ** WOMEN and MEN 
    collapse (mean) fram_risk10 ascvd_risk10, by(ed) 
    replace fram_risk10 = fram_risk10*100
    replace ascvd_risk10 = ascvd_risk10*100
    gsort fram_risk10
    gen order1 = _n 

    #delimit ;
        gr twoway 
            (rspike fram_risk10 ascvd_risk10 order1 , hor lc(gs6) lw(0.25))
            (sc order1 fram_risk10 , msize(3) m(o) mlc(gs0) mfc("4 90 141") mlw(0.1))
            (sc order1 ascvd_risk10 , msize(3) m(o) mlc(gs0) mfc("116 169 207") mlw(0.1))

            ,

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(10) xsize(6)
            
                xlab(0(10)45, labs(4) nogrid glc(gs16))
                ///xscale(off) 
                xscale(fill) 
                xtitle("", size(4) margin(l=2 r=2 t=5 b=2)) 
                xmtick(0(2.5)45, tl(1.5))
                
                ylab(0(5)45 
                ,
                labs(4) nogrid glc(gs16) angle(0) format(%9.1f))
                yscale(off) 
                ytitle("", size(2.5) margin(l=2 r=5 t=2 b=2)) 

                legend(size(4) position(3) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
                order(2 3) 
                lab(2 "Framingham") lab(3 "ASCVD")  
                )
                name(equiplot1) 
                ;
        #delimit cr
        graph export "`outputpath'/05_Outputs/cvdrisk_equiplot01.png", replace height(575) 
restore

** -------------------------------------------------------------------------------------------------------------------- 
*! Equiplot TWO of FRAMINGHAM versus ASCVD risk scores 
*! And comparing the two risk scores for the various stratifications in Table 1
** -------------------------------------------------------------------------------------------------------------------- 

** Create summaries by a range of binary stratifiers
tempfile s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14
replace fram_risk10 = fram_risk10*100
replace ascvd_risk10 = ascvd_risk10*100
gen indicator = .
** AGE25
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(age25 indicator) 
    keep if age25==1 
    replace indicator = 1
    drop age25
    save `s1', replace
restore
** AGE45
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(age45 indicator) 
    keep if age45==1 
    replace indicator = 2
    drop age45
    save `s2', replace
restore
** AGE65
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(age65 indicator) 
    keep if age65==1 
    replace indicator = 3
    drop age65 
    save `s3', replace
restore
** FEMALE
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(female indicator) 
    keep if female==1 
    replace indicator = 4
    drop female
    save `s4', replace
restore
** MALE
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(male indicator) 
    keep if male==1 
    replace indicator = 5
    drop male
    save `s5', replace
restore
** PRIMARY EDUCATED 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(primary_plus indicator) 
    keep if primary_plus==1 
    replace indicator = 6
    drop primary_plus
    save `s6', replace
restore
** SECONDARY EDUCATED 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(second_plus indicator) 
    keep if second_plus==1 
    replace indicator = 7
    drop second_plus
    save `s7', replace
restore
** TERTIARY EDUCATED 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(tertiary indicator) 
    keep if tertiary==1 
    replace indicator = 8
    drop tertiary
    save `s8', replace
restore
** PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(prof indicator) 
    keep if prof==1 
    replace indicator = 9
    drop prof
    save `s9', replace
restore
** SEMI PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(semi_prof indicator) 
    keep if semi_prof==1 
    replace indicator = 10
    drop semi_prof
    save `s10', replace
restore
** NON PROFESSIONAL 
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(non_prof indicator) 
    keep if non_prof==1 
    replace indicator = 11
    drop non_prof
    save `s11', replace
restore
** BINGE DRINKING
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(binge indicator) 
    keep if binge==1 
    replace indicator = 12
    drop binge
    save `s12', replace
restore
** 5 PORTIONS F&V
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(fv5 indicator) 
    keep if fv5 ==1 
    replace indicator = 13
    drop fv5 
    save `s13', replace
restore
** OBESE
preserve
    collapse (mean) fram_risk10 ascvd_risk10, by(ob indicator) 
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
        (rspike fram_risk10 ascvd_risk10 indicator , hor lc(gs6) lw(0.25))
        (sc indicator fram_risk10   , msize(3) m(o) mlc(gs0) mfc("4 90 141") mlw(0.1))
        (sc indicator ascvd_risk10  , msize(3) m(o) mlc(gs0) mfc("116 169 207") mlw(0.1))

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
            lab(2 "Framingham") lab(3 "ASCVD")  
            )            
            name(equiplot2) 
            ;
    #delimit cr
graph export "`outputpath'/05_Outputs/cvdrisk_equiplot02.png", replace height(575) 


* -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part4")
    b.delete_sheet("Part4")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part4)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Figure 4-1. Differences in Framingham and ASCVD CVD risk scores", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel B15 = "A. By ED. Women and Men combined", font("Calibri", 12) vcenter  
putexcel J15 = "B. By ED. Women only", font("Calibri", 12) vcenter  
putexcel R15 = "C. By ED. Men only", font("Calibri", 12) vcenter  
putexcel B48 = "D. By stratifiers presented in Table 1-1", font("Calibri", 12) vcenter  


** -------------------------------------------------------------------------------------------------------------------- 
*! Place the ED-level map
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B18 = image("`outputpath'/05_Outputs/cvdrisk_equiplot01.png")
putexcel J18 = image("`outputpath'/05_Outputs/cvdrisk_equiplot01w.png")
putexcel R18 = image("`outputpath'/05_Outputs/cvdrisk_equiplot01m.png")
putexcel B51 = image("`outputpath'/05_Outputs/cvdrisk_equiplot02.png")


** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part4")
    b.set_sheet_gridlines("Part4", "off")
    b.set_column_width(1,1,25)  //make row-title column widest
    b.set_row_height(1,1,30)    //make title row bigger
    b.set_row_height(5,5,30)    //make Interpretation title row bigger
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B5 = "Interpretation", font("Calibri", 12) bold vcenter  
putexcel (B6:S12) = "hello hello hello" , font("Calibri", 11) merge vcenter
putexcel (B5:S5), border(top, medium)
putexcel (B12:S12), border(bottom, medium)
putexcel (B5:B12), border(left, medium)
putexcel (S5:S12), border(right, medium) 
putexcel (B5:S5), fpattern(solid, "220 220 220")


