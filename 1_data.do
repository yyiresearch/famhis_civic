**SETTINGS
*Note: Modify settings as desired.

clear all
capture log close
clear matrix
clear mata
set linesize 160
set maxvar 32767
set more off


*log using "$folder\1_data.log", replace \\ uncomment to log

/*Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation

Programming Code Information:
Yi, Youngmin.
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436

Note: This program recodes the national FamHIS data for an analysis that provides
a more detailed look at the relationships between family incarceration and civic engagement. 
*/



**********
***DATA***
**********

	***IMPORT DATA
	/*Note: Family History of Incarceration Survey (FamHIS) data. See more information about these
	data at: https://ropercenter.cornell.edu/ipoll/study/31115615 */
	
	use famhis_raw.dta, clear
		
		

********************************
***RECODES: SOCIODEMOGRAPHICS***
********************************

	***RESPONDENT RACE/ETHNICITY
	recode s_raceth5 (2=1 "White, Non-Hispanic") (3=2 "Black, Non-Hispanic") (1=3 "Hispanic") (4/5=4 "Other, Non-Hispanic"), gen(raceth)
	
	recode raceth (1=1 "White") (2/4=0), gen(raceth_white)
	recode raceth (2=1 "Black") (1 3 4=0), gen(raceth_black)
	recode raceth (3=1 "Hispanic") (1 2 4=0), gen(raceth_hisp)
	recode raceth (4=1 "Other") (1/3=0), gen(raceth_other)
		
		
	***NATIVITY
	recode q44 (1=0 "Born in US") (2=1 "Born in other country") (98=.), gen(nativity)
	label var nativity "Country of Origin"
	
	
	***SEX
	recode gender (1=0 "Male") (2=1 "Female") (77 99=.), gen(female)
	
		
	***AGE (CATEGORICAL)
	recode age (18/29=1 "18-29 Years") (30/39=2 "30-39 Years") (40/49=3 "40-49 Years") (50/59=4 "50-59 Years") (60/69=5 "60-69 Years") (70/max=6 "70+ Years"), gen(age6)
	label var age6 "6-Category Age"
		
		
	***EDUCATIONAL ATTAINMENT (CATEGORICAL)
	*Just use "educ4" for now.
	recode educ4 (1=1 "< HS") (2/4=0), gen(educ4_lesshs)
	recode educ4 (2=1 "HS/GED") (1 3 4=0), gen(educ4_hs)
	recode educ4 (3=1 "Some College") (1 2 4=0), gen(educ4_somecoll)
	recode educ4 (4=1 "BA+") (1/3=0), gen(educ4_baplus)		
	
	
	***MARITAL STATUS
	recode marital (1=1 "Married") (2=2 "Widowed") (3/4=3 "Divorced/Separated") (5=4 "Never Married") (6=5 "Living w/Partner"), gen(marstat)
	label var marstat "Marital/Parternship Status"
	
	
	***EVER PARTNERED
	recode marital (1/4 6=1 "Ever or Currently Partnered") (5=0 "Never Married/Not Living with Partner"), gen(partner)
	label var partner "Partnership Status"
	
		
	***PARENTAL STATUS
	generate parent=.
	replace parent=1 if (q3_5>0 & q3_5<77) | (q3_6>0 & q3_6<77)
	replace parent=0 if q3_5==0 & q3_6==0
	label define parent 0 "Not a Parent" 1 "Parent"
	label values parent parent
	label var parent "Parent (>=1 Son/Daughter)"
	
	
	***LANGUAGE OF INTERVIEW
	recode surv_lang (1=0 "English") (2=1 "Spanish"), gen(lang_span)
	label var lang_span "Spanish Language Interview"
	
	recode surv_lang (2=0 "Spanish") (1=1 "English"), gen(english)
	label var english "English Language Interview"
		
	
	***INCOME
	recode income (1/5=1 "$0 to $24,999") (6/9=2 "$25,000 to $49,999") (10/11=3 "$50,000 to $74,999") (12/13=4 "$75,000 to $99,999")  (14/18=5 "$100,000+"), gen(incomequint)
	label var incomequint "Income Quintile (Sample Dist)"
		
	
	***CHILDREN PRESENT IN HOUSEHOLD
		
		**DICHOTOMOUS
		generate hhchild=.
		replace hhchild=1 if hh01>0 & hh01!=.
		replace hhchild=1 if hh25>0 & hh25!=.
		replace hhchild=1 if hh612>0 & hh612!=.
		replace hhchild=1 if hh1317>0 & hh1317!=.
		replace hhchild=0 if hhchild!=1 & (hh01!=. & hh25!=. & hh612!=. & hh1317!=.)
		
		**NUMBER (CONTINUOUS)
		egen hhchild_num=rowtotal(hh01 hh25 hh612 hh1317)
			
	
	***REGION
	*Note: Use region4 
	recode region4 (1=1 "Northeast") (2/4=0), gen(region4_ne)
	recode region4 (2=1 "Midwest") (1 3/4=0), gen(region4_mw)
	recode region4 (3=1 "South") (1 2 4=0), gen(region4_s)
	recode region4 (4=1 "West") (1/3=0), gen(region4_w)		
		
	
	***EMPLOYMENT STATUS 
	recode employ (3/4=1 "Underemployed") (5/7=2 "Non-LF: Retired/Disabled, Not Searching") (1/2=0 "Working"), gen(workstat)
	label var workstat "Working Status"
	
	
	**RELIGIOSITY
	recode relig1 (1=1 "Protestant") (2=2 "Catholic") (3=3 "Jewish") (4 6 7 8 12 13 14 = 4 "Other") (9 10 11 = 5 "No belief"), gen(relig5) 
	label var relig5 "Religiosity"
	
	
	***POLITICAL IDEOLOGY
	
		**DETAILED POLITICAL IDEOLOGY
		recode ideo (1=1 "Extremely Liberal") (2=2 "Liberal") (3=3 "Slightly Liberal") (4=4 "Moderate") (5=5 "Slightly Conservative") (6=6 "Conservative") (7=7 "Extremely Conservative") (77 8 =.), gen(polideo)
		label var polideo "Political Ideology"
			
		***POLITICAL PARTY
		recode partyid7 (-1=.) (1/2=1 "Democrat") (3/5=2 "Independent") (6/7=3 "Republican"), gen(polparty)
		label var polparty "Political Party Affiliation"
	
	
	***HOUSEHOLD SIZE
	*Note: Use hhsize
	
	***METRO
	*Note: Use metro
	
	
