/***************************************
Created By: Katherine Randazzo
Creation Date: 2020-02-14

Last Modified By: Katherine Randazzo
Modified Date: 2020-08-03

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
 import excel "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop-ntgrs-kvr.xlsx", sheet("claimpop") firstrow clear
use "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop-ntgrs-kvr.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Survey Data\Working Files\CIAC data by claimid all.dta", clear
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\CIAC data by claimid all-driver.dta"
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

order claimid, after(sampleid)
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\CIAC data by claimid all-driver.dta" , replace
*********************************************PREP OF CLAIMPOP DATA FOR NTGR ANALYSIS******************************************
save  "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop030620-kvr.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop030620-kvr.dta"
keep SampleID  ClaimID  SiteID  PrgID	 ImplementationPA  TotalFirstYearGrossTherm  Sector ///
 BldgVint BldgHVAC DeliveryType ///
 DeliveryType  BldgLoc	TotalFirstYearGrosskWh  TotalLifecycleGrosskWh  TotalLifecycleGrossTherm  TechType ///
 EUL_Yrs  RUL_Yrs  RealizationRatekWh  RealizationRateTherm  UseCategory  TotalGrossIncentive  PA  PrimarySector ///
 Financing  SBW_ImpactType  Sampled  Treatment  TotalGrossMeasureCost_Eval  NonEnergyBenefits  HardToReach ///
 ClaimUnweighted_NTGR  RigorkWh  RigorTherm  NetTrack  EvalEUL  EvalRUL  EvalMeasAppType ///
 ss_ExPostLifecycleGrosskWh_raw  ss_ExPostLifecycleGrossthm_raw    ss_ExPostLifecycleGrosskWh ///
 ss_ExPostLifecycleGrossthm  blended_ntgr_kwh  blended_ntgr_thm  EvalExPostLifeCycleNetkWh ///
 EvalExPostLifeCycleNetTherm  ExPost_Annualized_Gross_MMBtu  ExPost_Lifecycle_Gross_MMBtu project_pop 
keep if NetTrack != ""
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop_driver_vars.dta", replace
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop_driver_vars.dta", clear
rename SampleID sampleid
rename ClaimID claimid 
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop_driver_vars.dta", replace

****************MERGE SURVEY DATA ONTO CLAIMPOP DRIVER FILE*************************************************************
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop_driver_vars.dta", clear
merge m:1 claimid using "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\CIAC data by claimid all-driver.dta"
keep if _merge==3
save  "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\NTG Drivers\claimpop_survey.dta", replace
save  "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Drafts\In-Progress\NTGR Driver Analysis\claimpop_survey.dta", replace
**************************************ANALYSIS********************************************
egen ntgr_claim=rowmax(blended_ntgr_kwh blended_ntgr_thm)
tab ntgr_claim

recode ntgr_claim (0/.49=1)(.5/.75=2)(.751/.8939258=3)(.8939259/1=4), generate(ntgr_claim_qtl)
tab ntgr_claim_qtl 

tabulate ntgr_claim_qtl rebateavail_bi, row
tabulate ntgr_claim_qtl feastudy_bi, row
tabulate ntgr_claim_qtl venrec_bi, row
tabulate ntgr_claim_qtl mktmaterials_bi, row
tabulate ntgr_claim_qtl prevee_bi, row
tabulate ntgr_claim_qtl prevprogp_bi, row
tabulate ntgr_claim_qtl training_bi, row
tabulate ntgr_claim_qtl engrec_bi, row
tabulate ntgr_claim_qtl isp_bi, row
tabulate ntgr_claim_qtl obfavail_bi, row
tabulate ntgr_claim_qtl reprec_bi, row
tabulate ntgr_claim_qtl intpolicy_bi, row
tabulate ntgr_claim_qtl payroi_bi, row
tabulate ntgr_claim_qtl impquality_bi, row
tabulate ntgr_claim_qtl regcompliance_bi, row
tabulate ntgr_claim_qtl outsideassis_bi, row
tabulate ntgr_claim_qtl replacepol_bi, row
tabulate ntgr_claim_qtl parec_bi, row
tabulate ntgr_claim_qtl timing_bi, row
tabulate ntgr_claim_qtl exactsame_bi, row
tabulate ntgr_claim_qtl n6_bi, row
tabulate ntgr_claim_qtl before, row

tabulate ntgr_claim_qtl, summarize (ntgr_claim)
mean ntgr_claim

sort sampleid
list ntgr_claim  sampleid

********Method 2 ntgr driver analysis*****************
*Prelim anlayses
**Measure characteristics
*annualized mmbtu sav, lifecycle mmbtu sav, rul, eul, #claims,meas type,
*hvac, measure apptype-er/rob, use category
*means RealizationRatekWh RealizationRateTherm--they all have the same value of 0.9
*egen rr=rowmax(RealizationRatekWh RealizationRateTherm)
correlate ntgr_claim ExPost_Annualized_Gross_MMBtu ExPost_Lifecycle_Gross_MMBtu ///
  EvalEUL EvalRUL project_pop TotalGrossMeasureCost_Eval
tabulate EvalMeasAppType, summarize(ntgr_claim)
tabulate UseCategory, summarize(ntgr_claim)

**program characteristics
*PA, prog-ciac, sbd-wb, sbd-sa, sector, cz, ProgramCategory,incentive
tab1 ImplementationPA Sector SBW_ImpactType ciac_nsbd wb sys
gen progtype=1 if ciac_nsbd==1
replace progtype=2 if wb==1
replace progtype=3 if sys==1
label replace progtype 1 "CIAC-Non-SBD" ///
  2 "SBD-WB" ///
  3 "SBD-SA"
tab progtype
tabulate ImplementationPA, summarize(ntgr_claim) 
tabulate Sector, summarize(ntgr_claim)
tabulate SBW_ImpactType, summarize(ntgr_claim)   
tabulate progtype, summarize(ntgr_claim) 
**site & customer characteristics
*building type, htr
tab1 BldgVint BldgHVAC Sector Treatment DeliveryType HardToReach
tabulate BldgLoc, summarize(ntgr_claim)
tabulate Sector, summarize(ntgr_claim)
tabulate DeliveryType, summarize(ntgr_claim)
**rigor level

**** later supporting analyses in response to ED questions*************
use "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Drafts\In-Progress\NTGR Driver Analysis\claimpop_survey.dta"  
tab intro1
tabulate SBW_ImpactType, summarize(TotalFirstYearGrosskWh)
tabulate SBW_ImpactType, summarize(ntgr_claim)
correlate TotalFirstYearGrosskWh ntgr_claim if ciac_nsbd==1
correlate TotalLifecycleGrosskWh ntgr_claim if ciac_nsbd==1
correlate TotalLifecycleGrosskWh ntgr_claim if ciac_nsbd==0
regress ntgr_claim ciac_nsbd EUL_Yrs TotalFirstYearGrosskWh
correlate ntgr_claim ExPost_Annualized_Gross_MMBtu ExPost_Lifecycle_Gross_MMBtu ///
  EvalEUL EvalRUL project_pop TotalGrossMeasureCost_Eval TotalLifecycleGrosskWh
  
  ****Analyses to feed into Excel roll-up files for check on RPs based on SamplePop****************
import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\samplepop-kvr.xlsx",sheet("samplepop-kvr") firstrow clear
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\samplepop-kvr.dta"
keep if sampled_kWh=="Y"
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\samplepop-kwhsample.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\samplepop-kwhsample.dta"
tabulate domain if stratum_kWh==1, summarize(ExAnteLifecycleGrosskWh)
by domain stratum_kWh, sort : summarize ExAnteLifecycleGrosskWh Eval_ExPostLifecycleGrosskWh
catenate domstrat = domain stratum_kWh
format domstrat %25s
tab domstrat
tabstat ExAnte_Annualized_NoRR_kWh, format(%20.2f) by(domstrat) labelwidth (25) columns(s) s(mean sd sum)
tabstat Eval_ExPostAnnualizedGrosskWh, format(%20.2f) by(domstrat) labelwidth (25) columns(s) s(mean sd n)
bysort domstrat : correlate ExAnte_Annualized_NoRR_kWh Eval_ExPostAnnualizedGrosskWh
by domain, sort : summarize ExAnte_Annualized_NoRR_kWh Eval_ExPostAnnualizedGrosskWh

***based on claimpop**********
import excel "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\claimpop",sheet("claimpop") firstrow clear
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\claimpop.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\claimpop.dta" 
by domain stratum_kWh, sort : SBW_ProjID Frame_Electric
tab Frame_Electric
keep if Frame_Electric==1
keep if ExAnteFirstYearGrosskWh != 0
collapse (sum) ExAnteFirstYearGrosskWh (first) domain (first) stratum_kWh ,by(SBW_ProjID Frame_Electric)
save "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\popnumbers.dta"
use "J:\9100 - CPUC Group D\_Secure Data\Deliverable 10\CIAC\Working Files\popnumbers.dta"

catenate domstrat = domain stratum_kWh
format domstrat %25s
tab domstrat
tabstat ExAnteFirstYearGrosskWh , by(domstrat) labelwidth (25) columns(s) s(mean sd sum)
