// Fixing Value Labels for Variable sector
label define sector 1 "Industrial" ///
0 "Other", replace
capture label values sector sectorVL

// Fixing Value Labels for Variable rigor
label define rigor 1 "Basic" ///
2 "Standard" ///
3 "Enhanced", replace
capture label values rigor rigorVL

// Fixing Value Labels for Variable multimeas
label define multimeas 0 "One measure" ///
1 "More than one measure", replace
capture label values multimeas multimeasVL

// Fixing Value Labels for Variable multiaddr
label define multiaddr 0 "One address" ///
1 "More than one address", replace
capture label values multiaddr multiaddrVL

// Fixing Value Labels for Variable intro1
label define intro1VL 1 "Yes" ///
2 "No" ///
8 "Don't Know" ///
9 "Refused", replace
capture label values intro1 intro1VL

// Fixing Value Labels for Variable intro2
label define intro2VL 1 "Yes" ///
2 "No" ///
8 "Don't Know" ///
9 "Refused", replace
capture label values intro2 intro2VL

// Fixing Value Labels for Variable intro4
label define intro4VL 1 "Yes" ///
2 "No, Installed Something Else" ///
3 "No, Did Not Install Anything" ///
-96 "Does not apply" ///
98 "Don't Know" ///
99 "Refused", replace
capture label values intro4 intro4VL

// Fixing Value Labels for Variable incent1
label define incent1VL -98 "Don't Know" ///
-99 "Refused", replace
capture label values incent1 incent1VL

// Fixing Value Labels for Variable pi1
label define pi1VL 1 "New construction" ///
2 "A renovation or removal of an existing building" ///
3 "An addition to an existing building" ///
4 "A first tenant improvement or newly conditioned space of an existing shell" ///
5 "A gut rehabilitation of an existing building" ///
6 "A renovation and addition" ///
7 "An industrial project", replace
capture label values pi1 pi1VL

// Fixing Value Labels for Variable pi3
label define pi3VL 1 "Single Decision" ///
2 "Multiple decisions" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values pi3 pi3VL

// Fixing Value Labels for Variable pi3a
label define pi3aVL -98 "Don't Know" ///
-96 "Does not apply" ///
-99 "Refused", replace
capture label values pi3a pi3aVL

// Fixing Value Labels for Variable pi4
label define pi4VL -98 "Don't Know" ///
-96 "Does not apply" ///
-99 "Refused", replace
capture label values pi4 pi4VL

