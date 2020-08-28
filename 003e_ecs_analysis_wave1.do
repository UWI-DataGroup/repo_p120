** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			                Description of CVD risk according to Framingham General and simplified algorithms.

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

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\ecs_analysis_wave1_002", replace

** HEADER -----------------------------------------------------

**---------------------------------------
** PART ONE
** TABLE OF CVD RISK SCORES BY STRATIFIERS
**---------------------------------------

* ----------------------
** STEP 1. Load Data
** Dataset prepared in 003d_ecs_analysis_wave1.do
** USE FRAMINGHAM RISK SCORE
* ----------------------
use "`datapath'/version03/02-working/wave1_cvdrisk_prepared", clear

** -------------------------------------------------------------------------------------------------------------------- 
** DATA PREPARATION     
** -------------------------------------------------------------------------------------------------------------------- 
*Exclusions for Framingham: 
*   applicable to those 30-74 years, without previously diagnosed CVD
drop if partage>74 & partage<.
drop if mi==1 | stroke==1 | angina==1 | chd==1

**Convert mean risk scores to percentages rather than proportions for presentation:
**General algorithm
gen risk10perc = risk10*100
drop risk10 
rename risk10perc risk10 
**simplified algorithm
gen nolabrisk10perc = nolabrisk10*100
drop nolabrisk10 
rename nolabrisk10perc nolabrisk10 

** Create 0/1 variables for each risk category
** General algorithm

            tab risk10_cat, miss

                    /*
                    risk10_cat |      Freq.     Percent        Cum.
                    -------------+-----------------------------------
                            low |        817       27.59       27.59
                    intermediate |        478       16.14       43.74
                            high |        409       13.81       57.55
                            . |        871       29.42       86.96
                            .z |        386       13.04      100.00
                    -------------+-----------------------------------
                        Total |      2,961      100.00               */

            gen low=.
            replace low=0 if risk10_cat==2 | risk10_cat==3
            replace low=1 if risk10_cat==1
            replace low=.z if risk10_cat==.z
            label variable low "low Fram CVD risk"
            label define noyes 0 "No" 1 "Yes"
            label values low noyes

            gen inter=.
            replace inter=0 if risk10_cat==1 | risk10_cat==3
            replace inter=1 if risk10_cat==2
            replace inter=.z if risk10_cat==.z
            label variable inter "intermediate Fram CVD risk"
            label values inter noyes

            gen high=.
            replace high=0 if risk10_cat==1 | risk10_cat==2
            replace high=1 if risk10_cat==3
            replace high=.z if risk10_cat==.z
            label variable high "high Fram CVD risk"
            label values high noyes

** Simplified algorithm
            gen nolab_low=.
            replace nolab_low=0 if nolabrisk10cat!=1 
            replace nolab_low=1 if nolabrisk10cat==1
            label variable nolab_low "low Fram CVD risk (no lab)"
            label values nolab_low noyes

            gen nolab_inter=.
            replace nolab_inter=0 if nolabrisk10cat!=2
            replace nolab_inter=1 if nolabrisk10cat==2
            label variable nolab_inter "intermediate Fram CVD risk (no lab)"
            label values nolab_inter noyes

            gen nolab_high=.
            replace nolab_high=0 if nolabrisk10cat!=3
            replace nolab_high=1 if nolabrisk10cat==3
            label variable nolab_high "high Fram CVD risk (no lab)"
            label values nolab_high noyes



** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 1: Mean CVD risk score (UNADJUSTED) and CVD risk categorization calculated using general algorithm; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, 
** -------------------------------------------------------------------------------------------------------------------- 
**continuous risk score (based on lab algorithm)
mean risk10 
mean risk10, over(age_gr2)
mean risk10, over(gender)
mean risk10, over(educ)
mean risk10, over(occ)
mean risk10, over(binge)
mean risk10, over(inactive)
mean risk10, over(ob) 


** risk categories (based on lab algorithm)
prop risk10_cat
prop risk10_cat, over(age_gr2)
prop risk10_cat, over(gender)
prop risk10_cat, over(educ)
prop risk10_cat, over(occ)
prop risk10_cat, over(binge)
prop risk10_cat, over(inactive)
prop risk10_cat, over(ob)


** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 2: Mean CVD risk score (UNADJUSTED) and CVD risk categorization calculated using general algorithm; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, 
** -------------------------------------------------------------------------------------------------------------------- 

