/*
Created by: Samantha Lamos
Purpose: Unresponsive Bias in CIAC Sample

*/
capture clear all
capture log close
set more off
set min_memory 4g
set maxvar 25000
set excelxlsxlargefile on

// Set Useful Folder Paths
global main "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC"
global work "$main\Working Files"
//global clean "$main\Analysis"
global map "$main\Mapping Files"
global raw "$main\Raw"
global syntax "$main\Syntax"
exit

use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files\ciac_all_completes.dta", clear
keep completed sampleid sbw_projid
save "$work\CIAC All Completes IDs.dta", replace

import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_All Sample with added Net Sample.xlsx", firstrow clear
merge 1:m sampleid sbw_projid using "$work\CIAC All Completes IDs.dta"
save "$main\Reporting\CIAC All Completes.dta", replace

format %24s sbw_projid

// Compare Programs
tab PROGRAM
gen clean_PROGRAM = PROGRAM
replace clean_PROGRAM = "Agricultural Calculated Incentives Program" if regexm(PROGRAM, "Agricultural Calculated")
replace clean_PROGRAM = "Agricultural Calculated Incentives Program" if regexm(PROGRAM, "Agriculture Calculated")
replace clean_PROGRAM = "Association Of Monterey Bay Area Governments (Ambag)" if regexm(PROGRAM, "Association of Monterey Bay")
replace clean_PROGRAM = "California Community Colleges Energy Efficiency Partnership" if regexm(PROGRAM, "California Community Colleges")
replace clean_PROGRAM = "COM-Calculated Incentives Program" if regexm(PROGRAM, "Com-Calculated Incentives")
replace clean_PROGRAM = "Commercial Calculated Incentives Program" if regexm(PROGRAM, "Commercial Calculated Incentives")
replace clean_PROGRAM = "Commercial Calculated Incentives Program" if regexm(PROGRAM, "Commercial Calculated")
replace clean_PROGRAM = "Comprehensive Food Process Audit & Resource Efficiency Program" if regexm(PROGRAM, "Comprehensive Food Process") 
replace clean_PROGRAM = "Comprehensive Petroleum Refining Program" if PROGRAM == "Comprehensive Petroleum Refining"
replace clean_PROGRAM = "Cool Schools Program" if PROGRAM == "Cool Schools"
replace clean_PROGRAM = "Dairy and Winery Industry Efficiency Solutions Program" if regexm(PROGRAM, "Dairy And Winery")
replace clean_PROGRAM = "Data Center Energy Efficiency Program" if regexm(PROGRAM, "Data Center")
replace clean_PROGRAM = "Department of Corrections and Rehabilitation Program" if regexm(PROGRAM, "Department Of Corrections")
replace clean_PROGRAM = "Energy Efficiency Services for Oil Production Program" if regexm(PROGRAM, "Energy Efficiency Services For Oil")
replace clean_PROGRAM = "EnergySmart Grocer Program" if regexm(PROGRAM, "Energysmart Grocer")
replace clean_PROGRAM = "Food & Kindred Products Program" if regexm(PROGRAM, "Food & Kindred")
replace clean_PROGRAM = "Healthcare Energy Efficiency Program" if regexm(PROGRAM, "Healthcare EE")
replace clean_PROGRAM = "Healthcare Energy Efficiency Program" if regexm(PROGRAM, "Healthcare Ee")
replace clean_PROGRAM = "High Desert Regional Energy Leader Partnership Program" if regexm(PROGRAM, "High Desert")
replace clean_PROGRAM = "Industrial Calculated Energy Efficiency Program" if regexm(PROGRAM, "IND-Calculated Incentives Program")
replace clean_PROGRAM = "Industrial Calculated Energy Efficiency Program" if regexm(PROGRAM, "Industrial Calculated")
replace clean_PROGRAM = "Kern Program" if regexm(PROGRAM, "Kern")
replace clean_PROGRAM = "LED Accelerator Program" if regexm(PROGRAM, "Led Accelerator")
replace clean_PROGRAM = "Mendocino/Lake County Program" if regexm(PROGRAM, "Mendocino/Lake County")
replace clean_PROGRAM = "Multifamily Energy Efficiency Program" if regexm(PROGRAM, "Multifamily Energy Efficiency")
replace clean_PROGRAM = "Primary and Fabricated Metals Program" if regexm(PROGRAM, "Primary And Fabricated Metals")
replace clean_PROGRAM = "Savings By Design" if regexm(PROGRAM, "Savings by Design")
replace clean_PROGRAM = "Savings By Design" if regexm(PROGRAM, "Savings By Design")
replace clean_PROGRAM = "Silicon Valley Program" if regexm(PROGRAM, "Silicon Valley")
replace clean_PROGRAM = "Small Commercial Program" if regexm(PROGRAM, "Small Commercial")
replace clean_PROGRAM = "Sonoma County Program" if regexm(PROGRAM, "Sonoma County")
replace clean_PROGRAM = "State Of California Energy Efficiency Partnership" if regexm(PROGRAM, "State Of California")
replace clean_PROGRAM = "UC/CSU Energy Efficiency Partnership Program" if regexm(PROGRAM, "Uc/Csu Energy Efficiency Partnership")
replace clean_PROGRAM = "UC/CSU Energy Efficiency Partnership Program" if regexm(PROGRAM, "University of California")
replace clean_PROGRAM = "UC/CSU Energy Efficiency Partnership Program" if regexm(PROGRAM, "University Of California")
replace clean_PROGRAM = "Water Infrastructure Systems Energy Efficiency Program" if regexm(PROGRAM, "Water Infrastructure")
replace clean_PROGRAM = "Agricultural Calculated Incentives Program" if regexm(PROGRAM, "AG-Calculated")
replace clean_PROGRAM = "Agricultural Energy Advisor Program" if regexm(PROGRAM, "Agricultural Energy Advisor")
replace clean_PROGRAM = "HOPPs - Building Retro-Commissioning Program" if regexm(PROGRAM, "Hopps - Building Retro-Commissioning")
replace clean_PROGRAM = "San Mateo County Program" if regexm(PROGRAM, "San Mateo County")

tab2xl clean_PROGRAM completed using "$main\Reporting\CIAC Unresponsive Analysis.xlsx", col (10) row(1)
tab2xl clean_PROGRAM using "$main\Reporting\CIAC Unresponsive Analysis.xlsx", col (15) row(1)

// Compare Utilities
tab PA
tab2xl PA completed using "$main\Reporting\CIAC Unresponsive Analysis.xlsx", col(1) row(1) 
tab2xl PA using "$main\Reporting\CIAC Unresponsive Analysis.xlsx", col(5) row(1) 

// Compare Incentives? Not enough information to compare accurately- only 61 observations


// Compare ExAnte Savings 
