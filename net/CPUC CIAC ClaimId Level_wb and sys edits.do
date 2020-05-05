/***************************************
Created By: Adriana Kraig
Creation Date: 2019-10-08

Last Modified By: Adriana Kraig
Modified Date: 2019-11-22

This is code to prepare the sample for CIAC 2018 net surveys

THIS THE THE STEP INVOLVING RESHAING AND PREPARING THE SAMPLE
*********************************************************************************/

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
global claims "$work\ClaimId Level"
exit


*********************************************************************************/

*******************
// Make info data to match to
*******************
use "$work/ciac_all_completes.dta", clear
	keep completed sampleid sbw_projid contact business sector rigor multimeas multiaddr ///
	sbd ciac_nsbd wb sys dt 
save "$work/CIAC claimid info.dta", replace

*******************
// Duplication checks for multimeas>1 in non-sbd
*******************
use "$work/ciac_all_completes.dta", clear
	keep if ciac_nsbd ==1
	
	tostring _all, replace
	destring a1b multimeas, replace
	
		// start with aa3
		replace aa3_meas2_1= aa3_meas1_1 if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_2= aa3_meas1_2 if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_3= aa3_meas1_3  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_4= aa3_meas1_4  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_5= aa3_meas1_5  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_6= aa3_meas1_6  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_7= aa3_meas1_7  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2_98= aa3_meas1_98  if  multimeas >1 & meas2!="" & a1b ==1
		replace aa3_meas2other= aa3_meas1other if  multimeas >1 & meas2!="" & a1b ==1
		
		replace aa3_meas3_1= aa3_meas1_1 if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_2= aa3_meas1_2 if  multimeas >1 & meas3!=""  & a1b ==1
		replace aa3_meas3_3= aa3_meas1_3  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_4= aa3_meas1_4  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_5= aa3_meas1_5  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_6= aa3_meas1_6  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_7= aa3_meas1_7  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3_98= aa3_meas1_98  if  multimeas >1 & meas3!="" & a1b ==1
		replace aa3_meas3other= aa3_meas1other if  multimeas >1 & meas3!="" & a1b ==1
		
		// next obf1
		replace obf1_meas2=obf1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace obf1_meas3=obf1_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		// n2
		replace n2_meas2=n2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n2_meas3=n2_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		// n3 Qs
		replace n3a_meas2=n3a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3a_meas3=n3a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3aa_meas2=n3aa_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3aa_meas3=n3aa_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3aa_response_meas2=n3aa_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3aa_response_meas3=n3aa_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3b_meas2=n3b_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3b_meas3=n3b_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3bb_meas2=n3bb_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3bb_meas3=n3bb_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3bb_response_meas2=n3bb_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3bb_response_meas3=n3bb_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n3c_meas2=n3c_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3c_meas3=n3c_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3cc_meas2=n3cc_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3cc_meas3=n3cc_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3cc_response_meas2=n3cc_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3cc_response_meas3=n3cc_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace n3d_meas2=n3d_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3d_meas3=n3d_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3dd_2=n3dd if  multimeas >1 & meas2!="" & a1b ==1
		replace n3dd_3=n3dd if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3dd_2_0_text=n3dd_0_text if  multimeas >1 & meas2!="" & a1b ==1
		replace n3dd_3_0_text=n3dd_0_text if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3e_meas2=n3e_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3e_meas3=n3e_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n3f_meas2=n3f_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3f_meas3=n3f_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3ff_meas2=n3ff_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ff_meas3=n3ff_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3ff_response_meas2=n3ff_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ff_response_meas3=n3ff_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n3g_meas2=n3g_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3g_meas3=n3g_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n3gg_meas2=n3gg_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3gg_meas3=n3gg_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3gg_response_meas2=n3gg_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3gg_response_meas3=n3gg_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3ggg_meas2=n3ggg_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ggg_meas3=n3ggg_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3ggg_response_meas2=n3ggg_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ggg_response_meas3=n3ggg_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3h_meas2=n3h_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3h_meas3=n3h_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3hh_meas2=n3hh_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3hh_meas3=n3hh_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3hh_response_meas2=n3hh_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3hh_response_meas3=n3hh_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3hhh_meas2=n3hhh_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3hhh_meas3=n3hhh_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3hhh_response_meas2=n3hhh_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3hhh_response_meas3=n3hhh_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n3i_meas2=n3i_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3i_meas3=n3i_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3j_meas2=n3j_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3j_meas3=n3j_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3k_meas2=n3k_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3k_meas3=n3k_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3kk1_meas2=n3kk1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3kk1_meas3=n3kk1_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3kk1_response_meas2=n3kk1_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3kk1_response_meas3=n3kk1_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3kk2_meas2=n3kk2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3kk2_meas3=n3kk2_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3kk2_response_meas2=n3kk2_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3kk2_response_meas3=n3kk2_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
	
		replace n3l_meas2=n3l_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3l_meas3=n3l_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3ll_meas2=n3ll_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ll_meas3=n3ll_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3ll_response_meas2=n3ll_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ll_response_meas3=n3ll_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3lll_meas2=n3lll_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3lll_meas3=n3lll_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3lll_response_meas2=n3lll_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3lll_response_meas3=n3lll_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
				
		replace n3m_meas2=n3m_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3m_meas3=n3m_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3n_meas2=n3n_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3n_meas3=n3n_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3o_meas2=n3o_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3o_meas3=n3o_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3oo_meas2=n3oo_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3oo_meas3=n3oo_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3oo_response_meas2=n3oo_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3oo_response_meas3=n3oo_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace n3p_meas2=n3p_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3p_meas3=n3p_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3pp_meas2=n3pp_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3pp_meas3=n3pp_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3pp_response_meas2=n3pp_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3pp_response_meas3=n3pp_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3q_meas2=n3q_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3q_meas3=n3q_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
				
		replace n3r_meas2=n3r_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3r_meas3=n3r_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3rr_meas2=n3rr_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3rr_meas3=n3rr_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3rr_response_meas2=n3rr_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3rr_response_meas3=n3rr_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3rrr_meas2=n3rrr_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3rrr_meas3=n3rrr_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3rrr_response_meas2=n3rrr_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3rrr_response_meas3=n3rrr_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n3s_meas2=n3s_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3s_meas3=n3s_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
						
		replace n3t_meas2_1=n3t_meas1_1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3t_meas3_1=n3t_meas1_1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3t_meas2_2=n3t_meas1_2 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3t_meas3_2=n3t_meas1_2 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3t_other_2_meas2=n3t_other_2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3t_other_2_meas3=n3t_other_2_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
				
		replace n3t_other_meas2_meas2=n3t_other_meas1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3t_other_meas3_meas3=n3t_other_meas1_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3tt_1_meas2=n3tt_1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3tt_1_meas3=n3tt_1_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace n3tt_2_meas2=n3tt_2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3tt_2_meas3=n3tt_2_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n3ttt_meas2=n3ttt_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ttt_meas3=n3ttt_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n3ttt_meas2_response=n3ttt_meas1_response if  multimeas >1 & meas2!="" & a1b ==1
		replace n3ttt_meas3_response=n3ttt_meas1_response if  multimeas >1 & meas3!="" & a1b ==1		

		// Consitency checks
		replace cc1_meas2=cc1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cc1_meas3=cc1_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace cc1_response_meas2=cc1_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cc1_response_meas3=cc1_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace cc1a_meas2=cc1a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cc1a_meas3=cc1a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cc1a_response_meas2=cc1a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cc1a_response_meas3=cc1a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			

		replace ncc3_meas2=ncc3_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace ncc3_meas3=ncc3_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace ncc3_response_meas2=ncc3_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace ncc3_response_meas3=ncc3_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace ncc3a_meas2=ncc3a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace ncc3a_meas3=ncc3a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace ncc3a_response_meas2=ncc3a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace ncc3a_response_meas3=ncc3a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
	
		// Payback battery
		replace p1_meas2_1=p1_meas1_1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p1_meas3_1=p1_meas1_1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace p1_meas2_2=p1_meas1_2 if  multimeas >1 & meas2!="" & a1b ==1
		replace p1_meas3_2=p1_meas1_2 if  multimeas >1 & meas3!="" & a1b ==1		

		replace p1_meas2_3=p1_meas1_3 if  multimeas >1 & meas2!="" & a1b ==1
		replace p1_meas3_3=p1_meas1_3 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace p1_other_meas2=p1_other_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p1_other_meas3=p1_other_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace p2a_meas2=p2a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p2a_meas3=p2a_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace p2b_meas2=p2b_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p2b_meas3=p2b_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace p3_meas2=p3_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p3_meas3=p3_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace p4_meas2=p4_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p4_meas3=p4_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
	
		// Consistency checks
		replace p3a_meas2=p3a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p3a_meas3=p3a_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace p3a_response_meas2=p3a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p3a_response_meas3=p3a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace p3e_meas2=p3e_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p3e_meas3=p3e_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace p3e_response_meas2=p3e_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace p3e_response_meas3=p3e_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
	
		// Corporate policy battery 
		replace cp1_meas2=cp1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp1_meas3=cp1_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace cp1a_meas2=cp1a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp1a_meas3=cp1a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cp1a_response_meas2=cp1a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp1a_response_meas3=cp1a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			

		replace cp2_meas2=cp2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp2_meas3=cp2_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace cp2_response_meas2=cp2_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp2_response_meas3=cp2_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cp3_meas2=cp3_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp3_meas3=cp3_meas1 if  multimeas >1 & meas3!="" & a1b ==1

		replace cp3a_meas2=cp3a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp3a_meas3=cp3a_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace cp3a_response_meas2=cp3a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp3a_response_meas3=cp3a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cp4_meas2=cp4_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp4_meas3=cp4_meas1 if  multimeas >1 & meas3!="" & a1b ==1

		replace cp4_response_meas2=cp4_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp4_response_meas3=cp4_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cp6_meas2=cp6_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp6_meas3=cp6_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace cp6_response_meas2=cp6_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace cp6_response_meas3=cp6_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		// Standard Practice battery 
		replace sp1_meas2=sp1_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp1_meas3=sp1_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp1_response_meas2=sp1_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp1_response_meas3=sp1_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1

		replace sp2_meas2=sp2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp2_meas3=sp2_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp2a_meas2=sp2a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp2a_meas3=sp2a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp2a_response_meas2=sp2a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp2a_response_meas3=sp2a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1				
		
		replace sp3_meas2=sp3_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp3_meas3=sp3_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp3_response_meas2=sp3_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp3_response_meas3=sp3_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1

		replace sp3a_meas2=sp3a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp3a_meas3=sp3a_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp4_meas2=sp4_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp4_meas3=sp4_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp4_response_meas2=sp4_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp4_response_meas3=sp4_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace sp5_meas2=sp5_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp5_meas3=sp5_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace sp5_response_meas2=sp5_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace sp5_response_meas3=sp5_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n41_meas2=n41_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n41_meas3=n41_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n42_meas2=n42_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n42_meas3=n42_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n5_meas2=n5_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5_meas3=n5_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		replace n5_meas2_orig=n5_meas1_orig if  multimeas >1 & meas2!="" & a1b ==1
		replace n5_meas3_orig=n5_meas1_orig if  multimeas >1 & meas3!="" & a1b ==1	
		
		// Consistency checks
		replace n5a_meas2=n5a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5a_meas3=n5a_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace n5a_response_meas2=n5a_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5a_response_meas3=n5a_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace nn5aa_meas2=nn5aa_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace nn5aa_meas3=nn5aa_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n5b_meas2=n5b_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5b_meas3=n5b_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n5bb_meas2=n5bb_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5bb_meas3=n5bb_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n5bb_response_meas2=n5bb_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n5bb_response_meas3=n5bb_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n6_meas2=n6_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6_meas3=n6_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n6_other_meas2=n6_other_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6_other_meas3=n6_other_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace n6aa_meas2=n6aa_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6aa_meas3=n6aa_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n6ab_meas2=n6ab_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6ab_meas3=n6ab_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n6ac_meas2=n6ac_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6ac_meas3=n6ac_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n6ba_meas2=n6ba_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6ba_meas3=n6ba_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n6ca_meas2=n6ca_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6ca_meas3=n6ca_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n6cb_meas2=n6cb_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6cb_meas3=n6cb_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n6cc_meas2=n6cc_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6cc_meas3=n6cc_meas1 if  multimeas >1 & meas3!="" & a1b ==1		

		// Consistency checks
		replace n7_meas2=n7_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n7_meas3=n7_meas1 if  multimeas >1 & meas3!="" & a1b ==1
		
		replace n7_response_meas2=n7_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n7_response_meas3=n7_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n6a_meas2=n6a_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6a_meas3=n6a_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace n6b_meas2=n6b_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6b_meas3=n6b_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace n6c_meas2=n6c_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace n6c_meas3=n6c_meas1 if  multimeas >1 & meas3!="" & a1b ==1	

		// Early replacement battery 
		replace er2_meas2=er2_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er2_meas3=er2_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace er6_meas2=er6_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er6_meas3=er6_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace er9_meas2=er9_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er9_meas3=er9_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
		
		replace er15_meas2=er15_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er15_meas3=er15_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace er15_response_meas2=er15_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er15_response_meas3=er15_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1	
		
		replace er19_meas2=er19_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er19_meas3=er19_meas1 if  multimeas >1 & meas3!="" & a1b ==1		
		
		replace er19_response_meas2=er19_response_meas1 if  multimeas >1 & meas2!="" & a1b ==1
		replace er19_response_meas3=er19_response_meas1 if  multimeas >1 & meas3!="" & a1b ==1			
	

