cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	30/06/2021
	**	Date Modified:  21/07/2021
	**  Algorithm Task: Preparation for Spatial Mapping by Country.

    ** General algorithm set-up
    version 13
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
local phdpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p145"
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
keep if key!=""

preserve
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(TRACTCE10)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood", replace
restore

*No diabetes

preserve
keep if dm==0
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(TRACTCE10)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood_No_DM", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood_No_DM", replace
restore

*Diabetes

preserve
keep if dm==1
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(TRACTCE10)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}


*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood_DM", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/PR_metabolomics_neighborhood_DM", replace
restore

*-------------------------------------------------------------------------------

*USVI
import excel "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_Spatial_Join.xlsx", clear firstrow
keep if key_!=""
gen estateid_1 = OBJECTID_1


*All
preserve
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(estateid)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood", replace
*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood", replace
restore

*No Diabetes
preserve
keep if dm==0
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(estateid)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood_No_DM", replace
*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood_No_DM", replace
restore

*Diabetes
preserve
keep if dm==1
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(estateid)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood_DM", replace
*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/USVI_metabolomics_neighborhood_DM", replace
restore

*-------------------------------------------------------------------------------
*Barbados
import excel "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_Spatial_Join.xlsx", clear firstrow
sort ED
destring ED, replace
merge m:1 ED using "`phdpath'/version01/2-working/Walkability/walkability_paper_001.dta"
keep if CT!=""
replace Join_Count = 1
gen parishid = parish

*All
preserve
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(parishid parish)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood", replace
restore

*No diabetes
preserve
keep if dm==0
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(parishid parish)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood_No_DM", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood_No_DM", replace
restore

*Diabetes
preserve
keep if dm==1
collapse (mean) ethanolamine - aminoadipic_acid (sum) Join_Count, by(parishid parish)
*Removes "(mean)" after running collapse
foreach var of varlist _all {
    local variable_label : variable label `var'
    local variable_label : subinstr local variable_label "(mean) " ""
    label variable `var' "`variable_label'"
}

*Re-Labels variable label using proper format
foreach var of varlist _all {	
	local variable_label : variable label `var'
	local variable_label = subinstr(proper("`variable_label '"),"'S", "'s", .)
	label variable `var' "`variable_label'"
}
label var glutamic_acid "Glutamic Acid"
label var gamma_amino_n_butyric_acid "Gamma-Amino-n-Butyric Acid"
label var beta_aminoisobutyric_acid "Beta-Aminoisobutyric Acid"
label var alpha_amino_n_butyric_acid "Alpha-Amino-n-Butyric Acid"
label var isoleucine_alloleucine "Isoleucine Alloleucine"
label var aspartic_acid "Aspartic Acid"
label var beta_alanine "Beta-Alanine"
label var x_4_hydroxyproline "X-4 Hydroxyproline"
label var aminoadipic_acid "Aminoadipic Acid"

*Save dataset
save "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood_DM", replace

*Export dataset to encrypted location
export delimited using "`datapath'/version03/01-input/GIS Files/Spatial Join/BB_metabolomics_neighborhood_DM", replace
restore

*-------------------------------------------------------------------------------
