** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name					ecs_analysis_hotn_methods.do
    //  project:				        Pediatric ECHORN (P-ECS)
    //  analysts:				       	Ian HAMBLETON
    // 	date last modified	            05-NOV-2019
    //  algorithm task			        Methods Section 

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
    log using "`logpath'\ecs_analysis_hotn_methods", replace
** HEADER -----------------------------------------------------



* -------------------------------------------------------------------------------------------------------------------- 
*! Open Excel output file 
** -------------------------------------------------------------------------------------------------------------------- 
mata
    b=xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Methods")
    b.delete_sheet("Methods")
    b.close_book()
end 
putexcel set "`outputpath'/05_Outputs/cvdrisk_example_Barbados", modify sheet(Methods)

** -------------------------------------------------------------------------------------------------------------------- 
*! Create Overall title and Column titles
** -------------------------------------------------------------------------------------------------------------------- 
putexcel A1 = "10-year CVD risk in Barbados: An example analysis using the Health of the Nation national risk factor survey", font("Calibri", 14) vcenter
putexcel A2 = "Report Created by:" C2 = "Ian Hambleton", font("Calibri", 12) vcenter
putexcel A3 = "Results last updated:" C3 = "`c(current_date)'", font("Calibri", 12) vcenter
** putexcel C15 = "A. Without Diabetes. Reference Chart", font("Calibri", 12) vcenter bold 
** putexcel K15 = "B. Without Diabetes. HotN participants overlaid into Reference Chart", font("Calibri", 12) vcenter bold  
** putexcel C48 = "C. With Diabetes. Reference Chart", font("Calibri", 12) vcenter  bold 
** putexcel K48 = "D. With Diabetes. HotN participants overlaid into Reference Chart", font("Calibri", 12) vcenter bold  
** putexcel H81  = "E. WHO CVD Risk categories. Unadjusted", font("Calibri", 12) vcenter bold  
** putexcel H110 = "F. WHO CVD Risk categories. Adjusted", font("Calibri", 12) vcenter bold  

** -------------------------------------------------------------------------------------------------------------------- 
*! Format Excel cells
** -------------------------------------------------------------------------------------------------------------------- 
mata 
    b = xl() 
    b.load_book("`outputpath'/05_Outputs/cvdrisk_example_Barbados.xlsx")
    b.set_sheet("Methods")
    b.set_sheet_gridlines("Methods", "off")
    b.set_column_width(1,1,25)      // make row-title column widest
    b.set_row_height(1,1,30)        // make title row bigger
    b.set_row_height(6,6,60)        // Background paragraph 
    b.set_row_height(16,16,140)     // ECHORN paragraph
    b.set_row_height(18,18,130)     // HOTN paragraph
    b.set_row_height(21,21,50)      // CVD Risk Intro paragraph
    b.set_row_height(23,23,100)     // Framingham CVD Risk paragraph
    b.set_row_height(27,27,45)     // Framingham Reference
    b.set_row_height(29,29,190)     // AAC/AHA CVD Risk paragraph
    b.set_row_height(30,30,50)     // AAC/AHA CVD Risk paragraph
    b.set_row_height(31,31,35)     // ASCVD Reference
    b.set_row_height(33,33,100)     // WHO CVD Risk paragraph
    b.set_row_height(36,36,75)     // Methods. Intro
    b.set_row_height(38,38,80)     // Methods. Part 1

    b.set_row_height(40,40,140)     // Methods. Part 2
    b.set_row_height(42,42,110)     // Methods. Part 2
    b.set_row_height(44,44,110)     // Methods. Part 2
    b.set_row_height(46,46,110)     // Methods. Part 2
    b.set_row_height(48,48,210)     // Methods. Part 2

    b.set_row_height(49,49,35)     // Part 2 reference
    b.set_row_height(50,50,35)     // Part 2 reference
    b.set_row_height(51,51,35)     // Part 2 reference
    b.set_row_height(52,52,35)     // Part 2 reference

    b.set_row_height(54,54,75)     // Methods. Part 3
    b.set_row_height(56,56,75)     // Methods. Part 4
    b.set_row_height(58,58,110)     // Methods. Part 5
    b.close_book()
end