**continuous risk score (based on non-lab algorithm)
mean nolabrisk10 
mean nolabrisk10, over(age_gr2)
mean nolabrisk10, over(gender)
mean nolabrisk10, over(educ)
mean nolabrisk10, over(occ)
mean nolabrisk10, over(binge)
mean nolabrisk10, over(inactive)



** risk categories (based on non-lab algorithm)
prop nolabrisk10cat
prop nolabrisk10cat, over(age_gr2)
prop nolabrisk10cat, over(gender)
prop nolabrisk10cat, over(educ)
prop nolabrisk10cat, over(occ)
prop nolabrisk10cat, over(binge)
prop nolabrisk10cat, over(inactive)




** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 3: Mean CVD risk score (UNADJUSTED) by site calculated using general algorithm;
**          Stratified by Age, Sex, education, occupation, heavy drinking,
** -------------------------------------------------------------------------------------------------------------------- 

**continuous risk score (based on lab algorithm)
mean risk10 if siteid==1 
mean risk10 if siteid==1, over(age_gr2)
mean risk10 if siteid==1, over(gender)
mean risk10 if siteid==1, over(educ)
mean risk10 if siteid==1, over(occ)
mean risk10 if siteid==1, over(binge)
mean risk10 if siteid==1, over(inactive)

mean risk10 if siteid==2 
mean risk10 if siteid==2, over(age_gr2)
mean risk10 if siteid==2, over(gender)
mean risk10 if siteid==2, over(educ)
mean risk10 if siteid==2, over(occ)
mean risk10 if siteid==2, over(binge)
mean risk10 if siteid==2, over(inactive)

mean risk10 if siteid==3 
mean risk10 if siteid==3, over(age_gr2)
mean risk10 if siteid==3, over(gender)
mean risk10 if siteid==3, over(educ)
mean risk10 if siteid==3, over(occ)
mean risk10 if siteid==3, over(binge)
mean risk10 if siteid==3, over(inactive)

mean risk10 if siteid==4 
mean risk10 if siteid==4, over(age_gr2)
mean risk10 if siteid==4, over(gender)
mean risk10 if siteid==4, over(educ)
mean risk10 if siteid==4, over(occ)
mean risk10 if siteid==4, over(binge)
mean risk10 if siteid==4, over(inactive)

** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 4: Mean CVD risk score (UNADJUSTED) by site calculated using non-lab algorithm;
**          Stratified by Age, Sex, education, occupation, heavy drinking,
** -------------------------------------------------------------------------------------------------------------------- 
mean nolabrisk10 if siteid==1 
mean nolabrisk10 if siteid==1, over(age_gr2)
mean nolabrisk10 if siteid==1, over(gender)
mean nolabrisk10 if siteid==1, over(educ)
mean nolabrisk10 if siteid==1, over(occ)
mean nolabrisk10 if siteid==1, over(binge)
mean nolabrisk10 if siteid==1, over(inactive)

mean nolabrisk10 if siteid==2 
mean nolabrisk10 if siteid==2, over(age_gr2)
mean nolabrisk10 if siteid==2, over(gender)
mean nolabrisk10 if siteid==2, over(educ)
mean nolabrisk10 if siteid==2, over(occ)
mean nolabrisk10 if siteid==2, over(binge)
mean nolabrisk10 if siteid==2, over(inactive)

mean nolabrisk10 if siteid==3 
mean nolabrisk10 if siteid==3, over(age_gr2)
mean nolabrisk10 if siteid==3, over(gender)
mean nolabrisk10 if siteid==3, over(educ)
mean nolabrisk10 if siteid==3, over(occ)
mean nolabrisk10 if siteid==3, over(binge)
mean nolabrisk10 if siteid==3, over(inactive)

mean nolabrisk10 if siteid==4 
mean nolabrisk10 if siteid==4, over(age_gr2)
mean nolabrisk10 if siteid==4, over(gender)
mean nolabrisk10 if siteid==4, over(educ)
mean nolabrisk10 if siteid==4, over(occ)
mean nolabrisk10 if siteid==4, over(binge)
mean nolabrisk10 if siteid==4, over(inactive)




** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 5: Categories of CVD risk (UNADJUSTED) by site calculated using non-lab algorithm;
**          Stratified by Age and Gender
** -------------------------------------------------------------------------------------------------------------------- 

