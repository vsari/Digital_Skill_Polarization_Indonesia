*-------------------------------------------------------------------------------*
*	Author		: Virgi Sari 													*
*				  Anissa Rahmawati												*
*	Email		: vas39@bath.ac.uk												*
*				  anissarahmasukardi@gmail.com									*
*	Program 	: Sata preparation - generating DIGITAL SKILLS variables		*
*	Data		: World Bank Digital Economy Household Survey 2020				*
*				  Link - https://microdata.worldbank.org/index.php/catalog/4602	*
*	Created		: 30.04.2020													*
*	Version		: 02.03.2026 (final revision for jourmal submission)			*					
*-------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000

/* List of variables of interests: 
This do-file generates variables of digital skills*

1. DEPENDENT VARIABLES - DIGITAL SKILLS STATUS
Definition: a series of dummy variables with 1 indicating respondent has digital skill
and 0 otherwise. Definitions are referenced in Table 3 main text.


*Variable Names*			*Skill*
skill_ictdev				ICT devices and internet
skill_info					Information and data
skill_comm					Communication and collaboration
Skill_creation				Production of digital contents
skill_security				Digital security
skill_problem				Problem Solving


2. DEPENDENT VARIABLES - DIGITAL SKILL PROFICIENCY
Note: it is a categorical variable indicating skill level (0=have no skill, 1=beginner, 
2=intermediate, 3=advanced), and generated for each of the six digital skill components.
indicated level (e.g., beginner, intermediate, or advanced). The definitions are 
referenced in Table in the main text.

*Variable Names*			*Skill*

skill_ictdev1				Beginner level - skill: ICT devices and internet
skill_ictdev2				Intermediate level - skill: ICT devices and internet
skill_ictdev3				Advanced level - skill: ICT devices and internet

the number 1,2,3 indicated the digital skill proficiency. The rest of other digital skills
variables followed the above format.

3. SOFT-SKILLS (used as independent variables in the regressions)
Definition: a series of dummy variables with 1 indicating respondent has the soft skill
Note: Definitions are referenced in Table 3 main text as well as Annex Table A.2

*Variable Names*			*Skill*
inter_info					creative
inter_selfdirect 			Self-direction
inter_critical				Critical thinking
inter_growthmind			Growth mindset
intra_comm					Communication
intra_collab				Collaboration
intra_leadership			Leadership
intra_problen				Problem Solving
	
*/