/*
// Fixing Value Labels for Variable pi5
label define pi5VL 1 "Pre-Design Phase" ///
2 "Schematic Design & Design Development Phase" ///
3 "Construction Documents Phase" ///
4 "Construction Phase" ///
5 "Post Construction Phase" ///
-98 "Don't Know" ///
-96 "Does not apply" ///
-99 "Refused", replace
capture label values pi5 pi5VL
capture label values sa_pi5_meas1 pi5VL
capture label values sa_pi5_meas2 pi5VL
capture label values sa_pi5_meas3 pi5VL
capture label values wb_pi5 pi5VL

// Fixing Value Labels for Variable pi6
label define pi6VL 1 "Yes" ///
2 "No" ///
-98 "Don't Know" ///
-96 "Does not apply" ///
-99 "Refused", replace
capture label values pi6 pi6VL

// Fixing Value Labels for Variable pi7
label define pi7VL 1 "Multiple alternative design or equipment choices" ///
2 "Design team presented a single design" ///
-98 "Don't Know" ///
-96 "Does not apply" ///
-99 "Refused", replace
capture label values pi7 pi7VL

// Fixing Value Labels for Variable pi7a
label define pi7aVL 1 "Yes" ///
2 "No", replace
capture label values pi7a pi7aVL

// Fixing Value Labels for Variable obf1
label define obf1VL 1 "Yes" ///
2 "No", replace
capture label values obf1 obf1VL

// Fixing Value Labels for Variable wb1
label define wb1VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb1 wb1VL

// Fixing Value Labels for Variable wb1a
label define wb1a 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb1a wb1aVL

// Fixing Value Labels for Variable wb2
label define wb2VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb2 wb2VL

// Fixing Value Labels for Variable wb2a
label define wb2a 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb2a wb2aVL

// Fixing Value Labels for Variable wb3
label define wb3VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb3 wb3VL

// Fixing Value Labels for Variable wbcc1
label define wbcc1 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wbcc1 wbcc1VL

// Fixing Value Labels for Variable wb4
label define wb4VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb4 wb4VL

// Fixing Value Labels for Variable wb4a
label define wb4a 0 "Other" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb4a wb4aVL

// Fixing Value Labels for Variable wb5
label define wb5VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb5 wb5VL

// Fixing Value Labels for Variable wb5a
label define wb5a 0 "Other" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values wb5a wb5aVL

// Fixing Value Labels for Variable d1
label define d1 1 "Single decision-making process" ///
2 "Separate decision-making process for each type of equipment" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values d1 d1VL

// Fixing Value Labels for Variable sameas1
label define sameas1VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values sameas1 sameas1VL
capture label values sa_meas1 sameas1VL

// Fixing Value Labels for Variable sameas2
label define sameas2VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values sameas2 sameas2VL
capture label values sa_meas2 sameas2VL

// Fixing Value Labels for Variable sameas3
label define sameas3VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values sameas3 sameas3VL
capture label values sa_meas3 sameas3VL

// Fixing Value Labels for Variable sa1
label define sa1VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values sa1 sa1VL
capture label values sa1_meas1 sa1VL
capture label values sa1_meas2 sa1VL
capture label values sa1_meas3 sa1VL

// Fixing Value Labels for Variable sa2
label define sa2VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values sa2 sa2VL
capture label values sa2_meas1 sa1VL
capture label values sa2_meas2 sa1VL
capture label values sa2_meas3 sa1VL

// Fixing Value Labels for Variable npi1
label define npi1VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi1 npi1VL
capture label values sa_npi1_meas1 npi1VL
capture label values sa_npi1_meas2 npi1VL
capture label values sa_npi1_meas3 npi1VL
capture label values wb_npi1 npi1VL

// Fixing Value Labels for Variable npi2
label define npi2VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi2 npi2VL
capture label values sa_npi2_meas1 npi2VL
capture label values sa_npi2_meas2 npi2VL
capture label values sa_npi2_meas3 npi2VL
capture label values wb_npi2 npi2VL

// Fixing Value Labels for Variable npi3
label define npi3VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi3 npi3VL
capture label values sa_npi3_meas1 npi3VL
capture label values sa_npi3_meas2 npi3VL
capture label values sa_npi3_meas3 npi3VL
capture label values wb_npi3 npi3VL


// Fixing Value Labels for Variable npi4
label define npi4VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi4 npi4VL
capture label values sa_npi4_meas1 npi4VL
capture label values sa_npi4_meas2 npi4VL
capture label values sa_npi4_meas3 npi4VL
capture label values wb_npi4 npi4VL

// Fixing Value Labels for Variable npi5
label define npi5VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi5 npi5VL
capture label values sa_npi5_meas1 npi5VL
capture label values sa_npi5_meas2 npi5VL
capture label values sa_npi5_meas3 npi5VL
capture label values wb_npi5 npi5VL

// Fixing Value Labels for Variable npi6
label define npi6VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi6 npi6VL
capture label values sa_npi6_meas1 npi6VL
capture label values sa_npi6_meas2 npi6VL
capture label values sa_npi6_meas3 npi6VL
capture label values wb_npi6 npi6VL

// Fixing Value Labels for Variable npi7
label define npi7VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi7 npi7VL
capture label values sa_npi7_meas1 npi7VL
capture label values sa_npi7_meas2 npi7VL
capture label values sa_npi7_meas3 npi7VL
capture label values wb_npi7 npi7VL

// Fixing Value Labels for Variable npi8
label define npi8VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi8 npi8VL
capture label values sa_npi8_meas1 npi8VL
capture label values sa_npi8_meas2 npi8VL
capture label values sa_npi8_meas3 npi8VL
capture label values wb_npi8 npi8VL

// Fixing Value Labels for Variable npi9
label define npi9VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi9 npi9VL
capture label values sa_npi9_meas1 npi9VL
capture label values sa_npi9_meas2 npi9VL
capture label values sa_npi9_meas3 npi9VL
capture label values wb_npi9 npi9VL

// Fixing Value Labels for Variable npi10
label define npi10VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi10 npi10VL
capture label values sa_npi10_meas1 npi10VL
capture label values sa_npi10_meas2 npi10VL
capture label values sa_npi10_meas3 npi10VL
capture label values wb_npi10 npi10VL

// Fixing Value Labels for Variable npi11
label define npi11VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi11 npi11VL
capture label values sa_npi11_meas1 npi11VL
capture label values sa_npi11_meas2 npi11VL
capture label values sa_npi11_meas3 npi11VL
capture label values wb_npi11 npi11VL

// Fixing Value Labels for Variable npi12
label define npi12VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi12 npi12VL
capture label values sa_npi12_meas1 npi12VL
capture label values sa_npi12_meas2 npi12VL
capture label values sa_npi12_meas3 npi12VL
capture label values wb_npi12 npi12VL

// Fixing Value Labels for Variable npi13
label define npi13VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi13 npi13VL
capture label values sa_npi13_meas1 npi13VL
capture label values sa_npi13_meas2 npi13VL
capture label values sa_npi13_meas3 npi13VL
capture label values wb_npi13 npi13VL

// Fixing Value Labels for Variable npi14
label define npi14VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values npi14 npi14VL
capture label values sa_npi14_meas1 npi14VL
capture label values sa_npi14_meas2 npi14VL
capture label values sa_npi14_meas3 npi14VL
capture label values wb_npi14 npi14VL

*/



