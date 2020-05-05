/***************************************
Created By: Dan Hudgins
Creation Date: 2019-12-22

Last Modified By: Dan Hudgins
Modified Date: 2019-12-23

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
global raw "$main\_PMR\Completed Surveys"
exit

/*************************************************************************

			STEP 0: Create Formatted and Labeled, but RAW Dataset

**************************************************************************/
use "$raw\CIAC 2018 Evaluation_2020_1_24.dta", clear

// Fix Labels	
	// vlabelfix2 // Copy this output to a do file and put it in AMO Res HVAC - Survey Labels.do file
	
	use "$raw\CIAC 2018 Evaluation_2020_1_24.dta", clear	
	// displaylabel // Copy this output into the same do file as above
	
	//edit and execute
	//do "$syntax/CIAC Basic and Standard Survey Labels.do"

// Import raw data
	
//import delimited "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_PMR\Completed Surveys\CIAC 2018 Evaluation_2019_12_23.csv", encoding(UTF-8) clear 
import delimited "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_PMR\Completed Surveys\CIAC 2018 Evaluation_2020_2_21.csv", bindquote(strict) encoding(utf8) // drop variables that PMR did not update
	// Fix survey labels
		do "$syntax/CIAC Basic and Standard Survey Labels.do"

	drop verifiedphone respondentsname l_intv doi version wave rigor meas1 meas2 meas3 multimeas multiaddr sector 
	
// Merge survey data with sample file
		merge 1:1 sbw_projid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_All Sample with added Net Sample.dta", keepusing (sampleid ClaimI*	///
		MEAS1 MEAS2 MEAS3 MEAS1_DATE MEAS2_DATE MEAS3_DATE contactname_recruit BUSINESS SECTOR RIGOR MULTIMEAS MULTIADDR) 
		rename (MEAS1 MEAS2 MEAS3 MEAS1_DATE MEAS2_DATE MEAS3_DATE contactname_recruit BUSINESS SECTOR RIGOR MULTIMEAS MULTIADDR) ///
		(meas1 meas2 meas3 meas_1_date meas_2_date meas_3_date contact business sector rigor multimeas multiaddr)
		gen ciac_nsbd = 1
		keep if _merge == 3
		gen completed = 1
		order completed, first
		drop _merge

// Rename variables in sections

//Measure 1 loop
rename (aa3_1_01 aa3_1_02 aa3_1_03 aa3_1_04 aa3_1_05 aa3_1_06 aa3_1_07 aa3_1_08	aa3_1other obf1_1 n2_1 n3a_1 n3aa_1 n3aa_response_1 n3b_1 n3bb_1 n3bb_response_1) ///
(aa3_meas1_1 aa3_meas1_2 aa3_meas1_3 aa3_meas1_4 aa3_meas1_5 aa3_meas1_6 aa3_meas1_7 aa3_meas1_98 aa3_meas1other obf1_meas1 n2_meas1 n3a_meas1 n3aa_meas1 ///
n3aa_response_meas1 n3b_meas1 n3bb_meas1 n3bb_response_meas1)

rename (n3c_1 n3cc_1 n3cc_response_1 n3d_1 n3e_1 n3f_1 n3ff_1 n3ff_response_1 n3g_1 n3gg_1 n3gg_response_1 n3ggg_1 n3ggg_response_1 ///
n3h_1 n3hh_1 n3hh_response_1 n3hhh_1 n3hhh_response_1 n3i_1 n3j_1 n3k_1	n3kk1_1	n3kk1_response_1 n3kk2_1 n3kk2_response_1) ///
(n3c_meas1 n3cc_meas1 n3cc_response_meas1 n3d_meas1 n3e_meas1 n3f_meas1 n3ff_meas1 n3ff_response_meas1 n3g_meas1 n3gg_meas1 ///
n3gg_response_meas1 n3ggg_meas1 n3ggg_response_meas1 n3h_meas1 n3hh_meas1 n3hh_response_meas1 n3hhh_meas1 ///
n3hhh_response_meas1 n3i_meas1 n3j_meas1 n3k_meas1 n3kk1_meas1 n3kk1_response_meas1 n3kk2_meas1	n3kk2_response_meas1)

