/*******************************************************************************

				Burkina Faso: 0. Master Do-File
							
			- Exploratory Analysis -
						  
			By:           Mariana Garcia
			Last updated: 10Apr2020
						  
      ----------------------------------------------------------
			  
	*Objective: understand better the increase in violence in Burkina Faso
	
	This file performs the following tasks:
		0. Preable (set globals)
		1. Cleaning ACLED and Shapefiles data
		2. Merge World Bank Data
		3. Visual Aids
		4. Maps
		5. Fixed Effects Analysis
		
	*packeges 
	-ssc install shp2dta
	-ssc install spmap
	-ssc install outreg2
			
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
*capture log close


**********************               USERS                **********************  
/*
 User Number:
   * Mariana                 1    
   * User2                   2    // Assign a user number to each additional collaborator 
   * User3                   3    // Assign a user number to each additional collaborator 
*/    

 *Set this value to the user currently using this file
 global user  1

   
 *Add here YOUR globals for GitHub and Veracrypt
   
   if $user == 1 {
       global github "/Users/Home/Documents/GitHub/Burkina-Faso-Conflict-SUPERMUN"
	   global vera   ""
   }

   if $user == 2 {
       global github ""  // Enter the file path to the project folder for the next user here
	   global vera   ""  //Please note that you need the path to be "mounted" in Veracrypt
   }


   if $user == 3 {
       global github ""  // Enter the file path to the project folder for the next user here
	   global vera   ""  //Please note that you need the path to be "mounted" in Veracrypt
   }



**********************             Directories             ********************** 


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
	global dos		 "$github"
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
	global dos		 "$github"
	}
	
	
* Open log file 	
	*log using "$LOGS", replace text
	
*install packeges

	ssc install shp2dta
	ssc install spmap
	ssc install outreg2
	
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

********************************************************
************          5. Analysis           ************
************       Fixed effects analysis   ************ 
********************************************************

run "$dos/5. Analysis.do"
