
cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping_BB.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	19/07/2021
	**	Date Modified:  21/07/2021
	**  Algorithm Task: USVI Metabolomics Mapping

    ** General algorithm set-up
    version 13
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)


clear
cls

local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/01-input/GIS Files"
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/03-output/Metabolomics"

*Create Shapefile Datasets (Data and Coordinates)
shp2dta using "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted.shp", database("`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_data.dta") coordinates("`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta") genid(id) replace

*Open shapefile coordinates datasets
use  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta", clear
save "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta", replace

*Open shapefile datasets
use  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_data.dta", clear
drop estateid Join_Count
rename OBJECTID_1 estateid_1
*Merge in data
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_neighborhood.dta"

format ethanolamine - aminoadipic_acid %9.2f


save "`datapath'/Spatial Join/USVI_metabolomics_all_.dta", replace

*Create Labels dataset
import delimited "`datapath'/Neighborhoods/USVI_Estates_label.csv", clear
rename objectid_1 estateid_1
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_all_.dta", nogenerate
keep estateid_1 xcoord ycoord Join_Count
save "`datapath'/Spatial Join/USVI_metabolomics_all_label.dta", replace

use "`datapath'/Spatial Join/USVI_metabolomics_all_.dta", clear

foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	

#delimit ;
grmap `x' using  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta", 

			id(id) 
			clmethod(quantile)
			clnumber(5)
			fcolor(YlOrRd) legorder(lohi) 
			legtitle("{bf:Legend}" " ") legstyle(2) 
			ocolor(black) osize(vthin)
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			legend(on) legend(size(2))
			
			legend(region(lcolor(black)))	
			title(`: variable label `x'' "All" "US Virgin Islands", color(black) size(3.5))
			
			label(data("`datapath'/Spatial Join/USVI_metabolomics_all_label.dta")  xcoord(xcoord)  ycoord(ycoord) label(Join_Count) size(small) color(gs4))

						
			ndf(gs12)
			ndo(gs3)
			nds(0.2)
			
			name(`x'_all_U, replace)
			;
#delimit cr

graph export "`outputpath'/USVI/`x'_all.png.", replace width(4000) as(png)

}
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Open shapefile datasets
use  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_data.dta", clear
drop estateid Join_Count
rename OBJECTID_1 estateid_1
*Merge in data
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_neighborhood_No_DM.dta"

format ethanolamine - aminoadipic_acid %9.2f


save "`datapath'/Spatial Join/USVI_metabolomics_No_DM_.dta", replace

*Create Labels dataset
import delimited "`datapath'/Neighborhoods/USVI_Estates_label.csv", clear
rename objectid_1 estateid_1
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_No_DM_.dta", nogenerate
keep estateid_1 xcoord ycoord Join_Count
save "`datapath'/Spatial Join/USVI_metabolomics_No_DM_label.dta", replace

use "`datapath'/Spatial Join/USVI_metabolomics_No_DM_.dta", clear

foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {


#delimit ;
grmap `x' using  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta", 

			id(id) 
			clmethod(quantile)
			clnumber(5)
			fcolor(YlOrRd) legorder(lohi) 
			legtitle("{bf:Legend}" " ") legstyle(2) 
			ocolor(black) osize(vthin)
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			legend(on) legend(size(2))
			
			legend(region(lcolor(black)))	
			title(`: variable label `x'' "No Diabetes" "US Virgin Islands", color(black) size(3.5))
			
			label(data("`datapath'/Spatial Join/USVI_metabolomics_No_DM_label.dta")  xcoord(xcoord)  ycoord(ycoord) label(Join_Count) size(small) color(gs4))

						
			ndf(gs12)
			ndo(gs3)
			nds(0.2)
			
			name(`x'_No_U, replace)
			;
#delimit cr

graph export "`outputpath'/USVI/`x'_No_DM.png.", replace width(4000) as(png)

}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Open shapefile datasets
use  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_data.dta", clear
drop estateid Join_Count
rename OBJECTID_1 estateid_1
*Merge in data
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_neighborhood_DM.dta"

format ethanolamine - aminoadipic_acid %9.2f


save "`datapath'/Spatial Join/USVI_metabolomics_DM_.dta", replace

*Create Labels dataset
import delimited "`datapath'/Neighborhoods/USVI_Estates_label.csv", clear
rename objectid_1 estateid_1
merge 1:1 estateid_1 using "`datapath'/Spatial Join/USVI_metabolomics_DM_.dta", nogenerate
keep estateid_1 xcoord ycoord Join_Count
save "`datapath'/Spatial Join/USVI_metabolomics_DM_label.dta", replace

use "`datapath'/Spatial Join/USVI_metabolomics_DM_.dta", clear

foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	

#delimit ;
grmap `x' using  "`datapath'/Neighborhoods/USVI_Estates/USVI_Estates_adjusted_coordinates.dta", 

			id(id) 
			clmethod(quantile)
			clnumber(5)
			fcolor(YlOrRd) legorder(lohi) 
			legtitle("{bf:Legend}" " ") legstyle(2) 
			ocolor(black) osize(vthin)
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			legend(on) legend(size(2))
			
			legend(region(lcolor(black)))	
			title(`: variable label `x'' "Diabetes" "US Virgin Islands", color(black) size(3.5))
			
			label(data("`datapath'/Spatial Join/USVI_metabolomics_DM_label.dta")  xcoord(xcoord)  ycoord(ycoord) label(Join_Count) size(small) color(gs4))

						
			ndf(gs12)
			ndo(gs3)
			nds(0.2)
			
			name(`x'_DM_U, replace)
			;
#delimit cr

graph export "`outputpath'/USVI/`x'_DM.png.", replace width(4000) as(png)

}
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