rename (fin0_1 fin1_a_1	fin1_b_1 fin1_c_1 fin7_1_01 fin7_1_02 fin7_1_03 fin7_1_04 fin7_1_05 fin7_other_1 fin8_1_01 fin8_1_02 fin8_1_03 fin8_other_1) ///
(fin0_meas1 fin1_a_meas1 fin1_b_meas1 fin1_c_meas1 fin7_meas1_1	fin7_meas1_2 fin7_meas1_3 fin7_meas1_4 fin7_meas1_5 fin7_other_meas1 fin8_meas1_1 ///
fin8_meas1_2 fin8_meas1_3 fin8_other_meas1)

rename (n3l_1 n3ll_1 n3ll_response_1 n3lll_1 n3lll_response_1 n3m_1 n3n_1 n3o_1 n3oo_1 n3oo_response_1 n3p_1 n3pp_1 n3pp_response_1 n3q_1 ///
n3r_1 n3rr_1 n3rr_response_1 n3rrr_1 n3rrr_response_1 n3s_1 n3t_1_01 n3t_1_02 n3t_other_1_1 n3t_other_2_1 n3tt_1_1 n3tt_2_1 n3ttt_1 n3ttt_1_response) ///
(n3l_meas1 n3ll_meas1 n3ll_response_meas1 n3lll_meas1 n3lll_response_meas1 n3m_meas1 n3n_meas1 n3o_meas1 n3oo_meas1 n3oo_response_meas1 n3p_meas1 ///
n3pp_meas1 n3pp_response_meas1 n3q_meas1 n3r_meas1 n3rr_meas1 n3rr_response_meas1 n3rrr_meas1 n3rrr_response_meas1 n3s_meas1 n3t_meas1_1 n3t_meas1_2 ///
n3t_other_meas1_meas1 n3t_other_2_meas1 n3tt_1_meas1 n3tt_2_meas1 n3ttt_meas1 n3ttt_meas1_response)

rename (cc1_1 cc1_response_1 cc1a_1 cc1a_response_1 ncc3_1 ncc3_response_1 ncc3a_1 ncc3a_response_1 p1_1_01 p1_1_02 p1_1_03 p1_other_1 p2a_1 p2b_1 ///
p3_1 p4_1 p3a_1	p3a_response_1 p3e_1 p3e_response_1 cp1_1 cp1a_1 cp1a_response_1 cp2_1 cp2_response_1 cp3_1 cp3a_1 cp3a_response_1 cp4_1 cp4_response_1 ///
cp6_1 cp6_response_1 sp1_1 sp1_response_1 sp2_1 sp2a_1 sp2a_response_1	sp3_1 sp3_response_1 sp3a_1 sp4_1 sp4_response_1 sp5_1 sp5_response_1 n41_1 ///
n42_1 n5_1 n5a_1 n5a_response_1 nn5aa_1 revised_n3b_1 revised_n5_1 n5b_1 n5bb_1	n5bb_response_1	n6_1 n6_other_1 n6aa_1 n6ab_1 n6ac_1 n6ba_1 n6ca_1 ///
n6cb_1 n6cc_1 n7_1 n7_response_1 n6a_1 n6a_response_1 n6b_1 n6b_response_1 n6c_1 n6c_response_1 er2_1 er6_1 er9_1 er15_1 er15_response_1 er19_1 er19_response_1) ///
(cc1_meas1 cc1_response_meas1 cc1a_meas1 cc1a_response_meas1 ncc3_meas1	ncc3_response_meas1 ncc3a_meas1	ncc3a_response_meas1 p1_meas1_1	p1_meas1_2 ///
p1_meas1_3 p1_other_meas1 p2a_meas1 p2b_meas1 p3_meas1	p4_meas1 p3a_meas1 p3a_response_meas1 p3e_meas1	p3e_response_meas1 cp1_meas1 cp1a_meas1 cp1a_response_meas1 ///
cp2_meas1 cp2_response_meas1 cp3_meas1	cp3a_meas1 cp3a_response_meas1 cp4_meas1 cp4_response_meas1 cp6_meas1 cp6_response_meas1 sp1_meas1 sp1_response_meas1 sp2_meas1	///
sp2a_meas1 sp2a_response_meas1 sp3_meas1 sp3_response_meas1 sp3a_meas1	sp4_meas1 sp4_response_meas1 sp5_meas1 sp5_response_meas1 n41_meas1 n42_meas1 n5_meas1 ///
n5a_meas1 n5a_response_meas1 nn5aa_meas1 revised_n3b_meas1 revised_n5_meas1 n5b_meas1 n5bb_meas1 n5bb_response_meas1 n6_meas1 n6_other_meas1 n6aa_meas1	n6ab_meas1 ///
n6ac_meas1 n6ba_meas1 n6ca_meas1 n6cb_meas1 n6cc_meas1 n7_meas1 n7_response_meas1 n6a_meas1 n6a_response_meas1 n6b_meas1 ///
n6b_response_meas1 n6c_meas1 n6c_response_meas1	er2_meas1 er6_meas1 er9_meas1 er15_meas1 er15_response_meas1 er19_meas1 er19_response_meas1)	