****************************************************		
***RECODES: IMMEDIATE FAMILY MEMBER INCARCERATION***
****************************************************		
*Note: Using Q4 survey items that go back through each immediate family member type to ask about incarceration.
label define incarc 0 "No" 1 "Yes"


	***ANY IMMEDIATE FAMILY (DICHOTOMOUS)
	/*Note: Only if reported a type of family member who was incarcerated (see Peter's email 
	that Chris forwarded on 9/26/2018). Discrepancy between this and "group" because "group" coded missing as 0s. */
	generate famincarc_imm=.
	replace famincarc_imm=0 if q2==2 | (q2==1 & dov_jail==0)
	replace famincarc_imm=1 if q2==1 & dov_jail!=0 & dov_jail!=.
	label var famincarc_imm "Imm Fam Incarc, Q4/dov_jail"
	label values famincarc_imm incarc


	***IMMEDIATE FAMILY MEMBER TYPE (DICHOTOMOUS) 
	forvalues i=1(1)8{			
		recode q4_`i' (0=0 "No") (1/3=1 "Yes") (77 98 99=.), gen(q4_`i'r)
		replace q4_`i'r=0 if famincarc_imm==0
		label var q4_`i'r "Imm Fam Type Incarc, Q4"
	}
		
	rename q4_1r famincarc_dad
	rename q4_2r famincarc_mom
	rename q4_3r famincarc_bro
	rename q4_4r famincarc_sis
	rename q4_5r famincarc_son
	rename q4_6r famincarc_daughter
	rename q4_7r famincarc_spouse
	rename q4_8r famincarc_childpar
		
				
	***COLLAPSED FAMILY MEMBER TYPES
	generate famincarc_parent=.
	replace famincarc_parent=0 if famincarc_imm!=. 
	replace famincarc_parent=1 if famincarc_dad==1 | famincarc_mom==1 
	label var famincarc_parent "Imm Fam Type Incarc, Q4"
			
	generate famincarc_sib=.
	replace famincarc_sib=0 if famincarc_imm!=. 
	replace famincarc_sib=1 if famincarc_bro==1 | famincarc_sis==1 
	label var famincarc_sib "Imm Fam Type Incarc, Q4"
			
	generate famincarc_child=.
	replace famincarc_child=0 if famincarc_imm!=. 
	replace famincarc_child=1 if famincarc_son==1 | famincarc_daughter==1 
	label var famincarc_child "Imm Fam Type Incarc, Q4"
			
	generate famincarc_partner=.
	replace famincarc_partner=0 if famincarc_imm!=. 
	replace famincarc_partner=1 if famincarc_spouse==1 | famincarc_childpar==1 
	label var famincarc_partner "Imm Fam Type Incarc, Q4"
			
			
	***LONGEST IMMEDIATE FAMILY MEMBER INCARCERATION
	recode q4long (1=0 "1 Day or Less") (2/6=1 ">1 Day") (77 98 .=.), gen(dfamincarc_imm_longest)
	recode q4long (1/2=0 "1 Month or Less") (3/6=1 ">1 Month") (77 98 .=.), gen(mfamincarc_imm_longest)
	recode q4long (1/3=0 "1 Year or Less") (4/6=1 ">1 Year") (77 98 .=.), gen(yfamincarc_imm_longest)
	
	recode q4long (1/4=0 "5 Years or Less") (5/6=1 ">5 Years") (77 98 .=.), gen(famincarc_imm_longest_5)
	recode q4long (1/5=0 "10 Years or Less") (6=1 ">10 Years") (77 98 .=.), gen(famincarc_imm_longest_10)
	
	foreach t in d m y{
		replace `t'famincarc_imm_longest=0 if famincarc_imm==0
	}
	foreach n in 5 10{
		replace famincarc_imm_longest_`n'=0 if famincarc_imm==0
	}
		
		
	
