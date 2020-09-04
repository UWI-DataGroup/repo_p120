* HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			        Inequality in CVD risk by place for ECHORN wave 1

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
    log using "`logpath'\005_CVDInequality", replace

*----------------------------------------------------------------
** OPEN ADDRESS DATASET
*----------------------------------------------------------------
import excel "`datapath'\version03\01-input\addresses_CDRC.xlsx", sheet("addresses_CDRC") firstrow

* MERGE WITH ECHORN CVD RISK DATASET
merge 1:1 key using "`datapath'\version03\02-working\wave1_framingham_cvdrisk_prepared.dta"
order siteid, after(key)
destring ED, generate(ED1)
order ED1, after(ED)
drop ED
rename ED1 ED
list key if siteid==3 & ED==.
list key if siteid==4 & ED==.

*make 10 yr risk into % for presentation
gen riskperc = nolabrisk10*100
drop nolabrisk10
rename riskperc nolabrisk10

**************************************************************************************
* THESE DECISIONS TO BE REVIEWED OR USED FOR SENSITIVITY ANALYSIS
**************************************************************************************
*ED incorrectly written as 566 instead of 556 for 1 participant (Barbados)
replace ED = 556 in 855
*get rid of participant if ED is missing
drop if ED==.
*Trinidad has several EDs with less than 5 participants. Removed these from analysis
drop if ED==70001 | ED==7250 | ED==8220 | ED==1701 | ED==1900 | ED==10700
*Trinidad has two EDs with only women. Removed these from analysis
drop if ED==10300 | ED==12900 

*BARBADOS ONLY 
tempfile bbwomen bbmen bbcombine

*women only 
preserve
        keep if siteid==3
        keep if gender==2
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminw = min(nolabrisk10)
            egen rmaxw = max(nolabrisk10) 
            gen dw = rmaxw - rminw
            ** SIMPLE RELATIVE
            gen rrw = rmaxw / rminw
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jw =  _N-1
            gen rdiffw = abs(rminw - nolabrisk10)
            egen mdw = sum(rdiffw/Jw)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idw = (mdw / rminw) * 100
            sca sc_dw = dw
            sca sc_mdw = mdw 
            sca sc_rrw = rrw 
            sca sc_idw = idw 
            drop Jw rminw rdiffw
            save `bbwomen'
restore

*men only 
preserve
        keep if siteid==3
        keep if gender==1
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminm = min(nolabrisk10)
            egen rmaxm = max(nolabrisk10) 
            gen dm = rmaxm - rminm
            ** SIMPLE RELATIVE
            gen rrm = rmaxm / rminm
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jm =  _N-1
            gen rdiffm = abs(rminm - nolabrisk10)
            egen mdm = sum(rdiffm/Jm)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idm = (mdm / rminm) * 100
            sca sc_dm = dm 
            sca sc_mdm = mdm 
            sca sc_rrm = rrm 
            sca sc_idm = idm 
            drop Jm rminm rdiffm
            save `bbmen'
restore

*men and women combined 
preserve
        keep if siteid==3
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminc = min(nolabrisk10)
            egen rmaxc = max(nolabrisk10) 
            gen dc = rmaxc - rminc
            ** SIMPLE RELATIVE
            gen rrc = rmaxc / rminc
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jc =  _N-1
            gen rdiffc = abs(rminc - nolabrisk10)
            egen mdc = sum(rdiffc/Jc)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idc = (mdc / rminc) * 100
            sca sc_dc = dc
            sca sc_mdc = mdc 
            sca sc_rrc = rrc 
            sca sc_idc = idc 
            drop Jc rminc rdiffc
            save `bbcombine'
restore


**List inequality metrics for table
preserve
        use `bbwomen', clear
        merge 1:1 ED using `bbmen'
        drop _merge
        merge 1:1 ED using `bbcombine'
        drop _merge

    list dw mdw rrw idw if _n==1
    list dm mdm rrm idm if _n==1
    list dc mdc rrc idc if _n==1
restore


*TRINIDAD ONLY 
tempfile ttwomen ttmen ttcombine

