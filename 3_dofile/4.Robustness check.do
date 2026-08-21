*---------------------------------------------------------------*
*	Author		: Virgi Sari 									*
*	Email		: vas39@bath.ac.uk								*
*	Program 	: Robustness
*	Data		: Digital Economy Household Survey				*
*---------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000


******************************************************************************
* 3. ROBUSTNESS
* 3.1. Robustness for RQ1 - determinants of skill status (LOGIT MODELS)
* 3.2. Robustness for RQ2 - determinants of skill proficiency (MNL MODELS)
* Note for the paper, we use 3.1 and 3.2. to draft robustness section in methods

/* Outputs reported in Appendices, section robustness check:
(-) Table 1a - Sensitivity check on model specifications, skill 1-3)
(-) Table 1b - Sensitivity check on model specifications, skill 4-6
(-) Table 2 - Model fit tests for logit estimations of each skill component (final model m4)
(-) Table 3 - Model fit tests for logit estimations of each skill component from reduced to full model
(-) Table 4 - model fit tests for multinominal logit estimations of each skill component
*/
********************************************************************************

/*Run ROBUSTNESS Check*/

*Open file

	use "${coded}dehs_reg.dta", clear

/* 3.1  Run robustness for logit model (skill status determinant)
	//Ref: https://stats.oarc.ucla.edu/stata/webbooks/logistic/chapter3/lesson-3-logistic-regression-diagnostics/
	//https://www.rba.gov.au/publications/rdp/2020/2020-03/appendix-c.html
	//Stata: help logit postestimation (this will list you tests to run)
*/
	
	*3.1.1. Run FITSTAT for LOGIT model (Table 4 and Table A2)
	
	/* FITSTAT (AIC, BIC, model-fit)
	Note:
	(-) post-estimation command computes measure of fit for logit, mlogit, ologit, etc.
	References: J. Scott Long & Jeremy Freese. 2014.  Regression Models for Categorical Dependent Variables Using Stata
	(-) The model fit test is for LOGIT models reported in Table 4 (main text) and Table A2 (Appendices)
	(-) The results from this section is reported on Table 2 & 3 (Appendices, section Robustness Check) */
	
	
	*Install fitstat syntax in STATA
	ssc install fitstat, replace
		
		//Running FITSTAT for each six component of skill (final model - m4)
		//resulted reported in Table 2, Appendices, section Robustness check 
		foreach skill of varlist dum_ictdev dum_info dum_comm dum_content dum_security dum_problem {
			qui logit `skill' $connect $softsksills $demographic $geo $w, vce(cluster kab_id)
			di as text "FITSTAT for skill `skill'"
			fitstat
			//Note on the results: all STRONG FIT
			
		}
		
		*CONCLUSION: S1-S6 LOGIT MODEL ALL VERY GOOD FIT
		
		//Running FITSTAT for each six component of skill ON DIFFERENT MODEL SPECIFICATION
		*create global to store variables
		gl m1 $connect
		gl m2 $connect $softskills
		gl m3 $connect $softskills $demographic
		gl m4 $connect $softskills $demographic $geo //this's the model used in the paper
		
			//s1
			qui logit dum_ictdev $m1 $w, vce(cluster kab_id)
				di as text "ICTDEV-M1"
				fitstat //poorfit
			qui logit dum_ictdev $m2 $w, vce(cluster kab_id)
				di as text "ICTDEV-M2"
				fitstat //moderate
			qui logit dum_ictdev $m3 $w, vce(cluster kab_id)
				di as text "ICTDEV-M3"
				fitstat //strong
			qui logit dum_ictdev $m4 $w, vce(cluster kab_id)
				di as text "ICTDEV-M4"
				fitstat //strong
			
			//S2
			qui logit dum_info $m1 $w, vce(cluster kab_id)
				di as text "S2: INFO-M1"
				fitstat //poorfit
			qui logit dum_info $m2 $w, vce(cluster kab_id)
				di as text "S2: INFO-M2"
				fitstat
			qui logit dum_info $m3 $w, vce(cluster kab_id)
				di as text "S2: INFO-M3"
				fitstat
			qui logit dum_info $m4 $w, vce(cluster kab_id)
				di as text "S2: INFO-M4"
				fitstat
				
				
			//S3
			qui logit dum_comm $m1 $w, vce(cluster kab_id)
				di as text "S3: COMM-M1"
				fitstat //poorfit
			qui logit dum_comm $m2 $w, vce(cluster kab_id)
				di as text "S3: COMM-M2"
				fitstat
			qui logit dum_comm $m3 $w, vce(cluster kab_id)
				di as text "S3: comm-M3"
				fitstat
			qui logit dum_comm $m4 $w, vce(cluster kab_id)
				di as text "S3: COMM-M4"
				fitstat
				
			//S4
			qui logit dum_content $m1 $w, vce(cluster kab_id)
				di as text "S4: CONTENT-M1"
				fitstat //poorfit
			qui logit dum_content $m2 $w, vce(cluster kab_id)
				di as text "S4: CONTENT-M2"
				fitstat
			qui logit dum_content $m3 $w, vce(cluster kab_id)
				di as text "S4: CONTENT-M2"
				fitstat
			qui logit dum_content $m4
				di as text "S4: CONTENT-M4"
				fitstat
				
			//S5
			qui logit dum_security $m1 $w, vce(cluster kab_id)
				di as text "S5: SECURITY-M1"
				fitstat //poorfit
			qui logit dum_security $m2 $w, vce(cluster kab_id)
				di as text "S5: SECURITY-M2"
				fitstat
			qui logit dum_security $m3 $w, vce(cluster kab_id)
				di as text "S5: SECURITY-M3"
				fitstat
			qui logit dum_security $m4 $w, vce(cluster kab_id)
				di as text "S5: SECURITY-M4"
				fitstat
				
			//S6
			qui logit dum_problem $m1 $w, vce(cluster kab_id)
				di as text "S6: PROBLEM-M1"
				fitstat //poorfit
			qui logit dum_problem $m2 $w, vce(cluster kab_id)
				di as text "S6: PROBLEM-M2"
				fitstat
			qui logit dum_problem $m3 $w, vce(cluster kab_id)
				di as text "S6: PROBLEM-M3"
				fitstat
			qui logit dum_problem $m4 $w, vce(cluster kab_id)
				di as text "S6: PROBLEM-M4"
				fitstat
		
	
		*======*=================================*
			
		
	*3.1.2 Sensitivity check on different model specifications for logit estimations
	/*Note: This section run sensitivity check on logit estimations by running 	different set of model specifications. We ran 4 different models from less to more control variables included in the models. The tests show the final model (Model 4) shows consistent results.
	
	*The results are reported in TABLE 1A & TABLE 1B, Appendices section "Robustness check" */
	
	foreach skill in "ictdev" "info" "comm" "content" "security" "problem" {
	
	//Run logit for s1
		//Model 1 (m1)
		eststo mdum_`skill': logit dum_`skill' $connect $w, vce(cluster kab_id)
			outreg2 using "${check}/logitcoef_`skill'.xls", replace //saving result
		
		//Model 2 (m2)
		eststo mdum_`skill': logit dum_`skill' $connect $softskills $w, vce(cluster kab_id)
			outreg2 using "${check}/logitcoef_`skill'.xls", append //saving result
			
		//Model 3 (m3)
		eststo mdum_`skill': logit dum_`skill' $connect $softskills $demographic $w, vce(cluster kab_id)
			outreg2 using "${check}/logitcoef_`skill'.xls", append //saving result
		
		//Model 4 (m4)
		eststo mdum_`skill': logit dum_`skill' $connect $softskills $demographic $geo $w, vce(cluster kab_id)
			outreg2 using "${check}/logitcoef_`skill'.xls", append //saving result
	
	}