//Measure 2 loop
rename (aa3_2_01 aa3_2_02 aa3_2_03 aa3_2_04 aa3_2_05 aa3_2_06 aa3_2_07 aa3_2_08 aa3_2other obf1_2 n2_2	n3a_2 n3aa_2 n3aa_response_2 n3b_2 n3bb_2 n3bb_response_2) ///
(aa3_meas2_1 aa3_meas2_2 aa3_meas2_3 aa3_meas2_4 aa3_meas2_5 aa3_meas2_6 aa3_meas2_7 aa3_meas2_98 aa3_meas2other obf1_meas2 n2_meas2 n3a_meas2 n3aa_meas2 ///
n3aa_response_meas2 n3b_meas2 n3bb_meas2 n3bb_response_meas2)

rename (n3c_2	n3cc_2	n3cc_response_2	n3d_2	n3e_2	n3f_2	n3ff_2	n3ff_response_2	n3g_2 n3gg_2 n3gg_response_2	n3ggg_2	n3ggg_response_2 n3h_2	///
n3hh_2	n3hh_response_2	n3hhh_2	n3hhh_response_2 n3i_2	n3j_2	n3k_2	n3kk1_2	n3kk1_response_2 n3kk2_2 n3kk2_response_2) ///
(n3c_meas2 n3cc_meas2 n3cc_response_meas2 n3d_meas2 n3e_meas2 n3f_meas2 n3ff_meas2 n3ff_response_meas2 n3g_meas2 n3gg_meas2 ///
n3gg_response_meas2 n3ggg_meas2 n3ggg_response_meas2 n3h_meas2 n3hh_meas2 n3hh_response_meas2 n3hhh_meas2 ///
n3hhh_response_meas2 n3i_meas2 n3j_meas2 n3k_meas2 n3kk1_meas2 n3kk1_response_meas2 n3kk2_meas2	n3kk2_response_meas2)

rename (fin0_2	fin1_a_2	fin1_b_2	fin1_c_2	fin7_2_01	fin7_2_02	fin7_2_03	fin7_2_04	///
fin7_2_05	fin7_other_2	fin8_2_01	fin8_2_02	fin8_2_03	fin8_other_2) ///
(fin0_meas2 fin1_a_meas2 fin1_b_meas2 fin1_c_meas2 fin7_meas2_1	fin7_meas2_2 fin7_meas2_3 fin7_meas2_4 fin7_meas2_5 fin7_other_meas2 fin8_meas2_1 ///
fin8_meas2_2 fin8_meas2_3 fin8_other_meas2)

