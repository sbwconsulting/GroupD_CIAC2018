********************************
Created By: Samantha Lamos
Purpose: Cleaning Survey Data from Qualtrics
Date: 2020-2-6

********************************
capture clear all
*capture log close
set more off
set segmentsize 3g
set maxvar 25000
set excelxlsxlargefile on

// Set Useful Folder Paths
global main "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Enhanced\Quantitative Survey Data"
global work "$main\Working Files"
global syntax "$main\Syntax"
exit

//Import raw survey data
import excel "$main\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics REVISED.xlsx", sheet("CIAC Basic, Standard, Enhanced ") firstrow clear
drop rigor
rename B rigor
rename A sampleid
drop if sampleid == ""
drop if sampleid == "Project ID"
destring rigor, replace
destring sampleid, replace
//Drop responses based on Rigor

//Rigor 1 & 2 cleaning
replace n3aa="" if rigor==1
replace n3aa_1_text="" if rigor==1
replace n3aa_2="" if rigor==1
replace n3aa_2_1_text="" if rigor==1
replace n3aa_3="" if rigor==1
replace n3aa_3_1_text="" if rigor==1

replace n3bb="" if rigor==1
replace n3bb_0_text="" if rigor==1
replace n3bb_2="" if rigor==1
replace n3bb_2_0_text="" if rigor==1
replace n3bb_3="" if rigor==1
replace n3bb_3_0_text="" if rigor==1

replace n3cc="" if rigor==1
replace n3cc_0_text="" if rigor==1
replace n3cc_2="" if rigor==1
replace n3cc_2_0="" if rigor==1
replace n3cc_3="" if rigor==1
replace n3cc_3_0_text="" if rigor==1

replace n3dd="" if rigor==1
replace n3dd_0_text="" if rigor==1
replace n3dd_2="" if rigor==1
replace n3dd_2_0_text="" if rigor==1
replace n3dd_3="" if rigor==1
replace n3dd_3_0_text="" if rigor==1


replace n3ff="" if rigor==1
replace n3ff_0_text="" if rigor==1
replace n3ff_2="" if rigor==1
replace n3ff_2_0_text="" if rigor==1
replace n3ff_3="" if rigor==1
replace n3ff_3_0_text="" if rigor==1

replace n3gg="" if rigor==1
replace n3gg_0_text="" if rigor==1
replace n3gg_2="" if rigor==1
replace n3gg_2_0_text="" if rigor==1
replace n3gg_3="" if rigor==1
replace n3gg_3_0_text="" if rigor==1

replace n3hh="" if rigor==1
replace n3hh_0_text="" if rigor==1
replace n3hh_2="" if rigor==1
replace n3hh_2_0_text="" if rigor==1
replace n3hh_3="" if rigor==1
replace n3hh_3_0_text="" if rigor==1

replace n3ll="" if rigor==1
replace n3ll_0_text="" if rigor==1
replace n3ll_2="" if rigor==1
replace n3ll_2_0_text="" if rigor==1
replace n3ll_3="" if rigor==1
replace n3ll_3_0_text="" if rigor==1

replace n3oo="" if rigor==1
replace n3oo_0_text="" if rigor==1
replace n3oo_2="" if rigor==1
replace n3oo_2_0_text="" if rigor==1
replace n3oo_3="" if rigor==1
replace n3oo_3_0_text="" if rigor==1

replace n3pp="" if rigor==1
replace n3pp_0_text="" if rigor==1
replace n3pp_2="" if rigor==1
replace n3pp_2_0_text="" if rigor==1
replace n3pp_3="" if rigor==1
replace n3pp_3_0_text="" if rigor==1

replace n3rr="" if rigor==1
replace n3rr_0_text="" if rigor==1
replace n3rr_2="" if rigor==1
replace n3rr_2_0_text="" if rigor==1
replace n3rr_3="" if rigor==1
replace n3rr_3_0_text="" if rigor==1

replace n3ttt="" if rigor==1
replace n3ttt_0_text="" if rigor==1
replace n3ttt_2="" if rigor==1
replace n3ttt_2_0_text="" if rigor==1
replace n3ttt_3="" if rigor==1
replace n3ttt_3_0_text="" if rigor==1

replace a4a="" if rigor == 1
replace a4a="" if rigor == 2