/*------------------------------------------------------------------------------
	STEP 0 - Creating hierarchical ID 
--------------------------------------------------------------------------------*/
* Generating hierarcical ID in all books (for merging)
	
	foreach book in "VII" "VIII" "IX" "X" "XI" "XII" "XIII" {
	
		*Open file
		use "${raw}BUKU2_B`book'", clear
		
		*Gen hierarchical id
		rename ea_b2 wilcah //to make it consistent with other books
		
		gen hh_id = buku2_id //hhid
		
		tostring b2_cov1_id, replace //convert no ART using 
		
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
			la var ind_id "individual ID"
		
		sort wilcah hh_id ind_id
		tempfile `book'
		save ``book'', replace
	}
	
/*------------------------------------------------------------------------------
	STEP I - merge all datasets in digital literacy module
--------------------------------------------------------------------------------*/

	*merging data
	use `VII', clear
		merge 1:1 ind_id using `VIII', nogen
		merge 1:1 ind_id using `IX', nogen
		merge 1:1 ind_id using `X', nogen
		merge 1:1 ind_id using `XI', nogen
		merge 1:1 ind_id using `XII', nogen
		merge 1:1 ind_id using `XIII', nogen
	
	/* merging data
	use "${raw}BUKU2_BVII.dta", clear

		merge 1:1 cspro_id using "${raw}BUKU2_BVIII.dta", nogen //note that cspro_id = EA + hh_id + no urut ART (unique at the individual level)
		merge 1:1 cspro_id using "${raw}BUKU2_BIX.dta", nogen
		merge 1:1 cspro_id using "${raw}BUKU2_BX.dta", nogen
		merge 1:1 cspro_id using "${raw}BUKU2_BXI.dta", nogen
		merge 1:1 cspro_id using "${raw}BUKU2_BXII.dta", nogen
		merge 1:1 cspro_id using "${raw}BUKU2_BXIII.dta", nogen
	*/
	
	drop cspro_id buku2_id b2_cov1_
	sort wilcah hh_id ind_id
	order wilcah hh_id ind_id
	save "${coded}dehs_skill", replace //Total: 5523 individuals (unique observation)

/*------------------------------------------------------------------------------
	BOOK VII. OPERATION OF ICT DEVICES AND INTERNET (SKILL O1)
--------------------------------------------------------------------------------*/

*Open file
	use "${coded}dehs_skill", clear
	
	*gen variable on ICT and internet use
	gen ictuse = (bvii_1a==1)
		la var ictuse "1=have operated both ICT devices and internet"
		
	*gen total score in skill 01:
	egen s_skill01 = rowtotal(bvii_1_a bvii_1_b bvii_1_c bvii_1_d)
		replace s_skill01=0 if ictuse==0 //those who never use ICT and internet coded to have 0 skill
		la var s_skill01 "Total score in digital skill - ICT device use"
		
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_ictdev_`component' = bvii_1_`component'
				recode skill_ictdev_`component' (1/2=0) (3/4=1)
				replace skill_ictdev_`component'=0 if ictuse==0
			}
			
		sum skill_ictdev_*
		tab skill_ictdev_a, miss //no missing values
	
	*gen skill 01: Use of ICT devices
		//beginner
		egen easy = rowmean(bvii_1_a bvii_1_b)
		gen skill_ictdev1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_ictdev1 = 0 if ictuse==0 //never use ICT device
		drop easy
		
		//intermediate
		gen skill_ictdev2 = (skill_ictdev1==1 & bvii_1_c>=3 &ictuse==1)
		tab skill_ictdev2, miss
		
		//advance
		gen skill_ictdev3 = (skill_ictdev1==1 & skill_ictdev2==1 & bvii_1_d>=3 & ictuse==1)
			replace skill_ictdev3= 0 if ictuse==0 //never use ICT device
	
		*adjustment
			replace skill_ictdev1=1 if (skill_ictdev2!=1 | skill_ictdev3!=1) & skill_ictdev1==1 & ictuse==1 //beginner
			replace skill_ictdev2=1 if skill_ictdev3!=1 & skill_ictdev2==1 & ictuse==1
		
		*gen categorical var of skill 01
		gen skill_ictdev = 0
			replace skill_ictdev=0 if skill_ictdev1!=1 | ictuse==0
			replace skill_ictdev=1 if skill_ictdev1==1
			replace skill_ictdev=2 if skill_ictdev2==1
			replace skill_ictdev=3 if skill_ictdev3==1
			*replace skill_ictdev=0 if ictuse==0
			
			la def lvl 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_ictdev lvl		
			
	*labelling variable
		la var skill_ictdev		"Digital skill 01 - ICT device use"
		la var skill_ictdev1 	"1=beginner level of ICT use"
		la var skill_ictdev2 	"1=intermediate level of ICT device use"
		la var skill_ictdev3 	"1=advance level of ICT device use"
		
		tab skill_ictdev, miss

