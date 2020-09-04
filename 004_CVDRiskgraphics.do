* HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_cvdrisk_framingham.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON and Christina Howitt
    //  algorithm task			        Recreate the graphics created for HotN for ECHORN wave 1

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
    log using "`logpath'\004_CVDRiskGraphics", replace

** HEADER -----------------------------------------------------


* ----------------------
** STEP 1. Enter mean risk data with CIs
** 
* ----------------------

clear
input yind risk ll ul
1	17.5	16.9	18.1
2	19.1	17.2	21
3	16.8	15.8	17.9
4	16.4	15.4	17.4
5	18.9	17.7	20.1
7	7.3	    6.9	    7.7
8	15.1	14.4	15.8
9	26.8	25.5	28
10	36.0	33.2	38.7
12	23.8	22.6	24.9
13	14.4	13.7	15
15	20.8	19.7	22
16	15.5	14.3	16.6
17	17.2	15.9	18.5
18	14.6	13.4	15.7
20	16.7	15.4	17.9
21	16.9	16	    17.9
22	19.1	17.3	20.8
end 


label define yind 1 "Overall" 2 "USVI" 3 "PR" 4 "BB" 5 "TT" 7 "40-49" 8 "50-59" 9 "60-69" 10 "70+" 12 "Male" 13 "Female" 15 "Educ 1" 16 "Educ 2" 17 "Educ 3" 18 "Educ 4" 20 "Professional" ///
21 "Semi-professional" 22 "Non-professional"

label values yind yind


# delimit ;
    gr twoway
        (rcap ll ul yind, horizontal lc(gs8) fc(gs10) lw(0.25) msize(vsmall))
		(sc yind risk, m(O) mfc("4 90 141") mlc("4 90 141") msize(small))
        ,
        plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) ) 
			graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin)) 
			ysize(6)

			xlab(5(5)40, 
			labs(small) nogrid glc(gs14) angle(0) labgap(2))
			xscale(lw(vthin) ) xtitle("10 yr CVD risk", margin(t=4) size(small)) 
			xmtick(5(5)40) xtick(5(10)40)
			
			ylab( 1 "Overall" 2 "USVI" 3 "PR" 4 "BB" 5 "TT" 7 "40-49" 8 "50-59" 9 "60-69" 10 "70+" 12 "Male" 13 "Female" 15 "Educ 1" 16 "Educ 2" 17 "Educ 3" 18 "Educ 4" 20 "Professional" 21 "Semi-professional" 22 "Non-professional" ,
			labs(vsmall) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("", margin(r=3) size(large))
			yscale(reverse lw(vthin) range(0.5(0.5)6.5) fill) 

            legend(off)
            ;
#delimit cr



