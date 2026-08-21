*---------------------------------------------------------------------------------------*
*	Author		: Virgi Sari 															*
*				  Anissa Rahmawati														*
*	Email		: vas39@bath.ac.uk														*
*				  anissarahmasukardi@gmail.com											*
*	Program 	: Descriptive Analysis													*
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

THIS DO FILE PRODUCE DESCRIPTIVE STATISTICS THAT ARE DISCUSSED IN THE PAPER

	Output of this programming includes the following
	
	(-) Annex, Table A.1 
	(-) Annex
	
	(-) Paper - Figure 2, Figure 3, Figure 4, Figure 5
*/

/*------------------------------------------------------------------------------
	2.1 - Demographic of DEHS observations
--------------------------------------------------------------------------------*/

*Set global for survey weight
	global w "[fw=wgt_itg]"

*Open file
	use "${coded}dehs_skill_cleaned", clear
	
	keep if ictuse==1 //the paper focus only on internet users
	
*Setting Survey Data (following World Bank DEHS 2020 survey manual)
	svyset su1 [pweight=wgt], strata(strata1) fpc(fpc1) vce(linearized) singleunit(centered) || su2, fpc(fpc2)
	
*Generate variables

	*Create age group
	recode agex (15/24=1 "15 - 24 y.o") (25/34 = 2 " 25 - 34 y.o") (35/44=3 "35 - 44 y.o") ///
		(45/54=4 "45 - 54 y.o") (55/64=5 "55 - 64 y.o") (65/100=6 "> 65 y.o"), gen(agegroup)
	la var agegroup "age group"
	

*Tabulations (for Annex, Table A1)

	*Demographic characteristics of the sample population (ICT & internet users)
	foreach var of varlist ictuse hh_head male agegroup married school_attend educ_level 			///
		literate read write english working island coreperiphery_new {
			capture putexcel set, clear
			tab2xl `var' $w if ictuse==1 using "${table}/TableA1_demographics.xlsx", 			///
				row(1) col(1) sheet("`var'", replace)
		}
		
	*ICT Users by wealth groups (Decile & Quintile)
	
	foreach x of varlist quintile {
		capture putexcel set, clear
		tabout `x' ictuse [iw=wgt] using "${table}/ictuser_bywealthgroups.csv", cells(freq col) replace
	}
	
	
/*------------------------------------------------------------------------------
	2.2 - The proportion of individuals with digital skills
	Output: Figure 2
------------------------------------------------------------------------------*/

	*Create local to store components of core digital skills
	local ictdev	skill_ictdev_a skill_ictdev_b skill_ictdev_c skill_ictdev_d
	local info 		skill_info_a skill_info_b skill_info_c skill_info_d
	local comm 		skill_comm_a skill_comm_b skill_comm_c skill_comm_d
	local content 	skill_content_a skill_content_b skill_content_c skill_content_d
	local security 	skill_security_a skill_security_b skill_security_c skill_security_d
	local problem	skill_problem_a skill_problem_b skill_problem_c skill_problem_d
	global coreskill `ictdev' `info' `comm' `content' `security' `problem'
	
	
	*Renaming variables for organized output table
		
		*Core skill 01: Operating ICT devices
		la var skill_ictdev_a "Operating ICT device (mobile phone/computer/notebook)"
		la var skill_ictdev_b "Opening browser or applications on ICT device"
		la var skill_ictdev_c "Connecting ICT devices to the internet"
		la var skill_ictdev_d "Installing application and software in ICT device"
			
		foreach component in "a" "b" "c" "d" {
			la def skill_ictdev_`component' 0 "No" 1 "Yes"
			la val skill_ictdev_`component' skill_ictdev_`component'
			}	
		
		*Core skill02: Information and data searching
		la var skill_info_a "Using browser or search applications on ICT device"
		la var skill_info_b "Searching information using key words online"
		la var skill_info_c "Saving information from online search on ICT device"
		la var skill_info_d "Comparing information from different sources"
		
		foreach component in "a" "b" "c" "d" {
			la def skill_info_`component' 0 "No" 1 "Yes"
			la val skill_info_`component' skill_info_`component'
			}
			
		*Core skill03: Communication and collaboration
		la var skill_comm_a "Communication through instant messaging"
		la var skill_comm_b "Using email"
		la var skill_comm_c "Online discussion in groups through internet platform"
		la var skill_comm_d "Working together using cloud sharing"
		
		foreach component in "a" "b" "c" "d" {
			la def skill_comm_`component' 0 "No" 1 "Yes"
			la val skill_comm_`component' skill_comm_`component'
			}
		
		*Core skill04: Production of digital contents
		la var skill_content_a "Copy and forward information on online media"
		la var skill_content_b "Editing information from online media"
		la var skill_content_c "Composing or uploading media on the internet"
		la var skill_content_d "Developing own website and put copyright"
		
		foreach component in "a" "b" "c" "d" {
			la def skill_content_`component' 0 "No" 1 "Yes"
			la val skill_content_`component' skill_content_`component'
			}
		
		*Core skill05: Digital security
		la var skill_security_a "Setting strong password for own ICT device"
		la var skill_security_b "Read data privacy policy"
		la var skill_security_c "Limiting access to personal information on devices"
		la var skill_security_d "Identifying phising emails or messages"
		
		foreach component in "a" "b" "c" "d" {
			la def skill_security_`component' 0 "No" 1 "Yes"
			la val skill_security_`component' skill_security_`component'
			}
			
		*Core skill06: Problem solving
		la var skill_problem_a "searching products/services for daily needs online"
		la var skill_problem_b "buying products/services online"
		la var skill_problem_c "online mobile-banking transactions"
		la var skill_problem_d "updating applications on own ICT devices"
		
		foreach component in "a" "b" "c" "d" {
			la def skill_problem_`component' 0 "No" 1 "Yes"
			la val skill_problem_`component' skill_problem_`component'
			}
		
	*Tabulations
		tabout skill_ictdev_a [iw=wgt] using "${table}/digitalskills_proportion.xls", c(col ci) f(2 1) clab(Share_% 95%_CI) svy ///
			percent replace
		
		foreach skill of varlist $coreskill {
			tabout `skill' [iw=wgt] using "${table}/digitalskills_proportion.xls", c(col ci) f(2 1) clab(Share_% 95%_CI) svy ///
				percent append
			}	
	
/*----------------------------------------------------------------------------------------------------------
	2.3 - The variation in the level of digital skills by age-groups and education levels 
	Output: Figure 3
----------------------------------------------------------------------------------------------------------*/
	
*Generate global to store variable on the level of digital skills for each digital skill type
	global 	skill_level skill_ictdev skill_info skill_comm skill_content ///
			skill_security skill_problem

	//by age-group
	foreach skilllevel of varlist $skill_level {
		
		foreach agegroup of varlist agegroup {
		
			capture putexcel set, clear
		
			tabout `skilllevel' `agegroup' [iw=wgt] using "${table}/`skilllevel'_byage.csv", cells(freq col) 			replace
		}
	}
		
		
	//by education level
	recode educ_level (0=0 "not completing elementary"), gen(educ_levelx)
	foreach skilllevel of varlist $skill_level {
		
		foreach educlvl of varlist educ_levelx {
		
			capture putexcel set, clear
		
			tabout `skilllevel' `educlvl' [iw=wgt] using "${table}/`skilllevel'_byeduc.csv", cells(freq col) 			replace
		}
	}
	

