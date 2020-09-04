* HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			        Comparison of CVD risk scores in ECHORN wave 1

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 120

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"
     ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p120
    ** GRAPHS to project output folder
    local outputpath "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p120\05_Outputs\DASR_presentation"
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\006_CVDRisk_comparison", replace


** LOAD FRAMINGHAM AND ECHORN DATASET
    use "`datapath'/version03/02-working/wave1_framingham_cvdrisk_prepared", clear

*rename risk variables for clarity and convert to %
    gen framgen10 = risk10 * 100
    label variable framgen10 "General Fram, 10 yr risk"
    drop risk10 
    gen framsim10 = nolabrisk10 * 100
    label variable framsim10 "Simplified Fram, 10 yr risk"
    drop nolabrisk10
    rename risk10_cat framgen_cat
    label variable framgen_cat "General Fram Categories"
    rename nolabrisk10cat framsim_cat
    label variable framsim_cat "Simplified Fram Categories"
    rename optrisk10 framopt10

*merge with reduced ASCVD dataset
merge 1:1 key using "`datapath'/version03/02-working/ascvd_reduced"
drop _merge
codebook framgen10
codebook framsim10
codebook ascvd10


**Prevalence of high risk according to each risk score
*Framingham General equation
gen frgen_high = 0
replace frgen_high=1 if framgen_cat==3
replace frgen_high=. if framgen_cat==.
label variable frgen_high "high risk General Fram"
*Framingham simplified equation
gen frsim_high = 0
replace frsim_high=1 if framsim_cat==3
replace frsim_high=. if framsim_cat==.
label variable frsim_high "high risk General Fram"
*ASCVD
gen ascvd_high = 0
replace ascvd_high = 1 if ascvd10 >= 7.5 & ascvd10 <.
replace ascvd_high = . if ascvd10==.
label variable ascvd_high "high risk ASCVD"

*-----------------------------------------------------------------
**CREATE INDICATOR VARIABLES FOR EACH STRATIFIER
*-----------------------------------------------------------------
** COUNTRY indicators
gen usvi = (siteid==1) if !missing(siteid)
gen pr = (siteid==2) if !missing(siteid)
gen bb = (siteid==3) if !missing(siteid)
gen tt = (siteid==4) if !missing(siteid)

** AGE indicators
gen age40 = (age_gr2==1) if !missing(age_gr2)
gen age50 = (age_gr2==2) if !missing(age_gr2)
gen age60 = (age_gr2==3) if !missing(age_gr2)
gen age70 = (age_gr2==4) if !missing(age_gr2)

** EDUCATION
gen educ1 = (educ==1) if !missing(educ)
gen educ2 = (educ==2) if !missing(educ)
gen educ3 = (educ==3) if !missing(educ)
gen educ4 = (educ==4) if !missing(educ)

** GENDER and OCCUPATION indicators already exist


** -------------------------------------------------------------------------------------------------------------------- 
** Equiplot of FRAMINGHAM GENERAL AND SIMPLIFIED versus ASCVD risk scores 
** And comparing the risk scores for the various stratifications in Table 1
** -------------------------------------------------------------------------------------------------------------------- 

**  Create summaries by a range of binary stratifiers
tempfile s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17
gen indicator=.
replace frgen_high = frgen_high * 100
replace frsim_high = frsim_high * 100
replace ascvd_high = ascvd_high * 100

** COUNTRY (USVI)
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (usvi indicator)
    keep if usvi==1
    replace indicator = 1
    drop usvi
    save `s1', replace
restore

** COUNTRY (PR)
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (pr indicator)
    keep if pr==1
    replace indicator = 2
    drop pr
    save `s2', replace
restore

** COUNTRY (BB)
preserve    
    collapse (mean) frgen_high frsim_high ascvd_high, by (bb indicator)
    keep if bb==1
    replace indicator = 3
    drop bb
    save `s3', replace
restore

** COUNTRY TT
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (tt indicator)
    keep if tt==1
    replace indicator = 4
    drop tt 
    save `s4', replace
restore

** AGE40
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (age40 indicator)
    keep if age40==1
    replace indicator = 6
    drop age40 
    save `s5', replace
restore

** AGE50
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (age50 indicator)
    keep if age50==1
    replace indicator = 7
    drop age50 
    save `s6', replace
restore

