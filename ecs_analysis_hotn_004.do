** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_004.do
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
    log using "`logpath'\ecs_analysis_hotn_004", replace
** HEADER -----------------------------------------------------


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
tempfile risk10_barbados_ed risk10_barbados_parish

** -------------------------------------------------------------------------------------------------------------------- 
*! Set post-stratification weight 
** -------------------------------------------------------------------------------------------------------------------- 
gen unweighted = 1 
** wps_b2010
** wfinal1_ad
svyset ed [pweight=wps_b2010], strata(region) 

** -------------------------------------------------------------------------------------------------------------------- 
*! Prepare Risk categories and save dataset 
** -------------------------------------------------------------------------------------------------------------------- 
** CVD risk categories (WOMEN and MEN)
gen risk10_cat = . 
replace risk10_cat = 1 if risk10<0.1
replace risk10_cat = 2 if risk10>=0.1 & risk10<0.2
replace risk10_cat = 3 if risk10>=0.2 & risk10<.
label define _risk10_cat 1 "low" 2 "intermediate" 3 "high" 
label values risk10_cat _risk10_cat 
replace risk10 = risk10 * 100 

** ED level CVD risk data 
preserve
    keep pid ed parish sex risk10
    collapse (mean) risk10, by(ed sex) 
    gen r10w = risk10 if sex==1 
    gen r10m = risk10 if sex==2 
    collapse (mean) risk10 r10w r10m, by(ed) 
    save `risk10_barbados_ed', replace
restore

** Parish level CVD risk data 
preserve
    keep pid ed parish sex risk10
    collapse (mean) risk10, by(parish sex) 
    gen r10w = risk10 if sex==1 
    gen r10m = risk10 if sex==2 
    collapse (mean) risk10 r10w r10m, by(parish) 
    save `risk10_barbados_parish', replace
restore


** -------------------------------------------------------------------------------------------------------------------- 
*! Convert SHAPE files to Stata format 
** -------------------------------------------------------------------------------------------------------------------- 
** BARBADOS - ADMIN LEVEL 0 -- Country-level
shp2dta using "`datapath'/version02/1-input/gis/BRB_adm0"	///
				, data("`datapath'/version02/1-input/gis/brb0_database") coor("`datapath'/version02/1-input/gis/brb0_coords") replace genid(_polygonid)
				
** BARBADOS - ADMIN LEVEL 1 -- Parish-level
shp2dta using "`datapath'/version02/1-input/gis/BRB_adm1"	///
				, data("`datapath'/version02/1-input/gis/brb1_database2") coor("`datapath'/version02/1-input/gis/brb1_coords") replace genid(_polygonid)

** BARBADOS - ADMIN LEVEL 2 -- Enumeration District-level
shp2dta using "`datapath'/version02/1-input/gis/BRB_adm2_2010"	///
				, data("`datapath'/version02/1-input/gis/brb2_database2") coor("`datapath'/version02/1-input/gis/brb2_coords") replace genid(_polygonid)


** -------------------------------------------------------------------------------------------------------------------- 
*! Add CVD risk to Barbados GIS features database
** -------------------------------------------------------------------------------------------------------------------- 
** ED LEVEL DATA - merge with CVD risk
use "`datapath'/version02/1-input/gis/brb2_database", clear
rename ID3 tempid 
rename ENUM_NO1 ed 
replace _polygonid = ed
merge 1:1 ed using `risk10_barbados_ed'
drop _merge 
order ed _polygonid tempid risk10 r10w r10m
save "`datapath'/version02/1-input/gis/brb2_database2", replace


** PARISH LEVEL DATA - merge with CVD risk
use "`datapath'/version02/1-input/gis/brb1_database", clear
gen parish = _polygonid
merge 1:1 parish using `risk10_barbados_parish'
drop _merge 
order _polygonid parish NAME_1 r10w r10m
save "`datapath'/version02/1-input/gis/brb1_database2", replace