** risk categories (based on non-lab algorithm)
prop risk10_cat if siteid==1
prop risk10_cat if siteid==1, over(age_gr2)
prop risk10_cat if siteid==1, over(gender)

prop risk10_cat if siteid==2
prop risk10_cat if siteid==2, over(age_gr2)
prop risk10_cat if siteid==2, over(gender)

prop risk10_cat if siteid==3
prop risk10_cat if siteid==3, over(age_gr2)
prop risk10_cat if siteid==3, over(gender)

prop risk10_cat if siteid==4
prop risk10_cat if siteid==4, over(age_gr2)
prop risk10_cat if siteid==4, over(gender)


** -------------------------------------------------------------------------------------------------------------------- 
** ** TABLE 6: Categories of CVD risk (UNADJUSTED) by site calculated using non-lab algorithm;
**          Stratified by Age and Gender
** -------------------------------------------------------------------------------------------------------------------- 
** risk categories (based on non-lab algorithm)
prop nolabrisk10cat if siteid==1
prop nolabrisk10cat if siteid==1, over(age_gr2)
prop nolabrisk10cat if siteid==1, over(gender)

prop nolabrisk10cat if siteid==2
prop nolabrisk10cat if siteid==2, over(age_gr2)
prop nolabrisk10cat if siteid==2, over(gender)

prop nolabrisk10cat if siteid==3
prop nolabrisk10cat if siteid==3, over(age_gr2)
prop nolabrisk10cat if siteid==3, over(gender)

prop nolabrisk10cat if siteid==4
prop nolabrisk10cat if siteid==4, over(age_gr2)
prop nolabrisk10cat if siteid==4, over(gender)




**---------------------------------------
** PART TWO
** CVD RISK SCORE GRAPHICS
**---------------------------------------

** -------------------------------------------------------------------------------------------------------------------- 
** ** BAR CHART 1: Categories of CVD risk (UNADJUSTED) by site calculated using lab algorithm;
**          Stratified  Gender
** -------------------------------------------------------------------------------------------------------------------- 
*generate prevalences in each category
drop if risk10==.
gen prev1=low*100
gen prev2=inter*100
gen prev3=high*100

label define siteid 1 "USVI" 2 "PR" 3 "BB" 4 "TT"
label values siteid siteid

        #delimit ;

        graph hbar (mean) prev1 (mean) prev2 (mean) prev3, stack 
                name(FramCat_lab)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(4)
	
		
                over(siteid, gap(5)) 
                over(gender, gap(50))
		blabel(none, format(%9.0f) pos(outside) size(medsmall))
	
                bar(1, bc(green*0.65) blw(vthin) blc(green*0.65))
		bar(2, bc(yellow) blw(vthin) blc(yellow))
		bar(3, bc(red) blw(vthin) blc(red))
			
		
		ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		ytitle("10-yr CVD Risk Categories (lab-based)", margin(t=3) size(medsmall))
		ymtick(0(10)100)

                legend(size(small) position(12) bm(t=0 b=5 l=0 r=0) colf cols(3)
			region(lstyle(none) fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1)) 
			lab(1 "low risk")
			lab(2 "intermediate risk")
			lab(3 "high risk") )		
               saving(FramCat_lab, replace)  
                ;

	#delimit cr
        

** -------------------------------------------------------------------------------------------------------------------- 
** ** BAR CHART 2: Categories of CVD risk (UNADJUSTED) by site calculated using non-lab algorithm;
**          Stratified  Gender
** -------------------------------------------------------------------------------------------------------------------- 
*generate prevalences in each category
drop if nolabrisk10==.
gen prev4=nolab_low*100
gen prev5=nolab_inter*100
gen prev6=nolab_high*100


        #delimit ;

        graph hbar (mean) prev4 (mean) prev5 (mean) prev6, stack 
                        name(FramCat_nolab)
                        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
                        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                        ysize(4)
                
                        
                        over(siteid, gap(5)) 
                        over(gender, gap(50))
                        blabel(none, format(%9.0f) pos(outside) size(medsmall))
                
                        bar(1, bc(green*0.65) blw(vthin) blc(green*0.65))
                        bar(2, bc(yellow) blw(vthin) blc(yellow))
                        bar(3, bc(red) blw(vthin) blc(red))
                                
                        
                        ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
                        ytitle("10-yr CVD Risk Categories (non lab-based)", margin(t=3) size(medsmall))
                        ymtick(0(10)100)

                        legend(size(small) position(12) bm(t=0 b=5 l=0 r=0) colf cols(3)
                                region(lstyle(none) fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1)) 
                                lab(1 "low risk")
                                lab(2 "intermediate risk")
                                lab(3 "high risk") )		
                        saving(FramCat_nolab, replace)
                        ;

                #delimit cr


