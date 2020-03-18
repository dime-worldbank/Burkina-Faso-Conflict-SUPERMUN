
/*******************************************************************************

				Burkina Faso: 1. Cleaning
							
			- Exploratory Analysis -
						  
			By:   		  Mariana Garcia
			Last updated: 28Feb2020
						  
      ----------------------------------------------------------
			  
	*Objective: Clean datasets for merging
	
	This file performs the following tasks:
		1. Cleaning of Shapefiles data
		2. Cleaning of ACLED data 
		
			
*******************************************************************************/

clear all

********************************************************************************
**********************                                    **********************  
**********************       1. Cleaning Shapefiles       **********************
**********************                                    **********************    
********************************************************************************



***************************  1.0 Read shapefiles  ******************************

shp2dta using "$raw/shapefiles/new shapefile/BFA_adm3.shp", database("$raw/shapefiles/new shapefile/burkinafaso") coordinates("$raw/shapefiles/new shapefile/burkinacoord") genid(id_shapefile) gencentroids(Shape) replace

***************************  1.1 Format dataset ********************************

	
	*Format with UTF-8, set format so stata can read it
	*Note: unicode needs dataset to be in the cd
	cd "$raw/shapefiles/new shapefile"
	unicode encoding set latin1
	unicode translate burkinafaso.dta

	
****************************  1.2 Clean dataset  *******************************


	u "$raw/shapefiles/new shapefile/burkinafaso", clear
	 
	*Run program accents
	run "$dos/1.1 Accent.do" 
	
	*Use accent program
	accent NAME_2
	accent NAME_3 

	rename NAME_1 region
	rename NAME_2 province
	rename NAME_3 commune

	
	*Correct names

	
	*communes
	replace commune = "Coalla"			if commune == "Koalla"	
	replace commune = "Arbinda"         if commune == "Aribinda"
	replace commune = "Fada N'Gourma"	if commune == "Fada N'gourma"
	replace commune = "N'Dorola"		if commune == "N'dorola"
	rename  commune commune_edited	
	
	
    *province
	replace province = "Komandjari"    if province == "Komandjoari"
			
	*region 
	replace region = "Hauts-Bassins"   if region == "Haut-Bassins"

	
	*keep variables useful for the analysis
	keep  id_shapefile region province commune x_Shape y_Shape VARNAME_3
	
	order  id_shapefile region province commune x_Shape y_Shape
	
	*Fix names to match WB database
	
		*Upper case to match WB data
	foreach var in  commune province region {
		replace `var' = upper(`var')
		}
	
	*communes
	replace commune_edited = "GOROM -GOROM" 	  if commune_edited ==  "GOROM-GOROM"
	replace commune_edited = "ZIMTANGA"           if commune_edited ==  "ZIMTENGA"
	replace commune_edited = "SOUBAKANIE-DOUGOU"  if commune_edited ==  "SOUBAKANIEDOUGOU"
	replace commune_edited = "ARBOLE" 			  if commune_edited ==  "ARBOLLE"  
	replace commune_edited = "IMASGO" 			  if commune_edited ==  "IMASGHO"  
	
	*regions

	replace region = "PLATEAU CENTRAL" if region == "PLATEAU-CENTRAL"

	*correct names
	replace province= "IOBA"   						   if province == "BOUGOURIBA" & commune_edited == "GUEGUERE"
	replace commune_edited = "NAMISSIGUIMA OUAHIGOUYA" if province == "YATENGA"    & commune_edited == "NAMISSIGUIMA"
			


*****************   1.3 Save clean dataset in work folder **********************

	sa "$work/maps/burkinafaso", replace
	
********************************************************************************
**********************                                    **********************  
**********************            2. ACLED data           **********************
**********************                                    **********************    
********************************************************************************

*****************************   2.0 Import data   ******************************
	
	
	import delimited "$raw/20200124_acled.csv",   clear