rename (n3l_2 n3ll_2 n3ll_response_2 n3lll_2 n3lll_response_2 n3m_2 n3n_2 n3o_2	n3oo_2 n3oo_response_2 n3p_2 n3pp_2 n3pp_response_2 n3q_2 ///
n3r_2 n3rr_2 n3rr_response_2 n3rrr_2 n3rrr_response_2 n3s_2 n3t_2_01 n3t_2_02 n3t_other_1_2 n3t_other_2_2 n3tt_1_2 n3tt_2_2 n3ttt_2 n3ttt_2_response) ///
(n3l_meas2 n3ll_meas2 n3ll_response_meas2 n3lll_meas2 n3lll_response_meas2 n3m_meas2 n3n_meas2 n3o_meas2 n3oo_meas2 n3oo_response_meas2 n3p_meas2 ///
n3pp_meas2 n3pp_response_meas2 n3q_meas2 n3r_meas2 n3rr_meas2 n3rr_response_meas2 n3rrr_meas2 n3rrr_response_meas2 n3s_meas2 n3t_meas2_1 n3t_meas2_2 ///
n3t_other_meas2_meas2 n3t_other_2_meas2 n3tt_1_meas2 n3tt_2_meas2 n3ttt_meas2 n3ttt_meas2_response)

rename(cc1_2	cc1_response_2	cc1a_2	cc1a_response_2	ncc3_2	ncc3_response_2	ncc3a_2	ncc3a_response_2	///
p1_2_01	p1_2_02	p1_2_03	p1_other_2	p2a_2	p2b_2	p3_2	p4_2	p3a_2	p3a_response_2	p3e_2	p3e_response_2	cp1_2	cp1a_2	cp1a_response_2	cp2_2	///
cp2_response_2	cp3_2	cp3a_2	cp3a_response_2	cp4_2	cp4_response_2	cp6_2	cp6_response_2	sp1_2	sp1_response_2	sp2_2	///
sp2a_2	sp2a_response_2	sp3_2	sp3_response_2	sp3a_2	sp4_2	sp4_response_2	sp5_2	sp5_response_2	n41_2	n42_2	n5_2	///
n5a_2	n5a_response_2	nn5aa_2	revised_n3b_2	revised_n5_2	n5b_2	n5bb_2	n5bb_response_2	n6_2	n6_other_2	n6aa_2	n6ab_2	///
n6ac_2	n6ba_2	n6ca_2	n6cb_2	n6cc_2	n7_2	n7_response_2	n6a_2	n6a_response_2	n6b_2	n6b_response_2	n6c_2	n6c_response_2	///
er2_2	er6_2	er9_2	er15_2	er15_response_2	er19_2	er19_response_2) /// 
(cc1_meas2 cc1_response_meas2 cc1a_meas2 cc1a_response_meas2 ncc3_meas2	ncc3_response_meas2 ncc3a_meas2	ncc3a_response_meas2 p1_meas2_1	p1_meas2_2 ///
p1_meas2_3 p1_other_meas2 p2a_meas2 p2b_meas2 p3_meas2	p4_meas2 p3a_meas2 p3a_response_meas2 p3e_meas2	p3e_response_meas2 cp1_meas2 cp1a_meas2 cp1a_response_meas2 ///
cp2_meas2 cp2_response_meas2 cp3_meas2	cp3a_meas2 cp3a_response_meas2 cp4_meas2 cp4_response_meas2 cp6_meas2 cp6_response_meas2 sp1_meas2 sp1_response_meas2 sp2_meas2	///
sp2a_meas2 sp2a_response_meas2 sp3_meas2 sp3_response_meas2 sp3a_meas2	sp4_meas2 sp4_response_meas2 sp5_meas2 sp5_response_meas2 n41_meas2 n42_meas2 n5_meas2 ///
n5a_meas2 n5a_response_meas2 nn5aa_meas2 revised_n3b_meas2 revised_n5_meas2 n5b_meas2 n5bb_meas2 n5bb_response_meas2 n6_meas2 n6_other_meas2 n6aa_meas2	n6ab_meas2 ///
n6ac_meas2 n6ba_meas2 n6ca_meas2 n6cb_meas2 n6cc_meas2 n7_meas2 n7_response_meas2 n6a_meas2 n6a_response_meas2 n6b_meas2 ///
n6b_response_meas2 n6c_meas2 n6c_response_meas2	er2_meas2 er6_meas2 er9_meas2 er15_meas2 er15_response_meas2 er19_meas2 er19_response_meas2)	

