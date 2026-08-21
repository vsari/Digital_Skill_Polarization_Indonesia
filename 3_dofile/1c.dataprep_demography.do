*-------------------------------------------------------------------------------*
*	Author		: Virgi Sari													*
*	Email		: vas39@bath.ac.uk												*
*	Program 	: Data preparation on digital literacy							*
*				  Getting information on Household member demography			*
*	Data		: World Bank Digital Economy Household Survey 2020				*
*				  Download: https://microdata.worldbank.org/index.php/catalog/4602	*
*-------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000


/* List of variables of interests: 

This do-file generates DEMOGRAPHIC variables to be used as independent variables
for the regressions in Table 4-5.

The selected demography variables are below (also referenced in Table 3 main text):

	*Variable names*			*Definitions*
	male						a dummy variable; 1=male & 0=female
	age							age of household member (in years)
	educ_year					years of education

*/

/*------------------------------------------------------------------------------
	STEP 1 - clean book cover to obtain Household Demographics
--------------------------------------------------------------------------------*/
*Open file
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
		//note: 6,500 contraditions
			
	*Marrital status
	gen marrital = av_6
		la var marrital "marrital status"
	gen married = (marrital==2) if marrital!=.
		la var married "1=married"
			
	*Education
		*School participation
		gen school_attend = av_7
			la var school_attend "1=never attended school"
		
		*Educ level
		recode av_8 (1/3=1 "SD") (4/6=2 "SMP") (7/10=3 "SMA") (11/15=4 "Tertiary") (99=.), gen(educ_type)
			replace educ_type=0 if school_attend==1
			la var educ_type "Level of education completed"
			
		*Years of educ (need to work on this
		gen educ_year = 0
			//SD years
			replace educ_year=1 if educ_type==1 & av_9==1
			replace educ_year=2 if educ_type==1 & av_9==2
			replace educ_year=3 if educ_type==1 & av_9==3
			replace educ_year=4 if educ_type==1 & av_9==4
			replace educ_year=5 if educ_type==1 & av_9==5
			replace educ_year=6 if educ_type==1 & av_9==6
			replace educ_year=6 if educ_type==1 & av_9==8
			
			//SMP years
			replace educ_year=7 if educ_type==2 & av_9==1
			replace educ_year=8 if educ_type==2 & av_9==2
			replace educ_year=9 if educ_type==2 & av_9==3
			replace educ_year=9 if educ_type==2 & av_9==8

			
			//SMA years
			replace educ_year=10 if educ_type==3 & av_9==1
			replace educ_year=11 if educ_type==3 & av_9==2
			replace educ_year=12 if educ_type==3 & av_9==3
			replace educ_year=12 if educ_type==3 & av_9==8

			
			//Tertiary years
				*Diploma 1 or 2
				replace educ_year=13 if av_8==11 & av_9==1
				replace educ_year=14 if av_8==11 & av_9==2
				replace educ_year=14 if av_8==11 & av_9==3
				replace educ_year=14 if av_8==11 & av_9==4
				replace educ_year=14 if av_8==11 & av_9==5
				replace educ_year=14 if av_8==11 & av_9==8 //completed
				
				*Diploma 3
				replace educ_year=13 if av_8==12 & av_9==1
				replace educ_year=14 if av_8==12 & av_9==2
				replace educ_year=15 if av_8==12 & av_9==3
				replace educ_year=15 if av_8==12 & av_9==8 //completed
				
				*Undergraduate
				replace educ_year=13 if av_8==13 & av_9==1
				replace educ_year=14 if av_8==13 & av_9==2
				replace educ_year=15 if av_8==13 & av_9==3
				replace educ_year=16 if av_8==13 & av_9==4
				replace educ_year=17 if av_8==13 & av_9==5
				replace educ_year=16 if av_8==13 & av_9==8 // completed
				
				*Graduate
				replace educ_year=17 if av_8==14 & av_9==1
				replace educ_year=18 if av_8==14 & av_9==2
				replace educ_year=18 if av_8==14 & av_9==3
				replace educ_year=18 if av_8==14 & av_9==4
				replace educ_year=18 if av_8==13 & av_9==6
				replace educ_year=18 if av_8==14 & av_9==6
				replace educ_year=18 if av_8==14 & av_9==8 //completed
				
				*Phd
				replace educ_year=19 if av_8==15 & av_9==1
				replace educ_year=20 if av_8==15 & av_9==2
				replace educ_year=21 if av_8==15 & av_9==3
				replace educ_year=21 if av_8==15 & av_9==4
				replace educ_year=22 if av_8==15 & av_9==7 	
				replace educ_year=22 if av_8==15 & av_9==8
				
				replace educ_year=0 if school_attend==1 //replaced to 0 year if never attended education
				
			
			rename educ_type educ_level
			mdesc school_attend educ* //1 obs missing due to error in data input
			
		*Literacy
			*Reading and writing
			gen literate = (av_10==1) if av_10!=.
			gen read = (av_10==2) if av_10!=.
			gen write = (av_10==3) if av_10!=.
			
				//adjustment
				/*note: literacy question only asked those only completing elementary,
				so here we assume obs with JHS and above can read and write*/
				foreach var in literate read write {
					//adjustment
					replace `var'=1 if av_10a==3
					//labelling
					la var `var' "1=can `var'"
				}
				
			tab literate, m
			tab read, m
			tab write, m
			
			*English
			gen english = av_11
				la var english "subjective view on english skills"
	
	*Employment status
		gen working = (av_13a==1) if av_13a!=.
		
		tab working, miss //no missing values
		
	*Keep only relevant variable
	keep wilcah hh_id ind_id hh_head male age* marr* school* educ* literate 	///
		read write english working
	order wilcah hh_id ind_id
	sort wilcah hh_id ind_id
	
	*check missing values
	mdesc
	
*Save file

	save "${coded}dehs_demography", replace
	
	/* Note:
	- data is at individual-level age >15
	- Total individual: 8620
	*/
	

	