*******************
// Generate the files to de-dup the claims
*******************
	preserve
		drop ClaimId1 ClaimId2 ClaimId3 meas1 meas_1_date meas2 meas_2_date meas3 meas_3_date ///
		aa3_meas* obf1_meas* n2_meas* n3a_meas* n3aa_meas* n3aa_response_meas* n3b_meas* n3bb_meas* n3bb_response_meas* ///
		n3c_meas* n3cc_meas* n3cc_response_meas* n3d_meas* n3dd_2 n3dd n3dd_3 n3dd_* n3e_meas* n3f_meas* n3ff_meas* n3ff_response_meas* ///
		n3g_meas* n3gg_meas* n3gg_response_meas* n3ggg_meas* n3ggg_response_meas* n3h_meas*	n3hh_meas* n3hh_response_meas*  n3hhh_meas* ///
		n3hhh_response_meas* n3i_meas* n3j_meas* n3k_meas* n3kk1_meas* n3kk1_response_meas* n3kk2_meas* n3kk2_response_meas* n3l_meas* ///
		n3ll_meas* n3ll_response_meas* n3lll_meas* n3lll_response_meas*	n3m_meas* n3n_meas* n3o_meas* n3oo_meas* n3oo_response_meas* ///
		n3p_meas* n3pp_meas* n3pp_response_meas* n3q_meas* n3r_meas* n3rr_meas*	n3o_meas* n3rrr_meas* n3rrr_response_meas* n3s_meas* ///	
		n3t_meas* n3t_meas* n3t_other_2_meas* n3t_other_meas* n3tt_1_meas* n3tt_2_meas* n3ttt_meas* n3ttt_meas* cc1_meas* cc1_response_meas*	///	
		cc1a_meas* cc1a_response_meas* ncc3_meas* ncc3_response_meas* ncc3a_meas* ncc3a_response_meas* p1_meas* p1_other_meas* p2a_meas* p2b_meas*	///	
		p3_meas* p4_meas* p3a_meas* p3a_response_meas* p3e_meas* p3e_response_meas* cp1_meas* cp1a_meas* cp1a_response_meas* cp2_meas*  cp2_response_meas* ///
		cp3_meas* cp3a_meas* cp3a_response_meas* cp4_meas* cp4_response_meas* cp6_meas* cp6_response_meas* sp1_meas* sp1_response_meas* sp2_meas* ///
		sp2a_meas* sp2a_response_meas* sp3_meas* sp3_response_meas* sp3a_meas* sp4_meas* sp4_response_meas* sp5_meas* sp5_response_meas* n41_meas* /// 
		n42_meas* n5_meas* n5a_meas*  n5a_response_meas* nn5aa_meas* n5b_meas* n5bb_meas* n5bb_response_meas* n6_meas*  n6_other_meas* n6aa_meas* n6ab_meas* ///
		n6ac_meas* n6ba_meas* n6ca_meas* n6cb_meas* n6cc_meas*	 n7_meas* n7_response_meas* n6a_meas*  n6b_meas* n6c_meas* er2_meas* er6_meas* er9_meas* ///
		er15_meas* er15_response_meas* er19_meas* er19_response_meas*	
		
		keep sampleid intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 intro4_openend v1 v1a_01 v1a_02 v1a_03 v2 ///
		v2_other v2a v2aa v2b v3 v4 v4a v4b v40 v2_meas1 v3_meas1 v4_meas1 v5_meas1 v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 v14_meas1 v15_meas1 v16_meas1 v16a_meas1 ///
		ap9 ap9_other ap9a_01 ap9a_02 ap9a_03 ap9a_04 ap9a_05 ap9a_06 ap9a_07 ap9a_08 ap9a_09 ap9a_10 ///
		ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_other n33 n33name n33a_01 n33a_02 n33aemail n33aphone c4 c4_response c5 c5_response c6 a1a ///
		a1a_response a2a a2a_response a2b_01 a2b_02 a2b_03 a2b_other a2bb_01 a2bb_02 a2bb_03 a2bbname a2bbemail a3 a4 a4_response a4a ///
		a4a_response a1b a1c pp1 pp1_response pp2 pp2_response pp4 pp5 pp5_response lt2 lt3 ca6_01 ca6_02 ca6_03 ca6_04 ca6_05 ca6_06 ///
		ca6_07 ca6_08 ca6_09 ca6__99 ca6_other lt6 lt6_response lt7 lt7_response lt8 cc12a cc12b co ccc1 ccc3 c1 c1_response c2 c3 c3a
		order intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 intro4_openend v1 v1a_01 v1a_02 v1a_03 v2 ///
		v2_other v2a v2aa v2b v3 v4 v4a v4b v40 ap9 ap9_other ap9a_01 ap9a_02 ap9a_03 ap9a_04 ap9a_05 ap9a_06 ap9a_07 ap9a_08 ap9a_09 ap9a_10 ///
		ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_other n33 n33name n33a_01 n33a_02 n33aemail n33aphone c4 c4_response c5 c5_response c6 a1a ///
		a1a_response a2a a2a_response a2b_01 a2b_02 a2b_03 a2b_other a2bb_01 a2bb_02 a2bb_03 a2bbname a2bbemail a3 a4 a4_response a4a ///
		a4a_response a1b a1c pp1 pp1_response pp2 pp2_response pp4 pp5 pp5_response lt2 lt3 ca6_01 ca6_02 ca6_03 ca6_04 ca6_05 ca6_06 ///
		ca6_07 ca6_08 ca6_09 ca6__99 ca6_other lt6 lt6_response lt7 lt7_response lt8 cc12a cc12b co ccc1 ccc3 c1 c1_response c2 c3 c3a
		
		order sampleid intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 intro4_openend v1 v1a_01 v1a_02 v1a_03 v2 ///
		v2_other v2a v2aa v2b v3 v4 v4a v4b v40 v2_meas1 v3_meas1 v4_meas1 v5_meas1 v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 v14_meas1 v15_meas1 v16_meas1 v16a_meas1 ///
		ap9 ap9_other ap9a_01 ap9a_02 ap9a_03 ap9a_04 ap9a_05 ap9a_06 ap9a_07 ap9a_08 ap9a_09 ap9a_10 ///
		ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_other n33 n33name n33a_01 n33a_02 n33aemail n33aphone c4 c4_response c5 c5_response c6 a1a ///
		a1a_response a2a a2a_response a2b_01 a2b_02 a2b_03 a2b_other a2bb_01 a2bb_02 a2bb_03 a2bbname a2bbemail a3 a4 a4_response a4a ///
		a4a_response a1b a1c pp1 pp1_response pp2 pp2_response pp4 pp5 pp5_response lt2 lt3 ca6_01 ca6_02 ca6_03 ca6_04 ca6_05 ca6_06 ///
		ca6_07 ca6_08 ca6_09 ca6__99 ca6_other lt6 lt6_response lt7 lt7_response lt8 cc12a cc12b co ccc1 ccc3 c1 c1_response c2 c3 c3a
		order intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 intro4_openend v1 v1a_01 v1a_02 v1a_03 v2 ///
		v2_other v2a v2aa v2b v3 v4 v4a v4b v40 ap9 ap9_other ap9a_01 ap9a_02 ap9a_03 ap9a_04 ap9a_05 ap9a_06 ap9a_07 ap9a_08 ap9a_09 ap9a_10 ///
		ap9a_11 ap9a_12 ap9a_13 ap9a_14 ap9a_15 ap9a_other n33 n33name n33a_01 n33a_02 n33aemail n33aphone c4 c4_response c5 c5_response c6 a1a ///
		a1a_response a2a a2a_response a2b_01 a2b_02 a2b_03 a2b_other a2bb_01 a2bb_02 a2bb_03 a2bbname a2bbemail a3 a4 a4_response a4a ///
		a4a_response a1b a1c pp1 pp1_response pp2 pp2_response pp4 pp5 pp5_response lt2 lt3 ca6_01 ca6_02 ca6_03 ca6_04 ca6_05 ca6_06 ///
		ca6_07 ca6_08 ca6_09 ca6__99 ca6_other lt6 lt6_response lt7 lt7_response lt8 cc12a cc12b co ccc1 ccc3 c1 c1_response c2 c3 c3a
		
		replace v2=v2_meas1 if v2_meas1!=""
		replace v3=v3_meas1 if v3_meas1!=""
		replace v4=v4_meas1 if v4_meas1!=""
		rename (v5_meas1 v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 v14_meas1 v15_meas1 v16_meas1 v16a_meas1) ///
		(v5 v6a v6aa v6bb v7a v7b v7c v8 v9 v9a v10 v11 v12 v13 v13a v14 v15 v16 v16a)
		drop v2_meas1 v3_meas1 v4_meas1
		save "$claims/CIAC nonenhanced claimid non_dup_questions.dta", replace
	restore
		
		rename (ClaimId1 ClaimId2 ClaimId3) (ClaimId_meas1 ClaimId_meas2 ClaimId_meas3)
		rename (n3dd n3dd_2 n3dd_3 n3dd_0_text n3dd_2_0_text n3dd_3_0_text) (n3dd_meas1 n3dd_meas2 n3dd_meas3 n3dd_response_meas1 n3dd_response_meas2 n3dd_response_meas3)
		
		preserve
			keep sampleid ClaimId_meas1 meas1 meas_1_date  ///
			aa3_meas1_1 aa3_meas1_2 aa3_meas1_3 aa3_meas1_4 aa3_meas1_5 aa3_meas1_6 aa3_meas1_7 aa3_meas1_98 aa3_meas1other ///
			obf1_meas1 n2_meas1 n3a_meas1 n3aa_meas1 n3aa_response_meas1 n3b_meas1 n3bb_meas1 n3bb_response_meas1 ///
			n3c_meas1 n3cc_meas1 n3cc_response_meas1 n3d_meas1 n3dd_meas1 n3dd_response_meas1 n3e_meas1 n3f_meas1 n3ff_meas1 n3ff_response_meas1 ///
			n3g_meas1 n3gg_meas1 n3gg_response_meas1 n3ggg_meas1 n3ggg_response_meas1 n3h_meas1	n3hh_meas1 n3hh_response_meas1  n3hhh_meas1 ///
			n3hhh_response_meas1 n3i_meas1 n3j_meas1 n3k_meas1 n3kk1_meas1 n3kk1_response_meas1 n3kk2_meas1 n3kk2_response_meas1 n3l_meas1 ///
			n3ll_meas1 n3ll_response_meas1 n3lll_meas1 n3lll_response_meas1	n3m_meas1 n3n_meas1 n3o_meas1 n3oo_meas1 n3oo_response_meas1 ///
			n3p_meas1 n3pp_meas1 n3pp_response_meas1 n3q_meas1 n3r_meas1 n3rr_meas1 n3rrr_meas1 n3rrr_response_meas1 n3s_meas1 ///	
			n3t_meas1_1 n3t_meas1_2 n3t_other_2_meas1 n3t_other_meas1 n3tt_1_meas1 n3tt_2_meas1 n3ttt_meas1 n3ttt_meas1_response cc1_meas1 cc1_response_meas1	///	
			cc1a_meas1 cc1a_response_meas1 ncc3_meas1 ncc3_response_meas1 ncc3a_meas1 ncc3a_response_meas1 p1_meas1_1 p1_meas1_2 p1_meas1_3 p1_other_meas1 p2a_meas1 p2b_meas1	///	
			p3_meas1 p4_meas1 p3a_meas1 p3a_response_meas1 p3e_meas1 p3e_response_meas1 cp1_meas1 cp1a_meas1 cp1a_response_meas1 cp2_meas1  cp2_response_meas1 ///
			cp3_meas1 cp3a_meas1 cp3a_response_meas1 cp4_meas1 cp4_response_meas1 cp6_meas1 cp6_response_meas1 sp1_meas1 sp1_response_meas1 sp2_meas1 ///
			sp2a_meas1 sp2a_response_meas1 sp3_meas1 sp3_response_meas1 sp3a_meas1 sp4_meas1 sp4_response_meas1 sp5_meas1 sp5_response_meas1 n41_meas1 /// 
			n42_meas1 n5_meas1_orig n5_meas1 n5a_meas1  n5a_response_meas1 nn5aa_meas1 n5b_meas1 n5bb_meas1 n5bb_response_meas1 n6_meas1  n6_other_meas1 n6aa_meas1 n6ab_meas1 ///
			n6ac_meas1 n6ba_meas1 n6ca_meas1 n6cb_meas1 n6cc_meas1	 n7_meas1 n7_response_meas1 n6a_meas1  n6b_meas1 n6c_meas1 er2_meas1 er6_meas1 er9_meas1 ///
			er15_meas1 er15_response_meas1 er19_meas1 er19_response_meas1

			rename (ClaimId_meas1 meas1 meas_1_date ///
			aa3_meas1_1 aa3_meas1_2 aa3_meas1_3 aa3_meas1_4 aa3_meas1_5 aa3_meas1_6 aa3_meas1_7 aa3_meas1_98 aa3_meas1other ///
			obf1_meas1 n2_meas1 n3a_meas1 n3aa_meas1 n3aa_response_meas1 n3b_meas1 n3bb_meas1 n3bb_response_meas1 ///
			n3c_meas1 n3cc_meas1 n3cc_response_meas1 n3d_meas1 n3dd_meas1 n3dd_response_meas1 n3e_meas1 n3f_meas1 n3ff_meas1 n3ff_response_meas1 ///
			n3g_meas1 n3gg_meas1 n3gg_response_meas1 n3ggg_meas1 n3ggg_response_meas1 n3h_meas1	n3hh_meas1 n3hh_response_meas1  n3hhh_meas1 ///
			n3hhh_response_meas1 n3i_meas1 n3j_meas1 n3k_meas1 n3kk1_meas1 n3kk1_response_meas1 n3kk2_meas1 n3kk2_response_meas1 n3l_meas1 ///
			n3ll_meas1 n3ll_response_meas1 n3lll_meas1 n3lll_response_meas1	n3m_meas1 n3n_meas1 n3o_meas1 n3oo_meas1 n3oo_response_meas1 ///
			n3p_meas1 n3pp_meas1 n3pp_response_meas1 n3q_meas1 n3r_meas1 n3rr_meas1 n3rrr_meas1 n3rrr_response_meas1 n3s_meas1 ///	
			n3t_meas1_1 n3t_meas1_2 n3t_other_2_meas1 n3t_other_meas1 n3tt_1_meas1 n3tt_2_meas1 n3ttt_meas1 n3ttt_meas1_response cc1_meas1 cc1_response_meas1	///	
			cc1a_meas1 cc1a_response_meas1 ncc3_meas1 ncc3_response_meas1 ncc3a_meas1 ncc3a_response_meas1 p1_meas1_1 p1_meas1_2 p1_meas1_3 p1_other_meas1 p2a_meas1 p2b_meas1	///	
			p3_meas1 p4_meas1 p3a_meas1 p3a_response_meas1 p3e_meas1 p3e_response_meas1 cp1_meas1 cp1a_meas1 cp1a_response_meas1 cp2_meas1  cp2_response_meas1 ///
			cp3_meas1 cp3a_meas1 cp3a_response_meas1 cp4_meas1 cp4_response_meas1 cp6_meas1 cp6_response_meas1 sp1_meas1 sp1_response_meas1 sp2_meas1 ///
			sp2a_meas1 sp2a_response_meas1 sp3_meas1 sp3_response_meas1 sp3a_meas1 sp4_meas1 sp4_response_meas1 sp5_meas1 sp5_response_meas1 n41_meas1 /// 
			n42_meas1 n5_meas1_orig n5_meas1 n5a_meas1  n5a_response_meas1 nn5aa_meas1 n5b_meas1 n5bb_meas1 n5bb_response_meas1 n6_meas1  n6_other_meas1 n6aa_meas1 n6ab_meas1 ///
			n6ac_meas1 n6ba_meas1 n6ca_meas1 n6cb_meas1 n6cc_meas1	 n7_meas1 n7_response_meas1 n6a_meas1  n6b_meas1 n6c_meas1 er2_meas1 er6_meas1 er9_meas1 ///
			er15_meas1 er15_response_meas1 er19_meas1 er19_response_meas1) ///
			(claimid meas meas_date ///
			aa3_1 aa3_2 aa3_3 aa3_4 aa3_5 aa3_6 aa3_7 aa3_98 aa3_other ///
			obf1 n2 n3a n3aa n3aa_response n3b n3bb n3bb_response ///
			n3c n3cc n3cc_response n3d n3dd n3dd_response n3e n3f n3ff n3ff_response ///
			n3g n3gg n3gg_response n3ggg n3ggg_response n3h	n3hh n3hh_response  n3hhh ///
			n3hhh_response n3i n3j n3k n3kk1 n3kk1_response n3kk2 n3kk2_response n3l ///
			n3ll n3ll_response n3lll n3lll_response	n3m n3n n3o n3oo n3oo_response ///
			n3p n3pp n3pp_response n3q n3r n3rr n3rrr n3rrr_response n3s ///	
			n3t_1 n3t_2 n3t_other_2 n3t_other n3tt_1 n3tt_2 n3ttt n3ttt_response cc1 cc1_response	///	
			cc1a cc1a_response ncc3 ncc3_response ncc3a ncc3a_response p1_1 p1_2 p1_3 p1_other p2a p2b	///	
			p3 p4 p3a p3a_response p3e p3e_response cp1 cp1a cp1a_response cp2  cp2_response ///
			cp3 cp3a cp3a_response cp4 cp4_response cp6 cp6_response sp1 sp1_response sp2 ///
			sp2a sp2a_response sp3 sp3_response sp3a sp4 sp4_response sp5 sp5_response n41 /// 
			n42 n5_orig n5 n5a  n5a_response nn5aa n5b n5bb n5bb_response n6  n6_other n6aa n6ab ///
			n6ac n6ba n6ca n6cb n6cc n7 n7_response n6a  n6b n6c er2 er6 er9 ///
			er15 er15_response er19 er19_response)

		save "$claims/CIAC nonenhanced claimid dup_questions_meas1.dta", replace
		restore
		
		preserve
			keep if meas2!=""
			keep sampleid ClaimId_meas2 meas2 meas_1_date  ///
			aa3_meas2_1 aa3_meas2_2 aa3_meas2_3 aa3_meas2_4 aa3_meas2_5 aa3_meas2_6 aa3_meas2_7 aa3_meas2_98 aa3_meas2other ///
			obf1_meas2 n2_meas2 n3a_meas2 n3aa_meas2 n3aa_response_meas2 n3b_meas2 n3bb_meas2 n3bb_response_meas2 ///
			n3c_meas2 n3cc_meas2 n3cc_response_meas2 n3d_meas2 n3dd_meas2 n3dd_response_meas2 n3e_meas2 n3f_meas2 n3ff_meas2 n3ff_response_meas2 ///
			n3g_meas2 n3gg_meas2 n3gg_response_meas2 n3ggg_meas2 n3ggg_response_meas2 n3h_meas2	n3hh_meas2 n3hh_response_meas2  n3hhh_meas2 ///
			n3hhh_response_meas2 n3i_meas2 n3j_meas2 n3k_meas2 n3kk1_meas2 n3kk1_response_meas2 n3kk2_meas2 n3kk2_response_meas2 n3l_meas2 ///
			n3ll_meas2 n3ll_response_meas2 n3lll_meas2 n3lll_response_meas2	n3m_meas2 n3n_meas2 n3o_meas2 n3oo_meas2 n3oo_response_meas2 ///
			n3p_meas2 n3pp_meas2 n3pp_response_meas2 n3q_meas2 n3r_meas2 n3rr_meas2 n3rrr_meas2 n3rrr_response_meas2 n3s_meas2 ///	
			n3t_meas2_1 n3t_meas2_2 n3t_other_2_meas2 n3t_other_meas2 n3tt_1_meas2 n3tt_2_meas2 n3ttt_meas2 n3ttt_meas2_response cc1_meas2 cc1_response_meas2	///	
			cc1a_meas2 cc1a_response_meas2 ncc3_meas2 ncc3_response_meas2 ncc3a_meas2 ncc3a_response_meas2 p1_meas2_1 p1_meas2_2 p1_meas2_3 p1_other_meas2 p2a_meas2 p2b_meas2	///	
			p3_meas2 p4_meas2 p3a_meas2 p3a_response_meas2 p3e_meas2 p3e_response_meas2 cp1_meas2 cp1a_meas2 cp1a_response_meas2 cp2_meas2  cp2_response_meas2 ///
			cp3_meas2 cp3a_meas2 cp3a_response_meas2 cp4_meas2 cp4_response_meas2 cp6_meas2 cp6_response_meas2 sp1_meas2 sp1_response_meas2 sp2_meas2 ///
			sp2a_meas2 sp2a_response_meas2 sp3_meas2 sp3_response_meas2 sp3a_meas2 sp4_meas2 sp4_response_meas2 sp5_meas2 sp5_response_meas2 n41_meas2 /// 
			n42_meas2 n5_meas2_orig n5_meas2 n5a_meas2  n5a_response_meas2 nn5aa_meas2 n5b_meas2 n5bb_meas2 n5bb_response_meas2 n6_meas2  n6_other_meas2 n6aa_meas2 n6ab_meas2 ///
			n6ac_meas2 n6ba_meas2 n6ca_meas2 n6cb_meas2 n6cc_meas2	 n7_meas2 n7_response_meas2 n6a_meas2  n6b_meas2 n6c_meas2 er2_meas2 er6_meas2 er9_meas2 ///
			er15_meas2 er15_response_meas2 er19_meas2 er19_response_meas2

			rename (ClaimId_meas2 meas2 meas_1_date  ///
			aa3_meas2_1 aa3_meas2_2 aa3_meas2_3 aa3_meas2_4 aa3_meas2_5 aa3_meas2_6 aa3_meas2_7 aa3_meas2_98 aa3_meas2other ///
			obf1_meas2 n2_meas2 n3a_meas2 n3aa_meas2 n3aa_response_meas2 n3b_meas2 n3bb_meas2 n3bb_response_meas2 ///
			n3c_meas2 n3cc_meas2 n3cc_response_meas2 n3d_meas2 n3dd_meas2 n3dd_response_meas2 n3e_meas2 n3f_meas2 n3ff_meas2 n3ff_response_meas2 ///
			n3g_meas2 n3gg_meas2 n3gg_response_meas2 n3ggg_meas2 n3ggg_response_meas2 n3h_meas2	n3hh_meas2 n3hh_response_meas2  n3hhh_meas2 ///
			n3hhh_response_meas2 n3i_meas2 n3j_meas2 n3k_meas2 n3kk1_meas2 n3kk1_response_meas2 n3kk2_meas2 n3kk2_response_meas2 n3l_meas2 ///
			n3ll_meas2 n3ll_response_meas2 n3lll_meas2 n3lll_response_meas2	n3m_meas2 n3n_meas2 n3o_meas2 n3oo_meas2 n3oo_response_meas2 ///
			n3p_meas2 n3pp_meas2 n3pp_response_meas2 n3q_meas2 n3r_meas2 n3rr_meas2 n3rrr_meas2 n3rrr_response_meas2 n3s_meas2 ///	
			n3t_meas2_1 n3t_meas2_2 n3t_other_2_meas2 n3t_other_meas2 n3tt_1_meas2 n3tt_2_meas2 n3ttt_meas2 n3ttt_meas2_response cc1_meas2 cc1_response_meas2	///	
			cc1a_meas2 cc1a_response_meas2 ncc3_meas2 ncc3_response_meas2 ncc3a_meas2 ncc3a_response_meas2 p1_meas2_1 p1_meas2_2 p1_meas2_3 p1_other_meas2 p2a_meas2 p2b_meas2	///	
			p3_meas2 p4_meas2 p3a_meas2 p3a_response_meas2 p3e_meas2 p3e_response_meas2 cp1_meas2 cp1a_meas2 cp1a_response_meas2 cp2_meas2  cp2_response_meas2 ///
			cp3_meas2 cp3a_meas2 cp3a_response_meas2 cp4_meas2 cp4_response_meas2 cp6_meas2 cp6_response_meas2 sp1_meas2 sp1_response_meas2 sp2_meas2 ///
			sp2a_meas2 sp2a_response_meas2 sp3_meas2 sp3_response_meas2 sp3a_meas2 sp4_meas2 sp4_response_meas2 sp5_meas2 sp5_response_meas2 n41_meas2 /// 
			n42_meas2 n5_meas2_orig n5_meas2 n5a_meas2  n5a_response_meas2 nn5aa_meas2 n5b_meas2 n5bb_meas2 n5bb_response_meas2 n6_meas2  n6_other_meas2 n6aa_meas2 n6ab_meas2 ///
			n6ac_meas2 n6ba_meas2 n6ca_meas2 n6cb_meas2 n6cc_meas2	 n7_meas2 n7_response_meas2 n6a_meas2  n6b_meas2 n6c_meas2 er2_meas2 er6_meas2 er9_meas2 ///
			er15_meas2 er15_response_meas2 er19_meas2 er19_response_meas2) ///
			(claimid meas meas_date  ///
			aa3_1 aa3_2 aa3_3 aa3_4 aa3_5 aa3_6 aa3_7 aa3_98 aa3other ///
			obf1 n2 n3a n3aa n3aa_response n3b n3bb n3bb_response ///
			n3c n3cc n3cc_response n3d n3dd n3dd_response n3e n3f n3ff n3ff_response ///
			n3g n3gg n3gg_response n3ggg n3ggg_response n3h	n3hh n3hh_response  n3hhh ///
			n3hhh_response n3i n3j n3k n3kk1 n3kk1_response n3kk2 n3kk2_response n3l ///
			n3ll n3ll_response n3lll n3lll_response	n3m n3n n3o n3oo n3oo_response ///
			n3p n3pp n3pp_response n3q n3r n3rr n3rrr n3rrr_response n3s ///	
			n3t_1 n3t_2 n3t_other_2 n3t_other n3tt_1 n3tt_2 n3ttt n3ttt_response cc1 cc1_response	///	
			cc1a cc1a_response ncc3 ncc3_response ncc3a ncc3a_response p1_1 p1_2 p1_3 p1_other p2a p2b	///	
			p3 p4 p3a p3a_response p3e p3e_response cp1 cp1a cp1a_response cp2  cp2_response ///
			cp3 cp3a cp3a_response cp4 cp4_response cp6 cp6_response sp1 sp1_response sp2 ///
			sp2a sp2a_response sp3 sp3_response sp3a sp4 sp4_response sp5 sp5_response n41 /// 
			n42 n5_orig n5 n5a  n5a_response nn5aa n5b n5bb n5bb_response n6  n6_other n6aa n6ab ///
			n6ac n6ba n6ca n6cb n6cc	 n7 n7_response n6a  n6b n6c er2 er6 er9 ///
			er15 er15_response er19 er19_response)

		save "$claims/CIAC nonenhanced claimid dup_questions_meas2.dta", replace
		restore		
		
		preserve
			keep if meas3!=""
			keep sampleid ClaimId_meas3 meas3 meas_1_date  ///
			aa3_meas3_1 aa3_meas3_2 aa3_meas3_3 aa3_meas3_4 aa3_meas3_5 aa3_meas3_6 aa3_meas3_7 aa3_meas3_98 aa3_meas3other ///
			obf1_meas3 n2_meas3 n3a_meas3 n3aa_meas3 n3aa_response_meas3 n3b_meas3 n3bb_meas3 n3bb_response_meas3 ///
			n3c_meas3 n3cc_meas3 n3cc_response_meas3 n3d_meas3 n3dd_meas3 n3dd_response_meas3 n3e_meas3 n3f_meas3 n3ff_meas3 n3ff_response_meas3 ///
			n3g_meas3 n3gg_meas3 n3gg_response_meas3 n3ggg_meas3 n3ggg_response_meas3 n3h_meas3	n3hh_meas3 n3hh_response_meas3  n3hhh_meas3 ///
			n3hhh_response_meas3 n3i_meas3 n3j_meas3 n3k_meas3 n3kk1_meas3 n3kk1_response_meas3 n3kk2_meas3 n3kk2_response_meas3 n3l_meas3 ///
			n3ll_meas3 n3ll_response_meas3 n3lll_meas3 n3lll_response_meas3	n3m_meas3 n3n_meas3 n3o_meas3 n3oo_meas3 n3oo_response_meas3 ///
			n3p_meas3 n3pp_meas3 n3pp_response_meas3 n3q_meas3 n3r_meas3 n3rr_meas3 n3rrr_meas3 n3rrr_response_meas3 n3s_meas3 ///	
			n3t_meas3_1 n3t_meas3_2 n3t_other_2_meas3 n3t_other_meas3 n3tt_1_meas3 n3tt_2_meas3 n3ttt_meas3 n3ttt_meas3_response cc1_meas3 cc1_response_meas3	///	
			cc1a_meas3 cc1a_response_meas3 ncc3_meas3 ncc3_response_meas3 ncc3a_meas3 ncc3a_response_meas3 p1_meas3_1 p1_meas3_2 p1_meas3_3 p1_other_meas3 p2a_meas3 p2b_meas3	///	
			p3_meas3 p4_meas3 p3a_meas3 p3a_response_meas3 p3e_meas3 p3e_response_meas3 cp1_meas3 cp1a_meas3 cp1a_response_meas3 cp2_meas3  cp2_response_meas3 ///
			cp3_meas3 cp3a_meas3 cp3a_response_meas3 cp4_meas3 cp4_response_meas3 cp6_meas3 cp6_response_meas3 sp1_meas3 sp1_response_meas3 sp2_meas3 ///
			sp2a_meas3 sp2a_response_meas3 sp3_meas3 sp3_response_meas3 sp3a_meas3 sp4_meas3 sp4_response_meas3 sp5_meas3 sp5_response_meas3 n41_meas3 /// 
			n42_meas3 n5_meas3_orig n5_meas3 n5a_meas3  n5a_response_meas3 nn5aa_meas3 n5b_meas3 n5bb_meas3 n5bb_response_meas3 n6_meas3  n6_other_meas3 n6aa_meas3 n6ab_meas3 ///
			n6ac_meas3 n6ba_meas3 n6ca_meas3 n6cb_meas3 n6cc_meas3	 n7_meas3 n7_response_meas3 n6a_meas3  n6b_meas3 n6c_meas3 er2_meas3 er6_meas3 er9_meas3 ///
			er15_meas3 er15_response_meas3 er19_meas3 er19_response_meas3

			rename (ClaimId_meas3 meas3 meas_1_date  ///
			aa3_meas3_1 aa3_meas3_2 aa3_meas3_3 aa3_meas3_4 aa3_meas3_5 aa3_meas3_6 aa3_meas3_7 aa3_meas3_98 aa3_meas3other ///
			obf1_meas3 n2_meas3 n3a_meas3 n3aa_meas3 n3aa_response_meas3 n3b_meas3 n3bb_meas3 n3bb_response_meas3 ///
			n3c_meas3 n3cc_meas3 n3cc_response_meas3 n3d_meas3 n3dd_meas3 n3dd_response_meas3 n3e_meas3 n3f_meas3 n3ff_meas3 n3ff_response_meas3 ///
			n3g_meas3 n3gg_meas3 n3gg_response_meas3 n3ggg_meas3 n3ggg_response_meas3 n3h_meas3	n3hh_meas3 n3hh_response_meas3  n3hhh_meas3 ///
			n3hhh_response_meas3 n3i_meas3 n3j_meas3 n3k_meas3 n3kk1_meas3 n3kk1_response_meas3 n3kk2_meas3 n3kk2_response_meas3 n3l_meas3 ///
			n3ll_meas3 n3ll_response_meas3 n3lll_meas3 n3lll_response_meas3	n3m_meas3 n3n_meas3 n3o_meas3 n3oo_meas3 n3oo_response_meas3 ///
			n3p_meas3 n3pp_meas3 n3pp_response_meas3 n3q_meas3 n3r_meas3 n3rr_meas3 n3rrr_meas3 n3rrr_response_meas3 n3s_meas3 ///	
			n3t_meas3_1 n3t_meas3_2 n3t_other_2_meas3 n3t_other_meas3 n3tt_1_meas3 n3tt_2_meas3 n3ttt_meas3 n3ttt_meas3_response cc1_meas3 cc1_response_meas3	///	
			cc1a_meas3 cc1a_response_meas3 ncc3_meas3 ncc3_response_meas3 ncc3a_meas3 ncc3a_response_meas3 p1_meas3_1 p1_meas3_2 p1_meas3_3 p1_other_meas3 p2a_meas3 p2b_meas3	///	
			p3_meas3 p4_meas3 p3a_meas3 p3a_response_meas3 p3e_meas3 p3e_response_meas3 cp1_meas3 cp1a_meas3 cp1a_response_meas3 cp2_meas3  cp2_response_meas3 ///
			cp3_meas3 cp3a_meas3 cp3a_response_meas3 cp4_meas3 cp4_response_meas3 cp6_meas3 cp6_response_meas3 sp1_meas3 sp1_response_meas3 sp2_meas3 ///
			sp2a_meas3 sp2a_response_meas3 sp3_meas3 sp3_response_meas3 sp3a_meas3 sp4_meas3 sp4_response_meas3 sp5_meas3 sp5_response_meas3 n41_meas3 /// 
			n42_meas3 n5_meas3_orig n5_meas3 n5a_meas3  n5a_response_meas3 nn5aa_meas3 n5b_meas3 n5bb_meas3 n5bb_response_meas3 n6_meas3  n6_other_meas3 n6aa_meas3 n6ab_meas3 ///
			n6ac_meas3 n6ba_meas3 n6ca_meas3 n6cb_meas3 n6cc_meas3	 n7_meas3 n7_response_meas3 n6a_meas3  n6b_meas3 n6c_meas3 er2_meas3 er6_meas3 er9_meas3 ///
			er15_meas3 er15_response_meas3 er19_meas3 er19_response_meas3) ///
			(claimid meas meas_date  ///
			aa3_1 aa3_2 aa3_3 aa3_4 aa3_5 aa3_6 aa3_7 aa3_98 aa3other ///
			obf1 n2 n3a n3aa n3aa_response n3b n3bb n3bb_response ///
			n3c n3cc n3cc_response n3d n3dd n3dd_response n3e n3f n3ff n3ff_response ///
			n3g n3gg n3gg_response n3ggg n3ggg_response n3h	n3hh n3hh_response  n3hhh ///
			n3hhh_response n3i n3j n3k n3kk1 n3kk1_response n3kk2 n3kk2_response n3l ///
			n3ll n3ll_response n3lll n3lll_response	n3m n3n n3o n3oo n3oo_response ///
			n3p n3pp n3pp_response n3q n3r n3rr n3rrr n3rrr_response n3s ///	
			n3t_1 n3t_2 n3t_other_2 n3t_other n3tt_1 n3tt_2 n3ttt n3ttt_response cc1 cc1_response	///	
			cc1a cc1a_response ncc3 ncc3_response ncc3a ncc3a_response p1_1 p1_2 p1_3 p1_other p2a p2b	///	
			p3 p4 p3a p3a_response p3e p3e_response cp1 cp1a cp1a_response cp2  cp2_response ///
			cp3 cp3a cp3a_response cp4 cp4_response cp6 cp6_response sp1 sp1_response sp2 ///
			sp2a sp2a_response sp3 sp3_response sp3a sp4 sp4_response sp5 sp5_response n41 /// 
			n42 n5_orig n5 n5a  n5a_response nn5aa n5b n5bb n5bb_response n6  n6_other n6aa n6ab ///
			n6ac n6ba n6ca n6cb n6cc	 n7 n7_response n6a  n6b n6c er2 er6 er9 ///
			er15 er15_response er19 er19_response)

		save "$claims/CIAC nonenhanced claimid dup_questions_meas3.dta", replace
		restore		
				
		use "$claims/CIAC nonenhanced claimid dup_questions_meas1.dta", clear
		append using "$claims\CIAC nonenhanced claimid dup_questions_meas2.dta", force
		append using "$claims\CIAC nonenhanced claimid dup_questions_meas3.dta", force
			gen fin0=""
			gen fin1_a=""
			gen fin1_b=""
			gen fin1_c=""
			gen fin7=""
			gen fin8_1=""
			gen fin8_2=""
			gen fin8_3=""
			order fin0 fin1_a fin1_b fin1_c fin7 fin8_1 fin8_2 fin8_3, after(n3kk2_response)
			order n3t_2 n3t_other_2 n3tt_2, after(n3t_other)
			order meas meas_date aa3other, first
			order p1_3 , after(p1_2)
		save "$claims/CIAC nonenhanced claimid dup_questions_all.dta", replace
		
		