// Fixing Value Labels for Variable fdintro
label define fdintroVL 0 "Other" ///
1 "Simple payback or ROI" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fdintro fdintroVL

// Fixing Value Labels for Variable fd1
label define fd1VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fd1 fd1VL

// Fixing Value Labels for Variable fd2
label define fd2VL 1 "Yes" ///
2 "No" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fd2 fd2VL

// Fixing Value Labels for Variable fd3
label define fd3VL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fd3 fd3VL

// Fixing Value Labels for Variable fdcc1
label define fdcc1 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fdcc1 fdcc1VL

// Fixing Value Labels for Variable fdcc2
label define fdcc2 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fdcc2 fdcc2VL

// Fixing Value Labels for Variable n3k
label define n3kVL 0 "0 Not at All Important" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Important" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values n3k n3kVL
capture label values sa_n3k_meas1 n3kVL
capture label values sa_n3k_meas2 n3kVL
capture label values sa_n3k_meas3 n3kVL
capture label values wb_n3k n3kVL

// Fixing Value Labels for Variable n3kk2
label define n3kk2 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values n3kk2 n3kk2VL

// Fixing Value Labels for Variable fin0
label define fin0VL 1 "Yes - Internal" ///
2 "Yes - Other External" ///
3 "Yes - Both Internal and Other External" ///
4 "No - No Other Sources of Funding" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin0 finVL

// Fixing Value Labels for Variable fin7_1
label define fin7_1VL 0 "Other" ///
1 "Better Interest Rate" ///
2 "Better Loan Term/Duration" ///
3 "More Convenient" ///
4 "Contractor Recommended It" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin7_1 fin7_1VL

// Fixing Value Labels for Variable fin7_2
label define fin7_2VL 0 "Other" ///
1 "Better Interest Rate" ///
2 "Better Loan Term/Duration" ///
3 "More Convenient" ///
4 "Contractor Recommended It" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin7_2 fin7_2VL

// Fixing Value Labels for Variable fin7_3
label define fin7_3VL 0 "Other" ///
1 "Better Interest Rate" ///
2 "Better Loan Term/Duration" ///
3 "More Convenient" ///
4 "Contractor Recommended It" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin7_3 fin7_3VL

// Fixing Value Labels for Variable fin8_1
label define fin8_1VL 0 "Other" ///
1 "Internal Funding" ///
2 "Contractor Financing" ///
3 "Vendor Financing if Needed for Example, Taking a Store Loan From Sears to Buy An Appliance" ///
4 "Secured Loan From Bank if Needed a Loan Using Property or Assets as Collateral or Lien on the Business" ///
5 "Unsecured Loan From Bank if Needed a Loan Which Does Not Require a Collateral" ///
6 "Line of Credit" ///
7 "Equipment Financing or Leasing if Needed Any Method of Securing Capital for the Purposes of Acquiring Equipment; Vend" ///
8 "Company Credit Card" ///
9 "Cash on Hand" ///
10 "Would Not Have Installed This Equipment" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin8_1 fin8_1VL

// Fixing Value Labels for Variable fin8_2
label define fin8_2VL 0 "Other" ///
1 "Internal Funding" ///
2 "Contractor Financing" ///
3 "Vendor Financing if Needed for Example, Taking a Store Loan From Sears to Buy An Appliance" ///
4 "Secured Loan From Bank if Needed a Loan Using Property or Assets as Collateral or Lien on the Business" ///
5 "Unsecured Loan From Bank if Needed a Loan Which Does Not Require a Collateral" ///
6 "Line of Credit" ///
7 "Equipment Financing or Leasing if Needed Any Method of Securing Capital for the Purposes of Acquiring Equipment; Vend" ///
8 "Company Credit Card" ///
9 "Cash on Hand" ///
10 "Would Not Have Installed This Equipment" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin8_2 fin8_2VL

