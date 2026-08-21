*---------------------------------------------------------------*
*	Author		: Virgi Sari 									*
*				  Anissa Rahmawati								*
*	Email		: vas39@bath.ac.uk								*
*	Program 	: Modelling Determinants of Digital Skills		*
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
NOTE - This programming prepares two main outputs in the paper:

	Outputs in the paper
	--> Table 4 - odd ratios from logit regressions on the determinants of skill status
	--> Table 5 - results from multinominal logit for determinants of digital skill proficiency
	
	Annexes:
	--> Table A1 - logit coefficients from the logit models on the determinants of digital skill status

	
Two models:
1. Logit regression - determinants of DIGITAL SKILL STATUS (in section STEP 2)
- Outcome variables: digital skill status (1=have digital skill); six vdummy ariables representing 6 components of digital skills
- Control variables: set of variables covering individual characteristics & softskills, demographics, and geographical variations.

2. Multinominalogit (mlogit) regression - determinants of digital skill PROFIECIENCY (level of skills) (in section STEP 3)
- Outcome variables: digital skill proficiency (low, middle, high); six categorical variables representing 6 components of digital skills)
- Control variables: set of variables covering individual characteristics & softskills, demographics, and geographical variations.
--------------------------------------------------------------------------------*/


********************************************************************************	
* STEP 1 - Prepare the dataset
********************************************************************************	
*Open dataset
	
use "${coded}dehs_skill_cleaned.dta",clear

*Preparing some indicators: dummy variables
//note: always set reference group as the lowest group in the indicators. for region, set java bali as base groupƒ

	*Keep relevant sample size: ICT and internet users only*
	//note: the analysis focus on digital skills of >15yo ICT and internet users only ∂
	keep if ictuse==1
	
	*Modify String Variable to categorical variables for analysis
			gen island_region=1 if island =="Sumatera"
				replace island_region=2 if island=="Java-Bali"
				replace island_region=3 if island=="Kalimantan"
				replace island_region=4 if island=="Sulawesi"
				replace island_region=5 if island=="Nusa Tenggara"
				replace island_region=6 if island=="Maluku"
				replace island_region=7 if island=="Papua"
				
			label var island_region "Island"
			la def island 1 "Sumatera" 2 "Java-Bali" 3 "Kalimantan" 4 "Sulawesi" 5 "Nusa Tenggara" 6 "Maluku" 7 "Papua"
			la val island_region island		

			
			gen urban_classification=1 if coreperiphery_new=="Core"
				replace urban_classification=2 if coreperiphery_new=="Non-metro Rural"
				replace urban_classification=3 if coreperiphery_new=="Non-metro Urban"
				replace urban_classification=4 if coreperiphery_new=="Periphery Rural"
				replace urban_classification=5 if coreperiphery_new=="Periphery Urban"
				replace urban_classification=6 if coreperiphery_new=="Single District Metro"
				
			label var urban_classification "Urban Region Classification"
			la def urbanc 1 "Core" 2 "Non-metro Rural" 3 "Non-metro Urban" 4 "Periphery Rural" 5 "Periphery Urban" 6 "Single District Metro" 
			la val urban_classification urbanc		

		
		recode agex (15/24=1 "15 - 24 y.o") (25/34 = 2 " 25 - 34 y.o") (35/44=3 "35 - 44 y.o") ///
		(45/54=4 "45 - 54 y.o") (55/64=5 "55 - 64 y.o") (65/100=6 "> 65 y.o"), gen(agegroup)
				la var agegroup "age group"
				
* Create household indicators
		*number of household that is ICT Users
		bysort hh_id: egen hhconnected=sum(ictuse)
		tab hhconnected, m
		label var hhconnected "Number of HH member who uses internet & ICT device"

	save "${coded}dehs_reg.dta", replace
	
	
*Preparing main outcome of variables
	//the main outcome variables are a series of dummy variables with a score of..
	//1=respondents have the digital skill and 0 otherwise (as described in Table 3)
	foreach skilltype in "ictdev" "info" "comm" "content" "security" "problem" {
		gen dum_`skilltype' = (skill_`skilltype'!=0)
	}
	
	tab dum_ictdev $w, m
	tab dum_info $w, m
	tab dum_comm $w, m
	tab dum_content $w, m
	tab dum_security $w, m
	tab dum_problem $w, m
	
