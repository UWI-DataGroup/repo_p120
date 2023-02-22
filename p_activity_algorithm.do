*********************************************************************************************************************************************************
*   DESCRIPTION OF PHYSICAL ACTIVITY IN ECHORN DATASET
*********************************************************************************************************************************************************
* Starting with looking at prevalence of inactivity according to WHO guidelines: 150 minutes of moderate intensity activity per week OR 75 minutes of vigorous intensity 
* per week OR an equivalent combination, achieving at least 600 MET-minutes per week. 
*********************************************************************************************************************************************************
*------------------------------------------------------------------------------------------------------
* ACTIVITY AT WORK: Questions HB1 - HB8
*------------------------------------------------------------------------------------------------------
*VIGOROUS WORK ACTIVITY (HB1-HB4)

* If answered "no" to HB1, then HB2 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
recode HB2 0=.z
replace HB2=.z if HB1==0 | HB1==.

*Calculating min per day for vigorous work
gen mpdVW=.
replace mpdVW=(HB4*60) if HB3==1
replace mpdVW=HB4 if HB3==2
replace mpdVW=.a if HB4>16 & HB4<. & HB3==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses

*Calculating min per week for vigorous work
gen mpwVW=mpdVW*HB2 
replace mpwVW=.z if HB2==.z

*Calculating MET-min per week for vigorous work (assuming MET value of 8 for vigorous work)
gen VWMET=mpwVW*8
replace VWMET=.z if HB2==.z
label variable VWMET "MET-min per week from vigorous work"

* If answered "no" to HB5, then HB6 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
recode HB6 0=.z
replace HB6=.z if HB5==0 | HB5==.

*Calculating min per day for moderate-intensity work
gen mpdMW=.
replace mpdMW=(HB8*60) if HB7==1
replace mpdMW=HB8 if HB7==2
replace mpdMW=.a if HB8>16 & HB8<. & HB7==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses

*Calculating min per week for moderate intensity work
gen mpwMW=mpdMW*HB6  
replace mpwMW=.z if HB6==.z 

*Calculating MET-min per week for moderate intensity work (assuming MET value of 4 for moderate work)
gen MWMET=mpwMW*4
replace MWMET=.z if HB6==.z 
label variable MWMET "MET-min per week from moderate work"

*------------------------------------------------------------------------------------------------------
* ACTIVITY DURING ACTIVE TRANSPORT: Questions HB9 - HB12
*------------------------------------------------------------------------------------------------------

* If answered "no" to HB9, then HB10 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
recode HB10 0=.z
replace HB10=.z if HB9==0 | HB9==.

*Calculating min per day for active transport
gen mpdT=.
replace mpdT=(HB12*60) if HB11==1
replace mpdT=HB12 if HB11==2
replace mpdT=.a if HB12>16 & HB12<. & HB11==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses

*Calculating min per week for active transport
gen mpwT=mpdT*HB10 
replace mpwT=.z if HB10==.z 

*Calculating MET-min per week for active transport (assuming MET value of 4 for active transport)
gen TMET=mpwT*4
replace TMET=.z if HB10==.z 
label variable TMET "MET-min per week from active transport"

*------------------------------------------------------------------------------------------------------
* RECREATIONAL ACTIVITY: Questions HB13 - HB20
*------------------------------------------------------------------------------------------------------
**VIGOROUS ACTIVITY (questions HB13-HB16)

* If answered "no" to HB13, then HB14 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
recode HB14 0=.z
replace HB14=.z if HB13==0 | HB13==. 

*Calculating min per day for vigorous recreational activity
gen mpdVR=.
replace mpdVR=(HB16*60) if HB15==1
replace mpdVR=HB16 if HB15==2
replace mpdVR=.a if HB16>16 & HB16<. & HB15==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses

*Calculating min per week for vigorous recreational activity
gen mpwVR=mpdVR*HB14
replace mpwVR=.z if HB14==.z 

*Calculating MET-min per week for vigorous recreational activity (assuming MET value of 8 for vigorous recreational activity)
gen VRMET=mpwVR*8
replace VRMET=.z if HB14==.z 
label variable VRMET "MET-min per week from vigorous recreational activity"

* If answered "no" to HB17, then HB18 should have been skipped and "0" days should not have been an option. Need to recode those to .z (not applicable)
recode HB18 0=.z
replace HB18=.z if HB17==0 | HB17==.

*Calculating min per day for moderate recreational activity
gen mpdMR=.
replace mpdMR=(HB20*60) if HB19==1
replace mpdMR=HB20 if HB19==2
replace mpdMR=.a if HB20>16 & HB20<. & HB19==1 // according to GPAQ instructions, if more than 16 hours reported in ANY sub-domain, they should be removed from all analyses

*Calculating min per week for moderate recreational activity
gen mpwMR=mpdMR*HB18
replace mpwMR=.z if HB18==.z 

*Calculating MET-min per week for moderate recreational activity (assuming MET value of 4 for moderate recreational activity)
gen MRMET=mpwMR*4
replace MRMET=.z if HB18==.z 
label variable MRMET "MET-min per week from moderate recreational activity"

*------------------------------------------------------------------------------------------------------
* TOTAL MET MINUTES PER WEEK AND INACTIVITY PREVALENCE
*------------------------------------------------------------------------------------------------------
/* GPAQ analysis guide states that if either of the following conditions are met, the respondent should be removed from all analyses, resulting in the same denominator across 
all domains and analyses: 
1) More than 16 hours reported in ANY sub-domain
2) Inconsistent answers (e.g. 0 days reported, but values >0 in corresponding time variables)
*/

generate PAclean=1
replace PAclean=0 if mpdVW==.a | mpdMW==.a | mpdT==.a | mpdVR==.a | mpdMR==.a 
replace PAclean=0 if HB1==0 & HB2>=1 & HB2<=7 
replace PAclean=0 if HB5==0 & HB6>=1 & HB6<=7 
replace PAclean=0 if HB9==0 & HB10>=1 & HB10<=7
replace PAclean=0 if HB13==0 & HB14>=1 & HB14<=7  
replace PAclean=0 if HB17==0 & HB18>=1 & HB18<=7  

*TOTAL MET MINUTES PER WEEK FROM ALL DOMAINS
egen totMETmin=rowtotal(VWMET MWMET TMET VRMET MRMET)
replace totMETmin=. if PAclean==0
gen inactive=.
replace inactive=1 if totMETmin<600
replace inactive=0 if totMETmin>=600 & totMETmin<.
label variable inactive "inactive WHO recommendations"
label define inactive 0 "active" 1 "inactive"
label values inactive inactive 