/*-----------------------------------------------------------------------------------------
	2.4 - Digital skills distribution across quantile of wealth groups 
	Output: Figure 4; Annex, Figure A1
------------------------------------------------------------------------------------------*/

	//by quantile wealth groups

	foreach var of varlist $skill_level {
		
		foreach wealthgroup of varlist quintile {
		
		capture putexcel set, clear
		
		tabout `var' `wealthgroup' [iw=wgt] using "${table}/`var'_bywealthgroups.csv", cells(freq col) replace
		}
	}

/*-----------------------------------------------------------------------------------------
	2.5 - Intrapersonal and Interpersonal skills among internet users in Indonesia
	Output: Figure 5
------------------------------------------------------------------------------------------*/


* Preparing main outcome of variables
	//the main outcome variables are a series of dummy variables with a score of..
	//1=respondents have the digital skill and 0 otherwise (as described in Table 3)
		
		foreach skilltype in "ictdev" "info" "comm" "content" "security" "problem" {
			gen dum_`skilltype' = (skill_`skilltype'!=0)
		}
		
* Generate global to store the variables for tabulation
	global skilltype dum_ictdev dum_info dum_comm dum_content dum_security dum_problem


*Tabulations
	//Intrapersonal skill
	
	global intrasoftskills intra_selfdirect intra_creative intra_critical intra_growthmind
	
	foreach skilltype of varlist $skilltype {
		
		foreach intraskill of varlist $intrasoftskills {
			
			capture putexcel set, clear
			tabout `skilltype' `intraskill' [iw=wgt] using "${table}/`skilltype'_`intraskill'.csv", cells(freq 				row) replace
		}
	}
	
	
	//Interpersonalskill
	
	global intersoftskills inter_comm inter_collab inter_leadership inter_problem
	
	
	foreach skilltype of varlist $skilltype {
		
		foreach interskill of varlist $intersoftskills {
			
			capture putexcel set, clear
			tabout `skilltype' `interskill' [iw=wgt] using "${table}/`skilltype'_`interskill'.csv", cells(freq 				row) replace
		}
	}
	
	
* END *
