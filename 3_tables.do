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


Note: This program produces output/conducts descriptive analysis for generation of sample descriptive tables for the manuscript. 
*/


***********
***SETUP***
***********

	
	***IMPORT DATA
	use "$folder\famhis_recode_cem.dta", clear
	

	***GLOBALS FOR OUTCOME MEASURES
		
			**Community Engagement
			global comm comm_pta comm_group comm_blood comm_charity comm_vol 
			
			**Civic Participation
			/*Note: q41_4b and q41_11b (political campaign and elected to office) were not used in these analyses as an insufficient amount of variation within each item made models inestimable. To keep the main models and item-specific and stratified models comparable, we elected to exclude these rather than to only include them in specific analyses. */
			global civic civic_rally civic_contactgov civic_camppres civic_donatepres civic_donatepol civic_commprob civic_commboard civic_lettertoed civic_internet civic_camppres 
			
			**Trust in Government
			global govt trust_local trust_state trust_fed
			
			**Trust in Criminal Justice/Police
			global crim cj_conf police_trust
			
		
log using "$folder\table1.log", replace 

************************************************
***TABLE 1: DESCRIPTION OF FULL FAMHIS SAMPLE***
************************************************

	***APPLY SURVEY WEIGHTS
	*Note: All civic/community engagement and own CJ contact measures are in full survey, so weight2 applies.
	svyset [pweight=weight1]
	
	
	***INCARCERATION TYPE	
	
		**SAMPLE SIZE
		count 
		
		**OWN VS. IMMEDIATE FAMILY INCARCERATION 
		tab own_incarc famincarc_imm 
		svy: tab own_incarc famincarc_imm
				
		
	***FULL FAMHIS SAMPLE (N=4,041)
			
		**FEMALE (SEX/GENDER)
		svy: tab female, ci
		
		**AGE
		quietly svy: mean age
		estat sd
		svy: tab age6, ci	
		
		***RACE/ETHNICITY
		svy: tab raceth, ci
		
		***EDUCATIONAL ATTAINMENT
		svy: tab educ4, ci
		
		***PARTNERSHIP STATUS/HISTORY
		svy: tab partner, ci
		
		***HOUSEHOLD SIZE
		quietly svy: mean hhsize
		estat sd
		
		***PRESENCE OF CHILDREN IN HOUSEHOLD
		svy: tab hhchild, ci
			
		***INCOME QUINTILE
		svy: tab incomequint, ci
			
		***EMPLOYMENT STATUS
		svy: tab workstat, ci
		
		***METROPOLITAN STATUS
		svy: tab metro, ci
			
		***REGION
		svy: tab region4, ci
		
		***RELIGIOSITY
		svy: tab relig5, ci
		
		***POLITICAL IDEOLOGY
		svy: tab polideo, ci
		quietly svy: mean polideo
		estat sd
		
		***POLITICAL PARTY
		svy: tab polparty, ci 
		
		
		
*********************************************
***TABLE 1: DESCRIPTION OF ANALYTIC SAMPLE***
*********************************************
/*Note: See famhis_civic_analyticplan.doc for details on table and figure progression. 
(1) Full analytic sample
(2) Own incarceration
(3) Immediate family incarceration 
(4) Categorical descriptor of incarceration: neither, own only, immediate family only, both */

	
	***APPLY SURVEY WEIGHTS
	*Note: All civic/community engagement and own CJ contact measures are in full survey, so weight2 applies.
	svyset [weight=weight2]
	
	
	***INCARCERATION TYPE	
	global fullsample "if sample_all==1"
	
		**SAMPLE SIZE
		count $fullsample
		
		**OWN VS. IMMEDIATE FAMILY INCARCERATION 
		tab own_incarc famincarc_imm if sample_all==1
		svy, subpop($fullsample): tab own_incarc famincarc_imm
				
		
	***FULL ANALYTIC SAMPLE (N=2,073)
	global fullsample "if sample_all==1"
			
		**FEMALE (SEX/GENDER)
		svy, subpop($fullsample): tab female, ci
		
		**AGE
		quietly svy, subpop($fullsample): mean age
		estat sd
		svy, subpop($fullsample): tab age6, ci	
		
		***RACE/ETHNICITY
		svy, subpop($fullsample): tab raceth, ci
		
		***EDUCATIONAL ATTAINMENT
		svy, subpop($fullsample): tab educ4, ci
		
		***PARTNERSHIP STATUS/HISTORY
		svy, subpop($fullsample): tab partner, ci
		
		***HOUSEHOLD SIZE
		quietly svy, subpop($fullsample): mean hhsize
		estat sd
		
		***PRESENCE OF CHILDREN IN HOUSEHOLD
		svy, subpop($fullsample): tab hhchild, ci
			
		***INCOME QUINTILE
		svy, subpop($fullsample): tab incomequint, ci
			
		***EMPLOYMENT STATUS
		svy, subpop($fullsample): tab workstat, ci
		
		***METROPOLITAN STATUS
		svy, subpop($fullsample): tab metro, ci
			
		***REGION
		svy, subpop($fullsample): tab region4, ci
		
		***RELIGIOSITY
		svy, subpop($fullsample): tab relig5, ci
		
		***POLITICAL IDEOLOGY
		svy, subpop($fullsample): tab polideo, ci
		quietly svy, subpop($fullsample): mean polideo
		estat sd
		
		***POLITICAL PARTY
		svy, subpop($fullsample): tab polparty, ci 
		
		
	***BY OWN/IMMEDIATE FAMILY INCARCERATION (CATEGORICAL/COMBINED MEASURE)
	*Note: Comparison groups are: (1) neither, (2) only own, (3) only immediate family, (4) both
	global fullsample "if sample_all==1"
	
		***SAMPLE SIZE
		tab incarc_cat $fullsample
				
		***FEMALE (SEX/GENDER)
		svy, subpop($fullsample): tab female incarc_cat, col ci 
		
		***AGE
		quietly svy, subpop($fullsample): mean age, over(incarc_cat) 
		estat sd
		svy, subpop($fullsample): tab age6 incarc_cat, col ci 
		
		***RACE/ETHNICITY
		svy, subpop($fullsample): tab raceth incarc_cat, col ci 
		
		***EDUCATIONAL ATTAINMENT
		svy, subpop($fullsample): tab educ4 incarc_cat, col ci 
		
		***PARTNERSHIP STATUS/HISTORY
		svy, subpop($fullsample): tab partner incarc_cat, col ci 
		
		***HOUSEHOLD SIZE
		quietly svy, subpop($fullsample): mean hhsize, over(incarc_cat)  
		estat sd
		
		***PRESENCE OF CHILDREN IN HOUSEHOLD
		svy, subpop($fullsample): tab hhchild incarc_cat, col ci 
		
		***INCOME QUINTILE
		svy, subpop($fullsample): tab incomequint incarc_cat, col ci 
		
		***EMPLOYMENT STATUS
		svy, subpop($fullsample): tab workstat incarc_cat, col ci
		
		***METROPOLITAN STATUS
		svy, subpop($fullsample): tab metro incarc_cat, col ci
		
		***REGION
		svy, subpop($fullsample): tab region4 incarc_cat, col ci
		
		***RELIGIOSITY
		svy, subpop($fullsample): tab relig5 incarc_cat, col ci
		
		***POLITICAL IDEOLOGY
		svy, subpop($incarc_none): tab polideo incarc_cat, col ci 
		quietly svy, subpop($fullsample): mean polideo, over(incarc_cat) 
		estat sd
		
		***POLITICAL PARTY
		svy, subpop($fullsample): tab polparty incarc_cat, col ci
		
		
