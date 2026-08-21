*---------------------------------------------------------------------------------------*
*	Author		: Anissa Rahmawati 														*
*				  Virgi Sari															*
*	Email		: anissarahmasukardi@gmail.com											*
*				  vas39@bath.ac.uk														*
*	Program 	: Data prep on digital literacy											*
*				  Getting information on internet usage									*
*	Data		: World Bank Digital Economy Household Survey 2020						*
*				  Download: https://microdata.worldbank.org/index.php/catalog/4602		*
*---------------------------------------------------------------------------------------*

*!!!!! Please run the master dofile first to set up working folder and file paths !!!!!!

clear
cap log close
clear matrix
set more off
set matsize 11000


/*

Note: This do file retrieves variable related to the USE OF INTERNET

The selected ariables used in the analysis are below (see Table 3 from main text)

CONTINUE HERE

	*Variables*								*Description*
	own_laptop								A dummy-variable; 1=own tablets or computers
	own_smpartphone							A dummy-variable; 1=own smartphone
	Household ICT device ratio				Total number of ICT devices owned by household divided by household size
	Log of monthly phone expenditure		Log of monthly phone expenditure
	Average internet download speed			Average monthly download speed 

*/


/*------------------------------------------------------------------------------
	STEP 1 - clean book 2_1 to obtain information on ICT device ownership
--------------------------------------------------------------------------------*/
*Open file
	use "${raw}BUKU2_BI.dta", clear
	
*checking ID duplicates
	unique ea_b2 buku2_id b2_cov1_id
	
*Creating ID	
		rename ea_b2 wilcah //to make it consistent with other books		
		gen hh_id = buku2_id //hhid
		tostring b2_cov1_id, replace //convert no ART using 
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
		la var ind_id "individual ID"
	
	unique ind_id
	
*ICT device ownership
	gen own_pc= bi_1a==1
		replace own_pc=0 if bi_1a!=1
	gen own_laptop= bi_1b==1
		replace own_laptop=0 if bi_1b!=1
	gen own_tablet= bi_1c==1
		replace own_tablet=0 if bi_1c!=1
	gen own_smartphone= bi_1d==1
		replace own_smartphone=0 if bi_1d!=1
	gen own_mobilephone= bi_1e==1
		replace own_laptop=0 if bi_1e!=1
		
*Number of ICT device
	egen tot_ICTdevice=rowtotal(own_pc own_laptop own_tablet own_smartphone own_mobilephone)
		replace tot_ICTdevice=0 if tot_ICTdevice==.
	
	keep wilcah hh_id ind_id own_* tot_ICTdevice
	
	tempfile device
	save `device', replace
	
	/*************************************************
		TAKE INFORMATION OF HOUSEHOLD SIZE FROM B1
	*************************************************/
		use "${raw}BUKU1_AIV.dta", clear
		
		sort wilcah hh_id
		
		gen hhsize=aiv_1c
		
		keep wilcah hh_id hhsize
		
		merge 1:m hh_id using `device'
			drop if _m~=3
			drop _m
			
gen ictdevice_ratio=tot_ICTdevice/hhsize
	label var ictdevice_ratio "ICT Device/ Household Member"
	
	sort hh_id ind_id
	save "${coded}device", replace

/*------------------------------------------------------------------------------
	STEP 2 - clean book 2_II1 to obtain information on internet purchase
--------------------------------------------------------------------------------*/
*Open file
	use "${raw}BUKU2_BII1", clear
	
*checking ID duplicates
	unique ea_b2 buku2_id b2_cov1_id
	
*Creating ID	
		rename ea_b2 wilcah //to make it consistent with other books		
		gen hh_id = buku2_id //hhid
		tostring b2_cov1_id, replace //convert no ART using 
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
		la var ind_id "individual ID"
	
	unique ind_id
	
*creating internet purchase variables 

	gen phonecredit_rp= bii_7
		replace phonecredit_rp=0 if bii_7x==3
	gen ln_phonecr_rp=log(phonecredit_rp)
		label var ln_phonecr_rp "Log of Phone Credit"
		
	gen inetcredit_rp=phonecredit_rp if bii_9==1
		replace inetcredit_rp=0 if bii_9==3 
	
	replace inetcredit=0 if inetcredit_rp==. & bii_7x==3
	replace inetcredit=1 if inetcredit_rp>0 & inetcredit_rp<=25000
	replace inetcredit=2 if inetcredit_rp>25000  & inetcredit_rp<=50000
	replace inetcredit=3 if inetcredit_rp>50000  & inetcredit_rp<=100000
	replace inetcredit=4 if inetcredit_rp>100000 & inetcredit_rp<=250000
	replace inetcredit=5 if inetcredit_rp>250000
	
	label define credit 0 "No Internet Credit Purchase" 1 "<= Rp. 25,000" 2 "Rp 25,000 - Rp 50,000" 3 "Rp 50,000  Rp 100,000" 4 "Rp 100,000 - Rp 250,000" 5 "> Rp 250,000"
		label val inetcredit credit
	
	