replace n3kk1="" if rigor ==1
replace n3kk1="" if rigor ==2
replace n3kk1_1_text="" if rigor ==1
replace n3kk1_1_text="" if rigor ==2
replace n3kk1_2="" if rigor ==1
replace n3kk1_2="" if rigor ==2
replace n3kk1_2_1_text="" if rigor ==1
replace n3kk1_2_1_text="" if rigor ==2
replace n3kk1_3="" if rigor ==1
replace n3kk1_3="" if rigor ==2
replace n3kk1_3_1_text="" if rigor ==1
replace n3kk1_3_1_text="" if rigor ==2


replace n3kk2="" if rigor ==1
replace n3kk2="" if rigor ==2
replace n3kk2_1_text="" if rigor ==1
replace n3kk2_1_text="" if rigor ==2
replace n3kk2_2="" if rigor ==1
replace n3kk2_2="" if rigor ==2
replace n3kk2_2_1_text="" if rigor ==1
replace n3kk2_2_1_text="" if rigor ==2
replace n3kk2_3="" if rigor ==1
replace n3kk2_3="" if rigor ==2
replace n3kk2_3_1_text="" if rigor ==1
replace n3kk2_3_1_text="" if rigor ==2

replace fino="" if rigor==1
replace fino="" if rigor==2
replace fino_2="" if rigor==1
replace fino_2="" if rigor==2

replace fin1_1="" if rigor==1
replace fin1_2="" if rigor==1
replace fin1_3="" if rigor==1
replace fin1_2_1="" if rigor==1
replace fin1_2_2="" if rigor==1
replace fin1_2_3="" if rigor==1
replace fin1_3_1="" if rigor==1
replace fin1_3_2="" if rigor==1
replace fin1_3_3="" if rigor==1

replace fin1_1="" if rigor==2
replace fin1_2="" if rigor==2
replace fin1_3="" if rigor==2
replace fin1_2_1="" if rigor==2
replace fin1_2_2="" if rigor==2
replace fin1_2_3="" if rigor==2
replace fin1_3_1="" if rigor==2
replace fin1_3_2="" if rigor==2
replace fin1_3_3="" if rigor==2

replace fin7_2__99 ="" if rigor==1
replace fin7_2_0_text="" if rigor==1
replace fin7_3_1="" if rigor==1
replace fin7_3_2 ="" if rigor==1
replace fin7_3_3 ="" if rigor==1
replace fin7_3_4="" if rigor==1 
replace fin7_3_0 ="" if rigor==1
replace fin7_3__98 ="" if rigor==1
replace fin7_3__99 ="" if rigor==1
replace fin7_3_0_text="" if rigor==1

replace fin7_2__99 ="" if rigor==2
replace fin7_2_0_text="" if rigor==2
replace fin7_3_1="" if rigor==2
replace fin7_3_2 ="" if rigor==2
replace fin7_3_3 ="" if rigor==2
replace fin7_3_4="" if rigor==2
replace fin7_3_0 ="" if rigor==2
replace fin7_3__98 ="" if rigor==2
replace fin7_3__99 ="" if rigor==2
replace fin7_3_0_text="" if rigor==2

replace fin8_1 ="" if rigor==1
replace fin8_2 ="" if rigor==1
replace fin8_3 ="" if rigor==1
replace fin8_4 ="" if rigor==1
replace fin8_5 ="" if rigor==1
replace fin8_6 ="" if rigor==1
replace fin8_7 ="" if rigor==1
replace fin8_8 ="" if rigor==1
replace fin8_9="" if rigor==1
replace fin8_10="" if rigor==1
replace fin8_0 ="" if rigor==1
replace fin8__98="" if rigor==1
replace fin8__99="" if rigor==1
replace fin8_0_text ="" if rigor==1
replace fin8_2_1 ="" if rigor==1
replace fin8_2_2 ="" if rigor==1
replace fin8_2_3 ="" if rigor==1
replace fin8_2_4 ="" if rigor==1
replace fin8_2_5 ="" if rigor==1
replace fin8_2_6 ="" if rigor==1
replace fin8_2_7 ="" if rigor==1
replace fin8_2_8 ="" if rigor==1
replace fin8_2_9 ="" if rigor==1
replace fin8_2_10="" if rigor==1
replace fin8_2_0 ="" if rigor==1
replace fin8_2__98 ="" if rigor==1
replace fin8_2__99 ="" if rigor==1
replace fin8_2_0_text="" if rigor==1
replace fin8_3_1="" if rigor==1
replace fin8_3_2 ="" if rigor==1
replace fin8_3_3 ="" if rigor==1
replace fin8_3_4 ="" if rigor==1
replace fin8_3_5 ="" if rigor==1
replace fin8_3_6 ="" if rigor==1
replace fin8_3_7 ="" if rigor==1
replace fin8_3_8 ="" if rigor==1
replace fin8_3_9 ="" if rigor==1
replace fin8_3_10="" if rigor==1
replace fin8_3_0 ="" if rigor==1
replace fin8_3__98="" if rigor==1
replace fin8_3__99 ="" if rigor==1
replace fin8_3_0_text="" if rigor==1

