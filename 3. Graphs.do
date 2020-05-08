
/*******************************************************************************

				Burkina Faso: 3. Graphs
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 10Apr2020
			
      ----------------------------------------------------------
			  
	*Objective: Graph data from Acled and Supermun to better understad 
	the current situation in Burkina Faso
	
	This file performs the following tasks:
		1. Graph number of events and fatalities
		2. Graph violent events
		3. Graph SUPERMUN
	
			
*******************************************************************************/

	
u "$work/acled/acled_long", clear 

********************************************************************************
**********************                                    **********************  
**********************             0. Preamble            **********************
**********************                                    **********************    
********************************************************************************

*Save labels in a local --> after collapse, labels are dropped/replaced

local varlist fatalities no_event event_type event_cat region inter1 inter2 

	foreach v in `varlist'{
	local l_`v': variable label `v'
	}


********************************************************************************
**********************                                    **********************  
**********************  1. Number of events & Fatalities  **********************
**********************                                    **********************    
********************************************************************************


*********************  1.1 Number of events per year ********************* 


preserve
		* Sum number of events per year
		collapse (sum) no_event fatalities if !mi(year), by(year)
		
		*labels
		foreach v of varlist no_event fatalities {
		label variable `v' "`l_`v''"
		}


		*Generate an x-axis for graphs 
		sort year, stable
		gen x_axis= _n 

		*Label axis with years 
		levelsof year, local(a)
		local b: word count `a'
		
		forval i = 1/`b' {
			local c: word `i' of `a'
			di "Assign label `c' to value `i'"
			label def x_axis `i' `c', modify
		}

		label val x_axis x_axis

		*Move axis to the left, so the start point is the label
		replace x_axis = x_axis + 0.5
	


**** Graph 1: Number of events and fatalities per year ****

		graph twoway bar no_event x_axis , yaxis(1) scheme(s2color) ///
			color(emerald%50)  ///
			title("Number of Events and Fatalities 01Feb97-31Dec2019", size(medsmall)) ///
			xtitle(Year, size(small)) xlabel(1/`b', labsize(tiny) valuelabel) ///
			ytitle(Number of Events, size(small)) ylabel( #12 , labsize(tiny)) || ///
			scatter fatalities x_axis, color(maroon%70) yaxis(2) ///
			ytitle(Number of Fatalities, size(small) axis(2)) ylabel( #20 , labsize(tiny) axis(2))
			
				
		graph export "$output/1. Graphs/1. No_event_fatalities_year.png", replace
			
restore


**** Graph 2: Number of events and fatalities per year by event category ****


preserve
		* Sum number of events per year
		collapse (sum) no_event fatalities, by(year event_cat)
		

		*Generate an x-axis for graphs 
		sort year, stable
		egen x_axis=  group(year)

		*Label axis with years 
		levelsof year, local(a)
		local b: word count `a'
		
		*Label axis with years
		levelsof x_axis, local(a)
		levelsof year, local(b)
			local c: word count `a'
			forval i = 1/`c' {
				local d: word `i' of `b' 
					di "Assign label `d' to value `i' "
					label def x_axis `i' "`d'", modify		
		}
		

		label val x_axis x_axis

		*Move axis to the left, so the start point is the label
		replace x_axis = x_axis + 0.5
	
	*create 3 graphs, one per category
	
*set max value for y-axis label (the same one across 3 graphs)
qui sum fatalities
local min_f `r(min)'
local max_f `r(max)'

qui sum no_event
local min_e `r(min)'
local max_e `r(max)'


*Graph
		