** -------------------------------------------------------------------------------------------------------------------- 
*! SECTION: Background
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B5 = "BACKGROUND", font("Calibri", 12) bold vcenter  
** BACKGROUND
#delimit ; 
    putexcel (B6:P6) = 
    "This exploratory analysis provides an initial - mostly visual - introduction to understanding CVD burden - and contributors to that burden - in the Caribbean. A central theme is the attempt to better understand inequalities in CVD burden between the territories of the ECHORN cohort study, and also to highlight vulnerable populations with increased CVD burden." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 
putexcel (C7:P7) = "The analysis is divided into FIVE parts:", font("Calibri", 11) merge vcenter
putexcel (C8:P8) = "PART 1: Summarizing CVD risk by selected participant characteristics", font("Calibri", 11) merge vcenter
putexcel (C9:P9) = "PART 2: Inequalities in CVD risk by place of residence", font("Calibri", 11) merge vcenter
putexcel (C10:P10) = "PART 3: Mapping CVD risk", font("Calibri", 11) merge vcenter
putexcel (C11:P11) = "PART 4: Comparing alternative CVD risk scores", font("Calibri", 11) merge vcenter
putexcel (C12:P12) = "PART 5: Using the World Health Organization CVD risk score", font("Calibri", 11) merge vcenter


** -------------------------------------------------------------------------------------------------------------------- 
*! SECTION: Data
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B14 = "DATA", font("Calibri", 12) bold vcenter  
putexcel B15 = "The ECHORN Cohort Study (ECS)", font("Calibri", 12) bold vcenter  
** ECHORN
#delimit ; 
    putexcel (B16:P16) = 
    "Ultimately, this analysis will use data from the Eastern Caribbean Health Outcomes Research Network (ECHORN) Cohort Study (ECS). The ECS follows community-dwelling adults on the islands of the US Virgin Islands, Puerto Rico, Barbados and Trinidad with the goal of better understanding risk factors and early predictors for cancer, diabetes and cardiovascular disease. The ECS eligibility criteria included: age > 40 years, English or Spanish speaking, reliable contact information, has been semipermanent or permanent resident of the island for the past 10 years with no plans to relocate in the next 5 years. Pregnant women were not eligible. A random sampling frame was used for recruitment at each site: small islands included the entire island; larger islands (Puerto Rico, Trinidad) selected two communities with demographics representative of the island (similar distributions of age, race/ethnicity, sex and educational levels to the general island population). ECS baseline participants were enrolled between 2013 and 2016. They completed a baseline survey that captured sociodemographic, health status and health behavior information. The survey was conducted using computer guided and audio-assisted software. Participants also completed a brief physical exam and laboratory assessment." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 
** HOTN
putexcel B17 = "The Health of the Nation Barbados Risk Factor Survey (HotN)", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B18:P18) = 
    "The HotN was designed as a national, cross-sectional, population-based survey to determine the prevalence and distribution of diabetes, CVD and associated behavioural and biological risk factors in the Barbadian population, by age, sex and socioeconomic status. The design was based on island-wide sampling of enumeration districts (EDs), following the methodology of the Pan American Health Organization (PAHO)’s Pan American STEPS for CVD Risk Factors.6 The survey comprised the three following steps, all performed in the participant’s home: (1) The initial (questionnaire-based) step, in which research staff enquired directly about risk factors from a random selection of the population through face-to-face interviews; (2) the second step, which involved taking anthropometric measurements; (3) the third step, in which blood samples were drawn for estimates of biological markers for diabetes, kidney function, and lipids, amongst others. Participant sub-samples were recruited for dietary recall, and objective measures of physical activity." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 

** -------------------------------------------------------------------------------------------------------------------- 
*! SECTION: CVD Risk Scores
** -------------------------------------------------------------------------------------------------------------------- 
putexcel B20 = "CVD RISK SCORES", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B21:P21) = 
    "We have coded and used 3 CVD risk factor score: (1) The Framingham 10-year risk of General Cardiovascular Disease, (2) The ACC/AHA 2013 Cardiovascular Risk Assessment, and (3) The World Health Organization cardiovascular risk prediction charts."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 
