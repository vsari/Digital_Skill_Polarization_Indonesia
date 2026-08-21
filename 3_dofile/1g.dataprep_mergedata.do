*-----------------------------------------------------------------------------------*
*	Author		: Virgi Sari														*
*	Email		: vas39@bath.ac.uk													*
*	Program 	: Data prep on digital literacy										*
*				  Merging all dataset, incl relevant covariates						*
*	Data		: World Bank Digital Economy Household Survey 2020					*
*				  Download: https://microdata.worldbank.org/index.php/catalog/4602	*
*-----------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000


/* Note: This do-file generates the combined dataset, containing all variables used in the analysis */



/*------------------------------------------------------------------------------
	STEP 1 - merging all coded data for analysis
--------------------------------------------------------------------------------*/

	use "${coded}dehs_skill", clear
		merge 1:1 ind_id using "${coded}dehs_demography"
		drop if _m!=3
		drop _m
		merge m:1 hh_id using "${coded}dehs_geolocation"
		drop if _m!=3
		drop _m
		merge m:1 wilcah using "${raw}dehs_final_weight.dta"
		drop if _m!=3
		drop _m
		merge 1:1 ind_id using "${coded}internet_usage"
		drop if _m!=3
		drop _m
		merge m:1 hh_id using "${raw}deciles.dta"
		drop if _merge!=3
		drop _merge
		merge m:1 hh_id using "${coded}connecthh.dta"
		drop if _merge!=3
		drop _merge
		merge 1:1 ind_id using "${coded}socialmedia.dta"
		drop _merge
		
	*turning weight into integer form
	gen wgt_itg=round(wgt)
	format wgt_itg %8.0g
	
	*creating quantiles
	xtile quintile=decile_pmt [fw=wgt_itg], nq(5)
	label var quintile "Quintile Generated from PMT Decile"
	
	label data "DEHS SKILLS CLEANED DATA"	
	save "${coded}dehs_skill_cleaned", replace
		

	