levelsof event_cat, local(e)
local f: word count `e'
local z = 2
forval g=1/`f'{
	local var: label event_cat `g'
	
	di " ************ Graph for category: `var' ************ " 
	*Labels for legend
		foreach v of varlist no_event fatalities event_cat {
		label variable `v' "`l_`v''"
		}

	
	 graph twoway bar no_event x_axis if event_cat==`g', yaxis(1) scheme(s2color) ///
			color(emerald%50)  legend(order(1 "Number of Events" 2 "Number of Fatalities")) ///
			title("`var'", size(medsmall)) ///
			xtitle(Year, size(small)) xlabel(1/`c', labsize(tiny) valuelabel) ///
			ytitle(Number of Events, size(small)) ylabel( `min_e'(100)`max_e'  , labsize(tiny)) yscale() ///
			|| scatter fatalities x_axis if event_cat==`g', color(maroon%90)  yaxis(2) mlabsize(tiny) ///
			ytitle(Number of Fatalities, size(small) axis(2)) ylabel(`min_f'(200)`max_f' , labsize(tiny) axis(2))
	
			
		
		graph export "$output/1. Graphs/1.`z'. No_event_fatalies_year_`var'.png", replace
		
		local z= `++z'
}
					
restore


***************************  1.2  Graphs per quarter  ************************

**** Preare data *****

		*Create quaterly date 
		gen q_date_event=qofd(date_event)
		format %tq q_date_event
		
		*Generate an x-axis for graphs 
		sort q_*, stable
		egen x_axis= group(q_date_event) if year>2013

		*Label axis with quaters
		levelsof x_axis, local(a)
		levelsof q_date_event if year>2013, local(b)
			local c: word count `a'
			forval i = 1/`c' {
				local d: word `i' of `b' 
				local e = string(`d', "%tq")
					di "Assign label `e' to value `i' "
					label def x_axis `i' "`e'", modify		
		}
		
		
		label val x_axis x_axis
	 
		*Move axis to the left, so the start point is the label
		
		replace x_axis = x_axis + 0.5 if !mi(x_axis)
			
