*---------------------------------------------------------------*
*	Author		: Anissa Rahmawati								*
*	Email		: anissarahmasukardi@gmail.com					*
*	Program 	: Data prep on digital literacy					*
*				  Extracting Household Indicator:
*				  1- Dependency Ratio
*				  2- Fixed line & Mobile connectivity
*	Data		: Digital Economy Household Survey				*
*---------------------------------------------------------------*
*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000


/*------------------------------------------------------------------------------
					CREATING DEPENDENCY RATIO INDICATORS
------------------------------------------------------------------------------*/

	use "${raw}BUKU1_AV", clear
	*preserve
	
	*gen hierarchical id
	tostring av_1, replace //convert no ART using 
	
	sort hh_id av_1
	gen ind_id = wilcah + hh_id + av_1
		la var ind_id "individual ID"
	
	order cspro* wilcah hh* ind*
	
	*Household head
	gen hh_head = (av_5==1) if av_5!=.
		la var hh_head "1=Household head"
			
	*Gender
	gen male = (av_4==1) if av_4!=.
		la var male "1=male"
			
	*Age
	gen agex = 2020-av_4a_yr
		la var agex "age =  2020 - birth year"
	gen age=av_5
		la var age "age (in years)"
		
	gen age1564 = agex >= 15 & agex <=64
	gen youth = agex <15
	gen elder = agex >=65
	
	foreach x of varlist age1564 youth elder {
		replace `x'=0 if `x'==.
		
	}

	gcollapse (sum) age1564 youth elder, by(hh_id)
	
	gen tot_youtheld = elder + youth
	
	gen DR_youth =  youth/age1564
	gen DR_elder = elder/age1564
	gen DR 		 = tot_youtheld/age1564

		
	label var DR_elder  "Elderly Dependency Ratio"
	label var DR_youth  "Youth Dependency Ratio"
	label var DR	 	"Dependency Ratio"
	

	keep hh_id age1564 youth elder tot_youtheld DR_youth DR_elder DR
	sort hh_id
	
	tempfile dr
	save `dr', replace
	
	*NOTE: FINAL HH NUMBER = 3,063
	
/*------------------------------------------------------------------------------
					CREATING CONNECTIVITY INDICATORS
------------------------------------------------------------------------------*/
	
	*FIXED LINE CONNECTIVITY
	use "${raw}BUKU1_AVIII.dta", clear
	
	*ICT device ownership
	gen ownmobileph=aviii_40_a 
	gen ownpc=aviii_40_b 
	gen owntablet=aviii_40_c
	
	foreach x of varlist ownmobileph ownpc owntablet {
		
		recode `x' (3=0)
		tab `x'
	}
	
	label var ownmobileph 	"Household Own Mobile Phone"
	label var ownpc 		"Household Own Laptop or PC"
	label var owntablet 	"Household Own Tablet"
	
	*fixed line connection
	gen hasfixedline= aviii_41
		recode hasfixedline (3=0) (8=.) (.=0) 
		
	*fixed line expenditure
	gen fixedln_rp= aviii_43 if hasfixedline==1
		recode fixedln_rp (99999998=0)
		recode fixedln_rp (.=0)
		
	gen ln_fixedln = log(fixedln_rp)
		
	label var hasfixedline 	"Household Connected to Fixed Line Internet Network"
	label var fixedln_rp 	"Household Expenditure for Fixed Line Internet, Rp/Month"
	label var ln_fixedln 	"Log of Household Expenditure for Fixed Line Internet, Rp/Month"

	
	keep wilcah hh_id own* fixedln_rp hasfixedline ln_fixedln
	sort wilcah hh_id
	
	tempfile fixedline
	save `fixedline', replace
	
	
	*INTERNET QUALITY
	use "${raw}BUKU1_AX1.dta", clear
	
	gen has2G3G=ax_1a ==1
	gen has4G=ax_1b ==1
		replace has2G3G=0 if has2G3G==. & has2G3G!=1
		replace has4G=0 if has4G==. & has4G!=1
		
	label var has2G3G 	"2G/3G CONNECTION IS PRESENT IN THE HOUSEHOLD"
	label var has4G 	"4G CONNECTION IS PRESENT IN THE HOUSEHOLD"	
	
	keep wilcah hh_id has*
	sort wilcah hh_id
	
	tempfile mobilecon
	save `mobilecon'
	
	*INTERNET SPEED
	use "${raw}BUKU1_AX2.dta", clear
	
	*reshaping data
	reshape wide ax_2b ax_2c ax_2d ax_2e, i(cspro_id wilcah hh_id) j(ax_2a) string
	
	*recoding unique value
	foreach x of varlist ax_2eA ax_2eC ax_2eD ax_2eE{
		
		replace `x'=. if `x'==6
	}
	
	foreach x of varlist ax_2dA ax_2dC ax_2dD ax_2dE{
		
		replace `x'=. if `x'==996
	}
	
	
	foreach x of varlist ax_2bA ax_2cA ax_2bB ax_2cB ax_2bC ax_2cC ax_2bD ax_2cD ax_2bE ax_2cE{
		
		replace `x'=. if `x'==96.96
	}
	
	*creating average value 
	egen ms_download= rowmean(ax_2bA ax_2bB ax_2bC ax_2bD ax_2bE)
	egen ms_upload	= rowmean(ax_2cA ax_2cB ax_2cC ax_2cD ax_2cE)
	egen m_latency	= rowmean(ax_2dA ax_2dC ax_2dD ax_2dE)
	egen m_signalbar= rowmean(ax_2eA ax_2eC ax_2eD ax_2eE)
	
	label var ms_download	"Average Download Speed of 5 major operators, in Household"
	label var ms_upload		"Average Upload Speed of 5 major operators, in Household"
	label var m_latency		"Average Latency of 5 major operators, in Household"
	label var m_signalbar	"Average Signal Bar of 5 major operators, in Household"
	
	keep wilcah hh_id ms_download ms_upload m_latency m_signalbar
	sort wilcah hh_id
	
	count
	tempfile signal
	save `signal', replace
	
	*MERGING ALL HOUSEHOLD INDICATORS*

	merge 1:1 hh_id using `mobilecon'
		*replacing speed with 0 for hh with no 4g network
		
		foreach x of varlist ms_download ms_upload m_latency m_signalbar{
			replace `x'=0 if `x'==.
		}
		drop _merge
	merge 1:1 hh_id using `fixedline' 
		drop if _merge!=3
		drop _merge
	merge 1:1 hh_id using `dr'
		drop if _merge!=3
		drop _merge

		sort wilcah hh_id
		save "${coded}connecthh.dta", replace
	
	
							
	
	


	
	

	
	