// Measure 3 loop
rename (aa3_3_01 aa3_3_02 aa3_3_03 aa3_3_04 aa3_3_05 aa3_3_06 aa3_3_07 aa3_3_08 aa3_3other obf1_3 n2_3 n3a_3 n3aa_3 n3aa_response_3 n3b_3 n3bb_3 n3bb_response_3) ///
(aa3_meas3_1 aa3_meas3_2 aa3_meas3_3 aa3_meas3_4 aa3_meas3_5 aa3_meas3_6 aa3_meas3_7 aa3_meas3_98 aa3_meas3other obf1_meas3 n2_meas3 n3a_meas3 n3aa_meas3 ///
n3aa_response_meas3 n3b_meas3 n3bb_meas3 n3bb_response_meas3)

rename (n3c_3 n3cc_3 n3cc_response_3 n3d_3 n3e_3 n3f_3 n3ff_3 n3ff_response_3 n3g_3 n3gg_3 n3gg_response_3 n3ggg_3 n3ggg_response_3 ///
n3h_3 n3hh_3 n3hh_response_3 n3hhh_3 n3hhh_response_3 n3i_3 n3j_3 n3k_3 n3kk1_3 n3kk1_response_3 n3kk2_3 n3kk2_response_3) ///
(n3c_meas3 n3cc_meas3 n3cc_response_meas3 n3d_meas3 n3e_meas3 n3f_meas3 n3ff_meas3 n3ff_response_meas3 n3g_meas3 n3gg_meas3 ///
n3gg_response_meas3 n3ggg_meas3 n3ggg_response_meas3 n3h_meas3 n3hh_meas3 n3hh_response_meas3 n3hhh_meas3 ///
n3hhh_response_meas3 n3i_meas3 n3j_meas3 n3k_meas3 n3kk1_meas3 n3kk1_response_meas3 n3kk2_meas3	n3kk2_response_meas3)

rename (fin0_3	fin1_a_3 fin1_b_3 fin1_c_3 fin7_3_01 fin7_3_02 fin7_3_03 fin7_3_04 fin7_3_05 fin7_other_3 fin8_3_01 fin8_3_02 fin8_3_03 fin8_other_3) ///
(fin0_meas3 fin1_a_meas3 fin1_b_meas3 fin1_c_meas3 fin7_meas3_1	fin7_meas3_2 fin7_meas3_3 fin7_meas3_4 fin7_meas3_5 fin7_other_meas3 fin8_meas3_1 ///
fin8_meas3_2 fin8_meas3_3 fin8_other_meas3)

rename (n3l_3	n3ll_3	n3ll_response_3	n3lll_3	n3lll_response_3 n3m_3 n3n_3 n3o_3 n3oo_3 n3oo_response_3 n3p_3	n3pp_3 ///
n3pp_response_3	n3q_3	n3r_3	n3rr_3	n3rr_response_3	n3rrr_3	n3rrr_response_3 n3s_3 n3t_3_01 n3t_3_02 n3t_other_1_3 ///
n3t_other_2_3 n3tt_1_3 n3tt_2_3	n3ttt_3	n3ttt_3_response) ///
(n3l_meas3 n3ll_meas3 n3ll_response_meas3 n3lll_meas3 n3lll_response_meas3 n3m_meas3 n3n_meas3 n3o_meas3 n3oo_meas3 n3oo_response_meas3 n3p_meas3 ///
n3pp_meas3 n3pp_response_meas3 n3q_meas3 n3r_meas3 n3rr_meas3 n3rr_response_meas3 n3rrr_meas3 n3rrr_response_meas3 n3s_meas3 n3t_meas3_1 n3t_meas3_2 ///
n3t_other_meas3_meas3 n3t_other_2_meas3 n3tt_1_meas3 n3tt_2_meas3 n3ttt_meas3 n3ttt_meas3_response)

