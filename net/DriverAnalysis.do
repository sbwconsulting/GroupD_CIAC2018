/***************************************
Created By: Katherine Randazzo
Creation Date: 2020-02-14

Last Modified By: Katherine Randazzo
Modified Date: 2020--

This is code to prepare the sample for CIAC 2018 net driver analysis

THIS IS TO CREATE VARIABLES SUITABLE FOR ANALYSIS
*********************************************************************************/
set maxvar 25000

// Set Useful Folder Paths
global main "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files\"
global work "$main\Working Files"
global syntax "$main\Syntax"
global map "$main\Mapping Files"
global qc "$main\QC_Outputs"
global fin "$main\Final_Outputs"
global af "$main\Analysis Files"
global raw "$main\_Enhanced\SBD Survey Instrument- Excel"
global claims "$work\ClaimId Level"
exit

use "$main\CIAC data by claimid all.dta", clear
use "$main\CIAC data by claimid all-driver.dta", clear

***********************   candidate variables for different surveys  **********************************************************************

Non-SBD								SBD: Whole Building: Owner										SBD: System: Owner
htr (1=hard to reach; 0=otherwise)	htr (1=hard to reach; 0=otherwise)								htr (1=hard to reach; 0=otherwise)
ex post gross savings (MMBtu)		ex post gross savings (MMBtu)									ex post gross savings (MMBtu)
numb_meas (number of measures)		numb_meas (number of measures)									numb_meas (number of measures)
incentive (amount of incentive)		incentive (amount of incentive)									incentive (amount of incentive)
multimeas							multimeas														multimeas
sector								sector															sector
a1b									intro1															incent1
n2									design_team (1=yes; 0=no)										intro1
n3a									sector (1=industrial; 2=other)									pi1
n3b									mult (1=one measure; 2=more than one measure					pi3
n3c									mult_addr (1=one address, 2=more than one address)				pi5
n3d									Incent1 (percent of project cost covered by the incentive)		pi6
n3e									pi1																pi7a
n3f									pi3																obf1_meas1
n3g									pi5																d1
n3h									pi6																
n3i									pi7a															sa1_meas1
n3j									obf1															sa2_meas1
n3k									wb1																sa_npi1	
FIN0								wb2																sa_npi2	
n3l									wb3																sa_npi3
n3m									wb4																sa_npi5
n3n									wb5																sa_npi6
n3o									wb_npi_1														sa_npi7
n3p									wb_npi_2														sa_npi81
n3q									wb_npi_3														sa_npi9
n3r									wb_npi_4														sa_npi10
n3s									wb_npi_5														sa_npi11
n3t_1_01							wb_npi_6														sa_npi12
p3_1								wb_npi_7														sa_npi13
p4_1								wb_npi_8														sa_npi14
cp1_1								wb_npi_9														fd2
CP3									wb_npi_10														fd3
sp1_1								wb_npi_11														sa_n3k
sp2_1								wb_npi_12														fino
sp3a_1								wb_npi_13														fin1
cc12a								wb_npi_14														fin8
cc12b								fd2																lt1
co									fd3																lt2
ccc1								wb_n3k															lt3
ccc3								fin0	
c1									fin8	
c1_response							lt1	
c2									lt2	
c3									lt3	
c3a		
********************************************Exploration CIAC variables*********************************************************
tab1  v1 v1a_01 v1a_02 v1a_03 v2 v2a v2aa v2b v3 v4 v4b v40 	
tab1 meas multimeas	sector intro1 dt incent1 a1b n2	n3a	n3b	n3c	
tab1 n3d n3e n3f n3g n3h n3i n3j n3k n3l n3m n3n n3o n3p n3q n3r n3s n3t_1	
tab1 p3 p4 cp1 cp3 sp1 sp2 fin0	
tab1 sp3a cc12a	cc12b co ccc1 ccc3 c1 c1_response c2 c3	c3a

********************************************Exploration SBD-WB variables****************************
tab1 meas multimeas	sector intro1 dt incent1
tab1 pi1 pi3 pi4 pi6 pi7a obf1 wb1 wb2 wb3 wb4 wb5 wb_npi1 wb_npi2 wb_npi3 wb_npi4 wb_npi5 wb_npi6
tab1 wb_npi7 wb_npi8 wb_npi9 wb_npi10 wb_npi11 wb_npi12 wb_npi13 wb_npi14 fd2 fd3 wb_n3k fin0 fin8
	
*******************************************Exploration SBD-SA variables***********************************************
tab1 meas multimeas sector intro1 dt incent1 dt  pi1 pi3 pi4 pi6 pi7a obf1 d1	 
tab1 sa1 sa2 sa_npi1 sa_npi2 sa_npi3 sa_npi5 sa_npi6 sa_npi7	
tab1 sa_npi8 sa_npi9 sa_npi10 sa_npi11 sa_npi12 sa_npi13 sa_npi14 fd2 fd3 sa_n3k
tab1 fin0 fin1 fin8
*******************************************Creating Analysis Variables***********************************************************
***placeholder path: use "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop-ntgrs-kvr.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files\CIAC data by claimid all-driver.dta"
gen findven=0
replace findven=1 if v2==2
gen vencont=0
replace vencont=1 if v2==1
gen venhist=0
replace venhist=1 if v2aa==3
gen venpa=0
replace venpa=1 if v2aa==1
label variable findven "We contacted them"
label variable vencont "Vendor contacted us"
label variable venhist "We have worked with them before"
label variable venpa "The vendor came from the PA"
tab1 findven - venpa

egen veninfluence=rowmax(v2b v4a v4b)
egen reas_replace=anymatch(aa3_1 - aa3_7), v(1)
egen reas_remodel=anymatch(aa3_1 - aa3_7), v(2)
egen reas_comply=anymatch(aa3_1 - aa3_7), v(3,4)
egen reas_rebate=anymatch(aa3_1 - aa3_7), v(5)
egen reas_costofold=anymatch(aa3_1 - aa3_7), v(6)
egen reas_perform=anymatch(aa3_1 - aa3_7), v(7)
egen reas_savenergy=anymatch(aa3_1 - aa3_7), v(8)
label variable veninfluence "Planned to install this before vendor"
label variable reas_replace "Installed equip bec equip old"
label variable reas_remodel "Installed as part of remodel"
label variable reas_comply "Installed to comply with company or ISP"
label variable reas_rebate "Installed to get the rebate"
label variable reas_costofold "Installed bec cost of old equip too high"
label variable reas_perform "Installed to improve performance"
label variable reas_savenergy "Installed to save energy"
tab1 veninfluence - reas_savenergy

gen before=0
replace before=1 if n2==1
gen after=0
replace after=1 if n2==2
recode cc12a (1852/1950=1)(1951/1963=2)(1964/1984=3)(1985/2013=4)(2014/2018=5)(missing=3), generate(busestab)
recode co (1=1)(2=2)(3=3)(4=4)(5=5)(6=6)(7=7)(8=8)(missing=4), generate(pctopcost)
recode c3a (1=1)(2 3 4=2)(5=3)(missing=2), generate(nlocations)
recode v1 (1=1)(else=0), generate(usedvendor)
recode c6 (1=1)(else=0), generate(partof)
recode a3 (1=1)(else=0), generate(pastproj)
recode multimeas (1=1)(else=0), generate(multiplemeas)
recode obf1 (1=1)(else=0), generate(onbillfin)
label variable before "Installed equip before aware of rebate"
label variable after "Installed equip after learning of rebate"
label variable busestab "When the business was established"
label variable pctopcost "Energy is what % of operating costs"
label variable nlocations "Number of locations business occupies"
label variable usedvendor "Did you use a vendor or contractor to install any equip?"
label variable partof "Was this part of larger effort with multiple related projects?"
label variable pastproj "Have you installed similar projects here or in CA in the past?"
label variable multiplemeas "Did you installed multiple measures in this project?"
label variable onbillfin "Before learning about this program, research financing options?"
*label define busestab 1 "1852-1940"  2 "1951 - 1963"  3 "1964 - 1984"  4 "1985 - 2013"  5 "2014 - 2019"
*label define pctopcost 1 "Energy < 1% op costs"  2 Energy "1 - 2% op costs" 3 "Energy 3-5% op costs" 4 Energy 6-10% op costs" 5 Energy "11-15% op costs" 6 "Energy 16-20% op costs" 7 "Energy 21-50% op costs" 8 "Energy over 51% op costs"
*label define nlocations 1 "1 Location"  2 "2-4 Locations"  3 "5-10 Locations"  4 "11-25 Locations"  5 "Over 25 Locations" 
tab1 before - onbillfin

recode n3a (missing=0), generate(condoldequip)
recode n3b (missing=0), generate(rebateavail)
recode n3c (missing=0), generate(feastudy)
recode n3d (missing=0), generate(venrec)
recode n3e (missing=0), generate(prevee)
recode n3f (missing=0), generate(prevprog)
recode n3g (missing=0), generate(training)
recode n3h (missing=0), generate(mktmaterials)
recode n3i (missing=0), generate(engrec)
recode n3j (missing=0), generate(isp)
recode n3k (missing=0), generate(obfavail)
recode n3l (missing=0), generate(reprec)
recode n3m (missing=0), generate(intpolicy)
recode n3n (missing=0), generate(payroi)
recode n3o (missing=0), generate(impquality)
recode n3p (missing=0), generate(regcompliance)
recode n3q (missing=0), generate(outsideassis)
recode n3r (missing=0), generate(replacepol)
recode n3s (missing=0), generate(parec)
recode n5b (missing=0), generate(timing)
recode n5  (missing=0), generate(exactsame)
recode n6  (missing=0), generate(withoutprog)
tab1 partof - timing

recode condoldequip (8/10 = 1)(else=0), generate(condoldequip_bi)
recode rebateavail (8/10 = 1)(else=0), generate(rebateavail_bi)
recode feastudy (8/10 = 1)(else=0), generate(feastudy_bi)
recode venrec (8/10 = 1)(else=0), generate(venrec_bi)
recode prevee (8/10 = 1)(else=0), generate(prevee_bi)
recode prevprog (8/10 = 1)(else=0), generate(prevprogp_bi)
recode training (8/10 = 1)(else=0), generate(training_bi)
recode mktmaterials (8/10 = 1)(else=0), generate(mktmaterials_bi)
recode engrec (8/10 = 1)(else=0), generate(engrec_bi)
recode isp (8/10 = 1)(else=0), generate(isp_bi)
recode obfavail (8/10 = 1)(else=0), generate(obfavail_bi)
recode reprec (8/10 = 1)(else=0), generate(reprec_bi)
recode intpolicy (8/10 = 1)(else=0), generate(intpolicy_bi)
recode payroi (8/10 = 1)(else=0), generate(payroi_bi)
recode impquality (8/10 = 1)(else=0), generate(impquality_bi)
recode regcompliance (8/10 = 1)(else=0), generate(regcompliance_bi)
recode outsideassis (8/10 = 1)(else=0), generate(outsideassis_bi)
recode replacepol (8/10 = 1)(else=0), generate(replacepol_bi)
recode parec (8/10 = 1)(else=0), generate(parec_bi)
recode timing (8/10 = 1)(else=0), generate(timing_bi)
recode exactsame (8/10=1)(else=0), generate(exactsame_bi)
recode n6 (5 = 1)(else=0), generate(n6_bi)
tab1 condoldequip_bi - n6_bi

egen sbdincentive = rowmax(wb4 wb5 sa_meas)
egen sbdrepassist = rowmax(wb3 sa1)
egen sbdtechassist = rowmax(wb1 wb2 sa2)
egen sbdpayroi = rowmax(wb_npi4 sa_npi4)
egen sbdobf = rowmax(wb_n3k sa_n3k)
recode sbdincentive (missing=0)
recode sbdrepassis (missing=0)
recode sbdtechassist (missing=0)
recode sbdpayroi (missing=0)
recode sbdobf (missing=0)
tab1 sbdincentive sbdrepassis sbdtechassist sbdpayroi sbdobf


tab1 condoldequip_bi - n6_bi


