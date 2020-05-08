
/*******************************************************************************

				Burkina Faso: 4. Maps
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 09March2020
      ----------------------------------------------------------
			  
	*Objective: Graph and map data from Acled and Supermun to better understad 
	the current situation in Burkina Faso
	
	This file performs the following tasks:
		1. Map number of events and fatalities
		2. Maps by year and category for GIFs
		3. Map SUPERMUN data
	
	
			
*******************************************************************************/

u "$work/acled/acled_long_shp", clear 

********************************************************************************
**********************                                    **********************  
**********************  1. Number of events & fatalities  **********************
**********************                                    **********************    
********************************************************************************



preserve 
	drop if year<2014

	collapse (sum) no_event fatalities, by (id_shapefile)


		*In order to have the polygons in white for 0 events and fatalities, replace to missing

	
 **************** Total events  ****************
	
	
	*Check data distribution
    sum no_event, d 
	
/*
	Note: a little less than half of the data is 0,  
	
	     sum no_event, d

                       (sum) no_event
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 351
25%            0              0       Sum of Wgt.         351

50%            1                      Mean           5.162393
                        Largest       Std. Dev.      19.90519
75%            4             74
90%           11             86       Variance       396.2164
95%           20             97       Skewness       11.62042
99%           74            315       Kurtosis       171.2961

*/
	
	*Replace 0 -> . so smpap maps them as white		
	replace no_event  = . if no_event==0	
		
	*Create map
	spmap no_event using "$raw/shapefiles/new shapefile/burkinacoord", ///
	id(id_shapefile) fcolor(Reds2)  ///
	clmethod(custom) clbreaks( 0 3 10 19 73 315) ///
	osize(thin ..) legend(position(1)) ///
	title("Number of Events [2014-2019]")  ///
	legtitle("Number of Events")  ///
	legend(label(1 "0 Events (50% data)") label(2 "1-3          (25% data)") label(3 "4-10        (15% data)") label(4 "11-19      (5% data)") label(5 "20-73      (4% data)") label(6 "74-315    (1% data)") )
	
	graph export "$output/2. Maps/1. Overall maps/1. total events.png", replace
	
	
 **************** total fatalities ****************
	
	*Check data distribution
	sum fatalities, d 
	
	/*
	Note: same as in no_event, more than half of the data is 0
.         sum fatalities, d 

                      (sum) fatalities
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs                 351
25%            0              0       Sum of Wgt.         351

50%            0                      Mean           7.780627
                        Largest       Std. Dev.      35.09758
75%            2            125
90%           15            139       Variance        1231.84
95%           41            331       Skewness        9.65924
99%          125            479       Kurtosis       115.1899

*/
	
	*Replace 0 -> . so smpap maps them as white
	replace fatalities= . if fatalities==0
	
	
	spmap fatalities using "$raw/shapefiles/new shapefile/burkinacoord", ///
	id(id_shapefile)  fcolor(Reds2)  ///
	clmethod(custom) clbreaks(0 1 14 40 124 479) ///
	osize(thin ..) legend(position(1)) ///
	title("Number of Fatalities [2014-2019]") ///
	legtitle("Number of Fatalities") ///
	legend(label(1 "0 Fatalities (50% data)") label(2 "1                 (25% data)") ///
	label(3 "2-14            (15% data)") label(4 "15-40          (5% data)" )  ///
	label(5 "41-124        (4% data)") label(6 "125-479      (1% data)")) 
	
	graph export "$output/2. Maps/1. Overall maps/2. total fatalities.png", replace
	
	
restore
	


********************************************************************************
**********************                                    **********************  
**********************             2. For GIFS            **********************
**********************                                    **********************    
********************************************************************************
*To chose the breaks, I'm going to use the breaks for fatalities (higher values)




*Problem: label for 0 in scales, not very elegant solution
ren no_event events