*****************************   2.1 Clean dataset   ****************************

		keep event_date year time_precision event_type sub_event_type actor1 assoc_actor_1 inter1 actor2 assoc_actor_2 inter2 interaction admin1 admin2 admin3 location latitude longitude geo_precision source notes fatalities

	*For now, drop obs for 2020 
	drop if year == 2020
	
	*Rename vars as WB dataset
		rename admin1 region
		rename admin2 province
		rename admin3 commune
	
	
	*Correct names
		*commune
		
			replace commune= "Fada N'Gourma"  	 if commune== "Fada Ngourma"
			replace commune= "Comin-Yanga"    	 if commune== "Komin-Yanga"
			replace commune= "Komsilga"      	 if commune== "Komsliga"	
			replace commune= "N'Dorola"       	 if commune== "Ndorola"	
			replace commune= "Zimtenga"       	 if commune== "Zimtanga"
			replace commune= "Mani"			  	 if commune== "Manni"
			replace commune= "Karankasso-Sambla" if commune== "Karangasso-Sambla"	
			replace commune= "Karankasso-Vigue"  if commune== "Karangasso-Vigue"
		
		*province
	
			replace province="Komandjari"     	 if province=="Komonjdjari" 
			
			
	*Fix regions and provinces wrongly allocated to a commune
			replace province = "Sanmatenga"      if province== "Soum"        & commune== "Barsalogho"
			replace region   = "Centre-Nord"     if region==   "Sahel"       & commune== "Barsalogho"
			replace province = "Sissili"         if province== "Ziro"        & commune== "Leo"
			replace province = "Kompienga"       if province== "Tapoa"       & commune== "Madjoari"
			replace province = "Loroum"          if province== "Yatenga"     & commune== "Ouindigui"
			replace province = "Ganzourgou"      if province== "Kouritenga"  & commune== "Zorgho"
			replace region   = "Plateau-Central" if region==   "Centre-Est"  & commune== "Zorgho"
 
	*Wrong names of communes (drop for now)
	*[!]  commune values that are commune according to WB data -> missing value
			drop if commune=="Ioba" //its a province
			drop if commune=="Oudalan" //its a province
			drop if commune=="Ouanobian" //no mention of this 
			drop if commune=="Petegoli" //no mention of this 
			drop if commune=="Rapadama" //no mention of this 
			drop if commune=="Saben" //no mention of this 


		*Rename commune
		ren commune commune_edited
		
*Fix names to match WB database
	
		*Upper case to match WB data
	foreach var in  commune commune_edited province region {
		replace `var' = upper(`var')
		}

	
	*communes
	replace commune_edited = "GOROM -GOROM" 	  if commune_edited ==  "GOROM-GOROM"
	replace commune_edited = "ZIMTANGA"           if commune_edited ==  "ZIMTENGA"
	replace commune_edited = "SOUBAKANIE-DOUGOU"  if commune_edited ==  "SOUBAKANIEDOUGOU"
	replace commune_edited = "ARBOLE" 			  if commune_edited ==  "ARBOLLE"  
	replace commune_edited = "IMASGO" 			  if commune_edited ==  "IMASGHO"  
	
	*regions

	replace region = "PLATEAU CENTRAL" if region == "PLATEAU-CENTRAL"

	*correct names
	replace province= "IOBA"   						   if province == "BOUGOURIBA" & commune_edited == "GUEGUERE"
	replace commune_edited = "NAMISSIGUIMA OUAHIGOUYA" if province == "YATENGA"    & commune_edited == "NAMISSIGUIMA"
			
