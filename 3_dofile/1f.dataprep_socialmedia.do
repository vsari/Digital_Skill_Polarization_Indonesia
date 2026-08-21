*---------------------------------------------------------------*
*	Author		: Anissa Rahmawati								*
*	Email		: anissarahmasukardi@gmail.com					*
*	Program 	: Data prep on digital literacy					*
*				  Extracting Social Media Usage Indicators		*
*	Data		: World Bank Digital Economy Household Survey 2020						*
*				  Download: https://microdata.worldbank.org/index.php/catalog/4602		*
*---------------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000

/*------------------------------------------------------------------------------
							SOCIAL MEDIA INDICATORS
------------------------------------------------------------------------------*/

use "${raw}BUKU2_BIV1.dta", replace

keep cspro_id ea_b2 buku2_id b2_cov1_id biv_222_type biv_223 biv_224

*reshaping data
	reshape wide biv_223 biv_224, i(cspro_id ea_b2 buku2_id b2_cov1_id) j(biv_222_type) string
	unique cspro_id ea_b2 buku2_id b2_cov1_id /// id is unique for each observation
	
*Create ID	
rename ea_b2 wilcah //to make it consistent with other books
		
		gen hh_id = buku2_id //hhid
		
		tostring b2_cov1_id, replace //convert no ART using 
		
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
			la var ind_id "individual ID"
		
		sort wilcah hh_id ind_id
	
*create social media use
	gen usesocialmedia=1 if (biv_223A==1 | biv_223A==2) | (biv_223B==1 |biv_223B==2) | (biv_223C==1|biv_223C==2) | (biv_223D==1|biv_223D==2) | (biv_223E==1|biv_223E==2)
		replace usesocialmedia=0 if usesocialmedia==. & usesocialmedia!=1
		
		tab usesocialmedia
		
*total hours spent in social media of all platform
	egen hour_socmed=rowtotal(biv_224A biv_224B biv_224C biv_224D biv_224E)
		replace hour_socmed=0 if hour_socmed==. | hour_socmed<0
		
*checking consistency 
	sum hour_socmed if usesocialmedia==0
		
	keep wilcah hh_id ind_id usesocialmedia hour_socmed
	sort wilcah hh_id ind_id
	
	save "${coded}socialmedia.dta", replace


