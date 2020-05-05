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

 
 ****************
// CIAC SBD 
****************

// Disposition file
clear
 import delimited "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_Net Survey Dispositions.csv", clear

// save
save "$work/ciac_dispositions.dta", replace

// Raw data file
import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\_Enhanced\SBD Survey Instrument- Excel\CIAC SBD Survey Coded into Excel 1-24-20_MASTER.xlsx", sheet("SBD Owner Survey") firstrow case(lower) clear 		
		drop if sbw_projid==""
		
			// Merge in disposition file
			sort sampleid
			keep if completed==1

		// drop blankrows and incompletes
			drop if sbw_projid == ""
			drop if sampleid == .
			br
			
		// Merge survey data with sample file
		merge 1:1 sbw_projid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\CIAC_All Sample with added Net Sample.dta", keepusing (sampleid ClaimI*)
		keep if _merge == 3

		// Drop variables that are not needed
		drop v intro skip* surveystart wborsys wbintro1 wbintro2 saintro1 saintro2 npiintro pintro ///
		ltintro end complete_flag rpi check _merge interviewsummarycomplete ///
		ah meas1date aj meas2date al meas3date

		order sampleid, before(sbw_projid)
		order ClaimId1, after(meas1)
		order ClaimId2, after(meas2)
		order ClaimId3, after(meas3)
		order pa program, after(sys)
		order sector, after(dt)
		
		// untill we have a design team interview completed, leave this variable here
		gen dt_interview = 0
		order dt_interview, after(obf)
		
		//Tidy Data
		rename (importanceofprogramfactors importanceofnonprogramfac name phone email roleincompany department) ///
		(rpi1 rpi2 intro3_name intro3_phone intro3_email intro3_role intro3_department)

			
		//this is a loop to ensure that open-ends are not truncated
			foreach var of varlist _all {
				capture confirm string variable `var'
				if !_rc {
					recast str255 `var'
				}
			}
			
		// clean variables

	// Before we clean, convert variables to strings 
		foreach var of varlist intro1 intro4 obf* pi1 pi3 pi5 pi6 pi7 pi7a wb1 wb2 wb3 wb4 wb5 npi* fdintro fd2 fd3 n3k rpi1 rpi2 p3 d1 ap* sameas* sa1 sa2{
			tostring `var', replace
		}
		 
		//replace wb = 1 if sampleid == 91
		replace intro1 = "2" if intro1 == "0"
			
		foreach var of varlist intro2-intro3_department {
				replace `var' = -96 if intro1 != "1"
		}
			
		replace intro4 = "1" if intro4 == "."

		
		// Clean incentive variable
		rename incent1 incent_old
		gen incent1 = incent_old 
		order incent1, after(incent_old)
		replace incent1 = "-98" if sampleid == 91 | sampleid == 157
		replace incent1 = "0.05%" if sampleid == 320
		replace incent1 = "2%" if sampleid == 323
		replace incent1 = "3%" if sampleid == 341
		replace incent1 = "0.000071%" if sampleid == 324 | sampleid == 342
		replace incent1 = "3%" if sampleid == 327
		replace incent1 = "0.068%" if sampleid == 329
		replace incent1 = "0.30%" if sampleid == 330
		replace incent1 = "0.11%" if sampleid == 331
		replace incent1 = "0.95%" if sampleid == 248
		replace incent1 = "0.2%" if sampleid == 158
		replace incent1 = "10%" if sampleid == 162
		replace incent1 = "0.13%" if sampleid == 165
		replace incent1 = "1%" if sampleid == 171
		drop incent_old
		
		replace a1gg = -96 if sampleid == 157
				
		replace wb1 = "-98" if wb1 == "."
		replace wb2 = "-98" if wb2 == "."
		replace wb3 = "-98" if wb3 == "."
		
		replace pi3a = "" if multimeas == 1
		replace pi3a = "-96" if pi3 == "1"
		
		replace pi6_openend = "-96" if pi6 == "1"
		replace pi6_openend = "-98" if pi6 == "2" & pi6_openend == "-96"
		
		replace pi7a = "-96" if pi7 == "2"
		replace pi7pi7a_openend = "-96" if pi7 == "2"
				
		replace npi13 = "-96" if sector == 0
		
		replace d1 = "-96" if multimeas == 1 & sys == 1
		replace sameas1 = "" if sys == 0
		replace sameas2 = "" if sys == 0
		replace sameas3 = "" if sys == 0
		replace sameas2 = "-96" if sampleid == 242
		replace sa1 = "" if sys == 0
		replace sa2 = "" if sys == 0

		replace npi14_openend = "" if npi14 == "-96"
		replace npi14 = "-96" if sampleid == 165
	
		replace fd3 = "-96" if fd2 != "1"

		replace obf1 = "" if obf == "0"
		
		replace pi7="1" if sampleid==173

			//this is a loop to destring numeric variables
			foreach var of varlist sector rigor	multimeas multiaddr sbd wb sys obf dt ///
			intro1 intro4 obf* pi1 pi3 pi5 pi7 pi7a wb1 wb2 wb3 wb4 wb5 npi* fdintro fd2 fd3 n3k rpi1 rpi2 p3  d1 ap* sameas* sa1 sa2{
				destring `var', replace
			}
			
			// Need to make sure all these variables are numeric before doing so
			//this is a loop to replace 96 98 99 with -96 -98 -99
			/*foreach var of varlist pi1 pi3 pi5 pi7 pi7a wb1 wb2 wb3 wb4 wb5 npi* fd3 n3k{
				replace `var' = -96 if `var' == 96
				replace `var' = -98 if `var' == 98
				replace `var' = -99 if `var' == 99
			}*/

		autoformat

		// Consistency checks

		/*//wbcc1
		br sampleid wbcc1 pi7 wb1 wb2 if (pi7 == 2 & wb1 > 6 & wb1 !=.) | (pi7 == 2 & wb2 >6 * wb2 !=.)

		//apcc1
		br sampleid apcc1 ap2 wb4 sameas1 if (ap2 == 1 & wb4 > 7 & wb4 !=.) | (ap2 == 1 & sameas1 < 4 & sameas1 !=.)

		//apcc2
		br sampleid apcc2 ap2 wb1 wb2 sa1 sa2 if (ap2 == 1 & wb1 > 7 & wb1 !=.) | (ap2 == 1 & wb2 > 7 & wb2 !=.) |  (ap2 == 1 & sa1 > 7 & sa1 !=.) | (ap2 == 1 & sa2 > 7 & sa2 !=.) 

		// fdcc1
		br sampleid fdcc1 fd2 wb4 sameas1 sameas2 sameas3 if (fd2 == 1 & wb4 <5 & wb4 !=.) | ///
		(fd2 == 1 & sameas1 <5 & sameas1 !=.) | (fd2 == 1 & sameas2 <5 & sameas2 !=.) | (fd2 == 1 & sameas3 <5 & sameas3 !=.) 

		// fdcc2
		br sampleid fdcc1 fd2 wb4 sameas1 sameas2 sameas3 if (fd2 == 2 & wb4 >5 & wb4 !=.) | ///
		(fd2 == 2 & sameas1 >5 & sameas1 !=.) | (fd2 == 2 & sameas2 >5 & sameas2 !=.) | (fd2 == 2 & sameas3 >5 & sameas3 !=.) 
		*/
		drop if checkedforaccuracy==0
		
		drop checkedforaccuracy 
		br
		
	// make labels match for sbd
		gen wb_npi1 =npi1 if wb==1
		gen wb_npi2 =npi2 if wb==1
		gen wb_npi3 =npi3 if wb==1
		gen wb_npi4 =npi4 if wb==1
		gen wb_npi5 =npi5 if wb==1
		gen wb_npi6 =npi6 if wb==1
		gen wb_npi7 =npi7 if wb==1
		gen wb_npi8 =npi8 if wb==1
		gen wb_npi9 =npi9 if wb==1
		gen wb_npi10 =npi10 if wb==1
		gen wb_npi11 =npi11 if wb==1
		gen wb_npi12 =npi12 if wb==1
		gen wb_npi13 =npi13 if wb==1
		gen wb_npi14 =npi14 if wb==1
		gen wb_n3k =n3k if wb==1
		gen wb_rpi1 =rpi1 if wb==1
		gen wb_rpi2 =rpi2 if wb==1
		gen wb_pi5 =pi5 if wb==1
		gen wb_ap1 =ap1 if wb==1
		gen wb_ap2 =ap2 if wb==1
		gen Design_Team_Influence = . if wb==1 & dt_interview!=1
			//replace Design_Team_Influence=((wb_dtpi6+wb_dtpi7+wb_dtpi8) / 3) + wb_dtml2 + ((wb_dtnm2+wb_dtnm3+wb_dtnm4)/3) if wb==1 and dt_interview==1 // keep unsed until we have completed one of these interviews
		order Design_Team_Influence, after(dt_interview)
		
		gen sa_meas1 = sameas1
		gen sa_meas2 = sameas2
		gen sa_meas3 = sameas3 
		gen sa1_meas1 = sa1
		gen sa2_meas1 = sa2
		gen sa1_meas2 = sa1 if d1 ==1 & multimeas==2 & meas2 != ""
		gen sa2_meas2= sa2 if d1 ==1 & multimeas==2 & meas2 != ""
		gen sa1_meas3 = sa1 if d1 ==1 & multimeas==2 & meas3 != ""
		gen sa2_meas3 = sa2 if d1 ==1 & multimeas==2 & meas3 != ""

		gen sa_npi1_meas1 =npi1 if sys==1
		gen sa_npi2_meas1 =npi2 if sys==1
		gen sa_npi3_meas1 =npi3 if sys==1
		gen sa_npi4_meas1 =npi4 if sys==1
		gen sa_npi5_meas1 =npi5 if sys==1
		gen sa_npi6_meas1 =npi6 if sys==1
		gen sa_npi7_meas1 =npi7 if sys==1
		gen sa_npi8_meas1 =npi8 if sys==1
		gen sa_npi9_meas1 =npi9 if sys==1
		gen sa_npi10_meas1 =npi10 if sys==1
		gen sa_npi11_meas1 =npi11 if sys==1
		gen sa_npi12_meas1 =npi12 if sys==1
		gen sa_npi13_meas1 =npi13 if sys==1
		gen sa_npi14_meas1 =npi14 if sys==1
		gen sa_n3k_meas1 =n3k if sys==1
		gen sa_rpi1_meas1 =rpi1 if sys==1
		gen sa_rpi2_meas1 =rpi2 if sys==1
		gen sa_pi5_meas1 =pi5 if sys==1
		gen sa_ap1_meas1 =ap1 if sys==1
		gen sa_ap2_meas1 =ap2 if sys==1

		gen sa_npi1_meas2 =npi1 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi2_meas2 =npi2 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi3_meas2 =npi3 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi4_meas2 =npi4 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi5_meas2 =npi5 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi6_meas2 =npi6 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi7_meas2 =npi7 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi8_meas2 =npi8 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi9_meas2 =npi9 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi10_meas2 =npi10 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi11_meas2 =npi11 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi12_meas2 =npi12 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi13_meas2 =npi13 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_npi14_meas2 =npi14 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_n3k_meas2 =n3k if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_rpi1_meas2 =rpi1 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_rpi2_meas2 =rpi2 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_pi5_meas2 =pi5 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_ap1_meas2 =ap1 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""
		gen sa_ap2_meas2 =ap2 if sys==1 & d1 ==1 & multimeas==2 & meas2 != ""

		gen sa_npi1_meas3 =npi1 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi2_meas3 =npi2 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi3_meas3 =npi3 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi4_meas3 =npi4 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi5_meas3 =npi5 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi6_meas3 =npi6 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi7_meas3 =npi7 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi8_meas3 =npi8 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi9_meas3 =npi9 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi10_meas3 =npi10 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi11_meas3 =npi11 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi12_meas3 =npi12 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi13_meas3 =npi13 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_npi14_meas3 =npi14 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_n3k_meas3 =n3k if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_rpi1_meas3 =rpi1 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_rpi2_meas3 =rpi2 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_pi5_meas3 =pi5 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_ap1_meas3 =ap1 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
		gen sa_ap2_meas3 =ap2 if sys==1 & d1 ==1 & multimeas==2 & meas3 != ""
	
		gen ciac_nsbd = 0
			replace ciac_nsbd = 1 if rigor ==3 &sbd==0
		
		gen wb_dtintrob = ""
		gen wb_dtintro0b = ""
		gen wb_dtintro2b = ""
		gen wb_dtpi1 = .
		gen wb_dtpi2 = .
		gen wb_dtpi3 = .
		gen wb_dtpi4 = .
		gen wb_dtpi5 = .
		gen wb_dtpi5a = ""
		gen wb_dtpi6 =.
		gen wb_dtpi7 =.
		gen wb_dtpi8 =.
		gen wb_dtml1 =.
		gen wb_dtml1a =.
		gen wb_dtml1b =.
		gen wb_dtml2 =.
		gen wb_dtml2a =""
		gen wb_dtnm2 =.
		gen wb_dtnm3 =.
		gen wb_dtnm4 =.
		gen wb_dtp1 = ""
		gen wb_dtp2 = ""
		gen wb_dtp3 = .
		gen wb_dtp3b = ""
		gen wb_dtp4 = ""
		gen wb_dtlt1 = .
		gen wb_dtlt2 = ""
		gen wb_dtlt3 = ""
		gen sa_date_meas1 = meas_1_date if sys==1
		gen sa_date_meas2 = meas_2_date if sys==1
		gen sa_date_meas3 = meas_3_date if sys==1
		gen sa_claimid1 = ClaimId1 if sys==1
		gen sa_claimid2 = ClaimId2 if sys==1
		gen sa_claimid3 = ClaimId3 if sys==1
		
		rename pi7pi7a_openend pi7a_openend
		
		order completed sampleid sbw_projid contact business meas1 ClaimId1 meas_1_date ///
		sector rigor multimeas multiaddr sbd ciac_nsbd wb sys obf dt intro1 intro2 intro3 ///
		intro3_name intro3_phone intro3_email intro3_role intro3_department intro4 ///
		intro4_openend incent1 a1gg pi1 pi3 pi3a pi4 pi6 pi6_openend pi7 pi7a pi7a_openend ///
		obf1 d1 fdintro fdintro_openend fd1 fd1_openend fd2 fd2_openend fd3 fdcc1 ///
		fdcc1_openend fdcc2 fdcc2_openend n3kk1 n3kk2 fin0 fin1 fin11 fin12 fin13 ///
		fin7 fin7_1 fin7_2 fin7_3 fin8 fin8_1 fin8_2 fin8_3 npi14_openend ap1a ap2_openend ///
		ap2a ap2b apcc1 apcc2 p1 p2 p3 p4 lt1 lt2 lt3 wb1 wb1a wb2 wb2a wb3 ///
		wb3_openend wbcc1 wb4 wb4a wb5 wb5a  wb_n3k wb_npi1 wb_npi2 wb_npi3 wb_npi4 wb_npi5 ///
		wb_npi6 wb_npi7 wb_npi8 wb_npi9 wb_npi10 wb_npi11 wb_npi12 wb_npi13 wb_npi14 ///
		wb_rpi1 wb_rpi2 wb_pi5 wb_ap1 wb_ap2 wb_dtpi6 wb_dtpi7 wb_dtpi8 wb_dtml2 wb_dtnm2 ///
		wb_dtnm3 wb_dtnm4 sa_meas1 sa_claimid1 sa_date_meas1 sa1_meas1 sa2_meas1 ///
		sa_npi4_meas1 sa_n3k_meas1 sa_npi1_meas1 sa_npi2_meas1 sa_npi3_meas1 sa_npi5_meas1 ///
		sa_npi6_meas1 sa_npi7_meas1 sa_npi8_meas1 sa_npi9_meas1 sa_npi10_meas1 ///
		sa_npi11_meas1 sa_npi12_meas1 sa_npi13_meas1 sa_npi14_meas1 sa_rpi1_meas1 ///
		sa_rpi2_meas1 sa_pi5_meas1 sa_ap1_meas1 sa_ap2_meas1 sa_meas2 sa_claimid2 ///
		sa_date_meas2 sa1_meas2 sa2_meas2  sa_npi4_meas2 sa_n3k_meas2 sa_npi1_meas2 ///
		sa_npi2_meas2 sa_npi3_meas2 sa_npi5_meas2 sa_npi6_meas2 sa_npi7_meas2 sa_npi8_meas2 ///
		sa_npi9_meas2 sa_npi10_meas2 sa_npi11_meas2 sa_npi12_meas2 sa_npi13_meas2 ///
		sa_npi14_meas2 sa_rpi1_meas2 sa_rpi2_meas2 sa_pi5_meas2 sa_ap1_meas2 sa_ap2_meas2 ///
		sa_meas3 sa_claimid3 sa_date_meas3 sa1_meas3 sa2_meas3 sa_npi4_meas3 sa_n3k_meas3 ///
		sa_npi1_meas3 sa_npi2_meas3 sa_npi3_meas3 sa_npi5_meas3 sa_npi6_meas3 sa_npi7_meas3 ///
		sa_npi8_meas3 sa_npi9_meas3 sa_npi10_meas3 sa_npi11_meas3 sa_npi12_meas3 sa_npi13_meas3 ///
		sa_npi14_meas3 sa_rpi1_meas3 sa_rpi2_meas3 sa_pi5_meas3 sa_ap1_meas3 sa_ap2_meas3
		
				// Fix survey labels
				do "$syntax/CIAC Enhanced Survey Labels.do"

		drop dt_interview Design_Team_Influence p3moreexplanation meas2 meas_2_date meas3 meas_3_date pa program 
		drop npi1 npi2 npi3 npi4 npi5 npi6 npi7 npi8 npi9 npi10 npi11 npi12 npi13 npi14 sameas1 sameas2 sameas3 sa1 sa2 n3k pi5 ap1 ap2 rpi1 rpi2
		
		mvdecode _all, mv(-99)
		mvdecode _all, mv(-98)
		mvdecode _all, mv(-96)
		
				
		foreach var of varlist pi6_openend pi7a_openend incent1 wb1a wb2a wbcc1 wb4a wb5a fd1 fdcc1 fdcc1_openend  fdcc2_openend ap1a ap2a ap2b apcc1 apcc2 p1 p2  p4 lt2 lt3{
				replace `var' = "" if  `var' == "-99"|`var' == "-98"|`var' == "-96"
			}		
		drop  completed
		
		// these are differener questions from the other surveys
		rename (lt1 lt2 lt3 ) (sbd_lt1 sbd_lt2 sbd_lt3)
		
		// fix obf flag
		drop obf
		gen obf= intro1==1
		
	_strip_labels _all
		tostring _all, replace
				tostring wb_npi6, force replace
				replace wb_npi6="9.8" if sampleid=="162"
		foreach var of varlist * {
				replace `var' = "" if  `var' == "-999"|`var' == "-998"|`var' == "-996"|`var' == "-99"|`var' == "-98"|`var' == "-96"|`var' == "99"|`var' == "98"|`var' == "96"|`var' == "NA"|`var' == "N/A"
			}
		replace ClaimId2 ="" if sys=="1"
		replace ClaimId3 ="" if sys=="1"
			
		save "$work/ciac_sbd_completes.dta", replace
		// Save

		
		
/* GO TO THE NON_SBD FOR UPDATED VERSION
		// Append enhanced non-SBD and SBD data
		use "$work/ciac_sbd_completes.dta", clear
		//append using "$raw/ciac_nonsbd_enhanced.dta", force  /////////////////// LEFT OFF HERE!!!!!
		merge 1:1 sbw_projid using "$raw\ciac_nonsbd_enhanced.dta", update
		
		
		save "$work/ciac_enhanced_completes_cleaned_1_29_2020_clean.dta", replace
		// Save

		use "$work/ciac_enhanced_completes_cleaned_1_29_2020_clean.dta", clear
		export excel using "$work/ciac_enhanced_completes_cleaned_1_29_2020_clean.xlsx", sheet("Survey Data") sheetreplace firstrow(variables)

		//export variables and variable labels
		use "$work/ciac_enhanced_completes_cleaned_1_29_2020_clean.dta", clear
		describe, replace clear
		drop type isnumeric format vallab
		export excel using "$work/ciac_enhanced_completes_cleaned_1_29_2020_clean.xlsx", sheet("Variable Dictionary") firstrow(variables) sheetreplace
*/
/*	GO TO THE NON_SBD FOR UPDATED VERSION
	*************************************************************
	// Merge Basic, Standard, and Enhanced Together
	*************************************************************
	use "$work/ciac_sbd_completes.dta", clear
	
	// Append enhanced non-SBD 
	append using "$work/ciac_PMR_completes_cleaned_1_24_2020.dta", force
	append using "$raw/ciac_nonsbd_enhanced.dta", force 
	order ClaimId1, before(aa3_meas1_1)
	replace sbd = 0 if ciac_nsbd == 1
	drop caseid
	// Save
	save "$work/ciac_all_completes.dta", replace
	
	export delimited using "$work\ciac_all_completes.csv", nolabel replace
	drop complete_date
	merge 1:1 sbw_projid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\Dispositions\CIAC_Net Survey Dispositions.dta"
		
	gen pending_QC = 1 if (disposition== "Complete" | disposition=="COMPLETE") & completed==.
	keep completed sampleid sbw_projid RECRUIT PRETEST RIGOR DO_NOT_CONTACT type numofattempts complete_date disposition pending_QC
	order sampleid sbw_projid RECRUIT PRETEST RIGOR DO_NOT_CONTACT type numofattempts complete_date disposition pending_QC completed
	drop DO_NOT_CONTACT completed
	replace complete_date="" if strpos(disposition,"SCHE")|strpos(disposition,"DROPPED")
	export delimited using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\Dispositions\CIAC_Net Survey Dispositions_QC flag.csv", replace
*/