// Fixing Value Labels for Variable fin8_3
label define fin8_3VL 0 "Other" ///
1 "Internal Funding" ///
2 "Contractor Financing" ///
3 "Vendor Financing if Needed for Example, Taking a Store Loan From Sears to Buy An Appliance" ///
4 "Secured Loan From Bank if Needed a Loan Using Property or Assets as Collateral or Lien on the Business" ///
5 "Unsecured Loan From Bank if Needed a Loan Which Does Not Require a Collateral" ///
6 "Line of Credit" ///
7 "Equipment Financing or Leasing if Needed Any Method of Securing Capital for the Purposes of Acquiring Equipment; Vend" ///
8 "Company Credit Card" ///
9 "Cash on Hand" ///
10 "Would Not Have Installed This Equipment" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values fin8_3 fin8_3VL

/*
// Fixing Value Labels for Variable ap1
label define ap1VL 0 "0 Not at All Likely" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Extremely Likely" ///
-96 "Does not apply" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values ap1 ap1VL
capture label values sa_ap1_meas1 ap1VL
capture label values sa_ap1_meas2 ap1VL
capture label values sa_ap1_meas3 ap1VL
capture label values wb_ap1 ap1VL

// Fixing Value Labels for Variable ap1a
label define ap1aVL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values ap1a ap1aVL

// Fixing Value Labels for Variable ap2
label define ap2VL 0 "Other" ///
1 "Installed the same equipment" ///
2 "Installed standard efficiency equipment or what is required by code" ///
3 "Installed equipment more efficient than code but less efficient than what you installed through the program" ///
4 "Done nothing" ///
5 "Something else" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values ap2 ap2VL
capture label values sa_ap2_meas1 ap2VL
capture label values sa_ap2_meas2 ap2VL
capture label values sa_ap2_meas3 ap2VL
capture label values wb_ap2 ap2VL

// Fixing Value Labels for Variable ap2a
label define ap2aVL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values ap2a ap2aVL

// Fixing Value Labels for Variable ap2b
label define ap2bVL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values ap2b ap2bVL

// Fixing Value Labels for Variable apcc1
label define apcc1VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values apcc1 apcc1VL

// Fixing Value Labels for Variable apcc2
label define apcc2VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values apcc2 apcc2VL

// Fixing Value Labels for Variable p1
label define p1VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values p1 p1VL

// Fixing Value Labels for Variable p2
label define p2VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values p2 p2VL

*/
// Fixing Value Labels for Variable p3
label define p3VL 0 "0 Completely Dissatisfied" ///
1 "1" ///
2 "2" ///
3 "3" ///
4 "4" ///
5 "5" ///
6 "6" ///
7 "7" ///
8 "8" ///
9 "9" ///
10 "10 Completely Satisfied" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values p3 p3VL

// Fixing Value Labels for Variable p4
label define p4VL 0 "Other" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values p4 p4VL

// Fixing Value Labels for Variable lt1
label define lt1VL 1 "Yes" ///
2 "No" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values lt1 lt1VL

// Fixing Value Labels for Variable lt2
label define lt2VL 1 "Yes" ///
2 "No" ///
-98 "Don't Know" ///
-99 "Refused", replace
capture label values lt2 lt2VL


// Variable Labels
label variable completed "Flag for completed survey"
label variable intro1 "Did you also receive an on-bill financing loan for this project?"
label variable sbw_projid "SBW project id"
label variable contact "SBD owner contact name"
label variable business "SBD owner business name"
label variable meas1 "Measure 1 description"
label variable meas_1_date "Measure 1 date"
label variable meas2 "Measure 2 description"
label variable meas_2_date "Measure 2 date"
label variable meas2 "Measure 2 description"
label variable meas_2_date "Measure 2 date"
label variable sector "1=Industrial, 0=Other"
label variable rigor "Rigor level"
label variable multimeas "More than 1 measure flag"
label variable multiaddr "More than 1 address"
label variable sbd "Savings by design flag"
label variable wb "Whole building flag"
label variable sys "Systems approach flag"
label variable obf "Obf flag"
label variable dt "Design team flag"
label variable intro2 "Were you also involved in the decision to apply for the loan for this project?"
label variable intro3_name "Do you know who at this location was involved in the decision to apply for the l"
label variable intro3_phone "Phone:"
label variable intro3_email "Email:"
label variable intro3_role "Role within Company:"
label variable intro3_department "Department:"
label variable intro4 "I would like to confirm the following information about your project."
label variable intro4_openend "No, installed something else"
label variable incent1 "What percentage of the cost of your project was covered by the program?"
label variable a1gg "What incentive amount did your organization receive from the program towards your energy efficient equipment installation?"
label variable pi1 "Which of the following best describes the project?"
label variable pi3 "Was there a single decision-making process for the installation of this equipment, or was there a separate decision-making process for each type of equipment?"
label variable pi3a "Can you please describe the decision(s) involved and which measures were associated with each?"
label variable pi4 "How did the idea to participate in this program originate?"
label variable pi5 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable sa_pi5_meas1 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable sa_pi5_meas2 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable sa_pi5_meas3 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable wb_pi5 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable pi6 "Did you work directly with the Savings by Design representative or consultant on this project? "
label variable pi7 "Can you tell me a little more about the project design process?"
label variable pi7a "Did the incentive from the program help you make those design changes?"
label variable pi7a_openend "If yes, what apsects of the program helped. If no, why didn't the program influence the design?"
label variable obf1 "Before learning about this program, did you research financing options for your project?"
label variable wb1 "Importance of availability of the program Design Assistance including one or more possible services of: plan review, a recommendation, and/or energy model with financial analysis on multiple options for energy efficient systems"
label variable wb1a "Can you please explain why you gave it that rating?"
label variable wb2 "Availability of the program Design Analysis which includes energy simulation and financial analysis to quantify the benefits associated with multiple energy efficient options and strategies"
label variable wb2a "Can you please explain why you gave it that rating?"
label variable wb3 "Information & support from your utility account representative or SBD representative"
label variable wbcc1 "Will you explain in your own words, the role the programs design services played in your design decisions?"
label variable wb4 "Availability of the program Whole Building Approach kW/Energy Incentive"
label variable wb4a "Can you please explain why you gave it that rating?"
label variable wb5 "Availability of the program Design Team Incentive"
label variable wb5a "Can you please explain why you gave it that rating?"
label variable d1 "Was there a single decision-making process for the installation of this equipment, or was there a separate decision-making process for each type of equipment?"
label variable sameas1 "Importance of financial incentives on measure 1"
label variable sameas2 "Importance of financial incentives on measure 2"
label variable sameas3 "Importance of financial incentives on measure 3"