rename (cc1_3 cc1_response_3 cc1a_3 cc1a_response_3 ncc3_3 ncc3_response_3 ncc3a_3 ncc3a_response_3 p1_3_01 p1_3_02 p1_3_03 p1_other_3 p2a_3 p2b_3 ///
p3_3 p4_3 p3a_3	p3a_response_3 p3e_3 p3e_response_3 cp1_3 cp1a_3 cp1a_response_3 cp2_3 cp2_response_3 cp3_3 cp3a_3 cp3a_response_3 cp4_3 ///
cp4_response_3 cp6_3 cp6_response_3 sp1_3 sp1_response_3 sp2_3	sp2a_3	sp2a_response_3	sp3_3 sp3_response_3 sp3a_3 sp4_3 sp4_response_3 sp5_3 ///
sp5_response_3 n41_3 n42_3 n5_3	n5a_3 n5a_response_3 nn5aa_3 revised_n3b_3 revised_n5_3 n5b_3 n5bb_3 n5bb_response_3 n6_3 ///
n6_other_3 n6aa_3 n6ab_3 n6ac_3	n6ba_3 n6ca_3 n6cb_3 n6cc_3 n7_3 n7_response_3 n6a_3 n6a_response_3 n6b_3 n6b_response_3 n6c_3 ///
n6c_response_3 er2_3 er6_3 er9_3 er15_3	er15_response_3	er19_3	er19_response_3) ///
(cc1_meas3 cc1_response_meas3 cc1a_meas3 cc1a_response_meas3 ncc3_meas3	ncc3_response_meas3 ncc3a_meas3	ncc3a_response_meas3 p1_meas3_1	p1_meas3_2 ///
p1_meas3_3 p1_other_meas3 p2a_meas3 p2b_meas3 p3_meas3	p4_meas3 p3a_meas3 p3a_response_meas3 p3e_meas3	p3e_response_meas3 cp1_meas3 cp1a_meas3 cp1a_response_meas3 ///
cp2_meas3 cp2_response_meas3 cp3_meas3	cp3a_meas3 cp3a_response_meas3 cp4_meas3 cp4_response_meas3 cp6_meas3 cp6_response_meas3 sp1_meas3 sp1_response_meas3 sp2_meas3	///
sp2a_meas3 sp2a_response_meas3 sp3_meas3 sp3_response_meas3 sp3a_meas3	sp4_meas3 sp4_response_meas3 sp5_meas3 sp5_response_meas3 n41_meas3 n42_meas3 n5_meas3 ///
n5a_meas3 n5a_response_meas3 nn5aa_meas3 revised_n3b_meas3 revised_n5_meas3 n5b_meas3 n5bb_meas3 n5bb_response_meas3 n6_meas3 n6_other_meas3 n6aa_meas3	n6ab_meas3 ///
n6ac_meas3 n6ba_meas3 n6ca_meas3 n6cb_meas3 n6cc_meas3 n7_meas3 n7_response_meas3 n6a_meas3 n6a_response_meas3 n6b_meas3 ///
n6b_response_meas3 n6c_meas3 n6c_response_meas3	er2_meas3 er6_meas3 er9_meas3 er15_meas3 er15_response_meas3 er19_meas3 er19_response_meas3)	


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

