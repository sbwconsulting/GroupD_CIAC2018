/***************************************
Created By: Dan Hudgins
Creation Date: 2019-12-22

Last Modified By: Dan Hudgins
Modified Date: 2019-1-20

This file preps the raw survey data from
the 2018 CIAC Enhanced Surveys
***************************************/

capture clear all
*capture log close
set more off
set segmentsize 3g
set maxvar 25000
set excelxlsxlargefile on

// Set Useful Folder Paths
global main "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data"
global work "$main\Working Files"
global syntax "$main\Syntax"
global map "$main\Mapping Files"
global qc "$main\QC_Outputs"
global fin "$main\Final_Outputs"
global af "$main\Analysis Files"
global raw "$main\_Enhanced\SBD Survey Instrument- Excel"
exit

/*************************************************************************

			STEP 0: Create Formatted and Labeled, but RAW Dataset

**************************************************************************/
// prep all sample data for info merge
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_All Sample with added Net Sample.dta", clear
	// keep useful variables and rename
	keep sampleid sbw_projid ClaimI* MEAS1 MEAS2 MEAS3 MEAS1_DATE MEAS2_DATE MEAS3_DATE contactname_recruit BUSINESS SECTOR RIGOR MULTIMEAS MULTIADDR
		rename (MEAS1 MEAS2 MEAS3 MEAS1_DATE MEAS2_DATE MEAS3_DATE contactname_recruit BUSINESS SECTOR RIGOR MULTIMEAS MULTIADDR) ///
		(meas1 meas2 meas3 meas_1_date meas_2_date meas_3_date contact business sector rigor multimeas multiaddr)
	save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Enhanced Non SBD Info.dta", replace