label variable sa_meas1 "Importance of financial incentives on measure 1"
label variable sa_meas2 "Importance of financial incentives on measure 2"
label variable sa_meas3 "Importance of financial incentives on measure 3"

label variable sa1 "Interaction with your Account Rep or the SBD Account Rep?"
label variable sa2 "How about availability of energy modeling tools or technical assistance?"
label variable sa1_meas1 "Interaction with your Account Rep or the SBD Account Rep?"
label variable sa2_meas1 "How about availability of energy modeling tools or technical assistance?"
label variable sa1_meas2 "Interaction with your Account Rep or the SBD Account Rep?"
label variable sa2_meas2 "How about availability of energy modeling tools or technical assistance?"
label variable sa1_meas3 "Interaction with your Account Rep or the SBD Account Rep?"
label variable sa2_meas3 "How about availability of energy modeling tools or technical assistance?"

label variable npi1 "Previous experience or prior success with this measure(s)"
label variable npi2 "Previous experience or prior success with the program"
label variable npi3 "Non-energy benefits (such as improved occupant comfort and aesthetic enhancements)"
label variable npi4 "Payback on the investment or ROI"
label variable npi5 "Reduced cost of operation (Lifecycle cost)"
label variable npi6 "Recommendation from a vendor or manufacturer"
label variable npi7 "Recommendation from a consultant (lighting, refrigeration, mechanical, process, agri, industrial)"
label variable npi8 "Standard practice in your industry"
label variable npi9 "Corporate policy or guidelines"
label variable npi10 "Compliance with your organization's normal maintenance or equipment policies"
label variable npi11 "Desire for Green Building /LEED Compliance"
label variable npi12 "Corporate building template or prototype"
label variable npi13 "Compliance with rules or codes set by regulatory agencies"
label variable npi14 "Lastly, are there any other factors we haven't discussed that were influential in your decision to install this measure"

label variable wb_npi1 "Previous experience or prior success with this measure(s)"
label variable wb_npi2 "Previous experience or prior success with the program"
label variable wb_npi3 "Non-energy benefits (such as improved occupant comfort and aesthetic enhancements)"
label variable wb_npi4 "Payback on the investment or ROI"
label variable wb_npi5 "Reduced cost of operation (Lifecycle cost)"
label variable wb_npi6 "Recommendation from a vendor or manufacturer"
label variable wb_npi7 "Recommendation from a consultant (lighting, refrigeration, mechanical, process, agri, industrial)"
label variable wb_npi8 "Standard practice in your industry"
label variable wb_npi9 "Corporate policy or guidelines"
label variable wb_npi10 "Compliance with your organization's normal maintenance or equipment policies"
label variable wb_npi11 "Desire for Green Building /LEED Compliance"
label variable wb_npi12 "Corporate building template or prototype"
label variable wb_npi13 "Compliance with rules or codes set by regulatory agencies"
label variable wb_npi14 "Lastly, are there any other factors we haven't discussed that were influential in your decision to install this measure"