order (n3a_meas1	n3b_meas1	n3c_meas1	n3d_meas1	n3e_meas1	n3f_meas1	n3g_meas1	n3h_meas1	n3i_meas1	n3j_meas1	///
n3k_meas1	n3l_meas1	n3m_meas1	n3n_meas1	n3o_meas1	n3p_meas1	n3q_meas1	n3r_meas1	n3s_meas1	n3tt_1_meas1	///
n2_meas1	n41_meas1	n5_meas1	n6_meas1	n6a_meas1	n3a_meas2	n3b_meas2	n3c_meas2	n3d_meas2	n3e_meas2	///
n3f_meas2	n3g_meas2	n3h_meas2	n3i_meas2	n3j_meas2	n3k_meas2	n3l_meas2	n3m_meas2	n3n_meas2	n3o_meas2	///
n3p_meas2	n3q_meas2	n3r_meas2	n3s_meas2	n3tt_1_meas2	n2_meas2	n41_meas2	n5_meas2	n6_meas2	n6a_meas2	///
n3a_meas3	n3b_meas3	n3c_meas3	n3d_meas3	n3e_meas3	n3f_meas3	n3g_meas3	n3h_meas3	n3i_meas3	n3j_meas3	///
n3k_meas3	n3l_meas3	n3m_meas3	n3n_meas3	n3o_meas3	n3p_meas3	n3q_meas3	n3r_meas3	n3s_meas3	n3tt_1_meas3	///
n2_meas3 n41_meas3	n5_meas3	n6_meas3	n6a_meas3	v2_meas1	v3_meas1	v4_meas1	v5_meas1	v6aa_meas1	v6bb_meas1	///
v7a_meas1	v7b_meas1	v7c_meas1	v2_meas2	v3_meas2	v4_meas2	v5_meas2	v6aa_meas2	v6bb_meas2	v7a_meas2	v7b_meas2	///
v7c_meas2	v2_meas3	v3_meas3	v4_meas3	v5_meas3	v6aa_meas3	v6bb_meas3	v7a_meas3	v7b_meas3	v7c_meas3), first

		order sampleid, before(case_id)
		order sbw_projid, before(case_id)
		order ClaimId1, before(aa3_meas1_1)
		order ClaimId2, before(aa3_meas2_1)
		order ClaimId3, before(aa3_meas3_1)

		
//this is a loop to ensure that open-ends are not truncated
	foreach var of varlist _all {
		capture confirm string variable `var'
		if !_rc {
			recast str255 `var'
		}
	}

autoformat