*Store variables to global

	//weight
	*global w [aw=wgt]
	global w [iw=wgt_itg]

	//Main outcome
	global skill dum_ictdev dum_info dum_comm dum_content dum_security dum_problem

	//Regressors 
	
	*Connectivity
	gen own_computer = (own_laptop==1) | (own_pc==1) | (own_tablet==1)
		la var own_computer "1=own either laptop/PC/tablet"
		
	replace hasfixedline=0 if hasfixedline==.
	clonevar fixedline = hasfixedline

	global connect own_computer own_smartphone 									///
						ictdevice_ratio ln_phonecr_rp ms_download
						
	*Softskills
	global softskills intra_selfdirect intra_creative intra_critical 			///
						intra_growthmind inter_comm inter_collab 				///
						inter_leadership inter_problem
						
	*Demographic
	global demographic male b6.agegroup working educ_year i.quintile 

	*Geography
	global geo b7.island_region b4.urban_classification
		
		
//Save data
	save "${coded}dehs_reg.dta", replace

********************************************************************************	
** Step 2 - Determinants of individual digital skill	- LOGIT MODEL **
** Reference: Logit model (equation 1 & 2 in method section 3)
********************************************************************************

*Use data for running regressions
 use "${coded}dehs_reg.dta", clear
	
	* Running LOGIT model with clustered standard erros at district-level
	** Reference: Equation (1) in the methodology (section 3)
	 
	 //Outcome variable: ICT operation
	eststo mdum_ictdev: logit dum_ictdev $connect $softskills $demographic $geo $w, 	///
		vce(cluster kab_id)
	
	outreg2 using "${estimate}/logit_skillstatus.xls", replace
	
	//Loops to run logit for outcome variable of other digital skills
	foreach skill of varlist dum_info dum_comm dum_content dum_security dum_problem {
		eststo m`skill': logit `skill' $connect $softskills $demographic $geo $w, 		///
			vce(cluster kab_id)
		outreg2 using "${estimate}/logit_skillstatus.xls", append
	}
	

	* Generating table containing COEFFICIENTS from logit model (Annex, Table A2)
		eststo coef_ictdev: logit dum_ictdev $connect $softskills $demographic $geo $w, vce(			cluster kab_id)
			outreg2 using "${estimate}/logitcoef_skillstatus.xls", replace
			
		foreach skill of varlist dum_info dum_comm dum_content dum_security dum_problem {
			eststo coef`skill': logit `skill' $connect $softskills $demographic $geo $w, vce(			cluster kab_id)
			outreg2 using "${estimate}/logitcoef_skillstatus.xls", append
		}

	
	* Generating ODDS RATIO for the logit model (Ref: Equation 2 in method section - section 3)
	** NOTE: This section generates results on Table 4
		eststo ods_ictdev: logit dum_ictdev $connect $softskills $demographic $geo $w, or vce(			cluster kab_id)
			outreg2 using "${estimate}/logitods_skillstatus.xls", eform excel replace
			
		foreach skill of varlist dum_info dum_comm dum_content dum_security dum_problem {
			eststo ods_`skill': logit `skill' $connect $softskills $demographic $geo $w, or vce(cluster kab_id)
			outreg2 using "${estimate}/logitods_skillstatus.xls", eform excel append
			
		}

********************************************************************************
* Step 3 - MULTINOMINAL LOGIT (determinnts of skill PROFICIENCY)
* Reference: Multinominal logit model
* Outcome variables: a set of categorical variables denoting three level of digital skills
* The model is run for each of six components/type of digital skills
********************************************************************************

*Open file
use "${coded}dehs_reg.dta", clear


*run gl to store variables (see earlier codes)
	//weight
	*global w [aw=wgt]
	global w [iw=wgt_itg]

	//Main outcome
	global skill dum_ictdev dum_info dum_comm dum_content dum_security dum_problem

	//Regressors 
	
	*Connectivity
	global connect own_computer own_smartphone 									///
						ictdevice_ratio ln_phonecr_rp ms_download
						
	*Softskills
	global softskills intra_selfdirect intra_creative intra_critical 			///
						intra_growthmind inter_comm inter_collab 				///
						inter_leadership inter_problem
						
	*Demographic
	global demographic male /*b6.agegroup*/ working educ_year i.quintile 

	*Geography
	global geo b7.island_region b4.urban_classification
	
	gl mnlspec $connect $softskills male working educ_year i.quintile b7.island_region
	
	
//Run MNL regressions - results presented in Table 5
		
	//run multinominal logit for skill 01
		set emptycells drop
		mlogit skill_ictdev $mnlspec $w, b(0) vce(cluster kab_id)
		outreg2 using "${estimate}/mlogit_lvlskill.xls", replace eform excel
		
	foreach skill in "info" "comm" "content" "security" "problem" {
		
		//run multinominal logit for other components of digital skills
		set emptycells drop
		mlogit skill_`skill' $mnlspec $w, b(0) vce(cluster kab_id)
		outreg2 using "${estimate}/mlogit_lvlskill.xls", append eform excel
		
	}


* END *


