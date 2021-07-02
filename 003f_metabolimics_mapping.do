cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	30/06/2021
	**	Date Modified:  02/07/2021
	**  Algorithm Task: Preparation for Spatial Mapping by Country.

    ** General algorithm set-up
    version 13
    clear all
    macro drop _all
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)

*-------------------------------------------------------------------------------
** Dataset to encrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local datapath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

** Logfiles to unencrypted location

*WINDOWS OS - Ian & Christina (Data Group)
*local logpath "X:/The University of the West Indies/DataGroup - repo_data/data_p120"

*WINDOWS OS - Kern & Stephanie
*local logpath "X:/The UWI - Cave Hill Campus/DataGroup - repo_data/data_p120"

*MAC OS - Kern
local logpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"

*-------------------------------------------------------------------------------

**Aggregated output path

*WINDOWS OS - Ian & Christina (Data Group) 
*local outputpath "The University of the West Indies/DataGroup - PROJECT_p120"

*WINDOWS OS - Kern & Stephanie
*local outputpath "X:/The UWI - Cave Hill Campus/DataGroup - PROJECT_p120"

*MAC OS - Kern
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120"	
	
*-------------------------------------------------------------------------------

**Do file path

local dopath "/Volumes/Secomba/kernrocke/Boxcryptor/OneDrive - The UWI - Cave Hill Campus/Github Repositories/repo_p120"

*Open log file to store results
*log using "`logpath'/version03/3-output/metabolimics_mapping.log",  replace

*-------------------------------------------------------------------------------

*Load in data from encrypted location
import delimited "`datapath'/version01/1-input/echorn_dataset_062821_SunandWang.csv", clear 
	
*-------------------------------------------------------------------------------

*Data cleaning

*Remove NA from

foreach x in bp_systolic bp_diastolic bmi hip_circum_mean waist_circum_mean weight predsugnc predssb ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
replace `x' = "" if `x'== "NA"
destring `x', replace
}

rename record_id key

*Export dataset to encrypted location 
export delimited using "`datapath'/version03/02-working/echorn_metabolmics_mapping.csv", replace

*-------------------------------------------------------------------------------

**Import Spatial joined datasets and reduce file to mean within each neighborhood

*Puerto Rico
import excel "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_Spatial_Join.xlsx", clear firstrow

collapse (mean) ethanolamine - aminoadipic_acid, by(TRACTCE10)

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood"

*-------------------------------------------------------------------------------

*USVI
import excel "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_Spatial_Join.xlsx", clear firstrow

collapse (mean) ethanolamine - aminoadipic_acid, by(ESTATEFP)

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood"

*-------------------------------------------------------------------------------
*Barbados
import excel "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_Spatial_Join.xlsx", clear firstrow

collapse (mean) ethanolamine - aminoadipic_acid, by(ED)

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood"

*-------------------------------------------------------------------------------
