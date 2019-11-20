** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_004.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        Part 3. Mapping Framingham CVD Risk Score using HotN sample.

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
    b.set_sheet("Part3-Mapping")
    b.delete_sheet("Part3-Mapping")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part3-Mapping)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Figure 3-1. CVD risk score for women and men by place of residence (Enumeration District, Parish)", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel B14 = "A. By ED. Women and Men combined", font("Calibri", 12) vcenter bold  
putexcel J14 = "B. By ED. Women only", font("Calibri", 12) vcenter bold  
putexcel R14 = "C. By ED. Men only", font("Calibri", 12) vcenter bold  
putexcel B47 = "D. By Parish. Women and Men combined", font("Calibri", 12) vcenter bold  
putexcel J47 = "E. By Parish. Women only", font("Calibri", 12) vcenter bold  
putexcel R47 = "F. By Parish. Men only", font("Calibri", 12) vcenter bold  

** -------------------------------------------------------------------------------------------------------------------- 
*! Place the ED-level map
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B17 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_ed.png")
putexcel J17 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_edw.png")
putexcel R17 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_edm.png")
putexcel B50 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_pa.png")
putexcel J50 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_paw.png")
putexcel R50 = image("`outputpath'/05_Outputs/fram_cvdmap_barbados_pam.png")

** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part3-Mapping")
    b.set_sheet_gridlines("Part3-Mapping", "off")
    b.set_column_width(1,1,25)  //make row-title column widest
    b.set_row_height(1,1,30)    //make title row bigger
    b.set_row_height(5,5,30)    //make Interpretation title row bigger
    b.set_row_height(6,6,80)  //interpretation
    b.set_row_height(7,7,30)  //interpretation
    b.set_row_height(8,8,70)  //interpretation
    b.set_row_height(9,9,70)  //interpretation
    b.set_row_height(10,10,70)  //interpretation
    b.set_row_height(11,11,50)  //interpretation    
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 

putexcel B5 = "Interpretation", font("Calibri", 12) bold vcenter  

** Results Box 1 
local text1 = "Using Barbados for this example analysis, choropleth maps of 10-year CVD risk by ED are presented in Figures A-C, and by parish are presented in Figures D-F."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B6:S6) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 2 
local text1 = "Initially, we note the small number of EDs represented in the Health of the Nation risk factor survey (45 EDs out of a total 583 EDs). This limits our ability to conduct a traditional 'hot-spot' analysis, for which we would rely on the availability of risk information from contiguous neighborhoods. Alternative techniques are available to us, including using 'place' in CVD risk rankings - eg. see Part 2 of this analysis."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B7:S7) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 3 
local text1 = "Looking at the ED-level maps for women and for men, we note again the higher CVD risk distribution apparent among men, compared to women. Anecdotally, we wonder about a 'coastal ring' of high CVD risk EDs for men around Barbados, which includes the Bridgetown 'conurbation' of St.Michael and Christ Church. This somewhat arguable visual impression would need formal exploration."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B8:S8) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 4
local text1 = "Provide additional information on the sampled participants, by ED - as context for these ED-level CVD risk scores."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B9:S9) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 5
local text1 = "It is important to interpret GIS information in the context of local neighborhood knowledge. It will be important, and hopefully insightful, to provide summaries / characteristics of the sampled EDs, for context. These characteristics could feed into an 'ecological regression' noted as additional work below. ED-level information is collected at each census, is not openly available in much of the caribbean, but data access is perhaps worth exploring."
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B10:S10) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 6
local text1a = "Document additional GIS information layers available in each territory - GIS data audit."
local text1b = "Produce ED-level maps of HotN and ECHORN EDs combined."
local text1c = "Ecological regression - neighborhood influences on CVD risk"
local text1d = "Multi-level model of CVD risk - individual-level factors from survey + neighborhood-level factors from census."
local text2 = "Potential Additional Work:   " + ustrunescape("\u25cf") + " `text1a'   " + ustrunescape("\u25cf") + "  `text1b'  " + ustrunescape("\u25cf") + " `text1c' " + ustrunescape("\u25cf") + " `text1d' "
putexcel (B11:S11) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap italic bold

putexcel (B5:S5), border(top, medium)
putexcel (B5:S5), border(bottom, medium)
putexcel (B10:S10), border(bottom, medium)
putexcel (B11:S11), border(bottom, medium)
putexcel (B5:B11), border(left, medium)
putexcel (S5:S11), border(right, medium) 
putexcel (B5:S5), fpattern(solid, "220 220 220")
putexcel (B11:S11), fpattern(solid, "198 219 239")