** Framingham
putexcel B22 = "Framingham CVD Risk Score", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B23:P23) = 
    "The Framingham 10-year risk score for general cardiovascular disease was developed in 2008 as a gender-specific algorithm to estimate the 10-year cardiovascular risk of an individual. The estimated risk encompasses the following cardiovascular outcomes:  coronary heart disease, cerebrovascular events, peripheral artery disease and heart failure.(1) The score requires information on age, sex, systolic blood pressure, hypertension treatment status, smoking status, diabetes status, high density lipoprotein level, and total cholesterol level. The estimate is based on a Cox proportional hazards regression model, and can be applied to women and men who have had no prior history of cardiovascular disease. The score is continuous, stratified by sex (m/f) and whether lipid profile is available (n/y). With lipids, the choice of sex tweaks the implemented model, as follows:" 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 
#delimit ; 
    putexcel (B24:P24) = 
    "(Women) 1 - 0.95012 ^ exp(sum(beta*x) - 26.1931)      (Men) 1 - 0.88936 ^ exp(sum(beta*x) - 23.9802)" 
    , font("Calibri", 11) bold merge vcenter txtwrap;
#delimit cr 
#delimit ; 
    putexcel (B25:P25) = 
    "A simpler varient of the model is possible, if lipid profile does not exist which uses BMI instead" 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 

#delimit ; 
    putexcel (B26:P26) = 
    "(Women) 1 - 0.94833 ^ exp(sum(beta*x) - 26.0145)      (Men) 1 - 0.88431 ^ exp(sum(beta*x) - 23.9388)" 
    , font("Calibri", 11) bold merge vcenter txtwrap;
#delimit cr 
#delimit ; 
    putexcel (B27:P27) = 
    "(1) Ralph B. D’Agostino, Sr, Ramachandran S. Vasan, Michael J. Pencina, Philip A. Wolf, Mark Cobain, Joseph M. Massaro and William B. Kannel. General Cardiovascular Risk Profile for Use in Primary Care: The Framingham Heart Study. Circulation 2008; 117; 743-753" 
    , font("Calibri", 11) italic merge vcenter txtwrap;
#delimit cr 


** AAC/AHA
putexcel B28 = "ACC/AHA ASCVD Risk Score", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B29:P29) = 
    "The AAC/AHA CVD risk score uses Pooled Cohort Equations to estimate the 10-year primary risk of ASCVD (atherosclerotic cardiovascular disease) among patients without pre-existing cardiovascular disease who are between 40 and 79 years of age (1). Patients are considered to be at elevated risk if the Pooled Cohort Equations predicted risk is ≥ 7.5%. In many ways, the Pooled Cohort Equations have been proposed to replace the Framingham Risk 10-year CVD calculation, which was recommended for use in the NCEP ATP III guidelines for high blood cholesterol in adults. Current guidelines for the treatment of cholesterol to reduce cardiovascular risk recommend that the following four groups of patients will benefit from moderate- or high-intensity statin therapy: (1) Individuals with clinical ASCVD (2) Individuals with primary elevations of LDL ≥ 190 mg/dL (3) Individuals 40 to 75 years of age with diabetes and an LDL 70 to 189 mg/dL without clinical ASCVD (4) Individuals without clinical ASCVD or diabetes who are 40 to 75 years of age with LDL 70 to 189 mg/dL and a 10-year ASCVD risk of 7.5% or higher. So, among patients who do not otherwise have a compelling indication for statin therapy, the Pooled Cohort Equations can be used to estimate primary cardiovascular risk and potential benefit from statin therapy. The Pooled Cohort Equations were developed and validated among Caucasian and African American men and women who did not have clinical ASCVD. There are inadequate data in other racial groups, such as Hispanics, Asians, and American-Indian populations. Given the lack of data, current guidelines suggest to use the Caucasian race to estimate 10-year ASCVD risk with the knowledge that further research is needed to stratify these patients' risk. Compared to Caucasians, the risk of ASCVD is generally lower among Hispanic and Asian populations and generally higher among American-Indian populations." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 
#delimit ; 
    putexcel (B30:P30) = 
    "The ACC/AHA risk score has a similar analytical structure to the Framingham score, and differs in the coefficients and risk factor combination contributing to the score. The score requires age, sex, systolic blood pressure, hypertension treatment status, smoking status, diabetes status, high density lipoprotein level, and total cholesterol level. Two-way interaction terms are included, depending on the sex-race model in question." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 
#delimit ; 
    putexcel (B31:P31) = 
    "(1) 2013 ACC/AHA Guideline on the Assessment of Cardiovascular Risk. doi: 10.1161/​01.cir.0000437741.48606.98." 
    , font("Calibri", 11) merge vcenter txtwrap italic;
