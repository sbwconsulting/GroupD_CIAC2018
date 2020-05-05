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

use "$work/ciac_all_completes.dta", clear


// Awareness

		// SBD= pi4
			gen pi4_rec = 11 if strpos(pi4,"We just always have")|strpos(pi4,"past")|strpos(pi4,"previous")| ///
					strpos(pi4,"for many years")|strpos(pi4,"Been using the program")|strpos(pi4,"SBD before")|strpos(pi4,"since 2008") ///
					|strpos(pi4,"other projects")|strpos(pi4,"internal requirement")|strpos(pi4,"aware of the SBD")|strpos(pi4,"mandated") ///
					|strpos(pi4,"about 20 years")|strpos(pi4,"for years")|strpos(pi4,"continued participating")|strpos(pi4,"on other projects")
				replace pi4_rec = 5 if strpos(pi4,"SoCal Edison")|strpos(pi4,"PGE rep")|strpos(pi4,"Their consultant")|strpos(pi4,"PGE talked") ///
					|strpos(pi4,"Peggy Crossman")|strpos(pi4,"SDGE came to us")
				replace pi4_rec = 3 if strpos(pi4,"ccount rep")|strpos(pi4,"our rep")|strpos(pi4,"SDG&E rep")|strpos(pi4,"SDG&E brought")| ///
					strpos(pi4,"SCE was called")|strpos(pi4,"program manager")
				replace pi4_rec = 13 if strpos(pi4,"rchitect")
				replace pi4_rec = 98 if strpos(pi4,"The cbo")
				replace pi4_rec = 99 if pi4=="" & sbd==1
				replace pi4_rec = 0 if pi4!="" & pi4_rec==.

			label define pi4_label 0 "Other" ///
				1 "Bill Insert" ///
				2 "Program Literature" ///
				3 "Account Representative" ///
				4 "Program Approved Vendor" ///
				5 "Program Representative" ///
				6 "Utility or Program Website" ///
				7 "Trade Publication" ///
				8 "Conference" ///
				9 "Newspaper Article" ///
				10 "Word of Mouth" ///
				11 "Previous Experience with It" ///
				12 "Company Used It at Other Locations" ///
				13 "Contractor" ///
				14 "Result of An Audit" ///
				15 "Part of a Larger Expansion or Remodeling Effort" ///
				98 "Don't Know" ///
				99 "Refused", replace
				capture label values pi4_rec pi4_label	
				
				tab pi4_rec
				
				
				/*		
												pi4_rec |      Freq.     Percent        Cum.
				----------------------------------------+-----------------------------------
												  Other |          5        9.62        9.62
								 Account Representative |         11       21.15       30.77
								 Program Representative |          7       13.46       44.23
							Previous Experience with It |         22       42.31       86.54
											 Contractor |          5        9.62       96.15
											 Don't Know |          1        1.92       98.08
												Refused |          1        1.92      100.00
				----------------------------------------+-----------------------------------
												  Total |         52      100.00
				*/
				
		//Non-sbd= ap9
			gen ap9_rec= ap9
				replace ap9_rec = 10 if strpos(ap9_other,"customer of my")|strpos(ap9_other,"my partners")
				replace ap9_rec = 5 if strpos(ap9_other,"PG&E Rep")|strpos(ap9_other,"hired by PG")|strpos(ap9_other,"SCE")|strpos(ap9_other,"Consultant")
				replace ap9_rec = 3 if strpos(ap9_other,"ccount")
				replace ap9_rec = 4 if strpos(ap9_other,"vendor")
				replace ap9_rec = 11 if strpos(ap9_other,"long time")|strpos(ap9_other,"required us")|strpos(ap9_other,"revious")|strpos(ap9_other,"45 years")
				replace ap9_rec = 13 if strpos(ap9_other,"ontractor")

			gen ap9_other_rec = ap9_other 
				replace ap9_other_rec="" if ap9_rec!=0

			label define ap9VL 0 "Other" ///
				1 "Bill Insert" ///
				2 "Program Literature" ///
				3 "Account Representative" ///
				4 "Program Approved Vendor" ///
				5 "Program Representative" ///
				6 "Utility or Program Website" ///
				7 "Trade Publication" ///
				8 "Conference" ///
				9 "Newspaper Article" ///
				10 "Word of Mouth" ///
				11 "Previous Experience with It" ///
				12 "Company Used It at Other Locations" ///
				13 "Contractor" ///
				14 "Result of An Audit" ///
				15 "Part of a Larger Expansion or Remodeling Effort" ///
				98 "Don't Know" ///
				99 "Refused", replace
				capture label values ap9_rec ap9VL		
				
			tab ap9_rec if sbd!=1

			tab ap9_other_rec if ap9_other_rec!=" " & ap9_other_rec!=""


				/*
												ap9_rec |      Freq.     Percent        Cum.
				----------------------------------------+-----------------------------------
												  Other |         28       13.93       13.93
								 Account Representative |         45       22.39       36.32
								Program Approved Vendor |          5        2.49       38.81
								 Program Representative |         51       25.37       64.18
							 Utility or Program Website |         11        5.47       69.65
											 Conference |          2        1.00       70.65
										  Word of Mouth |         10        4.98       75.62
							Previous Experience with It |         30       14.93       90.55
					 Company Used It at Other Locations |          2        1.00       91.54
											 Contractor |         17        8.46      100.00
				----------------------------------------+-----------------------------------
												  Total |        201      100.00
				*/
				