*******************
// Duplication checks for multimeas>1 in sbd
*******************		
use "$work/ciac_all_completes.dta", clear
	keep if sbd ==1
	
	tostring _all, replace
	destring pi3, replace
	
	tab pi3 // there are 3 in need to duplicate-- 329 and 343 & 249
	expand 3 if sampleid=="329"
	list sampleid if sampleid=="329"
	replace meas1 = "Whole builiding SBD, water heater, high performance glazing, cool roof" in 54 if sampleid=="329"
	replace ClaimId1 = "SDGE-2018-3222-10384692-1320518" in 54 if sampleid=="329"
	replace meas1 = "vrf system" in 53 if sampleid=="329"
	replace ClaimId1 = "SDGE-2018-3222-10384692-1214062" in 53 if sampleid=="329"

	order intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role ///
	intro3_department intro4 intro4_other intro4_openend incent1 a1gg pi1 pi3 pi3a pi4 pi6 ///
	pi6_openend pi7 pi7a pi7a_openend obf1 wb1 wb1a wb2 wb2a wb3 wb3_openend wbcc1 ///
	wb4 wb4a wb5 wb5a wb_npi1 wb_npi2 wb_npi3 wb_npi4 wb_npi5 wb_npi6 wb_npi7 wb_npi8 ///
	wb_npi9 wb_npi10 wb_npi11 wb_npi12 wb_npi13 wb_npi14 wb_n3k wb_rpi1 wb_rpi2 wb_pi5 wb_ap1 wb_ap2 ///
	fdintro fdintro_openend fd1 fd1_openend fd2 fd2_openend fd3 fdcc1 fdcc1_openend fdcc2 fdcc2_openend ///
	fin0 fin1 fin7 fin7_1 fin7_2 fin7_3 fin8 fin8_1 fin8_2 fin8_3  ///
	ap1a ap2_openend ap2a ap2b apcc1 apcc2 d1 ///
	p1 p2 p3 p4 sbd_lt1 sbd_lt2 sbd_lt3
	
	rename (meas1 meas_1_date ClaimId1) (meas meas_date claimid)
	
	preserve
		keep sampleid sys meas meas_date claimid ///
			intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role ///
			intro3_department intro4 intro4_other intro4_openend incent1 a1gg pi1 pi3 pi3a pi4 pi6 ///
			pi6_openend pi7 pi7a pi7a_openend obf1 wb1 wb1a wb2 wb2a wb3 wb3_openend wbcc1 ///
			wb4 wb4a wb5 wb5a wb_npi1 wb_npi2 wb_npi3 wb_npi4 wb_npi5 wb_npi6 wb_npi7 wb_npi8 ///
			wb_npi9 wb_npi10 wb_npi11 wb_npi12 wb_npi13 wb_npi14 wb_n3k wb_rpi1 wb_rpi2 wb_pi5 wb_ap1 wb_ap2 ///
			fdintro fdintro_openend fd1 fd1_openend fd2 fd2_openend fd3 fdcc1 fdcc1_openend fdcc2 fdcc2_openend ///
			fin0 fin1 fin7 fin7_1 fin7_2 fin7_3 fin8 fin8_1 fin8_2 fin8_3  ///
			ap1a ap2_openend ap2a ap2b apcc1 apcc2 d1 ///
			p1 p2 p3 p4 sbd_lt1 sbd_lt2 sbd_lt3 ///
			v_aa1  v_aa2  v_a1  v_a2  v_a3  v2_meas1 v3_meas1  v4_meas1  v5_meas1  ///
			v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 ///
			v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 ///
			v14_meas1 v15_meas1 v16_meas1 v16a_meas1
		rename (v2_meas1 v3_meas1  v4_meas1  v5_meas1  ///
			v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 ///
			v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 ///
			v14_meas1 v15_meas1 v16_meas1 v16a_meas1) ///
			(v2 v3  v4  v5  v6a v6aa v6bb v7a v7b v7c v8 v9 v9a v10 v11 v12 v13 v13a v14 v15 v16 v16a)
			replace meas ="" if sys=="1"
			replace meas_date ="" if sys=="1"
			replace claimid ="" if sys=="1"
		drop if claimid=="SDGE-2018-3222-10384692-1320518" & sampleid=="329"
		drop if claimid=="SDGE-2018-3222-10384692-1214062" & sampleid=="329"

		save "$claims/CIAC enhanced claimid non_dup_questions.dta",replace
	restore
	
	preserve
		keep sampleid sys meas meas_date claimid ///
			intro1 intro2 intro3 intro3_name intro3_phone intro3_email intro3_role ///
			intro3_department intro4 intro4_other intro4_openend incent1 a1gg pi1 pi3 pi3a pi4 pi6 ///
			pi6_openend pi7 pi7a pi7a_openend obf1 wb1 wb1a wb2 wb2a wb3 wb3_openend wbcc1 ///
			wb4 wb4a wb5 wb5a wb_npi1 wb_npi2 wb_npi3 wb_npi4 wb_npi5 wb_npi6 wb_npi7 wb_npi8 ///
			wb_npi9 wb_npi10 wb_npi11 wb_npi12 wb_npi13 wb_npi14 wb_n3k wb_rpi1 wb_rpi2 wb_pi5 wb_ap1 wb_ap2 ///
			fdintro fdintro_openend fd1 fd1_openend fd2 fd2_openend fd3 fdcc1 fdcc1_openend fdcc2 fdcc2_openend ///
			fin0 fin1 fin7 fin7_1 fin7_2 fin7_3 fin8 fin8_1 fin8_2 fin8_3  ///
			ap1a ap2_openend ap2a ap2b apcc1 apcc2 d1 ///
			p1 p2 p3 p4 sbd_lt1 sbd_lt2 sbd_lt3 ///
			v_aa1  v_aa2  v_a1  v_a2  v_a3  v2_meas1 v3_meas1  v4_meas1  v5_meas1  ///
			v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 ///
			v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 ///
			v14_meas1 v15_meas1 v16_meas1 v16a_meas1 
		rename (v2_meas1 v3_meas1  v4_meas1  v5_meas1  ///
			v6a_meas1 v6aa_meas1 v6bb_meas1 v7a_meas1 v7b_meas1 v7c_meas1 v8_meas1 ///
			v9_meas1 v9a_meas1 v10_meas1 v11_meas1 v12_meas1 v13_meas1 v13a_meas1 ///
			v14_meas1 v15_meas1 v16_meas1 v16a_meas1) ///
			(v2 v3  v4  v5  v6a v6aa v6bb v7a v7b v7c v8 v9 v9a v10 v11 v12 v13 v13a v14 v15 v16 v16a)
			replace meas ="" if sys=="1"
			replace meas_date ="" if sys=="1"
			replace claimid ="" if sys=="1"
		keep if (claimid=="SDGE-2018-3222-10384692-1320518" & sampleid=="329") | (claimid=="SDGE-2018-3222-10384692-1214062" & sampleid=="329")  
		save "$claims/CIAC enhanced claimid dup_wb_questions.dta",replace
	restore
	
	preserve
		keep if sys=="1"
		keep sampleid sys multimeas pi3 meas claimid meas_date ///
			sa_meas1 ///
			sa1_meas1 sa2_meas1 sa_npi1_meas1 sa_npi2_meas1 sa_npi3_meas1 sa_npi4_meas1 ///
			sa_npi5_meas1 sa_npi6_meas1 sa_npi7_meas1 sa_npi8_meas1 sa_npi9_meas1 sa_npi10_meas1 ///
			sa_npi11_meas1 sa_npi12_meas1 sa_npi13_meas1 sa_npi14_meas1 sa_n3k_meas1 fin1_a_meas1 ///
			fin1_b_meas1 fin1_c_meas1 fin7_meas1_1 fin7_meas1_2 fin7_meas1_3 fin7_meas1_4 ///
			fin7_meas1_5 fin7_other_meas1 fin8_meas1_1 fin8_meas1_2 fin8_meas1_3 fin8_other_meas1 ///
			sa_rpi1_meas1 sa_rpi2_meas1 sa_pi5_meas1 sa_ap1_meas1_orig sa_ap1_meas1 sa_ap2_meas1 
			
		rename (sampleid pi3 meas claimid meas_date ///
			sa_meas1 ///
			sa1_meas1 sa2_meas1 sa_npi1_meas1 sa_npi2_meas1 sa_npi3_meas1 sa_npi4_meas1 ///
			sa_npi5_meas1 sa_npi6_meas1 sa_npi7_meas1 sa_npi8_meas1 sa_npi9_meas1 sa_npi10_meas1 ///
			sa_npi11_meas1 sa_npi12_meas1 sa_npi13_meas1 sa_npi14_meas1 sa_n3k_meas1 fin1_a_meas1 ///
			fin1_b_meas1 fin1_c_meas1 fin7_meas1_1 fin7_meas1_2 fin7_meas1_3 fin7_meas1_4 ///
			fin7_meas1_5 fin7_other_meas1 fin8_meas1_1 fin8_meas1_2 fin8_meas1_3 fin8_other_meas1 ///
			sa_rpi1_meas1 sa_rpi2_meas1 sa_pi5_meas1 sa_ap1_meas1_orig sa_ap1_meas1 sa_ap2_meas1) ///
			(sampleid pi3 meas claimid meas_date ///
			sa_meas ///
			sa1 sa2 sa_npi1 sa_npi2 sa_npi3 sa_npi4 ///
			sa_npi5 sa_npi6 sa_npi7 sa_npi8 sa_npi9 sa_npi10 ///
			sa_npi11 sa_npi12 sa_npi13 sa_npi14 sa_n3k fin1_a ///
			fin1_b fin1_c fin7_1 fin7_2 fin7_3 fin7_4 ///
			fin7_5 fin7_other fin8_1 fin8_2 fin8_3 fin8_other ///
			sa_rpi1 sa_rpi2 sa_pi5 sa_ap1_orig sa_ap1 sa_ap2)
		save "$claims/CIAC enhanced claimid dup_questions_meas1.dta",replace
	restore			
			
	preserve
		keep if multimeas=="2" & sa_claimid2!=""&sa_claimid2!="."
		keep sampleid sys pi3 meas claimid meas_date ///
			sa_meas2 ///
			sa1_meas2 sa2_meas2 sa_npi1_meas2 sa_npi2_meas2 sa_npi3_meas2 sa_npi4_meas2 ///
			sa_npi5_meas2 sa_npi6_meas2 sa_npi7_meas2 sa_npi8_meas2 sa_npi9_meas2 sa_npi10_meas2 ///
			sa_npi11_meas2 sa_npi12_meas2 sa_npi13_meas2 sa_npi14_meas2 sa_n3k_meas2 fin1_a_meas2 ///
			fin1_b_meas2 fin1_c_meas2 fin7_meas2_1 fin7_meas2_2 fin7_meas2_3 fin7_meas2_4 ///
			fin7_meas2_5 fin7_other_meas2 fin8_meas2_1 fin8_meas2_2 fin8_meas2_3 fin8_other_meas2 ///
			sa_rpi1_meas2 sa_rpi2_meas2 sa_pi5_meas2 sa_ap1_meas2_orig sa_ap1_meas2 sa_ap2_meas2 
			
		rename (sampleid pi3 meas claimid meas_date ///
			sa_meas2 ///
			sa1_meas2 sa2_meas2 sa_npi1_meas2 sa_npi2_meas2 sa_npi3_meas2 sa_npi4_meas2 ///
			sa_npi5_meas2 sa_npi6_meas2 sa_npi7_meas2 sa_npi8_meas2 sa_npi9_meas2 sa_npi10_meas2 ///
			sa_npi11_meas2 sa_npi12_meas2 sa_npi13_meas2 sa_npi14_meas2 sa_n3k_meas2 fin1_a_meas2 ///
			fin1_b_meas2 fin1_c_meas2 fin7_meas2_1 fin7_meas2_2 fin7_meas2_3 fin7_meas2_4 ///
			fin7_meas2_5 fin7_other_meas2 fin8_meas2_1 fin8_meas2_2 fin8_meas2_3 fin8_other_meas2 ///
			sa_rpi1_meas2 sa_rpi2_meas2 sa_pi5_meas2 sa_ap1_meas2_orig sa_ap1_meas2 sa_ap2_meas2) ///
			(sampleid pi3 meas claimid meas_date ///
			sa_meas ///
			sa1 sa2 sa_npi1 sa_npi2 sa_npi3 sa_npi4 ///
			sa_npi5 sa_npi6 sa_npi7 sa_npi8 sa_npi9 sa_npi10 ///
			sa_npi11 sa_npi12 sa_npi13 sa_npi14 sa_n3k fin1_a ///
			fin1_b fin1_c fin7_1 fin7_2 fin7_3 fin7_4 ///
			fin7_5 fin7_other fin8_1 fin8_2 fin8_3 fin8_other ///
			sa_rpi1 sa_rpi2 sa_pi5 sa_ap1_orig sa_ap1 sa_ap2)
		save "$claims/CIAC enhanced claimid dup_questions_meas2.dta",replace
	restore				
			
	preserve			
		keep if multimeas=="2" & sa_claimid3!=""&sa_claimid3!="."
		keep sampleid sys pi3 meas claimid meas_date ///
			sa_meas3 ///
			sa1_meas3 sa2_meas3 sa_npi1_meas3 sa_npi2_meas3 sa_npi3_meas3 sa_npi4_meas3 ///
			sa_npi5_meas3 sa_npi6_meas3 sa_npi7_meas3 sa_npi8_meas3 sa_npi9_meas3 sa_npi10_meas3 ///
			sa_npi11_meas3 sa_npi12_meas3 sa_npi13_meas3 sa_npi14_meas3 sa_n3k_meas3 fin1_a_meas3 ///
			fin1_b_meas3 fin1_c_meas3 fin7_meas3_1 fin7_meas3_2 fin7_meas3_3 fin7_meas3_4 ///
			fin7_meas3_5 fin7_other_meas3 fin8_meas3_1 fin8_meas3_2 fin8_meas3_3 fin8_other_meas3 ///
			sa_rpi1_meas3 sa_rpi2_meas3 sa_pi5_meas3 sa_ap1_meas3_orig sa_ap1_meas3 sa_ap2_meas3 

		rename (sampleid pi3 meas claimid meas_date ///
			sa_meas3 ///
			sa1_meas3 sa2_meas3 sa_npi1_meas3 sa_npi2_meas3 sa_npi3_meas3 sa_npi4_meas3 ///
			sa_npi5_meas3 sa_npi6_meas3 sa_npi7_meas3 sa_npi8_meas3 sa_npi9_meas3 sa_npi10_meas3 ///
			sa_npi11_meas3 sa_npi12_meas3 sa_npi13_meas3 sa_npi14_meas3 sa_n3k_meas3 fin1_a_meas3 ///
			fin1_b_meas3 fin1_c_meas3 fin7_meas3_1 fin7_meas3_2 fin7_meas3_3 fin7_meas3_4 ///
			fin7_meas3_5 fin7_other_meas3 fin8_meas3_1 fin8_meas3_2 fin8_meas3_3 fin8_other_meas3 ///
			sa_rpi1_meas3 sa_rpi2_meas3 sa_pi5_meas3 sa_ap1_meas3_orig sa_ap1_meas3 sa_ap2_meas3) ///
			(sampleid pi3 meas claimid meas_date ///
			sa_meas ///
			sa1 sa2 sa_npi1 sa_npi2 sa_npi3 sa_npi4 ///
			sa_npi5 sa_npi6 sa_npi7 sa_npi8 sa_npi9 sa_npi10 ///
			sa_npi11 sa_npi12 sa_npi13 sa_npi14 sa_n3k fin1_a ///
			fin1_b fin1_c fin7_1 fin7_2 fin7_3 fin7_4 ///
			fin7_5 fin7_other fin8_1 fin8_2 fin8_3 fin8_other ///
			sa_rpi1 sa_rpi2 sa_pi5 sa_ap1_orig sa_ap1 sa_ap2)			
		save "$claims/CIAC enhanced claimid dup_questions_meas3.dta",replace
	restore				
			
	use "$claims/CIAC enhanced claimid dup_questions_meas1.dta", clear
		append using "$claims/CIAC enhanced claimid dup_questions_meas2.dta", force
		append using "$claims/CIAC enhanced claimid dup_questions_meas3.dta", force
		order sampleid pi3 meas claimid meas_date ///
			sa_meas ///
			sa1 sa2 sa_npi1 sa_npi2 sa_npi3 sa_npi4 ///
			sa_npi5 sa_npi6 sa_npi7 sa_npi8 sa_npi9 sa_npi10 ///
			sa_npi11 sa_npi12 sa_npi13 sa_npi14 sa_n3k ///
			sa_rpi1 sa_rpi2 sa_pi5 sa_ap1 sa_ap2
		drop fin1_a ///
			fin1_b fin1_c fin7_1 fin7_2 fin7_3 fin7_4 ///
			fin7_5 fin7_other fin8_1 fin8_2 fin8_3 fin8_other 
			replace claimid="PGE-2018-Q4-95159" in 3 if sampleid=="176"
			replace meas="Systems approach: Efficient HVAC equipment" in 3	if sampleid=="176"		
			replace claimid="PGE-2018-Q4-95160" in 16 if sampleid=="176"
			replace meas="LIGHTING RETROFIT/NEW-INT-LED-OTHER" in 16	if sampleid=="176"
			replace claimid="PGE-2018-Q4-95161" in 21
			replace meas="HVAC RETROFIT/NEW-AC/SPLIT SYSTEMS/HEAT PUMPS-DX/AIR COOLED" in 21 if sampleid=="176"
			
			replace claimid="SDGE-2018-3222-10378857-1782842" in 10 if sampleid=="320"
			replace meas="Systems approach: central boiler and circ pumps" in 10 if sampleid=="320"
			replace claimid="SDGE-2018-3222-10378857-1782845" in 18 if sampleid=="320"
			replace meas="SBD Systems Approach - central boiler and circ pumps" in 18 if sampleid=="320"
					
			replace claimid="SDGE-2018-3222-10379146-1680756" in 12 if sampleid=="323"
			replace meas="Systems approach: exterior lighting" in 12 if sampleid=="323"
			replace claimid="SDGE-2018-3222-10379146-1680757" in 19 if sampleid=="323"
			replace meas="SBD systems approach - interior lighting" in 19 if sampleid=="323"
			
			replace claimid="SDGE-2018-3222-10378935-1715258" in 14 if sampleid=="343"
			replace meas="New Constr Split HVAC" in 14 if sampleid=="343"
			replace claimid="SDGE-2018-3222-10378935-1715381" in 20 if sampleid=="343"		
			replace meas="New Const Ext Ltg Prkg Strtr" in 20 if sampleid=="343"
			replace claimid="SDGE-2018-3222-10378935-1715259" in 22 if sampleid=="343"		
			replace meas="New Const Whole Bldg Int Ltg" in 22 if sampleid=="343"
			
			replace claimid="SCE-2018-Q4-0077660" in 7 if sampleid=="249"
			replace meas="New Construction - Above Code Systems Design - Parking Lot Lighting (Lighting Zone 3)" in 7 if sampleid=="249"
			replace claimid="SCE-2018-Q4-0077659" in 17 if sampleid=="249"
			replace meas="New Construction - Above Code Systems Design - Air-Cooled Package A/C" in 17 if sampleid=="249"
						
			
		save "$claims/CIAC enhanced claimid dup_questions_all.dta", replace
		
		