**---------------------------------------
** SAVE DATASET FOR NEXT ANALYSIS STEPS
**---------------------------------------
save "`datapath'/version03/02-working/wave1_framingham_cvdrisk", replace


/* THE BELOW CODE PRESENTS CVD RISK ADJUSTED FOR AGE AND GENDER. DECIDED NOT TO USE AS THESE ARE ACCOUNTED FOR IN THE FRAMINGHAM ALGORITHM
** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 1: Mean CVD risk score and CVD risk categorization calculated using general algorithm and adjusted by age and gender; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, obesity
** -------------------------------------------------------------------------------------------------------------------- 

*OVERALL
        **continuous risk score
        adjmean risk10, by(age_gr2) adjust(gender)
        adjmean risk10, by(gender) adjust(partage)
        adjmean risk10, by(educ) adjust(gender partage)
        adjmean risk10, by(occ) adjust(gender partage)
        adjmean risk10, by(binge) adjust(gender partage)
        adjmean risk10, by(inactive) adjust(gender partage) 
        adjmean risk10, by(ob) adjust(gender partage)


        adjprop low, by(age_gr2) adjust(gender)
        adjprop low, by(gender) adjust(partage)
        adjprop low, by(educ) adjust(gender partage)
        adjprop low, by(occ) adjust(gender partage)
        adjprop low, by(binge) adjust(gender partage)
        adjprop low, by(inactive) adjust(gender partage)
        adjprop low, by(ob) adjust(gender partage)

        adjprop inter, by(age_gr2) adjust(gender)
        adjprop inter, by(gender) adjust(partage)
        adjprop inter, by(educ) adjust(gender partage)
        adjprop inter, by(occ) adjust(gender partage)
        adjprop inter, by(binge) adjust(gender partage)
        adjprop inter, by(inactive) adjust(gender partage)
        adjprop inter, by(ob) adjust(gender partage)

        adjprop high, by(age_gr2) adjust(gender)
        adjprop high, by(gender) adjust(partage)
        adjprop high, by(educ) adjust(gender partage)
        adjprop high, by(occ) adjust(gender partage)
        adjprop high, by(binge) adjust(gender partage)
        adjprop high, by(inactive) adjust(gender partage)
        adjprop high, by(ob) adjust(gender partage)


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 2: Mean CVD risk score and CVD risk categorization calculated using simplified algorithm and adjusted by age and gender; 
**          Stratified by Age, Sex, education, occupation, heavy drinking, obesity
** -------------------------------------------------------------------------------------------------------------------- 

*OVERALL
        **continuous risk score
        adjmean nolabrisk10, by(age_gr2) adjust(gender)
        adjmean nolabrisk10, by(gender) adjust(partage)
        adjmean nolabrisk10, by(educ) adjust(gender partage)
        adjmean nolabrisk10, by(occ) adjust(gender partage)
        adjmean nolabrisk10, by(binge) adjust(gender partage)
        adjmean nolabrisk10, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10, by(ob) adjust(gender partage)
        

        *summarize categories adjusted by age and/or gender
        adjprop nolab_low, by(age_gr2) adjust(gender)
        adjprop nolab_low, by(gender) adjust(partage)
        adjprop nolab_low, by(educ) adjust(gender partage)
        adjprop nolab_low, by(occ) adjust(gender partage)
        adjprop nolab_low, by(binge) adjust(gender partage)
        adjprop nolab_low, by(inactive) adjust(gender partage)
        adjprop nolab_low, by(ob) adjust(gender partage)

        adjprop nolab_inter, by(age_gr2) adjust(gender)
        adjprop nolab_inter, by(gender) adjust(partage)
        adjprop nolab_inter, by(educ) adjust(gender partage)
        adjprop nolab_inter, by(occ) adjust(gender partage)
        adjprop nolab_inter, by(binge) adjust(gender partage)
        adjprop nolab_inter, by(inactive) adjust(gender partage)
        adjprop nolab_inter, by(ob) adjust(gender partage)

        adjprop nolab_high, by(age_gr2) adjust(gender)
        adjprop nolab_high, by(gender) adjust(partage)
        adjprop nolab_high, by(educ) adjust(gender partage)
        adjprop nolab_high, by(occ) adjust(gender partage)
        adjprop nolab_high, by(binge) adjust(gender partage)
        adjprop nolab_high, by(inactive) adjust(gender partage)
        adjprop nolab_high, by(ob) adjust(gender partage)


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 3: Mean CVD risk score calculated using general algorithm and adjusted by age and gender by site; 
**          Stratified by Age, Sex, education, occupation, heavy drinking and obesity
** --------------------------------------------------------------------------------------------------------------------

**BY SITE
**continuous risk score
        adjmean risk10, by(siteid) adjust(partage gender)

 **continuous risk score by site
        **USVI
        adjmean risk10 if siteid==1, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==1, by(gender) adjust(partage)
        adjmean risk10 if siteid==1, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==1, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==1, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==1, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==1, by(ob) adjust(gender partage)  

        **PR
        adjmean risk10 if siteid==2, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==2, by(gender) adjust(partage)
        adjmean risk10 if siteid==2, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==2, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==2, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==2, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==2, by(ob) adjust(gender partage)      

        **BARBADOS
        adjmean risk10 if siteid==3, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==3, by(gender) adjust(partage)
        adjmean risk10 if siteid==3, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==3, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==3, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==3, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==3, by(ob) adjust(gender partage) 

        **TRINIDAD
        adjmean risk10 if siteid==4, by(age_gr2) adjust(gender)
        adjmean risk10 if siteid==4, by(gender) adjust(partage)
        adjmean risk10 if siteid==4, by(educ) adjust(gender partage)
        adjmean risk10 if siteid==4, by(occ) adjust(gender partage)
        adjmean risk10 if siteid==4, by(binge) adjust(gender partage)
        adjmean risk10 if siteid==4, by(inactive) adjust(gender partage) 
        adjmean risk10 if siteid==4, by(ob) adjust(gender partage) 

** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 4: Mean CVD risk score calculated using simplified algorithm and adjusted by age and gender by site; 
**          Stratified by Age, Sex, education, occupation, heavy drinking and obesity
** --------------------------------------------------------------------------------------------------------------------

**BY SITE
**continuous risk score
        adjmean nolabrisk10, by(siteid) adjust(partage gender)

 **continuous risk score by site
        **USVI
        adjmean nolabrisk10 if siteid==1, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==1, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==1, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==1, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==1, by(ob) adjust(gender partage)  

        **PR
        adjmean nolabrisk10 if siteid==2, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==2, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==2, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==2, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==2, by(ob) adjust(gender partage)      

        **BARBADOS
        adjmean nolabrisk10 if siteid==3, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==3, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==3, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==3, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==3, by(ob) adjust(gender partage) 

        **TRINIDAD
        adjmean nolabrisk10 if siteid==4, by(age_gr2) adjust(gender)
        adjmean nolabrisk10 if siteid==4, by(gender) adjust(partage)
        adjmean nolabrisk10 if siteid==4, by(educ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(occ) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(binge) adjust(gender partage)
        adjmean nolabrisk10 if siteid==4, by(inactive) adjust(gender partage) 
        adjmean nolabrisk10 if siteid==4, by(ob) adjust(gender partage) 

   
 

** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 5: CVD risk categorization by site calculated using general algorithm and adjusted by age and gender; 
**          Stratified by Age 
** -------------------------------------------------------------------------------------------------------------------- 
**BY SITE
** risk categories
        adjprop low, by(siteid) adjust(partage gender)
        adjprop low if siteid==1, by(age_gr2) adjust(gender)
        adjprop low if siteid==2, by(age_gr2) adjust(gender)
        adjprop low if siteid==3, by(age_gr2) adjust(gender)
        adjprop low if siteid==4, by(age_gr2) adjust(gender)

        adjprop inter, by(siteid) adjust(partage gender)
        adjprop inter if siteid==1, by(age_gr2) adjust(gender)
        adjprop inter if siteid==2, by(age_gr2) adjust(gender)
        adjprop inter if siteid==3, by(age_gr2) adjust(gender)
        adjprop inter if siteid==4, by(age_gr2) adjust(gender)

        adjprop high, by(siteid) adjust(partage gender)
        adjprop high if siteid==1, by(age_gr2) adjust(gender)
        adjprop high if siteid==2, by(age_gr2) adjust(gender)
        adjprop high if siteid==3, by(age_gr2) adjust(gender)
        adjprop high if siteid==4, by(age_gr2) adjust(gender)


** -------------------------------------------------------------------------------------------------------------------- 
** TABLE 6: CVD risk categorization by site calculated using simplified algorithm and adjusted by age and gender; 
**          Stratified by Age 
** -------------------------------------------------------------------------------------------------------------------- 
**BY SITE
** risk categories
        adjprop nolab_low, by(siteid) adjust(partage gender)
        adjprop nolab_low if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_low if siteid==4, by(age_gr2) adjust(gender)

        adjprop nolab_inter, by(siteid) adjust(partage gender)
        adjprop nolab_inter if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_inter if siteid==4, by(age_gr2) adjust(gender)

        adjprop nolab_high, by(siteid) adjust(partage gender)
        adjprop nolab_high if siteid==1, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==2, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==3, by(age_gr2) adjust(gender)
        adjprop nolab_high if siteid==4, by(age_gr2) adjust(gender)

/*Boxplot comparing Framingham general to simplified

#delimit ;

graph hbox risk10 nolabrisk10, over(siteid, gap(*2)) 
        box(1, fcolor(gs10) fintensity(inten100) lcolor(gs10)) medtype(cline) medline(lcolor(white) lwidth(medthick)) marker(1, mcolor(gs5) msize(small))
        box(2, fcolor(gs2) fintensity(inten100) lcolor(gs2)) marker(2, mcolor(gs5) msize(small))
        	
        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
	graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
	ysize(6)
;
#delimit cr

*/