replace fin8_1 ="" if rigor==2
replace fin8_2 ="" if rigor==2
replace fin8_3 ="" if rigor==2
replace fin8_4 ="" if rigor==2
replace fin8_5 ="" if rigor==2
replace fin8_6 ="" if rigor==2
replace fin8_7 ="" if rigor==2
replace fin8_8 ="" if rigor==2
replace fin8_9="" if rigor==2
replace fin8_10="" if rigor==2
replace fin8_0 ="" if rigor==2
replace fin8__98="" if rigor==2
replace fin8__99="" if rigor==2
replace fin8_0_text ="" if rigor==2
replace fin8_2_1 ="" if rigor==2
replace fin8_2_2 ="" if rigor==2
replace fin8_2_3 ="" if rigor==2
replace fin8_2_4 ="" if rigor==2
replace fin8_2_5 ="" if rigor==2
replace fin8_2_6 ="" if rigor==2
replace fin8_2_7 ="" if rigor==2
replace fin8_2_8 ="" if rigor==2
replace fin8_2_9 ="" if rigor==2
replace fin8_2_10="" if rigor==2
replace fin8_2_0 ="" if rigor==2
replace fin8_2__98 ="" if rigor==2
replace fin8_2__99 ="" if rigor==2
replace fin8_2_0_text="" if rigor==2
replace fin8_3_1="" if rigor==2
replace fin8_3_2 ="" if rigor==2
replace fin8_3_3 ="" if rigor==2
replace fin8_3_4 ="" if rigor==2
replace fin8_3_5 ="" if rigor==2
replace fin8_3_6 ="" if rigor==2
replace fin8_3_7 ="" if rigor==2
replace fin8_3_8 ="" if rigor==2
replace fin8_3_9 ="" if rigor==2
replace fin8_3_10="" if rigor==2
replace fin8_3_0 ="" if rigor==2
replace fin8_3__98="" if rigor==2
replace fin8_3__99 ="" if rigor==2
replace fin8_3_0_text="" if rigor==2

replace p1_1 ="" if rigor==1
replace p1_2 ="" if rigor==1
replace p1_0 ="" if rigor==1
replace p1__98 ="" if rigor==1
replace p1__99="" if rigor==1
replace p1_0_text="" if rigor==1
replace p1_2_1 ="" if rigor==1
replace p1_2_2 ="" if rigor==1
replace p1_2_0 ="" if rigor==1
replace p1_2__98 ="" if rigor==1
replace p1_2__99 ="" if rigor==1
replace p1_2_0_text="" if rigor==1
replace p1_3_1 ="" if rigor==1
replace p1_3_2 ="" if rigor==1
replace p1_3_0 ="" if rigor==1
replace p1_3__98 ="" if rigor==1
replace p1_3__99 ="" if rigor==1
replace p1_3_0_text="" if rigor==1

replace p1_1 ="" if rigor==2
replace p1_2 ="" if rigor==2
replace p1_0 ="" if rigor==2
replace p1__98 ="" if rigor==2
replace p1__99="" if rigor==2
replace p1_0_text="" if rigor==2
replace p1_2_1 ="" if rigor==2
replace p1_2_2 ="" if rigor==2
replace p1_2_0 ="" if rigor==2
replace p1_2__98 ="" if rigor==2
replace p1_2__99 ="" if rigor==2
replace p1_2_0_text="" if rigor==2
replace p1_3_1 ="" if rigor==2
replace p1_3_2 ="" if rigor==2
replace p1_3_0 ="" if rigor==2
replace p1_3__98 ="" if rigor==2
replace p1_3__99 ="" if rigor==2
replace p1_3_0_text="" if rigor==2