/*------------------------------------------------------------------------------
	BOOK VIII. INFORMATION AND DATA (SKILL 02)
--------------------------------------------------------------------------------*/

	*gen total score in skill 02
	egen s_skill02 = rowtotal(bviii_2a bviii_2b bviii_2c bviii_2d)
		replace s_skill02=0 if ictuse==0  //those who never use ICT and internet coded to have 0 skill
		la var s_skill02 "Total score in digital skill - Online information and data searching"
	
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_info_`component' = bviii_2`component'
				recode skill_info_`component' (1/2=0) (3/4=1)
				replace skill_info_`component'=0 if ictuse==0
		}
		
		sum skill_info_*
		tab skill_info_a, miss //check for missing values
		
	*gen skill 02: information and data (searching using internet)
		//beginner
		egen easy = rowmean(bviii_2a bviii_2b)
		gen skill_info1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_info1=0 if ictuse==0
		drop easy
		
		//intermediate
		gen skill_info2 = (bviii_2c>=3 & ictuse==1) if bviii_2c!=.
			replace skill_info2=0 if ictuse==0
			
		//advance
		gen skill_info3 = (bviii_2d>=3 & ictuse==1) if bviii_2d!=.
			replace skill_info3=0 if ictuse==0

		*adjustment
			replace skill_info1=1 if (skill_info2!=1 | skill_info3!=1) & skill_info1==1 & ictuse==1 //beginner
			replace skill_info2=1 if skill_info3!=1 & skill_info2==1 & ictuse==1	 //intermediate
			
		*gen categorical var of skill02
		gen skill_info = 0
			replace skill_info=0 if skill_info1!=1 | ictuse==0
			replace skill_info=1 if skill_info1==1 & ictuse==1
			replace skill_info=2 if skill_info2==1 & ictuse==1
			replace skill_info=3 if skill_info3==1 & ictuse==1
			
			la def lvl2 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_info lvl2		

		*labelling variable
		la var skill_info	"Digital skill 02 - Information and data searching"
		la var skill_info1 	"1=beginner level of Information and data searching"
		la var skill_info2 	"1=intermediate level of Information and data searching"
		la var skill_info3 	"1=advance level of Information and data searching"
			
		tab skill_info, miss

/*------------------------------------------------------------------------------
	BOOK IX. COMMUNICATION & COLLABORATION - SKILL 03
--------------------------------------------------------------------------------*/

	*gen total score in skill 03
	egen s_skill03 = rowtotal(bix_3a bix_3b bix_3c bix_3d)
		replace s_skill03=0 if ictuse==0  //those who never use ICT device and internet coded to have 0 skill
		la var s_skill03 "Total score in digital skill - Communication and Collaboration"
		
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_comm_`component' = bix_3`component'
				recode skill_comm_`component' (1/2=0) (3/4=1) (9=.)
				replace skill_comm_`component'=0 if ictuse==0
		}
		
		sum skill_comm_*
		tab skill_comm_a, miss //no missing values
	
	*gen skill 03: information and data (searching using internet)
		//beginner
		egen easy = rowmean(bix_3a bix_3b)
		gen skill_comm1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_comm1=0 if ictuse==0
		drop easy
		
		//intermediate
		gen skill_comm2 = (bix_3c>=3 & ictuse==1) if bix_3c!=.
			replace skill_comm2=0 if ictuse==0
			
		//advance
		gen skill_comm3 = (bix_3d>=3 & ictuse==1) if bix_3d!=.
			replace skill_comm3=0 if ictuse==0

		*adjustment
			replace skill_comm1=1 if (skill_comm2!=1 | skill_comm3!=1) & skill_comm1==1 & ictuse==1 //beginner
			replace skill_comm2=1 if skill_comm3!=1 & skill_comm2==1 & ictuse==1	 //intermediate
			
		*gen categorical var of skill02
		gen skill_comm = 0
			replace skill_comm=0 if skill_comm1!=1 | ictuse==0
			replace skill_comm=1 if skill_comm1==1 & ictuse==1
			replace skill_comm=2 if skill_comm2==1 & ictuse==1
			replace skill_comm=3 if skill_comm3==1 & ictuse==1
			
		la def lvl3 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_comm lvl3		

		*labelling variable
		la var skill_comm	"Digital skill 01 - comm and collaboration"
		la var skill_comm1 	"1=beginner level of comm and collaboration"
		la var skill_comm2 	"1=intermediate level of comm and collaboration"
		la var skill_comm3 	"1=advance level of comm and collaboration"
					
		tab skill_comm, miss

