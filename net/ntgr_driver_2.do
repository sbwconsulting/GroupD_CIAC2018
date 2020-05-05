clear
cd "C:\Users\rsrid\Documents\Business\Group D\Delivarable 10 Ex Post Evaluated Net Savings Estimates\Analysis\pretest"

clear
cd "Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\10 - Ex Post Evaluated Net Savings Estimates\Net Template\Survey Data"

clear
set linesize 250
use xxxxxxxxx

********************************* descriptive stats on ntgr *******************************************************************************
histogram ntgr, frequency normal kdensity
summarize ntgr, detail
sktest ntgr


***********************   candidate variables for different surveys  **********************************************************************

Non-SBD								SBD: Whole Building: Owner										SBD: System: Owner
htr (1=hard to reach; 0=otherwise)	htr (1=hard to reach; 0=otherwise)								htr (1=hard to reach; 0=otherwise)
ex post gross savings (MMBtu)		ex post gross savings (MMBtu)									ex post gross savings (MMBtu)
numb_meas (number of measures)		numb_meas (number of measures)									numb_meas (number of measures)
incentive (amount of incentive)		incentive (amount of incentive)									incentive (amount of incentive)
multimeas							multimeas														multimeas
sector								sector															sector
a1b									intro1															incent1
n2_meas1							design_team (1=yes; 0=no)										intro1
n3a_meas1							sector (1=industrial; 2=other)									pi1
n3b_meas1							mult (1=one measure; 2=more than one measure					pi3
n3c_meas1							mult_addr (1=one address, 2=more than one address)				pi5
n3d_meas1							Incent1 (percent of project cost covered by the incentive)		pi6
n3e_meas1							pi1																pi7a
n3f_meas1							pi3																obf1_meas1
n3g_meas1							pi5																d1
n3h_meas1							pi6																
n3i_meas1							pi7a															sa1_meas1
n3j_meas1							obf1															sa2_meas1
n3k_meas1							wb1																sa_npi1_meas1
FIN0								wb2																sa_npi2_meas1
n3l_meas1							wb3																sa_npi3_meas1
n3m_meas1							wb4																sa_npi5_meas1
n3n_meas1							wb5																sa_npi6_meas1
n3o_meas1							wb_npi_1														sa_npi7_meas1
n3p_meas1							wb_npi_2														sa_npi8_meas1
n3q_meas1							wb_npi_3														sa_npi9_meas1
n3r_meas1							wb_npi_4														sa_npi10_meas1
n3s_meas1							wb_npi_5														sa_npi11_meas1
n3t_1_01							wb_npi_6														sa_npi12_meas1
p3_1								wb_npi_7														sa_npi13_meas1
p4_1								wb_npi_8														sa_npi14_meas1
cp1_1								wb_npi_9														fd2
CP3									wb_npi_10														fd3
sp1_1								wb_npi_11														sa_n3k_meas1
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

*******  prep ******************************************************************************************************************************

recode missing values



*********** non-sbd analysis ****************************************************************************************************************


keep if XX = nsbd
keep ntgr htr	gross_saving	numb_meas 	incentive 	multimeas	sector	a1b	n2_meas1	n3a_meas1	n3b_meas1	n3c_meas1	
		n3d_meas1	n3e_meas1	n3f_meas1	n3g_meas1	n3h_meas1	n3i_meas1	n3j_meas1	n3k_meas1	FIN0	n3l_meas1	n3m_meas1	
		n3n_meas1	n3o_meas1	n3p_meas1	n3q_meas1	n3r_meas1	n3s_meas1	n3t_1_01	p3_1 p4_1	cp1_1	CP3	sp1_1	sp2_1	
		sp3a_1	cc12a	cc12b	co	ccc1	ccc3	c1	c1_response	c2	c3	c3a

*********************************************************************************************************************************************
tab   	ntgr htr	gross_saving	numb_meas 	incentive 	multimeas	sector	a1b	n2_meas1	n3a_meas1	n3b_meas1	n3c_meas1	
		n3d_meas1	n3e_meas1	n3f_meas1	n3g_meas1	n3h_meas1	n3i_meas1	n3j_meas1	n3k_meas1	FIN0	n3l_meas1	n3m_meas1	
		n3n_meas1	n3o_meas1	n3p_meas1	n3q_meas1	n3r_meas1	n3s_meas1	n3t_1_01	p3_1 p4_1	cp1_1	CP3	sp1_1	sp2_1	
		sp3a_1	cc12a	cc12b	co	ccc1	ccc3	c1	c1_response	c2	c3	c3a


regress ntgr 

************ sbd whole building **************************************************************************************************************

keep if XX = sbd_wb
keep htr	gross saving	numb_meas 	incentive 	multimeas	sector	intro1	design_team	sector	mult	mult_addr 	Incent1 
	pi1	pi3	pi5	pi6	pi7a	obf1	wb1	wb2	wb3	wb4	wb5	wb_npi_1	wb_npi_2	wb_npi_3	wb_npi_4	wb_npi_5	wb_npi_6
	wb_npi_7	wb_npi_8	wb_npi_9	wb_npi_10	wb_npi_11	wb_npi_12	wb_npi_13	wb_npi_14	fd2	fd3	wb_n3k	fin0 fin8
	lt1	lt2	lt3

*********************************************************************************************************************************************
	
tab htr	gross saving	numb_meas 	incentive 	multimeas	sector	intro1	design_team	sector	mult	mult_addr 	Incent1 
	pi1	pi3	pi5	pi6	pi7a	obf1	wb1	wb2	wb3	wb4	wb5	wb_npi_1	wb_npi_2	wb_npi_3	wb_npi_4	wb_npi_5	wb_npi_6
	wb_npi_7	wb_npi_8	wb_npi_9	wb_npi_10	wb_npi_11	wb_npi_12	wb_npi_13	wb_npi_14	fd2	fd3	wb_n3k	fin0 fin8
	lt1	lt2	lt3




************ sbd systems *********************************************************************************************************************

keep if XX = sbd_system
keep htr	gross saving	numb_meas 	incentive 	multimeas	sector	incent1	intro1	pi1	pi3	pi5	pi6	pi7a obf1_meas1	d1	 
sa1_meas1	sa2_meas1	sa_npi1_meas1	sa_npi2_meas1	sa_npi3_meas1	sa_npi5_meas1	sa_npi6_meas1	sa_npi7_meas1	
sa_npi8_meas1	sa_npi9_meas1	sa_npi10_meas1	sa_npi11_meas1	sa_npi12_meas1	sa_npi13_meas1	sa_npi14_meas1	fd2	fd3	sa_n3k_meas1
fino	fin1	fin8	lt1	lt2	lt3

*********************************************************************************************************************************************

tab htr	gross saving	numb_meas 	incentive 	multimeas	sector	incent1	intro1	pi1	pi3	pi5	pi6	pi7a obf1_meas1	d1	 
sa1_meas1	sa2_meas1	sa_npi1_meas1	sa_npi2_meas1	sa_npi3_meas1	sa_npi5_meas1	sa_npi6_meas1	sa_npi7_meas1	
sa_npi8_meas1	sa_npi9_meas1	sa_npi10_meas1	sa_npi11_meas1	sa_npi12_meas1	sa_npi13_meas1	sa_npi14_meas1	fd2	fd3	sa_n3k_meas1
fino	fin1	fin8	lt1	lt2	lt3



************************************* end  ***************************************************************************************************




