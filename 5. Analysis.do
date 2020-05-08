/*******************************************************************************

				Burkina Faso: 5. Fixed Effects Analysis 
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 09Apr2020
						  
      ----------------------------------------------------------
			  
	*Objective: 
	
	This file performs the following tasks:
		1.
		
			
*******************************************************************************/


********************************************************************************
**********************                                    **********************  
**********************          1.            **********************
**********************                                    **********************    
********************************************************************************


u "$work/Master panel", clear




*Number of events
xtreg total_points total_events, fe robust
outreg2  using "$output/3. Tables/Fixed effects regresions_events.xls", replace


xtreg total_points e_cat_1,fe robust
outreg2  using "$output/3. Tables/Fixed effects regresions_events.xls", append

xtreg total_points e_cat_2,fe  robust
outreg2  using "$output/3. Tables/Fixed effects regresions_events.xls",  append


*Fatalities
xtreg total_points fatalities, fe robust
outreg2  using "$output/3. Tables/Fixed effects regresions_fatalities.xls", excel 


xtreg total_points fatalities_violent, fe robust
outreg2  using "$output/3. Tables/Fixed effects regresions_fatalities.xls", excel append


xtreg total_points fatalities_demon, fe robust
outreg2  using "$output/3. Tables/Fixed effects regresions_fatalities.xls", excel append