/*------------------------------------------------------------------------------
	BOOK X. PRODUCTION OF DIGITAL CONTENTS - SKILL 04
--------------------------------------------------------------------------------*/

	*gen total score in skill 04
	egen s_skill04 = rowtotal(bx_4a bx_4b bx_4c bx_4d)
		replace s_skill04=0 if ictuse==0  //those who never use ICT and internet coded to have 0 skill
		la var s_skill04 "Total score in digital skill - Digital content creation"
		
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_content_`component' = bx_4`component'
				recode skill_content_`component' (1/2=0) (3/4=1) /*(9=.)*/
				replace skill_content_`component'=0 if ictuse==0
		}
		
		sum skill_content_*
		tab skill_content_a, miss //no missing values
	
	*gen skill 04: digital content creation
		//beginner
		egen easy = rowmean(bx_4a bx_4b)
		gen skill_content1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_content1=0 if ictuse==0
		drop easy
		
		//intermediate
		gen skill_content2 = (bx_4c>=3 & ictuse==1) if bx_4c!=.
			replace skill_content2=0 if ictuse==0
			
		//advance
		gen skill_content3 = (bx_4d>=3 & ictuse==1) if bx_4d!=.
			replace skill_content3=0 if ictuse==0

		*adjustment
			replace skill_content1=1 if (skill_content2!=1 | skill_content3!=1) & skill_content1==1 & ictuse==1 //beginner
			replace skill_content2=1 if skill_content3!=1 & skill_content2==1 & ictuse==1	 //intermediate
			
		*gen categorical var of skill02
		gen skill_content = 0
			replace skill_content=0 if skill_content1!=1 | ictuse==0
			replace skill_content=1 if skill_content1==1 & ictuse==1
			replace skill_content=2 if skill_content2==1 & ictuse==1
			replace skill_content=3 if skill_content3==1 & ictuse==1
			
		la def lvl4 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_content lvl4	

		*labelling variable
		la var skill_content	"Digital skill 04 - digital content creation"
		la var skill_content1 	"1=beginner level of digital content creation"
		la var skill_content2 	"1=intermediate level of digital content creation"
		la var skill_content3 	"1=advance level of digital content creation"
			
		tab skill_content, miss
		
/*------------------------------------------------------------------------------
	BOOK XI. DIGITAL SECURITY - SKILL 05
--------------------------------------------------------------------------------*/

	*gen total score in skill 05
	egen s_skill05 = rowtotal(bxi_5a bxi_5b bxi_5c bxi_5d)
		replace s_skill02=0 if ictuse==0  //those who never use ICT and internet coded to have 0 skill
		la var s_skill02 "Total score in digital skill - Digital security"
		
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_security_`component' = bxi_5`component'
				recode skill_security_`component' (1/2=0) (3/4=1) /*(9=.)*/
				replace skill_security_`component'=0 if ictuse==0
		}
		
		sum skill_security_*
		tab skill_security_a, miss //no missing values
	
	*gen skill 05: information and data (searching using internet)
		//beginner
		egen easy = rowmean(bxi_5a bxi_5b)
		gen skill_security1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_security1=0 if ictuse==0
		drop easy
		
		//intermediate
		gen skill_security2 = (bxi_5c>=3 & ictuse==1) if bxi_5c!=.
			replace skill_security2=0 if ictuse==0
			
		//advance
		gen skill_security3 = (bxi_5d>=3 & ictuse==1) if bxi_5d!=.
			replace skill_security3=0 if ictuse==0

		tab skill_security1, miss //check with SM on large missing obs among ICT and internet users
 		tab skill_security2, miss
		tab skill_security3, miss
		
		*adjustment
			replace skill_security1=1 if (skill_security2!=1 | skill_security3!=1) & skill_security1==1 & ictuse==1 //beginner
			replace skill_security2=1 if skill_security3!=1 & skill_security2==1 & ictuse==1	 //intermediate
			
		*gen categorical var of skill02
		gen skill_security = 0
			replace skill_security=0 if skill_security1!=1 | ictuse==0
			replace skill_security=1 if skill_security1==1 & ictuse==1
			replace skill_security=2 if skill_security2==1 & ictuse==1
			replace skill_security=3 if skill_security3==1 & ictuse==1
		
		la def lvl5 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_security lvl5	

		*labelling variable
		la var skill_security	"Digital skill 05 - digital security"
		la var skill_security1 	"1=beginner level of digital security"
		la var skill_security2 	"1=intermediate level of digital security"
		la var skill_security3 	"1=advance level of digital security"
						
		tab skill_security, miss