*women only 
preserve
        keep if siteid==4
        keep if gender==2
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminw = min(nolabrisk10)
            egen rmaxw = max(nolabrisk10) 
            gen dw = rmaxw - rminw
            ** SIMPLE RELATIVE
            gen rrw = rmaxw / rminw
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jw =  _N-1
            gen rdiffw = abs(rminw - nolabrisk10)
            egen mdw = sum(rdiffw/Jw)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idw = (mdw / rminw) * 100
            sca sc_dw = dw
            sca sc_mdw = mdw 
            sca sc_rrw = rrw 
            sca sc_idw = idw 
            drop Jw rminw rdiffw
            save `ttwomen'
restore

*men only 
preserve
        keep if siteid==4
        keep if gender==1
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminm = min(nolabrisk10)
            egen rmaxm = max(nolabrisk10) 
            gen dm = rmaxm - rminm
            ** SIMPLE RELATIVE
            gen rrm = rmaxm / rminm
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jm =  _N-1
            gen rdiffm = abs(rminm - nolabrisk10)
            egen mdm = sum(rdiffm/Jm)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idm = (mdm / rminm) * 100
            sca sc_dm = dm 
            sca sc_mdm = mdm 
            sca sc_rrm = rrm 
            sca sc_idm = idm 
            drop Jm rminm rdiffm
            save `ttmen'
restore

*men and women combined 
preserve
        keep if siteid==4
        collapse (mean) nolabrisk10, by (ED)
            ** SIMPLE ABSOLUTE
            egen rminc = min(nolabrisk10)
            egen rmaxc = max(nolabrisk10) 
            gen dc = rmaxc - rminc
            ** SIMPLE RELATIVE
            gen rrc = rmaxc / rminc
            ** COMPLEX ABSOLUTE. Mean Absolute Deviation from BEST rate (MD) 
            gen Jc =  _N-1
            gen rdiffc = abs(rminc - nolabrisk10)
            egen mdc = sum(rdiffc/Jc)
            ** COMPLEX RELATIVE. Index of Disparity
            gen idc = (mdc / rminc) * 100
            sca sc_dc = dc
            sca sc_mdc = mdc 
            sca sc_rrc = rrc 
            sca sc_idc = idc 
            drop Jc rminc rdiffc
            save `ttcombine'
restore


**List inequality metrics for table
preserve
        use `ttwomen', clear
        merge 1:1 ED using `ttmen'
        drop _merge
        merge 1:1 ED using `ttcombine'
        drop _merge

    list dw mdw rrw idw if _n==1
    list dm mdm rrm idm if _n==1
    list dc mdc rrc idc if _n==1
restore
**----------------------------------------------------------------------
** ORDERED BAR CHARTS
**----------------------------------------------------------------------
** WOMEN and MEN in BARBADOS
#delimit ;
		gr hbar nolabrisk10 if siteid==3,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 153 41")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":7.8}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_all_BB)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_BBall.png", replace width(250)

** WOMEN in BARBADOS
#delimit ;
		gr hbar nolabrisk10 if siteid==3 & gender==2,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 196 79")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":9.1}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_women_BB)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_BBwomen.png", replace width(250)

** MEN in BARBADOS
#delimit ;
		gr hbar nolabrisk10 if siteid==3 & gender==1,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("236 112 20")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":20.7}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_men_BB)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_BBmen.png", replace width(250)


** WOMEN and MEN in TRINIDAD
#delimit ;
		gr hbar nolabrisk10 if siteid==4,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 153 41")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)45,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":10.8}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_all_TT)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_TTall.png", replace width(250)

** WOMEN in TRINIDAD
#delimit ;
		gr hbar nolabrisk10 if siteid==4 & gender==2,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("254 196 79")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(5(5)50,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":14.0}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_women_TT)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_TTwomen.png", replace width(250)

** MEN in TRINIDAD
#delimit ;
		gr hbar nolabrisk10 if siteid==4 & gender==1,
	
		over(ED, sort(1) lab(nolab labs(2.75)) axis(noline)) exclude0
		bar(1, col("236 112 20")) bargap(2)	
				
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(12) xsize(7)
	
		ylab(10(10)80,
		labs(4) notick grid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(t=3) size(3.75))
		yscale(lw(vthin) reverse noline fill range(7(1)26))

        text(43 80 `"{fontface "Calibri Light":MD}"', place(c) size(8) color(gs2))
        text(43 85 `"{fontface "Calibri Light":20.5}"', place(c) size(8) color(gs2))
		legend(off)
		name(cvd_risk_men_TT)
        ;
#delimit cr	
graph export "`outputpath'/fram_orderedbar_TTmen.png", replace width(250)