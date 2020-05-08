/*******************************************************************************

				Burkina Faso: 2. Merge
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 28Feb2020
						  
      ----------------------------------------------------------
			  
	*Objective: Merge cleaned datasets into a master dataset
	
	This file performs the following tasks:
		1. Merge ACLED data with shapefile
		2. Merge rounds of SUPERMUN to create panel
		3. Merge SUPERMUN with ACLED data
		4. Merge SUPERMUN + ACLED + SHP 
		
			
*******************************************************************************/


********************************************************************************
**********************                                    **********************  
**********************          1. ACLED - SHP            **********************
**********************                                    **********************    
********************************************************************************

u "$work/maps/burkinafaso", clear 
mmerge region province commune_edited using  "$work/acled/acled_long"
tab _merge 

/*
Note:  All obs from ACLED data are merged
-->157 obs are only in master data
-----> no ACLED events in these communes

                          _merge |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
             only in master data |        157        6.80        6.80
   both in master and using data |      2,153       93.20      100.00
---------------------------------+-----------------------------------
                           Total |      2,310      100.00


*/

drop _merge

*save dataset in both excel and stata formats


	order year region province commune_edited id_event event_cat event_type no_event fatalities
	sort  year region province commune_edited
	save "$work/acled/acled_long_shp", replace 
	

	
********************************************************************************
**********************                                    **********************  
**********************            2. SUPERMUN DATA        **********************
**********************                                    **********************    
********************************************************************************

forvalues i=2014/2018 {
	
	di "Merge year: `i'"
	tempfile `i'
		
		*Merge - note that for years <2016 there is no commune_edited var so we use 
		*commune as is an id. For the rest of the years, commune_edited & province are ids.
		*Also data for these years has been cleaned
			if(`i'<2016){
				u "$work/world bank/`i'_institutional_capacity", clear
				
				*rename variables with the same names in both datasets
				ren total_points total_points_ic
				ren stars_total stars_total_ic 
				
				mmerge province commune using "$work/world bank/`i'_service_delivery"
			}
				else{
			
					u "$raw/`i'_institutional_capacity", clear
					*rename variables with the same names in both datasets
					ren total_points total_points_ic
					ren stars_total stars_total_ic
					
					mmerge province commune_edited using "$raw/`i'_service_delivery"
					
					
				}	
				
		*rename variables with the same names in both datasets
		ren total_points total_points_sd
		ren stars_total  stars_total_sd 

		
		gen year = `i'
		move year region 
	save ``i''
}



/*

Note 1:

For the year 2018, 3 observations from institutional capacity dataset were not merged.

     +--------------------------------+
     |   commune               _merge |
     |--------------------------------|
347. |    BOULSA   only in using data |
348. |     DABLO   only in using data |
349. | OUINDIGUI   only in using data |
     +--------------------------------+
	 
	 
*Note 2:
	 
commune_edited does not uniquely identifies observations as BOUSSOUMA GARANGO and 
BOUSSOUMA KAYA are edited to BOUSSOUMA
	 
     +-------------------------------+
     |           commune   commune~d |
     |-------------------------------|
 57. | BOUSSOUMA GARANGO   BOUSSOUMA |
 58. |    BOUSSOUMA KAYA   BOUSSOUMA |
     +-------------------------------+

*/ 


append using `2014'
append using `2015'
append using `2016'
append using `2017'
 drop commune 
 
***Fix variables to have a unique ID 




*check if is ID
 isid year region province commune_edited
 sort year region province commune_edited
save "$work/world bank/SUPERMUN panel", replace

********************************************************************************
**********************                                    **********************  
**********************             3. MASTER DATA         **********************
**********************                                    **********************    
********************************************************************************



*ACLED

mmerge year region province commune_edited using "$work/acled/acled_long_year" 

*Drop obs that are not present in SUPERMUN data 
drop if year==2019 | year<2014


/* Note: not merged observations

. tab _merge
                          _merge |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
             only in master data |        909       78.29       78.29
              only in using data |         43        3.70       82.00
   both in master and using data |        209       18.00      100.00
---------------------------------+-----------------------------------
                           Total |      1,161      100.00


. tab year if _merge==2

       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2014 |         10       23.26       23.26
       2015 |         12       27.91       51.16
       2016 |         17       39.53       90.70
       2017 |          2        4.65       95.35
       2018 |          2        4.65      100.00
------------+-----------------------------------
      Total |         43      100.00

--> no obs for OUAGADOUGOU & BOBO-DIOULASSO
--> Other obs that are not merged are for events in munis that were part of 
SUPERMUN's expansion
*/

drop _merge


*Shapefiles
mmerge region province commune_edited using "$work/maps/burkinafaso" /// all obs merged

drop _merge



* create a panel ID
sort region province commune_edited
egen panel_id = group(region province commune_edited)



*Set panel format

xtset panel_id year 


/*note:

       panel variable:  panel_id (unbalanced)
        time variable:  year, 2014 to 2018, but with gaps
                delta:  1 unit

	*/
	

*Labels for better data visualization 
	
			*variables
			label var total_events    			"Number of Events"
			label var e_cat_1		   			"Number of Violent Events"
			label var e_cat_2	    			"Number of Demonstrations"
			label var e_cat_3	    			"Number of Non-Violent Events"
			label var fatalities            	"Number of Fatalities"
			label var fatalities_violent		"Number of Violent Fatalities"
			label var fatalities_demon      	"Number of Fatalities from Demonstrations"
			label var fatalities_no_violent   	"Number of Non-Violent Fatalities"
			
			
* assumption! all the missing values to 0 
 foreach i of varlist fatalities* total_events e_cat*{
 	tab `i', mi
 	replace `i'=0 if `i'==.
	tab `i'
 }

 *Gen total points
gen total_points= total_points_ic + total_points_sd
sum total_points* 
		
		
	
	save "$work/Master panel", replace