/*------------------------------------------------------------------------------
	BOOK XII. PROBLEM SOLVING - SKILL 06
--------------------------------------------------------------------------------*/

	*gen total score in skill 06
	egen s_skill06 = rowtotal(bxii_6a bxii_6b bxii_6c bxii_6d)
		replace s_skill06=0 if ictuse==0  //those who never use ICT and internet coded to have 0 skill
		la var s_skill06 "Total score in digital skill - Problem solving using internet"
	
		//renaming each component
		foreach component in "a" "b" "c" "d" {
			gen skill_problem_`component' = bxii_6`component'
				recode skill_problem_`component' (1/2=0) (3/4=1) /*(9=.)*/
				replace skill_problem_`component'=0 if ictuse==0
		}
		
		sum skill_problem_*
		tab skill_problem_a, miss //no missing values
		
	*gen skill 05: problem solving (using internet)
		//beginner
		egen easy = rowmean(bxii_6a bxii_6b)
		gen skill_problem1 = (easy>=3 & ictuse==1) if easy!=.
			replace skill_problem1=0 if ictuse==0
		drop easy
		
		//intermediate
		gen skill_problem2 = (bxii_6c>=3 & ictuse==1) if bxii_6c!=.
			replace skill_problem2=0 if ictuse==0
			
		//advance
		gen skill_problem3 = (bxii_6d>=3 & ictuse==1) if bxii_6d!=.
			replace skill_problem3=0 if ictuse==0

		*adjustment
			replace skill_problem1=1 if (skill_problem2!=1 | skill_problem3!=1) & skill_problem1==1 & ictuse==1 //beginner
			replace skill_problem2=1 if skill_problem3!=1 & skill_problem2==1 & ictuse==1	 //intermediate
			
		*gen categorical var of skill02
		gen skill_problem = .
			replace skill_problem=0 if skill_problem1!=1 | ictuse==0
			replace skill_problem=1 if skill_problem1==1 & ictuse==1
			replace skill_problem=2 if skill_problem2==1 & ictuse==1
			replace skill_problem=3 if skill_problem3==1 & ictuse==1
			
		la def lvl6 0 "no skill" 1 "beginner" 2 "intermediate" 3 "advance"
			la val skill_problem lvl6

		*labelling variable
		la var skill_problem	"Digital skill 05 - digital problem solving"
		la var skill_problem1 	"1=beginner level of digital problem solving"
		la var skill_problem2 	"1=intermediate level of digital problem solving"
		la var skill_problem3 	"1=advance level of digital problem solving"

		*check for missing value
		mdesc sk*
		
		tab skill_problem, miss

