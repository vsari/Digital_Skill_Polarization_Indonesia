*-------------------------------------------------------------------------------*
*	Author		: Virgi Sari													*
*	Email		: vas39@bath.ac.uk												*
*	Program 	: Data preparation to generate geolocation variables			*
*				  Getting information on geolocation							*
*	Data		: World Bank Digital Economy Household Survey 2020				*
*				  Link - https://microdata.worldbank.org/index.php/catalog/4602	*
*	Version		: 1 (30/04/2020)												*
*				  2 (09/04/2024)												*
*-------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000

/* List of variables of interests: 

This do-file generates GEOLOCATION variables to be used as independent variables
for the regressions in Table 4-5.

The geolocation variables are below (referenced in Table 3 main text)

	*Variable names*			*Definitions*
	island						categorical variables denoting geographical areas
								(Sumatera, Java-Bali, Kalimantan, 	Sulawesi, Nusa Tenggara, Maluku)
								
	metro*						Categorical variables denoting characteristics of urban/rural areas
								following World Bank definition, which includes core, non-metro rural,
								non-metro urban, periphery urban, and single district metro 

*/

/*------------------------------------------------------------------------------
	STEP 1 - clean book cover to obtain GEOLOCATION variable
--------------------------------------------------------------------------------*/
*Open file
	use "${raw}BUKU1COV.dta", clear
	
	*Renaming geolocation variables
		//province
		gen prov_id = aiii_1
		gen prov_name = aiii_1_nm
		
		//district
		gen kab_id = aiii_2
		gen kab_name = aiii_2_nm
		
		//subdistrict
		gen kec_id = aiii_3
		gen kec_name = aiii_3_nm
		
		//village
		gen desa_id = aiii_4
		
		
	*keep only relevant variables
		keep wilcah hh* prov* kab* kec* desa* island metro* core* single*
		order wilcah prov* kab* kec* desa* hh*
		sort hh_id
	
	*save file
	save "${coded}dehs_geolocation", replace
	/*note: data is at HH-level; total HH=3,063 obs*/