replace p2a ="" if rigor==1
replace p2b ="" if rigor==1
replace p2b_0_text="" if rigor==1
replace p2a_2 ="" if rigor==1
replace p2b_2 ="" if rigor==1
replace p2b_2_0_text="" if rigor==1
replace p2a_3 ="" if rigor==1
replace p2b_3 ="" if rigor==1
replace p2b_3_0_text="" if rigor==1

replace p2a ="" if rigor==2
replace p2b ="" if rigor==2
replace p2b_0_text="" if rigor==2
replace p2a_2 ="" if rigor==2
replace p2b_2 ="" if rigor==2
replace p2b_2_0_text="" if rigor==2
replace p2a_3 ="" if rigor==2
replace p2b_3 ="" if rigor==2
replace p2b_3_0_text="" if rigor==2

replace p3 ="" if rigor==1
replace p3a ="" if rigor==1
replace p3a_0_text ="" if rigor==1
replace p3e ="" if rigor==1
replace p3e_0_text="" if rigor==1
replace p4="" if rigor==1
replace p4_2="" if rigor==1
replace p4_3="" if rigor==1

replace p3 ="" if rigor==2
replace p3a ="" if rigor==2
replace p3a_0_text ="" if rigor==2
replace p3e ="" if rigor==2
replace p3e_0_text="" if rigor==2
replace p4="" if rigor==2
replace p4_2="" if rigor==2
replace p4_3="" if rigor==2

replace cp1 ="" if rigor==1
replace cp1a ="" if rigor==1
replace cp1a_0_text ="" if rigor==1
replace cp1_2 ="" if rigor==1
replace cp1a_2 ="" if rigor==1
replace cp1a_2_0_text ="" if rigor==1
replace cp1_3 ="" if rigor==1
replace cp1a_3 ="" if rigor==1
replace cp1a_3_0_text="" if rigor==1

replace cp1 ="" if rigor==2
replace cp1a ="" if rigor==2
replace cp1a_0_text ="" if rigor==2
replace cp1_2 ="" if rigor==2
replace cp1a_2 ="" if rigor==2
replace cp1a_2_0_text ="" if rigor==2
replace cp1_3 ="" if rigor==2
replace cp1a_3 ="" if rigor==2
replace cp1a_3_0_text="" if rigor==2

replace cp2 ="" if rigor==1
replace cp2_0_text ="" if rigor==1
replace cp2_2 ="" if rigor==1
replace cp2_2_0_text ="" if rigor==1
replace cp2_3 ="" if rigor==1
replace cp2_3_0_text="" if rigor==1

replace cp2 ="" if rigor==2
replace cp2_0_text ="" if rigor==2
replace cp2_2 ="" if rigor==2
replace cp2_2_0_text ="" if rigor==2
replace cp2_3 ="" if rigor==2
replace cp2_3_0_text="" if rigor==2

replace cp3 ="" if rigor==1
replace cp3a ="" if rigor==1
replace cp3a_0_text="" if rigor==1
replace cp3_2 ="" if rigor==1
replace cp3a_2="" if rigor==1
replace cp3a_2_0_text="" if rigor==1
replace cp3_3 ="" if rigor==1
replace cp3a_3="" if rigor==1
replace cp3a_3_0_text="" if rigor==1
 
replace cp3 ="" if rigor==2
replace cp3a ="" if rigor==2
replace cp3a_0_text="" if rigor==2
replace cp3_2 ="" if rigor==2
replace cp3a_2="" if rigor==2
replace cp3a_2_0_text="" if rigor==2
replace cp3_3 ="" if rigor==2
replace cp3a_3="" if rigor==2
replace cp3a_3_0_text="" if rigor==2

replace cp4="" if rigor==1
replace cp4_0_text="" if rigor==1
replace cp4_2="" if rigor==1
replace cp4_2_0_text="" if rigor==1
replace cp4_3="" if rigor==1
replace cp4_3_0_text="" if rigor==1
 