*data package purchase
	
	gen data_GB=bii_10b
	replace data_GB=0 if inetcredit==0 & bii_10b==.
	
	gen inetdata=0
	replace inetdata=0 if data_GB==0
	replace inetdata=1 if data_GB>0 & data_GB<=5
	replace inetdata=2 if data_GB>5 & data_GB<=10
	replace inetdata=3 if data_GB>10 & data_GB<=20
	replace inetdata=4 if data_GB>20
	
	label define data 0 "No Data Purchase" 1 "<=5 GB" 2 "5 GB - 10 GB" 3 "10 GB - 20 GB" 4 ">20 GB"
	label val inetdata data
		
	keep wilcah hh_id ind_id phonecredit_rp inetcredit_rp inetcredit data_GB inetdata ln_phonecr_rp
	
		label var inetcredit_rp "Expenditure for mobile data credit in Rp"
		label var inetcredit 	"Expenditure for mobile data credit: group"
		label var data_GB 		"Data purchased in GB"
		label var inetdata		"Data purchased, group"
		
	foreach v of varlist phonecredit_rp inetcredit_rp inetcredit data_GB inetdata {
	    
		replace `v'=0 if `v'==.
	}
	
	sort hh_id ind_id
	save "${coded}purchase", replace
	
/*------------------------------------------------------------------------------
	STEP 3 - clean book 2_III to obtain information on access of internet
--------------------------------------------------------------------------------*/
*Open file
	use "${raw}BUKU2_BIII", clear
	
*checking ID duplicates
	unique ea_b2 buku2_id b2_cov1_id
	
*Creating ID
		rename ea_b2 wilcah //to make it consistent with other books		
		gen hh_id = buku2_id //hhid
		tostring b2_cov1_id, replace //convert no ART using 
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
		la var ind_id "individual ID"
	
	unique ind_id
	
*device use for accessing the internet
	gen inet_computer=0
		replace inet_computer=1 if biii_13a==1 | biii_13b==1
		
	gen inet_smartphone=0
		replace inet_smartphone=1 if biii_13c==1 | biii_13d==1

		
	gen inet_2Gphone=0
		replace inet_2Gphone=1 if biii_13e==1
		
	gen inet_notown=0
		replace inet_notown=1 if biii_14a==3 & biii_15==1
		
		label var inet_computer 	"Individual use computer (Laptop & PC) for accessing internet"
		label var inet_smartphone	"Individual use 3G/4G smartphone / tablet for accessing internet"
		label var inet_2Gphone		"Individual use 2G phone  for accessing internet"
		label var inet_notown		"Individual use other's device for accessing internet"

		
*period since first time using internet	(note=internet usage less than a year coded as 0.5)
	gen inet_user_year = biii_17
		replace inet_user_year=0.5 if inet_user_year==0
		replace inet_user_year=0 if inet_user_year==.
	
	gen inet_exp=biii_17
		replace inet_exp=0 if biii_17==.
		replace inet_exp=1 if biii_17<=1				& biii_17!=.				
		replace inet_exp=2 if biii_17>1 & biii_17<=5	& biii_17!=.
		replace inet_exp=3 if biii_17>5 & biii_17<=10	& biii_17!=.
		replace inet_exp=4 if biii_17>10				& biii_17!=.
		
	label var inet_exp "Individual Experience of Using Internet (Year) group"
	label var inet_user_year "How long have been using internet (year)"
	
	label define experience 0 "Never Use Internet" 1 "Less than a year" 2 " 1 - 5 years" 3 "5-10 years" 4 "> 10 years"
	label values inet_exp experience
			
*main connection used to accessing internet
	gen inet_access=biii_20
		replace inet_access=0 if inet_access==.
		
	label define access 0 "N/A" 1 "Fixed broadband" 2 "Mobile broadband" 3 "Public wifi" 5 "Others"
	label values inet_access access
		
	label var inet_access "Main connection to access the internet"
		
	keep wilcah hh_id ind_id inet_* 
	
	foreach v of varlist inet_exp inet_access inet_computer inet_smartphone inet_2Gphone inet_notown {
		replace `v'=0 if `v'==.
	}
	
	sort hh_id ind_id                         		
	save "${coded}access", replace            		
	
	
/*------------------------------------------------------------------------------
	STEP 4 - clean book 2_V to obtain information on internet usage
--------------------------------------------------------------------------------*/
*Open file
	use "${raw}BUKU2_BV", clear
	
*Creating ID
		rename ea_b2 wilcah //to make it consistent with other books		
		gen hh_id = buku2_id //hhid
		tostring b2_cov1_id, replace //convert no ART using 
		sort wilcah hh_id b2_cov1_id
		gen ind_id = wilcah + hh_id + b2_cov1_id
		la var ind_id "individual ID"
	
	unique ind_id
	
	
*keeping only important variables

	keep wilcah hh_id ind_id bv_342_type bv_345 bv_343

	
*reshaping data to wide

	reshape wide bv_345 bv_343 , i(wilcah hh_id ind_id) j(bv_342_type) string
	