*All fatalities, number events
	foreach var of varlist fatalities events {
		
		
		local l: variable label `var'
		
		
			di " ************ Maps for variable: `l' ************ "
		
				forval i=2014/2019{
					preserve
				
					collapse (sum) `var', by (id_shapefile year)
	
					*Label variables
				
					di " ************ Map for year `i' ************ "                              
						* Gen aux variable for mapping 
						gen `var'_`i'= .
						replace `var'_`i'= `var' if year==`i'
						tab `var'_`i',mi  /// double check var
						
					
						* Have one obs per id_shapefile --> drop duplicates
						
							*Case 1: second or + occurrence of id & fatalities_2019 is missing
								sort id_shapefile, stable
								by id_shapefile: gen dup_aux = _n 
								drop if `var'_`i'==. & dup_aux >1
							
							*Case 2:  first occurrence of id has fatalities_2019 empty, 
							*and there is another obs for fatalities_2019
							*(i.e. we still have two obs per id)
								duplicates tag id_shapefile, g(dup) 
								drop if `var'_`i'==. & dup > 0
								
							*fill missing values with 0
							replace `var'_`i'= . if `var'_`i'==0
						
								*Map by category for events and total fatalities per year	
								if ("`var'"=="fatalities"){
									spmap `var'_`i' using "$raw/shapefiles/new shapefile/burkinacoord", ///
									id(id_shapefile)  fcolor(Reds2)  ///
									clmethod(custom) clbreaks(0 1 14 40 124 479) ///
									osize(thin ..) legend(position(1)) ///
									title(" `l' in `i'") legtitle("`l'") ///
									legend(label(1 "0 `var'") label(2 "1") ///
									label(3 "2-14") label(4 "15-40" )  ///
									label(5 "41-124") label(6 "125-479"))
								}
								
									else {
										spmap `var'_`i' using "$raw/shapefiles/new shapefile/burkinacoord", ///
										id(id_shapefile)  fcolor(Reds2)  ///
										clmethod(custom) clbreaks(0 3 10 19 73 315) ///
										osize(thin ..) legend(position(1)) ///
										title(" `l' in `i'") legtitle("`l'") ///
										legend(label(1 "0 `var'") label(2 "1-3") label(3 "4-10") ///
										label(4 "11-19") label(5 "20-73") label(6 "74-315")) 
									}
						
						drop `var'_`i'  dup* 
				restore
			graph export "$output/2. Maps/2. Gif creation/`var'_`i'.png", replace
			
			}
		
	}
	
	
	*By category of events, fatalities



levelsof event_cat, local(a)
local b: word count `a'
forval c=1/`b'{
	local lab: label event_cat `c'
	

		foreach var of varlist fatalities events {
			local l: variable label `var'
			di " ************ Maps for category: `lab' for `var' ************ "  
		
			forval i=2014/2019{
				
				preserve
					
					collapse (sum) `var', by (id_shapefile year event_cat)
		
					
						di " ************ Map for year `i' ************ "                              
							* Gen aux variable for mapping 
							gen     cat_`c'_`i'_`var'= .
							replace cat_`c'_`i'_`var'= `var' if year==`i' & event_cat == `c'
							tab     cat_`c'_`i'_`var',mi  /// double check var
							
						
							* Have one obs per id_shapefile --> drop duplicates
							
								*Case 1: second or + occurrence of id & fatalities_2019 is missing
									sort id_shapefile, stable
									by   id_shapefile: gen dup_aux = _n 
									drop if cat_`c'_`i'_`var'==. & dup_aux >1
									tab     cat_`c'_`i'_`var',mi  /// double check var
							
								*Case 2:  first occurrence of id has fatalities_2019 empty, 
								*and there is another obs for fatalities_2019
								*(i.e. we still have two obs per id)
									duplicates tag id_shapefile, g(dup) 
									drop if cat_`c'_`i'_`var'==. & dup > 0
									
									isid id_shapefile
									
									*fill missing values with 0
									replace cat_`c'_`i'_`var'= . if cat_`c'_`i'_`var'==0
								
									tab cat_`c'_`i'_`var', mi  /// double check var
							
							
							* Map by category for events and total fatalities per year	
							if ("`var'"=="fatalities"){
									spmap cat_`c'_`i'_`var' using "$raw/shapefiles/new shapefile/burkinacoord", ///
									id(id_shapefile)  fcolor(Reds2)  ///
									clmethod(custom) clbreaks(0 1 14 40 124 479) ///
									osize(thin ..) legend(position(1)) ///
									title("`lab': `l' in `i'") legtitle("`l'") ///
									legend(label(1 "0 `var'") label(2 "1") ///
									label(3 "2-14") label(4 "15-40" )  ///
									label(5 "41-124") label(6 "125-479")) 
								}
								
								
									else {
										spmap cat_`c'_`i'_`var' using "$raw/shapefiles/new shapefile/burkinacoord", ///
										id(id_shapefile)  fcolor(Reds2)  ///
										clmethod(custom) clbreaks(0 3 10 19 73 315) ///
										osize(thin ..) legend(position(1)) ///
										title("`lab': `l' in `i'") legtitle("`l'") ///
										legend(label(1 "0 `var'") label(2 "1-3") label(3 "4-10") ///
										label(4 "11-19") label(5 "20-73") label(6 "74-315")) 
									}
							
						
							drop cat_`c'_`i'_`var'  dup* 
					restore
					
				graph export "$output/2. Maps/2. Gif creation/`c'_`var'_`i'.png", replace
					}
				}
			
			}
		