**** Graph 2: Number of events after Dec2013 per quarter ****

	preserve
		*Sum number of events per quarter and type of event
		collapse (sum) no_event fatalities if  !mi(x_axis) , by(x_axis)
		
		*labels
		foreach v of varlist no_event fatalities {
		label variable `v' "`l_`v''"
		}
		
		*Graph number of events by year
		
		graph twoway bar no_event x_axis, yaxis(1) scheme(s2color) ///
			color(emerald%50)   ///
			title("Distribution of Events and Fatalities 2014-2019", size(medsmall)) ///
			xtitle(Quarter, size(small)) xlabel(1/`a' , labsize(tiny) valuelabel alt) ///
			ytitle(Number of Events, size(small)) ylabel( 0(50)250 , labsize(tiny)) || ///
			scatter fatalities x_axis, color(maroon%70) yaxis(2) ///
			ytitle(Number of Fatalities, size(small) axis(2)) ylabel( #20 , labsize(tiny) axis(2))
			
				
		graph export "$output/1. Graphs/2. No_event_fatalities_quarter.png", replace
			
	restore
	

**** Graph 3-7:  Number of events per quarter after Dec2013 by event type, region, category ****


local z=3
local var event_cat event_type region inter1 inter2 
foreach y in `var' {

		preserve
			
			*Sum number of events per quarter and type of event
			collapse (sum) no_event fatalities if  !mi(x_axis) , by(x_axis `y')
			
					*labels
					foreach v of varlist `y' no_event fatalities {
					label variable `v' "`l_`v''"
					}

			*Graph number of events by quarter and event type
			graph twoway bar no_event x_axis, by(`y') ///
				scheme(s2color) color(emerald%50) yaxis(1) ///
				xtitle(Quarter, size(small)) xlabel(1/`a' , labsize(half_tiny) valuelabel alt) ///
				ytitle(Frequency, size(small)) ylabel( 0(40)160 , labsize(tiny)) || ///
				scatter fatalities x_axis, color(maroon%70) yaxis(2) msize(small) ///
				ytitle(Number of Fatalities, size(small) axis(2)) ylabel( #10 , alt labsize(tiny) axis(2))
				
				graph export "$output/1. Graphs/`z'. No_event_fatalities_`y'_quarter.png", replace
				
		restore			
	local z= `++z'
	
}


********************************************************************************
**********************                                    **********************  
**********************    2. Graphs for violent events    **********************
**********************                                    **********************    
********************************************************************************
	
***Graph 8-11: Number of events per quarter after Dec2013 by event type, region, ONLY for vionlent events ****

local z=8
local var event_type region inter1 inter2 
foreach y in `var' {

		preserve
				
			di "Graph variable `y'"	
			*Sum number of events per quarter and type of event
			collapse (sum) no_event fatalities if event_cat== 1 & !mi(x_axis) , by(x_axis `y')
			
					*labels
					foreach v of varlist no_event fatalities `y'{
					label variable `v' "`l_`v''"
					}
			
			*Graph number of events by quarter and event type
			graph twoway bar no_event x_axis, by(`y') ///
				scheme(s2color) color(emerald%50) yaxis(1)  ///
				xtitle(Quarter, size(small)) xlabel(1/`a' , labsize(half_tiny) valuelabel alt) ///
				ytitle(Frequency, size(small)) ylabel( #12 , labsize(tiny)) || ///
				scatter fatalities x_axis, yaxis(2) color(maroon%70) ///
				ytitle(Number of Fatalities, size(small) axis(2)) ylabel( #10 , labsize(tiny) axis(2) alt)
			
				
			graph export "$output/1. Graphs/`z'. Violent_events_no_event_fatalities_`y'_quarter.png", replace
				
				
		restore			
	local z= `++z'
}



	*Collapse to sum the number of events by TOP REGIONS
	
	preserve
	
		keep if region=="SAHEL" | region == "CENTRE-NORD"  | region == "EST"
		collapse (sum) fatalities no_event, by(region x_axis)
		
			*labels
					foreach v of varlist no_event  fatalities region{
					label variable `v' "`l_`v''"
					}
		
		*Graph 
			graph twoway bar no_event x_axis, by(region) ///
				scheme(s2color) color(emerald%50) yaxis(1) ///
				xtitle(Quarter, size(small)) xlabel(1/`a' , labsize(half_tiny) valuelabel alt) ///
				ytitle(Frequency, size(small)) ylabel( #12 , labsize(tiny)) || ///
				scatter fatalities x_axis, color(maroon%70) yaxis(2) ///
				ytitle(Number of Fatalities, size(small) axis(2)) ylabel( #20 , labsize(tiny) axis(2) alt)

	graph export "$output/1. Graphs/12.Violent_events_top_region.png", as(png) replace	
	
	restore

	
**** Graph 0: CHECK -> Seasonal efects by category ****



preserve
		* Sum number of events per year
		collapse (sum) no_event fatalities , by(month_year event_cat)
		
		*labels
		foreach v of varlist no_event fatalities event_cat{
		label variable `v' "`l_`v''"
		}

		
		sort month_year, stable 
		egen x_axis= group(month_year) if month_year>tm(2013m12)

		*Label axis with quaters
		levelsof x_axis, local(a)
		levelsof month_year if month_year>tm(2013m12), local(b)
			local c: word count `a'
			forval i = 1/`c' {
				local d: word `i' of `b' 
				local e = string(`d', "%tm")
					di "Assign label `e' to value `i' "
					label def x_axis `i' "`e'", modify		
		}
		
		
		label val x_axis x_axis
	 
		*Move axis to the left, so the start point is the label
		
		replace x_axis = x_axis + 0.5 if !mi(x_axis)

			
	*set max value for y-axis label (the same one across 3 graphs)
qui sum fatalities
local min_f `r(min)'
local max_f `r(max)'

qui sum no_event
local min_e `r(min)'
local max_e `r(max)'

				
		levelsof event_cat, local(e)
		local f: word count `e'

		forval g=1/`f'{
			local var: label event_cat `g'
			
			di " ************ Graph for category: `var' ************ " 

			
			 graph twoway bar no_event x_axis if event_cat==`g', yaxis(1) scheme(s2color) ///
					color(emerald%50)   ///
					title("`var'", size(medsmall)) ///
					xtitle(Month, size(small)) xlabel(1/`c', labsize(half_tiny) valuelabel alt) ///
					ytitle(Frequency, size(small)) ylabel( `min_e'(10)`max_e', labsize(tiny)) yscale() || ///
					scatter fatalities x_axis if event_cat==`g', color(maroon%70) msize(tiny) yaxis(2) ///
					ytitle(Number of Fatalities, size(small) axis(2)) ylabel( `min_f'(50)`max_f', labsize(tiny) axis(2))
					
				
				graph export "$output/1. Graphs/CHECKS_no_event_fatalies_month_`var'.png", replace
				
		}
							
		restore



********************************************************************************
**********************                                    **********************  
**********************           3. SUPERMUN data         **********************
**********************                                    **********************    
********************************************************************************
u "$work/Master panel", clear



*3.1 Total Scores	
local varlist fatalities total_events region e_cat_1 fatalities_violent

	foreach v in `varlist'{
	local l_`v': variable label `v'
	di "`l_`v''"
	}
	
	
local method fpfit lfit	qfit
foreach m in `method' {	

	
	*Method
			di " ************* Method: `m' ************* "
	
		foreach v of varlist total_events fatalities{	
			
			*Label 	
			label var `v'  "`l_`v''"
			*tab `v'
			label var total_points  "Total points"
			
			*Graph
			di " ************* Graph variable: `l_`v'' ************* "

			
			twoway scatter total_points `v', color(emerald%40) ///
			scheme(s2color) title("Total Scores and `l_`v'' ") ///
			msize(tiny tiny) subtitle(For All Type of Events) ///
			xtitle(`l_`v'' , size(small)) ///
			ytitle(Total Points , size(small)) ylabel(, labsize(vsmall)) || ///
			`m'  total_points `v', color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			


		graph export "$output/1. Graphs/13.`m'_`v'_total_points.png", as(png) replace	
			
		}
	
	}
	



