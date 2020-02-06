** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_007.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        Section 5 - Exporting WHO CVD risk score charts to MS EXCEL

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
    log using "`logpath'\ecs_analysis_hotn_007", replace
** HEADER -----------------------------------------------------



* -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part5-WHO-risk")
    b.delete_sheet("Part5-WHO-risk")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Part5-WHO-risk)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "Figure 5-1. WHO CVD risk score for people with and without diabetes", font("Calibri", 14) vcenter
putexcel A2 = "Algorithms Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
putexcel C15 = "A. Without Diabetes. Reference Chart", font("Calibri", 12) vcenter bold 
putexcel K15 = "B. Without Diabetes. HotN participants overlaid into Reference Chart", font("Calibri", 12) vcenter bold  
putexcel C48 = "C. With Diabetes. Reference Chart", font("Calibri", 12) vcenter  bold 
putexcel K48 = "D. With Diabetes. HotN participants overlaid into Reference Chart", font("Calibri", 12) vcenter bold  
putexcel H81  = "E. WHO CVD Risk categories. Unadjusted", font("Calibri", 12) vcenter bold  
putexcel H110 = "F. WHO CVD Risk categories. Adjusted", font("Calibri", 12) vcenter bold  

** -------------------------------------------------------------------------------------------------------------------- 
*! Place the ED-level map
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B18 = image("`outputpath'/05_Outputs/who_cvd_ref_nodiab.png")
putexcel J18 = image("`outputpath'/05_Outputs/who_cvd_ref_nodiab_hotn.png")
putexcel B51 = image("`outputpath'/05_Outputs/who_cvd_ref_diab.png")
putexcel J51 = image("`outputpath'/05_Outputs/who_cvd_ref_diab_hotn.png")
putexcel D84 = image("`outputpath'/05_Outputs/who_cvd_stacked.png")
putexcel D113 = image("`outputpath'/05_Outputs/who_cvd_stacked_adj.png")

** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Part5-WHO-risk")
    b.set_sheet_gridlines("Part5-WHO-risk", "off")
    b.set_column_width(1,1,25)  //make row-title column widest
    b.set_row_height(1,1,30)    //make title row bigger
    b.set_row_height(5,5,30)    //make Interpretation title row bigger
    b.set_row_height(6,6,50)  //interpretation
    b.set_row_height(7,7,50)  //interpretation
    b.set_row_height(8,8,50)  //interpretation
    b.set_row_height(9,9,50)  //interpretation
    b.set_row_height(10,10,50)  //interpretation
    b.set_row_height(11,11,50)  //interpretation    
    b.set_row_height(12,12,50)  //interpretation    
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! Interpretation
** -------------------------------------------------------------------------------------------------------------------- 

putexcel B5 = "Interpretation", font("Calibri", 12) bold vcenter  

** Results Box 1 
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B6:S6) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 2 
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B7:S7) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 3 
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B8:S8) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 4
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B9:S9) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 5
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B10:S10) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 6
local text1 = "xxx"
local text2 = uchar(5171) + "  " + "`text1'"
putexcel (B11:S11) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap

** Results Box 6
local text1a = "xxx"
local text1b = "xxx"
local text1c = "xxx"
local text2 = "Potential Additional Work:   " + ustrunescape("\u25cf") + " `text1a'   " + ustrunescape("\u25cf") + "  `text1b'  " + ustrunescape("\u25cf") + " `text1c' "
putexcel (B12:S12) = "`text2'" , font("Calibri", 11) merge vcenter txtwrap italic bold

putexcel (B5:S5), border(top, medium)
putexcel (B5:S5), border(bottom, medium)
putexcel (B11:S11), border(bottom, medium)
putexcel (B12:S12), border(bottom, medium)
putexcel (B5:B12), border(left, medium)
putexcel (S5:S12), border(right, medium) 
putexcel (B5:S5), fpattern(solid, "220 220 220")
putexcel (B12:S12), fpattern(solid, "198 219 239")