label variable sa_npi1_meas1 "Previous experience or prior success with this measure(s)"
label variable sa_npi2_meas1 "Previous experience or prior success with the program"
label variable sa_npi3_meas1 "Non-energy benefits (such as improved occupant comfort and aesthetic enhancements)"
label variable sa_npi4_meas1 "Payback on the investment or ROI"
label variable sa_npi5_meas1 "Reduced cost of operation (Lifecycle cost)"
label variable sa_npi6_meas1 "Recommendation from a vendor or manufacturer"
label variable sa_npi7_meas1 "Recommendation from a consultant (lighting, refrigeration, mechanical, process, agri, industrial)"
label variable sa_npi8_meas1 "Standard practice in your industry"
label variable sa_npi9_meas1 "Corporate policy or guidelines"
label variable sa_npi10_meas1 "Compliance with your organization's normal maintenance or equipment policies"
label variable sa_npi11_meas1 "Desire for Green Building /LEED Compliance"
label variable sa_npi12_meas1 "Corporate building template or prototype"
label variable sa_npi13_meas1 "Compliance with rules or codes set by regulatory agencies"
label variable sa_npi14_meas1 "Lastly, are there any other factors we haven't discussed that were influential in your decision to install this measure"

label variable sa_npi1_meas2 "Previous experience or prior success with this measure(s)"
label variable sa_npi2_meas2 "Previous experience or prior success with the program"
label variable sa_npi3_meas2 "Non-energy benefits (such as improved occupant comfort and aesthetic enhancements)"
label variable sa_npi4_meas2 "Payback on the investment or ROI"
label variable sa_npi5_meas2 "Reduced cost of operation (Lifecycle cost)"
label variable sa_npi6_meas2 "Recommendation from a vendor or manufacturer"
label variable sa_npi7_meas2 "Recommendation from a consultant (lighting, refrigeration, mechanical, process, agri, industrial)"
label variable sa_npi8_meas2 "Standard practice in your industry"
label variable sa_npi9_meas2 "Corporate policy or guidelines"
label variable sa_npi10_meas2 "Compliance with your organization's normal maintenance or equipment policies"
label variable sa_npi11_meas2 "Desire for Green Building /LEED Compliance"
label variable sa_npi12_meas2 "Corporate building template or prototype"
label variable sa_npi13_meas2 "Compliance with rules or codes set by regulatory agencies"
label variable sa_npi14_meas2 "Lastly, are there any other factors we haven't discussed that were influential in your decision to install this measure"

label variable sa_npi1_meas3 "Previous experience or prior success with this measure(s)"
label variable sa_npi2_meas3 "Previous experience or prior success with the program"
label variable sa_npi3_meas3 "Non-energy benefits (such as improved occupant comfort and aesthetic enhancements)"
label variable sa_npi4_meas3 "Payback on the investment or ROI"
label variable sa_npi5_meas3 "Reduced cost of operation (Lifecycle cost)"
label variable sa_npi6_meas3 "Recommendation from a vendor or manufacturer"
label variable sa_npi7_meas3 "Recommendation from a consultant (lighting, refrigeration, mechanical, process, agri, industrial)"
label variable sa_npi8_meas3 "Standard practice in your industry"
label variable sa_npi9_meas3 "Corporate policy or guidelines"
label variable sa_npi10_meas3 "Compliance with your organization's normal maintenance or equipment policies"
label variable sa_npi11_meas3 "Desire for Green Building /LEED Compliance"
label variable sa_npi12_meas3 "Corporate building template or prototype"
label variable sa_npi13_meas3 "Compliance with rules or codes set by regulatory agencies"
label variable sa_npi14_meas3 "Lastly, are there any other factors we haven't discussed that were influential in your decision to install this measure"

