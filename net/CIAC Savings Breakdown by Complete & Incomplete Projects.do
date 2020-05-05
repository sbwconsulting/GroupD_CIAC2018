/*
File created by: Samantha Lamos
Purpose: CIAC Data Analysis for Report on unresponsive bias

*/

capture clear all
*capture log close
set more off
set segmentsize 3g
set maxvar 25000
set excelxlsxlargefile on

// Set Useful Folder Paths

global main "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Reporting"
global work "$main\Working Files"
global raw "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files"
global syntax "$main/Syntax"
exit

//Checking All Data file	
import excel using "$main/CIAC 2018 sample control file - add frames", firstrow clear
duplicates drop sbw_projid, force
export excel using "$main/CIAC 2018 sample control file- QC check.xlsx", firstrow(variables) sheetreplace


//Completed Projects Savings
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("Sampled Complete") clear

preserve
	collapse (sum) ExAnteFirstYearGrosskW ExAnteFirstYearGrosskWh ExAnteFirstYearGrossTherm ExAnteFirstYearNetkW ExAnteFirstYearNetkWh ExAnteFirstYearNetTherm ExAnteLifecycleGrosskW ExAnteLifecycleGrosskWh ExAnteLifecycleGrossTherm ExAnteLifecycleNetkW ExAnteLifecycleNetkWh ExAnteLifecycleNetTherm ExAnteGrossIncentive, by (SBW_ProjID)
	export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("Savings by Completes") firstrow(variables) sheetreplace
restore

//Unresponsive Projects Savings
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("Sampled Unresponsive") clear

preserve
	collapse (sum) ExAnteFirstYearGrosskW ExAnteFirstYearGrosskWh ExAnteFirstYearGrossTherm ExAnteFirstYearNetkW ExAnteFirstYearNetkWh ExAnteFirstYearNetTherm ExAnteLifecycleGrosskW ExAnteLifecycleGrosskWh ExAnteLifecycleGrossTherm ExAnteLifecycleNetkW ExAnteLifecycleNetkWh ExAnteLifecycleNetTherm ExAnteGrossIncentive, by (SBW_ProjID)
	export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("Savings by Incompletes") firstrow(variables) sheetreplace
restore


// # of Claims by Completes
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("Sampled Complete") clear
duplicates tag SBW_ProjID, generate(claim_flag)
replace claim_flag=claim_flag+1
order claim_flag
sort claim_flag
duplicates drop SBW_ProjID, force
tab claim_flag
export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("Sampled Completed Claims") firstrow(variables) sheetreplace


// # of Claims by Sampled Incomplete
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("Sampled Unresponsive") clear
duplicates tag SBW_ProjID, generate(claim_flag)
order claim_flag
sort claim_flag
replace claim_flag=claim_flag+1

duplicates drop SBW_ProjID, force
tab claim_flag
export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("Sampled Incomplete Claims") firstrow(variables) sheetreplace

// # of CLaims by Not Sampled
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("Not Sampled") clear
duplicates tag SBW_ProjID, generate(claim_flag)
order claim_flag
sort claim_flag
replace claim_flag=claim_flag+1

duplicates drop SBW_ProjID, force
tab claim_flag
export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("Not Sampled Claims") firstrow(variables) sheetreplace

// # of Claims by Sampled All
import excel using "$work/CIAC 2018 Savings completes v unresponsives.xlsx", firstrow sheet("All Sampled") clear
duplicates tag SBW_ProjID, generate(claim_flag)
order claim_flag
sort claim_flag
replace claim_flag=claim_flag+1

duplicates drop SBW_ProjID, force
tab claim_flag
export excel using "$main/CIAC Unresponsive Analysis.xlsx", sheet("All Sampled Claims") firstrow(variables) sheetreplace







