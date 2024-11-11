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
	
	***INSTALL REGSAVE
	*Note: Comment out if already installed.
	ssc install regsave, replace
	
	
	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear
	
			
	***CONFIDENCE LEVEL
	set level 95
	global conf unadj
		
		
	***RENAME KEY INDEPENDENT VARIABLES
	rename incarc_cat cat
	

	***COVARIATE GLOBALS
	global covars_all age i.partner hhsize i.hhchild i.female i.raceth_black i.raceth_hisp i.raceth_other income i.workstat i.educ4_lesshs i.educ4_hs i.educ4_somecoll i.region4_ne i.region4_w i.region4_s i.metro 
	
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
		
		
	log using "$folder\main-scales.log", replace
			
	local replace "replace"

	foreach v in trust civic comm{
					
			*************************
			***MODEL 1: UNADJUSTED***
			*************************

			svyset [pweight=weight2]
				
			display "MODEL 1: `v', unadjusted"
					
			svy, subpop(if subpop_analysis==1): glm $`v' i.cat 
					
			regsave 1.cat 2.cat 3.cat using "$folder\main-scales", ci addlabel(inctype, "cat", questiontype, "`v'", model, "unadj") `replace'
			local replace "append"


			***************************
			***MODEL 2: DEMOGRAPHICS***
			***************************
			
			svyset [pweight=weight2]
			
			display "MODEL 2: `v', adjusted"
					
			svy, subpop(if subpop_analysis==1): glm $`v' i.cat $covars_socdem
					
			regsave 1.cat 2.cat 3.cat using "$folder\main-scales", ci addlabel(inctype, "cat", questiontype, "`v'", model, "covars_socdem") `replace' 
			local replace "append"
			

			***************************************************
			***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
			***************************************************
			
			svyset [pweight=weight2]
			
			display "MODEL 3: `v', adjusted"
					
			svy, subpop(if subpop_analysis==1): glm $`v' i.cat $covars_socdem $covars_timevar
					
			regsave 1.cat 2.cat 3.cat using "$folder\main-scales", ci addlabel(inctype, "cat", questiontype, "`v'", model, "covars_all") `replace'
			local replace "append"
	}

	log close


*
**
***
**
*


*************************************************************
***ITEMS: TRUST, CIVIC PARTICIPATION, COMMUNITY ENGAGEMENT***
*************************************************************
			
	***OUTCOME VARIABLE GLOBALS
	
		**CIVIC/COMMUNITY ENGAGEMENT
		global civic civic_rally civic_contactgov civic_camppres civic_donatepres civic_donatepol civic_commprob civic_commboard civic_lettertoed civic_internet 
		
		**COMMUNITY ENGAGEMENT
		global comm comm_pta comm_group comm_blood comm_charity comm_vol 
		
		**TRUST IN THE STATE
		global govt trust_local trust_state trust_fed
		global trust police_trust cj_conf 
		
		
	log using "$folder\main-items.log", replace
	
	
	local replace "replace"
	

		******************************************
		***TRUST IN GOVERNMENT: LOCAL/STATE/FED***
		******************************************
			
			***************************************************
			***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
			***************************************************

			svyset [pweight=weight2]	
				
			foreach t in $govt{
				
				display "MODEL 3: trust, adjusted"
					
				svy, subpop(if subpop_analysis==1):  ologit `t' i.cat $covars_socdem $covars_timevar, or
					
				regsave 1.cat 2.cat 3.cat using "$folder\main-items", ci addlabel(inctype, "cat", questiontype, "trust", item, "`t'", model, "covars_all") `replace'
				local replace "append"
			}

		
		********************************************** 
		***TRUST IN STATE: CRIMINAL JUSTICE, POLICE***
		**********************************************
	
			***************************************************
			***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
			***************************************************

				***APPLY SURVEY WEIGHTS
				*Note: All civic/community engagement and own CJ contact measures are in full survey, so weight2 applies.
				svyset [pweight=weight2]	
				

				***REGRESSION MODELS
				display "MODEL 3: police_trust, adjusted"
					
				svy, subpop(if subpop_analysis==1): ologit police_trust i.cat $covars_socdem $covars_timevar, or
				
				regsave 1.cat 2.cat 3.cat using "$folder\main-items", ci addlabel(inctype, "cat", questiontype, "trust", item, "police_trust", model, "covars_all") `replace'
				local replace "append"
			
				display "MODEL 3: cj_conf, adjusted"
					
				svy, subpop(if subpop_analysis==1): ologit cj_conf i.cat $covars_socdem $covars_timevar, or
				
				regsave 1.cat 2.cat 3.cat using "$folder\main-items", ci addlabel(inctype, "cat", questiontype, "trust", item, "cj_conf", model, "covars_all") `replace'
				local replace "append"
	
	
		*************************
		***CIVIC PARTICIPATION***
		*************************
		

			***************************************************
			***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
			***************************************************

			svyset [pweight=weight2]	
				
			foreach t in $civic{
				
				display "MODEL 3: civic, adjusted"
					
				svy, subpop(if subpop_analysis==1): logistic `t' i.cat $covars_socdem $covars_timevar, or
					
				regsave 1.cat 2.cat 3.cat using "$folder\main-items", ci addlabel(inctype, "cat", questiontype, "civic", item, "`t'", model, "covars_all") `replace'
				local replace "append"
			}
			
			
		**************************
		***COMMUNITY ENGAGEMENT***
		**************************

			***************************************************
			***MODEL 3: DEMOGRAPHICS + TIME-VARYING MEASURES***
			***************************************************

			svyset [pweight=weight2]	
				
			foreach t in $comm{
				
				display "MODEL 3: comm, adjusted"

				regsave 1.cat 2.cat 3.cat using "$folder\main-items", ci addlabel(inctype, "cat", questiontype, "comm", item, "`t'", model, "covars_all") `replace'
				local replace "append"		
			}
			

	log close
