/*******************************************************************************

				Burkina Faso: 0. Master Do-File
							
			- Exploratory Analysis -
						  
			By:           Mariana Garcia
			Last updated: 27Feb2020
						  
      ----------------------------------------------------------
			  
	*Objective: understand better the increase in violence in Burkina Faso
	
	This file performs the following tasks:
		0. Preable (set globals)
		1. Cleaning ACLED and Shapefiles data
		2. Merge World Bank Data
		3. Visual Aids
		4. Maps
		
	*packeges 
	-ssc install shp2dta
	-ssc install spmap
			
*******************************************************************************/

********************************************************************************
**********************                                    **********************  
**********************           0. Preamble              **********************
**********************                                    **********************    
********************************************************************************

clear all
set more off
set mem 100m
set matsize 1000
capture log close

*Directories
cap conf f "C:\Windows\bootstat.dat"
if !_rc {
	global sys "WIN"
	*CHANGE HERE IF WIN
	global root 	 "C:\Users/`c(username)'\Dropbox\DIME Burkina Faso Portfolio\Data work"
	global data 	 "$root\2. Data"
	global raw       "$data\1. Raw"
	global work      "$data\2. Work"
	global output    "$root\4. Outputs"
	global graphs    "$output\1. Graphs"
	global maps      "$output\2. Maps"
	global logs      "$output\3. Logs"
	global dos		 "$root\3. DOs"
	}
else {
	global sys "MAC"
	*CHANGE HERE IF MAC
	global root      "/Users/`c(username)'/Dropbox/DIME Burkina Faso Portfolio/Data work"
	global data 	 "$root/2. Data"
	global raw 	     "$data/1. Raw"
	global work 	 "$data/2. Work"
	global output    "$root/4. Outputs"
	global graphs    "$output/1. Graphs"
	global maps      "$output/2. Maps"
	global logs      "$output/3. Logs"
	global dos		 "$root/3. DOs"
	}
	
	
* Open log file 	
	*log using "$LOGS", replace text
	
*install packeges

	ssc install shp2dta
	ssc install spmap
	
********************************************************
******      	  	   1. Cleaning              ********
****** Prepare ACLED and Shapefiles for  merge  ******** 
********************************************************

run "$dos/1. Cleaning.do"

********************************************************
*********              2. Merge               **********
****  Merge WB data in Long format, sorted by event  *** 
********************************************************

run "$dos/2. Merge.do"

********************************************************
************          3. Graphs             ************
************  Graph events  and fatalities  ************ 
********************************************************

run "$dos/3. Graphs.do"

********************************************************
************             4. Maps            ************
************    Map events and fatalities   ************ 
********************************************************

run "$dos/4. Maps.do"