label variable npi14_openend "Oher factors that were influential"
label variable fdintro_openend "What financial calculations does your company typically make before proceeding with the installation of a high efficiency PROJECT like this one?"
label variable fd1 "What is your threshold (num. of years) in terms of the payback or return on investment your company uses before deciding to proceed with an investment?"
label variable fd1_openend "Open end"
label variable fd2  "Did the incentive move your project within this acceptable range?"
label variable fd2_openend "Open end"
label variable fd3 "How important in your decision was it that the PROJECT was now in the acceptable range?"
label variable fdcc1 "The incentive seemed to make the difference between meeting your financial criteria and not meeting them, but you are saying that the incentive didn’t have much effect on your decision, why is that?"
label variable fdcc1_openend "Open end"
label variable fdcc2 "The incentive didn’t cause this PROJECT to meet your company’s financial criteria, but you said that the incentive had an impact on the decision to install PROJECT. Why did it have an impact? Would you like to adjust your responses to Fi1?"
label variable fdcc2_openend "Open end"
label variable n3k "How would you rate the importance of Availability of On-Bill Finance LOAN you received from <PA> in your decision to implement this PROJECT?"
label variable sa_n3k_meas1 "How would you rate the importance of Availability of On-Bill Finance LOAN you received from <PA> in your decision to implement this PROJECT?"
label variable sa_n3k_meas2 "How would you rate the importance of Availability of On-Bill Finance LOAN you received from <PA> in your decision to implement this PROJECT?"
label variable sa_n3k_meas3 "How would you rate the importance of Availability of On-Bill Finance LOAN you received from <PA> in your decision to implement this PROJECT?"
label variable wb_n3k "How would you rate the importance of Availability of On-Bill Finance LOAN you received from <PA> in your decision to implement this PROJECT?"
label variable n3kk1 "How did the availability of the loan enter into your decision to install this equipment?"
label variable n3kk2 "This suggests that the loan wasn’t very important in your decision to install this equipment. Why is that?"
label variable fin0 "In addition to the <PA> rebate and on-bill finance loan, did you use any internal or other external, non-program funding to pay for the upfront cost of this equipment?"
label variable fin1 "Thinking about the cost of this equipment, after the rebate, approximately what percentage of the remaining cost was covered by… "
label variable fin11 "the On-Bill Finance Loan"
label variable fin12 "other external sources of funding"
label variable fin13 "internal sources of funding"
label variable fin7 "Why did you choose the On-Bill Finance loan over other options of external funding?"
label variable fin7_1 "Response 1"
label variable fin7_2 "Response 2"
label variable fin7_3 "Response 3"
label variable fin8 "If the On-Bill Finance loan had not been available, how would you have paid for this equipment?"
label variable fin8_1 "Response 1"
label variable fin8_2 "Response 2"
label variable fin8_3 "Response 3"
label variable rpi1 "The importance of the PROGRAM factors in your decision"
label variable sa_rpi1_meas1 "The importance of the PROGRAM factors in your decision"
label variable sa_rpi1_meas2 "The importance of the PROGRAM factors in your decision"
label variable sa_rpi1_meas3 "The importance of the PROGRAM factors in your decision"
label variable wb_rpi1 "The importance of the PROGRAM factors in your decision"

label variable rpi2 "The importance of the non-PROGRAM factors in your decision"
label variable sa_rpi2_meas1 "The importance of the non-PROGRAM factors in your decision"
label variable sa_rpi2_meas2 "The importance of the non-PROGRAM factors in your decision"
label variable sa_rpi2_meas3 "The importance of the non-PROGRAM factors in your decision"
label variable wb_rpi2 "The importance of the non-PROGRAM factors in your decision"

label variable ap1 "If this PROGRAM was not available, what is the likelihood that you would have installed exactly the same program-qualifying efficiency equipment that you did in this project?"
label variable sa_ap1_meas1 "If this PROGRAM was not available, what is the likelihood that you would have installed exactly the same program-qualifying efficiency equipment that you did in this project?"
label variable sa_ap1_meas2 "If this PROGRAM was not available, what is the likelihood that you would have installed exactly the same program-qualifying efficiency equipment that you did in this project?"
label variable sa_ap1_meas3 "If this PROGRAM was not available, what is the likelihood that you would have installed exactly the same program-qualifying efficiency equipment that you did in this project?"
label variable wb_ap1 "If this PROGRAM was not available, what is the likelihood that you would have installed exactly the same program-qualifying efficiency equipment that you did in this project?"
label variable ap1a "Why do you say that?"
label variable ap2 "What action would you have taken if the program had not been available? What would you have done (installed) differently?"
label variable sa_ap2_meas1 "What action would you have taken if the program had not been available? What would you have done (installed) differently?"
label variable sa_ap2_meas2 "What action would you have taken if the program had not been available? What would you have done (installed) differently?"
label variable sa_ap2_meas3 "What action would you have taken if the program had not been available? What would you have done (installed) differently?"
label variable wb_ap2 "What action would you have taken if the program had not been available? What would you have done (installed) differently?"
label variable ap2_openend "Other, open end"
label variable ap2a "What are the specific reasons you would have installed this exact same equipment?"
label variable ap2b "Can you tell me what model or efficiency level you were considering as an alternative?"
label variable apcc1 "Will you explain in your own words, the role the INCENTIVE played in your decision to install this efficient equipment?"
label variable apcc2 "Will you explain in your own words, the role the DESIGN ASSISTANCE/ANALYSIS played in your decision to install this efficient equipment?"
label variable p1 "What do you believe the PROGRAM’S primary strengths are?"
label variable p2 "What concerns do you have about the PROGRAM, if any?"
label variable p3 "On a scale of 0 - 10, where 0 is completely dissatisfied and 10 is completely satisfied, how would you rate your OVERALL satisfaction with the PROGRAM?"
label variable p4 "If any, what recommendations would you have to change the SBD program to improve its delivery to customers such as yourself?"
label variable lt1 "Have you previously participated in the SBD program? "
label variable lt2 "Has this program had any long-term influence on your organization's energy efficiency related practices and policies?"
label variable lt3 "Regarding future development projects, do you think participation in this program will affect how you approach your standard building practice such that you would build a more energy efficient building in the future?"
//label variable checkedforaccuracy "Checked survey data for accuracy"
label variable sampleid "SBW sample ID"
label variable ClaimId1 "Claim ID 1"
label variable ClaimId2 "Claim ID 2"
label variable ClaimId3 "Claim ID 3"

