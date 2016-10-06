* Close previous log files

capture log close

* Create globals for file directories

global root "C:\Users\ARiel\Dropbox\AidData\Africa Social Capital\"
global logs "${root}/Logs"
global data "${root}/Data"
global tables "${root}/Tables"
global output "${root}/Output"

* Create directories

cap mkdir "${logs}"
cap mkdir "${tables}"

* Open log file

log using "${logs}/$S_DATE example .do file", text append


* Open data

use "locations_ratings_ethno_extract.dta", clear 

* Add few remaining variables

ge ieg_mod_sat = (ieg_outcome == 1) | (ieg_outcome == 3) if ieg_outcome!=. 

ge start_year = substr(start_actu, 1, 4)
destring start_year, force replace


bys project_id_n: egen count_loc = count(project_lo_n)
ge loc_weight_project = 1/count_loc

egen v107_ethno_n = group(v107_ethno)

* Analysis

reg ieg_mod_sat i.v33 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m1

reg ieg_mod_sat i.v30 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m2

reg ieg_mod_sat i.v30 i.v33 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m3	

reg ieg_mod_sat i.v33 gpw3_2000e ncc4_2012e i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m4
	
reg ieg_mod_sat i.v30 gpw3_2000e ncc4_2012e i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m5

reg ieg_mod_sat i.v30 i.v33 gpw3_2000e ncc4_2012e i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m6

	outreg2 using "${tables}/OLS regression",  ///
	excel /// 
	coefastr label  ///
	ctitle("Evaluation >= Moderately Satisfactory", OLS) ///
	 ///
	sortvar(v33 v30) ///
	append

esttab m1 m2 m3 m4 m5 m6 using "${tables}/OLS regression.csv", ///
	replace ///
	cells(b(star fmt(%9.3f)) se(par))                ///
    stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))      ///
    legend label collabels(none) varlabels(_cons Constant) ///
	mtitles("Evaluation >= Moderately Satisfactory")	///
	addnote("Weighted by N of locations per project, SEs clustered by country")

* Analysis - Sector by Sector (no lights/population)

levelsof major_sector, local(levels)
foreach 1 of local levels {
	quietly reg ieg_mod_sat i.v33 i.country i.start_year [pweight = loc_weight_project] if major_sector == `1', cluster(country) 
	eststo m1 

	quietly reg ieg_mod_sat i.v30 i.country i.start_year [pweight = loc_weight_project] if major_sector == `1', cluster(country)
	eststo m2
	
	quietly reg ieg_mod_sat i.v30 i.v33 i.country i.start_year [pweight = loc_weight_project] if major_sector == `1', cluster(country)
	eststo m3
	
		outreg2 using "${tables}/OLS regression sectors",  ///
		excel /// 
		coefastr label  ///
		ctitle("Evaluation >= Moderately Satisfactory", OLS) ///
		///
		sortvar(v33 v30) ///
		append

	esttab m1 m2 m3 using "${tables}/OLS regression sectors.csv", ///
		append ///
		cells(b(star fmt(%9.3f)) se(par))                ///
		stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))      ///
		legend label collabels(none) varlabels(_cons Constant) ///
		title ("OLS Regression Model using Sector" `1') ///
		mtitles("Evaluation >= Moderately Satisfactory")	///
		addnote("Weighted by N of locations per project, SEs clustered by country")
}
	

************** Analysis - Interactions of Sector and v33 ***********************
quietly reg ieg_mod_sat major_sector##v33 i.country i.start_year [pweight = loc_weight_project], cluster(country) 
eststo m1 

outreg2 using "${tables}/OLS regression interaction",  ///
	excel /// 
	coefastr label  ///
	ctitle("Evaluation >= Moderately Satisfactory", OLS) ///
	///
	sortvar(v33) ///
	append

esttab m1 using "${tables}/OLS regression interaction.csv", ///
	append ///
	cells(b(star fmt(%9.3f)) se(par))                ///
	stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))      ///
	legend label collabels(none) varlabels(_cons Constant) ///
	title ("OLS Regression Model using Interactions (Sector & v33)") ///
	mtitles("Evaluation >= Moderately Satisfactory")	///
	addnote("Weighted by N of locations per project, SEs clustered by country")
	
	
	
************* Analysis using the Extracted Point Level Data ********************	
* Open the Data
clear
use "${root}/Data/locs_ratings_ethno_extract_points.dta", clear 

replace gpw3_1995e_p = "." if gpw3_1995e_p == "NA"
replace gpw3_2000e_p = "." if gpw3_2000e_p == "NA"
replace dari_e_p = "." if dari_e_p == "NA"
replace dbri_e_p = "." if dbri_e_p == "NA"
replace droa_e_p = "." if droa_e_p == "NA"

destring gpw3_1995e_p gpw3_2000e_p dari_e_p dbri_e_p droa_e_p, replace

** Analysis **
quietly reg ieg_mod_sat i.v33 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m1

quietly reg ieg_mod_sat i.v30 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m2

quietly quietly reg ieg_mod_sat i.v30 i.v33 i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m3	

quietly reg ieg_mod_sat i.v33 gpw3_2000e_p ncc4_2012e_p i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m4
	
quietly reg ieg_mod_sat i.v30 gpw3_2000e_p ncc4_2012e_p i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m5

quietly reg ieg_mod_sat i.v30 i.v33 gpw3_2000e_p ncc4_2012e_p i.country i.major_sector i.start_year [pweight = loc_weight_project], cluster(country)
eststo m6

	outreg2 using "${tables}/OLS regression point",  ///
	excel /// 
	coefastr label  ///
	ctitle("Evaluation >= Moderately Satisfactory", OLS) ///
	 ///
	sortvar(v33 v30) ///
	append

esttab m1 m2 m3 m4 m5 m6 using "${tables}/OLS regression point.csv", ///
	replace ///
	cells(b(star fmt(%9.3f)) se(par))                ///
    stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))      ///
    legend label collabels(none) varlabels(_cons Constant) ///
	title ("OLS Regression Models using Point Level Data") ///
	mtitles("Evaluation >= Moderately Satisfactory")	///
	addnote("Weighted by N of locations per project, SEs clustered by country")

***Analysis: whether projects are more likely to be located in high v33 ethnicities***
* Open the Data
clear
use "${root}/Data/locs_ratings_ethno_extract_points.dta", clear 

* Collapse the data to the ethnicity level
preserve 
collapse (count) n_loc_ethno=project_lo_n (mean) v33_avg=v33, by(v107_ethno)
regress n_loc_ethno v33_avg