*recoding missing as 0 (spent 0 hours at each activity)
	foreach v of varlist bv_345A bv_345B bv_345C bv_345D bv_345E bv_345G bv_345H bv_345I bv_345J bv_345K bv_345L bv_345M {
		
		replace `v'=0 if `v'==. 
	}

/*  define productive usage of internet as: 
	b. Mengirim dan/atau menerima email 
	c. Pencarian informasi 
	d. Mengembangkan dan mengunggah konten digital 
	h. Menjual barang dan/atau jasa secara online melalui platform marketplace digital 
	j. Mencari dan/atau melamar pekerjaan dan freelancing online (misalnya, dengan menggunakan frellancer.com, tukang.com, sejasa.com, linkedin, dsb.)
	
	define entertainment usage of internet as:
	a. Komunikasi melalui pesan online 
	e. Kegiatan santai dan hiburan melalui internet  
	m. Menonton televisi
	
	define accessing service as:
	g. Membeli barang dan/atau jasa online dengan menggunakan platform marketplace digital 
	i. Reservasi travel 
	k. Jasa keuangan online
	l. Layanan ride hailing 
	
	*/
	
	gen productive_use=1 if bv_343B==1 | bv_343C==1 | bv_343D==1 | bv_343H==1 | bv_343J==1
		replace productive_use=0 if productive_use==. 
		label var productive_use "1 if individual use internet for productive usage"
		
	gen entertainment_use=1 if bv_343A==1 | bv_343E==1 | bv_343M==1
		replace entertainment_use=0 if entertainment_use==.
		label var entertainment_use "1 if individual use internet for entertainment usage"
		
	gen service_use=1 if bv_343G==1 | bv_343I==1 | bv_343K==1 | bv_343L==1
		replace service_use=0 if service_use==.
		label var service_use "1 if individual use internet for service usage"

		
	*Creating duration for each usage
	
	egen productive_use_hr		= rowtotal(bv_345B bv_345C bv_345D bv_345H bv_345J) if productive_use==1
		 replace productive_use_hr=0 if productive_use_hr==.
		 label var productive_use_hr "Duration for productive usage, hour"		

	egen entertainment_use_hr	= rowtotal(bv_345A bv_345E bv_343M) if entertainment_use==1
		 replace entertainment_use_hr=0 if entertainment_use_hr==.
		 label var entertainment_use_hr "Duration for entertainment usage, hour"
	
	egen service_use_hr			= rowtotal(bv_345G  bv_345I  bv_345K  bv_345L) if service_use==1
		 replace service_use_hr=0 if service_use_hr==.
		 label var service_use_hr "Duration for service usage, hour"
		 
	ren bv_343A use_messaging
	ren bv_343B use_emails
	ren bv_343C use_infosrch
	ren bv_343D use_contentcrt
	ren bv_343E use_leisure
	ren bv_343G use_shop
	ren bv_343H use_selling
	ren bv_343I use_travelrsvp
	ren bv_343J use_jobsrch
	ren bv_343K use_finsrv
	ren bv_343L use_ridehail
	ren bv_343M use_tvonline
	
		label var use_messaging		"1 if individual use internet for messaging"
		label var use_emails		"1 if individual use internet for emails"
		label var use_infosrch		"1 if individual use internet for information searching"
		label var use_contentcrt	"1 if individual use internet for upload contents"
		label var use_leisure		"1 if individual use internet for leisure"
		label var use_shop			"1 if individual use internet for buying"
		label var use_selling		"1 if individual use internet for selling"
		label var use_travelrsvp	"1 if individual use internet for travel reservation"
		label var use_jobsrch		"1 if individual use internet for job seraching"
		label var use_finsrv		"1 if individual use internet for accessing financial service"
		label var use_ridehail		"1 if individual use internet for ride hailing apps"
		label var use_tvonline		"1 if individual use internet for watching tv online"

		
	*keeping important variables
	keep wilcah hh_id ind_id productive* entertainment* service* use_*
	
	sort wilcah hh_id ind_id
	save "${coded}activity", replace
	
/*---------------------------------------------------------------------------
Merging all files
*/
	
	use "${coded}access", clear
	
	merge 1:1 ind_id using "${coded}activity"
	*ALL M!=3 are individuals who never use internet, change var values for inet indicators from .==0
		foreach x of varlist productive_use entertainment_use service_use productive_use_hr entertainment_use_hr service_use_hr {
			replace `x'=0 if `x'==.
		} 
	drop _m
		

	merge 1:1 ind_id using "${coded}purchase"
	*ALL M!=3 are individuals who never use internet, change var values for inet indicators from .==0
		foreach x of varlist phonecredit_rp inetcredit_rp inetcredit data_GB inetdata  {
			replace `x'=0 if `x'==.
		}
	drop _m
	
	merge 1:1 hh_id ind_id using "${coded}device"
	drop _merge
	
	sort wilcah hh_id ind_id	
	save "${coded}internet_usage", replace
	
	
	






	
	
	
	
	
	