label variable dt_interview "Flag if we preformed a design team interview too"
label variable Design_Team_Influence "the calculated DT influence"

label variable ciac_nsbd "CIAC Non-SBD Flag"
label variable wb_dtintrob "The SBD Project File has indicated that your firm was involved in the design of their project Is this correct?"
label variable wb_dtintro0b "Our records indicate that your design team received an SBD Design Team Incentive for this project is that correct?"
label variable wb_dtintro2b "Did you work directly with the Savings by Design representative on this project?"
label variable wb_dtpi1 "At which stage of the design and construction process did you first become actively involved with the Savings By Design Program?"
label variable wb_dtpi2 "How did the idea to participate in this program originate? (Probe: Whose idea was it to participate?"
label variable wb_dtpi3 "When you were designing the building, did you present design options to the customer or was there just a single design presented?"
label variable wb_dtpi4 "Did SBD provide Design Assistance on this project?"
label variable wb_dtpi5 "Did SBD also provide Design Analysis which may include energy simulation and financial analysis to quantify the benefits associated with multiple energy efficient options and strategies."
label variable wb_dtpi5a "Can you describe the technical assistance was provided on the project was it simply plan checks and recommendations for improvements or was it more involved with parametric runs and economic analysis of energy efficient measures?"
label variable wb_dtpi6 "Importance of the program Energy Design Resources including: Design Briefs and Case Histories Energy Design Software Training and Workshops on the design of this project?"
label variable wb_dtpi7 "Importance of the information from <PA> or program training course such as: SCE’s Energy Education Center, PG&E’s Pacific Energy Center, SCG’s Energy Resource Center, SDG&E’s Energy Innovation Center?"
label variable wb_dtpi8 "Importance of the inclusion of SBD program representatives in your meetings with the owners in the design of this project?"
label variable wb_dtml1 "Did the initial design of your building change (become more efficient) as a result of the Design Assistance & Analysis component of SBD?"
label variable wb_dtml1a "What specific changes or modification were made as a result of the program?"
label variable wb_dtml1b "Why didn't the program result in changes to the design?"
label variable wb_dtml2 "Could you please rate the importance of the program services including assistance and analysis on a 0 to 10 scale?"
label variable wb_dtml2a "Can you please explain why you gave it that rating?"
label variable wb_dtnm2 "Without the Design Team Incentive & Services we would not be able to provide customers with this same level of design service."
label variable wb_dtnm3 "Availability of the design team incentive makes it possible for us to encourage our customers to enroll in the SBD program early in the design process"
label variable wb_dtnm4 "For projects that do not participate in the program we also specify an integrated design approach"
label variable wb_dtp1 "What do you believe the <PROGRAM>’s primary strengths are?"
label variable wb_dtp2 "What concerns do you have about the <PROGRAM>, if any? "
label variable wb_dtp3 "On a scale of 0 - 10, where 0 is completely dissatisfied and 10 is completely satisfied, how would you rate your OVERALL satisfaction with the PROGRAM?"
label variable wb_dtp3b "Why do you say that?"
label variable wb_dtp4 "If any, what recommendations would you have to change the SBD program to improve its delivery to customers such as yourself?"
label variable wb_dtlt1 "Have you previously participated in the SBD program?"
label variable wb_dtlt2 "Has this program had any long-term influence on your organization's energy efficiency related practices and policies that go beyond the immediate effect of incentives on individual project(s)"
label variable wb_dtlt3 "Regarding future development projects, do you think participation in this program will affect how you approach your future projects and building practice such that you would design a more energy efficient building in the future?"

label variable sa_claimid1 "System approach claim ID 1"
label variable sa_date_meas1 "System approach measure description 1"
label variable sa_claimid2 "System approach claim ID 2"
label variable sa_date_meas2 "System approach measure description 2"
label variable sa_claimid3 "System approach claim ID 3"
label variable sa_date_meas3 "System approach measure description 3"


