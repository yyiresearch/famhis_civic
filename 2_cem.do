**SETTINGS
*Note: Modify settings as desired.

clear all
capture log close
clear matrix
clear mata
set linesize 160
set maxvar 32767
set more off


log using "$folder\2_cem.log", replace 

/*Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation

Programming Code Information:
Yi, Youngmin.
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436

Note: This program sets up a Coarsened Exact Matching (cem) procedure (Blackwell et al. 2009) 
for supplementary analyses.
*/


***********
***SETUP***
***********
	
	***INSTALL CEM
	*Note: Comment out if already installed.
	net from https://www.mattblackwell.org/files/stata
	net install cem, replace
	
	
	***IMPORT DATA
	use "$folder\famhis_recode.dta", clear
			
		
	***BONFERRONI ADJUSTMENT
	
		**BONFERRONI-ADJUSTED INTERVALS
		set level 99.93 // 0.05/(19*4), 19 responses with 4 models each
		global conf bonfadj
	
		**UNADJUSTED INTERVALS 
		set level 95
		global conf unadj
	
	
	***OUTCOME VARIABLES (SCALES)
	
		**CIVIC PARTICIPATION
		global civic stdscale_civic
		
		**COMMUNITY ENGAGEMENT
		global comm stdscale_comm
		
		**CRIMINAL JUSTICE SYSTEM
		global govt stdscale_trust
		
	

****************
***DIAGNOSTIC***
****************

	***BALANCE TESTS, ANY
	
		**OWN INCARCERATION
		imb age7 partner hhsize hhchild female raceth incomequint workstat educ4 region4 metro famincarc_imm if subpop_analysis==1, treatment(own_incarc)
		
		**IMMEDIATE FAMILY INCARCERATION
		imb age7 partner hhsize hhchild female raceth incomequint workstat educ4 region4 metro own_incarc if subpop_analysis==1, treatment(famincarc_imm)
		
	

******************************
***COARSENED EXACT MATCHING***
******************************

	***CEM VARIABLES GLOBAL
	global cemvars cem_strata cem_weights cem_matched 

	
	***CEM MATCHING PROCEDURE

		**OWN INCARCERATION
		cem age (30, 40, 55, 65) partner (0 1) hhsize (1 2 3 4 5) hhchild (0 1) female (0 1) raceth (1 2 3 4) income (1 6 10 12 14) workstat(0 1 2) educ4 (1 2 3 4) region4 (1 2 3 4) metro (0 1) famincarc_imm (0 1) if subpop_analysis==1, treatment(own_incarc)

		foreach v in $cemvars{
			rename `v' `v'_own
		}		

		**IMMEDIATE FAMILY INCARCERATION
		cem age (30, 40, 55, 65) partner (0 1) hhsize (1 2 3 4 5) hhchild (0 1) female (0 1) raceth (1 2 3 4) income (1 6 10 12 14) workstat (0 1 2) educ4 (1 2 3 4) region4 (1 2 3 4) metro (0 1) own_incarc (0 1) if subpop_analysis==1, treatment(famincarc_imm)

		foreach v in $cemvars{
			rename `v' `v'_immfam
		}		
	

	***SCALE SURVEY WEIGHTS
	/*Note: All civic/community engagement and own CJ contact measures are in full survey, so weight2 applies.
	It needs to be adjusted using the CEM weights. */
	foreach s in own immfam { // own_cons year_restrict ownyear_restrict
	
		generate weight_cem_`s'=weight2*cem_weights_`s'
	}

	

**********
***SAVE***
**********
save "$folder\famhis_recode_cem.dta", replace

keep if sample_all==1
export delimited using "$folder\famhis_recode_cem.csv", replace


log close