log close 

*
**
***
**
*
		
log using "$folder\table2.log", replace
			
	
*******************************************************************************************************
***TABLE 2: DESCRIPTIVES, MEASURES OF CIVIC PARTICIPATION, COMMUNITY ENGAGEMENT, TRUST IN GOVERNMENT***
*******************************************************************************************************
		
	***APPLY SURVEY WEIGHTS
	*Note: All civic/community engagement and own CJ contact measures are in full survey, so weight2 applies.
	svyset [pweight=weight2]
			
			
	***FULL ANALYTIC SAMPLE
	global fullsample "if sample_all==1"
				
		**TRUST IN STATE
		foreach v in $govt $crim{
			display "`v'"
			quietly svy, subpop($fullsample): mean `v'
			estat sd
		}
		
		**COMMUNITY ENGAGEMENT
		foreach v in $comm{
			display "`v'"
			svy, subpop($fullsample): tab `v', ci
		}
		
		**CIVIC PARTICIPATION
		foreach v in $civic{
			display "`v'"
			svy, subpop($fullsample): tab `v', ci
		}
						
		**SCALES

			**Trust in State
			svy, subpop($fullsample): mean scale_trust
			estat sd
			alpha $crim $govt $fullsample
			
			svy, subpop($fullsample): mean stdscale_trust 
			estat sd
			alpha $crim $govt $fullsample, std
			
			**Community Engagement
			svy, subpop($fullsample): mean scale_comm
			estat sd
			alpha $comm $fullsample
			
			svy, subpop($fullsample): mean stdscale_comm 
			estat sd
			alpha $comm $fullsample, std
					
			**Civic Participation
			svy, subpop($fullsample): mean scale_civic
			estat sd
			alpha $civic $fullsample
			
			svy, subpop($fullsample): mean stdscale_civic 
			estat sd
			alpha $civic $fullsample, std
	
							
	***BY OWN/IMMEDIATE FAMILY INCARCERATION (CATEGORICAL/COMBINED MEASURE)
	global fullsample "if sample_all==1"
	
		**TRUST IN STATE
		foreach v in $govt $crim{
			display "`v'"
			quietly svy, subpop($fullsample): mean `v', over(incarc_cat)
			estat sd
		}
		
		**COMMUNITY ENGAGEMENT
		foreach v in $comm{
			display "`v'"
			svy, subpop($fullsample): tab `v' incarc_cat, col ci
		}
		
		**CIVIC PARTICIPATION
		foreach v in $civic{
			display "`v'"
			svy, subpop($fullsample): tab `v' incarc_cat, col ci 
		}				
			
		***SCALES
		forvalues g=0(1)3{
		
		global fullsample "if sample_all==1 & incarc_cat==`g'"
		
		display "incarc_cat==`g'"
			
			**Trust in State
			svy, subpop($fullsample): mean scale_trust, over(incarc_cat)
			estat sd
			alpha $crim $govt $fullsample
						
			**Community Engagement
			svy, subpop($fullsample): mean scale_comm, over(incarc_cat)
			estat sd
			alpha $comm $fullsample
			
			**Civic Participation
			svy, subpop($fullsample): mean scale_civic, over(incarc_cat)
			estat sd
			alpha $civic $fullsample
			
		}			
			
log close 