#delimit cr 


** WHO
putexcel B32 = "WHO/ISH Risk Prediction Charts", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B33:P33) = 
    "The WHO/ISH risk prediction charts indicate 10-year risk of a fatal or nonfatal major cardiovascular event (myocardial infarction or stroke), according to age, sex, blood pressure, smoking status, total blood cholesterol and presence or absence of diabetes mellitus for 14 WHO epidemiological sub-regions. Among the 193 Member States of WHO, all high-income countries have developed and refined cardiovascular risk prediction charts using cohort data from their own populations. Methods to predict the risk of heart attack or stroke do not exist for 160 low-resource WHO Member States. The WHO/ISH risk prediction charts have been developed from best available mortality and risk factor data of these low- and middle-income country (LMIC) populations. They are meant to be used in LMICs, where refined risk prediction charts do not exist." 
    , font("Calibri", 11) merge vcenter txtwrap;
#delimit cr 



** -------------------------------------------------------------------------------------------------------------------- 
*! SECTION: Analysis Methods
** -------------------------------------------------------------------------------------------------------------------- 
** Intro
putexcel B35 = "ANALYSIS OVERVIEW", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B36:P36) = 
    "We introduce and explore CVD burden - and contributors to that burden - in the Caribbean. Our central theme is an attempt to better understand inequalities in CVD burden between the territories of the ECHORN cohort study, and also to highlight vulnerable populations with increased CVD burden. Our analysis is in 5 parts: (Part 1) CVD risk summary (Part 2) Inequalities in CVD risk (Part 3) CVD risk maps (Part 4) COmparisong alternative CVD scores (Part 5) Using the WHO/ISH CVD risk score"
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

** PART ONE. CVD risk by stratifiers
putexcel B37 = "Part 1. CVD Risk Score Summary", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B38:P38) = 
    "Using the Framingham CVD Risk Score, we present average score (95% confidence intervals) by selected participant characteristics: age, sex, education, occupation, alcohol consumption, fruit and vegetable consumption, and obesity. We also present CVD risk categories as low (<10% risk), intermediate risk (10 to 20% risk), and high risk (20% risk or higher). In time, we plan to extend this presentation to include all the stratifiers of the PROGRESS+ acronym (Place, Race/Ethnicity, Occupation, Gender, Religion, Education, Socio-economic position, Social Capital, + Age)."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

** PART TWO. INEQUALITIES
putexcel B39 = "Part 2. CVD Risk Score Inequalities", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B40:P40) = 
    "Inequality is a complex and ambiguous concept that can be measured and conveyed using a variety of statistical techniques. When measuring health inequality the goal is always the same: to provide a quantitative estimate of health inequality in a population. To this end, one may have to use a variety of measures to fully explore a situation of health inequality. A goal of this analysis is to describe inequalities in cardiovascular disease (CVD) in the ECHORN countries (Barbados, Puerto Rico, Trinidad and Tobago, US Virgin Islands). There are many potential measures of health inequality, and the properties of some of these measures have been summarized previously (1-3). This report uses a number of inequality metrics based on three considerations: (Consideration 1) Do we want to present an absolute or relative inequality? (Consideration 2) Does the inequality stratifier have 2 or more than 2 groups? (Consideration 3) Are the stratfier groups ordered or non-ordered? "
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 
putexcel B41 = "(Consideration 1) Absolute or relative inequality?", font("Calibri", 12) vcenter italic 

#delimit ; 
    putexcel (B42:P42) = 
    "For a given health indicator, absolute inequality reflects the magnitude of difference in health between two subgroups. Hypothetically, if health service coverage were 100% and 90% in two subgroups of one population, and 20% and 10% in subgroups of another population, both cases would report absolute inequality of 10 percentage points (using simple difference calculation). Absolute inequality retains the same unit of measure as the health indicator, and conveys an easily understood concept. Relative inequality measures show proportional differences in health among subgroups. Using a simple ratio calculation, the relative inequality in a population with health service coverage of 100% and 50% in two subgroups would equal 2 (100/50 = 2); the relative inequality in a population with health service coverage of 2% and 1% in two subgroups would also equal 2 (2/1 = 2)."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 


putexcel B43 = "(Consideration 2) Two subgroups or more than 2 subgroups?", font("Calibri", 12) vcenter italic 

