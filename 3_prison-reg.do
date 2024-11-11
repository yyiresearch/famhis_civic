**SETTINGS
*Note: Modify settings as desired.

clear all
capture log close
clear matrix
clear mata
set linesize 160
set maxvar 32767
set more off

*log using "$folder\3_prison-reglog", replace // uncomment to log

/*Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation

Programming Code Information:
Yi, Youngmin.
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436

Note: This is for supplementary analysis of incarceration spells of more than a year in duration.
*/


***********
***SETUP***
***********
	
	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear
			
			
	***CONFIDENCE LEVEL
	set level 95
	global conf unadj
		
		
	***RENAME KEY INDEPENDENT VARIABLES
	rename yown_incarc_long own_prison
	rename yfamincarc_imm_longest immfam_prison
	
	generate both_prison=1 if own_prison==1 & immfam_prison==1
	replace both_prison=0 if both_prison!=1
	
	generate cat_prison=.
	replace cat_prison=0 if own_prison==0 & immfam_prison==0
	replace cat_prison=1 if own_prison==1 & immfam_prison==0
	replace cat_prison=2 if own_prison==0 & immfam_prison==1
	replace cat_prison=3 if both_prison==1


	***COVARIATE GLOBALS
	global covars_all age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other income i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.workstat i.region4_ne i.region4_w i.region4_s i.metro 
	
	global covars_socdem age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other i.region4_ne i.region4_w i.region4_s i.metro 
	global covars_timevar income i.workstat i.educ4_lesshs i.educ4_hs i.educ4_somecoll 
		
	

*
**
***
**
*



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
	
		***************************************************
		***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
		***************************************************
			
		svyset [pweight=weight2]
			
		display "MODEL 3: `v', adjusted"
					
		svy, subpop(if subpop_analysis==1): glm $`v' i.cat_prison $covars_socdem $covars_timevar
					
		regsave 1.cat_prison 2.cat_prison 3.cat_prison using "$folder\prison", ci addlabel(inctype, "cat", questiontype, "`v'", model, "covars_all") `replace'
		local replace "append"
	}

*log close // uncomment to log
	

***********************
***MODIFY DATA FILES***
***********************

	***SCALES
	use "$folder\prison.dta", clear
	
	
		***FORMAT FOR PLOTTING
		rename var incarc_cat
		foreach i in "stdscale_trust" "stdscale_civic" "stdscale_comm"{
			replace incarc_cat="own" if incarc_cat=="`i':1.cat_prison"
			replace incarc_cat="immfam" if incarc_cat=="`i':2.cat_prison"
			replace incarc_cat="both" if incarc_cat=="`i':3.cat_prison"
		}
		
	export delimited using "$folder\prison.csv", replace

	
