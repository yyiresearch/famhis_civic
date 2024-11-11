**SETTINGS
*Note: Modify settings as desired.

clear all
capture log close
clear matrix
clear mata
set linesize 160
set maxvar 32767
set more off

*log using "$folder\4_reg-estimates.log", replace // uncomment to log

/*Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation

Programming Code Information:
Yi, Youngmin.
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436

Note: This program is a post-analysis file that is used to create a version of the
estimates/output CSV files that only uses estimates from the categorical operationalization
of incarceration exposure.
*/


***********
***SETUP***
***********

	***IMPORT ESTIMATES
	use "$folder\main-items.dta", clear // generated in 3_main-reg.do
	
	
	***RESTRICT TO CATEGORICAL MEASURE ONLY
	rename var incarc_cat
	keep if inctype=="cat"
	
	generate inctype_order=.
	replace inctype_order=1 if incarc_cat=="own"
	replace inctype_order=2 if incarc_cat=="immfam"
	replace inctype_order=3 if incarc_cat=="both"
	
	***FORMAT FOR PLOTTING
	levelsof item, local(items)
			
	foreach i in `items'{
		forvalues n=1(1)3{
			replace incarc_cat="`n'" if incarc_cat=="`i':`n'.cat"
		}
	}
	replace incarc_cat="own" if incarc_cat=="1"
	replace incarc_cat="immfam" if incarc_cat=="2"
	replace incarc_cat="both" if incarc_cat=="3"
	
	export delimited using "$folder\items.csv", replace
			
			

*******************************
***MAIN: STANDARDIZED SCALES***
*******************************

	***IMPORT ESTIMATES
	use "$folder\main-scales.dta", clear // generated in 3_main-reg_yi-enns-wildeman.do
	
	
	***RESTRICT TO CATEGORICAL MEASURE ONLY
	rename var incarc_cat
	keep if inctype=="cat"
	
	generate inctype_order=.
	replace inctype_order=1 if incarc_cat=="own"
	replace inctype_order=2 if incarc_cat=="immfam"
	replace inctype_order=3 if incarc_cat=="both"
	
	
	***FORMAT FOR PLOTTING
	foreach s in civic comm trust{
		forvalues n=1(1)3{
			replace incarc_cat="`n'" if incarc_cat=="stdscale_`s':`n'.cat"
		}
	}
	replace incarc_cat="own" if incarc_cat=="1"
	replace incarc_cat="immfam" if incarc_cat=="2"
	replace incarc_cat="both" if incarc_cat=="3"

	export delimited using "$folder\scales.csv", replace

	
	
**************************
***SUPP: RACE/ETHNICITY*** 
**************************

	***SCALES
	
		**IMPORT ESTIMATES
		use "$folder\strat-raceth.dta", clear
		
		**RESTRICT TO CATEGORICAL MEASURE ONLY
		keep if inctype=="cat"
		rename var incarc_cat
		
		generate inctype_order=.
		replace inctype_order=1 if incarc_cat=="own"
		replace inctype_order=2 if incarc_cat=="immfam"
		replace inctype_order=3 if incarc_cat=="both"
		
		**FORMAT FOR PLOTTING
		foreach i in "stdscale_trust" "stdscale_civic" "stdscale_comm"{
			forvalues n=1(1)3{
				replace incarc_cat="`n'" if incarc_cat=="`i':`n'.cat"
			}
		}
		replace incarc_cat="own" if incarc_cat=="1"
		replace incarc_cat="immfam" if incarc_cat=="2"
		replace incarc_cat="both" if incarc_cat=="3"
				
		tempfile scales_cat_raceth
		save `scales_cat_raceth'
				
		**FORMAT CONFIDENCE INTERVALS
		foreach c in uncorrected bonf{
			
			use if conf=="`c'" using `scales_cat_raceth', clear
			
			foreach v in stderr ci_lower ci_upper{
				rename `v' `v'_`c'
			}
			
			drop conf
			
			tempfile `c'
			save ``c''
		}
		
		merge 1:1 questiontype inctype incarc_cat raceth model using `uncorrected'	
		drop _merge	
			
		export delimited using "$folder\strat-raceth.csv", replace
		
	
***********************
***SUPP: FAMILY TYPE***
***********************
	
	***SCALES
	
		**IMPORT ESTIMATES
		use "$folder\strat-famtype.dta", clear
								
		**FORMAT CONFIDENCE INTERVALS
		drop var
				
		tempfile scales_famtype
		save `scales_famtype'
			
			foreach c in uncorrected bonf{
							
				use if conf=="`c'" using `scales_famtype', clear
					
				foreach v in stderr ci_lower ci_upper{	
					rename `v' `v'_`c'
				}
				drop conf
					
				tempfile `c'
				save ``c''
			}
		
		merge 1:1 questiontype famtype model using `uncorrected'	
		drop _merge	
			
		export delimited using "$folder\strat-famtype.csv", replace



***********************************
***SUPP: COARSENED EXACT MATCHED***
***********************************
	
	***SCALES
	
		**IMPORT ESTIMATES
		use "$folder\cem.dta", clear

		***FORMAT FOR PLOTTING
		rename var incarc_cat
			
		generate inctype_order=.
		replace inctype_order=1 if incarc_cat=="own"
		replace inctype_order=2 if incarc_cat=="immfam"
	
		replace incarc_cat="own" if inctype=="own"
		replace incarc_cat="immfam" if inctype=="immfam"
		
		export delimited using "$folder\cem.csv", replace
	