#delimit ; 
    putexcel (B44:P44) = 
    "Some equity stratifiers naturally generate two subgroups (for example, sex, urban-rural place of residence), while others may comprise multiple subgroups (for example, economic status, education level, region). Depending on the available data and the definition adopted, many equity stratifiers could be classified either way. For example, urban-rural subgroups could be expanded to differentiate between people living in large cities, small cities, towns, villages or countryside; economic status could be dichotomized to those living above or below the poverty line. In cases where there are two subgroups, it is appropriate to use pairwise comparisons of inequality (difference and ratio) to compare between subgroups directly. Complex measures of inequality are useful to measure inequality across more than two subgroups. "
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 


putexcel B45 = "(Consideration 3) Inequality measures for ordered or non-ordered groups?", font("Calibri", 12) vcenter italic 

#delimit ; 
    putexcel (B46:P46) = 
    "Groups may be either ordered or non-ordered, depending on the dimension of inequality (equity stratifier). Ordered groups have an inherent positioning and can be ranked. For example, wealth has an inherent ordering of subgroups in the sense that those with less wealth unequivocally have less of something compared to those with more wealth. Non-ordered groups, by contrast, are not based on criteria that can be logically ranked. Regions, ethnicity, religion and place of residence are examples of non-ordered groupings. This is an important distinction for health inequality monitoring, as certain inequality measures are appropriate for ordered groups or non-ordered groups."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 



putexcel B47 = "Suggested measures of inequality in this report", font("Calibri", 12) vcenter italic 

#delimit ; 
    putexcel (B48:P48) = 
    "We present TWO simple measures of inquality, comparing a notional best performing category with a worst performing. RATE DIFFERENCE (RD): The rate difference (RD) is a simple absolute inequality measure. It is the arithmetic difference between two subgroups (for example the two ECHORN countries with the highest and lowest levels of a risk factor or disease outcome). In other words it reports the absolute disparity range. It retains the same unit of measure as the health indicator, and conveys an easily understood concept. RATE RATIO (RR): The rate ratio (RR) is a relative inequality measure. We use the ratio of the best and worst performing category as a simple measure of relative inequality. For any given risk factor or outcome, it divides the subgroup with the highest level for that measure by that with the lowest; in other words it reports the relative inequality range. We present present TWO complex measures of inequality for stratifiers with more than two subgroups and which HAVE NO implicit order. We describe our two measures below, using country as an example of a non-ordered inequality stratifier. ABSOLUTE MEAN DIFFERENCE (MD): The absolute mean difference (MD) is a ‘complex’ absolute inequality measure. Using the four ECHORN countries and for a chosen risk factor or outcome, for each country we calculate the difference between that country and the best performing country, we add these differences together, and we divide by the number of countries. MD arrives at a single inequality value whilst considering all countries in the assessment group. INDEX OF DISPARITY (ID): The index of disparity (ID) (4) is a relative disparity measure. It is the absolute mean difference (MD), expressed as a percentage of the reference country (usually the best performing country)."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

#delimit ; 
    putexcel (B49:P49) = 
    "(1) Harper S, Lynch J. Methods for Measuring Cancer Disparities: Using Data Relevant to Healthy People 2010 Cancer-Related Objectives. 2005;NCI Cancer Surveillance Monograph Series, Number 6. NIH Publication No. 05-5777." 
    , font("Calibri", 11) merge vcenter txtwrap italic;
#delimit cr 

#delimit ; 
    putexcel (B50:P50) = 
    "(2) Harper S, Lynch J, Meersman SC, Breen N, Davis WW, Reichman ME. An overview of methods for monitoring social disparities in cancer with an example using trends in lung cancer incidence by area-socioeconomic position and race-ethnicity, 1992-2004. American journal of epidemiology. 2008;167(8):889-99." 
    , font("Calibri", 11) merge vcenter txtwrap italic;
#delimit cr 

#delimit ; 
    putexcel (B51:P51) = 
    "(3) World Health Organization. Handbook on Health inequality monitoring with a special focus on low- and middle-income countries. 2013. Available from: http://www.who.int/social_determinants/action/handbook_inequality_monitoring/en/index.html." 
    , font("Calibri", 11) merge vcenter txtwrap italic;
#delimit cr 

