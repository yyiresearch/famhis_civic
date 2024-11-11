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

Note: This program conducts a descriptive analysis of survey experiment data collected
in partnership with Verasight. This supplementary analyses examines the effects of
survey question wording on estimated prevalence of family incarceration. The data for this analysis 
are available upon request.*/

*/


***********
***SETUP***
***********

	***INSTALL TABOUT
	*Note: Comment out if already installed.
	ssc install tabout
	

	***IMPORT VERASIGHT SURVEY EXPERIMENT DATA
	*Note: Data available upon request.
	use "$folder\verasight_raw.dta", clear 
		
		
	
************
***RECODE***
************

	***LABEL TREATMENTS
	clonevar treat_lab=treat
	label values treat_lab
	tostring treat_lab, replace
	
	replace treat_lab="original" if treat_lab=="1"
	replace treat_lab="jail/prison, no time" if treat_lab=="2"
	replace treat_lab="jail, no time" if treat_lab=="3"
	replace treat_lab="prison, no time" if treat_lab=="4"
	replace treat_lab="no s/f/a" if treat_lab=="5"
	replace treat_lab="jail/prison, no s/f/a, no time" if treat_lab=="6"
	replace treat_lab="jail, no s/f/a, no time" if treat_lab=="7"
	replace treat_lab="prison, no s/f/a, no time" if treat_lab=="8"
	replace treat_lab="jail/prison, immfam" if treat_lab=="9"
	replace treat_lab="jail/prison, immfam, no time" if treat_lab=="10"
	replace treat_lab="jail, immfam no time" if treat_lab=="11"
	replace treat_lab="prison, immfam no time" if treat_lab=="12"
	
	
	***RECODE RESPONSE OPTIONS
	recode q2 (1=0 "No") (2=1 "Yes"), gen(prev)
	
	
	***SUBPOPULATION FLAG
	generate subpop_analysis=1 if q1!=. & q2!=. & q3!=. & q4!=. & q5!=. & q6!=.
	
		

log using "$folder\3_experiment.log", replace

*****************************
***DESCRIPTIVE TABULATIONS***
*****************************

	***SURVEY SET
	svyset [weight=weight]
	
	
	***IMMEDIATE FAMILY INCARCERATION, OVERALL
	*Note:
	
		**WEIGHTED
		svy: tab q2, ci	
		
		**UNWEIGHTED
		tab q2
		
		
	***IMMEDIATE FAMILY INCARCERATION, BY TREATMENT
	
		**WEIGHTED
		svy: tab treat_lab prev, row ci
		tabout treat_lab prev using "$folder\experiment_prev.csv", svy cells(row lb ub) f(4) style(csv) replace
		
		
		**UNWEIGHTED
		tab treat_lab q2, row
	

log close 
