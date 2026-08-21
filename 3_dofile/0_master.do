*------------------------------------------------------------------------------*
*	Author		: Virgi Agita Sari 												*
*				  Anissa Rahmawati Sukardi										*
*	Email		: vas39@bath.ac.uk												*
*				  anissarahmasukardi@gmail.com									*
*	Program 	: The Promise and Peril of Digital Technology:					*
*				  Evidence from Digital Skill Polarization in Indonesia			*
*	Data		: Digital Economy Household Survey, Indonesia					*
*				  World Bank 2020												*
*				  Download at https://doi.org/10.48529/3vrg-x206				*
*-------------------------------------------------------------------------------*

clear
cap log close
clear matrix
set more off
set matsize 11000

*User setup

/*Virgi*/
global main "/Users/vsari/Library/CloudStorage/OneDrive-Personal/Research/Publication/RR_Digital skills and connectivity/backgroundpaper02_digital literacy/Replication/"


/*Anissa
global main "/Users/anissasukardi/Library/CloudStorage/OneDrive-Personal/backgroundpaper02_digital literacy/Replication/"
*/


/* Others
global main "paste link to folder path where you store the replication folder in your device here"
*/


*Set-up working folder
global raw 		 	"${main}1_rawdata/DEHS 2020 Final Diseminated Data/Data/"
global coded 	 	"${main}2_codeddata/"
global do 		 	"${main}3_dofile/"
global output   	"${main}4_output/"
global table 		"${output}Table"
global estimate     "${output}Regression"
global figure		"${output}Figure"
global check		"${output}Robustness"


*installing ado
local commands = "confirmdir mdesc gsample gtools mmerge outreg2 tabout binscatter unique tab2xl estout coefplot fitstat boxtid oparallel gologit"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc!=0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

net install http://www.stata.com/users/kcrow/tab2xl, replace
net install st0491, from("http://www.stata-journal.com/software/sj17-3")
net get st0491, from("http://www.stata-journal.com/software/sj17-3")
net from https://spost.su.domains/
net install spost13_ado, replace

*If needed, install the directories, and sub-directories used in the process 
foreach i in "$raw" "$coded" "$do" "$output" "$table" "$estimate" "$figure" "$check" {
	confirmdir "`i'" 
	if _rc!=0 {
		mkdir "`i'" 
	}
	else {
		qui display "No action needed"		
	}
}

/*------------------------------------------------------------------------------
	STEP 1 - Data preparation
--------------------------------------------------------------------------------*/

	do "${do}1a.dataprep_skills.do"
	*does: merging all books in digital skills modul and clean the data
	*data input: ${raw}BUKU2_BVII ~ ${raw}BUKU2_XIII
	*data output: ${coded}dehs_skills
	
	do "${do}1b.dataprep_geolocation.do"
	*does: retrieving geolocation information
	*data input: ${raw}BUKU1COV.dta
	*data output: ${coded}dehs_geolocation
	
	do "${do}1c.dataprep_demography.do"
	*does: clean and retrieving data on HH demography
	*data input: ${raw}BUKU1_AV
	*data output: ${coded}dehs_demography
	
	do "${do}1d.dataprep_usage.do"
	*does: clean, merging internet usage indicators from book2_II1, book2_III, book2_V
	*data input:  "${raw}BUKU2_BII1",  "${raw}BUKU2_BIII",  "${raw}BUKU2_V"
	*data output: "${coded}internet_usage"
	
	do "${do}1e.dataprep_hhindicator.do"
	*does: clean, merging household dependency ratio and internet connection indicators from book1
	*data input:  ${raw}BUKU1_AV" and "${raw}BUKU1_AVIII.dta"
	*data output: "${coded}connecthh.dta"
	
	do "${do}1f.dataprep_socialmedia.do"
	*does: clean social media indicators from book II
	*data input: "${raw}\BUKU2_BIV1.dta"
	*data output: "${coded}socialmedia.dta"

	do "${do}1g.dataprep_mergedata.do"
	*does: merging all books in digital skills modul
	*data input: ${coded}dehs_skill; ${coded}dehs_geolocation; ${coded}dehs_demography "${coded}internet_usage"
	*data output: ${coded}dehs_skill_cleaned.dta
	

/*------------------------------------------------------------------------------
	STEP 2 - Descriptives analysis
--------------------------------------------------------------------------------*/

	do "${do}2.digital skills descriptive.do"
	*does: produce tables of descriptive statistics
	*data input:dehs_skill_cleaned
	*data output: various excel files in the folder $table
	
/*------------------------------------------------------------------------------
	STEP 3 - Regression analysis
--------------------------------------------------------------------------------*/

	do "${do}3.Regression analysis.do"
	*does: produce the main analysis in the paper (determinants of digital skill and proficiency
	*data input:${coded}dehs_reg.dta
	*data output: various excel files in the folder $estimate

/*------------------------------------------------------------------------------
	STEP 4 - Robustness check
--------------------------------------------------------------------------------*/

	do "${do}4.Robustness check.do"
	*does: run a series of robustness check to ensure reliability of the models in step 3
	*data input:${coded}dehs_reg.dta
	*data output: various excel files in the folder $check