/*Bar chart comparing risk categorization based on Framingham general and simplified

drop if nolabrisk10==.
gen prev1=nolab_low*100
gen prev2=nolab_inter*100
gen prev3=nolab_high*100

gen prev4=low*100
gen prev5=inter*100
gen prev6=high*100

label define siteid 1 "USVI" 2 "PR" 3 "BB" 4 "TT"
label values siteid siteid

#delimit ;

graph hbar (mean) prev1 (mean) prev2 (mean) prev3, stack 
                name(g1)
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(4)
	
		
                over(siteid, gap(5)) 
                over(gender, gap(50))
		blabel(none, format(%9.0f) pos(outside) size(medsmall))
	
                bar(1, bc(green*0.65) blw(vthin) blc(green*0.65))
		bar(2, bc(yellow) blw(vthin) blc(yellow))
		bar(3, bc(red) blw(vthin) blc(red))
			
		
		ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		ytitle("10-yr CVD Risk Categories", margin(t=3) size(medium))
		ymtick(0(10)100)

                legend(size(small) position(12) bm(t=0 b=5 l=0 r=0) colf cols(3)
			region(lstyle(none) fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1)) 
			lab(1 "low risk")
			lab(2 "intermediate risk")
			lab(3 "high risk") )		
                
                ;

	#delimit cr
	


label define age_gr 1 "40-49" 2 "50-59" 3 "60-69" 4 "70+"
label values age_gr2 age_gr

#delimit ;

graph hbar (mean) prev1 (mean) prev2 (mean) prev3, stack
                name(g2) 
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
		ysize(5)   
	
		over(age_gr2, gap(5))
                over(siteid, gap(50)) 
		blabel(none, format(%9.0f) pos(outside) size(vsmall))
	
                bar(1, bc(green*0.65) blw(vthin) blc(white))
		bar(2, bc(yellow) blw(vthin) blc(white))
		bar(3, bc(red) blw(vthin) blc(white))
	
		ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		ytitle("10-yr CVD Risk Categories", margin(t=3) size(medium))
		ymtick(0(10)100)

                legend(size(small) position(12) bm(t=0 b=5 l=0 r=0) colf cols(3)
			region(lstyle(none) fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1)) 
			lab(1 "low risk")
			lab(2 "intermediate risk")
			lab(3 "high risk") )
		
			;

	#delimit cr		



        