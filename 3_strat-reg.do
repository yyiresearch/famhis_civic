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

Note: This program conducts stratified analyses of own and family inarceration and all outcome measures as scales and item-specific models. This is based on 3_famhis_civic_analysis_ss.do.
*/


*log using "$folder\3_strat-raceth.log", replace // uncomment to log

**********************************************************************************************
***STANDARDIZED SCALES, BY RACE/ETHNICITY: TRUST, CIVIC PARTICIPATION, COMMUNITY ENGAGEMENT***
**********************************************************************************************
*Note: The scale_trust variable has a roughly normal distribution, so using linear regression model. 

	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear

		
	***RENAME KEY INDEPENDENT VARIABLES
	rename incarc_cat cat
	
	
	***OUTCOME VARIABLES
	
		**CIVIC PARTICIPATION
		global civic stdscale_civic
		
		**COMMUNITY ENGAGEMENT
		global comm stdscale_comm
		
		**CRIMINAL JUSTICE SYSTEM
		global trust stdscale_trust
	

	***COVARIATE GLOBALS
	global covars_all age i.partner hhsize i.hhchild i.female income i.workstat i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.region4_ne i.region4_w i.region4_s i.metro 
	global covars_socdem age i.partner hhsize i.hhchild i.female i.region4_ne i.region4_w i.region4_s i.metro 
	global covars_timevar income i.workstat i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.workstat


	
	********************************************************
	***MODEL: BY RACE/ETHNICITY + ADDITIONAL DEMOGRAPHICS***
	********************************************************
			
			
	local replace "replace"
			
	foreach c in uncorrected bonf{
	    
	**UNCORRECTED
	if "`c'"=="uncorrected"{
	    set level 95
	}
		
	**CORRECTED
	if "`c'"=="bonf"{
	    set level 98.75
	}
		
	global conf `c'

		foreach v in trust civic comm{
				
			foreach r in white black hisp other{
					
				svyset [pweight=weight2]
							
				display "MODEL: `v', model covars_all, by raceth"
			
				svy, subpop(if subpop_analysis==1 & raceth_`r'==1): glm $`v' i.cat $covars_all
					
				regsave 1.cat 2.cat 3.cat using "$folder\strat-raceth", ci addlabel(inctype, "cat", questiontype, "`v'", raceth, "`r'", model, "covars_all", conf, "`c'") `replace'
				local replace "append"
			
			}	
		}
	}

log close 
	

log using "$folder\3_strat-famtype.log", replace 
	
**************************************************************************************************
***STANDARDIZED SCALES, BY FAMILY MEMBER TYPE: TRUST, CIVIC PARTICIPATION, COMMUNITY ENGAGEMENT***
**************************************************************************************************
*Note: The scale_trust variable has a roughly normal distribution, so using linear regression model. 
	
	
	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear
		
		
	***RENAME KEY INDEPENDENT VARIABLES
	foreach m in spouse parent child sib{
		replace famincarc_`m'=. if own_incarc==1
	}
	
	
	***OUTCOME VARIABLES
	
		**CIVIC PARTICIPATION
		global civic stdscale_civic
		
		**COMMUNITY ENGAGEMENT
		global comm stdscale_comm
		
		**CRIMINAL JUSTICE SYSTEM
		global trust stdscale_trust
	

	***COVARIATE GLOBALS
	global covars_all age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other income i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.region4_ne i.region4_w i.metro i.workstat	
	global covars_socdem age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other i.region4_ne i.region4_w i.metro 	
	global covars_timevar income i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.workstat 
			
	
	************************************************************
	***MODEL: BY FAMILY MEMBER TYPE + ADDITIONAL DEMOGRAPHICS***
	************************************************************
			
	local replace "replace"
		
	foreach c in uncorrected bonf{
	    
	**UNCORRECTED
	if "`c'"=="uncorrected"{
	    set level 95
	}
		
	**CORRECTED
	if "`c'"=="bonf"{
	    set level 98.75
	}
		
	global conf `c'

		foreach v in trust civic comm{
			
			foreach f in spouse parent child sib{

				svyset [pweight=weight2]
							
				display "MODEL: `v', model covars_all, by famtype"
				
				svy, subpop(if subpop_analysis==1): glm $`v' i.famincarc_`f' $covars_all
						
				regsave 1.famincarc_`f' using "$folder\strat-famtype", ci addlabel(questiontype, "`v'", famtype, "`f'", model, "covars_all", conf, "`c'") `replace'
				local replace "append"
			}	
		}
	}
	
log close 
	
	