#delimit ; 
    putexcel (B52:P52) = 
    "(4) Pearcy JN, Keppel KG. A summary measure of health disparity. Public Health Reports (Washington, DC: 1974). 2002;117(3):273-80." 
    , font("Calibri", 11) merge vcenter txtwrap italic;
#delimit cr 


** PART THREE. MAPPING
putexcel B53 = "Part 3. CVD Risk Score Mapping", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B54:P54) = 
    "We explore the effect of PLACE on 10-year CVD risk. We use the Framingham risk score, and visualise difference in risk categories (low risk, intermediate risk, high risk) using choropleth maps. Maps are produced for all sampled Enumeration Districts, and for all sampled parishes. When we extend this analysis to the ECS, we will explore country-level differences."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

** PART FOUR: RISK SCORE COMPARISON
putexcel B55 = "Part 4. Comparison of CVD Risk Scores", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B56:P56) = 
    "We use equiplot charts to describe absolute differences between alternative CVD score systems, and between participant charcteristics. The equiplot allows us to visualize the level of CVD risk in each group, and the distance between groups (represented by a horizontal line) shows us the absolute inequality in CVD risk."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

** PART FIVE. WHO RISK SCORE
putexcel B57 = "Part 5. WHO CVD Risk Score", font("Calibri", 12) bold vcenter  
#delimit ; 
    putexcel (B58:P58) = 
    "We present WHO/ISH risk prediction charts for the Americas region B (AMR-B). We have overlaid the survey participants into these risk charts, with circle sizes representing the number off participants falling into a particular risk profile cell. We have also produced stacked bar charts providing the 10-year CVD risk in 5 risk groups (<10%, 10 to <20%, 20 to <30%, 30 to <40%, and 40% and higher). METHODS NOTE: The WHO has recently published updates of its charts for Low and Middle income nations (DOI: DOI:https://doi.org/10.1016/S2214-109X(19)30318-3, Lancet, Sep 2019). When analysing using the ECS data, we will update this analysis to reflect the 1029 WHO update."
    , font("Calibri", 12) merge vcenter txtwrap; 
#delimit cr 

** -------------------------------------------------------------------------------------------------------------------- 
*! Borders
** -------------------------------------------------------------------------------------------------------------------- 
** BACKGROUND 
putexcel (B5:P5), border(top, medium)
putexcel (B5:P5), border(bottom, medium)
putexcel (B5:P5), fpattern(solid, "220 220 220")
putexcel (B5:B12), border(left, medium)
putexcel (P5:P12), border(right, medium) 
putexcel (B12:P12), border(bottom, medium)
** DATA 
putexcel (B14:P14), border(top, medium)
putexcel (B14:P14), border(bottom, medium)
putexcel (B14:P14), fpattern(solid, "220 220 220")
putexcel (B14:B18), border(left, medium)
putexcel (P14:P18), border(right, medium) 
putexcel (B18:P18), border(bottom, medium)
** CVD RISK SCORES
putexcel (B20:P20), border(top, medium)
putexcel (B20:P20), border(bottom, medium)
putexcel (B20:P20), fpattern(solid, "220 220 220")
putexcel (B20:B33), border(left, medium)
putexcel (P20:P33), border(right, medium) 
putexcel (B33:P33), border(bottom, medium)
putexcel (B22:P22), border(top, medium)
putexcel (B22:P22), border(bottom, medium)
putexcel (B28:P28), border(top, medium)
putexcel (B28:P28), border(bottom, medium)
putexcel (B32:P32), border(top, medium)
putexcel (B32:P32), border(bottom, medium)

** ANALYSIS METHODS
putexcel (B35:P35), border(top, medium)
putexcel (B35:P35), border(bottom, medium)
putexcel (B35:P35), fpattern(solid, "220 220 220")
putexcel (B35:B58), border(left, medium)
putexcel (P35:P58), border(right, medium) 
putexcel (B58:P58), border(bottom, medium)

putexcel (B37:P37), border(top, medium)
putexcel (B37:P37), border(bottom, medium)
putexcel (B39:P39), border(top, medium)
putexcel (B39:P39), border(bottom, medium)
putexcel (B53:P53), border(top, medium)
putexcel (B53:P53), border(bottom, medium)
putexcel (B55:P55), border(top, medium)
putexcel (B55:P55), border(bottom, medium)
putexcel (B57:P57), border(top, medium)
putexcel (B57:P57), border(bottom, medium)