** AGE60
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (age60 indicator)
    keep if age60==1
    replace indicator = 8
    drop age60 
    save `s7', replace
restore

** AGE70
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by (age70 indicator)
    keep if age70==1
    replace indicator = 9
    drop age70 
    save `s8', replace
restore

** FEMALE
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(female indicator) 
    keep if female==1 
    replace indicator = 11
    drop female
    save `s9', replace
restore

** MALE
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(male indicator) 
    keep if male==1 
    replace indicator = 12
    drop male
    save `s10', replace
restore

** Level 1 education
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(educ1 indicator) 
    keep if educ1==1 
    replace indicator = 14
    drop educ1
    save `s11', replace
restore
** Level 2 education
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(educ2 indicator) 
    keep if educ2==1 
    replace indicator = 15
    drop educ2
    save `s12', replace
restore
** Level 3 education 
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(educ3 indicator) 
    keep if educ3==1 
    replace indicator = 16
    drop educ3 
    save `s13', replace
restore
** Level 4 education 
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(educ4 indicator) 
    keep if educ4==1 
    replace indicator = 17
    drop educ4
    save `s14', replace
restore

** PROFESSIONAL 
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(prof indicator) 
    keep if prof==1 
    replace indicator = 19
    drop prof
    save `s15', replace
restore
** SEMI PROFESSIONAL 
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(semi_prof indicator) 
    keep if semi_prof==1 
    replace indicator = 20
    drop semi_prof
    save `s16', replace
restore
** NON PROFESSIONAL 
preserve
    collapse (mean) frgen_high frsim_high ascvd_high, by(non_prof indicator) 
    keep if non_prof==1 
    replace indicator = 21
    drop non_prof
    save `s17', replace
restore


preserve
use `s1', clear
forval x = 2(1)17 {
    append using `s`x''
}


#delimit ;
label define _indicator 1 "USVI"
                        2 "PR"
                        3 "BB"
                        4 "TT"
                        6 "40-49 years"
                        7 "50-59 years"
                        8 "60-69 years"
                        9 "70+ years"
                        11 "Female"
                        12 "Male"
                        14 "Educ Level 1"
                        15 "Educ Level 2"
                        16 "Educ level 3"
                        17 "Educ Level 4"
                        19 "Professional"
                        20 "Semi-Professional"
                        21 "Non-Professional";
#delimit cr
label values indicator _indicator

    #delimit ;
        gr twoway 
        (rspike frgen_high frsim_high indicator , hor lc(gs6) lw(0.25))
        (rspike frsim_high ascvd_high indicator , hor lc(gs6) lw(0.25))
        (sc indicator frgen_high   , msize(2) m(o) mlc(gs0) mfc("4 90 141") mlw(0.1))
        (sc indicator frsim_high  , msize(2) m(o) mlc(gs0) mfc("116 169 207") mlw(0.1))
        (sc indicator ascvd_high  , msize(2) m(o) mlc(gs0) mfc("84 39 143") mlw(0.1))

        ,

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
        bgcolor(white) 
        ysize(20) xsize(15)
            
            xlab(0(20)100, labs(vsmall) nogrid glc(gs16))
            ///xscale(off) 
            xscale(fill) 
            xtitle("% High Risk", size(3) margin(l=2 r=2 t=5 b=2)) 
            xmtick(0(20)100, tl(1))
            
			ylab( 1 "USVI" 2 "PR" 3 "BB" 4 "TT" 6 "40-49" 7 "50-59" 8 "60-69" 9 "70+" 11 "Female" 12 "Male" 14 "Educ 1" 15 "Educ 2" 16 "Educ 3" 17 "Educ 4" 19 "Professional" 20 "Semi-professional" 21 "Non-professional"
            ,
            labs(vsmall) val nogrid glc(gs16) angle(0) format(%9.1f))
            yscale(fill reverse range(0(1)20)) 
            ytitle("", size(2.5) margin(l=2 r=5 t=2 b=2)) 

            legend(size(2) position(1) ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
            region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
            order(3 4 5) 
            lab(3 "Framingham General") lab (4 "Framingham Simplified") lab(5 "AHA/ASCVD")  
            )            
            name(equiplot_scores) 
            ;
    #delimit cr
graph export "`outputpath'/cvdrisk_equiplotscores.png", replace height(575) 


restore