********************************
***RECODES: OWN INCARCERATION***
********************************

	**ANY
	recode q20 (1=1 "Yes") (2=0 "No") (98=.), gen(own_incarc)
	label var own_incarc "R: Ever Incarcerated"
	
		
	**DURATION (1 YEAR +)
	generate own_incarc_long=.
	replace own_incarc_long=q22a if q21==1
	replace own_incarc_long=q22b if q21==2
	replace own_incarc_long=0 if own_incarc==0
	label var own_incarc_long "R: Incarc Duration"
			
	recode own_incarc_long (0/3=0) (4/6=1 "1 Year or More"), gen(yown_incarc_long)
	

	
*****************************************
***RECODES: COMBINED CARCERAL EXPOSURE***
*****************************************

	***OWN/IMMEDIATE FAMILY INCARCERATION
	generate incarc_cat=.
	replace incarc_cat=0 if own_incarc==0 & famincarc_imm==0
	replace incarc_cat=1 if own_incarc==1 & famincarc_imm==0
	replace incarc_cat=2 if own_incarc==0 & famincarc_imm==1
	replace incarc_cat=3 if own_incarc==1 & famincarc_imm==1
	label define incarc_cat 0 "Neither" 1 "Own Incarceration Only" 2 "Immediate Family Incarceration Only" 3 "Own and Immediate Family Incarceration"
	label values incarc_cat incarc_cat
	label variable incarc_cat "Incarceration, Categorical"
	


