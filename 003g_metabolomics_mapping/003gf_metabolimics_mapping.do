cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	19/07/2021
	**	Date Modified:  21/07/2021
	**  Algorithm Task: Combining Diabetes Status maps

    ** General algorithm set-up
    version 13
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)

local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/01-input/GIS Files"
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/03-output/Metabolomics"

*Puerto Rico
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	
	
#delimit ;
	grc1leg `x'_No_P `x'_DM_P, 
			name(combine1, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))			
	
		;
#delimit cr

#delimit ;
	grc1leg  `x'_all_P combine1, 
			row(2) name(`x'_com_, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(7)
			title(`: variable label `x'' "San Juan, Puerto Rico", color(black) size(3.5))
	
		;
#delimit cr
	
	graph export "`outputpath'/Combine/Diabetes/PR/`x'_PR.png.", replace width(4000) as(png)
}


*Barbados
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	
	
#delimit ;
	grc1leg `x'_No_B `x'_DM_B, 
			name(combine1, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))			
	
		;
#delimit cr

#delimit ;
	grc1leg  `x'_all_B combine1, 
			row(2) name(`x'_com_, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(2)
			title(`: variable label `x'' "Barbados", color(black) size(3.5))
	
		;
#delimit cr
	
	graph export "`outputpath'/Combine/Diabetes/BB/`x'_BB.png.", replace width(4000) as(png)
}


*USVI
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	
	
#delimit ;
	grc1leg `x'_No_U `x'_DM_U, 
			name(combine1, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))			
	
		;
#delimit cr

#delimit ;
	grc1leg  `x'_all_U combine1, 
			row(2) name(`x'_com_, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(2)
			title(`: variable label `x'' "USVI", color(black) size(3.5))
	
		;
#delimit cr
	
	graph export "`outputpath'/Combine/Diabetes/USVI/`x'_USVI.png.", replace width(4000) as(png)
}