************************    2.2 Variables creation     *************************


	*Missing values
	replace assoc_actor_1="No information" if assoc_actor_1==""
	
	*Create an auxiliary variable for easy counting
	gen no_event= 1
	
	
	*Variable formatting/labeling 

			
			*Format time variables
			gen double date_event=.
			replace date_event=date(event_date, "DMY", 2019 )
			format %td date_event 
			drop event_date
			
				*Create a month/year var 
				gen month_year= mofd(date_event)
				format month_year %tm  
				order date_event month_year year
			
			

			 *Transform string variables to numerical for easy manipulation 
			 foreach i of varlist event_type location  {
			 encode `i', g(`i'_aux)
			 drop `i'
			 ren `i'_aux `i'
			}
			
			*recode event_type
			recode event_type (6=3) (3=5) (5=6)
			
			*edit label
			label drop event_type_aux
			label define event_type 1 "Battles" 2 "Explosions/Remote violence"  ///
			3 "Violence against civilians" ///
			4 "Riots" 5 "Protests" 6 "Strategic developments"
			
			label values event_type event_type
			
			
			*Generate category for events
			gen event_cat=. 
			replace event_cat=1 if event_type <4
			replace event_cat=2 if event_type >=4 & event_type <6
			replace event_cat=3 if event_type==6
			
			label define event_cat 1 "Violent events" 2 "Demonstrations" 3 "Non-violent actions"
			label values event_cat  event_cat
			
	*Labels for better data visualization 
	
			*variables
			label var inter1      "Actor 1"
			label var inter2      "Actor 2"
			label var no_event    "Number of Events"
			label var fatalities  "Number of Fatalities"
			label var event_cat   "Category of Events"
			label var event_type  "Sub-category of Events"
			
			*observations
			label define inter 0 "No second actor" 1 "State Forces" 2 "Rebel Groups" ///
			3 "Political Militias" 4 "Identity Militias" 5 "Rioters" 6 "Protesters"  ///
			7 "Civilians" 8 "External/Other Forces" 
			label values inter1 inter
			label values inter2 inter

	
******************  2.3 Create unique id for each event   **********************


/* Note: the folowing variables do not uniquely identify the event:
date_event event sub_event_type actor1 assoc_actor_1 actor2 location fatalities */
	
	duplicates tag date_event event_type sub_event_type inter1 assoc_actor_1 inter2 location fatalities, g(dup) 
	
	***Note: 38 duplicates, surplus of 19 obs
	
	
    *Save duplicates for record keeping
	preserve
	drop if dup==0
	export excel using "$work/excel/duplicates_acled", firstrow(var) replace
	restore
	
	*Analyze duplicates by case
	bys date_event event_type sub_event_type inter1 assoc_actor_1 inter2 location fatalities: gen dup_aux= _n
	
	
		*Drop second observation of duplicates for dates 8Apr2011 - notes suggest that it's the same event. For more info, review the file "$work/excel/duplicates_acled.xlsx"
		drop if dup>0 & date_event<=td(08Apr2011) & dup_aux==2  /// 13 obs delated
	
	
		*Six remaining cases. It was decided to consider the following cases as duplicates: 
		*19May2014
		drop if dup>0 & date_event==td(19May2014) & dup_aux==2  /// 1 obs delated
		
		
		*30Oct2014
		drop if dup>0 & date_event==td(30Oct2014) & dup_aux==2  /// 1 obs delated
		
	
	*Generate ID for each event
	egen id_event_aux= group(date_event event_type sub_event_type inter1 assoc_actor_1 inter2 location fatalities)
	
	gen id_event= "ACLED"+ "_" + string(id_event_aux,"%02.0f") + "_" + string(dup_aux, "%02.0f")
	
	drop dup dup_aux id_event_aux
	move id_event date_event
	
	*check if id uniquely identifies the events
	isid id_event 

	
***************************   2.4 Save dataset  *******************************
	
	order id_event date_event month_year year region province commune_edited commune ///
	event_type fatalities
	
	*save dataset in both excel and stata formats
	sort region province commune_edited year, stable
	export excel  using "$work/excel/acled_long", replace firstrow(var)
	sa "$work/acled/acled_long", replace
	