**********************************************
***CIVIC PARTICIPATION/COMMUNITY ENGAGEMENT***
**********************************************

	***COMMUNITY ENGAGEMENT
	
		**COMMUNITY ENGAGEMENT, ITEM-SPECIFIC
		forvalues v=1(1)5{
			clonevar q40_`v'b=q40_`v'
		}
		rename q40_1b comm_pta
		rename q40_2b comm_group
		rename q40_3b comm_blood
		rename q40_4b comm_charity
		rename q40_5b comm_vol
		
		**COMMUNITY ENGAGEMENT SCALE
		generate scale_comm=.
		replace scale_comm=comm_pta 
		foreach v in group blood charity vol{
			replace scale_comm=scale_comm+comm_`v' if scale_comm!=. 
		}
		label var scale_comm "Scale: Community Engagement"
	
		**COMMUNITY ENGAGEMENT, STANDARDIZED SCALE
		quietly summ scale_comm, detail
		local sigma=r(sd)
		local mu=r(mean)
		generate stdscale_comm=(scale_comm-`mu')/`sigma'
		
	
	***CIVIC PARTICIPATION
	/*Note: q41_4b and q41_11b (political campaign and elected to office) were not used in these analyses as an insufficient amount of variation within each item made models inestimable. To keep the main models and item-specific and stratified models comparable, we elected to exclude these rather than to only include them in specific analyses. */
	
		**CIVIC PARTICIPATION, ITEM-SPECIFIC
		forvalues v=1(1)11{
			clonevar q41_`v'b=q41_`v'
		}	
		rename q41_1b civic_rally
		rename q41_2b civic_contactgov
		rename q41_3b civic_camppres
		rename q41_5b civic_donatepres
		rename q41_6b civic_donatepol
		rename q41_7b civic_commprob
		rename q41_8b civic_commboard
		rename q41_9b civic_lettertoed
		rename q41_10b civic_internet
		
		**CIVIC PARTICIPATION, SCALE
		generate scale_civic=.
		replace scale_civic=civic_rally 
		foreach v in contactgov camppres donatepres donatepol commprob commboard lettertoed internet { 
			replace scale_civic=scale_civic+civic_`v' if scale_civic!=. 
		}
		label var scale_civic "Scale: Civic Participation"
		
		**CIVIC PARTICIPATION, STANDARDIZED SCALE
		quietly summ scale_civic, detail
		local sigma=r(sd)
		local mu=r(mean)
		generate stdscale_civic=(scale_civic-`mu')/`sigma'
		
	
***********************************
***TRUST IN THE STATE/GOVERNMENT***
***********************************
	
	***CONFIDENCE IN CRIMINAL JUSTICE SYSTEM
	recode q1 (1=1 "Very Little") (2=2 "Some Confidence") (3=3 "Great Deal") (77 98 99=.), gen(cj_conf)
	label var cj_conf "Confidence in Local CJ"

	***TRUST IN POLICE
	recode q38 (4=1 "Almost Never") (3=2 "Only Sometimes") (2=3 "Most of the Time") (1=4 "Almost Always") (77 98=.), gen(police_trust)
	label var police_trust "Trust in Police"
		
	***TRUST IN GOVERNMENT
	label define trust 1 "Never" 2 "Some of the time" 3 "About half the time" 4 "Most of the time" 5 "Always"
	
	foreach v in q42_1 q42_2 q42_3{
		generate trust_`v'=.
		replace trust_`v'=5 if `v'==1
		replace trust_`v'=4 if `v'==2
		replace trust_`v'=3 if `v'==3
		replace trust_`v'=2 if `v'==4
		replace trust_`v'=1 if `v'==5
		label values trust_`v' trust
	}
	rename trust_q42_1 trust_fed
	rename trust_q42_2 trust_state
	rename trust_q42_3 trust_local
	label var trust_fed "Fed Govt, How often trust"
	label var trust_state "State Govt, How often trust"
	label var trust_local "Local Govt, How often trust"
		
	***TRUST IN STATE, SCALE 
	gen scale_trust=.
	replace scale_trust=((cj_conf-1)/2)
	replace scale_trust=scale_trust+((police_trust-1)/3)
	foreach g in local state fed{
		replace scale_trust=scale_trust+((trust_`g'-1)/4)
	}
	label var scale_trust "Scale: Trust in State"
	
	***TRUST IN STATE, STANDARDIZED SCALE
	quietly summ scale_trust, detail
	local sigma=r(sd)
	local mu=r(mean)
	generate stdscale_trust=(scale_trust-`mu')/`sigma'
		

*******************************		
***SUBPOPULATION DEFINITIONS***
*******************************

	***GENERATE SUBPOP DEFINITIONS
	label define subpop 0 "Not in Sample" 1 "In Sample"
	
	generate subpop_analysis=1 if own_incarc!=. & famincarc_imm!=.
	
	
	***DEFINE ANALYTIC SAMPLE
		
		**EXCLUDE IF MISSING ON DVs
		global civic civic_commprob civic_camppres civic_donatepres civic_donatepol civic_contact civic_lettertoed civic_internet
		global comm comm_pta comm_group comm_blood comm_charity comm_vol
		global crim cj_conf police_trust 
		global govt trust_local trust_state trust_fed
		foreach v in $civic $comm $crim $govt { 
			
			replace subpop_analysis=0 if `v'==.
		}
				
		**EXCLUDE IF MISSING ON CONTROLS/COVARS
		global covars age partner hhsize hhchild female raceth income workstat educ4 region4 metro
		foreach v in $covars{
			
			replace subpop_analysis=0 if `v'==.
		}
		replace subpop_analysis=0 if weight2==.
					
		**LABEL SUBPOP DEFS
		label values subpop_analysis subpop
	
	
	***DEFINE COMPARISON GROUPS
	
		**OVERALL ANALYTIC SAMPLE
		generate sample_all=1 if subpop_analysis==1
		label var sample_all "Sample: Full Analytic Sample"
				
		**NEITHER IMMEDIATE FAMILY NOR OWN INCARCERATION
		generate sample_none=0 if sample_all==1
		replace sample_none=1 if sample_all==1 & own_incarc==0 & famincarc_imm==0
		label var sample_none "Sample: No Imm Fam/Own Incarc"
				
		**OWN INCARCERATION ONLY
		generate sample_own=0 if sample_all==1
		replace sample_own=1 if sample_all==1 & own_incarc==1 & famincarc_imm==0
		label var sample_own "Sample: Own Incarc Only"
				
		**IMMEDIATE FAMILY INCARCERATION ONLY
		generate sample_immfam=0 if sample_all==1
		replace sample_immfam=1 if sample_all==1 & own_incarc==0 & famincarc_imm==1
		label var sample_immfam "Sample: Imm Fam Incarc Only"
				
		**BOTH IMMEDIATE FAMILY AND OWN INCARCERATION
		generate sample_both=0 & own_incarc==1 & famincarc_imm==1
		replace sample_both=1 & own_incarc==1 & famincarc_imm==1
		label var sample_both "Sample: Both Imm Fam/Own Incarc"
				
		**SINGLE VARIABLE FOR COMPARISON GROUPS (MUTUALLY EXCLUSIVE)
		generate sample_cat=0 if sample_none==1 
		replace sample_cat=1 if sample_own==1
		replace sample_cat=2 if sample_immfam==1
		replace sample_cat=3 if sample_both==1
		replace sample_cat=. if sample_all!=1
		label define sample_cat 0 "Neither" 1 "Own Only" 2 "Immediate Family Only" 3 "Both Own/Immediate Family"
		label var sample_cat sample_cat
			
	
**********
***SAVE***
**********

	***SAVE RECODED DATA
	save "$folder\famhis_recode.dta", replace
	
	export delimited using "$folder\famhis_recode.csv", replace
	export delimited sample_all scale_* famincarc_imm own_incarc incarc_cat using "$folder\famhis_recode.csv", replace
		


*log close // uncomment to log