*For violent events



local method fpfit lfit	qfit
foreach m in `method' {	
	
	*Method
			di " ************* Method: `m' ************* "
	
		foreach v of varlist e_cat_1 fatalities_violent{	
			
			*Label 	
			label var `v'  "`l_`v''"
			*tab `v'
			label var total_points  "Total points"
			
			*Graph
			di " ************* Graph variable: `l_`v'' ************* "

			
			twoway scatter total_points `v', color(emerald%40) ///
			scheme(s2color) title("Total Scores and `l_`v'' ") ///
			msize(tiny tiny) subtitle(For Violent Events) ///
			xtitle(`l_`v'' , size(small)) ///
			ytitle(Total Points , size(small)) ylabel(, labsize(vsmall)) || ///
			`m'  total_points `v', color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			


		graph export "$output/1. Graphs/13.violent_events_`m'_`v'_service_delivery.png", as(png) replace	
			
		}
	
	}
	


*3.2 Total Scores --> cap values to <=20

drop if fatalities>10
drop if total_events >10



	
	
local method fpfit lfit	qfit
foreach m in `method' {	


	*Method
			di " ************* Method: `m' ************* "
	
		foreach v of varlist total_events fatalities{	
			
			*Label 	
			label var `v'  "`l_`v''"
			*tab `v'
			label var total_points  "Total points"
			
			*Graph
			di " ************* Graph variable: `l_`v'' ************* "

			
			twoway scatter total_points `v' if  `v'<=10 , color(emerald%40) ///
			scheme(s2color) title("Total Scores and `l_`v'' ") ///
			msize(tiny tiny) subtitle(For All Type of Events) ///
			xtitle(`l_`v'' , size(small)) ///
			ytitle(Total Points , size(small)) ylabel(, labsize(vsmall)) || ///
			`m'  total_points `v', color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			


		graph export "$output/1. Graphs/14.`m'_`v'_total_points_cap.png", as(png) replace	
			
		}
	
	}
	


*For violent events



local method fpfit lfit	qfit
foreach m in `method' {	
	
	*Method
			di " ************* Method: `m' ************* "
	
		foreach v of varlist e_cat_1 fatalities_violent{	
			
			*Label 	
			label var `v'  "`l_`v''"
			*tab `v'
			label var total_points  "Total points"
			
			*Graph
			di " ************* Graph variable: `l_`v'' ************* "

			
			twoway scatter total_points `v', color(emerald%40) ///
			scheme(s2color) title("Total Scores and `l_`v'' ") ///
			msize(tiny tiny) subtitle(For Violent Events) ///
			xtitle(`l_`v'' , size(small)) ///
			ytitle(Total Points , size(small)) ylabel(, labsize(vsmall)) || ///
			`m'  total_points `v', color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			


		graph export "$output/1. Graphs/14.violent_events_`m'_`v'_total_points_cap.png", as(png) replace	
			
		}
	
	}
	
	
*Final graphs for presentation
u "$work/Master panel", clear

drop if fatalities_violent>15
drop if e_cat_1>15

	twoway scatter total_points fatalities_violent, color(emerald%40) ///
			scheme(s2color) title("Total Scores and Number of Fatalities (2014-2018)") ///
			msize(tiny tiny) subtitle(For Violent Events) ///
			xtitle(Number of Fatalities, size(small)) xlabel(0(1)15, labsize(vsmall)) ///
			ytitle(Total Points , size(small)) ylabel(0(20)180, labsize(vsmall)) || ///
			fpfit total_points fatalities_violent, color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			graph export "$output/1. Graphs/15.violent_events_fatalities_total_points_cap.png", as(png) replace	
			
				twoway scatter total_points e_cat_1, color(emerald%40) ///
			scheme(s2color) title("Total Scores and Number of Events(2014-2018)") ///
			msize(tiny tiny) subtitle(For Violent Events) ///
			xtitle(Number of Violent Events, size(small)) xlabel(0(1)15, labsize(vsmall)) ///
			ytitle(Total Points , size(small)) ylabel(0(20)180, labsize(vsmall)) || ///
			fpfit total_points e_cat_1, color(navy%80) ///
			legend(order(1 "Total points" 2 "Predicted total points")) 
			graph export "$output/1. Graphs/15.violent_events_no_events_total_points_cap.png", as(png) replace	
