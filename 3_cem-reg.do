**SETTINGS
*Note: Modify settings as desired.

clear all
capture log close
clear matrix
clear mata
set linesize 160
set maxvar 32767
set more off


/*Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation

Programming Code Information:
Yi, Youngmin.
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436

Note: This program conducts regression (non-matched and matched) analyses of the 
relationships between family incarceration and all outcome measures *scales* and 
creates output files for data visualization. 
*/

***********
***SETUP***
***********
	
	***INSTALL REVRS
	ssc install revrs, replace
	
	
	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear
			
			
	***CONFIDENCE LEVEL
	set level 95
	global conf unadj
		
		
	***RENAME KEY INDEPENDENT VARIABLES
	rename famincarc_imm immfam
	rename own_incarc own
	

	***COVARIATE GLOBALS
	global covars age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other income i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.region4_ne i.region4_w i.region4_s i.metro i.workstat
	global covars_cem age income
	

*
**
***
**
*

log using "$folder\3_cem-reg.log", replace

***************************************************************************
***STANDARDIZED SCALES: TRUST, CIVIC PARTICIPATION, COMMUNITY ENGAGEMENT***
***************************************************************************
*Note: The scale_trust variable has a roughly normal distribution, so using linear regression model. 
	
	***OUTCOME VARIABLES
	
		**CIVIC PARTICIPATION
		global civic stdscale_civic
		
		**COMMUNITY ENGAGEMENT
		global comm stdscale_comm
		
		**CRIMINAL JUSTICE SYSTEM
		global trust stdscale_trust
		
			
	local replace "replace"

	foreach v in trust civic comm{

		foreach i in immfam own{ 

			**************************************************************
			***MODEL: COARSENED EXACT MATCHED + ADDITIONAL DEMOGRAPHICS***
			**************************************************************
			
			svyset [iweight=cem_weights_`i']
			
			display "MODEL 3: `v', adjusted"
					
			svy, subpop(if subpop_analysis==1): glm $`v' i.`i' $covars_cem
					
			regsave 1.`i' using "$folder\cem", ci addlabel(inctype, "`i'", questiontype, "`v'", model, "cem") `replace'
			local replace "append"
				
		}
	}

log close 



***********************
***MODIFY DATA FILES***
***********************

	***STANDARDIZED SCALE MODEL RESULTS
		
	use $folder\cem.dta, clear
	
		encode inctype, generate(inctype_order)
		revrs inctype_order, replace
		label values inctype_order .		
				
		encode inctype, generate(inctype2)
		revrs inctype2, replace
		drop inctype
		rename inctype2 inctype
				
		label drop inctype2
		label define inctype 1 "own" 2 "immfam"
		label values inctype inctype
		
		drop var 
		
	export delimited using "$folder\cem.csv", replace