/* 3.2  Run robustness for MULTINOMINAL LOGIT model (RQ2: skill proficiency determinant)
* References: https://statsapplied.com/part-ii-regression-analysis/multinomial-regression/model-diagnostics-multinomial-regr/assess-model-fit/
* Test: (1) model fit using FITSTAT
* Output: Table 3 & 4, Robustness check section in Appendices  */

	*3.2.1. Run FITSTAT for MNL
	
	/* FITSTAT (AIC, BIC, model-fit)
	Note: post-estimation comman computes measure of fit for logit, mlogit, ologit, etc.
	References: J. Scott Long & Jeremy Freese. 2014.  Regression Models for Categorical Dependent Variables Using Stata
	*ssc install fitstat, replace */
		
		//Running FITSTAT for each six component of skill
		
		gl mnlspec $connect $softsksills male working educ_year b6.agegroup i.quintile b7.island_region
		
		*S1
		qui mlogit skill_ictdev $mnlspec $w, vce(cluster kab_id)
				fitstat //moderate fit for s1
		*S2
		qui	mlogit skill_info $mnlspec $w, vce(cluster kab_id)
				fitstat //moderate fit for s2
		
		*S3
		qui	mlogit skill_comm $mnlspec $w, vce(cluster kab_id)
				fitstat //moderate fit for s3
					
		*s4
		qui mlogit skill_content $connect $softsksills male working educ_year i.quintile 			b7.island_region $w, ///
				vce(cluster kab_id) //this is the only spec that converged
				di as text "S4"
				fitstat //poor fit, low r-squared, poor fit	
			
		*S5
		qui mlogit skill_security $connect $softsksills male working educ_year i.quintile 			b7.island_region $w, ///
				vce(cluster kab_id) //this is the only spec that converged
				di as text "S5"
				fitstat //moderate fit
				
		*s6
		qui mlogit skill_problem $connect $softsksills male working educ_year i.			quintile b7.island_region $w, ///
				vce(cluster kab_id) //this is the only spec that converged
				di as text "S6"
				fitstat //moderate fit
				


			


