/*******************************************************************************

				Burkina Faso: 2. Merge
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 28Feb2020
						  
      ----------------------------------------------------------
			  
	*Objective: Merge cleaned datasets into a master dataset
	
	This file performs the following tasks:
		1. Merge ACLED data with 2018 SUPERMUN data 
		2. Merge output 1. with shapefile data
		
			
*******************************************************************************/


********************************************************************************
**********************                                    **********************  
**********************        1. SUPERMUN - ACLED         **********************
**********************                                    **********************    
********************************************************************************


u "$raw/2018_service_delivery", clear
*create a year variable for match with ACLED
gen year=2018
move year region

mmerge region province commune_edited year using  "$work/acled/acled_long"
drop _merge 

/*
Note: 

 ---> ACLED data has 394 obs for 2018= 331 obs were merged + 63 obs for Bobo & Ouaga
. tab _merge
                          _merge |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
             only in master data |        250       10.40       10.40
              only in using data |      1,822       75.82       86.23
   both in master and using data |        331       13.77      100.00
---------------------------------+-----------------------------------
                           Total |      2,403      100.00




ACLED data not merged with SUPERMUN  in 2018--> BOBO-DIOULASSO & OUAGADOUGOU communes

. tab commune_edited if _merge==2 & year==2018

         commune_edited |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         BOBO-DIOULASSO |         17       26.98       26.98
            OUAGADOUGOU |         46       73.02      100.00
------------------------+-----------------------------------
                  Total |         63      100.00

*/



********************************************************************************
**********************                                    **********************  
**********************   2. Shapefile - Dataset from 1.   **********************
**********************                                    **********************    
********************************************************************************

*merge
	mmerge region province commune_edited using  "$work/maps/burkinafaso"
	drop _merge /// all matched
	
	
	
*save dataset in both excel and stata formats

	order year region province commune_edited id_event event_cat event_type no_event fatalities
	export excel  using "$work/excel/acled_wb_long", replace firstrow(var)
	
	sa "$work/acled/acled_wb_long", replace
	
	