** (GRAPHIC 1)  BARBADOS EDs (WOMEN and MEN COMBINED)
use "`datapath'/version02/1-input/gis/brb2_database2", replace
#delimit ;
spmap 	risk10 using "`datapath'/version02/1-input/gis/brb2_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(on) legend(pos(1) size(4))
		name(A_ED_all)
        ;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_ed.png", replace height(550) width(440) 


** (GRAPHIC 2)  BARBADOS EDs (WOMEN ONLY)
use "`datapath'/version02/1-input/gis/brb2_database2", replace
#delimit ;
spmap 	r10w using "`datapath'/version02/1-input/gis/brb2_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(off) legend(pos(1))
		name(B_ED_w)
		;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_edw.png", replace height(550) width(440) 

** (GRAPHIC 3)  BARBADOS EDs (MEN ONLY)
use "`datapath'/version02/1-input/gis/brb2_database2", replace
#delimit ;
spmap 	r10m using "`datapath'/version02/1-input/gis/brb2_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(off) legend(pos(1))
		name(C_ED_m)
		;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_edm.png", replace height(550) width(440) 



** (GRAPHIC 1)  BARBADOS PARISHES (WOMEN and MEN COMBINED)
use "`datapath'/version02/1-input/gis/brb1_database2", replace
#delimit ;
spmap 	risk10 using "`datapath'/version02/1-input/gis/brb1_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(on) legend(pos(1) size(4))
		name(A_PA_all)
        ;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_pa.png", replace height(550) width(440) 

** (GRAPHIC 2)  BARBADOS PARISHES (WOMEN ONLY)
use "`datapath'/version02/1-input/gis/brb1_database2", replace
#delimit ;
spmap 	r10w using "`datapath'/version02/1-input/gis/brb1_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(off) legend(pos(1))
		name(B_PA_w)
		;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_paw.png", replace height(550) width(440) 

** (GRAPHIC 3)  BARBADOS PARISHES (MEN ONLY)
use "`datapath'/version02/1-input/gis/brb1_database2", replace
#delimit ;
spmap 	r10m using "`datapath'/version02/1-input/gis/brb1_coords", moc(gs10)
		id(_polygonid) 
		clmethod(custom) clbreaks(0 5 10 15 20 45) clnumber(5) 
		fc("26 150 65" "166 217 106" "255 255 191" "253 174 97" "215 25 28") 
		oc(gs0 gs0 gs0 gs0 gs0 ) 
		os(0.02 0.02 0.02 0.02 0.02) 
        ndf(gs12)
        ndo(gs0)
        nds(0.01)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        legenda(off) legend(pos(1))
		name(C_PA_m)
		;
#delimit cr
graph export "`outputpath'/05_Outputs/fram_cvdmap_barbados_pam.png", replace height(550) width(440) 



* -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part3")
    b.delete_sheet("Part3")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part3)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Figure 3-1. CVD risk score for women and men by place of residence (Enumeration District, Parish)", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel B15 = "A. By ED. Women and Men combined", font("Calibri", 12) vcenter  
putexcel J15 = "B. By ED. Women only", font("Calibri", 12) vcenter  
putexcel R15 = "C. By ED. Men only", font("Calibri", 12) vcenter  
putexcel B48 = "D. By Parish. Women and Men combined", font("Calibri", 12) vcenter  
putexcel J48 = "E. By Parish. Women only", font("Calibri", 12) vcenter  
putexcel R48 = "F. By Parish. Men only", font("Calibri", 12) vcenter  

** -------------------------------------------------------------------------------------------------------------------- 
*! Place the ED-level map
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B18 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_ed.png")
putexcel J18 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_edw.png")
putexcel R18 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_edm.png")
putexcel B51 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_pa.png")
putexcel J51 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_paw.png")
putexcel R51 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_pam.png")

** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part3")
    b.set_sheet_gridlines("Part3", "off")
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