/*------------------------------------------------------------------------------
	BOOK XIII. COMPLEMENTARY NON-DIGITAL SKILLS
--------------------------------------------------------------------------------*/
/* There are two sets of complementary skills:
	(i) Digital building blocks
	(ii) intrapersonal skills
*/	
*gen var on various complementary digital skills
	
	*send/receive emails
	gen c_emails = bxiii_7a
	
	*search for a job online
	gen c_jobsearch = bxiii_7b
	
	*conduct transaction online
	gen c_ecommerce = bxiii_7c
	
	*use spreadsheet
	gen c_spreadsheet = bxiii_7d
	
	*use word processor
	gen c_word = bxiii_7e
	
	*use a programmming language
	gen c_program = bxiii_7f
	
	*conduct online real time discussion
	gen c_discuss = bxiii_7g
	
	*adjustment with those who never use ICT device and internet
		foreach skill in "emails" "jobsearch" "ecommerce" "spreadsheet" "word" 	///
			"spreadsheet" "word" "program" "discuss" {
			
			replace c_`skill'=1 if ictuse==0 //replace skill to 0 who have never used ICT device or internet
		
			label var c_`skill' "DIGITAL BUILDING BLOCK in `skill'"
			
			tab c_`skill', miss
		}

	mdesc c_* //check for missing values

*gen var on INTRA-personal skills
/*note: this questions ask to all individuals, regardless of ICT&internet users or not*/

	mdesc bxiii_8* //no missing value
	
	*self-direction
	egen level = rowmean(bxiii_8a bxiii_8b) //averaging the two proxy questions for this skills
	gen intra_selfdirect = (level>=3) if level!=. //1= have the skill if the average of the two proxy is >=3
		drop level
		
		**unpacking (added in 11.Dec.20)
		gen intra_selfdirect1_findideas = bxiii_8a
			gen intra_selfdirect1 = (bxiii_8a>2)
		
		gen intra_selfdirect2_findinfo = bxiii_8b
			gen intra_selfdirect2 = (bxiii_8b>2)
		
	*creativity
	egen level = rowmean(bxiii_8c bxiii_8d)
	gen intra_creative = (level>=3) if level!=.
		drop level
			
		**unpacking
		gen intra_creative1_openideas = bxiii_8c
			gen intra_creative1 = (bxiii_8c>2) if bxiii_8c!=.
		
		gen intra_creative2_exploreideas = bxiii_8d
			gen intra_creative2 = (bxiii_8d>2) if bxiii_8d!=.
	
	*critical thinking
	egen level = rowmean(bxiii_8e bxiii_8f)
	gen intra_critical = (level>=3) if level!=.
		drop level
		
		**unpacking
		gen intra_critical1_logical = bxiii_8e
			gen intra_critical1 = (bxiii_8e>2) if bxiii_8e!=.
			
		gen intra_critical2_evidence = bxiii_8f
			gen intra_critical2 =  (bxiii_8f>2) if bxiii_8f!=.
	
	*analytical skills [but the question rather look into growth mindset]
	egen level = rowmean (bxiii_8g bxiii_8h)
	gen intra_growthmind = (level>=3) if level!=.
		drop level
		
		**unpacking
		gen intra_growthmind1_learning = bxiii_8g
			gen intra_growthmind1 = (bxiii_8g>2) if bxiii_8g!=.
			
		gen intra_growthmind2_experience = bxiii_8h
			gen intra_growthmind2 = (bxiii_8h>2) if bxiii_8h!=.
	
		*labelling vars
		foreach intraskill in "selfdirect" "creative" "critical" "growthmind" {
			label var intra_`intraskill' "1=have intrapersonal skill in `intraskill'"
			
			tab intra_`intraskill', miss
		}
		
*gen var on INTER-personal skills
	
	*communication
	egen level = rowmean(cix_9a cix_9b) //averaging the two proxy questions for this skills
	gen inter_comm = (level>=3) if level!=. //1= have the skill if the average of the two proxy is >=3
		drop level
		
		**unpacking (added 11.Dec.20)
		gen inter_comm1_tellideas = cix_9a
			gen inter_comm1 = (cix_9a>2) if cix_9a!=.
		
		gen inter_comm2_publicspeak = cix_9b
			gen inter_comm2 = (cix_9b>2) if cix_9b!=.
	
	*collaboration
	egen level = rowmean(cix_9c cix_9d)
	gen inter_collab = (level>=3) if level!=.
		drop level
		
		**unpacking
		gen inter_collab1_workothers = cix_9c
			gen inter_collab1 =(cix_9c>2) if cix_9c!=.
		
		gen inter_collab2_otherspers = cix_9d
			gen inter_collab2 = (cix_9d>2) if cix_9d!=.
	
	*leadership
	egen level = rowmean(cix_9e cix_9f)
	gen inter_leadership = (level>=3) if level!=.
		drop level
		
		**unpacking
		gen inter_leadership1_initiative = cix_9e
			gen inter_leadership1 = (cix_9e>2) if cix_9e!=.
			
		gen inter_leadership2_mngpeople = cix_9f
			gen inter_leadership2 = (cix_9f>2) if cix_9f!=.
	
	*problem solving
	egen level = rowmean(cix_9g cix_9h)
	gen inter_problem = (level>=3) if level!=.
		drop level
	
		**unpacking
		gen inter_problem1_calm = cix_9g
			gen inter_problem1 = (cix_9g>2) if cix_9g!=.
			
		gen inter_problem2_solve = cix_9h
			gen inter_problem2 = (cix_9h>2) if cix_9h!=.
	
		*labelling vars
		foreach interskill in "comm" "collab" "leadership" "problem" {
			label var inter_`interskill' "1=have interpersonal skill in `interskill'"
			
			tab inter_`interskill', miss
		}
	
	mdesc inter* //no missing obs
 
* keep only relevant variable
	
	keep wilcah hh_id ind_id ict* s* c_* inter* intra*
	order wilcah hh_id ind_id ict* s* c_* inter* intra*
	
* check for missing obs
	mdesc
	
saveold "${coded}dehs_skill", replace