****************
// CIAC Vendor 
****************
clear
import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Vendor Interviews\Vendor Interviews.xlsx", sheet("Survey Data") firstrow case(lower)
	// keep useful variables 
	keep sampleid v_aa1 v_aa2 v_a1 v_a2 v_a3 v2_meas1 v3_meas1 v4_meas1 v5_meas1 v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 v14_meas1 v15_meas1 v16_meas1 v16a_meas1
	tostring _all, replace
	foreach var of varlist _all ///
	{
		replace `var' = "" if `var' == "9999998"|`var' == "-99"|`var' == "-98"|`var' == "-96" |`var' == "99"|`var' == "98"|`var' == "96"|`var' == "NA" ///
		|`var' == "-999"|`var' == "-998"|`var' == "-996"|`var' == "."
	}	
	
	replace v4_meas1="0" if strpos(v4_meas1, "0%")
	replace v4_meas1="" if strpos(v4_meas1, "We are mission driven")
	replace v5_meas1="1" if strpos(v5_meas1, "100%")
	replace v8_meas1="" if strpos(v8_meas1, "15 different")
	replace v_aa1="1" if sampleid=="135"|sampleid=="579"
	replace v_a1="1" if sampleid=="135"|sampleid=="579"
	replace v_a2="1" if sampleid=="135"|sampleid=="579"
	replace v_a3="1" if sampleid=="135"|sampleid=="579"
	destring sampleid,replace
	save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Vendor Info.dta", replace

	
****************
// CIAC NON-SBD 
****************
/*clear
import delimited "$main\_Enhanced\_Qualtrics\CIAC+Evaluation+-+Basic,+Standard,+and+Enhanced+Decision+Maker+Survey_January+29,+2020_17.30.csv", bindquote(strict) varnames(1) 
drop if startdate=="Start Date"| strpos(startdate,"Import")
rename externalreference sbw_projid
*/
import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Enhanced\Quantitative Survey Data\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics REVISED 2020-2-7.xlsx", sheet("CIAC Basic, Standard, Enhanced") firstrow case(lower) clear
drop if startdate=="Start Date" | strpos(startdate,"timeZone")
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Enhanced\Quantitative Survey Data\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics.dta" , replace

use  "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Enhanced\Quantitative Survey Data\CIAC Basic, Standard, Enhanced Duplicated Responses Qualtrics.dta", clear
	rename *, lower
	rename externalreference sbw_projid
	drop meas_1 meas_1_date meas_2 meas_2_date meas_3 meas_3_date business sector rigor multmeas multiadd contact

// Merge survey data with sample file
		merge 1:1 sbw_projid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Enhanced Non SBD Info.dta" 
		keep if _merge==3
		gen ciac_nsbd = 1
		gen completed = 1
		order completed sampleid sbw_projid rigor, first
		drop _merge  
		
// Add vendor interview variables
gen v_aa1 = .
gen v_aa2 = .
gen v_a1 = .
gen v_a2 = .
gen v_a3 = ""
gen v2_meas1 = .
gen v3_meas1 = .
gen v4_meas1 = .
gen v5_meas1 = .
gen v6a_meas1 = ""
gen v6aa_meas1 = .
gen v6bb_meas1 = .
gen v7a_meas1 = .
gen v7b_meas1 = .
gen v7c_meas1 = .
gen v8_meas1 = .
gen v9_meas1 = .
gen v9a_meas1 = .
gen v10_meas1 = .
gen v11_meas1 = .
gen v12_meas1 = .
gen v13_meas1 = .
gen v13a_meas1 = ""
gen v14_meas1 = .
gen v15_meas1 = .
gen v16_meas1 = .
gen v16a_meas1 = ""

gen v2_meas2 = .
gen v3_meas2 = .
gen v4_meas2 = .
gen v5_meas2 = .
gen v6a_meas2 = ""
gen v6aa_meas2 = .
gen v6bb_meas2 = .
gen v7a_meas2 = .
gen v7b_meas2 = .
gen v7c_meas2 = .
gen v8_meas2 = .
gen v9_meas2 = .
gen v9a_meas2 = .
gen v10_meas2 = .
gen v11_meas2 = .
gen v12_meas2 = .
gen v13_meas2 = .
gen v13a_meas2 = ""
gen v14_meas2 = .
gen v15_meas2 = .
gen v16_meas2 = .
gen v16a_meas2 = ""

gen v2_meas3 = .
gen v3_meas3 = .
gen v4_meas3 = .
gen v5_meas3 = .
gen v6a_meas3 = ""
gen v6aa_meas3 = .
gen v6bb_meas3 = .
gen v7a_meas3 = .
gen v7b_meas3 = .
gen v7c_meas3 = .
gen v8_meas3 = .
gen v9_meas3 = .
gen v9a_meas3 = .
gen v10_meas3 = .
gen v11_meas3 = .
gen v12_meas3 = .
gen v13_meas3 = .
gen v13a_meas3 = ""
gen v14_meas3 = .
gen v15_meas3 = .
gen v16_meas3 = .
gen v16a_meas3 = ""

//drop v671 v672 v673 v674 v675 v676 v677 v678 v679 v680 v681 v682 v683 v684 v685 v686 v687 v688 v689 v690 v691 v692
// rename variable to match PMR

rename (intro3_1_text intro3_2_text intro3_3_text intro3_4_text intro3_5_text intro4_1_0 intro4_1_2_text) ///
(intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 intro4_other)
	drop intro3__98 intro3_1 intro3_2 intro3_3 intro3_4 intro3_5
		
rename (v1a_1 v1a_2  v2_0_text) (v1a_01 v1a_02 v2_other)		
	gen v1a_03=.
	replace v1a_01 = ""
		
rename (ap9_0_text ap9a_1 ap9a_2 ap9a_3 ap9a_4 ap9a_5 ap9a_6 ap9a_7 ap9a_8 ap9a_9 ap9a_10 ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_0_text) ///
(ap9_other ap9a_01 ap9a_02 ap9a_03 ap9a_04 ap9a_05 ap9a_06 ap9a_07 ap9a_08 ap9a_09 ap9a_10 ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_other)	
		
rename (n33_0_text n33a_1_text n33a_2_text n33a_1 n33a_2 c4 c4_0_text c5 c5_0_text c6)	///
(n33name  n33aemail n33aphone n33a_01 n33a_02 c4 c4_response c5 c5_response c6)	
	drop n33a__98 n33a__99		
		
rename (a1a_0_text a2a_0_text a2b_1 a2b_2 a2bb_1 a2bb_2 a2bb_0_text a2bb_1_text a2bb_2_text a4_0_text a4a) ///
(a1a_response a2a_response a2b_01 a2b_02 a2bb_01 a2bb_02 a2bbname a2bbemail a2bbphone a4_response a4a_response)
	drop a2b__98 a2b__99 a2bb_0 a2bb__98 a2bb__99
	gen a2b_03=.	
	gen a2b_other=""
	gen a2bb_03=.	
	gen a4a=.
		
rename (aa3_1 aa3_2 aa3_3 aa3_4 aa3_5 aa3_6 aa3_7 aa3_0_text aa3__98 ///
aa3_2_1 aa3_2_2 aa3_2_3 aa3_2_4 aa3_2_5 aa3_2_6 aa3_2_7 aa3_2_0_text aa3_2__98 ///
aa3_3_1 aa3_3_2 aa3_3_3 aa3_3_4 aa3_3_5 aa3_3_6 aa3_3_7 aa3_3_0_text aa3_3__98) ///
(aa3_meas1_1 aa3_meas1_2 aa3_meas1_3 aa3_meas1_4 aa3_meas1_5 aa3_meas1_6 aa3_meas1_7 aa3_meas1other aa3_meas1_98	///
aa3_meas2_1 aa3_meas2_2 aa3_meas2_3 aa3_meas2_4 aa3_meas2_5 aa3_meas2_6 aa3_meas2_7 aa3_meas2other aa3_meas2_98	///
aa3_meas3_1 aa3_meas3_2 aa3_meas3_3 aa3_meas3_4 aa3_meas3_5 aa3_meas3_6 aa3_meas3_7 aa3_meas3other aa3_meas3_98)
	drop aa3_0 aa3__99 aa3_2_0 aa3_2__99 aa3_3_0 aa3_3__99
		
rename (obf1 obf1_2 obf1_3 n2 n2_2 n2_3 n3a n3a_2 n3a_3 ///
n3aa n3aa_1_text n3aa_2 n3aa_2_1_text n3aa_3 n3aa_3_1_text) ///
(obf1_meas1 obf1_meas2 obf1_meas3 n2_meas1 n2_meas2 n2_meas3 n3a_meas1 n3a_meas2 n3a_meas3 ///
n3aa_meas1 n3aa_response_meas1 n3aa_meas2 n3aa_response_meas2 n3aa_meas3 n3aa_response_meas3)
		
rename (n3b n3b_2 n3b_3 n3bb n3bb_0_text n3bb_2 n3bb_2_0_text n3bb_3 n3bb_3_0_text ///
n3c n3c_2 n3c_3 n3cc n3cc_0_text n3cc_2 n3cc_2_0_text n3cc_3 n3cc_3_0_text ///
n3d n3d_2 n3d_3 n3dd n3dd_0_text n3dd_2 n3dd_2_0_text n3dd_3 n3dd_3_0_text ///
n3e n3e_2 n3e_3 ///
n3f n3f_2 n3f_3 n3ff n3ff_0_text n3ff_2 n3ff_2_0_text n3ff_3 n3ff_3_0_text ///
n3g n3g_2 n3g_3 n3gg n3gg_0_text n3gg_2 n3gg_2_0_text n3gg_3 n3gg_3_0_text ///
n3ggg n3ggg_0_text n3ggg_2 n3ggg_2_0_text n3ggg_3 n3ggg_3_0_text ///
n3h n3h_2 n3h_3 n3hh n3hh_0_text n3hh_2 n3hh_2_0_text n3hh_3 n3hh_3_0_text ///
n3hhh n3hhh_1_text n3hhh_2 n3hhh_2_1_text n3hhh_3 n3hhh_3_1_text ///
n3i n3i_2 n3i_3 n3j n3j_2 n3j_3 ///
n3k n3k_2 n3k_3 n3kk1 n3kk1_1_text n3kk1_2 n3kk1_2_1_text n3kk1_3 n3kk1_3_1_text  ///
n3kk2 n3kk2_1_text n3kk2_2 n3kk2_2_1_text n3kk2_3 n3kk2_3_1_text) ///
(n3b_meas1 n3b_meas2 n3b_meas3 n3bb_meas1 n3bb_response_meas1 n3bb_meas2 n3bb_response_meas2 n3bb_meas3 n3bb_response_meas3 ///
n3c_meas1 n3c_meas2 n3c_meas3 n3cc_meas1 n3cc_response_meas1 n3cc_meas2 n3cc_response_meas2 n3cc_meas3 n3cc_response_meas3 ///
n3d_meas1 n3d_meas2 n3d_meas3 n3dd n3dd_0_text n3dd_2 n3dd_2_0_text n3dd_3 n3dd_3_0_text ///
n3e_meas1 n3e_meas2 n3e_meas3 ///
n3f_meas1 n3f_meas2 n3f_meas3 n3ff_meas1 n3ff_response_meas1 n3ff_meas2 n3ff_response_meas2 n3ff_meas3 n3ff_response_meas3 ///
n3g_meas1 n3g_meas2 n3g_meas3 n3gg_meas1 n3gg_response_meas1 n3gg_meas2 n3gg_response_meas2 n3gg_meas3 n3gg_response_meas3 ///
n3ggg_meas1 n3ggg_response_meas1 n3ggg_meas2 n3ggg_response_meas2 n3ggg_meas3 n3ggg_response_meas3 ///
n3h_meas1 n3h_meas2 n3h_meas3 n3hh_meas1 n3hh_response_meas1 n3hh_meas2 n3hh_response_meas2 n3hh_meas3 n3hh_response_meas3 ///
n3hhh_meas1 n3hhh_response_meas1 n3hhh_meas2 n3hhh_response_meas2 n3hhh_meas3 n3hhh_response_meas3 ///
n3i_meas1 n3i_meas2 n3i_meas3 n3j_meas1 n3j_meas2 n3j_meas3 ///
n3k_meas1 n3k_meas2 n3k_meas3 n3kk1_meas1 n3kk1_response_meas1 n3kk1_meas2 n3kk1_response_meas2 n3kk1_meas3 n3kk1_response_meas3 ///
n3kk2_meas1 n3kk2_response_meas1 n3kk2_meas2 n3kk2_response_meas2 n3kk2_meas3 n3kk2_response_meas3)		
	gen revised_n3b_meas1 =.
	gen revised_n3b_meas2 =.
	gen revised_n3b_meas3 =.
		
rename (fino fino_2 fin0_3 fin1_1 fin1_2 fin1_3 fin1_2_1 fin1_2_2 fin1_2_3 fin1_3_1 fin1_3_2 fin1_3_3 ///
fin7_1 fin7_2 fin7_3 fin7_4 fin7_0 fin7_0_text fin7_2_1 fin7_2_2 fin7_2_3 fin7_2_4 fin7_2_0 fin7_2_0_text fin7_3_1 fin7_3_2 fin7_3_3 fin7_3_4 fin7_3_0 fin7_3_0_text) ///
(fin0_meas1 fin0_meas2 fin0_meas3 fin1_a_meas1 fin1_b_meas1 fin1_c_meas1 fin1_a_meas2 fin1_b_meas2 fin1_c_meas2 fin1_a_meas3 fin1_b_meas3 fin1_c_meas3 ///
fin7_meas1_1 fin7_meas1_2 fin7_meas1_3 fin7_meas1_4 fin7_meas1_5 fin7_other_meas1 fin7_meas2_1 fin7_meas2_2 fin7_meas2_3 fin7_meas2_4 fin7_meas2_5 fin7_other_meas2 fin7_meas3_1 fin7_meas3_2 fin7_meas3_3 fin7_meas3_4 fin7_meas3_5 fin7_other_meas3)
	drop fin7_2__98 fin7_2__99 fin7_3__98 fin7_3__99 fin7__98 fin7__99
		 
		 destring fin8_*, replace
	gen fin8_meas1_1 = .
			replace fin8_meas1_1 =1 if fin8_1 == 1
			replace fin8_meas1_1 =2 if fin8_2 == 1 & fin8_1 == .
			replace fin8_meas1_1 =3 if fin8_3 == 1 & fin8_1 == . & fin8_2 == .
			replace fin8_meas1_1 =4 if fin8_4 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == .
			replace fin8_meas1_1 =5 if fin8_5 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == .
			replace fin8_meas1_1 =6 if fin8_6 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == .
			replace fin8_meas1_1 =7 if fin8_7 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == .
			replace fin8_meas1_1 =8 if fin8_8 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == .
			replace fin8_meas1_1 =9 if fin8_9 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == .
			replace fin8_meas1_1 =10 if fin8_10 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == . & fin8_9 == .
	gen fin8_meas1_2  = .
			replace fin8_meas1_2 =1 if fin8_1 == 1 & fin8_meas1_1!=1
			replace fin8_meas1_2 =2 if fin8_2 == 1 & fin8_1 == . & fin8_meas1_1!=2
			replace fin8_meas1_2 =3 if fin8_3 == 1 & fin8_1 == . & fin8_2 == .  & fin8_meas1_1!=3
			replace fin8_meas1_2 =4 if fin8_4 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_meas1_1!=4
			replace fin8_meas1_2 =5 if fin8_5 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_meas1_1!=5
			replace fin8_meas1_2 =6 if fin8_6 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_meas1_1!=6
			replace fin8_meas1_2 =7 if fin8_7 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == .  & fin8_meas1_1!=7
			replace fin8_meas1_2 =8 if fin8_8 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_meas1_1!=8
			replace fin8_meas1_2 =9 if fin8_9 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == . & fin8_meas1_1!=9
			replace fin8_meas1_2 =10 if fin8_10 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == . & fin8_9 == . & fin8_meas1_1!=10
	gen fin8_meas1_3 = .
			replace fin8_meas1_3 =1 if fin8_1 == 1 & fin8_meas1_1!=1 & fin8_meas1_2!=1
			replace fin8_meas1_3 =2 if fin8_2 == 1 & fin8_1 == . & fin8_meas1_1!=2 & fin8_meas1_2!=2
			replace fin8_meas1_3 =3 if fin8_3 == 1 & fin8_1 == . & fin8_2 == .  & fin8_meas1_1!=3 & fin8_meas1_2!=3
			replace fin8_meas1_3 =4 if fin8_4 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_meas1_1!=4 & fin8_meas1_2!=4
			replace fin8_meas1_3 =5 if fin8_5 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_meas1_1!=5 & fin8_meas1_2!=5
			replace fin8_meas1_3 =6 if fin8_6 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_meas1_1!=6 & fin8_meas1_2!=6
			replace fin8_meas1_3 =7 if fin8_7 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == .  & fin8_meas1_1!=7 & fin8_meas1_2!=7
			replace fin8_meas1_3 =8 if fin8_8 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_meas1_1!=8  & fin8_meas1_2!=8
			replace fin8_meas1_3 =9 if fin8_9 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == . & fin8_meas1_1!=9 & fin8_meas1_2!=9
			replace fin8_meas1_3 =10 if fin8_10 == 1 & fin8_1 == . & fin8_2 == . & fin8_3 == . & fin8_4 == . & fin8_5 == . & fin8_6 == . & fin8_7 == . & fin8_8 == . & fin8_9 == . & fin8_meas1_1!=10 & fin8_meas1_2!=10
	gen fin8_other_meas1 = fin8_0_text

	gen fin8_meas2_1 = .
			replace fin8_meas2_1 =1 if fin8_2_1 == 1
			replace fin8_meas2_1 =2 if fin8_2_2 == 1 & fin8_2_1 == .
			replace fin8_meas2_1 =3 if fin8_2_3 == 1 & fin8_2_1 == . & fin8_2_2 == .
			replace fin8_meas2_1 =4 if fin8_2_4 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == .
			replace fin8_meas2_1 =5 if fin8_2_5 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == .
			replace fin8_meas2_1 =6 if fin8_2_6 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == .
			replace fin8_meas2_1 =7 if fin8_2_7 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == .
			replace fin8_meas2_1 =8 if fin8_2_8 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == .
			replace fin8_meas2_1 =9 if fin8_2_9 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == .
			replace fin8_meas2_1 =10 if fin8_2_10 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == . & fin8_2_9 == .
	gen fin8_meas2_2  = .
			replace fin8_meas2_2 =1 if fin8_2_1 == 1 & fin8_meas2_1!=1
			replace fin8_meas2_2 =2 if fin8_2_2 == 1 & fin8_2_1 == . & fin8_meas2_1!=2
			replace fin8_meas2_2 =3 if fin8_2_3 == 1 & fin8_2_1 == . & fin8_2_2 == .  & fin8_meas2_1!=3
			replace fin8_meas2_2 =4 if fin8_2_4 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_meas2_1!=4
			replace fin8_meas2_2 =5 if fin8_2_5 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_meas2_1!=5
			replace fin8_meas2_2 =6 if fin8_2_6 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_meas2_1!=6
			replace fin8_meas2_2 =7 if fin8_2_7 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == .  & fin8_meas2_1!=7
			replace fin8_meas2_2 =8 if fin8_2_8 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_meas2_1!=8
			replace fin8_meas2_2 =9 if fin8_2_9 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == . & fin8_meas2_1!=9
			replace fin8_meas2_2 =10 if fin8_2_10 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == . & fin8_2_9 == . & fin8_meas2_1!=10
	gen fin8_meas2_3 = .
			replace fin8_meas2_3 =1 if fin8_2_1 == 1 & fin8_meas2_1!=1 & fin8_meas2_2!=1
			replace fin8_meas2_3 =2 if fin8_2_2 == 1 & fin8_2_1 == . & fin8_meas2_1!=2 & fin8_meas2_2!=2
			replace fin8_meas2_3 =3 if fin8_2_3 == 1 & fin8_2_1 == . & fin8_2_2 == .  & fin8_meas2_1!=3 & fin8_meas2_2!=3
			replace fin8_meas2_3 =4 if fin8_2_4 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_meas2_1!=4 & fin8_meas2_2!=4
			replace fin8_meas2_3 =5 if fin8_2_5 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_meas2_1!=5 & fin8_meas2_2!=5
			replace fin8_meas2_3 =6 if fin8_2_6 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_meas2_1!=6 & fin8_meas2_2!=6
			replace fin8_meas2_3 =7 if fin8_2_7 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == .  & fin8_meas2_1!=7 & fin8_meas2_2!=7
			replace fin8_meas2_3 =8 if fin8_2_8 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_meas2_1!=8  & fin8_meas2_2!=8
			replace fin8_meas2_3 =9 if fin8_2_9 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == . & fin8_meas2_1!=9 & fin8_meas2_2!=9
			replace fin8_meas2_3 =10 if fin8_2_10 == 1 & fin8_2_1 == . & fin8_2_2 == . & fin8_2_3 == . & fin8_2_4 == . & fin8_2_5 == . & fin8_2_6 == . & fin8_2_7 == . & fin8_2_8 == . & fin8_2_9 == . & fin8_meas2_1!=10 & fin8_meas2_2!=10
	gen fin8_other_meas2 = fin8_2_0_text

	gen fin8_meas3_1 = .
			replace fin8_meas3_1 =1 if fin8_3_1 == 1
			replace fin8_meas3_1 =2 if fin8_3_2 == 1 & fin8_3_1 == .
			replace fin8_meas3_1 =3 if fin8_3_3 == 1 & fin8_3_1 == . & fin8_3_2 == .
			replace fin8_meas3_1 =4 if fin8_3_4 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == .
			replace fin8_meas3_1 =5 if fin8_3_5 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == .
			replace fin8_meas3_1 =6 if fin8_3_6 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == .
			replace fin8_meas3_1 =7 if fin8_3_7 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == .
			replace fin8_meas3_1 =8 if fin8_3_8 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == .
			replace fin8_meas3_1 =9 if fin8_3_9 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == .
			replace fin8_meas3_1 =10 if fin8_3_10 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == . & fin8_3_9 == .
	gen fin8_meas3_2  = .
			replace fin8_meas3_2 =1 if fin8_3_1 == 1 & fin8_meas2_1!=1
			replace fin8_meas3_2 =2 if fin8_3_2 == 1 & fin8_3_1 == . & fin8_meas2_1!=2
			replace fin8_meas3_2 =3 if fin8_3_3 == 1 & fin8_3_1 == . & fin8_3_2 == .  & fin8_meas2_1!=3
			replace fin8_meas3_2 =4 if fin8_3_4 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_meas2_1!=4
			replace fin8_meas3_2 =5 if fin8_3_5 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_meas2_1!=5
			replace fin8_meas3_2 =6 if fin8_3_6 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_meas2_1!=6
			replace fin8_meas3_2 =7 if fin8_3_7 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == .  & fin8_meas2_1!=7
			replace fin8_meas3_2 =8 if fin8_3_8 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_meas2_1!=8
			replace fin8_meas3_2 =9 if fin8_3_9 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == . & fin8_meas2_1!=9
			replace fin8_meas3_2 =10 if fin8_3_10 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == . & fin8_3_9 == . & fin8_meas2_1!=10
	gen fin8_meas3_3 = .
			replace fin8_meas3_3 =1 if fin8_3_1 == 1 & fin8_meas2_1!=1 & fin8_meas2_2!=1
			replace fin8_meas3_3 =2 if fin8_3_2 == 1 & fin8_3_1 == . & fin8_meas2_1!=2 & fin8_meas2_2!=2
			replace fin8_meas3_3 =3 if fin8_3_3 == 1 & fin8_3_1 == . & fin8_3_2 == .  & fin8_meas2_1!=3 & fin8_meas2_2!=3
			replace fin8_meas3_3 =4 if fin8_3_4 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_meas2_1!=4 & fin8_meas2_2!=4
			replace fin8_meas3_3 =5 if fin8_3_5 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_meas2_1!=5 & fin8_meas2_2!=5
			replace fin8_meas3_3 =6 if fin8_3_6 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_meas2_1!=6 & fin8_meas2_2!=6
			replace fin8_meas3_3 =7 if fin8_3_7 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == .  & fin8_meas2_1!=7 & fin8_meas2_2!=7
			replace fin8_meas3_3 =8 if fin8_3_8 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_meas2_1!=8  & fin8_meas2_2!=8
			replace fin8_meas3_3 =9 if fin8_3_9 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == . & fin8_meas2_1!=9 & fin8_meas2_2!=9
			replace fin8_meas3_3 =10 if fin8_3_10 == 1 & fin8_3_1 == . & fin8_3_2 == . & fin8_3_3 == . & fin8_3_4 == . & fin8_3_5 == . & fin8_3_6 == . & fin8_3_7 == . & fin8_3_8 == . & fin8_3_9 == . & fin8_meas2_1!=10 & fin8_meas2_2!=10
	gen fin8_other_meas3 = fin8_3_0_text		
		
	rename (n3l n3l_2 n3l_3 n3ll n3ll_0_text n3ll_2 n3ll_2_0_text n3ll_3 n3ll_3_0_text) ///
		(n3l_meas1 n3l_meas2 n3l_meas3 n3ll_meas1 n3ll_response_meas1 n3ll_meas2 n3ll_response_meas2 n3ll_meas3 n3ll_response_meas3)

	rename (n3lll n3lll_0_text n3lll_2 n3lll_2_0_text n3lll_3 n3lll_3_0_text n3m n3m_2 n3m_3 n3n n3n_2 n3n_3) ///
		(n3lll_meas1 n3lll_response_meas1 n3lll_meas2 n3lll_response_meas2 n3lll_meas3 n3lll_response_meas3 n3m_meas1 n3m_meas2 n3m_meas3 n3n_meas1 n3n_meas2 n3n_meas3)

	rename (n3o n3o_2 n3o_3 n3oo n3oo_0_text n3oo_2 n3oo_2_0_text n3oo_3 n3oo_3_0_text) ///
		(n3o_meas1 n3o_meas2 n3o_meas3 n3oo_meas1 n3oo_response_meas1 n3oo_meas2 n3oo_response_meas2 n3oo_meas3 n3oo_response_meas3)

	rename (n3p n3p_2 n3p_3 n3pp n3pp_0_text n3pp_2 n3pp_2_0_text n3pp_3 n3pp_3_0_text) ///
		(n3p_meas1 n3p_meas2 n3p_meas3 n3pp_meas1 n3pp_response_meas1 n3pp_meas2 n3pp_response_meas2 n3pp_meas3 n3pp_response_meas3)

	rename (n3q n3q_2 n3q_3 n3r n3r_2 n3r_3 n3rr n3rr_0_text n3rr_2 n3rr_2_0_text n3rr_3 n3rr_3_0_text) ///
		(n3q_meas1 n3q_meas2 n3q_meas3 n3r_meas1 n3r_meas2 n3r_meas3 n3rr_meas1 n3rr_response_meas1 n3rr_meas2 n3rr_response_meas2 n3rr_meas3 n3rr_response_meas3)

	rename (n3rrr n3rrr_0_text n3rrr_2 n3rrr_2_0_text n3rrr_3 n3rrr_3_0_text n3s n3s_2 n3s_3) ///
		(n3rrr_meas1 n3rrr_response_meas1 n3rrr_meas2 n3rrr_response_meas2 n3rrr_meas3 n3rrr_response_meas3 n3s_meas1 n3s_meas2 n3s_meas3)
	
	rename (n3t n3t_1_text n3t_2 n3t_2_1_text n3t_3 n3t_3_1_text ///
	n3tt n3tt_2_1 n3tt_3_1 ///
	n3ttt n3ttt_0_text n3ttt_2 n3ttt_2_0_text n3ttt_3 n3ttt_3_0_text) ///
	(n3t_meas1_1 n3t_other_meas1_meas1 n3t_meas2_1 n3t_other_meas2_meas2 n3t_meas3_1 n3t_other_meas3_meas3 ///
	n3tt_1_meas1 n3tt_1_meas2 n3tt_1_meas3 ///
	n3ttt_meas1 n3ttt_meas1_response n3ttt_meas2 n3ttt_meas2_response n3ttt_meas3 n3ttt_meas3_response)
	
	rename (cc1 cc1_0_text cc1a cc1a_0_text cc1_2 cc1_2_0_text cc1a_2 cc1a_2_0_text cc1_3 cc1_3_0_text cc1a_3 cc1a_3_0_text ///
	ncc3 ncc3_0_text ncc3_2 ncc3_2_0_text ncc3_3 ncc3_3_0_text ncc3a ncc3a_0_text ncc3a_2 ncc3a_2_0_text ncc3a_3 ncc3a_3_0_text) ///
	(cc1_meas1 cc1_response_meas1 cc1a_meas1 cc1a_response_meas1 cc1_meas2 cc1_response_meas2 cc1a_meas2 cc1a_response_meas2 cc1_meas3 cc1_response_meas3 cc1a_meas3 cc1a_response_meas3 ///
	ncc3_meas1 ncc3_response_meas1 ncc3_meas2 ncc3_response_meas2 ncc3_meas3 ncc3_response_meas3 ncc3a_meas1 ncc3a_response_meas1 ncc3a_meas2 ncc3a_response_meas2 ncc3a_meas3 ncc3a_response_meas3)
	
	rename (p1_1 p1_2 p1_0_text p1_2_1 p1_2_2 p1_2_0_text p1_3_1 p1_3_2 p1_3_0_text ///
	p2a p2a_2 p2a_3  p2b_0_text  p2b_2_0_text  p2b_3_0_text ///
	p3 p3_2 p3_3 p3a p3a_0_text p3a_2 p3a_2_0_text p3a_3 p3a_3_0_text p4 p4_2 p4_3 ///
	p3e p3e_0_text p3e_2 p3e_2_0_text p3e_3 p3e_3_0_text) ///
	(p1_meas1_1 p1_meas1_2  p1_other_meas1 p1_meas2_1 p1_meas2_2  p1_other_meas2 p1_meas3_1 p1_meas3_2  p1_other_meas3 ///
	p2a_meas1 p2a_meas2 p2a_meas3 p2b_meas1 p2b_meas2 p2b_meas3 ///
	p3_meas1 p3_meas2 p3_meas3 p3a_meas1 p3a_response_meas1 p3a_meas2 p3a_response_meas2 p3a_meas3 p3a_response_meas3 p4_meas1 p4_meas2 p4_meas3 ///
	p3e_meas1 p3e_response_meas1 p3e_meas2 p3e_response_meas2 p3e_meas3 p3e_response_meas3)
	
		drop p1_0 p1_2_0 p1_2__98 p1_2__99 p1_3_0 p1_3__98 p1_3__99 p1__98 p1__99
	
	rename (cp1 cp1_2 cp1_3 cp1a cp1a_0_text cp1a_2 cp1a_2_0_text cp1a_3 cp1a_3_0_text ///
	cp2 cp2_0_text cp2_2 cp2_2_0_text cp2_3 cp2_3_0_text ///
	cp3 cp3_2 cp3_3 cp3a cp3a_0_text cp3a_2 cp3a_2_0_text cp3a_3 cp3a_3_0_text ///
	cp4 cp4_0_text cp4_2 cp4_2_0_text cp4_3 cp4_3_0_text ///
	cp6 cp6_0_text cp6_2 cp6_2_0_text cp6_3 cp6_3_0_text) ///
	(cp1_meas1 cp1_meas2 cp1_meas3 cp1a_meas1 cp1a_response_meas1 cp1a_meas2 cp1a_response_meas2 cp1a_meas3 cp1a_response_meas3 ///
	cp2_meas1 cp2_response_meas1 cp2_meas2 cp2_response_meas2 cp2_meas3 cp2_response_meas3 ///
	cp3_meas1 cp3_meas2 cp3_meas3 cp3a_meas1 cp3a_response_meas1 cp3a_meas2 cp3a_response_meas2 cp3a_meas3 cp3a_response_meas3 ///
	cp4_meas1 cp4_response_meas1 cp4_meas2 cp4_response_meas2 cp4_meas3 cp4_response_meas3 ///
	cp6_meas1 cp6_response_meas1 cp6_meas2 cp6_response_meas2 cp6_meas3 cp6_response_meas3)
	
	rename (sp1 sp1_0_text sp1_2 sp1_2_0_text sp1_3 sp1_3_0_text ///
	sp2 sp2_2 sp2_3 sp2a sp2a_0_text sp2a_2 sp2a_2_0_text sp2a_3 sp2a_3_0_text ///
	sp3 sp3_0_text sp3_2 sp3_2_0_text sp3_3 sp3_3_0_text sp3a sp3a_2 sp3a_3 ///
	sp4a sp4a_0_text sp4_2 sp4_2_0_text sp4_3 sp4_3_0_text ///
	sp5 sp5_0_text sp5_2 sp5_2_0_text sp5_3 sp5_3_0_text n41___n42_1 n41___n42_2 n41_2___n42_2_1 n41_2___n42_2_2 n41_3___n42_3_1 n41_3___n42_3_2) ///
	(sp1_meas1 sp1_response_meas1 sp1_meas2 sp1_response_meas2 sp1_meas3 sp1_response_meas3 ///
	sp2_meas1 sp2_meas2 sp2_meas3 sp2a_meas1 sp2a_response_meas1 sp2a_meas2 sp2a_response_meas2 sp2a_meas3 sp2a_response_meas3 ///
	sp3_meas1 sp3_response_meas1 sp3_meas2 sp3_response_meas2 sp3_meas3 sp3_response_meas3 sp3a_meas1 sp3a_meas2 sp3a_meas3 ///
	sp4_meas1 sp4_response_meas1 sp4_meas2 sp4_response_meas2 sp4_meas3 sp4_response_meas3 ///
	sp5_meas1 sp5_response_meas1 sp5_meas2 sp5_response_meas2 sp5_meas3 sp5_response_meas3 n41_meas1 n42_meas1 n41_meas2 n42_meas2 n41_meas3 n42_meas3)
	
	rename (n5 n5_2 n5_3 n5a n5a_0_text n5a_2 n5a_2_0_text n5a_3 n5a_3_0_text ///
	nn5aa nn5aa_0_text nn5aa_2 nn5aa_2_0_text nn5aa_3 nn5aa_3_0_text ///
	n5b n5b_2 n5b_3 n5bb n5bb_0_text n5bb_2 n5bb_2_0_text n5bb_3 n5bb_3_0_text ///
	n6_0_text n6_2_0_text n6_3_0_text n6 n6aa n6aa_2 n6aa_3 ///
	n6ab_0_text  n6ab_2_0_text  n6ab_3_0_text n6ac n6ac_2 n6ac_3 n6ba n6ba_2 n6ba_3 n6ca n6ca_2 n6ca_3 ///
	n6cb_0_text n6cb_2_0_text n6cb_3_0_text n6cc n6cc_2 n6cc_3 ///
	n7 n7_0_text n7_2 n7_2_0_text n7_3 n7_3_0_text ///
	n6a n6a_0_text n6a_2 n6a_2_0_text n6a_3 n6a_3_0_text ///
	n6b n6b_0_text n6b_2 n6b_2_0_text n6b_3 n6b_3_0_text  ///
	n6c n6c_0_text n6c_2 n6c_2_0_text n6c_3 n6c_3_0_text) ///
	(n5_meas1 n5_meas2 n5_meas3 n5a_meas1 n5a_response_meas1 n5a_meas2 n5a_response_meas2 n5a_meas3 n5a_response_meas3 ///
	nn5aa_meas1 revised_n5_meas1 nn5aa_meas2 revised_n5_meas2 nn5aa_meas3 revised_n5_meas3 ///
	n5b_meas1 n5b_meas2 n5b_meas3 n5bb_meas1 n5bb_response_meas1 n5bb_meas2 n5bb_response_meas2 n5bb_meas3 n5bb_response_meas3 ///
	n6_other_meas1 n6_other_meas2 n6_other_meas3 n6_meas1 n6aa_meas1 n6aa_meas2 n6aa_meas3 ///
	n6ab_meas1 n6ab_meas2 n6ab_meas3 n6ac_meas1 n6ac_meas2 n6ac_meas3 n6ba_meas1 n6ba_meas2 n6ba_meas3 n6ca_meas1 n6ca_meas2 n6ca_meas3 ///
	n6cb_meas1 n6cb_meas2 n6cb_meas3 n6cc_meas1 n6cc_meas2 n6cc_meas3 ///
	n7_meas1 n7_response_meas1 n7_meas2 n7_response_meas2 n7_meas3 n7_response_meas3 ///
	n6a_meas1 n6a_response_meas1 n6a_meas2 n6a_response_meas2 n6a_meas3 n6a_response_meas3 ///
	n6b_meas1 n6b_response_meas1 n6b_meas2 n6b_response_meas2 n6b_meas3 n6b_response_meas3  ///
	n6c_meas1 n6c_response_meas1 n6c_meas2 n6c_response_meas2 n6c_meas3 n6c_response_meas3)
		drop n6ab n6ab_2 n6ab_3 n6cb n6cb_2 n6cb_3
	
	rename (er2_0_text er2_2_0_text er2_3_0_text er6_0_text er6_2_0_text er6_3_0_text er9_0_text er9_2_0_text er9_3_0_text ///
	er15 er15_0_text er15_2 er15_2_0_text er15_3 er15_3_0_text ///
	er19 er19_0_text er19_2 er19_2_0_text er19_3 er19_3_0_text) ///
	(er2_meas1 er2_meas2 er2_meas3 er6_meas1 er6_meas2 er6_meas3 er9_meas1 er9_meas2 er9_meas3 ///
	er15_meas1 er15_response_meas1 er15_meas2 er15_response_meas2 er15_meas3 er15_response_meas3 ///
	er19_meas1 er19_response_meas1 er19_meas2 er19_response_meas2 er19_meas3 er19_response_meas3)
		drop er2 er2_2 er2_3 er6 er6_2 er6_3 er9 er9_2 er9_3

		drop lt2  cc12a ccc1
	rename (pp1 pp1_0_text pp2 pp2_0_text pp4 pp5 pp5_0_text lt2_0_text lt3 lt6 lt6_0_text lt7 lt7_0_text lt8 ///
	ca6_1 ca6_2 ca6_3 ca6_4 ca6_5 ca6_6 ca6_7 ca6_8 ca6_99 ca6_99_text  cc12a_0_text cc12b c0 ccc1_0_text c1_0_text) ///
	(pp1 pp1_response pp2 pp2_response pp4 pp5 pp5_response lt2 lt3 lt6 lt6_response lt7 lt7_response lt8 ///
	ca6_01 ca6_02 ca6_03 ca6_04 ca6_05 ca6_06 ca6_07 ca6_08 ca6_09 ca6_other cc12a cc12b co ccc1 c1_response)
	
	
	drop a__* ///
	addr_1 addr_2 addr_3 ap9a_0 ap9a_96 ap9a__98 ap9a__99 ca6__98 ///
	close1 close1_1_text close2 close2_1_text close3 close3_2_text contactemail_recruit_alt contactname_recruit_alt ///
	contactphonenumber_recruit contactphonenumber_recruit_alt contactphonenumberalt_recruit ///
	contactphonenumberalt_recruit_al contactphonetype_recruit contactphonetype_recruit_alt contacttype_recruit contacttype_recruit_alt ///
	distributionchannel dup_con duration__in_seconds_ a__22 enddate

	drop fin8_0 fin8_0_text fin8_1 fin8_10 fin8_2 fin8_2_0 fin8_2_0_text fin8_2_1 fin8_2_10 fin8_2_2 fin8_2_3 fin8_2_4 ///
	 fin8_2_5 fin8_2_6 fin8_2_7 fin8_2_8 fin8_2_9 fin8_2__98 fin8_2__99 fin8_3 fin8_3_0 fin8_3_0_text fin8_3_1 fin8_3_10 ///
	 fin8_3_2 fin8_3_3 fin8_3_4 fin8_3_5 fin8_3_6 fin8_3_7 fin8_3_8 fin8_3_9 fin8_3__98 fin8_3__99 fin8_4 fin8_5 fin8_6 fin8_7 ///
	 fin8_8 fin8_9 fin8__98 fin8__99 finished intro4_1 intro4_2 intro4_3 ///
	 ipaddress keydecisionmakeremail1 keydecisionmakeremail2 keydecisionmakername1 keydecisionmakername2 keydecisionmakerphone1 ///
	 keydecisionmakerphone2 locationlatitude locationlongitude n41a_* n6_2_* n6_3_* p2b p2b_2 p2b_3 pa ///
	 pretest sbd  program progress recipientemail recipientfirstname recipientlastname recordeddate recruit ///
	 repemail repmobile repname repphone responseid startdate status userlanguage v1a_97 v1a__98 v1a__99 wb
	
	replace cc12a="" if cc12a=="reduce costs overall"
	destring cc12a, replace
	recast str25 sbw_projid, force	
	destring obf, replace	
	
_strip_labels _all
	tostring _all, replace
	foreach var of varlist * {
			replace `var' = "" if  `var' == "-99"|`var' == "-98"|`var' == "-96"|`var' == "99"|`var' == "98"|`var' == "96"|`var' == "NA"|`var' == "N/A"
		}
	drop if sampleid=="139"| sampleid=="140"| sampleid=="64" |sampleid=="53"| sampleid=="56"| ///
	sampleid=="68"|sampleid=="397"|sampleid=="651"|sampleid=="739"|sampleid=="740"|sampleid=="741"|sampleid=="742"|sampleid=="743" ///
	|sampleid=="694"|sampleid=="695"|sampleid=="696"|sampleid=="697"|sampleid=="700"|sampleid=="701"|sampleid=="702"|sampleid=="704" ///
	|sampleid=="705"|sampleid=="706" ///
	|sampleid=="707"|sampleid=="708"|sampleid=="709"|sampleid=="710"|sampleid=="711"|sampleid=="712"|sampleid=="713"|sampleid=="716"
	
	drop if sbw_projid=="PRJ - 01182564"|sbw_projid=="PRJ - 01185924"|sbw_projid=="PRJ - 01193561"|sbw_projid=="PRJ - 01345252" ///
	|sbw_projid=="PRJ - 01345253"|sbw_projid=="PRJ - 01480526"|sbw_projid=="PRJ - 01510736"

		/// duplicates with PMR		
		
	replace aa3_meas1_1 ="2" if aa3_meas1_2=="1" & aa3_meas1_1==""
		replace aa3_meas1_2="" if aa3_meas1_1 =="2" & aa3_meas1_2=="1"
	replace aa3_meas1_1 ="3" if aa3_meas1_3=="1" & aa3_meas1_1=="" & aa3_meas1_2==""
		replace aa3_meas1_3="" if aa3_meas1_1 =="3" & aa3_meas1_3=="1"
	replace aa3_meas1_1 ="4" if aa3_meas1_4=="1" & aa3_meas1_1=="" & aa3_meas1_2=="" & aa3_meas1_3==""
		replace aa3_meas1_4="" if aa3_meas1_1 =="4" & aa3_meas1_4=="1"
	replace aa3_meas1_1 ="5" if aa3_meas1_5=="1" & aa3_meas1_1=="" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4==""
		replace aa3_meas1_5="" if aa3_meas1_1 =="5" & aa3_meas1_5=="1"	
	replace aa3_meas1_1 ="6" if aa3_meas1_6=="1" & aa3_meas1_1=="" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5==""
		replace aa3_meas1_6="" if aa3_meas1_1 =="6" & aa3_meas1_6=="1"
	replace aa3_meas1_1 ="7" if aa3_meas1_7=="1" & aa3_meas1_1=="" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5=="" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_1 =="7" & aa3_meas1_7=="1"
	
	replace aa3_meas1_2="2" if aa3_meas1_2=="1"
	replace aa3_meas1_2 ="3" if aa3_meas1_3=="1" & aa3_meas1_2==""
		replace aa3_meas1_3="" if aa3_meas1_2 =="3" & aa3_meas1_3=="1"	
	replace aa3_meas1_2 ="4" if aa3_meas1_4=="1" & aa3_meas1_2=="" & aa3_meas1_3==""
		replace aa3_meas1_4="" if aa3_meas1_2 =="4" & aa3_meas1_4=="1"
	replace aa3_meas1_2 ="5" if aa3_meas1_5=="1" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4==""
		replace aa3_meas1_5="" if aa3_meas1_2 =="5" & aa3_meas1_5=="1"
	replace aa3_meas1_2 ="6" if aa3_meas1_6=="1" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5==""
		replace aa3_meas1_6="" if aa3_meas1_2 =="6" & aa3_meas1_6=="1"
	replace aa3_meas1_2 ="7" if aa3_meas1_7=="1" & aa3_meas1_2=="" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5=="" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_2 =="7" & aa3_meas1_7=="1"	
		
	replace aa3_meas1_3="3" if aa3_meas1_3=="1"
	replace aa3_meas1_3 ="4" if aa3_meas1_4=="1" & aa3_meas1_3==""
		replace aa3_meas1_4="" if aa3_meas1_3 =="4" & aa3_meas1_4=="1"
	replace aa3_meas1_3 ="5" if aa3_meas1_5=="1" & aa3_meas1_3=="" & aa3_meas1_4==""
		replace aa3_meas1_5="" if aa3_meas1_3 =="5" & aa3_meas1_5=="1"
	replace aa3_meas1_3 ="6" if aa3_meas1_6=="1" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5==""
		replace aa3_meas1_6="" if aa3_meas1_3 =="6" & aa3_meas1_6=="1"
	replace aa3_meas1_3 ="7" if aa3_meas1_7=="1" & aa3_meas1_3=="" & aa3_meas1_4=="" & aa3_meas1_5=="" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_3 =="7" & aa3_meas1_7=="1"			
		
	replace aa3_meas1_4="4" if aa3_meas1_4=="1"
	replace aa3_meas1_4 ="5" if aa3_meas1_5=="1" & aa3_meas1_4==""
		replace aa3_meas1_5="" if aa3_meas1_4 =="5" & aa3_meas1_5=="1"
	replace aa3_meas1_4 ="6" if aa3_meas1_6=="1" & aa3_meas1_4=="" & aa3_meas1_5==""
		replace aa3_meas1_6="" if aa3_meas1_4 =="6" & aa3_meas1_6=="1"
	replace aa3_meas1_4 ="7" if aa3_meas1_7=="1" & aa3_meas1_4=="" & aa3_meas1_5=="" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_4 =="7" & aa3_meas1_7=="1"			
		
	replace aa3_meas1_5="5" if aa3_meas1_5=="1"
	replace aa3_meas1_5 ="6" if aa3_meas1_6=="1" & aa3_meas1_5==""
		replace aa3_meas1_6="" if aa3_meas1_5 =="6" & aa3_meas1_6=="1"
	replace aa3_meas1_5 ="7" if aa3_meas1_7=="1" & aa3_meas1_5=="" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_5 =="7" & aa3_meas1_7=="1"
		
	replace aa3_meas1_6="6" if aa3_meas1_6=="1"
	replace aa3_meas1_6 ="7" if aa3_meas1_7=="1" & aa3_meas1_6==""
		replace aa3_meas1_7="" if aa3_meas1_6 =="7" & aa3_meas1_7=="1"		
		
	replace aa3_meas1_7="7" if aa3_meas1_6=="1"

	
	replace ap9a_01="2" if ap9a_02=="1" & ap9a_01==""
		replace ap9a_02="" if ap9a_01=="2" & ap9a_02=="1"
	replace ap9a_01 ="3" if ap9a_03=="1" & ap9a_01=="" & ap9a_02==""
		replace ap9a_03="" if ap9a_01 =="3" & ap9a_03=="1"
	replace ap9a_01 ="4" if ap9a_04=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03==""
		replace ap9a_04="" if ap9a_01 =="4" & ap9a_04=="1"
	replace ap9a_01 ="5" if ap9a_05=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04==""
		replace ap9a_05="" if ap9a_01 =="5" & ap9a_05=="1"		
	replace ap9a_01 ="6" if ap9a_06=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05==""
		replace ap9a_06="" if ap9a_01 =="6" & ap9a_06=="1"
	replace ap9a_01 ="7" if ap9a_07=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06==""
		replace ap9a_07="" if ap9a_01 =="7" & ap9a_07=="1"
	replace ap9a_01 ="8" if ap9a_08=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_01 =="8" & ap9a_08=="1"
	replace ap9a_01 ="9" if ap9a_09=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_01 =="9" & ap9a_09=="1"
	replace ap9a_01 ="10" if ap9a_10=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_01 =="10" & ap9a_10=="1"
	replace ap9a_01 ="11" if ap9a_11=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_01 =="11" & ap9a_11=="1"
	replace ap9a_01 ="12" if ap9a_12=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_01 =="12" & ap9a_12=="1"
	replace ap9a_01 ="13" if ap9a_13=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_01 =="13" & ap9a_13=="1"
	replace ap9a_01 ="14" if ap9a_14=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_01 =="14" & ap9a_14=="1"
	replace ap9a_01 ="15" if ap9a_15=="1" & ap9a_01=="" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_01 =="15" & ap9a_15=="1"

	replace ap9a_02="2" if ap9a_02=="1" 
	replace ap9a_02 ="3" if ap9a_03=="1" & ap9a_02=="" 
		replace ap9a_03="" if ap9a_02 =="3" & ap9a_03=="1"	
	replace ap9a_02 ="4" if ap9a_04=="1" & ap9a_02=="" & ap9a_03==""
		replace ap9a_04="" if ap9a_02 =="4" & ap9a_04=="1"
	replace ap9a_02 ="5" if ap9a_05=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04==""
		replace ap9a_05="" if ap9a_02 =="5" & ap9a_05=="1"		
	replace ap9a_02 ="6" if ap9a_06=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05==""
		replace ap9a_06="" if ap9a_02 =="6" & ap9a_06=="1"
	replace ap9a_02 ="7" if ap9a_07=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06==""
		replace ap9a_07="" if ap9a_02 =="7" & ap9a_07=="1"
	replace ap9a_02 ="8" if ap9a_08=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_02 =="8" & ap9a_08=="1"
	replace ap9a_02 ="9" if ap9a_09=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_02 =="9" & ap9a_09=="1"
	replace ap9a_02 ="10" if ap9a_10=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_02 =="10" & ap9a_10=="1"
	replace ap9a_02 ="11" if ap9a_11=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_02 =="11" & ap9a_11=="1"
	replace ap9a_02 ="12" if ap9a_12=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_02 =="12" & ap9a_12=="1"
	replace ap9a_02 ="13" if ap9a_13=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_02 =="13" & ap9a_13=="1"
	replace ap9a_02 ="14" if ap9a_14=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_02 =="14" & ap9a_14=="1"
	replace ap9a_02 ="15" if ap9a_15=="1" & ap9a_02=="" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_02 =="15" & ap9a_15=="1"		
		
	replace ap9a_03 ="3" if ap9a_03=="1" 
	replace ap9a_03 ="4" if ap9a_04=="1" & ap9a_03==""
		replace ap9a_04="" if ap9a_03 =="4" & ap9a_04=="1"
	replace ap9a_03 ="5" if ap9a_05=="1" & ap9a_03=="" & ap9a_04==""
		replace ap9a_05="" if ap9a_03 =="5" & ap9a_05=="1"		
	replace ap9a_03 ="6" if ap9a_06=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05==""
		replace ap9a_06="" if ap9a_03 =="6" & ap9a_06=="1"
	replace ap9a_03 ="7" if ap9a_07=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06==""
		replace ap9a_07="" if ap9a_03 =="7" & ap9a_07=="1"
	replace ap9a_03 ="8" if ap9a_08=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_03 =="8" & ap9a_08=="1"
	replace ap9a_03 ="9" if ap9a_09=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_03 =="9" & ap9a_09=="1"
	replace ap9a_03 ="10" if ap9a_10=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_03 =="10" & ap9a_10=="1"
	replace ap9a_03 ="11" if ap9a_11=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_03 =="11" & ap9a_11=="1"
	replace ap9a_03 ="12" if ap9a_12=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_03 =="12" & ap9a_12=="1"
	replace ap9a_03 ="13" if ap9a_13=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_03 =="13" & ap9a_13=="1"
	replace ap9a_03 ="14" if ap9a_14=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_03 =="14" & ap9a_14=="1"
	replace ap9a_03 ="15" if ap9a_15=="1" & ap9a_03=="" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_03 =="15" & ap9a_15=="1"			
		
	replace ap9a_04 ="4" if ap9a_04=="1" 
	replace ap9a_04 ="5" if ap9a_05=="1" & ap9a_04==""
		replace ap9a_05="" if ap9a_04 =="5" & ap9a_05=="1"		
	replace ap9a_04 ="6" if ap9a_06=="1" & ap9a_04=="" & ap9a_05==""
		replace ap9a_06="" if ap9a_04 =="6" & ap9a_06=="1"
	replace ap9a_04 ="7" if ap9a_07=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06==""
		replace ap9a_07="" if ap9a_04 =="7" & ap9a_07=="1"
	replace ap9a_04 ="8" if ap9a_08=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_04 =="8" & ap9a_08=="1"
	replace ap9a_04 ="9" if ap9a_09=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_04 =="9" & ap9a_09=="1"
	replace ap9a_04 ="10" if ap9a_10=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_04 =="10" & ap9a_10=="1"
	replace ap9a_04 ="11" if ap9a_11=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_04 =="11" & ap9a_11=="1"
	replace ap9a_04 ="12" if ap9a_12=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_04 =="12" & ap9a_12=="1"
	replace ap9a_04 ="13" if ap9a_13=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_04 =="13" & ap9a_13=="1"
	replace ap9a_04 ="14" if ap9a_14=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_04 =="14" & ap9a_14=="1"
	replace ap9a_04 ="15" if ap9a_15=="1" & ap9a_04=="" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_04 =="15" & ap9a_15=="1"			

	replace ap9a_05 ="5" if ap9a_05=="1" 
	replace ap9a_05 ="6" if ap9a_06=="1" & ap9a_05==""
		replace ap9a_06="" if ap9a_05 =="6" & ap9a_06=="1"
	replace ap9a_05 ="7" if ap9a_07=="1" & ap9a_05=="" & ap9a_06==""
		replace ap9a_07="" if ap9a_05 =="7" & ap9a_07=="1"
	replace ap9a_05 ="8" if ap9a_08=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_05 =="8" & ap9a_08=="1"
	replace ap9a_05 ="9" if ap9a_09=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_05 =="9" & ap9a_09=="1"
	replace ap9a_05 ="10" if ap9a_10=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_05 =="10" & ap9a_10=="1"
	replace ap9a_05 ="11" if ap9a_11=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_05 =="11" & ap9a_11=="1"
	replace ap9a_05 ="12" if ap9a_12=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_05 =="12" & ap9a_12=="1"
	replace ap9a_05 ="13" if ap9a_13=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_05 =="13" & ap9a_13=="1"
	replace ap9a_05 ="14" if ap9a_14=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_05 =="14" & ap9a_14=="1"
	replace ap9a_05 ="15" if ap9a_15=="1" & ap9a_05=="" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_05 =="15" & ap9a_15=="1"			
		
	replace ap9a_06 ="6" if ap9a_06=="1" 
	replace ap9a_06 ="7" if ap9a_07=="1" & ap9a_06==""
		replace ap9a_07="" if ap9a_05 =="7" & ap9a_07=="1"
	replace ap9a_06 ="8" if ap9a_08=="1" & ap9a_06=="" & ap9a_07==""
		replace ap9a_08="" if ap9a_05 =="8" & ap9a_08=="1"
	replace ap9a_06 ="9" if ap9a_09=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_05 =="9" & ap9a_09=="1"
	replace ap9a_06 ="10" if ap9a_10=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_05 =="10" & ap9a_10=="1"
	replace ap9a_06 ="11" if ap9a_11=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_05 =="11" & ap9a_11=="1"
	replace ap9a_06 ="12" if ap9a_12=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_05 =="12" & ap9a_12=="1"
	replace ap9a_06 ="13" if ap9a_13=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_05 =="13" & ap9a_13=="1"
	replace ap9a_06 ="14" if ap9a_14=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_05 =="14" & ap9a_14=="1"
	replace ap9a_06 ="15" if ap9a_15=="1" & ap9a_06=="" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_06 =="15" & ap9a_15=="1"			
	
	replace ap9a_07 ="7" if ap9a_07=="1" 
	replace ap9a_07 ="8" if ap9a_08=="1" & ap9a_07==""
		replace ap9a_08="" if ap9a_07 =="8" & ap9a_08=="1"
	replace ap9a_07 ="9" if ap9a_09=="1" & ap9a_07=="" & ap9a_08==""
		replace ap9a_09="" if ap9a_07 =="9" & ap9a_09=="1"
	replace ap9a_07 ="10" if ap9a_10=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_07 =="10" & ap9a_10=="1"
	replace ap9a_07 ="11" if ap9a_11=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_07 =="11" & ap9a_11=="1"
	replace ap9a_07 ="12" if ap9a_12=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_07 =="12" & ap9a_12=="1"
	replace ap9a_07 ="13" if ap9a_13=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_07 =="13" & ap9a_13=="1"
	replace ap9a_07 ="14" if ap9a_14=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_07 =="14" & ap9a_14=="1"
	replace ap9a_07 ="15" if ap9a_15=="1" & ap9a_07=="" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_07 =="15" & ap9a_15=="1"		
	
	replace ap9a_08 ="8" if ap9a_08=="1" 
	replace ap9a_08 ="9" if ap9a_09=="1" & ap9a_08==""
		replace ap9a_09="" if ap9a_08 =="9" & ap9a_09=="1"
	replace ap9a_08 ="10" if ap9a_10=="1" & ap9a_08=="" & ap9a_09==""
		replace ap9a_10="" if ap9a_08 =="10" & ap9a_10=="1"
	replace ap9a_08 ="11" if ap9a_11=="1" & ap9a_08=="" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_08 =="11" & ap9a_11=="1"
	replace ap9a_08 ="12" if ap9a_12=="1" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_08 =="12" & ap9a_12=="1"
	replace ap9a_08 ="13" if ap9a_13=="1" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_08 =="13" & ap9a_13=="1"
	replace ap9a_08 ="14" if ap9a_14=="1" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_08 =="14" & ap9a_14=="1"
	replace ap9a_08 ="15" if ap9a_15=="1" & ap9a_08=="" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_08 =="15" & ap9a_15=="1"		
	
	replace ap9a_09 ="9" if ap9a_09=="1" 
	replace ap9a_09 ="10" if ap9a_10=="1" & ap9a_09==""
		replace ap9a_10="" if ap9a_09 =="10" & ap9a_10=="1"
	replace ap9a_09 ="11" if ap9a_11=="1" & ap9a_09=="" & ap9a_10==""
		replace ap9a_11="" if ap9a_09 =="11" & ap9a_11=="1"
	replace ap9a_09 ="12" if ap9a_12=="1" & ap9a_09=="" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_09 =="12" & ap9a_12=="1"
	replace ap9a_09 ="13" if ap9a_13=="1" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_09 =="13" & ap9a_13=="1"
	replace ap9a_09 ="14" if ap9a_14=="1" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_09 =="14" & ap9a_14=="1"
	replace ap9a_09 ="15" if ap9a_15=="1" & ap9a_09=="" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_09 =="15" & ap9a_15=="1"		
	
	replace ap9a_10 ="10" if ap9a_10=="1" 
	replace ap9a_10 ="11" if ap9a_11=="1" & ap9a_10==""
		replace ap9a_11="" if ap9a_10 =="11" & ap9a_11=="1"
	replace ap9a_10 ="12" if ap9a_12=="1" & ap9a_10=="" & ap9a_11==""
		replace ap9a_12="" if ap9a_10 =="12" & ap9a_12=="1"
	replace ap9a_10 ="13" if ap9a_13=="1" & ap9a_10=="" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_10 =="13" & ap9a_13=="1"
	replace ap9a_10 ="14" if ap9a_14=="1" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_10 =="14" & ap9a_14=="1"
	replace ap9a_10 ="15" if ap9a_15=="1" & ap9a_10=="" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_10 =="15" & ap9a_15=="1"	
		
	replace ap9a_11 ="11" if ap9a_11=="1" 
	replace ap9a_11 ="12" if ap9a_12=="1" & ap9a_11==""
		replace ap9a_12="" if ap9a_11 =="12" & ap9a_12=="1"
	replace ap9a_11 ="13" if ap9a_13=="1" & ap9a_11=="" & ap9a_12==""
		replace ap9a_13="" if ap9a_11 =="13" & ap9a_13=="1"
	replace ap9a_11 ="14" if ap9a_14=="1" & ap9a_11=="" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_11 =="14" & ap9a_14=="1"
	replace ap9a_11 ="15" if ap9a_15=="1" & ap9a_11=="" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_11 =="15" & ap9a_15=="1"	
		
	replace ap9a_12 ="12" if ap9a_12=="1" 
	replace ap9a_12 ="13" if ap9a_13=="1" & ap9a_12==""
		replace ap9a_13="" if ap9a_12 =="13" & ap9a_13=="1"
	replace ap9a_12 ="14" if ap9a_14=="1" & ap9a_12=="" & ap9a_13==""
		replace ap9a_14="" if ap9a_12 =="14" & ap9a_14=="1"
	replace ap9a_12 ="15" if ap9a_15=="1" & ap9a_12=="" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_12 =="15" & ap9a_15=="1"		
		
	replace ap9a_13 ="13" if ap9a_13=="1"
	replace ap9a_13 ="14" if ap9a_14=="1" & ap9a_13==""
		replace ap9a_14="" if ap9a_13 =="14" & ap9a_14=="1"
	replace ap9a_13 ="15" if ap9a_15=="1" & ap9a_13=="" & ap9a_14==""
		replace ap9a_15="" if ap9a_13 =="15" & ap9a_15=="1"	
		
	replace ap9a_14 ="14" if ap9a_14=="1" 
	replace ap9a_14 ="15" if ap9a_15=="1" & ap9a_14==""
		replace ap9a_15="" if ap9a_14 =="15" & ap9a_15=="1"	

	replace ap9a_15 ="15" if ap9a_15=="1" 
	
	replace ca6_01 ="2" if ca6_02=="1" & ca6_01==""
		replace ca6_02="" if ca6_01 =="2" & ca6_02=="1"
	replace ca6_01 ="3" if ca6_03=="1" & ca6_01=="" & ca6_02==""
		replace ca6_03="" if ca6_01 =="3" & ca6_03=="1"
	replace ca6_01 ="4" if ca6_04=="1" & ca6_01=="" & ca6_02=="" & ca6_03==""
		replace ca6_04="" if ca6_01 =="4" & ca6_04=="1"
	replace ca6_01 ="5" if ca6_05=="1" & ca6_01=="" & ca6_02=="" & ca6_03=="" & ca6_04==""
		replace ca6_05="" if ca6_01 =="5" & ca6_05=="1"
	replace ca6_01 ="6" if ca6_06=="1" & ca6_01=="" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05==""
		replace ca6_06="" if ca6_01 =="6" & ca6_06=="1"	
	replace ca6_01 ="7" if ca6_07=="1" & ca6_01=="" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06==""
		replace ca6_07="" if ca6_01 =="7" & ca6_07=="1"	
	replace ca6_01 ="8" if ca6_08=="1" & ca6_01=="" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_01 =="8" & ca6_08=="1"	
	replace ca6_01 ="9" if ca6_09=="1" & ca6_01=="" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_01 =="9" & ca6_09=="1"
		
	replace ca6_02 ="2" if ca6_02=="1" 
	replace ca6_02 ="3" if ca6_03=="1" & ca6_02==""
		replace ca6_03="" if ca6_02 =="3" & ca6_03=="1"
	replace ca6_02 ="4" if ca6_04=="1" & ca6_02=="" & ca6_03==""
		replace ca6_04="" if ca6_02 =="4" & ca6_04=="1"
	replace ca6_02 ="5" if ca6_05=="1" & ca6_02=="" & ca6_03=="" & ca6_04==""
		replace ca6_05="" if ca6_02 =="5" & ca6_05=="1"
	replace ca6_02 ="6" if ca6_06=="1" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05==""
		replace ca6_06="" if ca6_02 =="6" & ca6_06=="1"	
	replace ca6_02 ="7" if ca6_07=="1" &  ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06==""
		replace ca6_07="" if ca6_02 =="7" & ca6_07=="1"	
	replace ca6_02 ="8" if ca6_08=="1" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_02 =="8" & ca6_08=="1"	
	replace ca6_02 ="9" if ca6_09=="1" & ca6_02=="" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_02 =="9" & ca6_09=="1"
		
	replace ca6_03 ="3" if ca6_03=="1" 
	replace ca6_03 ="4" if ca6_04=="1" & ca6_03==""
		replace ca6_04="" if ca6_03 =="4" & ca6_04=="1"
	replace ca6_03 ="5" if ca6_05=="1" & ca6_03=="" & ca6_04==""
		replace ca6_05="" if ca6_03 =="5" & ca6_05=="1"
	replace ca6_03 ="6" if ca6_06=="1" & ca6_03=="" & ca6_04=="" & ca6_05==""
		replace ca6_06="" if ca6_03 =="6" & ca6_06=="1"	
	replace ca6_03 ="7" if ca6_07=="1" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06==""
		replace ca6_07="" if ca6_03 =="7" & ca6_07=="1"	
	replace ca6_03 ="8" if ca6_08=="1" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_03 =="8" & ca6_08=="1"	
	replace ca6_03 ="9" if ca6_09=="1" & ca6_03=="" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_03 =="9" & ca6_09=="1"		
		
	replace ca6_04 ="4" if ca6_04=="1" 
	replace ca6_04 ="5" if ca6_05=="1" & ca6_04==""
		replace ca6_05="" if ca6_04 =="5" & ca6_05=="1"
	replace ca6_04 ="6" if ca6_06=="1" & ca6_04=="" & ca6_05==""
		replace ca6_06="" if ca6_04 =="6" & ca6_06=="1"	
	replace ca6_04 ="7" if ca6_07=="1" & ca6_04=="" & ca6_05=="" & ca6_06==""
		replace ca6_07="" if ca6_04 =="7" & ca6_07=="1"	
	replace ca6_04 ="8" if ca6_08=="1" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_04 =="8" & ca6_08=="1"	
	replace ca6_04 ="9" if ca6_09=="1" & ca6_04=="" & ca6_05=="" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_04 =="9" & ca6_09=="1"	
		
	replace ca6_05 ="5" if ca6_05=="1" 
	replace ca6_05 ="6" if ca6_06=="1" & ca6_05==""
		replace ca6_06="" if ca6_05 =="6" & ca6_06=="1"	
	replace ca6_05 ="7" if ca6_07=="1" & ca6_05=="" & ca6_06==""
		replace ca6_07="" if ca6_05 =="7" & ca6_07=="1"	
	replace ca6_05 ="8" if ca6_08=="1" & ca6_05=="" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_05 =="8" & ca6_08=="1"	
	replace ca6_05 ="9" if ca6_09=="1" & ca6_05=="" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_05 =="9" & ca6_09=="1"			
		
	replace ca6_06 ="6" if ca6_06=="1" 
	replace ca6_06 ="7" if ca6_07=="1" & ca6_06==""
		replace ca6_07="" if ca6_06 =="7" & ca6_07=="1"	
	replace ca6_06 ="8" if ca6_08=="1" & ca6_06=="" & ca6_07==""
		replace ca6_08="" if ca6_06 =="8" & ca6_08=="1"	
	replace ca6_06 ="9" if ca6_09=="1" & ca6_06=="" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_06 =="9" & ca6_09=="1"			
		
	replace ca6_07 ="7" if ca6_07=="1" 
	replace ca6_07 ="8" if ca6_08=="1" & ca6_07==""
		replace ca6_08="" if ca6_07 =="8" & ca6_08=="1"	
	replace ca6_07 ="9" if ca6_09=="1" & ca6_07=="" & ca6_08==""
		replace ca6_09="" if ca6_07 =="9" & ca6_09=="1"	

	replace ca6_08 ="8" if ca6_08=="1" 
	replace ca6_08 ="9" if ca6_09=="1" & ca6_08==""
		replace ca6_09="" if ca6_08 =="9" & ca6_09=="1"	

	replace ca6_09 ="9" if ca6_09=="1"

		drop if sampleid=="250" // it's also in the sbd file
		
	replace a1b="1" if sampleid=="266"
// save
save "$work/ciac_nonsbd_enhanced.dta", replace


	*************************************************************
	// Merge Basic, Standard, and Enhanced Together
	*************************************************************
	use "$work/ciac_nonsbd_enhanced.dta", clear
	append using "$work/ciac_PMR_completes_cleaned_2_21_2020.dta", force
	save "$work/ciac_B&S&E.dta", replace
	*************************************************************
	// Merge Enhanced SBD Together
	*************************************************************
	// use this file to match variables
	use "$work/ciac_sbd_completes.dta", clear
	append using "$work/ciac_B&S&E.dta", force

	order ClaimId1, before(aa3_meas1_1)
	replace sbd = "0" if ciac_nsbd == "1"
	replace obf="" if obf=="0"
	order completed, first
		replace completed ="1"
	order wb_npi4, after(wb_npi3)
		
		foreach var of varlist _all ///
		{
				replace `var' = "" if `var' == "9999998"|`var' == "-99"|`var' == "-98"|`var' == "-96" |`var' == "99"|`var' == "98"|`var' == "96"|`var' == "NA" ///
				|`var' == "-999"|`var' == "-998"|`var' == "-996"|`var' == "."
			}	
			
	replace  n6a_meas1=".5" if sampleid=="115"
	replace sampleid="96" if sbw_projid=="PRJ - 00035428"
	replace fdintro ="0" if fdintro =="OO"
	
	replace n3b_meas1 = revised_n3b_meas1 if revised_n3b_meas1 != "" & revised_n3b_meas1 != "." & revised_n3b_meas1 != " "
	replace n3b_meas2 = revised_n3b_meas2 if revised_n3b_meas2 != "" & revised_n3b_meas2 != "." & revised_n3b_meas2 != " "
	replace n3b_meas3 = revised_n3b_meas3 if revised_n3b_meas3 != "" & revised_n3b_meas3 != "." & revised_n3b_meas3 != " "

	replace revised_n5_meas1= "9" if revised_n5_meas1=="10 Rebate ,9 likelihood"	
	replace n5_meas1 = revised_n5_meas1 if revised_n5_meas1 != "" & revised_n5_meas1 != "." & revised_n5_meas1 != " "
	replace n5_meas2 = revised_n5_meas2 if revised_n5_meas2 != "" & revised_n5_meas2 != "." & revised_n5_meas2 != " "
	replace n5_meas3 = revised_n5_meas3 if revised_n5_meas3 != "" & revised_n5_meas3 != "." & revised_n5_meas3 != " "
	
	drop revised_n5_meas1 revised_n5_meas2 revised_n5_meas3
	
	replace ClaimId1 =  "" if sbd =="1" & sys== "1"
	replace ClaimId2 =  "" if sbd =="1" & sys== "1"
	replace ClaimId3 =  "" if sbd =="1" & sys== "1"
	
	destring sampleid, replace
	merge 1:1 sampleid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\Dispositions\CIAC_Net Survey Dispositions.dta"
	keep if _merge==3
	drop RECRUIT PRETEST RIGOR type numofattempts disposition complete_date pending_QC _merge
	replace last_updated_date= "2/5/2020" if sampleid==315
	replace last_updated_date= "2/5/2020" if sampleid==309
	replace last_updated_date= "2/5/2020" if sampleid==44
	replace pi7="2" if pi7=="1 and 2, back and forth"

		replace lt2="10" if strpos(lt2,"Over 10")
		replace lt2="12.5" if strpos(lt2,"10 to 15")
		replace ccc1="" if ccc1=="NA - factories"| ccc1=="We have several different facilities: City Hall is 222,000 sq ft. and the police Dept. 35,0000"| ccc1=="9999999"| strpos(ccc1, "20 a")
		replace ccc1="150,000" if ccc1=="100,000-200,000"
		replace n6ab_meas1="2" if n6ab_meas1=="Not until someone complained- 2 years approx"
		replace n6ab_meas2="2" if n6ab_meas2=="Not until someone complained- 2 years approx"
		replace n6ab_meas3="2" if n6ab_meas3=="Not until someone complained- 2 years approx"
		replace fdintro ="0" if fdintro == "oo"
		replace fdintro ="1" if fdintro == "ROI/ operating cost"
		replace fd1="0" if fd1=="OO"
		replace sbd_lt2 ="1" if strpos(sbd_lt2, "1")
		replace sbd_lt2 = "2" if strpos(sbd_lt2, "2")
		replace sbd_lt2 = "" if sbd_lt2!="1"| sbd_lt2!="2"
		replace sbd_lt3 ="1" if strpos(sbd_lt3, "1")
		replace sbd_lt3 = "2" if strpos(sbd_lt3, "2")
		replace sbd_lt3 = "" if sbd_lt3!="1"| sbd_lt3!="2"
		replace n6ab_meas1="" if n6ab_meas1=="Until the equipment fails"
		replace n6ab_meas2="" if n6ab_meas2=="Until the equipment fails"
		replace n6ab_meas3="" if n6ab_meas3=="Until the equipment fails"
		replace n6cb_meas1="3" if strpos(n6cb_meas1,"Feb")
		replace n6cb_meas2="3" if strpos(n6cb_meas2,"Feb")
		replace n6cb_meas3="3" if strpos(n6cb_meas3,"Feb")
		replace er2_meas1="7.5" if  strpos(er2_meas1,"5 to 10")		
		replace er2_meas1="" if  strpos(er2_meas1,"Until fail")
		replace er2_meas1="2.5" if strpos(er2_meas1,"2 to 3")
		replace er2_meas1="6" if strpos(er2_meas1,"-6")
		replace er6_meas1="" if strpos(er6_meas1,"75%")
		replace er9_meas1="3" if strpos(er9_meas1,"2 to 4")
		replace er9_meas1="2.5" if strpos(er9_meas1,"2 to 3")		
		replace er9_meas1="5.5" if strpos(er9_meas1,"5 to 6")
		replace er9_meas1="" if strpos(er9_meas1,"Repair as")
		replace er9_meas1="7.5" if  strpos(er9_meas1,"5 to 10")			
		replace er9_meas1="2.5" if  strpos(er9_meas1,"1 to 4")	
		replace er2_meas2="7.5" if  strpos(er2_meas2,"5 to 10")		
		replace er2_meas2="" if  strpos(er2_meas2,"Until fail")
		replace er2_meas2="2.5" if strpos(er2_meas2,"2 to 3")
		replace er2_meas2="6" if strpos(er2_meas2,"-6")
		replace er6_meas2="" if strpos(er6_meas2,"75%")
		replace er9_meas2="3" if strpos(er9_meas2,"2 to 4")
		replace er9_meas2="2.5" if strpos(er9_meas2,"2 to 3")		
		replace er9_meas2="5.5" if strpos(er9_meas2,"5 to 6")
		replace er9_meas2="" if strpos(er9_meas2,"Repair as")
		replace er9_meas2="7.5" if  strpos(er9_meas2,"5 to 10")			
		replace er9_meas2="2.5" if  strpos(er9_meas2,"1 to 4")	
		replace er2_meas3="7.5" if  strpos(er2_meas3,"5 to 10")		
		replace er2_meas3="" if  strpos(er2_meas3,"Until fail")
		replace er2_meas3="2.5" if strpos(er2_meas3,"2 to 3")
		replace er2_meas3="6" if strpos(er2_meas3,"-6")
		replace er6_meas3="" if strpos(er6_meas3,"75%")
		replace er9_meas3="3" if strpos(er9_meas3,"2 to 4")
		replace er9_meas3="2.5" if strpos(er9_meas3,"2 to 3")		
		replace er9_meas3="5.5" if strpos(er9_meas3,"5 to 6")
		replace er9_meas3="" if strpos(er9_meas3,"Repair as")
		replace er9_meas3="7.5" if  strpos(er9_meas3,"5 to 10")			
		replace er9_meas3="2.5" if  strpos(er9_meas3,"1 to 4")	
		replace incent1="1%" if  strpos(incent1,"<")&strpos(incent1,"1%")		
		replace ccc1="150000" if strpos(ccc1,"150,000")
	
	destring _all, replace
			replace cc12a=. if cc12a>9995
	replace contact= "Anna Levitt" if sampleid==315
	replace business= "University of California, San Diego" if sampleid==315
	drop meas1 meas_1_date
	merge 1:1 sampleid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Enhanced Non SBD Info.dta", keepusing(meas1 meas_1_date)
	keep if _merge==3
	drop _merge samedecisionprocess aez
	order meas1 meas_1_date , after(business)
	
	gen wb_npi8_orig = wb_npi8
	gen sa_npi8_meas1_orig = sa_npi8_meas1
	gen sa_npi8_meas2_orig = sa_npi8_meas2
	gen sa_npi8_meas3_orig = sa_npi8_meas3
	gen n3j_meas1_orig = n3j_meas1
	gen n3j_meas2_orig = n3j_meas2
	gen n3j_meas3_orig = n3j_meas3
	
	replace wb_npi8=1 if wb_npi8!=.
	replace sa_npi8_meas1=1 if sa_npi8_meas1!=.
	replace sa_npi8_meas2=1 if sa_npi8_meas2!=.
	replace sa_npi8_meas3=1 if sa_npi8_meas3!=.
	replace n3j_meas1=1 if n3j_meas1!=.
	replace n3j_meas2=1 if n3j_meas2!=.
	replace n3j_meas3=1 if n3j_meas3!=.
	
	order wb_npi8_orig, after(wb_npi8)
	order sa_npi8_meas1_orig, after(sa_npi8_meas1)
	order sa_npi8_meas2_orig, after(sa_npi8_meas2)
	order sa_npi8_meas3_orig, after(sa_npi8_meas3)
	order n3j_meas1_orig, after(n3j_meas1)
	order n3j_meas2_orig, after(n3j_meas2)
	order n3j_meas3_orig, after(n3j_meas3)
	
	replace last_updated_date ="2/21/2020"
	
	gen n5_meas1_orig = n5_meas1
	gen n5_meas2_orig = n5_meas2
	gen n5_meas3_orig = n5_meas3
	gen sa_ap1_meas1_orig = sa_ap1_meas1
	gen sa_ap1_meas2_orig = sa_ap1_meas2
	gen sa_ap1_meas3_orig = sa_ap1_meas3

	gen n5_meas1_new = 10 - n5_meas1
	gen n5_meas2_new = 10 - n5_meas2
	gen n5_meas3_new = 10 - n5_meas3
	gen sa_ap1_meas1_new = 10 - sa_ap1_meas1
	gen sa_ap1_meas2_new = 10 - sa_ap1_meas2
	gen sa_ap1_meas3_new = 10 - sa_ap1_meas3

	replace n5_meas1 = n5_meas1_new
	replace n5_meas2 =n5_meas2_new
	replace n5_meas3  =n5_meas3_new
	replace sa_ap1_meas1 =sa_ap1_meas1_new
	replace sa_ap1_meas2 =sa_ap1_meas2_new
	replace sa_ap1_meas3 =sa_ap1_meas3_new
	
	drop n5_meas1_new n5_meas2_new n5_meas3_new ///
	sa_ap1_meas1_new sa_ap1_meas2_new sa_ap1_meas3_new
	
	order n5_meas1_orig, after(n5_meas1)
	order n5_meas2_orig, after(n5_meas2)
	order n5_meas3_orig, after(n5_meas3)
	order sa_ap1_meas1_orig, after(sa_ap1_meas1)
	order sa_ap1_meas2_orig, after(sa_ap1_meas2)
	order sa_ap1_meas3_orig, after(sa_ap1_meas3)
		
	drop if sampleid == 156
	replace n6a_meas1= .15 if strpos(n6a_response_meas1,"15")
	replace n6a_meas1= .5 if strpos(n6a_response_meas1,"half")
	replace n6a_meas1= .02 if strpos(n6a_response_meas1,"2")
	
	// Merge in vedor interviews
	foreach var of varlist v_aa1 v_aa2 v_a1 v_a2 v_a3 v2_meas1 v3_meas1 v4_meas1 v5_meas1 v6a_meas1 v6aa_meas1 ///
	v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 ///
	v13a_meas1 v14_meas1 v15_meas1 v16_meas1 v16a_meas1 ///
	{
		tostring `var'  ,replace
	}		
	merge 1:1 sampleid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Vendor Info.dta", update replace force	
	destring _all, replace
	replace last_updated_date= "2/28/2020" if _merge==5
	drop _merge
	replace last_updated_date= "3/02/2020" if sampleid==249|sampleid==329|sampleid==343

	// Save
	save "$work/ciac_all_completes.dta", replace
	
	export excel using "$work\ciac_all_completes.xlsx", firstrow(variables) nolabel replace

/*	
	drop complete_date
	merge 1:1 sbw_projid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\Dispositions\CIAC_Net Survey Dispositions.dta"
		
	gen pending_QC = 1 if (disposition== "Complete" | disposition=="COMPLETE") & completed==.
	keep completed sampleid sbw_projid RECRUIT PRETEST RIGOR DO_NOT_CONTACT type numofattempts complete_date disposition pending_QC
	order sampleid sbw_projid RECRUIT PRETEST RIGOR DO_NOT_CONTACT type numofattempts complete_date disposition pending_QC completed
	drop DO_NOT_CONTACT completed
	replace complete_date="" if strpos(disposition,"SCHE")|strpos(disposition,"DROPPED")
	export delimited using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\Dispositions\CIAC_Net Survey Dispositions_QC flag.csv", replace
*/