replace cp4="" if rigor==2
replace cp4_0_text="" if rigor==2
replace cp4_2="" if rigor==2
replace cp4_2_0_text="" if rigor==2
replace cp4_3="" if rigor==2
replace cp4_3_0_text="" if rigor==2
 
replace cp6 ="" if rigor==1
replace cp6_0_text ="" if rigor==1
replace cp6_2 ="" if rigor==1
replace cp6_2_0_text ="" if rigor==1
replace cp6_3 ="" if rigor==1
replace cp6_3_0_text="" if rigor==1

 
replace cp6 ="" if rigor==2
replace cp6_0_text ="" if rigor==2
replace cp6_2 ="" if rigor==2
replace cp6_2_0_text ="" if rigor==2
replace cp6_3 ="" if rigor==2
replace cp6_3_0_text="" if rigor==2

*****
replace sp1 ="" if rigor==1
replace sp1_0_text="" if rigor==1
replace sp1_2="" if rigor==1
replace sp1_2_0_text="" if rigor==1
replace sp1_3="" if rigor==1
replace sp1_3_0_text="" if rigor==1
replace sp2 ="" if rigor==1
replace sp2a ="" if rigor==1
replace sp2a_0_text="" if rigor==1
replace sp2_2 ="" if rigor==1
replace sp2a_2 ="" if rigor==1
replace sp2a_2_0_text ="" if rigor==1
replace sp2_3 ="" if rigor==1
replace sp2a_3 ="" if rigor==1
replace sp2a_3_0_text="" if rigor==1
 
replace sp3 ="" if rigor==1
replace sp3_0_text ="" if rigor==1
replace sp3a ="" if rigor==1
replace sp3_2="" if rigor==1
replace sp3_2_0_text ="" if rigor==1
replace sp3a_2 ="" if rigor==1
replace sp3_3 ="" if rigor==1
replace sp3_3_0_text="" if rigor==1
replace sp3a_3="" if rigor==1
 
replace sp4a ="" if rigor==1
replace sp4a_0_text="" if rigor==1
replace sp4_2="" if rigor==1
replace sp4_2_0_text="" if rigor==1
replace sp4_3 ="" if rigor==1
replace sp4_3_0_text="" if rigor==1
 
replace sp5 ="" if rigor==1
replace sp5_0_text="" if rigor==1
replace sp5_2 ="" if rigor==1
replace sp5_2_0_text="" if rigor==1
replace sp5_3 ="" if rigor==1
replace sp5_3_0_text="" if rigor==1

 ************
 
replace sp1 ="" if rigor==2
replace sp1_0_text="" if rigor==2
replace sp1_2="" if rigor==2
replace sp1_2_0_text="" if rigor==2
replace sp1_3="" if rigor==2
replace sp1_3_0_text="" if rigor==2
replace sp2 ="" if rigor==2
replace sp2a ="" if rigor==2
replace sp2a_0_text="" if rigor==2
replace sp2_2 ="" if rigor==2
replace sp2a_2 ="" if rigor==2
replace sp2a_2_0_text ="" if rigor==2
replace sp2_3 ="" if rigor==2
replace sp2a_3 ="" if rigor==2
replace sp2a_3_0_text="" if rigor==2
 
replace sp3 ="" if rigor==2
replace sp3_0_text ="" if rigor==2
replace sp3a ="" if rigor==2
replace sp3_2="" if rigor==2
replace sp3_2_0_text ="" if rigor==2
replace sp3a_2 ="" if rigor==2
replace sp3_3 ="" if rigor==2
replace sp3_3_0_text="" if rigor==2
replace sp3a_3="" if rigor==2
 
replace sp4a ="" if rigor==2
replace sp4a_0_text="" if rigor==2
replace sp4_2="" if rigor==2
replace sp4_2_0_text="" if rigor==2
replace sp4_3 ="" if rigor==2
replace sp4_3_0_text="" if rigor==2
 
replace sp5 ="" if rigor==2
replace sp5_0_text="" if rigor==2
replace sp5_2 ="" if rigor==2
replace sp5_2_0_text="" if rigor==2
replace sp5_3 ="" if rigor==2
replace sp5_3_0_text="" if rigor==2

save "$main\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics REVISED.dta", replace
export excel using "$main\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics REVISED 2020-2-7.xlsx", sheet("CIAC Basic, Standard, Enhanced") firstrow(variables) sheetreplace
