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
Lead File

Programming Code Information:
Yi, Youngmin
November 4, 2024

Publication Information: 
Yi, Youngmin, Peter Enns, Christopher Wildeman. 2024. Reconsidering the Relationship between Incarceration, Trust in the State, Community Engagement, and Civic Participation. Socius, 10. https://doi.org/10.1177/23780231241277436


Note: This is the lead file for replication of analyses published in this article */


***********
***SETUP***
***********

	clear
	clear mata

	**SETTINGS
	*Note: Modify preferences as desired.
	set linesize 160
	set maxvar 32767
	set more off

	
	**SET WORKING DIRECTORY
	/*Note: Working directory location should contain all programming files that
	are called below as well as the data files (labeled "famhis_raw.dta" and "verasight_raw.dta"in the 
	replication materials.*/
	*global folder "[[WORKING DIRECTORY PATH HERE]]" 
	global folder "C:\Users\yyi\Dropbox\projects\famhis\famhis_civic\drafts\socius\replication"
	cd "$folder"

	
**************
***ANALYSIS*** 
**************
/*Note: The files are numbered in the order that they *have* to be run. Files that share the same lead number do not
need to be run in a particular order. As a default, unless necessary for storing/exporting output, the .do files do
not log the analyses. If you wish to see the granular output, manually uncomment the "log..." syntax in the relevant
programming file. */

do "1_data.do" 

do "2_cem.do" 

do "3_tables.do" 

do "3_main-reg.do" 

do "3_cem-reg.do" 

do "3_prison-reg.do" 

do "3_strat-reg.do" 

do "3_experiment.do" 

do "4_reg-estimates.do" 

