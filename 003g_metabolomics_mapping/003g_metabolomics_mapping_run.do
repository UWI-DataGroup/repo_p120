
cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping_run.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	19/07/2021
	**	Date Modified:  22/07/2021
	**  Algorithm Task: Run do file Mapping Batch

    ** General algorithm set-up
    version 13
    clear all
    macro drop _all
    set more 1
    set linesize 80
	
	
/*
NOTE THE FOLLOWING:

This algorthim should be run 1st before any of the linked do files.

Do-File Descritpion

metabolomics_mapping
	003g:  Batch Do file run
	003ga: Preparation for Spatial Mapping by Country
	003gb: Puerto Rico Metabolomics Mapping by Census Tracts
	003gc: Barbados Metabolomics Mapping by Parish
	003gd: USVI Metabolomics Mapping by Census Estates
	003ge: Combining Country Mapping
	003gf: Combining Diabetes Status Mapping
	
	**Algorithms with the ending _c replaces diabetes status for country name for map titles
	**Algorithms with the ending _t renames the map to the Amino Acid name. These will not be used for graph combining
	
These do files should create Amino Acid cholropleth maps by diabetes status for the ECHORN Adult Cohort
	*Trinidad not included due to lack of Amino Acid data
	
If not installed run the following command (needed for mapping within STATA):
	ssc install shp2dta, replace
*/

*Setting working directory (Choose the appropriate one for your system)

** DATASETS to encrypted SharePoint folder
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

** LOGFILES to unencrypted OneDrive folder
local logpath "/Volumes/Secomba/kernrocke/Boxcryptor/OneDrive - The UWI - Cave Hill Campus/Github Repositories/repo_p120/003g_metabolomics_mapping"

** Close any open log file and open a new log file
capture log close
log using "`logpath'/metabolomics_mapping_run", replace


** HEADER -----------------------------------------------------

**Data Preparation
do "`logpath'/003ga_metabolimics_mapping"
*Puerto Rico Mapping
do "`logpath'/003gb_metabolimics_mapping_c"
*Barbados Mapping
do "`logpath'/003gc_metabolimics_mapping_c"
*USVI Mapping 
do "`logpath'/003gd_metabolimics_mapping_c"
**Combining Countries
do "`logpath'/003ge_metabolimics_mapping"


graph close _all
clear all
*Puerto Rico Mapping
do "`logpath'/003gb_metabolimics_mapping"
*Barbados Mapping
do "`logpath'/003gc_metabolimics_mapping"
*USVI Mapping 
do "`logpath'/003gd_metabolimics_mapping"
**Combining Diabetes Status
do "`logpath'/003gf_metabolimics_mapping"


graph close _all
clear all
*Puerto Rico Mapping
do "`logpath'/003gb_metabolimics_mapping_t"
*Barbados Mapping
do "`logpath'/003gc_metabolimics_mapping_t"
*USVI Mapping 
do "`logpath'/003gd_metabolimics_mapping_t"

*----------------------------------END------------------------------------------
