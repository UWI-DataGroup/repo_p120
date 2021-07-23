cls
** HEADER -----------------------------------------------------
	**  DO-FILE METADATA
	**  Program:		metabolomics_mapping.do
	**  Project:      	Pediatric ECHORN (P-ECS)
	**	Sub-Project:	Metabolomics Mapping
	**  Analyst:		Kern Rocke
	**	Date Created:	19/07/2021
	**	Date Modified:  21/07/2021
	**  Algorithm Task: Combining country maps

    ** General algorithm set-up
    version 13
    set more 1
    set linesize 80


*Setting working directory (Choose the appropriate one for your system)

local datapath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/01-input/GIS Files"
local outputpath "/Volumes/Secomba/kernrocke/Boxcryptor/The University of the West Indies/DataGroup - data_p120/version03/03-output/Metabolomics"

*All
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	
	
#delimit ;
	grc1leg `x'_all_P `x'_all_B, 
			name(combine1, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))	
			ring(0) pos(7)
	
		;
#delimit cr

#delimit ;
	grc1leg combine1 `x'_all_U, 
			col(1) name(`x'_com_, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(7)
			title(`: variable label `x'', color(black) size(3.5))
	
		;
#delimit cr
	
	graph export "`outputpath'/Combine/Country/`x'_all.png.", replace width(4000) as(png)
}

*No Diabetes
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
		
	
#delimit ;
	grc1leg `x'_No_P `x'_No_B, 
			name(combine1, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(7)
	
	;
#delimit cr

#delimit ;
	grc1leg combine1 `x'_No_U, 
			col(1) name(`x'_com_, replace)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ring(0) pos(7)
			title(`: variable label `x'', color(black) size(3.5))
	
		;
#delimit cr
	
	graph export "`outputpath'/Combine/Country/`x'_No_DM.png.", replace width(4000) as(png)
}

*Diabetes
foreach x in ethanolamine glutamic_acid glutamine gamma_amino_n_butyric_acid beta_aminoisobutyric_acid alpha_amino_n_butyric_acid valine isoleucine_alloleucine leucine aspartic_acid histidine sacrosine beta_alanine alanine glycine taurine tryptophan arginine tyrosine citrulline phenylalanine hydroxylysine proline x_4_hydroxyproline serine asparagine threonine methionine aminoadipic_acid {
	
	
#delimit ;
	grc1leg `x'_DM_P `x'_DM_B, 
	
				name(combine1, replace)
				plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
				graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			
			;
#delimit cr
				
#delimit ;			
	grc1leg combine1 `x'_DM_U, 
				
				col(1) name(`x'_com_, replace)
				plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
				graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
				ring(0) pos(7)
				title(`: variable label `x'', color(black) size(3.5))
			
			;
#delimit cr
	
	graph export "`outputpath'/Combine/Country/`x'_DM.png.", replace width(4000) as(png)
}

*-------------------------------------------------------------------------------
