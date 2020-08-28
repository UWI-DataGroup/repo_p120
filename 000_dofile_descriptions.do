*********************************************************************************************************************
*	P-ECHORN DO FILE GUIDE
*********************************************************************************************************************
*********************************************************************************************************************
*	HOTN EXAMPLE ANALYSES
*********************************************************************************************************************
*	1. 001_background_(risk score)
*      * Previously coded CVD risk score do files
*
*   2. hotn_ecs_cvdrisk_[NAME OF RISK SCORE]
*		* Ensures that HOTN and risk calculator variable names are matched.
*		* Calculates 10 year risk
*				- Output datasets: framingham_cvdrisk.dta; who_cvdrisk_sample.dta; ascvd_cvdrisk; ascvd_cvdrisk_reduced 
*
*	3. hotn_example_001
*		* Merges the HotN dataset with the 3 risk scores to create one dataset for analysis
*		* Prepares risk factor and disease variables
*
*	4. hotn_example_[002-007]
*		* creates analysis output in an excel sheet (20191124_cvdrisk_example_Barbados_ForYale). Each do-file 
*		  corresponds to one tab of the workbook, with 002 corresponding to tab 1, 003 to tab 2, and so on.
*	
*	5. hotn_example_methods
*		* inserts text describing the methods used to an excel sheet 
*
*********************************************************************************************************************


*********************************************************************************************************************
*	ECHORN WAVE 1 ANALYSES
*********************************************************************************************************************
*	_____________________________________
*		Do-files are numbered as: 
*				001: Background and weight preparation
*				002: data prep 
*				003: data analysis
*	______________________________________

*	001_prep_ecs_weights
*		Creates post-stratification survey weights based on UN WPP, US Census Bureau, and 	
*		local censuses for a variety of years between 2010 and 2015
*				- Output dataset: ECHORN_weights.dta
*
*	002_ecs_prep_DM
*		Brings in dataset created by Yale and prepares it for analysis by:
*		- Recoding all not applicable responses to .z (originally coded as 999)
*		- Merging with survey weights created by ecs_weights 
*				- Output dataset: survey_wave1_weighted.dta
*
*	003a_ecs_progress_rf
*		* Provides a description of PROGRESS stratifiers and self-reported risk factors
*	
*	003b&c_ecs_cvdrisk_[NAME OF RISK SCORE]
*		* Ensures that ECHORN and risk calculator variable names are matched.
*		* Calculates 10 year risk 
*				- Output datasets: wave1_framingham_cvdrisk; wave1_ascvd_cvdrisk
*
*	003d_ecs_analysis_wave1
*		* Prepares risk factor and disease variables
*		* Merges with risk score datasets
*				- Output dataset: wave1_cvdrisk_prepared
*
*	003e_ecs_analysis_wave1
*		Describes CVD risk using the Framingham risk score, overall and stratified by: country; age group, gender, 
*		education level; occupational skill level; obesity; and behavioural risk factors (heavy episodic drinking; 
*		physical inactivity)
*
*   003f_ecs_cvdrisk_framingham
*       Examines association between social determinants, health behaviours and CVD risk
*********************************************************************************************************************