*******************
// Combine all
*******************		

	use "$claims/CIAC nonenhanced claimid non_dup_questions.dta", clear
		expand 2 if sampleid=="53"|sampleid=="56"|sampleid=="64"|sampleid=="93"|sampleid=="94"|sampleid=="95"|sampleid=="101"|sampleid=="104"|sampleid=="108"|sampleid=="118" ///
		|sampleid=="131"|sampleid=="133"|sampleid=="216"|sampleid=="285"|sampleid=="410"|sampleid=="426"|sampleid=="430" ///
		|sampleid=="497"|sampleid=="527"|sampleid=="529"|sampleid=="584"|sampleid=="588"|sampleid=="589" ///
		|sampleid=="603"|sampleid=="612"|sampleid=="622"|sampleid=="628"|sampleid=="630"|sampleid=="651"|sampleid=="684"|sampleid=="734" ///
		|sampleid=="735"|sampleid=="736"|sampleid=="737"|sampleid=="740"|sampleid=="742"|sampleid=="743"|sampleid=="828"

		expand 3 if sampleid=="9"|sampleid=="115"|sampleid=="142"|sampleid=="195"|sampleid=="201"|sampleid=="266"|sampleid=="276"|sampleid=="455" ///
		|sampleid=="528"|sampleid=="613"|sampleid=="633"|sampleid=="655"|sampleid=="717"|sampleid=="798"|sampleid=="829"
		merge m:m sampleid using "$claims\CIAC nonenhanced claimid dup_questions_all.dta", update replace
			drop _merge 
		save "$claims\CIAC nonenhanced claimid all.dta", replace

	use "$claims\CIAC enhanced claimid non_dup_questions.dta", clear
		append using "$claims/CIAC enhanced claimid dup_wb_questions.dta"
		expand 2 if sampleid=="320"|sampleid=="323"|sampleid=="249"
		expand 3 if sampleid=="176"|sampleid=="343"
		merge m:m sampleid using "$claims/CIAC enhanced claimid dup_questions_all.dta", update replace
			drop _merge 
		
		replace claimid="SDGE-2018-3222-10794360-1893084" if sampleid=="349" & claimid==""
		replace claimid="SDGE-2018-3222-10786686-1802008" if sampleid=="337" & claimid==""
		replace claimid="SDGE-2018-3222-10379146-1680756" if sampleid=="323" & claimid==""
		replace claimid="SDGE-2018-3222-10378875-1810070" if sampleid=="321" & claimid==""
		replace claimid="SCG-2018-3710-500000614U-10" if sampleid=="258" & claimid==""
		replace claimid="SCE-2018-Q4-0113246" if sampleid=="242" & claimid==""
		replace claimid="SCE-2018-Q1-0001752" if sampleid=="243" & claimid==""
		replace claimid="SCE-2018-Q1-0001753" if sampleid=="244" & claimid==""
		replace claimid="PGE-2018-Q3-73995" if sampleid=="164" & claimid==""
		replace claimid="PGE-2018-Q4-127336" if sampleid=="92" & claimid==""
		replace claimid="SCE-2018-Q4-0077638" if sampleid=="250" & claimid==""
		
		order sa*, after(wb_ap2)
		save "$claims\CIAC enhanced claimid all.dta", replace

	use "$claims\CIAC nonenhanced claimid all.dta", clear
		append using "$claims\CIAC enhanced claimid all.dta", force
		destring sampleid sys, replace
		merge m:1 sampleid using "$work/CIAC claimid info.dta", force
			drop _merge
			order completed sampleid sbw_projid contact business sector rigor multimeas multiaddr ///
		sbd ciac_nsbd wb sys dt , first
		
		replace lt2="10" if strpos(lt2,"Over 10")
		replace lt2="12.5" if strpos(lt2,"10 to 15")
		replace ccc1="" if ccc1=="NA - factories"| ccc1=="We have several different facilities: City Hall is 222,000 sq ft. and the police Dept. 35,0000"| ccc1=="9999999"| strpos(ccc1, "20 a")
		replace ccc1="150000" if ccc1=="150,000"
		replace n6ab="2" if n6ab=="Not until someone complained- 2 years approx"
		replace fdintro ="0" if fdintro == "oo"
		replace fdintro ="1" if fdintro == "ROI/ operating cost"
		replace fd1="0" if fd1=="OO"
		replace sbd_lt2 ="1" if strpos(sbd_lt2, "1")
		replace sbd_lt2 = "2" if strpos(sbd_lt2, "2")
		replace sbd_lt2 = "" if sbd_lt2!="1"| sbd_lt2!="2"
		replace sbd_lt3 ="1" if strpos(sbd_lt3, "1")
		replace sbd_lt3 = "2" if strpos(sbd_lt3, "2")
		replace sbd_lt3 = "" if sbd_lt3!="1"| sbd_lt3!="2"
		replace n6ab="" if n6ab=="Until the equipment fails"
		replace n6cb="3" if strpos(n6cb,"Feb")
		replace er2="7.5" if  strpos(er2,"5 to 10")		
		replace er2="" if  strpos(er2,"Until fail")
		replace er2="2.5" if strpos(er2,"2 to 3")
		replace er2="6" if strpos(er2,"-6")
		replace er6="" if strpos(er6,"75%")
		replace er9="3" if strpos(er9,"2 to 4")
		replace er9="2.5" if strpos(er9,"2 to 3")		
		replace er9="5.5" if strpos(er9,"5 to 6")
		replace er9="" if strpos(er9,"Repair as")
		replace er9="7.5" if  strpos(er9,"5 to 10")			
		replace er9="2.5" if  strpos(er9,"1 to 4")		
		replace incent1="1%" if  strpos(incent1,"<")&strpos(incent1,"1%")
		replace incent1 = subinstr(incent1, "%", "",.)
		replace ccc1="150000" if ccc1 =="100,000-200,000"
		replace n6cb="0" if strpos(n6cb,"We")
		destring _all,replace
		replace cc12a=. if cc12a>9995
		drop if sampleid==156
		replace sa_meas=8 if sampleid==249|sampleid==343
	save "$work\CIAC data by claimid all.dta", replace
	export excel using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files\ClaimId Level\CIAC data by claimid all.xlsx", firstrow(variables) nolabel replace








		
		
		