foreach var of varlist n3a_meas1	n3b_meas1	n3c_meas1	n3d_meas1	n3e_meas1	n3f_meas1	n3g_meas1	n3h_meas1	n3i_meas1	n3j_meas1	///
	n3k_meas1	n3l_meas1	n3m_meas1	n3n_meas1	n3o_meas1	n3p_meas1	n3q_meas1	n3r_meas1	n3s_meas1	n3tt_1_meas1	///
	n2_meas1	n41_meas1	n5_meas1	n6_meas1	n6a_meas1	n3a_meas2	n3b_meas2	n3c_meas2	n3d_meas2	n3e_meas2	///
	n3f_meas2	n3g_meas2	n3h_meas2	n3i_meas2	n3j_meas2	n3k_meas2	n3l_meas2	n3m_meas2	n3n_meas2	n3o_meas2	///
	n3p_meas2	n3q_meas2	n3r_meas2	n3s_meas2	n3tt_1_meas2	n2_meas2	n41_meas2	n5_meas2	n6_meas2	n6a_meas2	///
	n3a_meas3	n3b_meas3	n3c_meas3	n3d_meas3	n3e_meas3	n3f_meas3	n3g_meas3	n3h_meas3	n3i_meas3	n3j_meas3	///
	n3k_meas3	n3l_meas3	n3m_meas3	n3n_meas3	n3o_meas3	n3p_meas3	n3q_meas3	n3r_meas3	n3s_meas3	n3tt_1_meas3	///
	n2_meas3 n41_meas3	n5_meas3	n6_meas3	n6a_meas3	v2_meas1	v3_meas1	v4_meas1	v5_meas1	v6aa_meas1	v6bb_meas1	///
	v7a_meas1	v7b_meas1	v7c_meas1	v2_meas2	v3_meas2	v4_meas2	v5_meas2	v6aa_meas2	v6bb_meas2	v7a_meas2	v7b_meas2	///
	v7c_meas2	v2_meas3	v3_meas3	v4_meas3	v5_meas3	v6aa_meas3	v6bb_meas3	v7a_meas3	v7b_meas3	v7c_meas3 {
	destring `var', replace
	}


foreach var of varlist n3a_meas1	n3b_meas1	n3c_meas1	n3d_meas1	n3e_meas1	n3f_meas1	n3g_meas1	n3h_meas1	n3i_meas1	n3j_meas1	///
	n3k_meas1	n3l_meas1	n3m_meas1	n3n_meas1	n3o_meas1	n3p_meas1	n3q_meas1	n3r_meas1	n3s_meas1	n3tt_1_meas1	///
	n2_meas1	n41_meas1	n5_meas1	n6_meas1	n6a_meas1	n3a_meas2	n3b_meas2	n3c_meas2	n3d_meas2	n3e_meas2	///
	n3f_meas2	n3g_meas2	n3h_meas2	n3i_meas2	n3j_meas2	n3k_meas2	n3l_meas2	n3m_meas2	n3n_meas2	n3o_meas2	///
	n3p_meas2	n3q_meas2	n3r_meas2	n3s_meas2	n3tt_1_meas2	n2_meas2	n41_meas2	n5_meas2	n6_meas2	n6a_meas2	///
	n3a_meas3	n3b_meas3	n3c_meas3	n3d_meas3	n3e_meas3	n3f_meas3	n3g_meas3	n3h_meas3	n3i_meas3	n3j_meas3	///
	n3k_meas3	n3l_meas3	n3m_meas3	n3n_meas3	n3o_meas3	n3p_meas3	n3q_meas3	n3r_meas3	n3s_meas3	n3tt_1_meas3	///
	n2_meas3 n41_meas3	n5_meas3	n6_meas3	n6a_meas3	v2_meas1	v3_meas1	v4_meas1	v5_meas1	v6aa_meas1	v6bb_meas1	///
	v7a_meas1	v7b_meas1	v7c_meas1	v2_meas2	v3_meas2	v4_meas2	v5_meas2	v6aa_meas2	v6bb_meas2	v7a_meas2	v7b_meas2	///
	v7c_meas2	v2_meas3	v3_meas3	v4_meas3	v5_meas3	v6aa_meas3	v6bb_meas3	v7a_meas3	v7b_meas3	v7c_meas3 {
	replace `var' = . if `var' == 99 |`var' == 98 |`var' == 96
	}
	
// Clean n6a_meas1 n6a_meas2 and n6a_meas3
replace n6a_meas1 = 0.25 if n6a_response_meas1 == "half"

// drop repeated rigor mistake
drop if sbw_projid=="PRJ - 00929837"
	
	
		mvdecode _all, mv(99)
		mvdecode _all, mv(98)
		mvdecode _all, mv(96)
		mvdecode _all, mv(97)

_strip_labels _all
	tostring _all, replace
	foreach var of varlist * {
			replace `var' = "" if  `var' == "-99"|`var' == "-98"|`var' == "-96"|`var' == "99"|`var' == "98"|`var' == "96"|`var' == "NA"|`var' == "N/A"
		}		
	replace a1b ="1" if multimeas=="2" & (a1b ==""|a1b ==" ")
	
// Save
save "$work/ciac_PMR_completes_cleaned_2_21_2020.dta", replace


export excel using "$raw\CIAC 2018 Basic and Standard Completes.xlsx", sheet("CIAC 2018 Basic and Standard") firstrow(variables) sheetreplace

//export variables and variable labels
describe, replace clear
drop type isnumeric format vallab
export excel using "$raw\CIAC 2018 Basic and Standard Completes.xlsx", sheet("Variable Dictionary") firstrow(variables) sheetreplace
	