// Process

		// SBD= p1-p4
			
			// Strengths
			gen p1_rec =1 if strpos(p1,"esign analysis")|strpos(p1,"esign assistance")|strpos(p1,"facilities people to look at") ///
				|strpos(p1,"process between")|strpos(p1,"assist design")|strpos(p1,"preliminary design")|strpos(p1,"design review") ///
				|strpos(p1,"initial consultation")|strpos(p1,"working with the Ed")|strpos(p1,"set of eyes") ///
				|strpos(p1,"consultant help us")|strpos(p1,"designing to be")|strpos(p1,"working with the engin") ///
				|strpos(p1,"with the process")|strpos(p1,"some direction")|strpos(p1,"supported")|strpos(p1,"communications")
				replace p1_rec =2 if strpos(p1,"incentive")|strpos(p1,"funding")|strpos(p1,"cost sav")|strpos(p1,"money")
				replace p1_rec =3 if strpos(p1,"educate")|strpos(p1,"about Energy effici")|strpos(p1,"raised awareness") 
				replace p1_rec =4 if strpos(p1,"to be EE")|strpos(p1,"realize savings")|strpos(p1,"sustainability")|strpos(p1,"most efficient") ///
				|strpos(p1,"exists to be")
				replace p1_rec =99 if strpos(p1,"believe that it")
				
			label define p1VL 0 "Other" ///
				1 "Design anaylsis and assisteance" ///
				2 "Financial incentives" ///
				3 "Education" ///
				4 "Reduce Enegry Consumption and Bills" ///
				99 "None" , replace
				capture label values p1_rec p1VL
				
				tab p1_rec

				/*                           p1_rec |      Freq.     Percent        Cum.
				------------------------------------+-----------------------------------
					Design anaylsis and assisteance |         17       34.00       34.00
							   Financial incentives |         19       38.00       72.00
										  Education |          3        6.00       78.00
				Reduce Enegry Consumption and Bills |          6       12.00       90.00
											   None |          5       10.00      100.00
				------------------------------------+-----------------------------------
											  Total |         50      100.00
				*/				
				
			// Concerns

				
			// Overall satisfaction
			
			tab p3
				/*      sat |      Freq.     Percent        Cum.
				------------+-----------------------------------
						  5 |          3        5.88        5.88
						  6 |          6       11.76       17.65
						  7 |          6       11.76       29.41
						  8 |         10       19.61       49.02
						8.5 |          1        1.96       50.98
						  9 |          7       13.73       64.71
						 10 |         18       35.29      100.00
				------------+-----------------------------------
					  Total |         51      100.00

				--------------------------------------------------------------
							 |       Mean   Std. Err.     [90% Conf. Interval]
				-------------+------------------------------------------------
						  p3 |   8.323529   .2265788      7.943805    8.703254
				--------------------------------------------------------------				  
				*/
			
			// Recommendations
			
		
		// Non- SBD= pp1-5

			// Strengths
			gen pp1_rec =1 if strpos(pp1_response,"esign analysis")|strpos(pp1_response,"esign assistance")|strpos(pp1_response,"facilities people to look at") ///
				|strpos(pp1_response,"ommunication")|strpos(pp1_response,"projects they do")|strpos(pp1_response,"research") ///
				|strpos(pp1_response,"validating ener")|strpos(pp1_response,"available equip")|strpos(pp1_response,"nowledge") ///
				|strpos(pp1_response,"equipment")|strpos(pp1_response,"echnolo")|strpos(pp1_response,"guidance")|strpos(pp1_response,"indentification") ///
				|strpos(pp1_response,"analysis")|strpos(pp1_response,"information")|strpos(pp1_response,"helped us do") ///
				|strpos(pp1_response,"omprehensive")|strpos(pp1_response,"creative")|strpos(pp1_response,"advising") ///
				|strpos(pp1_response,"way it was executed")|strpos(pp1_response,"executing") ///
				|strpos(pp1_response,"identificationj")|strpos(pp1_response,"scope of the projest")
				replace pp1_rec =2 if strpos(pp1_response,"incentive")|strpos(pp1_response,"fund")|strpos(pp1_response,"ffordability") ///
				|strpos(pp1_response,"large capital")|strpos(pp1_response,"economically")|strpos(pp1_response,"ebate") ///
				|strpos(pp1_response,"oney savings")|strpos(pp1_response,"costs")|strpos(pp1_response,"ROI")|strpos(pp1_response,"on invest") ///
				|strpos(pp1_response,"business owners")|strpos(pp1_response,"Money")|strpos(pp1_response,"inancing") ///
				|strpos(pp1_response,"Free")|strpos(pp1_response,"incentivize")|strpos(pp1_response,"simple payback") ///
				|strpos(pp1_response,"reward")|strpos(pp1_response,"economical")|strpos(pp1_response,"incentivise") ///
				|strpos(pp1_response,"capital")|strpos(pp1_response,"help pay")|strpos(pp1_response,"afford") ///
				|strpos(pp1_response,"feasable")|strpos(pp1_response,"financial")|strpos(pp1_response,"budget") ///
				|strpos(pp1_response,"saving money")|strpos(pp1_response,"us to implement")|strpos(pp1_response,"insight") ///
				|strpos(pp1_response,"financial")
				replace pp1_rec =3 if strpos(pp1_response,"educat")|strpos(pp1_response,"raised awareness") ///
				|strpos(pp1_response,"explanation")|strpos(pp1_response,"ducation")
				replace pp1_rec =4 if strpos(pp1_response,"energy bill")|strpos(pp1_response,"nergy conser")|strpos(pp1_response,"nergy saving") ///
				|strpos(pp1_response,"efficiently")|strpos(pp1_response,"reduced demand")|strpos(pp1_response,"been saving") ///
				|strpos(pp1_response,"efficiency")|strpos(pp1_response,"energy use")|strpos(pp1_response,"energy efficient") ///
				|strpos(pp1_response,"reduction")|strpos(pp1_response,"helping the")|strpos(pp1_response,"big impact")
				replace pp1_rec =99 if strpos(pp1_response,"No idea")|strpos(pp1_response,"Nothing")|pp1_response==" "
				replace pp1_rec =0 if pp1_rec==. & pp1_response!=""

			label define p1VL 0 "Other" ///
				1 "Design anaylsis and assistance" ///
				2 "Financial incentives" ///
				3 "Education" ///
				4 "Reduce Enegry Consumption and Bills" ///
				99 "None" , replace
				capture label values pp1_rec p1VL
				
				/*                          pp1_rec |      Freq.     Percent        Cum.
				------------------------------------+-----------------------------------
											  Other |          4        1.97        1.97
				  	 Design anaylsis and assistance |         19        9.36       11.33
							   Financial incentives |        118       58.13       69.46
										  Education |          7        3.45       72.91
				Reduce Enegry Consumption and Bills |         49       24.14       97.04
											   None |          6        2.96      100.00
				------------------------------------+-----------------------------------
											  Total |        203      100.00
				*/				
					
			// Concerns
			
			
			
			// Overall satisfaction
			
			tab pp4
				/*
						pp4 |      Freq.     Percent        Cum.
				------------+-----------------------------------
						  5 |          6        2.91        2.91
						  6 |          2        0.97        3.88
						  7 |         18        8.74       12.62
						  8 |         45       21.84       34.47
						  9 |         59       28.64       63.11
						 10 |         76       36.89      100.00
				------------+-----------------------------------
					  Total |        206      100.00

				--------------------------------------------------------------
							 |       Mean   Std. Err.     [90% Conf. Interval]
				-------------+------------------------------------------------
						 pp4 |   8.830097   .0844328      8.690587    8.969607
				--------------------------------------------------------------
				*/
			
				
// Long Term
			// Lt1- previous participation
			gen lt1_rec= sbd_lt1
				replace lt1_rec =1 if n3f_meas1>-1 &sbd!=1

			label define lt1VL 1 "Yes" ///
				2 "No" , replace
				capture label values lt1_rec lt1VL
				/*
					lt1_rec |      Freq.     Percent        Cum.
				------------+-----------------------------------
						Yes |        244       93.85       93.85
						 No |         16        6.15      100.00
				------------+-----------------------------------
					  Total |        260      100.00
				*/

			// Long term influence Lt2 and Lt8
		
			//tab lt2_rec /// on the sbd dataset
			
				/*  lt2_rec |      Freq.     Percent        Cum.
				------------+-----------------------------------
						  1 |         30       60.00       60.00
						  2 |         20       40.00      100.00
				------------+-----------------------------------
					  Total |         50      100.00
				*/
			
			tab lt8
			
			label define lt8VL 1 "Yes" ///
				2 "No" , replace
				capture label values lt8 lt8VL
				
				/*      lt8 |      Freq.     Percent        Cum.
				------------+-----------------------------------
						  1 |         68       71.58       71.58
						  2 |         27       28.42      100.00
				------------+-----------------------------------
					  Total |         95      100.00
				*/
			


		