*rename the variables back so the code doesn't break
ren events no_event


********************************************************************************
**********************                                    **********************  
**********************          3. SUPERMUN data          **********************
**********************                                    **********************    
********************************************************************************

u "$work/Master panel", clear


*look at cuts for maps

sum total_points, detail 
local varlist p25 p50 p75 max
foreach j in `varlist' {
local c_`j'     `r(`j')'
local l_c_`j' = round(`c_`j'', 1)
di "Check local: `c_`j'', and rounded value for graph labels `l_c_`j''"
}

*create a map for overview
preserve
collapse total_points, by(id_shapefile)
spmap total_points using "$raw/shapefiles/new shapefile/burkinacoord" , ///
	id(id_shapefile)  fcolor(RdBu)  ///
	clmethod(custom) clbreaks(0 `c_p25' `c_p50' `c_p75' `c_max') ///
	osize(thin ..) legend(position(1)) ///
	title("Average Total Points 2014-2018") legtitle("Average Total Points") ///
	legend(label(1 "No data") label(2 "1 to `l_c_p25' (25% of data)") label(3 "`l_c_p25' to `l_c_p50'(25% of data)" ) ///
	label(4 "`l_c_p50' to `l_c_p75' (25% of data)") label(5 "`l_c_p75' to `l_c_max' (25% of data)")  ) 
graph export "$output/2. Maps/1. Overall maps/SUPERMUN_average_total_p.png", replace

restore

 
*create maps per year
keep year id_shapefile fatalities fatalities_violent fatalities_demon fatalities_no_violent e_cat_1 e_cat_2 e_cat_3 total_events total_points

* reshape dataset to have one obs per id_shapefile 

reshape wide fatalities fatalities_violent fatalities_demon fatalities_no_violent e_cat_1 e_cat_2 e_cat_3 total_events total_points, i(id_shapefile) j (year)

*for total_points

forval i=2014/2018{
	
	
	spmap total_points`i' using "$raw/shapefiles/new shapefile/burkinacoord" , ///
	id(id_shapefile)  fcolor(RdBu)  ///
	clmethod(custom) clbreaks(0 `c_p25' `c_p50' `c_p75' `c_max') ///
	osize(thin ..) legend(position(1)) ///
	title("Total Points in `i'") legtitle("Total Points") ///
	legend(label(1 "No data") label(2 "1 to `l_c_p25'") label(3 "`l_c_p25' to `l_c_p50'" ) ///
	label(4 "`l_c_p50' to `l_c_p75'") label(5 "`l_c_p75' to `l_c_max' ")  ) 
	
graph export "$output/2. Maps/2. Gif creation/SUPERMUN_total_p_`i'.png", replace
	
}


clear all 	

