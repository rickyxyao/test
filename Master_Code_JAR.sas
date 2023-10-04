/*Table of Contents*/
/*1. Create Limit_Discr (called dscore*-1 in code)*/
	/*a. Create 10k word count*/
	/*b. Create Relative Importance*/
	/*c. Analysis of link with codification*/		
	/*d. Create link with codification*/
	/*e. Create modal counts rr1z*/
	/*f. Create alternative measure orthogonalized to Length*/
	/*g. Create alternative measure orthogonalized to RBC*/
	/*h. Create number of standards*/
	/*i. Create shall21rraz*/
	/*j. Create alternative measure recognition only*/




/*2. SAS CREATE DATA FOR MAIN TESTS */
	/*a. Main_tests*/
		/*i.create non_gaap1*/
		/*ii.create inst_own*/
		
	/*b. Main_robustness*/

	/*c. MD&A Tests*/	
	
	/*d. MD&A Robustness*/

	/*e. Validate D_SCORE/Non-GAAP Difference in Difference*/

	/*f. Appendix B of paper*/
		/*i.Table B1*/
		/*ii.TABLE B4*/
	/*g. Replicate Folsom et al.*/
		/*i.create limit_discr for Folsom sample*/
			/*x.Create rel_imp for folsom sample*/
			/*xx.create limit_discr*/
		/*ii. create dataset exported to stata*/

	/*h. examine what types of forecasts are most prevalent*/


/*3. STATA CODE*/
	




	












/*BEGIN:1. Create Limit_Discr (called dscore in code)*/
	/*BEGIN: a. Create 10k word count*/
			
		/*assign library*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';



		*Import word count datasets to designate treatment and control firms;
		PROC IMPORT OUT= WORK.KeyWords
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\nonames.xlsx"
		      DBMS=xlsx REPLACE;
		      GETNAMES=YES;
		  
		RUN;

		PROC IMPORT OUT= WORK.Names
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\names.xlsx"
		       DBMS=xlsx REPLACE;
		      GETNAMES=YES;
		     
		RUN;

		*combine related standards in names count dataset;
		data data1; set names; 
			arb43_3aREVISE = arb43_3a + fas6;
			fas34REVISE = fas34 + fas42 + fas58;
			fas13REVISE = fas13 + fas17 + fas23 + fas27 + fas91 + fas98;
			apb16REVISE = apb16 + fas38;
			fas35REVISE = fas35 + fas59;
			fas19REVISE = fas19 + fas69;
			fas71REVISE = fas71 + fas90;
			arb51REVISE = arb51 + fas94;
			fas5REVISE = fas5 + fas112 + fas114 + fin14;
			fas114REVISE = fas114 + fas118;
			fas133REVISE = fas133 + fas138;
			apb29REVISE = apb29 + fas153;
			sab101REVISE = sab101 + sab104;
			drop 	arb43_3a fas34 fas13 apb16 fas35 fas19 fas71 arb51 fas5	fas114 fas133 apb29 sab101;
		run;

		data data2; set data1;
			arb43_3a =arb43_3aREVISE;
			fas34 = fas34REVISE;
			fas13 = fas13REVISE;
			apb16 = apb16REVISE;
			fas35 =fas35REVISE;
			fas19 =fas19REVISE;
			fas71 =fas71REVISE;
			arb51 =arb51REVISE;
			fas5 =fas5REVISE;
			fas114 =fas114REVISE;
			fas133 =fas133REVISE;
			apb29 =apb29REVISE;
			sab101 =sab101REVISE;
		 	drop arb43_3aREVISE fas34REVISE fas13REVISE apb16REVISE fas35REVISE fas19REVISE fas71REVISE arb51REVISE fas5REVISE fas114REVISE fas133REVISE apb29REVISE sab101REVISE;
		run;

		*combine names and key word searches counts;
		proc sql;
			create table data3
			as select a.cik, a.file_date, a.accession, a.len, a.Apb25 as apb25a, a.Apb2 as apb2a, a.Apb4 as apb4a, a.Apb9 as apb9a, a.Apb14 as apb14a, a.Apb16 as apb16a, a.Apb17 as apb17a, a.Apb18 as apb18a, a.Apb20 as apb20a, a.Apb21 as apb21a, a.Apb23 as apb23a, a.Apb26 as apb26a, a.Apb29 as apb29a, a.Apb30 as apb30a, a.Arb45 as arb45a, a.Arb51 as arb51a, a.Arb43_2a as arb43_2aa, 
				a.Arb43_3a as arb43_3aa, a.Arb43_3b as arb43_3ba, a.Arb43_4 as arb43_4a, a.Arb43_7a as arb43_7aa, a.Arb43_7b as arb43_7ba, a.Arb43_9a as arb43_9aa, a.Arb43_9b as arb43_9ba, a.Arb43_10a as arb43_10aa, a.Arb43_11a as arb43_11aa, a.Arb43_11b as arb43_11ba, a.Arb43_11c as arb43_11ca,
				a.Arb43_12 as arb43_12a, a.Con5_6 as con5_6a, a.Eitf00_21 as Eitf00_21a, a.Eitf94_03 as Eitf94_03a, a.Fas2 as fas2a, a.Fas5 as fas5a, a.Fas7 as fas7a, a.Fas13 as fas13a, a.Fas15 as fas15a, a.Fas16 as fas16a, a.Fas19 as fas19a, a.Fas34 as fas34a, a.Fas35 as fas35a, a.Fas43 as fas43a, a.Fas45 as fas45a, a.Fas47 as fas47a, 
				a.Fas48 as fas48a, a.Fas49 as fas49a, a.Fas50 as fas50a, a.Fas51 as fas51a, a.Fas52 as fas52a, a.Fas53 as fas53a, a.Fas57 as fas57a, a.Fas60 as fas60a, a.Fas61 as fas61a, a.Fas63 as fas63a, a.Fas65 as fas65a, a.Fas66 as fas66a, a.Fas67 as fas67a, a.Fas68 as fas68a, a.Fas71 as fas71a, a.Fas77 as fas77a, a.Fas80 as fas80a, a.Fas86 as fas86a,
				a.Fas87 as fas87a, a.Fas88 as fas88a, a.Fas97 as fas97a, a.Fas101 as fas101a, a.Fas105 as fas105a, a.Fas106 as fas106a, a.Fas107 as fas107a, a.Fas109 as fas109a, a.Fas113 as fas113a, a.Fas115 as fas115a, a.Fas116 as fas116a, a.Fas119 as fas119a, a.Fas121 as fas121a, a.Fas123 as fas123a, a.Fas123r as fas123ra, a.Fas125 as fas125a, 
				a.Fas130 as fas130a, a.Fas132 as fas132a, a.Fas132r as fas132ra, a.Fas133 as fas133a, a.Fas140 as fas140a, a.Fas141 as fas141a, a.Fas142 as fas142a, a.Fas143 as fas143a, a.Fas144 as fas144a, a.Fas146 as fas146a, a.Fas150 as fas150a, a.Fas154 as fas154a, a.Sab101 as sab101a, a.Sop97_2 as sop97_2a, a.asu2009_17 as asu2009_17a, 
				a.asu2011_08 as asu2011_08a, a.asu2012_01 as asu2012_01a, a.asu2012_02 as asu2012_02a,
				b.Apb25 as apb25b, b.Apb2 as apb2b, b.Apb4 as apb4b, b.Apb9 as apb9b, b.Apb14 as apb14b, b.Apb16 as apb16b, b.Apb17 as apb17b, b.Apb18 as apb18b, b.Apb20 as apb20b, b.Apb21 as apb21b, b.Apb23 as apb23b, b.Apb26 as apb26b, b.Apb29 as apb29b, b.Apb30 as apb30b, b.Arb45 as arb45b, b.Arb51 as arb51b, 
				b.Arb43_3a as arb43_3ab, b.Arb43_3b as arb43_3bb, b.Arb43_4 as arb43_4b, b.Arb43_7a as arb43_7ab, b.Arb43_7b as arb43_7bb, b.Arb43_9a as arb43_9ab, b.Arb43_9b as arb43_9bb, b.Arb43_10a as arb43_10ab, b.Arb43_11a as arb43_11ab, b.Arb43_11b as arb43_11bb, b.Arb43_11c as arb43_11cb,
				b.Arb43_12 as arb43_12b, b.Con5_6 as con5_6b, b.Eitf00_21 as Eitf00_21b, b.Eitf94_03 as Eitf94_03b, b.Fas2 as fas2b, b.Fas5 as fas5b, b.Fas7 as fas7b, b.Fas13 as fas13b, b.Fas15 as fas15b, b.Fas16 as fas16b, b.Fas19 as fas19b, b.Fas34 as fas34b, b.Fas35 as fas35b, b.Fas43 as fas43b, b.Fas45 as fas45b, b.Fas47 as fas47b, 
				b.Fas48 as fas48b, b.Fas49 as fas49b, b.Fas50 as fas50b, b.Fas51 as fas51b, b.Fas52 as fas52b, b.Fas53 as fas53b, b.Fas57 as fas57b, b.Fas60 as fas60b, b.Fas61 as fas61b, b.Fas63 as fas63b, b.Fas65 as fas65b, b.Fas66 as fas66b, b.Fas67 as fas67b, b.Fas68 as fas68b, b.Fas71 as fas71b, b.Fas77 as fas77b, b.Fas80 as fas80b, b.Fas86 as fas86b,
				b.Fas87 as fas87b, b.Fas88 as fas88b, b.Fas97 as fas97b, b.Fas101 as fas101b, b.Fas105 as fas105b, b.Fas106 as fas106b, b.Fas107 as fas107b, b.Fas109 as fas109b, b.Fas113 as fas113b, b.Fas115 as fas115b, b.Fas116 as fas116b, b.Fas119 as fas119b, b.Fas121 as fas121b, b.Fas123 as fas123b, b.Fas123r as fas123rb, b.Fas125 as fas125b, 
				b.Fas130 as fas130b, b.Fas132 as fas132b, b.Fas132r as fas132rb, b.Fas133 as fas133b, b.Fas140 as fas140b, b.Fas141 as fas141b, b.Fas142 as fas142b, b.Fas143 as fas143b, b.Fas144 as fas144b, b.Fas146 as fas146b, b.Fas150 as fas150b, b.Fas154 as fas154b, b.Sab101 as sab101b, b.Sop97_2 as sop97_2b, b.asu2009_17 as asu2009_17b, 
				b.asu2011_08 as asu2011_08b, b.asu2012_01 as asu2012_01b, b.asu2012_02 as asu2012_02b
			from data2 as a 
			left join keywords as b
			on a.accession = b.accession and a.cik = b.cik;
		quit;

		data data4; set data3;
			Apb25= apb25a+apb25b; Apb2= apb2a +apb2b; Apb4= apb4a+apb4b; Apb9= apb9a+apb9b; Apb14= apb14a+apb14b; Apb16= apb16a+apb16b; 
			Apb17= apb17a+apb17b; Apb18= apb18a+apb18b; Apb20= apb20a+apb20b; Apb21= apb21a+apb21b;	Apb23= apb23a+apb23b; 
			Apb26= apb26a+apb26b; Apb29= apb29a+apb29b; Apb30= apb30a+apb30b; Arb45= arb45a+arb45b; Arb51= arb51a+arb51b; Arb43_2a= arb43_2aa; 
			Arb43_3a= arb43_3aa+arb43_3ab; Arb43_3b= arb43_3ba+arb43_3bb; Arb43_4= arb43_4a+arb43_4b; Arb43_7a= arb43_7aa+arb43_7ab; 
			Arb43_7b= arb43_7ba+arb43_7bb; Arb43_9a= arb43_9aa+arb43_9ab; Arb43_9b= arb43_9ba+arb43_9bb; Arb43_10a= arb43_10aa+arb43_10ab; 
			Arb43_11a= arb43_11aa+arb43_11ab; Arb43_11b= arb43_11ba+arb43_11bb; Arb43_11c= arb43_11ca+arb43_11cb; Arb43_12= arb43_12a+arb43_12b; 
			Con5_6= con5_6a+con5_6b; Eitf00_21= eitf00_21a +eitf00_21b; Eitf94_03= eitf94_03a+eitf94_03b; Fas2= fas2a+fas2b; Fas5= fas5a+fas5b; 
			Fas7= fas7a + fas7b; Fas13= fas13a+fas13b; Fas15= fas15a+fas15b; Fas16= fas16a+fas16b; Fas19= fas19a+fas19b; Fas34= fas34a+fas34b; 
			Fas35= fas35a+fas35b; Fas43= fas43a+fas43b; Fas45= fas45a+fas45b; Fas47= fas47a+fas47b;	Fas48= fas48a+fas48b; Fas49= fas49a+fas49b; 
			Fas50= fas50a+fas50b; Fas51= fas51a+fas51b; Fas52= fas52a+fas52b; Fas53= fas53a+fas53b; Fas57= fas57a+fas57b; Fas60= fas60a+fas60b; 
			Fas61= fas61a+fas61b; Fas63= fas63a+fas63b; Fas65= fas65a+fas65b; Fas66= fas66a+fas66b; Fas67= fas67a+fas67b; Fas68= fas68a+fas68b; 
			Fas71= fas71a+fas71b; Fas77= fas77a+fas77b; Fas80= fas80a+fas80b; Fas86= fas86a+fas86b; Fas87= fas87a+fas87b; Fas88= fas88a+fas88b; 
			Fas97= fas97a+fas97b; Fas101= fas101a+fas101b; Fas105= fas105a+fas105b; Fas106= fas106a+fas106b; Fas107= fas107a+fas107b; Fas109= fas109a+fas109b; 
			Fas113= fas113a+fas113b; Fas115= fas115a+fas115b; Fas116= fas116a+fas116b; Fas119= fas119a+fas119b; Fas121= fas121a+fas121b; Fas123= fas123a+fas123b; 
			Fas123r= fas123ra+fas123rb; Fas125= fas125a+fas125b; Fas130= fas130a+fas130b; Fas132=fas132a+fas132b; Fas132r= fas132ra+fas132rb; 
			Fas133= fas133a+fas133b; Fas140= fas140a+fas140b; Fas141= fas141a+fas141b; Fas142= fas142a+fas142b; Fas143= fas143a+fas143b; Fas144= fas144a+fas144b; 
			Fas146= fas146a+fas146b; Fas150= fas150a+fas150b; Fas154= fas154a+fas154b; Sab101= sab101a+sab101b; Sop97_2= sop97_2a+sop97_2b; 
			asu2009_17= asu2009_17a+asu2009_17b; asu2011_08= asu2011_08a+asu2011_08b; asu2012_01=asu2012_01a+asu2012_01b ; asu2012_02=asu2012_02a+asu2012_02b;
		keep cik file_date accession len Apb25 Apb2 Apb4 Apb9 Apb14 Apb16 Apb17 Apb18 Apb20 Apb21 Apb23 Apb26 Apb29 Apb30 
			Arb45 Arb51 Arb43_2a Arb43_3a Arb43_3b Arb43_4 Arb43_7a Arb43_7b Arb43_9a Arb43_9b Arb43_10a Arb43_11a Arb43_11b 
			Arb43_11c Arb43_12 Con5_6 Eitf00_21 Eitf94_03 Fas2 Fas5 Fas7 Fas13 Fas15 Fas16 Fas19 Fas34 Fas35 Fas43 Fas45 Fas47 
			Fas48 Fas49 Fas50 Fas51 Fas52 Fas53 Fas57 Fas60 Fas61 Fas63 Fas65 Fas66 Fas67 Fas68 Fas71 Fas77 Fas80 Fas86 
			Fas87 Fas88 Fas97 Fas101 Fas105 Fas106 Fas107 Fas109 Fas113 Fas115 Fas116 Fas119 Fas121 Fas123 Fas123r Fas125 
			Fas130 Fas132 Fas132r Fas133 Fas140 Fas141 Fas142 Fas143 Fas144 Fas146 Fas150 Fas154 Sab101 Sop97_2 asu2009_17 
			asu2011_08 asu2012_01 asu2012_02;
		run;

		data data5; set data4;
		if Apb25 = . or Apb2= . or Apb4 =. or Apb9=. or Apb14=. or  Apb16=. or  Apb17=. or 
			Apb18 =. or Apb20 =. or Apb21 =. or Apb23=. or  Apb26=. or  Apb29=. or  Apb30=. or  Arb45=. or  Arb51=. or  
			Arb43_2a=. or  Arb43_3a =. or Arb43_3b=. or  Arb43_4=. or  Arb43_7a=. or  Arb43_7b=. or  Arb43_9a=. or  Arb43_9b=. or  Arb43_10a=. or 
			Arb43_11a=. or  Arb43_11b=. or  Arb43_11c=. or Arb43_12 =. or Con5_6 =. or Eitf00_21=. or  Eitf94_03=. or 
			Fas2=. or  Fas5=. or  Fas7=. or  Fas13=. or  Fas15=. or  Fas16=. or  Fas19=. or  Fas34=. or  Fas35=. or  Fas43=. or  Fas45=. or  Fas47=. or  
			Fas48=. or  Fas49=. or  Fas50=. or  Fas51=. or  Fas52=. or  Fas53=. or  Fas57=. or  Fas60=. or  Fas61=. or  Fas63=. or  Fas65=. or  Fas66=. or  Fas67=. or  Fas68=. or 
			Fas71=. or  Fas77=. or  Fas80=. or  Fas86=. or Fas87=. or  Fas88=. or  Fas97=. or  Fas101=. or  Fas105=. or  Fas106=. or  Fas107=. or  Fas109=. or 
			Fas113=. or  Fas115=. or  Fas116=. or  Fas119=. or  Fas121=. or  Fas123=. or  Fas123r=. or  Fas125=. or  
			Fas130=. or  Fas132=. or  Fas132r=. or  Fas133=. or  Fas140=. or  Fas141=. or  Fas142=. or  Fas143=. or  Fas144=. or  Fas146=. or  Fas150=. or 
			Fas154=. or  Sab101=. or  Sop97_2=. or  asu2009_17=. or  asu2011_08=. or  asu2012_01=. or  asu2012_02=. then delete;
		run; 

		data dperm.data5; set data5;run;
		data data5; set dperm.data5;run;

		/*The following gets datadate for each observation*/

		PROC IMPORT OUT= WORK.LMa
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\LM_first_half.csv"
		      DBMS=csv REPLACE;
		      GETNAMES=YES;
		  guessingrows=10000;
		RUN;

		PROC IMPORT OUT= WORK.LM2
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\LM_second_half.csv"
		      DBMS=csv REPLACE;
		      GETNAMES=YES;
		  guessingrows=10000;
		RUN;

		data dperm.lm; set lma lm2;run;
		data lm; set dperm.lm;run;


		data lm1;
				set lm;

				format date_filed date9.;
				format fiscal_year_ended date9.;

				informat date_filed date9.;
				informat fiscal_year_ended date9.;

				date_filed = file_date;
				fiscal_year_ended = conf_per_rpt;
				cikn = cik * 1;
				type = conf_subtype;
				accession_id = acc_num;

				format datadate YYMMDDN8.;
				informat datadate 8.;
				datadate = input(put(conf_per_rpt,8.),yymmdd8.);
			run; quit;

		proc sort data=lm1 out=lm2 nodupkey;by f_cik f_fdate f_ftype f_year acc_num;run;

		data lm3;
			set lm2;

			if prxmatch("!(10-K|10K)!i",conf_subtype) > 0 and not missing(cikn) and not missing(datadate);
		run; quit;



		proc sql;
			create table 	data6
			as select 		a.*, b.*
			from 			data5 as a left join lm3 as b
			on	 			a.cik = b.f_cik 
								and not missing(a.cik) and not missing(b.f_cik) 
								and a.accession = b.acc_num  ;
		quit;




		data dperm.tenK_wordcounts; set data6;
		drop b_num ba_csa ba_cbsa ba_msa ba_county var51 ba_contiguous_state ba_is_state ba_population ba_longitude ba_latitude ma_zip5 ba_zip5 filer_number number_of_filers former_name date_of_name_chg ma_zip9
		ma_state ma_city ma_street2 ma_street1 ba_phone ba_zip9 ba_state ba_city ba_street2 ba_street1 film_num irs_num sic_label comp_conf_name pdoc_cnt accpt_datetime;
		run;

	/*END: a. Create 10k word count*/
	/*BEGIN: b.Create Relative Importance*/





		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/

		data wc; set dperm.tenK_wordcounts;
		if datadate ne .;
		run;

		/*identify those that are ammended 10ks*/
		data wc1; set wc;
		if find(f_ftype,'A') ge 1 then delete=1;
		run;

		/*create dataset of only ammended*/
		data amm; set wc1;
		if delete=1;
		*keep cik datadate delete;
		run;

		/*create dataset with no ammendeds*/
		data wc2; set wc1;
		if delete ne 1;
		run;


		/*delete any 10k that was ever ammended*/
		proc sql;
			create table 	wc3
			as select 		a.*, b.delete as d, b.cik as bcik, b.datadate as bdate
			from 			wc2 as a left join amm as b
			on	 			a.cik = b.cik 
								and a.datadate = b.datadate  ;
		quit;


		data wc4; set wc3;
		if d eq .;
		run;

		proc sort data=wc4 out=wc5 nodupkey; by cik accession;run;


		/*create Rel_imp measure*/


		data link; set byu.gvkey_permno_link2017nov30;
		cik1=cik/1;
		run;

		proc sql; create table link1 as select
		a.*, b.fyear
		from link as a left join wrds.comp b
		on a.gvkey=b.gvkey
		and a.datadate eq b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=link1 out=link2 nodupkey; by gvkey datadate;
		run;

		data  wc6; set wc5;
		if fyear eq . and month(datadate) le 5 then fyear=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then fyear=year(datadate);
		run;

		proc sql; create table ps1 as select
		a.*, b.permno, b.gvkey,b.fyear as fyear1, b.datadate as datadate1
		from wc6 as a left join link2 as b
		on a.cik=b.cik1
		and (a.fyear eq b.fyear or (intnx('day',a.datadate,-20) <= b.datadate <= intnx('day',a.datadate,20)))
		order by cik, datadate;
		quit;


		/*create annual average count and annual std_dev(firm_count)*/
		/*WARNING: the word counts for a standard can be positive prior
		to the standard being passed*/
		proc sql; create table ps2 as select distinct
		fyear,
						avg(apb25) as avg_apb25, std(apb25) as std_apb25,
						avg(apb2) as avg_apb2, std(apb2) as std_apb2,
						avg(apb4) as avg_apb4, std(apb4) as std_apb4,
						avg(apb9) as avg_apb9, std(apb9) as std_apb9,
						avg(apb14) as avg_apb14, std(apb14) as std_apb14,
						avg(apb16) as avg_apb16, std(apb16) as std_apb16,
						avg(apb17) as avg_apb17, std(apb17) as std_apb17,
						avg(apb18) as avg_apb18, std(apb18) as std_apb18,
						avg(apb20) as avg_apb20, std(apb20) as std_apb20,
						avg(apb21) as avg_apb21, std(apb21) as std_apb21,
						avg(apb23) as avg_apb23, std(apb23) as std_apb23,
						avg(apb26) as avg_apb26, std(apb26) as std_apb26,
						avg(apb29) as avg_apb29, std(apb29) as std_apb29,
						avg(apb30) as avg_apb30, std(apb30) as std_apb30,
						avg(arb45) as avg_arb45, std(arb45) as std_arb45,
						avg(arb51) as avg_arb51, std(arb51) as std_arb51,
						avg(arb43_2a) as avg_arb43_2a, std(arb43_2a) as std_arb43_2a,
						avg(arb43_3a) as avg_arb43_3a, std(arb43_3a) as std_arb43_3a,
						avg(arb43_3b) as avg_arb43_3b, std(arb43_3b) as std_arb43_3b,
						avg(arb43_4) as avg_arb43_4, std(arb43_4) as std_arb43_4,
						avg(arb43_7a) as avg_arb43_7a, std(arb43_7a) as std_arb43_7a,
						avg(arb43_7b) as avg_arb43_7b, std(arb43_7b) as std_arb43_7b,
						avg(arb43_9a) as avg_arb43_9a, std(arb43_9a) as std_arb43_9a,
						avg(arb43_9b) as avg_arb43_9b, std(arb43_9b) as std_arb43_9b,
						avg(arb43_10a) as avg_arb43_10a, std(arb43_10a) as std_arb43_10a,
						avg(arb43_11a) as avg_arb43_11a, std(arb43_11a) as std_arb43_11a,
						avg(arb43_11b) as avg_arb43_11b, std(arb43_11b) as std_arb43_11b,
						avg(arb43_11c) as avg_arb43_11c, std(arb43_11c) as std_arb43_11c,
						avg(arb43_12) as avg_arb43_12, std(arb43_12) as std_arb43_12,
						avg(con5_6) as avg_con5_6, std(con5_6) as std_con5_6,
						avg(eitf00_21) as avg_eitf00_21, std(eitf00_21) as std_eitf00_21,
						avg(eitf94_03) as avg_eitf94_03, std(eitf94_03) as std_eitf94_03,
						avg(fas2) as avg_fas2, std(fas2) as std_fas2,
						avg(fas5) as avg_fas5, std(fas5) as std_fas5,
						avg(fas7) as avg_fas7, std(fas7) as std_fas7,
						avg(fas13) as avg_fas13, std(fas13) as std_fas13,
						avg(fas15) as avg_fas15, std(fas15) as std_fas15,
						avg(fas16) as avg_fas16, std(fas16) as std_fas16,
						avg(fas19) as avg_fas19, std(fas19) as std_fas19,
						avg(fas34) as avg_fas34, std(fas34) as std_fas34,
						avg(fas35) as avg_fas35, std(fas35) as std_fas35,
						avg(fas43) as avg_fas43, std(fas43) as std_fas43,
						avg(fas45) as avg_fas45, std(fas45) as std_fas45,
						avg(fas47) as avg_fas47, std(fas47) as std_fas47,
						avg(fas48) as avg_fas48, std(fas48) as std_fas48,
						avg(fas49) as avg_fas49, std(fas49) as std_fas49,
						avg(fas50) as avg_fas50, std(fas50) as std_fas50,
						avg(fas51) as avg_fas51, std(fas51) as std_fas51,
						avg(fas52) as avg_fas52, std(fas52) as std_fas52,
						avg(fas53) as avg_fas53, std(fas53) as std_fas53,
						avg(fas57) as avg_fas57, std(fas57) as std_fas57,
						avg(fas60) as avg_fas60, std(fas60) as std_fas60,
						avg(fas61) as avg_fas61, std(fas61) as std_fas61,
						avg(fas63) as avg_fas63, std(fas63) as std_fas63,
						avg(fas65) as avg_fas65, std(fas65) as std_fas65,
						avg(fas66) as avg_fas66, std(fas66) as std_fas66,
						avg(fas67) as avg_fas67, std(fas67) as std_fas67,
						avg(fas68) as avg_fas68, std(fas68) as std_fas68,
						avg(fas71) as avg_fas71, std(fas71) as std_fas71,
						avg(fas77) as avg_fas77, std(fas77) as std_fas77,
						avg(fas80) as avg_fas80, std(fas80) as std_fas80,
						avg(fas86) as avg_fas86, std(fas86) as std_fas86,
						avg(fas87) as avg_fas87, std(fas87) as std_fas87,
						avg(fas88) as avg_fas88, std(fas88) as std_fas88,
						avg(fas97) as avg_fas97, std(fas97) as std_fas97,
						avg(fas101) as avg_fas101, std(fas101) as std_fas101,
						avg(fas105) as avg_fas105, std(fas105) as std_fas105,
						avg(fas106) as avg_fas106, std(fas106) as std_fas106,
						avg(fas107) as avg_fas107, std(fas107) as std_fas107,
						avg(fas109) as avg_fas109, std(fas109) as std_fas109,
						avg(fas113) as avg_fas113, std(fas113) as std_fas113,
						avg(fas115) as avg_fas115, std(fas115) as std_fas115,
						avg(fas116) as avg_fas116, std(fas116) as std_fas116,
						avg(fas119) as avg_fas119, std(fas119) as std_fas119,
						avg(fas121) as avg_fas121, std(fas121) as std_fas121,
						avg(fas123) as avg_fas123, std(fas123) as std_fas123,
						avg(fas123r) as avg_fas123r, std(fas123r) as std_fas123r,
						avg(fas125) as avg_fas125, std(fas125) as std_fas125,
						avg(fas130) as avg_fas130, std(fas130) as std_fas130,
						avg(fas132) as avg_fas132, std(fas132) as std_fas132,
						avg(fas132r) as avg_fas132r, std(fas132r) as std_fas132r,
						avg(fas133) as avg_fas133, std(fas133) as std_fas133,
						avg(fas140) as avg_fas140, std(fas140) as std_fas140,
						avg(fas141) as avg_fas141, std(fas141) as std_fas141,
						avg(fas142) as avg_fas142, std(fas142) as std_fas142,
						avg(fas143) as avg_fas143, std(fas143) as std_fas143,
						avg(fas144) as avg_fas144, std(fas144) as std_fas144,
						avg(fas146) as avg_fas146, std(fas146) as std_fas146,
						avg(fas150) as avg_fas150, std(fas150) as std_fas150,
						avg(fas154) as avg_fas154, std(fas154) as std_fas154,
						avg(sab101) as avg_sab101, std(sab101) as std_sab101,
						avg(sop97_2) as avg_sop97_2, std(sop97_2) as std_sop97_2,
						avg(asu2009_17) as avg_asu2009_17, std(asu2009_17) as std_asu2009_17,
						avg(asu2011_08) as avg_asu2011_08, std(asu2011_08) as std_asu2011_08,
						avg(asu2012_01) as avg_asu2012_01, std(asu2012_01) as std_asu2012_01,
						avg(asu2012_02) as avg_asu2012_02, std(asu2012_02) as std_asu2012_02
						

		from ps1 group by fyear
		order by fyear;
		quit;

		proc sql; create table ps3 as select
		a.*, b.*
		from ps1 as a left join ps2 as b
		on a.fyear eq b.fyear
		order by cik, fyear;
		quit;

		/*create raw rel_imp*/

		data ps4; set ps3;
		r_apb25= (apb25 -avg_apb25)/std_apb25;
		r_apb2= (apb2 -avg_apb2)/std_apb2;
		r_apb4= (apb4 -avg_apb4)/std_apb4;
		r_apb9= (apb9 -avg_apb9)/std_apb9;
		r_apb14= (apb14 -avg_apb14)/std_apb14;
		r_apb16= (apb16 -avg_apb16)/std_apb16;
		r_apb17= (apb17 -avg_apb17)/std_apb17;
		r_apb18= (apb18 -avg_apb18)/std_apb18;
		r_apb20= (apb20 -avg_apb20)/std_apb20;
		r_apb21= (apb21 -avg_apb21)/std_apb21;
		r_apb23= (apb23 -avg_apb23)/std_apb23;
		r_apb26= (apb26 -avg_apb26)/std_apb26;
		r_apb29= (apb29 -avg_apb29)/std_apb29;
		r_apb30= (apb30 -avg_apb30)/std_apb30;
		r_arb45= (arb45 -avg_arb45)/std_arb45;
		r_arb51= (arb51 -avg_arb51)/std_arb51;
		r_arb43_2a= (arb43_2a -avg_arb43_2a)/std_arb43_2a;
		r_arb43_3a= (arb43_3a -avg_arb43_3a)/std_arb43_3a;
		r_arb43_3b= (arb43_3b -avg_arb43_3b)/std_arb43_3b;
		r_arb43_4= (arb43_4 -avg_arb43_4)/std_arb43_4;
		r_arb43_7a= (arb43_7a -avg_arb43_7a)/std_arb43_7a;
		r_arb43_7b= (arb43_7b -avg_arb43_7b)/std_arb43_7b;
		r_arb43_9a= (arb43_9a -avg_arb43_9a)/std_arb43_9a;
		r_arb43_9b= (arb43_9b -avg_arb43_9b)/std_arb43_9b;
		r_arb43_10a= (arb43_10a -avg_arb43_10a)/std_arb43_10a;
		r_arb43_11a= (arb43_11a -avg_arb43_11a)/std_arb43_11a;
		r_arb43_11b= (arb43_11b -avg_arb43_11b)/std_arb43_11b;
		r_arb43_11c= (arb43_11c -avg_arb43_11c)/std_arb43_11c;
		r_arb43_12= (arb43_12 -avg_arb43_12)/std_arb43_12;
		r_con5_6= (con5_6 -avg_con5_6)/std_con5_6;
		r_eitf00_21= (eitf00_21 -avg_eitf00_21)/std_eitf00_21;
		r_eitf94_03= (eitf94_03 -avg_eitf94_03)/std_eitf94_03;
		r_fas2= (fas2 - avg_fas2)/std_fas2;
		r_fas5= (fas5 - avg_fas5)/std_fas5;
		r_fas7= (fas7 - avg_fas7)/std_fas7;
		r_fas13= (fas13 - avg_fas13)/std_fas13;
		r_fas15= (fas15 - avg_fas15)/std_fas15;
		r_fas16= (fas16 - avg_fas16)/std_fas16;
		r_fas19= (fas19 - avg_fas19)/std_fas19;
		r_fas34= (fas34 - avg_fas34)/std_fas34;
		r_fas35= (fas35 - avg_fas35)/std_fas35;
		r_fas43= (fas43 - avg_fas43)/std_fas43;
		r_fas45= (fas45 - avg_fas45)/std_fas45;
		r_fas47= (fas47 - avg_fas47)/std_fas47;
		r_fas48= (fas48 - avg_fas48)/std_fas48;
		r_fas49= (fas49 - avg_fas49)/std_fas49;
		r_fas50= (fas50 - avg_fas50)/std_fas50;
		r_fas51= (fas51 - avg_fas51)/std_fas51;
		r_fas52= (fas52 - avg_fas52)/std_fas52;
		r_fas53= (fas53 - avg_fas53)/std_fas53;
		r_fas57= (fas57 - avg_fas57)/std_fas57;
		r_fas60= (fas60 - avg_fas60)/std_fas60;
		r_fas61= (fas61 - avg_fas61)/std_fas61;
		r_fas63= (fas63 - avg_fas63)/std_fas63;
		r_fas65= (fas65 - avg_fas65)/std_fas65;
		r_fas66= (fas66 - avg_fas66)/std_fas66;
		r_fas67= (fas67 - avg_fas67)/std_fas67;
		r_fas68= (fas68 - avg_fas68)/std_fas68;
		r_fas71= (fas71 - avg_fas71)/std_fas71;
		r_fas77= (fas77 - avg_fas77)/std_fas77;
		r_fas80= (fas80 - avg_fas80)/std_fas80;
		r_fas86= (fas86 - avg_fas86)/std_fas86;
		r_fas87= (fas87 - avg_fas87)/std_fas87;
		r_fas88= (fas88 - avg_fas88)/std_fas88;
		r_fas97= (fas97 - avg_fas97)/std_fas97;
		r_fas101= (fas101 - avg_fas101)/std_fas101;
		r_fas105= (fas105 - avg_fas105)/std_fas105;
		r_fas106= (fas106 - avg_fas106)/std_fas106;
		r_fas107= (fas107 - avg_fas107)/std_fas107;
		r_fas109= (fas109 - avg_fas109)/std_fas109;
		r_fas113= (fas113 - avg_fas113)/std_fas113;
		r_fas115= (fas115 - avg_fas115)/std_fas115;
		r_fas116= (fas116 - avg_fas116)/std_fas116;
		r_fas119= (fas119 - avg_fas119)/std_fas119;
		r_fas121= (fas121 - avg_fas121)/std_fas121;
		r_fas123= (fas123 - avg_fas123)/std_fas123;
		r_fas123r= (fas123r - avg_fas123r)/std_fas123r;
		r_fas125= (fas125 - avg_fas125)/std_fas125;
		r_fas130= (fas130 - avg_fas130)/std_fas130;
		r_fas132= (fas132 - avg_fas132)/std_fas132;
		r_fas132r= (fas132r - avg_fas132r)/std_fas132r;
		r_fas133= (fas133 - avg_fas133)/std_fas133;
		r_fas140= (fas140 - avg_fas140)/std_fas140;
		r_fas141= (fas141 - avg_fas141)/std_fas141;
		r_fas142= (fas142 - avg_fas142)/std_fas142;
		r_fas143= (fas143 - avg_fas143)/std_fas143;
		r_fas144= (fas144 - avg_fas144)/std_fas144;
		r_fas146= (fas146 - avg_fas146)/std_fas146;
		r_fas150= (fas150 - avg_fas150)/std_fas150;
		r_fas154= (fas154 - avg_fas154)/std_fas154;
		r_sab101= (sab101 - avg_sab101)/std_sab101;
		r_sop97_2= (sop97_2 - avg_sop97_2)/std_sop97_2;
		r_asu2009_17 = (asu2009_17 - avg_asu2009_17)/std_asu2009_17;
		r_asu2011_08 = (asu2011_08 - avg_asu2011_08)/std_asu2011_08;
		r_asu2012_01 = (asu2012_01 - avg_asu2012_01)/std_asu2012_01;
		r_asu2012_02 = (asu2012_02 - avg_asu2012_02)/std_asu2012_02;
						
		run;


		/*create minimum rel_imp per year*/

		proc sql; create table ps5 as select distinct
		fyear,
						min(r_apb25) as min_apb25, 
						min(r_apb2) as min_apb2, 
						min(r_apb4) as min_apb4, 
						min(r_apb9) as min_apb9, 
						min(r_apb14) as min_apb14, 
						min(r_apb16) as min_apb16, 
						min(r_apb17) as min_apb17,				
						min(r_apb18) as min_apb18, 
						min(r_apb20) as min_apb20, 
						min(r_apb21) as min_apb21, 
						min(r_apb23) as min_apb23, 
						min(r_apb26) as min_apb26, 
						min(r_apb29) as min_apb29, 
						min(r_apb30) as min_apb30, 
						min(r_arb45) as min_arb45, 
						min(r_arb51) as min_arb51, 
				min(r_arb43_2a) as min_arb43_2a,
				min(r_arb43_3a) as min_arb43_3a, 
				min(r_arb43_3b) as min_arb43_3b, 
				min(r_arb43_4) as min_arb43_4, 
				min(r_arb43_7a) as min_arb43_7a, 
				min(r_arb43_7b) as min_arb43_7b,
				min(r_arb43_9a) as min_arb43_9a, 
				min(r_arb43_9b) as min_arb43_9b, 
				min(r_arb43_10a) as min_arb43_10a, 
				min(r_arb43_11a) as min_arb43_11a,
				min(r_arb43_11b) as min_arb43_11b, 
				min(r_arb43_11c) as min_arb43_11c, 
				min(r_arb43_12) as min_arb43_12, 
				min(r_con5_6) as min_con5_6, 
				min(r_eitf00_21) as min_eitf00_21, 
				min(r_eitf94_03) as min_eitf94_03, 
						min(r_fas2) as min_fas2, 
						min(r_fas5) as min_fas5, 
						min(r_fas7) as min_fas7, 
						min(r_fas13) as min_fas13, 
						min(r_fas15) as min_fas15, 
						min(r_fas16) as min_fas16, 
						min(r_fas19) as min_fas19, 
						min(r_fas34) as min_fas34, 
						min(r_fas35) as min_fas35, 
						min(r_fas43) as min_fas43, 
						min(r_fas45) as min_fas45, 
						min(r_fas47) as min_fas47, 
						min(r_fas48) as min_fas48, 
						min(r_fas49) as min_fas49, 
						min(r_fas50) as min_fas50, 
						min(r_fas51) as min_fas51, 
						min(r_fas52) as min_fas52, 
						min(r_fas53) as min_fas53, 
						min(r_fas57) as min_fas57, 
						min(r_fas60) as min_fas60, 
						min(r_fas61) as min_fas61, 
						min(r_fas63) as min_fas63, 
						min(r_fas65) as min_fas65, 
						min(r_fas66) as min_fas66, 
						min(r_fas67) as min_fas67, 
						min(r_fas68) as min_fas68, 
						min(r_fas71) as min_fas71, 
						min(r_fas77) as min_fas77, 
						min(r_fas80) as min_fas80, 
						min(r_fas86) as min_fas86, 
						min(r_fas87) as min_fas87, 
						min(r_fas88) as min_fas88,				
						min(r_fas97) as min_fas97, 
						min(r_fas101) as min_fas101, 
						min(r_fas105) as min_fas105, 
						min(r_fas106) as min_fas106, 
						min(r_fas107) as min_fas107, 
						min(r_fas109) as min_fas109, 
						min(r_fas113) as min_fas113, 
						min(r_fas115) as min_fas115, 
						min(r_fas116) as min_fas116, 
						min(r_fas119) as min_fas119, 
						min(r_fas121) as min_fas121, 
						min(r_fas123) as min_fas123, 
					min(r_fas123r) as min_fas123r, 
						min(r_fas125) as min_fas125, 
						min(r_fas130) as min_fas130,				
						min(r_fas132) as min_fas132, 
					min(r_fas132r) as min_fas132r, 
						min(r_fas133) as min_fas133, 
						min(r_fas140) as min_fas140, 
						min(r_fas141) as min_fas141, 
						min(r_fas142) as min_fas142,				
						min(r_fas143) as min_fas143, 
						min(r_fas144) as min_fas144, 
						min(r_fas146) as min_fas146, 
						min(r_fas150) as min_fas150, 
						min(r_fas154) as min_fas154, 
						min(r_sab101) as min_sab101, 
						min(r_sop97_2) as min_sop97_2,
		min(r_asu2009_17)  as min_asu2009_17,
		min(r_asu2011_08) as min_asu2011_08,
		min(r_asu2012_01) as min_asu2012_01,
		min(r_asu2012_02) as min_asu2012_02
			 

		from ps4 group by fyear
		order by fyear;
		quit;


		proc sql; create table ps6 as select
		a.*, b.*
		from ps4 as a left join ps5 as b
		on a.fyear eq b.fyear
		order by cik, fyear;
		quit;

		/*subtract minimum to get final rel_imp*/

		data ps7; set ps6;
		ri_apb25= r_apb25 - min_apb25;
		ri_apb2= r_apb2 -min_apb2;
		ri_apb4= r_apb4 -min_apb4;
		ri_apb9= r_apb9 -min_apb9;
		ri_apb14= r_apb14 -min_apb14;
		ri_apb16= r_apb16 -min_apb16;
		ri_apb17= r_apb17 -min_apb17;
		ri_apb18= r_apb18 -min_apb18;
		ri_apb20= r_apb20 -min_apb20;
		ri_apb21= r_apb21 -min_apb21;
		ri_apb23= r_apb23 -min_apb23;
		ri_apb26= r_apb26 -min_apb26;
		ri_apb29= r_apb29 -min_apb29;
		ri_apb30= r_apb30 -min_apb30;
		ri_arb45= r_arb45 -min_arb45;
		ri_arb51= r_arb51 -min_arb51;
		ri_arb43_2a= r_arb43_2a -min_arb43_2a;
		if ri_arb43_2a eq . then ri_arb43_2a=0;
		ri_arb43_3a= r_arb43_3a -min_arb43_3a;
		ri_arb43_3b= r_arb43_3b -min_arb43_3b;
		ri_arb43_4= r_arb43_4 -min_arb43_4;
		ri_arb43_7a= r_arb43_7a -min_arb43_7a;
		ri_arb43_7b= r_arb43_7b -min_arb43_7b;
		ri_arb43_9a= r_arb43_9a -min_arb43_9a;
		ri_arb43_9b= r_arb43_9b -min_arb43_9b;
		ri_arb43_10a= r_arb43_10a -min_arb43_10a;
		ri_arb43_11a= r_arb43_11a -min_arb43_11a;
		ri_arb43_11b= r_arb43_11b -min_arb43_11b;
		ri_arb43_11c= r_arb43_11c -min_arb43_11c;
		ri_arb43_12= r_arb43_12 -min_arb43_12;
		ri_con5_6= r_con5_6 -min_con5_6;
		ri_eitf00_21= r_eitf00_21 -min_eitf00_21;
		ri_eitf94_03= r_eitf94_03 -min_eitf94_03;
		ri_fas2= r_fas2 - min_fas2;
		ri_fas5= r_fas5 - min_fas5;
		ri_fas7= r_fas7 - min_fas7;
		ri_fas13= r_fas13 - min_fas13;
		ri_fas15= r_fas15 - min_fas15;
		ri_fas16= r_fas16 - min_fas16;
		ri_fas19= r_fas19 - min_fas19;
		ri_fas34= r_fas34 - min_fas34;
		ri_fas35= r_fas35 - min_fas35;
		ri_fas43= r_fas43 - min_fas43;
		ri_fas45= r_fas45 - min_fas45;
		ri_fas47= r_fas47 - min_fas47;
		ri_fas48= r_fas48 - min_fas48;
		ri_fas49= r_fas49 - min_fas49;
		ri_fas50= r_fas50 - min_fas50;
		ri_fas51= r_fas51 - min_fas51;
		ri_fas52= r_fas52 - min_fas52;
		ri_fas53= r_fas53 - min_fas53;
		ri_fas57= r_fas57 - min_fas57;
		ri_fas60= r_fas60 - min_fas60;
		ri_fas61= r_fas61 - min_fas61;
		ri_fas63= r_fas63 - min_fas63;
		ri_fas65= r_fas65 - min_fas65;
		ri_fas66= r_fas66 - min_fas66;
		ri_fas67= r_fas67 - min_fas67;
		ri_fas68= r_fas68 - min_fas68;
		ri_fas71= r_fas71 - min_fas71;
		ri_fas77= r_fas77 - min_fas77;
		ri_fas80= r_fas80 - min_fas80;
		ri_fas86= r_fas86 - min_fas86;
		ri_fas87= r_fas87 - min_fas87;
		ri_fas88= r_fas88 - min_fas88;
		ri_fas97= r_fas97 - min_fas97;
		ri_fas101= r_fas101 - min_fas101;
		ri_fas105= r_fas105 - min_fas105;
		ri_fas106= r_fas106 - min_fas106;
		ri_fas107= r_fas107 - min_fas107;
		ri_fas109= r_fas109 - min_fas109;
		ri_fas113= r_fas113 - min_fas113;
		ri_fas115= r_fas115 - min_fas115;
		ri_fas116= r_fas116 - min_fas116;
		ri_fas119= r_fas119 - min_fas119;
		ri_fas121= r_fas121 - min_fas121;
		ri_fas123= r_fas123 - min_fas123;
		ri_fas123r= r_fas123r - min_fas123r;
		ri_fas125= r_fas125 - min_fas125;
		ri_fas130= r_fas130 - min_fas130;
		ri_fas132= r_fas132 - min_fas132;
		ri_fas132r= r_fas132r - min_fas132r;
		ri_fas133= r_fas133 - min_fas133;
		ri_fas140= r_fas140 - min_fas140;
		ri_fas141= r_fas141 - min_fas141;
		ri_fas142= r_fas142 - min_fas142;
		ri_fas143= r_fas143 - min_fas143;
		ri_fas144= r_fas144 - min_fas144;
		ri_fas146= r_fas146 - min_fas146;
		ri_fas150= r_fas150 - min_fas150;
		ri_fas154= r_fas154 - min_fas154;
		ri_sab101= r_sab101 - min_sab101;
		ri_sop97_2= r_sop97_2 - min_sop97_2;

		ri_asu2009_17=r_asu2009_17 -min_asu2009_17;
		ri_asu2011_08=r_asu2011_08 -min_asu2011_08;
		ri_asu2012_01=r_asu2012_01- min_asu2012_01;
		ri_asu2012_02=r_asu2012_02 -min_asu2012_02;
			 

		run;

		data ps8; set ps7;
		keep gvkey cik fyear datadate permno ri_apb25 ri_apb2 file_date f_ftype
		ri_apb4 ri_apb9 ri_apb14 ri_apb16 ri_apb17 ri_apb18 ri_apb20 ri_apb21 ri_apb23 ri_apb26 ri_apb29 ri_apb30 ri_arb45 ri_arb51 ri_arb43_2a ri_arb43_3a 
		ri_arb43_3b ri_arb43_4 ri_arb43_7a ri_arb43_7b ri_arb43_9a ri_arb43_9b ri_arb43_10a ri_arb43_11a ri_arb43_11b ri_arb43_11c ri_arb43_12 ri_con5_6 ri_eitf00_21 ri_eitf94_03 ri_fas2 ri_fas5 
		ri_fas7 ri_fas13 ri_fas15 ri_fas16 ri_fas19 ri_fas34 ri_fas35 ri_fas43 ri_fas45 ri_fas47 ri_fas48 ri_fas49 ri_fas50 ri_fas51 ri_fas52 ri_fas53 
		ri_fas57 ri_fas60 ri_fas61 ri_fas63 ri_fas65 ri_fas66 ri_fas67 ri_fas68 ri_fas71 ri_fas77 ri_fas80 ri_fas86 ri_fas87 ri_fas88 ri_fas97 ri_fas101 
		ri_fas105 ri_fas106 ri_fas107 ri_fas109 ri_fas113 ri_fas115 ri_fas116 ri_fas119 ri_fas121 ri_fas123 ri_fas123r ri_fas125 ri_fas130 ri_fas132 ri_fas132r ri_fas133 
		ri_fas140 ri_fas141 ri_fas142 ri_fas143 ri_fas144 ri_fas146 ri_fas150 ri_fas154 ri_sab101 ri_sop97_2
		ri_asu2009_17 ri_asu2011_08 ri_asu2012_01 ri_asu2012_02;
		run;

		data dperm.rel_imp; set ps8;run;
		data ps8; set dperm.rel_imp;run;



	/*END: b.Create Relative Importance*/
	/*BEGIN: c. Analysis of link with codification*/
		*Basic Initializations;
		%let wrds = wrds.wharton.upenn.edu 4016;
		options comamid=TCP remote=wrds;
		signon username=_prompt_;
		Libname rwork slibref=work server=wrds;


		/*ASSIGN LIBRARIES*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\new_codification_link.xlsx'
		DBMS = xlsx OUT = flink;run;


		/*this code calculates which standard impacted which paragraph the most*/
		/* this is fulfilled by flink28*/
		data flink2; set flink; 
		id=_N_;
		id4=compress(cat(topic,subtopic,section,paragraph));
		id3=compress(cat(topic,subtopic,section));
		id2=compress(cat(topic,subtopic));
		id1=compress(topic);
		if org="ARB" and std_num=43 and c=: "Ch." then std_num=cat(compress(std_num),"_",lowcase(substr(c,5,2)));
		stid=cat(org,std_num);
		drop i j k l m;
		run;



		proc sql; create table flink3 as select distinct
		id4,
						count(id) as tot_edit_par
		from flink2 group by id4
		order by id4;
		quit;

		proc sql; create table flink4 as select distinct
		id4,stid,
						count(id) as n_std_edit_par
		from flink2 group by id4,stid
		order by id4,stid;
		quit;

		proc sql; create table flink5 as select
		a.*, b.n_std_edit_par,b.stid
		from flink3 as a left join flink4 b
		on a.id4=b.id4 
		order by id4, stid;
		quit;

		data flink6; set flink5;
		Perc_par_edit_by_std=n_std_edit_par/tot_edit_par;
		run;



		proc sort data=flink6 out=flink6m; by id4 descending perc_par_edit_by_std;run;
		proc sort data=flink6m out=flink6ma nodupkey; by id4 ;run;

		data flink6max; set  flink6ma;
		max=1;
		run;

		proc sql; create table flink7 as select
		a.*, b.max
		from flink6m as a left join flink6max b
		on a.id4=b.id4 and b.stid=a.stid
		order by id4, stid;
		quit;

		data flink6m2; set flink7;
		if max eq .;
		run;

		proc sort data=flink6m2 out=flink6m2; by id4 descending perc_par_edit_by_std;run;
		proc sort data=flink6m2 out=flink6m2a nodupkey; by id4 ;run;

		data flink6m2b; set flink6m2a;
		max=2;
		run;

		proc sql; create table flink8 as select
		a.*, b.max as max2
		from flink7 as a left join flink6m2b b
		on a.id4=b.id4 and b.stid=a.stid
		order by id4, stid;
		quit;

		data flink9; set flink8;
		if max eq . and max2 eq .;
		run;


		proc sort data=flink9 out=flink10; by id4 descending perc_par_edit_by_std;run;
		proc sort data=flink10 out=flink11 nodupkey; by id4 ;run;

		data flink12; set flink11;
		max=3;
		run;

		proc sql; create table flink13 as select
		a.*, b.max as max3
		from flink8 as a left join flink12 b
		on a.id4=b.id4 and b.stid=a.stid
		order by id4, stid;
		quit;

		data flink14; set flink13;
		if max eq . and max2 eq . and max3 eq .;
		run;


		proc sort data=flink14 out=flink14; by id4 descending perc_par_edit_by_std;run;
		proc sort data=flink14 out=flink15 nodupkey; by id4 ;run;

		data flink16; set flink15;
		max=4;
		run;

		proc sql; create table flink17 as select
		a.*, b.max as max4
		from flink13 as a left join flink16 b
		on a.id4=b.id4 and b.stid=a.stid
		order by id4, stid;
		quit;



		data flink18; set flink17;
		if max eq . and max2 eq . and max3 eq . and max4 eq .;
		run;


		proc sort data=flink18 out=flink18; by id4 descending perc_par_edit_by_std;run;
		proc sort data=flink18 out=flink19 nodupkey; by id4 ;run;

		data flink20; set flink19;
		max=5;
		run;

		proc sql; create table flink21 as select
		a.*, b.max as max5
		from flink17 as a left join flink20 b
		on a.id4=b.id4 and b.stid=a.stid
		order by id4, stid;
		quit;


		data flink22; set flink21;
		if max=. then max=0;
		if max2=. then max2=0;
		if max3=. then max3=0;
		if max4=. then max4=0;
		if max5=. then max5=0;
		maximum=max+max2+max3+max4+max5;
		run;


		proc sql; create table flink23 as select
		a.*, b.perc_par_edit_by_std as max_perc_par_edit_by_std, b.stid as stid_max
		from flink2 as a left join flink22 b
		on a.id4=b.id4 and b.maximum=1
		order by id4, stid;
		quit;

		proc sql; create table flink24 as select
		a.*, b.perc_par_edit_by_std as max2_perc_par_edit_by_std, b.stid as stid_max2
		from flink23 as a left join flink22 b
		on a.id4=b.id4 and b.maximum=2
		order by id4, stid;
		quit;

		proc sql; create table flink25 as select
		a.*, b.perc_par_edit_by_std as max3_perc_par_edit_by_std, b.stid as stid_max3
		from flink24 as a left join flink22 b
		on a.id4=b.id4 and b.maximum=3
		order by id4, stid;
		quit;
		proc sql; create table flink26 as select
		a.*, b.perc_par_edit_by_std as max4_perc_par_edit_by_std, b.stid as stid_max4
		from flink25 as a left join flink22 b
		on a.id4=b.id4 and b.maximum=4
		order by id4, stid;
		quit;
		proc sql; create table flink27 as select
		a.*, b.perc_par_edit_by_std as max5_perc_par_edit_by_std, b.stid as stid_max5
		from flink26 as a left join flink22 b
		on a.id4=b.id4 and b.maximum=5
		order by id4, stid;
		quit;


		data flink28; set flink27;
		multimax=0;
		if max_perc_par_edit_by_std=max2_perc_par_edit_by_std then multimax=1;
		if max_perc_par_edit_by_std=max3_perc_par_edit_by_std then multimax=1;
		if max_perc_par_edit_by_std=max4_perc_par_edit_by_std then multimax=1;
		if max_perc_par_edit_by_std=max5_perc_par_edit_by_std then multimax=1;
		run;



		/*I will now attempt to create a section edit percentage*/

		proc sql; create table flink3 as select distinct
		id3,
						count(id) as tot_edit_sec
		from flink2 group by id3
		order by id3;
		quit;

		proc sql; create table flink4 as select distinct
		id3,stid,
						count(id) as n_std_edit_sec
		from flink2 group by id3,stid
		order by id3,stid;
		quit;

		proc sql; create table flink5 as select
		a.*, b.n_std_edit_sec,b.stid
		from flink3 as a left join flink4 b
		on a.id3=b.id3 
		order by id3, stid;
		quit;

		data flink6; set flink5;
		Perc_sec_edit_by_std=n_std_edit_sec/tot_edit_sec;
		run;



		proc sort data=flink6 out=flink6m; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink6m out=flink6ma nodupkey; by id3 ;run;

		data flink6max; set  flink6ma;
		max=1;
		run;

		proc sql; create table flink7 as select
		a.*, b.max
		from flink6m as a left join flink6max b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;

		data flink6m2; set flink7;
		if max eq .;
		run;

		proc sort data=flink6m2 out=flink6m2; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink6m2 out=flink6m2a nodupkey; by id3 ;run;

		data flink6m2b; set flink6m2a;
		max=2;
		run;

		proc sql; create table flink8 as select
		a.*, b.max as max2
		from flink7 as a left join flink6m2b b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;

		data flink9; set flink8;
		if max eq . and max2 eq .;
		run;


		proc sort data=flink9 out=flink10; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink10 out=flink11 nodupkey; by id3 ;run;

		data flink12; set flink11;
		max=3;
		run;

		proc sql; create table flink13 as select
		a.*, b.max as max3
		from flink8 as a left join flink12 b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;

		data flink14; set flink13;
		if max eq . and max2 eq . and max3 eq .;
		run;


		proc sort data=flink14 out=flink14; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink14 out=flink15 nodupkey; by id3 ;run;

		data flink16; set flink15;
		max=4;
		run;

		proc sql; create table flink17 as select
		a.*, b.max as max4
		from flink13 as a left join flink16 b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;



		data flink18; set flink17;
		if max eq . and max2 eq . and max3 eq . and max4 eq .;
		run;


		proc sort data=flink18 out=flink18; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink18 out=flink19 nodupkey; by id3 ;run;

		data flink20; set flink19;
		max=5;
		run;

		proc sql; create table flink21 as select
		a.*, b.max as max5
		from flink17 as a left join flink20 b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21a; set flink21;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq .;
		run;


		proc sort data=flink21a out=flink21a; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21a out=flink21b nodupkey; by id3 ;run;

		data flink21b; set flink21b;
		max=6;
		run;

		proc sql; create table flink21c as select
		a.*, b.max as max6
		from flink21 as a left join flink21b b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21d; set flink21c;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq . and max6 eq .;
		run;


		proc sort data=flink21d out=flink21d; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21d out=flink21e nodupkey; by id3 ;run;

		data flink21e; set flink21e;
		max=7;
		run;

		proc sql; create table flink21f as select
		a.*, b.max as max7
		from flink21c as a left join flink21e b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21g; set flink21f;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq . and max6 eq . and max7 eq .;
		run;


		proc sort data=flink21g out=flink21g; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21g out=flink21h nodupkey; by id3 ;run;

		data flink21h; set flink21h;
		max=8;
		run;

		proc sql; create table flink21i as select
		a.*, b.max as max8
		from flink21f as a left join flink21h b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21j; set flink21i;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq . and max6 eq . and max7 eq . and max8 eq .;
		run;


		proc sort data=flink21j out=flink21j; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21j out=flink21k nodupkey; by id3 ;run;

		data flink21k; set flink21k;
		max=9;
		run;

		proc sql; create table flink21l as select
		a.*, b.max as max9
		from flink21i as a left join flink21k b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21m; set flink21l;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq . and max6 eq . and max7 eq . and max8 eq . and max9 eq .;
		run;


		proc sort data=flink21m out=flink21m; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21m out=flink21n nodupkey; by id3 ;run;

		data flink21o; set flink21n;
		max=10;
		run;

		proc sql; create table flink21p as select
		a.*, b.max as max10
		from flink21l as a left join flink21o b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;


		data flink21q; set flink21p;
		if max eq . and max2 eq . and max3 eq . and max4 eq . and max5 eq . and max6 eq . and max7 eq . and max8 eq . and max9 eq . and max10 eq .;
		run;


		proc sort data=flink21q out=flink21q; by id3 descending Perc_sec_edit_by_std;run;
		proc sort data=flink21q out=flink21r nodupkey; by id3 ;run;

		data flink21r; set flink21r;
		max=11;
		run;

		proc sql; create table flink21s as select
		a.*, b.max as max11
		from flink21p as a left join flink21r b
		on a.id3=b.id3 and b.stid=a.stid
		order by id3, stid;
		quit;




		data flink22a; set flink21s;
		if max=. then max=0;
		if max2=. then max2=0;
		if max3=. then max3=0;
		if max4=. then max4=0;
		if max5=. then max5=0;
		if max6=. then max6=0;
		if max7=. then max7=0;
		if max8=. then max8=0;
		if max9=. then max9=0;
		if max10=. then max10=0;
		if max11=. then max11=0;
		maximum=max+max2+max3+max4+max5+max6+max7+max8+max9+max10+max11;
		run;


		proc sql; create table flink29 as select
		a.*, b.perc_sec_edit_by_std as max_perc_sec_edit_by_std, b.stid as stid_max_sec
		from flink28 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=1
		order by id3, stid;
		quit;

		proc sql; create table flink30 as select
		a.*, b.perc_sec_edit_by_std as max2_perc_sec_edit_by_std, b.stid as stid_max2_sec
		from flink29 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=2
		order by id3, stid;
		quit;

		proc sql; create table flink31 as select
		a.*, b.perc_sec_edit_by_std as max3_perc_sec_edit_by_std, b.stid as stid_max3_sec
		from flink30 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=3
		order by id3, stid;
		quit;

		proc sql; create table flink32 as select
		a.*, b.perc_sec_edit_by_std as max4_perc_sec_edit_by_std, b.stid as stid_max4_sec
		from flink31 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=4
		order by id3, stid;
		quit;

		proc sql; create table flink33 as select
		a.*, b.perc_sec_edit_by_std as max5_perc_sec_edit_by_std, b.stid as stid_max5_sec
		from flink32 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=5
		order by id3, stid;
		quit;

		proc sql; create table flink34 as select
		a.*, b.perc_sec_edit_by_std as max6_perc_sec_edit_by_std, b.stid as stid_max6_sec
		from flink33 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=6
		order by id3, stid;
		quit;

		proc sql; create table flink35 as select
		a.*, b.perc_sec_edit_by_std as max7_perc_sec_edit_by_std, b.stid as stid_max7_sec
		from flink34 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=7
		order by id3, stid;
		quit;

		proc sql; create table flink36 as select
		a.*, b.perc_sec_edit_by_std as max8_perc_sec_edit_by_std, b.stid as stid_max8_sec
		from flink35 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=8
		order by id3, stid;
		quit;
		proc sql; create table flink37 as select
		a.*, b.perc_sec_edit_by_std as max9_perc_sec_edit_by_std, b.stid as stid_max9_sec
		from flink36 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=9
		order by id3, stid;
		quit;

		proc sql; create table flink38 as select
		a.*, b.perc_sec_edit_by_std as max10_perc_sec_edit_by_std, b.stid as stid_max10_sec
		from flink37 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=10
		order by id3, stid;
		quit;

		proc sql; create table flink39 as select
		a.*, b.perc_sec_edit_by_std as max11_perc_sec_edit_by_std, b.stid as stid_max11_sec
		from flink38 as a left join flink22a b
		on a.id3=b.id3 and b.maximum=11
		order by id3, stid;
		quit;



		data flink40; set flink39;
		multimax_sec=0;
		if max_perc_sec_edit_by_std=max2_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max3_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max4_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max5_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max6_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max7_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max8_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max9_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max10_perc_sec_edit_by_std then multimax_sec=1;
		if max_perc_sec_edit_by_std=max11_perc_sec_edit_by_std then multimax_sec=1;
		run;


		data dperm.par_and_sec_max_edits1; set flink40;
		run;



	/*END: c. Analysis of link with codification*/
	/*BEGIN: d. Create link with codification*/



		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';

		/*This code creates a link first using the reference tool provided by the FASB
		Then for paragraphs that aren't in the reference tool. I calculate which standard edited
		either that paragraph or section the most and infer from that which standard the
		paragraph applies too*/

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\asu_word_counts1.xlsx'
		DBMS = xlsx OUT = rtool;run;

		data rtool;set rtool;
		aeff_date=mdy(month,day,year);
		format aeff_date mmddyy.;
		drop asu_eff_date month day year;
		rename aeff_date=asu_eff_date;
		run;

		data maxedit; set dperm.par_and_sec_max_edits1; /*created by "cod_link_analysis"*/
		m=0;
		if cat(org,std_num)=stid_max and max_perc_par_edit_by_std=1 then m=1;
		m1=0;
		if cat(org,std_num)=stid_max and max_perc_par_edit_by_std gt .5 and max_perc_par_edit_by_std lt 1 then m1=1;
		m3=0;
		if cat(org,std_num)=stid_max and max_perc_sec_edit_by_std eq 1 then m3=1;
		m4=0;
		if cat(org,std_num)=stid_max and max_perc_sec_edit_by_std gt .5 and max_perc_sec_edit_by_std lt 1 then m4=1;
		/*below this line I manually edit some std_num to make them match later on*/
		run;



		data rtool1; set rtool;
		subtopic1=subtopic*1;
		if subtopic ne "";
		if section ne "";
		run;

		proc sql; create table rtool2 as select
		a.*, b.stid_max, b.max_perc_par_edit_by_std,b.stid_max2, b.max2_perc_par_edit_by_std,
		b.stid_max3, b.max3_perc_par_edit_by_std,b.stid_max4, b.max4_perc_par_edit_by_std,
		b.stid_max5, b.max5_perc_par_edit_by_std
		from rtool1 as a left join maxedit b
		on a.topic=b.topic and a.subtopic1=b.subtopic and a.section=b.section and a.paragraph=b.paragraph
		order by filename;
		quit;

		proc sort data=rtool2 out=rtool3 noduprecs; by filename; run;

		proc sql; create table rtool4 as select
		a.*, b.stid_max_sec, b.max_perc_sec_edit_by_std,
		b.stid_max2_sec, b.max2_perc_sec_edit_by_std,b.stid_max3_sec, b.max3_perc_sec_edit_by_std,
		b.stid_max4_sec, b.max4_perc_sec_edit_by_std,b.stid_max5_sec, b.max5_perc_sec_edit_by_std,
		b.stid_max6_sec, b.max6_perc_sec_edit_by_std,b.stid_max7_sec, b.max7_perc_sec_edit_by_std,
		b.stid_max8_sec, b.max8_perc_sec_edit_by_std,b.stid_max9_sec, b.max9_perc_sec_edit_by_std,
		b.stid_max10_sec, b.max10_perc_sec_edit_by_std,b.stid_max11_sec, b.max11_perc_sec_edit_by_std
		from rtool3 as a left join maxedit b
		on a.topic=b.topic and a.subtopic1=b.subtopic and a.section=b.section 
		order by filename;
		quit;

		proc sort data=rtool4 out=rtool5 noduprecs; by filename; run;



		data rtool6; set rtool5;
		LINK=stid_max;
		if link eq "" then link=stid_max_sec;
		run;

		data test; set rtool6;
		if link ne "";
		d=7946/11201;
		run;

		data dperm.cod_link; set rtool6;
		run;





	/*END: d. Create link with codification*/
	/*BEGIN:e. Create modal counts rr1z */


		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/


		data ps8; set dperm.rel_imp;run;

		/*below code brings in the count of shall,should must */

		/*brings in raw word counts...This brings in the word counts
		from standards but not ASUS*/
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\modal_words.xlsx'
		DBMS = xlsx OUT = mwords;run;

		data dperm.words1; set mwords;run;
		data words; set dperm.words1;
		drop sentence n o p q r s t u v w;
		run;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
		DBMS = xlsx OUT = rbc;run;
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
		DBMS = xlsx OUT = rbc2;run;



		/*rbc2 contains which standards are effective in which years some of the 
		iteration variables are whole numbers and some are decimals. i.e. iteration 1 is 
		sometimes represented as 1 and sometimes represented as .1 so I altered them to all be
		whole numbers*/




		data rbc2; set rbc2;
		iter=iteration;
		if iteration =: '0.' then iter=iteration*10;
		if iteration =: '0.91' then iter=iteration*100;
		if iteration =: '0.92' then iter=iteration*100;
		if iteration =: '0.93' then iter=iteration*100;
		if iteration =: '0.94' then iter=iteration*100;
		if iteration =: '.94' then iter=iteration*100;
		if iteration =: '0.95' then iter=iteration*100;
		if iteration =: '0.96' then iter=iteration*100;
		if iteration =: '0.15' then iter=iteration*100;
		if iteration =: '0.11' then iter=iteration*100;
		if iteration =: '0.12' then iter=iteration*100;
		if iteration =: '0.13' then iter=iteration*100;
		if iteration =: '0.14' then iter=iteration*100;
		if iteration =: '0.16' then iter=iteration*100;
		if iteration =: '0.17' then iter=iteration*100;
		if iteration =: '0.18' then iter=iteration*100;
		if iteration =: '0.19' then iter=iteration*100;
		orgx=compress(cat(org,std_num));
		if org='apb' and std_num='15' and year=1996 then matchv=1;
		run;

		data rbc1; set rbc;
		yeary=year*1;
		if standard='apb15' and year=1997 then yeary=1996;
		if standard='arb43_11b' and year ge 2006 then yeary=2005;
		run;

		proc sql; create table rbc3 as select
		a.*, b.*
		from rbc2 as a left join rbc1 b
		on b.standard=a.orgx and a.year=b.yeary
		order by org, std_num,year, iteration;
		quit;


		/*data test; set rbc2;
		keep org iter iteration std_num;
		run;


		proc sort data=test out=test2 nodupkey; by iter;run;*/

		/*we only want to keep the word counts for a subset of words*/

		proc sort data=words out=words1 nodupkey; by filename org stddev stditr word;run;


		data shall; set words1;
		where word in ('shall','must','should');
		run;

		proc sort data=shall out=shalln nodupkey; by filename;run;




		data shall21; set dperm.shall21rraz;
		run;

		/*I need to combine with reliance data and then orthogonalize
		with complexity*/




		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\rbc_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = rbcm ;run;
		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\complexity_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = compm ;run;

		data shall21a; set shall21;
		linkz=compress(cat(org,std_num));
		run;

		proc sql; create table shall21b as select
		a.*, b.complex1,b.complex2
		from shall21a as a  left join compm as b
		on a.linkz=b.link
		order by org, std_num, year;
		quit;

		data shall21c; set shall21b;
		linky=compress(cat(year,org,std_num));
		run;

		proc sql; create table shall21d as select
		a.*, b.rbc1,b.rbc2
		from shall21c as a  left join rbcm as b
		on a.linky=b.link
		order by org, std_num, year;
		quit;

		data shall21e; set shall21d;
		drop linkz linky;
		if complex1 eq . then complex1=0;
		if complex2 eq . then complex2=0;
		iteration1=iteration*1;
		run;








		data shallna; set shalln;
		if org="sop" then stddev=tranwrd(stddev,"-","_");
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stddev="97_2";
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stditr="0.1";
		org1=lowcase(org);
		if org="SAB" and stddev="01A" then stddev="101A";
		if org="SAB" and stddev="01B" then stddev="101B";
		std_num=lowcase(stddev);
		stditr1=stditr*1;
		if org="fas" and stditr ge 1 then stditr1=stditr/10;
		if org="fas" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stditr ge 1 then stditr1=stditr/10;
		if org="apb" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stddev=1 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=1 and stditr eq 2 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 2 then stditr1=stditr*1;
		if filename="apb9.1.5.txt" then stditr1="0.15";
		if org1="arb" and stditr ge 1 then stditr1=stditr/10;
		if stddev="43_2A" then stddev=std_num;
		if stddev="43_2B" then stddev=std_num;
		if filename="abs00-21.txt" then org1="eitf";
		if filename="abs00-21.txt" then stddev=tranwrd(stddev,"-","_");
		if org="fas" and stddev="141ri" then stddev="141r";
		if org="fas" and stddev="158i" then stddev="158";
		if org="fas" and stddev="159i" then stddev="159";
		if org="fas" and stddev="160i" then stddev="160";
		if org="fas" and stddev="161a" then stddev="161";
		if org="fas" and stddev="162i" then stddev="162";
		if org="fas" and stddev="163i" then stddev="163";
		if org="fas" and stddev="164i" then stddev="164";
		if org="fas" and stddev="165i" then stddev="165";
		if org="fas" and stddev="166i" then stddev="166";
		if org="fas" and stddev="167i" then stddev="167";
		if org1="fas" and stddev="44" then stditr1=stditr/10;

		run;


		proc sql; create table length as select
		a.*, b.totalword as length
		from shall21e as a left join shallna b
		on a.org=b.org1 and a.std_num=b.stddev and a.iteration1=b.stditr1
		order by org, std_num, stditr;
		quit;


		/*I manually had to gather these word lengths*/
		data length1; set length;
		if org=:"eitf" and std_num=:"94_3" then length=5306;
		if org="fas" and std_num="68" then length=1816; 
		if org="arb" and std_num="43_3b" and iteration=0 then length=584; 
		if org="fas" and std_num="113" and iteration=0.3 then length=5955; 
		if org="fas" and std_num="15" and iteration=0.93 then length=5042;
		if org="fas" and std_num="156" and iteration=0.1 then length=40929;
		if org="fas" and std_num="67" and iteration=0.6 then length=3497;
		if org="fas" and std_num="53"  then length=3942;/**/
		*stm=total_modal/length;
		run;

		/*****this section adds in the changes in length in the post codification period*******/
		data shall15o; set dperm.shall15rra;
		yearz=year*1;
		run;

		proc sort data=shall15o out=shall15m; by standard descending year; run;
		proc sort data=shall15m out=shall15n nodupkey; by standard; run;

		data shall15p; set shall15n;
		if year=2009;
		run;

		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\myear.xlsx' 
		DBMS = xlsx OUT = myear ;run;


		proc sql; create table shall15q as select
		a.*, b.*
		from myear as a , shall15p b
		order by standard, myear;
		quit;

		data shall15r; set shall15q;
		if myear ne 2009;
		year=myear;
		drop myear;
		run;

		data shall15s; set shall15o shall15r;run;

		proc sort data=shall15s; by standard year;run;

		data link; set dperm.cod_link;
		link1=lowcase(compress(link));
		asuyear1=asuyear*1;
		if link1 =: "eitf" then link1=tranwrd(link1,"-","_");
		if link1 =: "sop" then link1=tranwrd(link1,"-","_");
		run;

		proc sort data=link; by link1;run;

		data shall15sa; set shall15s;
		link=compress(cat(org,std_num));
		yearx1=year*1;
		run;

		data link1; set link;
		if AorD="A" then total=total;
		if AorD="D" then total=total*-1;
		mergeyear=year(asu_eff_date);
		if asuyear1 gt mergeyear then mergeyear=asuyear1;
		run;



		
		
		data link1z; set link1;
		if link1="fas141(r)" then link1="fas141r";
		if link1="fas123(r)" then link1="fas123r";
		if link1="fas132(r)" then link1="fas132r";
		run;

		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\wcasu.xlsx' 
		DBMS = xlsx OUT = wcasu1 ;run;


		proc sql; create table lz1 as select
		a.*, b.wcasu
		from link1z as a  left join wcasu1 as b
		on a.filename=b.filename ;
		quit;

		data lz2; set lz1;
		if AorD="A" then wcasu=wcasu;
		if AorD="D" then wcasu=wcasu*-1;
		run;



		proc sql; create table shall15t as select
		a.*, b.topic, b.subtopic,b.section,b.paragraph,b.wcasu
		from shall15sa as a  left join lz2 as b
		on a.link=b.link1 and a.yearx1>=b.mergeyear
		order by standard, year;
		quit;





		proc sql; create table shall15u as select distinct
		filename, org,stddev,stditr,year,
						sum(wcasu) as wcASUt

		from shall15t group by filename,org,stddev,stditr,year
		order by filename,org,stddev,stditr,year;
		quit;



		proc sql; create table l1 as select
		a.*, b.wcASUt
		from shall15sa as a  left join shall15u as b
		on a.org=b.org and a.stddev=b.stddev and a.year=b.year
		order by standard, year;
		quit;

		proc sort data=l1 out=shall15w noduprecs; by standard year; run;


		proc sql; create table l1 as select
		a.*, b.wcASUt
		from shall15sa as a  left join shall15u as b
		on a.org=b.org and a.stddev=b.stddev and a.year=b.year
		order by standard, year;
		quit;

		proc sql; create table l2 as select
		a.*, b.wcASUt
		from length1 as a  left join l1 as b
		on a.org=b.org and a.std_num=b.std_num and a.year=b.year
		order by standard, year;
		quit;


		data length2; set l2;
		if wcasut eq . then wcasut=0;
		tlength=length+wcasut;
		stm=total_modal/tlength;
		run;



		/************/




		proc reg data=length2 ;
		model stm= complex1 complex2;
		output out=ds
		p=predicted
		r=residual;
		run;quit;

		proc sort data=ds; by org std_num year;run;

		data dperm.lengthrraz; set ds;
		keep org std_num iteration year end_dt stditr1 igr1 restrict arnew total_modal stm eff_date complex1 complex2 length org1 iteration1 totr predicted residual rbc1 rbc2 tlength;
		run;


		Proc export data=dperm.lengthrraz
		outfile='C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\lengthrraz.xlsx'
		dbms=xlsx
		replace;
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\imp1_lengthrraz.xlsx'
		dbms=xlsx OUT = imp1;run;

		data ps9; set ps8;
		if fyear ne . then year=fyear;
		if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then year=year(datadate);
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
		dbms=xlsx OUT = mdataa;run;

		data mdata3; set mdataa;
		/*I added this line to include fas141r which is included
		in the word counts of 141*/
		max_fas141=max_fas141r;
		id=1;
		if min_apb2 ne .;
		drop ko kp;
		run;
		data ps9; set ps9;
		id=1;
		run;

		proc sql; create table ps10 as select
		a.*, b.*
		from ps9 as a left join mdata3 b
		on a.id=b.id
		order by cik, fyear;
		quit;

		data ps11 ; set ps10;
		if fyear lt min_apb25 then ri_apb25=0;
		if fyear gt max_apb25 then ri_apb25=0;

		if fyear lt min_apb4 then ri_apb4=0;
		if fyear gt max_apb4 then ri_apb4=0;

		if fyear lt min_apb9 then ri_apb9=0;
		if fyear gt max_apb9 then ri_apb9=0;

		if fyear lt min_apb14 then ri_apb14=0;
		if fyear gt max_apb14 then ri_apb14=0;

		if fyear lt min_apb16 then ri_apb16=0;
		if fyear gt max_apb16 then ri_apb16=0;

		if fyear lt min_apb17 then ri_apb17=0;
		if fyear gt max_apb17 then ri_apb17=0;

		if fyear lt min_apb18 then ri_apb18=0;
		if fyear gt max_apb18 then ri_apb18=0;

		if fyear lt min_apb20 then ri_apb20=0;
		if fyear gt max_apb20 then ri_apb20=0;

		if fyear lt min_apb21 then ri_apb21=0;
		if fyear gt max_apb21 then ri_apb21=0;

		if fyear lt min_apb23 then ri_apb23=0;
		if fyear gt max_apb23 then ri_apb23=0;

		if fyear lt min_apb26 then ri_apb26=0;
		if fyear gt max_apb26 then ri_apb26=0;

		if fyear lt min_apb29 then ri_apb29=0;
		if fyear gt max_apb29 then ri_apb29=0;

		if fyear lt min_apb30 then ri_apb30=0;
		if fyear gt max_apb30 then ri_apb30=0;

		if fyear lt min_arb45 then ri_arb45=0;
		if fyear gt max_arb45 then ri_arb45=0;

		if fyear lt min_arb51 then ri_arb51=0;
		if fyear gt max_arb51 then ri_arb51=0;

		if fyear lt min_arb43_2a then ri_arb43_2a=0;
		if fyear gt max_arb43_2a then ri_arb43_2a=0;

		if fyear lt min_arb43_3a then ri_arb43_3a=0;
		if fyear gt max_arb43_3a then ri_arb43_3a=0;

		if fyear lt min_arb43_3b then ri_arb43_3b=0;
		if fyear gt max_arb43_3b then ri_arb43_3b=0;

		if fyear lt min_arb43_4 then ri_arb43_4=0;
		if fyear gt max_arb43_4 then ri_arb43_4=0;

		if fyear lt min_arb43_7a then ri_arb43_7a=0;
		if fyear gt max_arb43_7a then ri_arb43_7a=0;

		if fyear lt min_arb43_7b then ri_arb43_7b=0;
		if fyear gt max_arb43_7b then ri_arb43_7b=0;

		if fyear lt min_arb43_9a then ri_arb43_9a=0;
		if fyear gt max_arb43_9a then ri_arb43_9a=0;

		if fyear lt min_arb43_9b then ri_arb43_9b=0;
		if fyear gt max_arb43_9b then ri_arb43_9b=0;

		if fyear lt min_arb43_10a then ri_arb43_10a=0;
		if fyear gt max_arb43_10a then ri_arb43_10a=0;

		if fyear lt min_arb43_11a then ri_arb43_11a=0;
		if fyear gt max_arb43_11a then ri_arb43_11a=0;

		if fyear lt min_arb43_11b then ri_arb43_11b=0;
		if fyear gt max_arb43_11b then ri_arb43_11b=0;

		if fyear lt min_arb43_11c then ri_arb43_11c=0;
		if fyear gt max_arb43_11c then ri_arb43_11c=0;

		if fyear lt min_arb43_12 then ri_arb43_12=0;
		if fyear gt max_arb43_12 then ri_arb43_12=0;

		if fyear lt min_con5_6 then ri_con5_6=0;
		if fyear gt max_con5_6 then ri_con5_6=0;

		if fyear lt min_eitf00_21 then ri_eitf00_21=0;
		if fyear gt max_eitf00_21 then ri_eitf00_21=0;

		if fyear lt min_eitf94_3 then ri_eitf94_03=0;
		if fyear gt max_eitf94_3 then ri_eitf94_03=0;

		if fyear lt min_fas2 then ri_fas2=0;
		if fyear gt max_fas2 then ri_fas2=0;

		if fyear lt min_fas5 then ri_fas5=0;
		if fyear gt max_fas5 then ri_fas5=0;

		if fyear lt min_fas7 then ri_fas7=0;
		if fyear gt max_fas7 then ri_fas7=0;

		if fyear lt min_fas13 then ri_fas13=0;
		if fyear gt max_fas13 then ri_fas13=0;

		if fyear lt min_fas15 then ri_fas15=0;
		if fyear gt max_fas15 then ri_fas15=0;

		if fyear lt min_fas16 then ri_fas16=0;
		if fyear gt max_fas16 then ri_fas16=0;

		if fyear lt min_fas19 then ri_fas19=0;
		if fyear gt max_fas19 then ri_fas19=0;

		if fyear lt min_fas34 then ri_fas34=0;
		if fyear gt max_fas34 then ri_fas34=0;

		if fyear lt min_fas35 then ri_fas35=0;
		if fyear gt max_fas35 then ri_fas35=0;

		if fyear lt min_fas43 then ri_fas43=0;
		if fyear gt max_fas43 then ri_fas43=0;

		if fyear lt min_fas45 then ri_fas45=0;
		if fyear gt max_fas45 then ri_fas45=0;

		if fyear lt min_fas47 then ri_fas47=0;
		if fyear gt max_fas47 then ri_fas47=0;

		if fyear lt min_fas48 then ri_fas48=0;
		if fyear gt max_fas48 then ri_fas48=0;

		if fyear lt min_fas49 then ri_fas49=0;
		if fyear gt max_fas49 then ri_fas49=0;

		if fyear lt min_fas50 then ri_fas50=0;
		if fyear gt max_fas50 then ri_fas50=0;

		if fyear lt min_fas51 then ri_fas51=0;
		if fyear gt max_fas51 then ri_fas51=0;

		if fyear lt min_fas52 then ri_fas52=0;
		if fyear gt max_fas52 then ri_fas52=0;

		if fyear lt min_fas53 then ri_fas53=0;
		if fyear gt max_fas53 then ri_fas53=0;

		if fyear lt min_fas57 then ri_fas57=0;
		if fyear gt max_fas57 then ri_fas57=0;

		if fyear lt min_fas60 then ri_fas60=0;
		if fyear gt max_fas60 then ri_fas60=0;

		if fyear lt min_fas61 then ri_fas61=0;
		if fyear gt max_fas61 then ri_fas61=0;

		if fyear lt min_fas63 then ri_fas63=0;
		if fyear gt max_fas63 then ri_fas63=0;

		if fyear lt min_fas65 then ri_fas65=0;
		if fyear gt max_fas65 then ri_fas65=0;

		if fyear lt min_fas66 then ri_fas66=0;
		if fyear gt max_fas66 then ri_fas66=0;

		if fyear lt min_fas67 then ri_fas67=0;
		if fyear gt max_fas67 then ri_fas67=0;

		if fyear lt min_fas68 then ri_fas68=0;
		if fyear gt max_fas68 then ri_fas68=0;

		if fyear lt min_fas71 then ri_fas71=0;
		if fyear gt max_fas71 then ri_fas71=0;

		if fyear lt min_fas77 then ri_fas77=0;
		if fyear gt max_fas77 then ri_fas77=0;

		if fyear lt min_fas80 then ri_fas80=0;
		if fyear gt max_fas80 then ri_fas80=0;

		if fyear lt min_fas86 then ri_fas86=0;
		if fyear gt max_fas86 then ri_fas86=0;

		if fyear lt min_fas87 then ri_fas87=0;
		if fyear gt max_fas87 then ri_fas87=0;

		if fyear lt min_fas88 then ri_fas88=0;
		if fyear gt max_fas88 then ri_fas88=0;

		if fyear lt min_fas97 then ri_fas97=0;
		if fyear gt max_fas97 then ri_fas97=0;

		if fyear lt min_fas101 then ri_fas101=0;
		if fyear gt max_fas101 then ri_fas101=0;

		if fyear lt min_fas105 then ri_fas105=0;
		if fyear gt max_fas105 then ri_fas105=0;

		if fyear lt min_fas106 then ri_fas106=0;
		if fyear gt max_fas106 then ri_fas106=0;

		if fyear lt min_fas107 then ri_fas107=0;
		if fyear gt max_fas107 then ri_fas107=0;

		if fyear lt min_fas109 then ri_fas109=0;
		if fyear gt max_fas109 then ri_fas109=0;

		if fyear lt min_fas113 then ri_fas113=0;
		if fyear gt max_fas113 then ri_fas113=0;

		if fyear lt min_fas115 then ri_fas115=0;
		if fyear gt max_fas115 then ri_fas115=0;

		if fyear lt min_fas119 then ri_fas116=0;
		if fyear gt max_fas119 then ri_fas116=0;

		if fyear lt min_fas121 then ri_fas121=0;
		if fyear gt max_fas121 then ri_fas121=0;

		if fyear lt min_fas123 then ri_fas123=0;
		if fyear gt max_fas123 then ri_fas123=0;

		if fyear lt min_fas123r then ri_fas123r=0;
		if fyear gt max_fas123r then ri_fas123r=0;

		if fyear lt min_fas125 then ri_fas125=0;
		if fyear gt max_fas125 then ri_fas125=0;

		if fyear lt min_fas130 then ri_fas130=0;
		if fyear gt max_fas130 then ri_fas130=0;

		if fyear lt min_fas132 then ri_fas132=0;
		if fyear gt max_fas132 then ri_fas132=0;

		if fyear lt min_fas132r then ri_fas132r=0;
		if fyear gt max_fas132r then ri_fas132r=0;

		if fyear lt min_fas133 then ri_fas133=0;
		if fyear gt max_fas133 then ri_fas133=0;

		if fyear lt min_fas140 then ri_fas140=0;
		if fyear gt max_fas140 then ri_fas140=0;

		if fyear lt min_fas141 then ri_fas141=0;
		if fyear gt max_fas141 then ri_fas141=0;

		if fyear lt min_fas142 then ri_fas142=0;
		if fyear gt max_fas142 then ri_fas142=0;

		if fyear lt min_fas143 then ri_fas143=0;
		if fyear gt max_fas143 then ri_fas143=0;

		if fyear lt min_fas144 then ri_fas144=0;
		if fyear gt max_fas144 then ri_fas144=0;

		if fyear lt min_fas146 then ri_fas146=0;
		if fyear gt max_fas146 then ri_fas146=0;

		if fyear lt min_fas150 then ri_fas150=0;
		if fyear gt max_fas150 then ri_fas150=0;
		if fyear lt min_fas154 then ri_fas154=0;
		if fyear gt max_fas154 then ri_fas154=0;
		if fyear lt min_sab101 then ri_sab101=0;
		if fyear gt max_sab101 then ri_sab101=0;
		if fyear lt min_sop97_2 then ri_sop97_2=0;
		if fyear gt max_sop97_2 then ri_sop97_2=0;
		if fyear lt 2009 then ri_asu2009_17=0;
		if fyear lt 2011 then ri_asu2011_08=0;
		if fyear lt 2012 then ri_asu2012_01=0;
		if fyear lt 2012 then ri_asu2012_02=0;
		run;


		proc sql; create table ds1 as select
		a.*, b.*
		from ps11 as a left join imp1 b
		on a.year=b.year
		order by cik, fyear;
		quit;


		data ds1a; set ds1;
		if ri_apb25 eq . then  ri_apb25=0;    
		if apb25 eq . then  apb25=0; 
		if ri_apb2  eq . then  ri_apb2=0;           
		if apb2 eq . then  apb2=0; 
		if ri_apb4 eq . then  ri_apb4=0;          
		if apb4 eq . then  apb4=0; 
		if ri_apb9 eq . then  ri_apb9=0;          
		if apb9 eq . then  apb9=0; 
		if ri_apb14 eq . then  ri_apb14=0;           
		if apb14 eq . then apb14=0; 
		if ri_apb16 eq . then  ri_apb16=0;          
		if apb16 eq . then apb16=0; 
		if ri_apb17 eq . then  ri_apb17=0;         
		if apb17 eq . then apb17=0; 
		if ri_apb18 eq . then  ri_apb18=0;         
		if apb18 eq . then  apb18=0; 
		if ri_apb20 eq . then  ri_apb20=0;          
		if apb20 eq . then  apb20=0; 
		if ri_apb21 eq . then  ri_apb21=0;          
		if apb21 eq . then  apb21=0; 
		if ri_apb23 eq . then  ri_apb23=0;          
		if apb23 eq . then  apb23=0; 
		if ri_apb26 eq . then  ri_apb26=0;          
		if apb26 eq . then  apb26=0; 
		if ri_apb29 eq . then  ri_apb29=0;          
		if apb29 eq . then  apb29=0; 
		if ri_apb30 eq . then  ri_apb30=0;          
		if apb30 eq . then  apb30=0; 
		if ri_arb45 eq .  then ri_arb45=0;        
		if arb45  eq . then arb45=0;
		if ri_arb51  eq . then ri_arb51=0;
		if arb51  eq . then arb51=0;
		if ri_arb43_2a  eq . then ri_arb43_2a=0;        
		if arb43_2a eq . then arb43_2a=0;    
		if ri_arb43_3a eq . then ri_arb43_3a=0;              
		if arb43_3a  eq . then arb43_3a=0;  
		if ri_arb43_3b eq . then ri_arb43_3b=0;            
		if arb43_3b  eq . then arb43_3b=0;  
		if ri_arb43_4  eq . then ri_arb43_4=0;           
		if arb43_4  eq . then arb43_4=0;  
		if ri_arb43_7a eq . then ri_arb43_7a=0;           
		if arb43_7a  eq . then arb43_7a=0;  
		if ri_arb43_7b eq . then ri_arb43_7b=0;            
		if arb43_7b  eq . then arb43_7b=0;  
		if ri_arb43_9a eq . then ri_arb43_9a=0;            
		if arb43_9a  eq . then arb43_9a=0;  
		if ri_arb43_9b eq . then ri_arb43_9b=0;            
		if arb43_9b  eq . then arb43_9b=0;  
		if ri_arb43_10a  eq . then ri_arb43_10a=0;           
		if arb43_10a  eq . then arb43_10a=0;  
		if ri_arb43_11a  eq . then ri_arb43_11a=0;            
		if arb43_11a  eq . then arb43_11a=0;  
		if ri_arb43_11b  eq . then ri_arb43_11b=0;           
		if arb43_11b  eq . then arb43_11b=0;  
		if ri_arb43_11c  eq . then ri_arb43_11c=0;          
		if arb43_11c  eq . then arb43_11c=0;  
		if ri_arb43_12   eq . then ri_arb43_12=0;          
		if arb43_12  eq . then arb43_12=0;  
		if ri_con5_6     eq . then ri_con5_6=0;       
		if con5_6  eq . then con5_6=0;  
		if ri_eitf00_21  eq . then ri_eitf00_21=0;           
		if abs00_21  eq . then abs00_21=0;  
		if ri_eitf94_03  eq . then ri_eitf94_03=0;           
		if abs94_03  eq . then abs94_03=0;  
		if ri_fas2       eq . then ri_fas2=0;      
		if fas2  eq . then fas2=0;  
		if ri_fas5       eq . then ri_fas5=0;      
		if fas5  eq . then fas5=0;  
		if ri_fas7       eq . then ri_fas7=0;      
		if fas7  eq . then fas7=0;  
		if ri_fas13      eq . then ri_fas13=0;       
		if fas13  eq . then fas13=0;  
		if ri_fas15      eq . then ri_fas15=0;       
		if fas15  eq . then fas15=0;  
		if ri_fas16      eq . then ri_fas16=0;      
		if fas16  eq . then fas16=0;  
		if ri_fas19      eq . then ri_fas19=0;       
		if  fas19  eq . then fas19=0;  
		if ri_fas34      eq . then ri_fas34=0;      
		if fas34  eq . then fas34=0;  
		if ri_fas35      eq . then ri_fas35=0;      
		if fas35  eq . then fas35=0;  
		if ri_fas43      eq . then ri_fas43=0;       
		if fas43  eq . then fas43=0;  
		if ri_fas45      eq . then ri_fas45=0;      
		if fas45  eq . then fas45=0;  
		if ri_fas47      eq . then ri_fas47=0;       
		if fas47  eq . then fas47=0;  
		if ri_fas48      eq . then ri_fas48=0;      
		if fas48  eq . then fas48=0;  
		if ri_fas49      eq . then ri_fas49=0;      
		if fas49  eq . then fas49=0;  
		if ri_fas50      eq . then ri_fas50=0;      
		if fas50  eq . then fas50=0;  
		if ri_fas51      eq . then ri_fas51=0;      
		if fas51  eq . then fas51=0;  
		if ri_fas52      eq . then ri_fas52=0;      
		if fas52  eq . then fas52=0;  
		if ri_fas53      eq . then ri_fas53=0;       
		if fas53  eq . then fas53=0;  
		if ri_fas57      eq . then ri_fas57=0;      
		if fas57  eq . then fas57=0;  
		if ri_fas60      eq . then ri_fas60=0;      
		if fas60  eq . then fas60=0;  
		if ri_fas61      eq . then ri_fas61=0;       
		if fas61  eq . then fas61=0;  
		if ri_fas63      eq . then ri_fas63=0;       
		if fas63  eq . then fas63=0;  
		if ri_fas65      eq . then ri_fas65=0;       
		if fas65  eq . then fas65=0;  
		if ri_fas66      eq . then ri_fas66=0;       
		if fas66  eq . then fas66=0;  
		if ri_fas67      eq . then ri_fas67=0;       
		if fas67  eq . then fas67=0;  
		if ri_fas68      eq . then ri_fas68=0;       
		if fas68  eq . then fas68=0;  
		if ri_fas71      eq . then ri_fas71=0;       
		if fas71  eq . then fas71=0;  
		if ri_fas77      eq . then ri_fas77=0;       
		if fas77  eq . then fas77=0;  
		if ri_fas80      eq . then ri_fas80=0;       
		if fas80  eq . then fas80=0;  
		if ri_fas86      eq . then ri_fas86=0;       
		if fas86  eq . then fas86=0;  
		if ri_fas87      eq . then ri_fas87=0;       
		if fas87  eq . then fas87=0;  
		if ri_fas88      eq . then ri_fas88=0;      
		if fas88  eq . then fas88=0;  
		if ri_fas97      eq . then ri_fas97=0;       
		if fas97  eq . then fas97=0;  
		if ri_fas101     eq . then ri_fas101=0;        
		if fas101  eq . then fas101=0;  
		if ri_fas105     eq . then ri_fas105=0;        
		if fas105  eq . then fas105=0;  
		if ri_fas106     eq . then ri_fas106=0;        
		if fas106  eq . then fas106=0;  
		if ri_fas107     eq . then ri_fas107=0;        
		if fas107  eq . then fas107=0;  
		if ri_fas109     eq . then ri_fas109=0;        
		if fas109  eq . then fas109=0;  
		if ri_fas113     eq . then ri_fas113=0;        
		if fas113  eq . then fas113=0;  
		if ri_fas115     eq . then ri_fas115=0;        
		if fas115  eq . then fas115=0;  
		if ri_fas116     eq . then ri_fas116=0;        
		if fas116  eq . then fas116=0;  
		if ri_fas119     eq . then ri_fas119=0;        
		if fas119  eq . then fas119=0;  
		if ri_fas121     eq . then ri_fas121=0;        
		if fas121  eq . then fas121=0;  
		if ri_fas123     eq . then ri_fas123=0;       
		if fas123  eq . then fas123=0;  
		if ri_fas123r    eq . then ri_fas123r=0;       
		if fas123r  eq . then fas123r=0;  
		if ri_fas125     eq . then ri_fas125=0;        
		if fas125  eq . then fas125=0;  
		if ri_fas130     eq . then ri_fas130=0;        
		if fas130  eq . then fas130=0;  
		if ri_fas132     eq . then ri_fas132=0;        
		if fas132  eq . then fas132=0;  
		if ri_fas132r    eq . then ri_fas132r=0;        
		if fas132r  eq . then fas132r=0;  
		if ri_fas133     eq . then ri_fas133=0;       
		if fas133  eq . then fas133=0;  
		if ri_fas140     eq . then ri_fas140=0;        
		if fas140  eq . then fas140=0;  
		if ri_fas141     eq . then ri_fas141=0;       
		if fas141  eq . then fas141=0;  
		if ri_fas142     eq . then ri_fas142=0;       
		if fas142  eq . then fas142=0;  
		if ri_fas143     eq . then ri_fas143=0;       
		if fas143  eq . then fas143=0;  
		if ri_fas144     eq . then ri_fas144=0;       
		if fas144  eq . then fas144=0;  
		if ri_fas146     eq . then ri_fas146=0;       
		if fas146  eq . then fas146=0;  
		if ri_fas150     eq . then ri_fas150=0;       
		if fas150  eq . then fas150=0;  
		if ri_fas154     eq . then ri_fas154=0;       
		if fas154  eq . then fas154=0;  
		if ri_sab101 eq . then ri_sab101=0;  
		if sab101  eq . then sab101=0;  
		if ri_sop97_2 eq . then ri_sop97_2=0;  
		if sop97_2  eq . then sop97_2=0;  
		run;


		data ds2; set ds1a;
		Dscore=-1*(ri_apb25*apb25+
		ri_apb2*apb2+
		ri_apb4*apb4+
		ri_apb9*apb9+
		ri_apb14*apb14+
		ri_apb16*apb16+
		ri_apb17*apb17+
		ri_apb18*apb18+
		ri_apb20*apb20+
		ri_apb21*apb21+
		ri_apb23*apb23+
		ri_apb26*apb26+
		ri_apb29*apb29+
		ri_apb30*apb30+
		ri_arb45*arb45+
		ri_arb51*arb51+
		ri_arb43_2a*arb43_2a+
		ri_arb43_3a*arb43_3a+
		ri_arb43_3b*arb43_3b+
		ri_arb43_4*arb43_4+
		ri_arb43_7a*arb43_7a+
		ri_arb43_7b*arb43_7b+
		ri_arb43_9a*arb43_9a+
		ri_arb43_9b*arb43_9b+
		ri_arb43_10a*arb43_10a+
		ri_arb43_11a*arb43_11a+
		ri_arb43_11b*arb43_11b+
		ri_arb43_11c*arb43_11c+
		ri_arb43_12*arb43_12+
		ri_con5_6*con5_6+
		ri_eitf00_21*abs00_21+
		ri_eitf94_03*abs94_03+
		ri_fas2*fas2+
		ri_fas5*fas5+
		ri_fas7*fas7+
		ri_fas13*fas13+
		ri_fas15*fas15+
		ri_fas16*fas16+
		ri_fas19*fas19+
		ri_fas34*fas34+
		ri_fas35*fas35+
		ri_fas43*fas43+
		ri_fas45*fas45+
		ri_fas47*fas47+
		ri_fas48*fas48+
		ri_fas49*fas49+
		ri_fas50*fas50+
		ri_fas51*fas51+
		ri_fas52*fas52+
		ri_fas53*fas53+
		ri_fas57*fas57+
		ri_fas60*fas60+
		ri_fas61*fas61+
		ri_fas63*fas63+
		ri_fas65*fas65+
		ri_fas66*fas66+
		ri_fas67*fas67+
		ri_fas68*fas68+
		ri_fas71*fas71+
		ri_fas77*fas77+
		ri_fas80*fas80+
		ri_fas86*fas86+
		ri_fas87*fas87+
		ri_fas88*fas88+
		ri_fas97*fas97+
		ri_fas101*fas101+
		ri_fas105*fas105+
		ri_fas106*fas106+
		ri_fas107*fas107+
		ri_fas109*fas109+
		ri_fas113*fas113+
		ri_fas115*fas115+
		ri_fas116*fas116+
		ri_fas119*fas119+
		ri_fas121*fas121+
		ri_fas123*fas123+
		ri_fas123r*fas123r+
		ri_fas125*fas125+
		ri_fas130*fas130+
		ri_fas132*fas132+
		ri_fas132r*fas132r+
		ri_fas133*fas133+
		ri_fas140*fas140+
		ri_fas141*fas141+
		ri_fas142*fas142+
		ri_fas143*fas143+
		ri_fas144*fas144+
		ri_fas146*fas146+
		ri_fas150*fas150+
		ri_fas154*fas154+
		ri_sab101*sab101+
		ri_sop97_2*sop97_2);
		run;

		data dperm.dscore_length_rr1az; set ds2;
		run;

		data dperm.dscore_limited_length_rr1az; set ds2;
		keep cik datadate fyear permno gvkey year dscore;
		run;




	/*END:e. Create modal counts rr1z*/
	/*BEGIN: f. Create alternative measure orthogonalized to Length*/
			libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
			libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
			libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
			/*bring in word count data*/


			data ps8; set dperm.rel_imp;run;

			/*below code brings in the count of shall,should must */

			/*brings in raw word counts...This brings in the word counts
			from standards but not ASUS*/
			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\modal_words.xlsx'
			DBMS = xlsx OUT = mwords;run;

			data dperm.words1; set mwords;run;
			data words; set dperm.words1;
			drop sentence n o p q r s t u v w;
			run;



			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
			DBMS = xlsx OUT = rbc;run;
			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
			DBMS = xlsx OUT = rbc2;run;



			/*rbc2 contains which standards are effective in which years some of the 
			iteration variables are whole numbers and some are decimals. i.e. iteration 1 is 
			sometimes represented as 1 and sometimes represented as .1 so I altered them to all be
			whole numbers*/




			data rbc2; set rbc2;
			iter=iteration;
			if iteration =: '0.' then iter=iteration*10;
			if iteration =: '0.91' then iter=iteration*100;
			if iteration =: '0.92' then iter=iteration*100;
			if iteration =: '0.93' then iter=iteration*100;
			if iteration =: '0.94' then iter=iteration*100;
			if iteration =: '.94' then iter=iteration*100;
			if iteration =: '0.95' then iter=iteration*100;
			if iteration =: '0.96' then iter=iteration*100;
			if iteration =: '0.15' then iter=iteration*100;
			if iteration =: '0.11' then iter=iteration*100;
			if iteration =: '0.12' then iter=iteration*100;
			if iteration =: '0.13' then iter=iteration*100;
			if iteration =: '0.14' then iter=iteration*100;
			if iteration =: '0.16' then iter=iteration*100;
			if iteration =: '0.17' then iter=iteration*100;
			if iteration =: '0.18' then iter=iteration*100;
			if iteration =: '0.19' then iter=iteration*100;
			orgx=compress(cat(org,std_num));
			if org='apb' and std_num='15' and year=1996 then matchv=1;
			run;

			data rbc1; set rbc;
			yeary=year*1;
			if standard='apb15' and year=1997 then yeary=1996;
			if standard='arb43_11b' and year ge 2006 then yeary=2005;
			run;

			proc sql; create table rbc3 as select
			a.*, b.*
			from rbc2 as a left join rbc1 b
			on b.standard=a.orgx and a.year=b.yeary
			order by org, std_num,year, iteration;
			quit;


			/*data test; set rbc2;
			keep org iter iteration std_num;
			run;


			proc sort data=test out=test2 nodupkey; by iter;run;*/

			/*we only want to keep the word counts for a subset of words*/

			proc sort data=words out=words1 nodupkey; by filename org stddev stditr word;run;


			data shall; set words1;
			where word in ('shall','must','should');
			run;

			proc sort data=shall out=shalln nodupkey; by filename;run;




			data shall21; set dperm.shall21rraz;
			run;

			/*I need to combine with reliance data and then orthogonalize
			with complexity*/




			proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\rbc_ready_to_merge.xlsx' 
			DBMS = xlsx OUT = rbcm ;run;
			proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\complexity_ready_to_merge.xlsx' 
			DBMS = xlsx OUT = compm ;run;

			data shall21a; set shall21;
			linkz=compress(cat(org,std_num));
			run;

			proc sql; create table shall21b as select
			a.*, b.complex1,b.complex2
			from shall21a as a  left join compm as b
			on a.linkz=b.link
			order by org, std_num, year;
			quit;

			data shall21c; set shall21b;
			linky=compress(cat(year,org,std_num));
			run;

			proc sql; create table shall21d as select
			a.*, b.rbc1,b.rbc2
			from shall21c as a  left join rbcm as b
			on a.linky=b.link
			order by org, std_num, year;
			quit;

			data shall21e; set shall21d;
			drop linkz linky;
			if complex1 eq . then complex1=0;
			if complex2 eq . then complex2=0;
			iteration1=iteration*1;
			run;








			data shallna; set shalln;
			if org="sop" then stddev=tranwrd(stddev,"-","_");
			if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stddev="97_2";
			if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stditr="0.1";
			org1=lowcase(org);
			if org="SAB" and stddev="01A" then stddev="101A";
			if org="SAB" and stddev="01B" then stddev="101B";
			std_num=lowcase(stddev);
			stditr1=stditr*1;
			if org="fas" and stditr ge 1 then stditr1=stditr/10;
			if org="fas" and stditr ge 10 then stditr1=stditr/100;
			if org="apb" and stditr ge 1 then stditr1=stditr/10;
			if org="apb" and stditr ge 10 then stditr1=stditr/100;
			if org="apb" and stddev=1 and stditr eq 1 then stditr1=stditr*1;
			if org="apb" and stddev=1 and stditr eq 2 then stditr1=stditr*1;
			if org="apb" and stddev=5 and stditr eq 1 then stditr1=stditr*1;
			if org="apb" and stddev=5 and stditr eq 2 then stditr1=stditr*1;
			if filename="apb9.1.5.txt" then stditr1="0.15";
			if org1="arb" and stditr ge 1 then stditr1=stditr/10;
			if stddev="43_2A" then stddev=std_num;
			if stddev="43_2B" then stddev=std_num;
			if filename="abs00-21.txt" then org1="eitf";
			if filename="abs00-21.txt" then stddev=tranwrd(stddev,"-","_");
			if org="fas" and stddev="141ri" then stddev="141r";
			if org="fas" and stddev="158i" then stddev="158";
			if org="fas" and stddev="159i" then stddev="159";
			if org="fas" and stddev="160i" then stddev="160";
			if org="fas" and stddev="161a" then stddev="161";
			if org="fas" and stddev="162i" then stddev="162";
			if org="fas" and stddev="163i" then stddev="163";
			if org="fas" and stddev="164i" then stddev="164";
			if org="fas" and stddev="165i" then stddev="165";
			if org="fas" and stddev="166i" then stddev="166";
			if org="fas" and stddev="167i" then stddev="167";
			if org1="fas" and stddev="44" then stditr1=stditr/10;

			run;


			proc sql; create table length as select
			a.*, b.totalword as length
			from shall21e as a left join shallna b
			on a.org=b.org1 and a.std_num=b.stddev and a.iteration1=b.stditr1
			order by org, std_num, stditr;
			quit;


			/*I manually had to gather thess word lengths*/
			data length1; set length;
			if org=:"eitf" and std_num=:"94_3" then length=5306;
			if org="fas" and std_num="68" then length=1816; 
			if org="arb" and std_num="43_3b" and iteration=0 then length=584; 
			if org="fas" and std_num="113" and iteration=0.3 then length=5955; 
			if org="fas" and std_num="15" and iteration=0.93 then length=5042;
			if org="fas" and std_num="156" and iteration=0.1 then length=40929;
			if org="fas" and std_num="67" and iteration=0.6 then length=3497;
			if org="fas" and std_num="53"  then length=3942;/**/
			*stm=total_modal/length;
			*length1=length*1;
			run;


			/*****this section adds in the changes in length in the post codification period*******/
			data shall15o; set dperm.shall15rra;
			yearz=year*1;
			run;

			proc sort data=shall15o out=shall15m; by standard descending year; run;
			proc sort data=shall15m out=shall15n nodupkey; by standard; run;

			data shall15p; set shall15n;
			if year=2009;
			run;

			proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\myear.xlsx' 
			DBMS = xlsx OUT = myear ;run;


			proc sql; create table shall15q as select
			a.*, b.*
			from myear as a , shall15p b
			order by standard, myear;
			quit;

			data shall15r; set shall15q;
			if myear ne 2009;
			year=myear;
			drop myear;
			run;

			data shall15s; set shall15o shall15r;run;

			proc sort data=shall15s; by standard year;run;

			data link; set dperm.cod_link;
			link1=lowcase(compress(link));
			asuyear1=asuyear*1;
			if link1 =: "eitf" then link1=tranwrd(link1,"-","_");
			if link1 =: "sop" then link1=tranwrd(link1,"-","_");
			run;

			proc sort data=link; by link1;run;

			data shall15sa; set shall15s;
			link=compress(cat(org,std_num));
			yearx1=year*1;
			run;

			data link1; set link;
			if AorD="A" then total=total;
			if AorD="D" then total=total*-1;
			mergeyear=year(asu_eff_date);
			if asuyear1 gt mergeyear then mergeyear=asuyear1;
			run;




			data link1z; set link1;
			if link1="fas141(r)" then link1="fas141r";
			if link1="fas123(r)" then link1="fas123r";
			if link1="fas132(r)" then link1="fas132r";
			run;

			proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\wcasu.xlsx' 
			DBMS = xlsx OUT = wcasu1 ;run;


			proc sql; create table lz1 as select
			a.*, b.wcasu
			from link1z as a  left join wcasu1 as b
			on a.filename=b.filename ;
			quit;

			data lz2; set lz1;
			if AorD="A" then wcasu=wcasu;
			if AorD="D" then wcasu=wcasu*-1;
			run;



			proc sql; create table shall15t as select
			a.*, b.topic, b.subtopic,b.section,b.paragraph,b.wcasu
			from shall15sa as a  left join lz2 as b
			on a.link=b.link1 and a.yearx1>=b.mergeyear
			order by standard, year;
			quit;





			proc sql; create table shall15u as select distinct
			filename, org,stddev,stditr,year,
							sum(wcasu) as wcASUt

			from shall15t group by filename,org,stddev,stditr,year
			order by filename,org,stddev,stditr,year;
			quit;



			proc sql; create table l1 as select
			a.*, b.wcASUt
			from shall15sa as a  left join shall15u as b
			on a.org=b.org and a.stddev=b.stddev and a.year=b.year
			order by standard, year;
			quit;

			proc sort data=l1 out=shall15w noduprecs; by standard year; run;


			proc sql; create table l1 as select
			a.*, b.wcASUt
			from shall15sa as a  left join shall15u as b
			on a.org=b.org and a.stddev=b.stddev and a.year=b.year
			order by standard, year;
			quit;

			proc sql; create table l2 as select
			a.*, b.wcASUt
			from length1 as a  left join l1 as b
			on a.org=b.org and a.std_num=b.std_num and a.year=b.year
			order by standard, year;
			quit;


			data length2; set l2;
			if wcasut eq . then wcasut=0;
			tlength=length+wcasut;
			stm=total_modal/tlength;
			tlength1=tlength*1;
			run;



			/************/



			proc reg data=length2 ;
			model total_modal= complex1 complex2 tlength1;
			output out=ds
			p=predicted
			r=residual;
			run;quit;

			proc sort data=ds; by org std_num year;run;

			data dperm.orthlengthrraz; set ds;
			keep org std_num iteration year end_dt stditr1 igr1 restrict arnew total_modal stm eff_date complex1 complex2 length org1 iteration1 totr predicted residual rbc1 rbc2 tlength;
			run;


			Proc export data=dperm.orthlengthrraz
			outfile='C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\orthlengthrraz.xlsx'
			dbms=xlsx
			replace;
			run;

			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\imp1_orthlengthrraz.xlsx'
			dbms=xlsx OUT = imp1;run;

			data ps9; set ps8;
			if fyear ne . then year=fyear;
			if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
			if fyear eq . and month(datadate) gt 5 then year=year(datadate);
			run;

			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
			dbms=xlsx OUT = mdataa;run;

			data mdata3; set mdataa;
			/*I added this line to include fas141r which is included
			in the word counts of 141*/
			max_fas141=max_fas141r;
			id=1;
			if min_apb2 ne .;
			drop ko kp;
			run;
			data ps9; set ps9;
			id=1;
			run;

			proc sql; create table ps10 as select
			a.*, b.*
			from ps9 as a left join mdata3 b
			on a.id=b.id
			order by cik, fyear;
			quit;

			data ps11 ; set ps10;
			if fyear lt min_apb25 then ri_apb25=0;
			if fyear gt max_apb25 then ri_apb25=0;

			if fyear lt min_apb4 then ri_apb4=0;
			if fyear gt max_apb4 then ri_apb4=0;

			if fyear lt min_apb9 then ri_apb9=0;
			if fyear gt max_apb9 then ri_apb9=0;

			if fyear lt min_apb14 then ri_apb14=0;
			if fyear gt max_apb14 then ri_apb14=0;

			if fyear lt min_apb16 then ri_apb16=0;
			if fyear gt max_apb16 then ri_apb16=0;

			if fyear lt min_apb17 then ri_apb17=0;
			if fyear gt max_apb17 then ri_apb17=0;

			if fyear lt min_apb18 then ri_apb18=0;
			if fyear gt max_apb18 then ri_apb18=0;

			if fyear lt min_apb20 then ri_apb20=0;
			if fyear gt max_apb20 then ri_apb20=0;

			if fyear lt min_apb21 then ri_apb21=0;
			if fyear gt max_apb21 then ri_apb21=0;

			if fyear lt min_apb23 then ri_apb23=0;
			if fyear gt max_apb23 then ri_apb23=0;

			if fyear lt min_apb26 then ri_apb26=0;
			if fyear gt max_apb26 then ri_apb26=0;

			if fyear lt min_apb29 then ri_apb29=0;
			if fyear gt max_apb29 then ri_apb29=0;

			if fyear lt min_apb30 then ri_apb30=0;
			if fyear gt max_apb30 then ri_apb30=0;

			if fyear lt min_arb45 then ri_arb45=0;
			if fyear gt max_arb45 then ri_arb45=0;

			if fyear lt min_arb51 then ri_arb51=0;
			if fyear gt max_arb51 then ri_arb51=0;

			if fyear lt min_arb43_2a then ri_arb43_2a=0;
			if fyear gt max_arb43_2a then ri_arb43_2a=0;

			if fyear lt min_arb43_3a then ri_arb43_3a=0;
			if fyear gt max_arb43_3a then ri_arb43_3a=0;

			if fyear lt min_arb43_3b then ri_arb43_3b=0;
			if fyear gt max_arb43_3b then ri_arb43_3b=0;

			if fyear lt min_arb43_4 then ri_arb43_4=0;
			if fyear gt max_arb43_4 then ri_arb43_4=0;

			if fyear lt min_arb43_7a then ri_arb43_7a=0;
			if fyear gt max_arb43_7a then ri_arb43_7a=0;

			if fyear lt min_arb43_7b then ri_arb43_7b=0;
			if fyear gt max_arb43_7b then ri_arb43_7b=0;

			if fyear lt min_arb43_9a then ri_arb43_9a=0;
			if fyear gt max_arb43_9a then ri_arb43_9a=0;

			if fyear lt min_arb43_9b then ri_arb43_9b=0;
			if fyear gt max_arb43_9b then ri_arb43_9b=0;

			if fyear lt min_arb43_10a then ri_arb43_10a=0;
			if fyear gt max_arb43_10a then ri_arb43_10a=0;

			if fyear lt min_arb43_11a then ri_arb43_11a=0;
			if fyear gt max_arb43_11a then ri_arb43_11a=0;

			if fyear lt min_arb43_11b then ri_arb43_11b=0;
			if fyear gt max_arb43_11b then ri_arb43_11b=0;

			if fyear lt min_arb43_11c then ri_arb43_11c=0;
			if fyear gt max_arb43_11c then ri_arb43_11c=0;

			if fyear lt min_arb43_12 then ri_arb43_12=0;
			if fyear gt max_arb43_12 then ri_arb43_12=0;

			if fyear lt min_con5_6 then ri_con5_6=0;
			if fyear gt max_con5_6 then ri_con5_6=0;

			if fyear lt min_eitf00_21 then ri_eitf00_21=0;
			if fyear gt max_eitf00_21 then ri_eitf00_21=0;

			if fyear lt min_eitf94_3 then ri_eitf94_03=0;
			if fyear gt max_eitf94_3 then ri_eitf94_03=0;

			if fyear lt min_fas2 then ri_fas2=0;
			if fyear gt max_fas2 then ri_fas2=0;

			if fyear lt min_fas5 then ri_fas5=0;
			if fyear gt max_fas5 then ri_fas5=0;

			if fyear lt min_fas7 then ri_fas7=0;
			if fyear gt max_fas7 then ri_fas7=0;

			if fyear lt min_fas13 then ri_fas13=0;
			if fyear gt max_fas13 then ri_fas13=0;

			if fyear lt min_fas15 then ri_fas15=0;
			if fyear gt max_fas15 then ri_fas15=0;

			if fyear lt min_fas16 then ri_fas16=0;
			if fyear gt max_fas16 then ri_fas16=0;

			if fyear lt min_fas19 then ri_fas19=0;
			if fyear gt max_fas19 then ri_fas19=0;

			if fyear lt min_fas34 then ri_fas34=0;
			if fyear gt max_fas34 then ri_fas34=0;

			if fyear lt min_fas35 then ri_fas35=0;
			if fyear gt max_fas35 then ri_fas35=0;

			if fyear lt min_fas43 then ri_fas43=0;
			if fyear gt max_fas43 then ri_fas43=0;

			if fyear lt min_fas45 then ri_fas45=0;
			if fyear gt max_fas45 then ri_fas45=0;

			if fyear lt min_fas47 then ri_fas47=0;
			if fyear gt max_fas47 then ri_fas47=0;

			if fyear lt min_fas48 then ri_fas48=0;
			if fyear gt max_fas48 then ri_fas48=0;

			if fyear lt min_fas49 then ri_fas49=0;
			if fyear gt max_fas49 then ri_fas49=0;

			if fyear lt min_fas50 then ri_fas50=0;
			if fyear gt max_fas50 then ri_fas50=0;

			if fyear lt min_fas51 then ri_fas51=0;
			if fyear gt max_fas51 then ri_fas51=0;

			if fyear lt min_fas52 then ri_fas52=0;
			if fyear gt max_fas52 then ri_fas52=0;

			if fyear lt min_fas53 then ri_fas53=0;
			if fyear gt max_fas53 then ri_fas53=0;

			if fyear lt min_fas57 then ri_fas57=0;
			if fyear gt max_fas57 then ri_fas57=0;

			if fyear lt min_fas60 then ri_fas60=0;
			if fyear gt max_fas60 then ri_fas60=0;

			if fyear lt min_fas61 then ri_fas61=0;
			if fyear gt max_fas61 then ri_fas61=0;

			if fyear lt min_fas63 then ri_fas63=0;
			if fyear gt max_fas63 then ri_fas63=0;

			if fyear lt min_fas65 then ri_fas65=0;
			if fyear gt max_fas65 then ri_fas65=0;

			if fyear lt min_fas66 then ri_fas66=0;
			if fyear gt max_fas66 then ri_fas66=0;

			if fyear lt min_fas67 then ri_fas67=0;
			if fyear gt max_fas67 then ri_fas67=0;

			if fyear lt min_fas68 then ri_fas68=0;
			if fyear gt max_fas68 then ri_fas68=0;

			if fyear lt min_fas71 then ri_fas71=0;
			if fyear gt max_fas71 then ri_fas71=0;

			if fyear lt min_fas77 then ri_fas77=0;
			if fyear gt max_fas77 then ri_fas77=0;

			if fyear lt min_fas80 then ri_fas80=0;
			if fyear gt max_fas80 then ri_fas80=0;

			if fyear lt min_fas86 then ri_fas86=0;
			if fyear gt max_fas86 then ri_fas86=0;

			if fyear lt min_fas87 then ri_fas87=0;
			if fyear gt max_fas87 then ri_fas87=0;

			if fyear lt min_fas88 then ri_fas88=0;
			if fyear gt max_fas88 then ri_fas88=0;

			if fyear lt min_fas97 then ri_fas97=0;
			if fyear gt max_fas97 then ri_fas97=0;

			if fyear lt min_fas101 then ri_fas101=0;
			if fyear gt max_fas101 then ri_fas101=0;

			if fyear lt min_fas105 then ri_fas105=0;
			if fyear gt max_fas105 then ri_fas105=0;

			if fyear lt min_fas106 then ri_fas106=0;
			if fyear gt max_fas106 then ri_fas106=0;

			if fyear lt min_fas107 then ri_fas107=0;
			if fyear gt max_fas107 then ri_fas107=0;

			if fyear lt min_fas109 then ri_fas109=0;
			if fyear gt max_fas109 then ri_fas109=0;

			if fyear lt min_fas113 then ri_fas113=0;
			if fyear gt max_fas113 then ri_fas113=0;

			if fyear lt min_fas115 then ri_fas115=0;
			if fyear gt max_fas115 then ri_fas115=0;

			if fyear lt min_fas119 then ri_fas116=0;
			if fyear gt max_fas119 then ri_fas116=0;

			if fyear lt min_fas121 then ri_fas121=0;
			if fyear gt max_fas121 then ri_fas121=0;

			if fyear lt min_fas123 then ri_fas123=0;
			if fyear gt max_fas123 then ri_fas123=0;

			if fyear lt min_fas123r then ri_fas123r=0;
			if fyear gt max_fas123r then ri_fas123r=0;

			if fyear lt min_fas125 then ri_fas125=0;
			if fyear gt max_fas125 then ri_fas125=0;

			if fyear lt min_fas130 then ri_fas130=0;
			if fyear gt max_fas130 then ri_fas130=0;

			if fyear lt min_fas132 then ri_fas132=0;
			if fyear gt max_fas132 then ri_fas132=0;

			if fyear lt min_fas132r then ri_fas132r=0;
			if fyear gt max_fas132r then ri_fas132r=0;

			if fyear lt min_fas133 then ri_fas133=0;
			if fyear gt max_fas133 then ri_fas133=0;

			if fyear lt min_fas140 then ri_fas140=0;
			if fyear gt max_fas140 then ri_fas140=0;

			if fyear lt min_fas141 then ri_fas141=0;
			if fyear gt max_fas141 then ri_fas141=0;

			if fyear lt min_fas142 then ri_fas142=0;
			if fyear gt max_fas142 then ri_fas142=0;

			if fyear lt min_fas143 then ri_fas143=0;
			if fyear gt max_fas143 then ri_fas143=0;

			if fyear lt min_fas144 then ri_fas144=0;
			if fyear gt max_fas144 then ri_fas144=0;

			if fyear lt min_fas146 then ri_fas146=0;
			if fyear gt max_fas146 then ri_fas146=0;

			if fyear lt min_fas150 then ri_fas150=0;
			if fyear gt max_fas150 then ri_fas150=0;
			if fyear lt min_fas154 then ri_fas154=0;
			if fyear gt max_fas154 then ri_fas154=0;
			if fyear lt min_sab101 then ri_sab101=0;
			if fyear gt max_sab101 then ri_sab101=0;
			if fyear lt min_sop97_2 then ri_sop97_2=0;
			if fyear gt max_sop97_2 then ri_sop97_2=0;
			if fyear lt 2009 then ri_asu2009_17=0;
			if fyear lt 2011 then ri_asu2011_08=0;
			if fyear lt 2012 then ri_asu2012_01=0;
			if fyear lt 2012 then ri_asu2012_02=0;
			run;


			proc sql; create table ds1 as select
			a.*, b.*
			from ps11 as a left join imp1 b
			on a.year=b.year
			order by cik, fyear;
			quit;


			data ds1a; set ds1;
			if ri_apb25 eq . then  ri_apb25=0;    
			if apb25 eq . then  apb25=0; 
			if ri_apb2  eq . then  ri_apb2=0;           
			if apb2 eq . then  apb2=0; 
			if ri_apb4 eq . then  ri_apb4=0;          
			if apb4 eq . then  apb4=0; 
			if ri_apb9 eq . then  ri_apb9=0;          
			if apb9 eq . then  apb9=0; 
			if ri_apb14 eq . then  ri_apb14=0;           
			if apb14 eq . then apb14=0; 
			if ri_apb16 eq . then  ri_apb16=0;          
			if apb16 eq . then apb16=0; 
			if ri_apb17 eq . then  ri_apb17=0;         
			if apb17 eq . then apb17=0; 
			if ri_apb18 eq . then  ri_apb18=0;         
			if apb18 eq . then  apb18=0; 
			if ri_apb20 eq . then  ri_apb20=0;          
			if apb20 eq . then  apb20=0; 
			if ri_apb21 eq . then  ri_apb21=0;          
			if apb21 eq . then  apb21=0; 
			if ri_apb23 eq . then  ri_apb23=0;          
			if apb23 eq . then  apb23=0; 
			if ri_apb26 eq . then  ri_apb26=0;          
			if apb26 eq . then  apb26=0; 
			if ri_apb29 eq . then  ri_apb29=0;          
			if apb29 eq . then  apb29=0; 
			if ri_apb30 eq . then  ri_apb30=0;          
			if apb30 eq . then  apb30=0; 
			if ri_arb45 eq .  then ri_arb45=0;        
			if arb45  eq . then arb45=0;
			if ri_arb51  eq . then ri_arb51=0;
			if arb51  eq . then arb51=0;
			if ri_arb43_2a  eq . then ri_arb43_2a=0;        
			if arb43_2a eq . then arb43_2a=0;    
			if ri_arb43_3a eq . then ri_arb43_3a=0;              
			if arb43_3a  eq . then arb43_3a=0;  
			if ri_arb43_3b eq . then ri_arb43_3b=0;            
			if arb43_3b  eq . then arb43_3b=0;  
			if ri_arb43_4  eq . then ri_arb43_4=0;           
			if arb43_4  eq . then arb43_4=0;  
			if ri_arb43_7a eq . then ri_arb43_7a=0;           
			if arb43_7a  eq . then arb43_7a=0;  
			if ri_arb43_7b eq . then ri_arb43_7b=0;            
			if arb43_7b  eq . then arb43_7b=0;  
			if ri_arb43_9a eq . then ri_arb43_9a=0;            
			if arb43_9a  eq . then arb43_9a=0;  
			if ri_arb43_9b eq . then ri_arb43_9b=0;            
			if arb43_9b  eq . then arb43_9b=0;  
			if ri_arb43_10a  eq . then ri_arb43_10a=0;           
			if arb43_10a  eq . then arb43_10a=0;  
			if ri_arb43_11a  eq . then ri_arb43_11a=0;            
			if arb43_11a  eq . then arb43_11a=0;  
			if ri_arb43_11b  eq . then ri_arb43_11b=0;           
			if arb43_11b  eq . then arb43_11b=0;  
			if ri_arb43_11c  eq . then ri_arb43_11c=0;          
			if arb43_11c  eq . then arb43_11c=0;  
			if ri_arb43_12   eq . then ri_arb43_12=0;          
			if arb43_12  eq . then arb43_12=0;  
			if ri_con5_6     eq . then ri_con5_6=0;       
			if con5_6  eq . then con5_6=0;  
			if ri_eitf00_21  eq . then ri_eitf00_21=0;           
			if abs00_21  eq . then abs00_21=0;  
			if ri_eitf94_03  eq . then ri_eitf94_03=0;           
			if abs94_03  eq . then abs94_03=0;  
			if ri_fas2       eq . then ri_fas2=0;      
			if fas2  eq . then fas2=0;  
			if ri_fas5       eq . then ri_fas5=0;      
			if fas5  eq . then fas5=0;  
			if ri_fas7       eq . then ri_fas7=0;      
			if fas7  eq . then fas7=0;  
			if ri_fas13      eq . then ri_fas13=0;       
			if fas13  eq . then fas13=0;  
			if ri_fas15      eq . then ri_fas15=0;       
			if fas15  eq . then fas15=0;  
			if ri_fas16      eq . then ri_fas16=0;      
			if fas16  eq . then fas16=0;  
			if ri_fas19      eq . then ri_fas19=0;       
			if  fas19  eq . then fas19=0;  
			if ri_fas34      eq . then ri_fas34=0;      
			if fas34  eq . then fas34=0;  
			if ri_fas35      eq . then ri_fas35=0;      
			if fas35  eq . then fas35=0;  
			if ri_fas43      eq . then ri_fas43=0;       
			if fas43  eq . then fas43=0;  
			if ri_fas45      eq . then ri_fas45=0;      
			if fas45  eq . then fas45=0;  
			if ri_fas47      eq . then ri_fas47=0;       
			if fas47  eq . then fas47=0;  
			if ri_fas48      eq . then ri_fas48=0;      
			if fas48  eq . then fas48=0;  
			if ri_fas49      eq . then ri_fas49=0;      
			if fas49  eq . then fas49=0;  
			if ri_fas50      eq . then ri_fas50=0;      
			if fas50  eq . then fas50=0;  
			if ri_fas51      eq . then ri_fas51=0;      
			if fas51  eq . then fas51=0;  
			if ri_fas52      eq . then ri_fas52=0;      
			if fas52  eq . then fas52=0;  
			if ri_fas53      eq . then ri_fas53=0;       
			if fas53  eq . then fas53=0;  
			if ri_fas57      eq . then ri_fas57=0;      
			if fas57  eq . then fas57=0;  
			if ri_fas60      eq . then ri_fas60=0;      
			if fas60  eq . then fas60=0;  
			if ri_fas61      eq . then ri_fas61=0;       
			if fas61  eq . then fas61=0;  
			if ri_fas63      eq . then ri_fas63=0;       
			if fas63  eq . then fas63=0;  
			if ri_fas65      eq . then ri_fas65=0;       
			if fas65  eq . then fas65=0;  
			if ri_fas66      eq . then ri_fas66=0;       
			if fas66  eq . then fas66=0;  
			if ri_fas67      eq . then ri_fas67=0;       
			if fas67  eq . then fas67=0;  
			if ri_fas68      eq . then ri_fas68=0;       
			if fas68  eq . then fas68=0;  
			if ri_fas71      eq . then ri_fas71=0;       
			if fas71  eq . then fas71=0;  
			if ri_fas77      eq . then ri_fas77=0;       
			if fas77  eq . then fas77=0;  
			if ri_fas80      eq . then ri_fas80=0;       
			if fas80  eq . then fas80=0;  
			if ri_fas86      eq . then ri_fas86=0;       
			if fas86  eq . then fas86=0;  
			if ri_fas87      eq . then ri_fas87=0;       
			if fas87  eq . then fas87=0;  
			if ri_fas88      eq . then ri_fas88=0;      
			if fas88  eq . then fas88=0;  
			if ri_fas97      eq . then ri_fas97=0;       
			if fas97  eq . then fas97=0;  
			if ri_fas101     eq . then ri_fas101=0;        
			if fas101  eq . then fas101=0;  
			if ri_fas105     eq . then ri_fas105=0;        
			if fas105  eq . then fas105=0;  
			if ri_fas106     eq . then ri_fas106=0;        
			if fas106  eq . then fas106=0;  
			if ri_fas107     eq . then ri_fas107=0;        
			if fas107  eq . then fas107=0;  
			if ri_fas109     eq . then ri_fas109=0;        
			if fas109  eq . then fas109=0;  
			if ri_fas113     eq . then ri_fas113=0;        
			if fas113  eq . then fas113=0;  
			if ri_fas115     eq . then ri_fas115=0;        
			if fas115  eq . then fas115=0;  
			if ri_fas116     eq . then ri_fas116=0;        
			if fas116  eq . then fas116=0;  
			if ri_fas119     eq . then ri_fas119=0;        
			if fas119  eq . then fas119=0;  
			if ri_fas121     eq . then ri_fas121=0;        
			if fas121  eq . then fas121=0;  
			if ri_fas123     eq . then ri_fas123=0;       
			if fas123  eq . then fas123=0;  
			if ri_fas123r    eq . then ri_fas123r=0;       
			if fas123r  eq . then fas123r=0;  
			if ri_fas125     eq . then ri_fas125=0;        
			if fas125  eq . then fas125=0;  
			if ri_fas130     eq . then ri_fas130=0;        
			if fas130  eq . then fas130=0;  
			if ri_fas132     eq . then ri_fas132=0;        
			if fas132  eq . then fas132=0;  
			if ri_fas132r    eq . then ri_fas132r=0;        
			if fas132r  eq . then fas132r=0;  
			if ri_fas133     eq . then ri_fas133=0;       
			if fas133  eq . then fas133=0;  
			if ri_fas140     eq . then ri_fas140=0;        
			if fas140  eq . then fas140=0;  
			if ri_fas141     eq . then ri_fas141=0;       
			if fas141  eq . then fas141=0;  
			if ri_fas142     eq . then ri_fas142=0;       
			if fas142  eq . then fas142=0;  
			if ri_fas143     eq . then ri_fas143=0;       
			if fas143  eq . then fas143=0;  
			if ri_fas144     eq . then ri_fas144=0;       
			if fas144  eq . then fas144=0;  
			if ri_fas146     eq . then ri_fas146=0;       
			if fas146  eq . then fas146=0;  
			if ri_fas150     eq . then ri_fas150=0;       
			if fas150  eq . then fas150=0;  
			if ri_fas154     eq . then ri_fas154=0;       
			if fas154  eq . then fas154=0;  
			if ri_sab101 eq . then ri_sab101=0;  
			if sab101  eq . then sab101=0;  
			if ri_sop97_2 eq . then ri_sop97_2=0;  
			if sop97_2  eq . then sop97_2=0;  
			run;


			data ds2; set ds1a;
			Dscore=-1*(ri_apb25*apb25+
			ri_apb2*apb2+
			ri_apb4*apb4+
			ri_apb9*apb9+
			ri_apb14*apb14+
			ri_apb16*apb16+
			ri_apb17*apb17+
			ri_apb18*apb18+
			ri_apb20*apb20+
			ri_apb21*apb21+
			ri_apb23*apb23+
			ri_apb26*apb26+
			ri_apb29*apb29+
			ri_apb30*apb30+
			ri_arb45*arb45+
			ri_arb51*arb51+
			ri_arb43_2a*arb43_2a+
			ri_arb43_3a*arb43_3a+
			ri_arb43_3b*arb43_3b+
			ri_arb43_4*arb43_4+
			ri_arb43_7a*arb43_7a+
			ri_arb43_7b*arb43_7b+
			ri_arb43_9a*arb43_9a+
			ri_arb43_9b*arb43_9b+
			ri_arb43_10a*arb43_10a+
			ri_arb43_11a*arb43_11a+
			ri_arb43_11b*arb43_11b+
			ri_arb43_11c*arb43_11c+
			ri_arb43_12*arb43_12+
			ri_con5_6*con5_6+
			ri_eitf00_21*abs00_21+
			ri_eitf94_03*abs94_03+
			ri_fas2*fas2+
			ri_fas5*fas5+
			ri_fas7*fas7+
			ri_fas13*fas13+
			ri_fas15*fas15+
			ri_fas16*fas16+
			ri_fas19*fas19+
			ri_fas34*fas34+
			ri_fas35*fas35+
			ri_fas43*fas43+
			ri_fas45*fas45+
			ri_fas47*fas47+
			ri_fas48*fas48+
			ri_fas49*fas49+
			ri_fas50*fas50+
			ri_fas51*fas51+
			ri_fas52*fas52+
			ri_fas53*fas53+
			ri_fas57*fas57+
			ri_fas60*fas60+
			ri_fas61*fas61+
			ri_fas63*fas63+
			ri_fas65*fas65+
			ri_fas66*fas66+
			ri_fas67*fas67+
			ri_fas68*fas68+
			ri_fas71*fas71+
			ri_fas77*fas77+
			ri_fas80*fas80+
			ri_fas86*fas86+
			ri_fas87*fas87+
			ri_fas88*fas88+
			ri_fas97*fas97+
			ri_fas101*fas101+
			ri_fas105*fas105+
			ri_fas106*fas106+
			ri_fas107*fas107+
			ri_fas109*fas109+
			ri_fas113*fas113+
			ri_fas115*fas115+
			ri_fas116*fas116+
			ri_fas119*fas119+
			ri_fas121*fas121+
			ri_fas123*fas123+
			ri_fas123r*fas123r+
			ri_fas125*fas125+
			ri_fas130*fas130+
			ri_fas132*fas132+
			ri_fas132r*fas132r+
			ri_fas133*fas133+
			ri_fas140*fas140+
			ri_fas141*fas141+
			ri_fas142*fas142+
			ri_fas143*fas143+
			ri_fas144*fas144+
			ri_fas146*fas146+
			ri_fas150*fas150+
			ri_fas154*fas154+
			ri_sab101*sab101+
			ri_sop97_2*sop97_2);
			run;

			data dperm.dscore_orthlength_rr1az; set ds2;
			run;

			data dperm.dscore_limited_orthlength_rr1az; set ds2;
			keep cik datadate fyear permno gvkey year dscore;
			run;




	/*END:f. Create alternative measure orthogonalized to Length*/
	/*BEGIN:g. Create alternative measure orthogonalized to RBC*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/


		data ps8; set dperm.rel_imp;run;

		/*below code brings in the count of shall,should must */

		/*brings in raw word counts...This brings in the word counts
		from standards but not ASUS*/
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\modal_words.xlsx'
		DBMS = xlsx OUT = mwords;run;

		data dperm.words1; set mwords;run;
		data words; set dperm.words1;
		drop sentence n o p q r s t u v w;
		run;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
		DBMS = xlsx OUT = rbc;run;
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
		DBMS = xlsx OUT = rbc2;run;



		/*rbc2 contains which standards are effective in which years some of the 
		iteration variables are whole numbers and some are decimals. i.e. iteration 1 is 
		sometimes represented as 1 and sometimes represented as .1 so I altered them to all be
		whole numbers*/




		data rbc2; set rbc2;
		iter=iteration;
		if iteration =: '0.' then iter=iteration*10;
		if iteration =: '0.91' then iter=iteration*100;
		if iteration =: '0.92' then iter=iteration*100;
		if iteration =: '0.93' then iter=iteration*100;
		if iteration =: '0.94' then iter=iteration*100;
		if iteration =: '.94' then iter=iteration*100;
		if iteration =: '0.95' then iter=iteration*100;
		if iteration =: '0.96' then iter=iteration*100;
		if iteration =: '0.15' then iter=iteration*100;
		if iteration =: '0.11' then iter=iteration*100;
		if iteration =: '0.12' then iter=iteration*100;
		if iteration =: '0.13' then iter=iteration*100;
		if iteration =: '0.14' then iter=iteration*100;
		if iteration =: '0.16' then iter=iteration*100;
		if iteration =: '0.17' then iter=iteration*100;
		if iteration =: '0.18' then iter=iteration*100;
		if iteration =: '0.19' then iter=iteration*100;
		orgx=compress(cat(org,std_num));
		if org='apb' and std_num='15' and year=1996 then matchv=1;
		run;

		data rbc1; set rbc;
		yeary=year*1;
		if standard='apb15' and year=1997 then yeary=1996;
		if standard='arb43_11b' and year ge 2006 then yeary=2005;
		run;

		proc sql; create table rbc3 as select
		a.*, b.*
		from rbc2 as a left join rbc1 b
		on b.standard=a.orgx and a.year=b.yeary
		order by org, std_num,year, iteration;
		quit;


		/*data test; set rbc2;
		keep org iter iteration std_num;
		run;


		proc sort data=test out=test2 nodupkey; by iter;run;*/

		/*we only want to keep the word counts for a subset of words*/

		proc sort data=words out=words1 nodupkey; by filename org stddev stditr word;run;


		data shall; set words1;
		where word in ('shall','must','should');
		run;

		proc sort data=shall out=shalln nodupkey; by filename;run;




		data shall21; set dperm.shall21rraz;
		run;

		/*I need to combine with reliance data and then orthogonalize
		with complexity*/




		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\rbc_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = rbcm ;run;
		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\complexity_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = compm ;run;

		data shall21a; set shall21;
		linkz=compress(cat(org,std_num));
		run;

		proc sql; create table shall21b as select
		a.*, b.complex1,b.complex2
		from shall21a as a  left join compm as b
		on a.linkz=b.link
		order by org, std_num, year;
		quit;

		data shall21c; set shall21b;
		linky=compress(cat(year,org,std_num));
		run;

		proc sql; create table shall21d as select
		a.*, b.rbc1,b.rbc2
		from shall21c as a  left join rbcm as b
		on a.linky=b.link
		order by org, std_num, year;
		quit;

		data shall21e; set shall21d;
		drop linkz linky;
		if complex1 eq . then complex1=0;
		if complex2 eq . then complex2=0;
		iteration1=iteration*1;
		run;








		data shallna; set shalln;
		if org="sop" then stddev=tranwrd(stddev,"-","_");
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stddev="97_2";
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stditr="0.1";
		org1=lowcase(org);
		if org="SAB" and stddev="01A" then stddev="101A";
		if org="SAB" and stddev="01B" then stddev="101B";
		std_num=lowcase(stddev);
		stditr1=stditr*1;
		if org="fas" and stditr ge 1 then stditr1=stditr/10;
		if org="fas" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stditr ge 1 then stditr1=stditr/10;
		if org="apb" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stddev=1 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=1 and stditr eq 2 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 2 then stditr1=stditr*1;
		if filename="apb9.1.5.txt" then stditr1="0.15";
		if org1="arb" and stditr ge 1 then stditr1=stditr/10;
		if stddev="43_2A" then stddev=std_num;
		if stddev="43_2B" then stddev=std_num;
		if filename="abs00-21.txt" then org1="eitf";
		if filename="abs00-21.txt" then stddev=tranwrd(stddev,"-","_");
		if org="fas" and stddev="141ri" then stddev="141r";
		if org="fas" and stddev="158i" then stddev="158";
		if org="fas" and stddev="159i" then stddev="159";
		if org="fas" and stddev="160i" then stddev="160";
		if org="fas" and stddev="161a" then stddev="161";
		if org="fas" and stddev="162i" then stddev="162";
		if org="fas" and stddev="163i" then stddev="163";
		if org="fas" and stddev="164i" then stddev="164";
		if org="fas" and stddev="165i" then stddev="165";
		if org="fas" and stddev="166i" then stddev="166";
		if org="fas" and stddev="167i" then stddev="167";
		if org1="fas" and stddev="44" then stditr1=stditr/10;

		run;


		proc sql; create table length as select
		a.*, b.totalword as length
		from shall21e as a left join shallna b
		on a.org=b.org1 and a.std_num=b.stddev and a.iteration1=b.stditr1
		order by org, std_num, stditr;
		quit;


		/*I manually had to gather these word lengths*/
		data length1; set length;
		if org=:"eitf" and std_num=:"94_3" then length=5306;
		if org="fas" and std_num="68" then length=1816; 
		if org="arb" and std_num="43_3b" and iteration=0 then length=584; 
		if org="fas" and std_num="113" and iteration=0.3 then length=5955; 
		if org="fas" and std_num="15" and iteration=0.93 then length=5042;
		if org="fas" and std_num="156" and iteration=0.1 then length=40929;
		if org="fas" and std_num="67" and iteration=0.6 then length=3497;
		if org="fas" and std_num="53"  then length=3942;
		stm=total_modal/length;
		length1=length*1;
		run;

		proc reg data=length1 ;
		model stm= complex1 complex2 rbc1;
		output out=ds
		p=predicted
		r=residual;
		run;quit;


		data dperm.orthrbcrraz; set ds;
		keep org std_num iteration year end_dt stditr1 igr1 restrict arnew total_modal stm eff_date complex1 complex2 length org1 iteration1 totr predicted residual rbc1 rbc2 length;
		run;


		Proc export data=dperm.orthrbcrraz
		outfile='C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\orthrbcrraz.xlsx'
		dbms=xlsx
		replace;
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\imp1_orthrbcrraz.xlsx'
		dbms=xlsx OUT = imp1;run;

		data ps9; set ps8;
		if fyear ne . then year=fyear;
		if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then year=year(datadate);
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
		dbms=xlsx OUT = mdataa;run;

		data mdata3; set mdataa;
		/*I added this line to include fas141r which is included
		in the word counts of 141*/
		max_fas141=max_fas141r;
		id=1;
		if min_apb2 ne .;
		drop ko kp;
		run;
		data ps9; set ps9;
		id=1;
		run;

		proc sql; create table ps10 as select
		a.*, b.*
		from ps9 as a left join mdata3 b
		on a.id=b.id
		order by cik, fyear;
		quit;

		data ps11 ; set ps10;
		if fyear lt min_apb25 then ri_apb25=0;
		if fyear gt max_apb25 then ri_apb25=0;

		if fyear lt min_apb4 then ri_apb4=0;
		if fyear gt max_apb4 then ri_apb4=0;

		if fyear lt min_apb9 then ri_apb9=0;
		if fyear gt max_apb9 then ri_apb9=0;

		if fyear lt min_apb14 then ri_apb14=0;
		if fyear gt max_apb14 then ri_apb14=0;

		if fyear lt min_apb16 then ri_apb16=0;
		if fyear gt max_apb16 then ri_apb16=0;

		if fyear lt min_apb17 then ri_apb17=0;
		if fyear gt max_apb17 then ri_apb17=0;

		if fyear lt min_apb18 then ri_apb18=0;
		if fyear gt max_apb18 then ri_apb18=0;

		if fyear lt min_apb20 then ri_apb20=0;
		if fyear gt max_apb20 then ri_apb20=0;

		if fyear lt min_apb21 then ri_apb21=0;
		if fyear gt max_apb21 then ri_apb21=0;

		if fyear lt min_apb23 then ri_apb23=0;
		if fyear gt max_apb23 then ri_apb23=0;

		if fyear lt min_apb26 then ri_apb26=0;
		if fyear gt max_apb26 then ri_apb26=0;

		if fyear lt min_apb29 then ri_apb29=0;
		if fyear gt max_apb29 then ri_apb29=0;

		if fyear lt min_apb30 then ri_apb30=0;
		if fyear gt max_apb30 then ri_apb30=0;

		if fyear lt min_arb45 then ri_arb45=0;
		if fyear gt max_arb45 then ri_arb45=0;

		if fyear lt min_arb51 then ri_arb51=0;
		if fyear gt max_arb51 then ri_arb51=0;

		if fyear lt min_arb43_2a then ri_arb43_2a=0;
		if fyear gt max_arb43_2a then ri_arb43_2a=0;

		if fyear lt min_arb43_3a then ri_arb43_3a=0;
		if fyear gt max_arb43_3a then ri_arb43_3a=0;

		if fyear lt min_arb43_3b then ri_arb43_3b=0;
		if fyear gt max_arb43_3b then ri_arb43_3b=0;

		if fyear lt min_arb43_4 then ri_arb43_4=0;
		if fyear gt max_arb43_4 then ri_arb43_4=0;

		if fyear lt min_arb43_7a then ri_arb43_7a=0;
		if fyear gt max_arb43_7a then ri_arb43_7a=0;

		if fyear lt min_arb43_7b then ri_arb43_7b=0;
		if fyear gt max_arb43_7b then ri_arb43_7b=0;

		if fyear lt min_arb43_9a then ri_arb43_9a=0;
		if fyear gt max_arb43_9a then ri_arb43_9a=0;

		if fyear lt min_arb43_9b then ri_arb43_9b=0;
		if fyear gt max_arb43_9b then ri_arb43_9b=0;

		if fyear lt min_arb43_10a then ri_arb43_10a=0;
		if fyear gt max_arb43_10a then ri_arb43_10a=0;

		if fyear lt min_arb43_11a then ri_arb43_11a=0;
		if fyear gt max_arb43_11a then ri_arb43_11a=0;

		if fyear lt min_arb43_11b then ri_arb43_11b=0;
		if fyear gt max_arb43_11b then ri_arb43_11b=0;

		if fyear lt min_arb43_11c then ri_arb43_11c=0;
		if fyear gt max_arb43_11c then ri_arb43_11c=0;

		if fyear lt min_arb43_12 then ri_arb43_12=0;
		if fyear gt max_arb43_12 then ri_arb43_12=0;

		if fyear lt min_con5_6 then ri_con5_6=0;
		if fyear gt max_con5_6 then ri_con5_6=0;

		if fyear lt min_eitf00_21 then ri_eitf00_21=0;
		if fyear gt max_eitf00_21 then ri_eitf00_21=0;

		if fyear lt min_eitf94_3 then ri_eitf94_03=0;
		if fyear gt max_eitf94_3 then ri_eitf94_03=0;

		if fyear lt min_fas2 then ri_fas2=0;
		if fyear gt max_fas2 then ri_fas2=0;

		if fyear lt min_fas5 then ri_fas5=0;
		if fyear gt max_fas5 then ri_fas5=0;

		if fyear lt min_fas7 then ri_fas7=0;
		if fyear gt max_fas7 then ri_fas7=0;

		if fyear lt min_fas13 then ri_fas13=0;
		if fyear gt max_fas13 then ri_fas13=0;

		if fyear lt min_fas15 then ri_fas15=0;
		if fyear gt max_fas15 then ri_fas15=0;

		if fyear lt min_fas16 then ri_fas16=0;
		if fyear gt max_fas16 then ri_fas16=0;

		if fyear lt min_fas19 then ri_fas19=0;
		if fyear gt max_fas19 then ri_fas19=0;

		if fyear lt min_fas34 then ri_fas34=0;
		if fyear gt max_fas34 then ri_fas34=0;

		if fyear lt min_fas35 then ri_fas35=0;
		if fyear gt max_fas35 then ri_fas35=0;

		if fyear lt min_fas43 then ri_fas43=0;
		if fyear gt max_fas43 then ri_fas43=0;

		if fyear lt min_fas45 then ri_fas45=0;
		if fyear gt max_fas45 then ri_fas45=0;

		if fyear lt min_fas47 then ri_fas47=0;
		if fyear gt max_fas47 then ri_fas47=0;

		if fyear lt min_fas48 then ri_fas48=0;
		if fyear gt max_fas48 then ri_fas48=0;

		if fyear lt min_fas49 then ri_fas49=0;
		if fyear gt max_fas49 then ri_fas49=0;

		if fyear lt min_fas50 then ri_fas50=0;
		if fyear gt max_fas50 then ri_fas50=0;

		if fyear lt min_fas51 then ri_fas51=0;
		if fyear gt max_fas51 then ri_fas51=0;

		if fyear lt min_fas52 then ri_fas52=0;
		if fyear gt max_fas52 then ri_fas52=0;

		if fyear lt min_fas53 then ri_fas53=0;
		if fyear gt max_fas53 then ri_fas53=0;

		if fyear lt min_fas57 then ri_fas57=0;
		if fyear gt max_fas57 then ri_fas57=0;

		if fyear lt min_fas60 then ri_fas60=0;
		if fyear gt max_fas60 then ri_fas60=0;

		if fyear lt min_fas61 then ri_fas61=0;
		if fyear gt max_fas61 then ri_fas61=0;

		if fyear lt min_fas63 then ri_fas63=0;
		if fyear gt max_fas63 then ri_fas63=0;

		if fyear lt min_fas65 then ri_fas65=0;
		if fyear gt max_fas65 then ri_fas65=0;

		if fyear lt min_fas66 then ri_fas66=0;
		if fyear gt max_fas66 then ri_fas66=0;

		if fyear lt min_fas67 then ri_fas67=0;
		if fyear gt max_fas67 then ri_fas67=0;

		if fyear lt min_fas68 then ri_fas68=0;
		if fyear gt max_fas68 then ri_fas68=0;

		if fyear lt min_fas71 then ri_fas71=0;
		if fyear gt max_fas71 then ri_fas71=0;

		if fyear lt min_fas77 then ri_fas77=0;
		if fyear gt max_fas77 then ri_fas77=0;

		if fyear lt min_fas80 then ri_fas80=0;
		if fyear gt max_fas80 then ri_fas80=0;

		if fyear lt min_fas86 then ri_fas86=0;
		if fyear gt max_fas86 then ri_fas86=0;

		if fyear lt min_fas87 then ri_fas87=0;
		if fyear gt max_fas87 then ri_fas87=0;

		if fyear lt min_fas88 then ri_fas88=0;
		if fyear gt max_fas88 then ri_fas88=0;

		if fyear lt min_fas97 then ri_fas97=0;
		if fyear gt max_fas97 then ri_fas97=0;

		if fyear lt min_fas101 then ri_fas101=0;
		if fyear gt max_fas101 then ri_fas101=0;

		if fyear lt min_fas105 then ri_fas105=0;
		if fyear gt max_fas105 then ri_fas105=0;

		if fyear lt min_fas106 then ri_fas106=0;
		if fyear gt max_fas106 then ri_fas106=0;

		if fyear lt min_fas107 then ri_fas107=0;
		if fyear gt max_fas107 then ri_fas107=0;

		if fyear lt min_fas109 then ri_fas109=0;
		if fyear gt max_fas109 then ri_fas109=0;

		if fyear lt min_fas113 then ri_fas113=0;
		if fyear gt max_fas113 then ri_fas113=0;

		if fyear lt min_fas115 then ri_fas115=0;
		if fyear gt max_fas115 then ri_fas115=0;

		if fyear lt min_fas119 then ri_fas116=0;
		if fyear gt max_fas119 then ri_fas116=0;

		if fyear lt min_fas121 then ri_fas121=0;
		if fyear gt max_fas121 then ri_fas121=0;

		if fyear lt min_fas123 then ri_fas123=0;
		if fyear gt max_fas123 then ri_fas123=0;

		if fyear lt min_fas123r then ri_fas123r=0;
		if fyear gt max_fas123r then ri_fas123r=0;

		if fyear lt min_fas125 then ri_fas125=0;
		if fyear gt max_fas125 then ri_fas125=0;

		if fyear lt min_fas130 then ri_fas130=0;
		if fyear gt max_fas130 then ri_fas130=0;

		if fyear lt min_fas132 then ri_fas132=0;
		if fyear gt max_fas132 then ri_fas132=0;

		if fyear lt min_fas132r then ri_fas132r=0;
		if fyear gt max_fas132r then ri_fas132r=0;

		if fyear lt min_fas133 then ri_fas133=0;
		if fyear gt max_fas133 then ri_fas133=0;

		if fyear lt min_fas140 then ri_fas140=0;
		if fyear gt max_fas140 then ri_fas140=0;

		if fyear lt min_fas141 then ri_fas141=0;
		if fyear gt max_fas141 then ri_fas141=0;

		if fyear lt min_fas142 then ri_fas142=0;
		if fyear gt max_fas142 then ri_fas142=0;

		if fyear lt min_fas143 then ri_fas143=0;
		if fyear gt max_fas143 then ri_fas143=0;

		if fyear lt min_fas144 then ri_fas144=0;
		if fyear gt max_fas144 then ri_fas144=0;

		if fyear lt min_fas146 then ri_fas146=0;
		if fyear gt max_fas146 then ri_fas146=0;

		if fyear lt min_fas150 then ri_fas150=0;
		if fyear gt max_fas150 then ri_fas150=0;
		if fyear lt min_fas154 then ri_fas154=0;
		if fyear gt max_fas154 then ri_fas154=0;
		if fyear lt min_sab101 then ri_sab101=0;
		if fyear gt max_sab101 then ri_sab101=0;
		if fyear lt min_sop97_2 then ri_sop97_2=0;
		if fyear gt max_sop97_2 then ri_sop97_2=0;
		if fyear lt 2009 then ri_asu2009_17=0;
		if fyear lt 2011 then ri_asu2011_08=0;
		if fyear lt 2012 then ri_asu2012_01=0;
		if fyear lt 2012 then ri_asu2012_02=0;
		run;


		proc sql; create table ds1 as select
		a.*, b.*
		from ps11 as a left join imp1 b
		on a.year=b.year
		order by cik, fyear;
		quit;


		data ds1a; set ds1;
		if ri_apb25 eq . then  ri_apb25=0;    
		if apb25 eq . then  apb25=0; 
		if ri_apb2  eq . then  ri_apb2=0;           
		if apb2 eq . then  apb2=0; 
		if ri_apb4 eq . then  ri_apb4=0;          
		if apb4 eq . then  apb4=0; 
		if ri_apb9 eq . then  ri_apb9=0;          
		if apb9 eq . then  apb9=0; 
		if ri_apb14 eq . then  ri_apb14=0;           
		if apb14 eq . then apb14=0; 
		if ri_apb16 eq . then  ri_apb16=0;          
		if apb16 eq . then apb16=0; 
		if ri_apb17 eq . then  ri_apb17=0;         
		if apb17 eq . then apb17=0; 
		if ri_apb18 eq . then  ri_apb18=0;         
		if apb18 eq . then  apb18=0; 
		if ri_apb20 eq . then  ri_apb20=0;          
		if apb20 eq . then  apb20=0; 
		if ri_apb21 eq . then  ri_apb21=0;          
		if apb21 eq . then  apb21=0; 
		if ri_apb23 eq . then  ri_apb23=0;          
		if apb23 eq . then  apb23=0; 
		if ri_apb26 eq . then  ri_apb26=0;          
		if apb26 eq . then  apb26=0; 
		if ri_apb29 eq . then  ri_apb29=0;          
		if apb29 eq . then  apb29=0; 
		if ri_apb30 eq . then  ri_apb30=0;          
		if apb30 eq . then  apb30=0; 
		if ri_arb45 eq .  then ri_arb45=0;        
		if arb45  eq . then arb45=0;
		if ri_arb51  eq . then ri_arb51=0;
		if arb51  eq . then arb51=0;
		if ri_arb43_2a  eq . then ri_arb43_2a=0;        
		if arb43_2a eq . then arb43_2a=0;    
		if ri_arb43_3a eq . then ri_arb43_3a=0;              
		if arb43_3a  eq . then arb43_3a=0;  
		if ri_arb43_3b eq . then ri_arb43_3b=0;            
		if arb43_3b  eq . then arb43_3b=0;  
		if ri_arb43_4  eq . then ri_arb43_4=0;           
		if arb43_4  eq . then arb43_4=0;  
		if ri_arb43_7a eq . then ri_arb43_7a=0;           
		if arb43_7a  eq . then arb43_7a=0;  
		if ri_arb43_7b eq . then ri_arb43_7b=0;            
		if arb43_7b  eq . then arb43_7b=0;  
		if ri_arb43_9a eq . then ri_arb43_9a=0;            
		if arb43_9a  eq . then arb43_9a=0;  
		if ri_arb43_9b eq . then ri_arb43_9b=0;            
		if arb43_9b  eq . then arb43_9b=0;  
		if ri_arb43_10a  eq . then ri_arb43_10a=0;           
		if arb43_10a  eq . then arb43_10a=0;  
		if ri_arb43_11a  eq . then ri_arb43_11a=0;            
		if arb43_11a  eq . then arb43_11a=0;  
		if ri_arb43_11b  eq . then ri_arb43_11b=0;           
		if arb43_11b  eq . then arb43_11b=0;  
		if ri_arb43_11c  eq . then ri_arb43_11c=0;          
		if arb43_11c  eq . then arb43_11c=0;  
		if ri_arb43_12   eq . then ri_arb43_12=0;          
		if arb43_12  eq . then arb43_12=0;  
		if ri_con5_6     eq . then ri_con5_6=0;       
		if con5_6  eq . then con5_6=0;  
		if ri_eitf00_21  eq . then ri_eitf00_21=0;           
		if abs00_21  eq . then abs00_21=0;  
		if ri_eitf94_03  eq . then ri_eitf94_03=0;           
		if abs94_03  eq . then abs94_03=0;  
		if ri_fas2       eq . then ri_fas2=0;      
		if fas2  eq . then fas2=0;  
		if ri_fas5       eq . then ri_fas5=0;      
		if fas5  eq . then fas5=0;  
		if ri_fas7       eq . then ri_fas7=0;      
		if fas7  eq . then fas7=0;  
		if ri_fas13      eq . then ri_fas13=0;       
		if fas13  eq . then fas13=0;  
		if ri_fas15      eq . then ri_fas15=0;       
		if fas15  eq . then fas15=0;  
		if ri_fas16      eq . then ri_fas16=0;      
		if fas16  eq . then fas16=0;  
		if ri_fas19      eq . then ri_fas19=0;       
		if  fas19  eq . then fas19=0;  
		if ri_fas34      eq . then ri_fas34=0;      
		if fas34  eq . then fas34=0;  
		if ri_fas35      eq . then ri_fas35=0;      
		if fas35  eq . then fas35=0;  
		if ri_fas43      eq . then ri_fas43=0;       
		if fas43  eq . then fas43=0;  
		if ri_fas45      eq . then ri_fas45=0;      
		if fas45  eq . then fas45=0;  
		if ri_fas47      eq . then ri_fas47=0;       
		if fas47  eq . then fas47=0;  
		if ri_fas48      eq . then ri_fas48=0;      
		if fas48  eq . then fas48=0;  
		if ri_fas49      eq . then ri_fas49=0;      
		if fas49  eq . then fas49=0;  
		if ri_fas50      eq . then ri_fas50=0;      
		if fas50  eq . then fas50=0;  
		if ri_fas51      eq . then ri_fas51=0;      
		if fas51  eq . then fas51=0;  
		if ri_fas52      eq . then ri_fas52=0;      
		if fas52  eq . then fas52=0;  
		if ri_fas53      eq . then ri_fas53=0;       
		if fas53  eq . then fas53=0;  
		if ri_fas57      eq . then ri_fas57=0;      
		if fas57  eq . then fas57=0;  
		if ri_fas60      eq . then ri_fas60=0;      
		if fas60  eq . then fas60=0;  
		if ri_fas61      eq . then ri_fas61=0;       
		if fas61  eq . then fas61=0;  
		if ri_fas63      eq . then ri_fas63=0;       
		if fas63  eq . then fas63=0;  
		if ri_fas65      eq . then ri_fas65=0;       
		if fas65  eq . then fas65=0;  
		if ri_fas66      eq . then ri_fas66=0;       
		if fas66  eq . then fas66=0;  
		if ri_fas67      eq . then ri_fas67=0;       
		if fas67  eq . then fas67=0;  
		if ri_fas68      eq . then ri_fas68=0;       
		if fas68  eq . then fas68=0;  
		if ri_fas71      eq . then ri_fas71=0;       
		if fas71  eq . then fas71=0;  
		if ri_fas77      eq . then ri_fas77=0;       
		if fas77  eq . then fas77=0;  
		if ri_fas80      eq . then ri_fas80=0;       
		if fas80  eq . then fas80=0;  
		if ri_fas86      eq . then ri_fas86=0;       
		if fas86  eq . then fas86=0;  
		if ri_fas87      eq . then ri_fas87=0;       
		if fas87  eq . then fas87=0;  
		if ri_fas88      eq . then ri_fas88=0;      
		if fas88  eq . then fas88=0;  
		if ri_fas97      eq . then ri_fas97=0;       
		if fas97  eq . then fas97=0;  
		if ri_fas101     eq . then ri_fas101=0;        
		if fas101  eq . then fas101=0;  
		if ri_fas105     eq . then ri_fas105=0;        
		if fas105  eq . then fas105=0;  
		if ri_fas106     eq . then ri_fas106=0;        
		if fas106  eq . then fas106=0;  
		if ri_fas107     eq . then ri_fas107=0;        
		if fas107  eq . then fas107=0;  
		if ri_fas109     eq . then ri_fas109=0;        
		if fas109  eq . then fas109=0;  
		if ri_fas113     eq . then ri_fas113=0;        
		if fas113  eq . then fas113=0;  
		if ri_fas115     eq . then ri_fas115=0;        
		if fas115  eq . then fas115=0;  
		if ri_fas116     eq . then ri_fas116=0;        
		if fas116  eq . then fas116=0;  
		if ri_fas119     eq . then ri_fas119=0;        
		if fas119  eq . then fas119=0;  
		if ri_fas121     eq . then ri_fas121=0;        
		if fas121  eq . then fas121=0;  
		if ri_fas123     eq . then ri_fas123=0;       
		if fas123  eq . then fas123=0;  
		if ri_fas123r    eq . then ri_fas123r=0;       
		if fas123r  eq . then fas123r=0;  
		if ri_fas125     eq . then ri_fas125=0;        
		if fas125  eq . then fas125=0;  
		if ri_fas130     eq . then ri_fas130=0;        
		if fas130  eq . then fas130=0;  
		if ri_fas132     eq . then ri_fas132=0;        
		if fas132  eq . then fas132=0;  
		if ri_fas132r    eq . then ri_fas132r=0;        
		if fas132r  eq . then fas132r=0;  
		if ri_fas133     eq . then ri_fas133=0;       
		if fas133  eq . then fas133=0;  
		if ri_fas140     eq . then ri_fas140=0;        
		if fas140  eq . then fas140=0;  
		if ri_fas141     eq . then ri_fas141=0;       
		if fas141  eq . then fas141=0;  
		if ri_fas142     eq . then ri_fas142=0;       
		if fas142  eq . then fas142=0;  
		if ri_fas143     eq . then ri_fas143=0;       
		if fas143  eq . then fas143=0;  
		if ri_fas144     eq . then ri_fas144=0;       
		if fas144  eq . then fas144=0;  
		if ri_fas146     eq . then ri_fas146=0;       
		if fas146  eq . then fas146=0;  
		if ri_fas150     eq . then ri_fas150=0;       
		if fas150  eq . then fas150=0;  
		if ri_fas154     eq . then ri_fas154=0;       
		if fas154  eq . then fas154=0;  
		if ri_sab101 eq . then ri_sab101=0;  
		if sab101  eq . then sab101=0;  
		if ri_sop97_2 eq . then ri_sop97_2=0;  
		if sop97_2  eq . then sop97_2=0;  
		run;


		data ds2; set ds1a;
		Dscore=-1*(ri_apb25*apb25+
		ri_apb2*apb2+
		ri_apb4*apb4+
		ri_apb9*apb9+
		ri_apb14*apb14+
		ri_apb16*apb16+
		ri_apb17*apb17+
		ri_apb18*apb18+
		ri_apb20*apb20+
		ri_apb21*apb21+
		ri_apb23*apb23+
		ri_apb26*apb26+
		ri_apb29*apb29+
		ri_apb30*apb30+
		ri_arb45*arb45+
		ri_arb51*arb51+
		ri_arb43_2a*arb43_2a+
		ri_arb43_3a*arb43_3a+
		ri_arb43_3b*arb43_3b+
		ri_arb43_4*arb43_4+
		ri_arb43_7a*arb43_7a+
		ri_arb43_7b*arb43_7b+
		ri_arb43_9a*arb43_9a+
		ri_arb43_9b*arb43_9b+
		ri_arb43_10a*arb43_10a+
		ri_arb43_11a*arb43_11a+
		ri_arb43_11b*arb43_11b+
		ri_arb43_11c*arb43_11c+
		ri_arb43_12*arb43_12+
		ri_con5_6*con5_6+
		ri_eitf00_21*abs00_21+
		ri_eitf94_03*abs94_03+
		ri_fas2*fas2+
		ri_fas5*fas5+
		ri_fas7*fas7+
		ri_fas13*fas13+
		ri_fas15*fas15+
		ri_fas16*fas16+
		ri_fas19*fas19+
		ri_fas34*fas34+
		ri_fas35*fas35+
		ri_fas43*fas43+
		ri_fas45*fas45+
		ri_fas47*fas47+
		ri_fas48*fas48+
		ri_fas49*fas49+
		ri_fas50*fas50+
		ri_fas51*fas51+
		ri_fas52*fas52+
		ri_fas53*fas53+
		ri_fas57*fas57+
		ri_fas60*fas60+
		ri_fas61*fas61+
		ri_fas63*fas63+
		ri_fas65*fas65+
		ri_fas66*fas66+
		ri_fas67*fas67+
		ri_fas68*fas68+
		ri_fas71*fas71+
		ri_fas77*fas77+
		ri_fas80*fas80+
		ri_fas86*fas86+
		ri_fas87*fas87+
		ri_fas88*fas88+
		ri_fas97*fas97+
		ri_fas101*fas101+
		ri_fas105*fas105+
		ri_fas106*fas106+
		ri_fas107*fas107+
		ri_fas109*fas109+
		ri_fas113*fas113+
		ri_fas115*fas115+
		ri_fas116*fas116+
		ri_fas119*fas119+
		ri_fas121*fas121+
		ri_fas123*fas123+
		ri_fas123r*fas123r+
		ri_fas125*fas125+
		ri_fas130*fas130+
		ri_fas132*fas132+
		ri_fas132r*fas132r+
		ri_fas133*fas133+
		ri_fas140*fas140+
		ri_fas141*fas141+
		ri_fas142*fas142+
		ri_fas143*fas143+
		ri_fas144*fas144+
		ri_fas146*fas146+
		ri_fas150*fas150+
		ri_fas154*fas154+
		ri_sab101*sab101+
		ri_sop97_2*sop97_2);
		run;

		data dperm.dscore_orthrbc_rr1az; set ds2;
		run;

		data dperm.dscore_limited_orthrbc_rr1az; set ds2;
		keep cik datadate fyear permno gvkey year dscore;
		run;




	/*END:g. Create alternative measure orthogonalized to RBC*/
	/*BEGIN:h. Create number of standards*/

		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/


		data ps8; set dperm.rel_imp;run;




		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
		dbms=xlsx OUT = mdataa;run;


		data ps9; set ps8;
		if fyear ne . then year=fyear;
		if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then year=year(datadate);
		run;

		data mdata3; set mdataa;
		id=1;
		if min_apb2 ne .;
		drop ko kp;
		run;
		data ps9; set ps9;
		id=1;
		run;

		proc sql; create table ps10 as select
		a.*, b.*
		from ps9 as a left join mdata3 b
		on a.id=b.id
		order by cik, fyear;
		quit;

		data ps11 ; set ps10;
		if fyear lt min_apb25 then ri_apb25=0;
		if fyear gt max_apb25 then ri_apb25=0;

		if fyear lt min_apb4 then ri_apb4=0;
		if fyear gt max_apb4 then ri_apb4=0;

		if fyear lt min_apb9 then ri_apb9=0;
		if fyear gt max_apb9 then ri_apb9=0;

		if fyear lt min_apb14 then ri_apb14=0;
		if fyear gt max_apb14 then ri_apb14=0;

		if fyear lt min_apb16 then ri_apb16=0;
		if fyear gt max_apb16 then ri_apb16=0;

		if fyear lt min_apb17 then ri_apb17=0;
		if fyear gt max_apb17 then ri_apb17=0;

		if fyear lt min_apb18 then ri_apb18=0;
		if fyear gt max_apb18 then ri_apb18=0;

		if fyear lt min_apb20 then ri_apb20=0;
		if fyear gt max_apb20 then ri_apb20=0;

		if fyear lt min_apb21 then ri_apb21=0;
		if fyear gt max_apb21 then ri_apb21=0;

		if fyear lt min_apb23 then ri_apb23=0;
		if fyear gt max_apb23 then ri_apb23=0;

		if fyear lt min_apb26 then ri_apb26=0;
		if fyear gt max_apb26 then ri_apb26=0;

		if fyear lt min_apb29 then ri_apb29=0;
		if fyear gt max_apb29 then ri_apb29=0;

		if fyear lt min_apb30 then ri_apb30=0;
		if fyear gt max_apb30 then ri_apb30=0;

		if fyear lt min_arb45 then ri_arb45=0;
		if fyear gt max_arb45 then ri_arb45=0;

		if fyear lt min_arb51 then ri_arb51=0;
		if fyear gt max_arb51 then ri_arb51=0;

		if fyear lt min_arb43_2a then ri_arb43_2a=0;
		if fyear gt max_arb43_2a then ri_arb43_2a=0;

		if fyear lt min_arb43_3a then ri_arb43_3a=0;
		if fyear gt max_arb43_3a then ri_arb43_3a=0;

		if fyear lt min_arb43_3b then ri_arb43_3b=0;
		if fyear gt max_arb43_3b then ri_arb43_3b=0;

		if fyear lt min_arb43_4 then ri_arb43_4=0;
		if fyear gt max_arb43_4 then ri_arb43_4=0;

		if fyear lt min_arb43_7a then ri_arb43_7a=0;
		if fyear gt max_arb43_7a then ri_arb43_7a=0;

		if fyear lt min_arb43_7b then ri_arb43_7b=0;
		if fyear gt max_arb43_7b then ri_arb43_7b=0;

		if fyear lt min_arb43_9a then ri_arb43_9a=0;
		if fyear gt max_arb43_9a then ri_arb43_9a=0;

		if fyear lt min_arb43_9b then ri_arb43_9b=0;
		if fyear gt max_arb43_9b then ri_arb43_9b=0;

		if fyear lt min_arb43_10a then ri_arb43_10a=0;
		if fyear gt max_arb43_10a then ri_arb43_10a=0;

		if fyear lt min_arb43_11a then ri_arb43_11a=0;
		if fyear gt max_arb43_11a then ri_arb43_11a=0;

		if fyear lt min_arb43_11b then ri_arb43_11b=0;
		if fyear gt max_arb43_11b then ri_arb43_11b=0;

		if fyear lt min_arb43_11c then ri_arb43_11c=0;
		if fyear gt max_arb43_11c then ri_arb43_11c=0;

		if fyear lt min_arb43_12 then ri_arb43_12=0;
		if fyear gt max_arb43_12 then ri_arb43_12=0;

		if fyear lt min_con5_6 then ri_con5_6=0;
		if fyear gt max_con5_6 then ri_con5_6=0;

		if fyear lt min_eitf00_21 then ri_eitf00_21=0;
		if fyear gt max_eitf00_21 then ri_eitf00_21=0;

		if fyear lt min_eitf94_3 then ri_eitf94_03=0;
		if fyear gt max_eitf94_3 then ri_eitf94_03=0;

		if fyear lt min_fas2 then ri_fas2=0;
		if fyear gt max_fas2 then ri_fas2=0;

		if fyear lt min_fas5 then ri_fas5=0;
		if fyear gt max_fas5 then ri_fas5=0;

		if fyear lt min_fas7 then ri_fas7=0;
		if fyear gt max_fas7 then ri_fas7=0;

		if fyear lt min_fas13 then ri_fas13=0;
		if fyear gt max_fas13 then ri_fas13=0;

		if fyear lt min_fas15 then ri_fas15=0;
		if fyear gt max_fas15 then ri_fas15=0;

		if fyear lt min_fas16 then ri_fas16=0;
		if fyear gt max_fas16 then ri_fas16=0;

		if fyear lt min_fas19 then ri_fas19=0;
		if fyear gt max_fas19 then ri_fas19=0;

		if fyear lt min_fas34 then ri_fas34=0;
		if fyear gt max_fas34 then ri_fas34=0;

		if fyear lt min_fas35 then ri_fas35=0;
		if fyear gt max_fas35 then ri_fas35=0;

		if fyear lt min_fas43 then ri_fas43=0;
		if fyear gt max_fas43 then ri_fas43=0;

		if fyear lt min_fas45 then ri_fas45=0;
		if fyear gt max_fas45 then ri_fas45=0;

		if fyear lt min_fas47 then ri_fas47=0;
		if fyear gt max_fas47 then ri_fas47=0;

		if fyear lt min_fas48 then ri_fas48=0;
		if fyear gt max_fas48 then ri_fas48=0;

		if fyear lt min_fas49 then ri_fas49=0;
		if fyear gt max_fas49 then ri_fas49=0;

		if fyear lt min_fas50 then ri_fas50=0;
		if fyear gt max_fas50 then ri_fas50=0;

		if fyear lt min_fas51 then ri_fas51=0;
		if fyear gt max_fas51 then ri_fas51=0;

		if fyear lt min_fas52 then ri_fas52=0;
		if fyear gt max_fas52 then ri_fas52=0;

		if fyear lt min_fas53 then ri_fas53=0;
		if fyear gt max_fas53 then ri_fas53=0;

		if fyear lt min_fas57 then ri_fas57=0;
		if fyear gt max_fas57 then ri_fas57=0;

		if fyear lt min_fas60 then ri_fas60=0;
		if fyear gt max_fas60 then ri_fas60=0;

		if fyear lt min_fas61 then ri_fas61=0;
		if fyear gt max_fas61 then ri_fas61=0;

		if fyear lt min_fas63 then ri_fas63=0;
		if fyear gt max_fas63 then ri_fas63=0;

		if fyear lt min_fas65 then ri_fas65=0;
		if fyear gt max_fas65 then ri_fas65=0;

		if fyear lt min_fas66 then ri_fas66=0;
		if fyear gt max_fas66 then ri_fas66=0;

		if fyear lt min_fas67 then ri_fas67=0;
		if fyear gt max_fas67 then ri_fas67=0;

		if fyear lt min_fas68 then ri_fas68=0;
		if fyear gt max_fas68 then ri_fas68=0;

		if fyear lt min_fas71 then ri_fas71=0;
		if fyear gt max_fas71 then ri_fas71=0;

		if fyear lt min_fas77 then ri_fas77=0;
		if fyear gt max_fas77 then ri_fas77=0;

		if fyear lt min_fas80 then ri_fas80=0;
		if fyear gt max_fas80 then ri_fas80=0;

		if fyear lt min_fas86 then ri_fas86=0;
		if fyear gt max_fas86 then ri_fas86=0;

		if fyear lt min_fas87 then ri_fas87=0;
		if fyear gt max_fas87 then ri_fas87=0;

		if fyear lt min_fas88 then ri_fas88=0;
		if fyear gt max_fas88 then ri_fas88=0;

		if fyear lt min_fas97 then ri_fas97=0;
		if fyear gt max_fas97 then ri_fas97=0;

		if fyear lt min_fas101 then ri_fas101=0;
		if fyear gt max_fas101 then ri_fas101=0;

		if fyear lt min_fas105 then ri_fas105=0;
		if fyear gt max_fas105 then ri_fas105=0;

		if fyear lt min_fas106 then ri_fas106=0;
		if fyear gt max_fas106 then ri_fas106=0;

		if fyear lt min_fas107 then ri_fas107=0;
		if fyear gt max_fas107 then ri_fas107=0;

		if fyear lt min_fas109 then ri_fas109=0;
		if fyear gt max_fas109 then ri_fas109=0;

		if fyear lt min_fas113 then ri_fas113=0;
		if fyear gt max_fas113 then ri_fas113=0;

		if fyear lt min_fas115 then ri_fas115=0;
		if fyear gt max_fas115 then ri_fas115=0;

		if fyear lt min_fas119 then ri_fas116=0;
		if fyear gt max_fas119 then ri_fas116=0;

		if fyear lt min_fas121 then ri_fas121=0;
		if fyear gt max_fas121 then ri_fas121=0;

		if fyear lt min_fas123 then ri_fas123=0;
		if fyear gt max_fas123 then ri_fas123=0;

		if fyear lt min_fas123r then ri_fas123r=0;
		if fyear gt max_fas123r then ri_fas123r=0;

		if fyear lt min_fas125 then ri_fas125=0;
		if fyear gt max_fas125 then ri_fas125=0;

		if fyear lt min_fas130 then ri_fas130=0;
		if fyear gt max_fas130 then ri_fas130=0;

		if fyear lt min_fas132 then ri_fas132=0;
		if fyear gt max_fas132 then ri_fas132=0;

		if fyear lt min_fas132r then ri_fas132r=0;
		if fyear gt max_fas132r then ri_fas132r=0;

		if fyear lt min_fas133 then ri_fas133=0;
		if fyear gt max_fas133 then ri_fas133=0;

		if fyear lt min_fas140 then ri_fas140=0;
		if fyear gt max_fas140 then ri_fas140=0;

		if fyear lt min_fas141 then ri_fas141=0;
		if fyear gt max_fas141 then ri_fas141=0;

		if fyear lt min_fas142 then ri_fas142=0;
		if fyear gt max_fas142 then ri_fas142=0;

		if fyear lt min_fas143 then ri_fas143=0;
		if fyear gt max_fas143 then ri_fas143=0;

		if fyear lt min_fas144 then ri_fas144=0;
		if fyear gt max_fas144 then ri_fas144=0;

		if fyear lt min_fas146 then ri_fas146=0;
		if fyear gt max_fas146 then ri_fas146=0;

		if fyear lt min_fas150 then ri_fas150=0;
		if fyear gt max_fas150 then ri_fas150=0;
		if fyear lt min_fas154 then ri_fas154=0;
		if fyear gt max_fas154 then ri_fas154=0;
		if fyear lt min_sab101 then ri_sab101=0;
		if fyear gt max_sab101 then ri_sab101=0;
		if fyear lt min_sop97_2 then ri_sop97_2=0;
		if fyear gt max_sop97_2 then ri_sop97_2=0;
		if fyear lt 2009 then ri_asu2009_17=0;
		if fyear lt 2011 then ri_asu2011_08=0;
		if fyear lt 2012 then ri_asu2012_01=0;
		if fyear lt 2012 then ri_asu2012_02=0;
		run;

		data ps12; set ps11;
		if ri_apb25  gt 0 then var1=1;
		if ri_apb4 gt 0 then var2=1;
		if ri_apb9 gt 0 then var3=1;
		if ri_apb14 gt 0 then var4=1;
		if ri_apb16 gt 0 then var5=1;
		if ri_apb17 gt 0 then var6=1;
		if ri_apb18 gt 0 then var7=1;
		if ri_apb20 gt 0 then var8=1;
		if ri_apb21 gt 0 then var9=1;
		if ri_apb23 gt 0 then var10=1;
		if ri_apb26 gt 0 then var11=1;
		if ri_apb29 gt 0 then var12=1;
		if ri_apb30 gt 0 then var13=1;
		if ri_arb45 gt 0 then var14=1;
		if ri_arb51 gt 0 then var15=1;
		if ri_arb43_2a gt 0 then var16=1;
		if ri_arb43_3a gt 0 then var17=1;
		if ri_arb43_3b gt 0 then var18=1;
		if ri_arb43_4 gt 0 then var19=1;
		if ri_arb43_7a gt 0 then var20=1;
		if ri_arb43_7b gt 0 then var21=1;
		if ri_arb43_9a gt 0 then var22=1;
		if ri_arb43_9b gt 0 then var23=1;
		if ri_arb43_10a gt 0 then var24=1;
		if ri_arb43_11a gt 0 then var25=1;
		if ri_arb43_11b gt 0 then var26=1;
		if ri_arb43_11c gt 0 then var27=1;
		if ri_arb43_12 gt 0 then var28=1;
		if ri_con5_6 gt 0 then var29=1;
		if ri_eitf00_21 gt 0 then var30=1;
		if ri_eitf94_03 gt 0 then var31=1;
		if ri_fas2 gt 0 then var32=1;
		if ri_fas5 gt 0 then var33=1;
		if ri_fas7 gt 0 then var34=1;
		if ri_fas13 gt 0 then var35=1;
		if ri_fas15 gt 0 then var36=1;
		if ri_fas16 gt 0 then var37=1;
		if ri_fas19 gt 0 then var38=1;
		if ri_fas34 gt 0 then var39=1;
		if ri_fas35 gt 0 then var40=1;
		if ri_fas43 gt 0 then var41=1;
		if ri_fas45 gt 0 then var42=1;
		if ri_fas47 gt 0 then var43=1;
		if ri_fas48 gt 0 then var44=1;
		if ri_fas49 gt 0 then var45=1;
		if ri_fas50 gt 0 then var46=1;
		if ri_fas51 gt 0 then var47=1;
		if ri_fas52 gt 0 then var48=1;
		if ri_fas53 gt 0 then var49=1;
		if ri_fas57 gt 0 then var50=1;
		if ri_fas60 gt 0 then var51=1;
		if ri_fas61 gt 0 then var52=1;
		if ri_fas63 gt 0 then var53=1;
		if ri_fas65 gt 0 then var54=1;
		if ri_fas66 gt 0 then var55=1;
		if ri_fas67 gt 0 then var56=1;
		if ri_fas68 gt 0 then var57=1;
		if ri_fas71 gt 0 then var58=1;
		if ri_fas77 gt 0 then var59=1;
		if ri_fas80 gt 0 then var60=1;
		if ri_fas86 gt 0 then var61=1;
		if ri_fas87 gt 0 then var62=1;
		if ri_fas88 gt 0 then var63=1;
		if ri_fas97 gt 0 then var64=1;
		if ri_fas101 gt 0 then var65=1;
		if ri_fas105 gt 0 then var66=1;
		if ri_fas106 gt 0 then var67=1;
		if ri_fas107 gt 0 then var68=1;
		if ri_fas109 gt 0 then var69=1;
		if ri_fas113 gt 0 then var70=1;
		if ri_fas115 gt 0 then var71=1;
		if ri_fas116 gt 0 then var72=1;
		if ri_fas121 gt 0 then var73=1;
		if ri_fas123 gt 0 then var74=1;
		if ri_fas123r gt 0 then var75=1;
		if ri_fas125 gt 0 then var76=1;
		if ri_fas130 gt 0 then var77=1;
		if ri_fas132 gt 0 then var78=1;
		if ri_fas132r gt 0 then var79=1;
		if ri_fas133 gt 0 then var80=1;
		if ri_fas140 gt 0 then var81=1;
		if ri_fas141 gt 0 then var82=1;
		if ri_fas142 gt 0 then var83=1;
		if ri_fas143 gt 0 then var84=1;
		if ri_fas144 gt 0 then var85=1;
		if ri_fas146 gt 0 then var86=1;
		if ri_fas150 gt 0 then var87=1;
		if ri_fas154 gt 0 then var88=1;
		if ri_sab101 gt 0 then var89=1;
		if ri_sop97_2 gt 0 then var90=1;
		if ri_asu2009_17 gt 0 then ar91=1;
		if ri_asu2011_08 gt 0 then ar92=1;
		if ri_asu2012_01 gt 0 then ar93=1;
		if ri_asu2012_02 gt 0 then ar94=1;
		run;

		data ps13; set ps12;
		n_stand=sum(of var:);
		if n_stand=. then n_stand=0;
		run;

		data dperm.n_stand; set ps13;
		keep cik file_date f_ftype datadate gvkey permno fyear n_stand;
		run;

	/*END:h. Create number of standards*/
	/*BEGIN:i. Create shall21rraz*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/


		data ps8; set dperm.rel_imp;run;

		/*below code brings in the count of shall,should must */

		/*brings in raw word counts...This brings in the word counts
		from standards but not ASUS*/
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\modal_words.xlsx'
		DBMS = xlsx OUT = mwords;run;

		data dperm.words1; set mwords;run;
		data words; set dperm.words1;
		drop sentence n o p q r s t u v w;
		run;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
		DBMS = xlsx OUT = rbc;run;
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
		DBMS = xlsx OUT = rbc2;run;



		/*rbc2 contains which standards are effective in which years some of the 
		iteration variables are whole numbers and some are decimals. i.e. iteration 1 is 
		sometimes represented as 1 and sometimes represented as .1 so I altered them to all be
		whole numbers*/




		data rbc2; set rbc2;
		iter=iteration;
		if iteration =: '0.' then iter=iteration*10;
		if iteration =: '0.91' then iter=iteration*100;
		if iteration =: '0.92' then iter=iteration*100;
		if iteration =: '0.93' then iter=iteration*100;
		if iteration =: '0.94' then iter=iteration*100;
		if iteration =: '.94' then iter=iteration*100;
		if iteration =: '0.95' then iter=iteration*100;
		if iteration =: '0.96' then iter=iteration*100;
		if iteration =: '0.15' then iter=iteration*100;
		if iteration =: '0.11' then iter=iteration*100;
		if iteration =: '0.12' then iter=iteration*100;
		if iteration =: '0.13' then iter=iteration*100;
		if iteration =: '0.14' then iter=iteration*100;
		if iteration =: '0.16' then iter=iteration*100;
		if iteration =: '0.17' then iter=iteration*100;
		if iteration =: '0.18' then iter=iteration*100;
		if iteration =: '0.19' then iter=iteration*100;
		orgx=compress(cat(org,std_num));
		if org='apb' and std_num='15' and year=1996 then matchv=1;
		run;

		data rbc1; set rbc;
		yeary=year*1;
		if standard='apb15' and year=1997 then yeary=1996;
		if standard='arb43_11b' and year ge 2006 then yeary=2005;
		run;

		proc sql; create table rbc3 as select
		a.*, b.*
		from rbc2 as a left join rbc1 b
		on b.standard=a.orgx and a.year=b.yeary
		order by org, std_num,year, iteration;
		quit;


		/*data test; set rbc2;
		keep org iter iteration std_num;
		run;


		proc sort data=test out=test2 nodupkey; by iter;run;*/

		/*we only want to keep the word counts for a subset of words*/

		proc sort data=words out=words1 nodupkey; by filename org stddev stditr word;run;


		data shall; set words1;
		where word in ('shall','must','should');
		run;

		proc sql; create table shall1 as select distinct
		filename, org,stddev,stditr,
						sum(wordcount) as rest_words

		from shall group by filename,org,stddev,stditr
		order by filename,org,stddev,stditr;
		quit;



		proc sort data=shall1 out=shall2 nodupkey; by filename ;run;

		/*but we need to put zeroes in for those standards that never
		used the word shall...I put them back in below*/

		proc sort data=words out=words2 nodupkey; by filename;run;

		data shall2a; set shall2 words2;
		run;

		proc sort data=shall2a out=shall3; by filename descending rest_words ;run;
		proc sort data=shall3 out=shall4 nodupkey; by filename  ;run;

		data shall5; set shall4;
		if rest_words eq . then rest_words=0;
		org1=lowcase(org);
		if org="SAB" and stddev="01A" then stddev="101A";
		if org="SAB" and stddev="01B" then stddev="101B";
		std_num=lowcase(stddev);
		stditr1=stditr/1;
		run;

		data rbc3a; set rbc3;
		iter1=iter/1;
		run;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\link_int_guidance.xlsx'
		DBMS = xlsx OUT = iglink;run;

		/*the names of files are not perfectly ready to match with the implementation 
		guidance So I alter them slightly*/

		data shall5a; set shall5;
		if org eq 'apb' then link1='apb';
		if org eq 'apb' and stddev =: '_' then link2=substr(stddev,2,length(stddev)-1);
		if org eq 'APB' then link1='apb';
		if org eq 'APB' and stddev =: '_' then link2=substr(stddev,2,length(stddev)-1);
		if org eq 'apb' and link2 eq '' then link2=stddev;
		if org eq 'APB' and link2 eq '' then link2=stddev;
		if org eq 'FAS' then link1='fas';
		if org eq 'FAS' then link2=stddev;
		if org eq 'fas' then link1='fas';
		if org eq 'fas' then link2=stddev;
		if org eq 'ARB' then link1='arb';
		if org eq 'ARB' then link2=stddev;
		if org eq 'arb' then link1='arb';
		if org eq 'arb' then link2=stddev;
		if org eq 'ARB' and stddev =: '_' then link2=substr(stddev,2,length(stddev)-1);
		if org eq 'SAB' then link1='sab';
		if org eq 'SAB' then link2=lowcase(stddev);
		if org eq 'sab' then link1='sab';
		if org eq 'sab' then link2=lowcase(stddev);
		iglink=cat(link1,link2);
		run;



		proc sql; create table shall5b as select
		a.*, b.year1, b.ig
		from shall5a as a left join iglink b
		on a.iglink=b.glink1
		order by org, std_num, stditr;
		quit;

		data iglink1; set iglink;
		if glink2 ne "";
		run;

		proc sql; create table shall5c as select
		a.*, b.year1, b.ig
		from shall5a as a left join iglink1 b
		on a.iglink=b.glink2
		order by org, std_num, stditr;
		quit;

		data iglink2; set iglink;
		if glink3 ne "";
		run;

		proc sql; create table shall5d as select
		a.*, b.year1, b.ig
		from shall5a as a left join iglink2 b
		on a.iglink=b.glink3
		order by org, std_num, stditr;
		quit;

		data shall6; set shall5b shall5c shall5d;run;



		data shall7; set shall6;
		xlink2="                               ";
		if org='abs' and stddev='94-03' then stddev='94-3';
		if org='abs' and stddev='96-08' then stddev='96-8';
		if filename =: 'ain_apb' then xlink1='ain_apb';
		if filename =: 'AIN_APB' then xlink1='ain_apb';
		if filename =: 'ain_apb26'  then xlink2='26';
		if filename =: 'ain_apb18' then xlink2='18';
		if filename =: 'AIN_APB26' then xlink2='26';
		if filename =: 'AIN_APB18'  then xlink2='18';
		if filename =: 'ain_apb23' then xlink2='23';
		if filename =: 'AIN_APB23' then xlink2='23';
		if filename =: 'ain_apb7' then xlink2='7';
		if filename =: 'AIN_APB7' then xlink2='7';
		if filename =: 'ain-apb17' then xlink2='17';
		if filename =: 'AIN-APB17' then xlink2='17';
		if filename =: 'ain-apb' then xlink1='ain_apb';
		if filename =: 'AIN-APB' then xlink1='ain_apb';
		if filename =: 'ain_apb8' then xlink2='8';
		if filename =: 'AIN_APB8' then xlink2='8';
		if filename =: 'ain_apb9' then xlink2='9';
		if filename =: 'AIN_APB9' then xlink2='9';
		if filename =: 'ain_apb22' then xlink2='22';
		if filename =: 'AIN_APB22' then xlink2='22';
		if filename =: 'ain_apb16' then xlink2='16';
		if filename =: 'AIN_APB16' then xlink2='16';
		if filename =: 'ain_apb25' then xlink2='25';
		if filename =: 'AIN_APB25' then xlink2='25';
		if filename =: 'ain_apb30' then xlink2='30';
		if filename =: 'AIN_APB30' then xlink2='30';

		if filename =: 'ain_apb4' then xlink2='4';
		if filename =: 'AIN_APB4' then xlink2='4';

		if filename =: 'ain_apb19' then xlink2='19';
		if filename =: 'AIN_APB19' then xlink2='19';

		if filename =: 'ain_apb21' then xlink2='21';
		if filename =: 'AIN_APB21' then xlink2='21';

		if filename =: 'ain_apb11' then xlink2='11';
		if filename =: 'AIN_APB11' then xlink2='11';

		if filename =: 'ain_apb78' then xlink2='78';
		if filename =: 'AIN_APB78' then xlink2='78';
		if filename =: 'ain_apb15' then xlink2='15';
		if filename =: 'AIN_APB15' then xlink2='15';
		if filename =: 'ain_arb51' then xlink2='51';
		if filename =: 'AIN_ARB51' then xlink2='51';
		if filename =: 'ain_arb' then xlink1='ain_arb';
		if filename =: 'AIN_ARB' then xlink1='ain_arb';
		if org eq 'EITF' then xlink1='eitf';
		if org eq 'abs' then xlink1='eitf';
		if org eq 'eitf' then xlink1='eitf';
		if org eq 'ABS' then xlink1='eitf';
		if org eq 'EITF' then xlink2=stddev;
		if org eq 'abs' then xlink2=stddev;
		if org eq 'eitf' then xlink2=stddev;
		if org eq 'ABS' then xlink2=stddev;

		if org eq 'FTB' then xlink1='ftb';
		if org eq 'ftb' then xlink1='ftb';
		if org eq 'ftb' then xlink2=stddev;
		if org eq 'FTB' then xlink2=stddev;

		if org eq 'FIN' then xlink1='fin';
		if org eq 'fin' then xlink1='fin';
		if org eq 'fin' then xlink2=stddev;
		if org eq 'FIN' then xlink2=stddev;

		if org eq 'SOP' then xlink1='sop';
		if org eq 'sop' then xlink1='sop';
		if org eq 'sop' then xlink2=stddev;
		if org eq 'SOP' then xlink2=stddev;

		if org eq 'APPD' then xlink1='appd';
		if org eq 'appd' then xlink1='appd';
		if org eq 'APPD' then xlink2=stddev;
		if org eq 'appd' then xlink2=stddev;

		if org eq 'FSP' then xlink1='fsp';
		if org eq 'fsp' then xlink1='fsp';
		if org eq 'fsp' then xlink2=stddev;
		if org eq 'FSP' then xlink2=stddev;
		if xlink2=:'fas107-1andapb28' then xlink2='107-1/apb28-1';
		if xlink2=:'fas115-1_and_fas124-1' then xlink2='115-1/124-1';
		if xlink2=:'fas115-2andfas124-2' then xlink2='115-2/124-2';
		if xlink2=:'fas141-1_and_fas142-1' then xlink2='141-1/142-1';
		if xlink1='fsp' and substr(xlink2,1,3)='fas' then xlink2=substr(xlink2,4,length(xlink2)-3);
		if substr(xlink2,1,5) eq '140-4' and xlink1='fsp' then xlink2='140-4';
		if substr(filename,1,3) eq '133' then xlink1='issue ';
		if substr(filename,1,3) eq '133' then xlink2=substr(filename,4,3);
		if substr(filename,1,3) eq '133' and substr(xlink2,3,1) = '.' then xlink2=substr(filename,4,2);
		if filename =: 'Topic' then xlink1='appd';
		if filename =: 'Topic' then xlink2=substr(stddev,3,length(stddev)-2);
		if xlink1= "" then xlink1=link1;
		if xlink2= "" then xlink2=link2;
		xlink=compress(cat(xlink1,xlink2));
		if xlink= 'ftb42736' then xlink='ftb01-1';
		iter1=stditr/1;
		if org='sop' and stddev='97-2' then
		std_num='97_2';
		if org='sop' and stddev='97-2' then iter1=0;
		if org='sop' and length(stddev) ge 20 and stddev =: '97-2' then
		std_num='97_2';
		if org='sop' and length(filename) ge 20 then iter1=1;
		year2=year1/1;
		if org='fas' and stddev='160i' then stditr=0;
		if org='fas' and stddev='160i' then iter1=0;
		if org='fas' and stddev='160i' then std_num='160';
		if org='fas' and stddev='161a' then stditr=0;
		if org='fas' and stddev='161a' then iter1=0;
		if org='fas' and stddev='161a' then std_num='161';
		if org='abs' and stddev='00-21' then std_num='00_21';
		if org='abs' and stddev='00-21' then org='eitf';
		if org='abs' and stddev='94-3' then std_num='94_3';
		if org='abs' and stddev='94-3' then org='eitf';
		if org='fas' and stddev='158i' then std_num='158';
		if org='fas' and stddev='158i' then iter1='0';
		if org='fas' and stddev='159i' then std_num='159';
		if org='fas' and stddev='159i' then iter1='0';
		if org='abs' and stddev='96-08' then stddev='96-8';
		if filename ne "";
		if org='fas' and stddev='141ri' then std_num='141r';
		run;



		/*edit a standard in rbc*/

		data rbc4; set rbc3a;
		if org='apb' and std_num='9' and iteration='0.15' then iter1='2';

		run;

		data shall7a; set shall7;
		if iter1 ne .;
		if org ne "";
		if std_num ne .;
		run;


		proc sql; create table shall8 as select
		a.*, b.*
		from rbc4 as a left join shall7 b
		on lowcase(a.org)=lowcase(b.org)
		and a.std_num eq b.std_num and a.iter1 eq b.iter1
		order by org, std_num, stditr, year;
		quit;


		proc sort data=shall7; by filename;run;

		/*start here and test is after shall15*/

		data shall9; set shall8;
		if org=:'fas' and std_num=:'68' and iteration=:'0.1' then rest_words=20;
		if org=:'fas' and std_num=:'67' and iteration=:'0.6' then rest_words=59;
		if org=:'fas' and std_num=:'156' and iteration=:'0.1' then rest_words=181;

		if org=:'fas' and std_num=:'113' and iteration=:'0.3' then rest_words=48;
		if org=:'fas' and std_num=:'141' and iteration=:'0.6' then rest_words=155;
		if org=:'fas' and std_num=:'15' and iteration=:'0.93' then rest_words=76;
		if org=:'fas' and std_num=:'113' and iteration=:'0.3' then ig='fin40';
		if org=:'fas' and std_num=:'15' and iteration=:'0.93' then ig='ftb80-1';
		if org=:'fas' and std_num=:'113' and iteration=:'0.3' then year1=1992;
		if org=:'fas' and std_num=:'15' and iteration=:'0.93' then year=1980;
		run;


		 data shall9; set shall9;
		IG1=lowcase(compress(ig));
		if ig1 eq "" then ig1='xrxyz';
		if ig1 =: 'ain-apb26'  then ig1='ain_apb26';
		if ig1 =: 'ain-apb4'  then ig1='ain_apb4';
		if ig1 =: 'ain-apb9'  then ig1='ain_apb9';
		if ig1 =: 'ain-apb16'  then ig1='ain_apb16';
		if ig1 =: 'ain-apb17'  then ig1='ain_apb17';
		if ig1 =: 'ain-apb18'  then ig1='ain_apb18';
		if ig1 =: 'ain-apb20'  then ig1='ain_apb20';
		if ig1 =: 'ain-apb21'  then ig1='ain_apb21';
		if ig1 =: 'ain-apb23'  then ig1='ain_apb23';
		if ig1 =: 'ain-apb25'  then ig1='ain_apb25';
		if ig1 =: 'ain-apb30'  then ig1='ain_apb30';
		if ig1 =: 'ain-arb51'  then ig1='ain_arb51';
		if  ig1 = 'd-74' then ig1='appd74';
		if  ig1 = 'd-1' then ig1='appd1';
		if  ig1 =: 'eitfd' then ig1=cat('appd',substr(ig1,7,length(ig1)-6));
		if ig1= 'eitf01-08' then ig1='eitf01-8';
		if ig1= 'fsp94-6-1' then ig1='fspsop94-6-1';
		if ig1= 'ftb85-2(supersededbyfas125)' then ig1='ftb85-2';

		ig1=lowcase(ig1);
		run;




		proc sql; create table shall10 as select
		a.*, b.rest_words as igr_words
		from shall9 as a left join shall7 b
		on a.ig1=lowcase(b.xlink) 
		order by org, std_num, stditr, year;
		quit;

		/*fin43  word count 
		was manually gathered*/
		data shall10; set shall10;
		if year lt year2 then igr_words=0;
		if ig1='issuec4' then igr_words=0;
		if ig1='issuej4' then igr_words=0;
		if ig1='fin43' then igr_words=22;
		if ig1='ain_apb20' then igr_words=0;
		run;




		data shall11; set shall10;
		if igr_words=. then igr_words=0;
		run;

		proc sort data=shall11 out=shall11a; by org std_num iter year ig1 descending igr_words;run;
		proc sort data=shall11a out=shall12 nodupkey; by org std_num iter year ig1;run;



		proc sql; create table shall12a as select distinct
		org,std_num,iter1,year,
						sum(igr_words) as igr1
		from shall12 group by org, std_num, iteration, year
		order by year;
		quit;



		proc sql; create table shall13 as select
		a.*, b.igr1
		from shall12 as a left join shall12a b
		on a.std_num=b.std_num and a.org=b.org and a.iter1=b.iter1 and a.year=b.year
		order by org, std_num, stditr, year;
		quit;

		proc sort data=shall13 out=shall14 nodupkey; by org std_num iter1 year;
		run;


		data shall15; set shall14;
		if igr1 eq . then igr1=0;
		restrict=rest_words+igr1;
		run;

		data rbc2a; set rbc2;
		if amm1_org ne "";
		iter1=iter/1;
		run;

		proc sql; create table s15 as select
		a.*, b.org as aorg1, b.std_num as anum1, b.year as yeara1
		from shall15 as a left join rbc2a b
		on a.orgx=cat(b.amm1_org,b.amm1_stdnum) and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;



		proc sort data=s15 out=s15a; by orgx year aorg1 anum1 yeara1;run;
		proc sort data=s15a out=s15b nodupkey; by orgx  year aorg1 anum1 yeara1;run;

		proc sql; create table s15c as select
		a.*, b.org as aorg2, b.std_num as anum2, b.year as yeara2
		from s15b as a left join rbc2a b
		on a.orgx=cat(b.amm2_org,b.amm2_stdnum) and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;

		proc sort data=s15c out=s15d; by orgx year aorg1 anum1 yeara1;run;
		proc sort data=s15d out=s15e nodupkey; by orgx year aorg1 anum1 yeara1;run;


		proc sql; create table s15f as select
		a.*, b.org as aorg3, b.std_num as anum3, b.year as yeara3
		from s15e as a left join rbc2a b
		on a.orgx=cat(b.amm3_org,b.amm3_stdnum) and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;

		proc sort data=s15f out=s15g; by orgx year aorg1 anum1 yeara1;run;
		proc sort data=s15g out=s15h nodupkey; by orgx year aorg1 anum1 yeara1;run;



		proc sort data=shall7 out=shall7x nodupkey; by filename org std_num stditr1  rest_words ;
		run;



		proc sql; create table shall7y as select
		a.*, b.year
		from shall7x as a left join rbc2a b
		on a.org1=b.org and a.std_num=b.std_num and a.iter1=b.iter1
		order by org, std_num, stditr, year;
		quit;



		proc sql; create table s15i as select
		a.*, b.rest_words as ar1
		from s15h as a left join shall7y b
		on lowcase(a.aorg1)=lowcase(b.org)
		and a.anum1 eq b.std_num and a.aorg1 ne "" and a.anum1 ne ""
		and b.org ne "" and b. std_num ne "" and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;


		proc sql; create table s15j as select
		a.*, b.rest_words as ar2
		from s15i as a left join shall7y b
		on lowcase(a.aorg2)=lowcase(b.org)
		and a.anum1 eq b.std_num and a.aorg1 ne "" and a.anum1 ne ""
		and b.org ne "" and b. std_num ne "" and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;

		proc sql; create table s15k as select
		a.*, b.rest_words as ar3
		from s15j as a left join shall7y b
		on lowcase(a.aorg3)=lowcase(b.org)
		and a.anum1 eq b.std_num and a.aorg1 ne "" and a.anum1 ne ""
		and b.org ne "" and b. std_num ne "" and a.yeary=b.year
		order by org, std_num, stditr, year;
		quit;



		data shall15k; set s15k;
		if ar1=. then ar1=0;
		if ar2=. then ar2=0;
		if ar3=. then ar3=0;
		run;

		proc sql; create table shall15l as select distinct
		orgx, year,
						min(ar1+ar2+ar3) as AR, sum(ar1+ar2+ar3) as ARnew
						 

		from shall15k group by orgx, year
		order by orgx, year;
		quit;

		proc sql; create table shall15m as select
		a.*, b.arnew
		from shall15k as a left join shall15l b
		on a.orgx=b.orgx and a.year=b.year
		order by standard, year;
		quit;

		proc sort data=shall15m out=shall15n nodupkey; by orgx year org std_num iteration iter iter1 rest_words stditr restrict arnew;
		run;

		data shall15o; set shall15n;
		TOTR=restrict+arnew;
		run;

		data dperm.shall15rra; set shall15o;
		run;
		data shall15o; set dperm.shall15rra;
		yearz=year*1;
		run;


		/*get min and max years*/
		proc means data=shall15o min max; by orgx;
		var yearz;
		output out=mdata;
		run;

		data mdata1; set mdata;
		if _stat_ eq "MIN" or _stat_ eq 'MAX';
		run;

		Proc export data=mdata1
		outfile='C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata.xlsx'
		dbms=xlsx
		replace;
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
		dbms=xlsx OUT = mdataa;run;

		/*above code creates the total restrictive words in each standard in each year
		up to 2009*/

		/*below adds the ASUS in the appropriate years*/


		proc sort data=shall15o out=shall15m; by standard descending year; run;
		proc sort data=shall15m out=shall15n nodupkey; by standard; run;

		data shall15p; set shall15n;
		if year=2009;
		run;

		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\myear.xlsx' 
		DBMS = xlsx OUT = myear ;run;


		proc sql; create table shall15q as select
		a.*, b.*
		from myear as a , shall15p b
		order by standard, myear;
		quit;

		data shall15r; set shall15q;
		if myear ne 2009;
		year=myear;
		drop myear;
		run;

		data shall15s; set shall15o shall15r;run;

		proc sort data=shall15s; by standard year;run;

		data link; set dperm.cod_link;
		link1=lowcase(compress(link));
		asuyear1=asuyear*1;
		if link1 =: "eitf" then link1=tranwrd(link1,"-","_");
		if link1 =: "sop" then link1=tranwrd(link1,"-","_");
		run;

		proc sort data=link; by link1;run;

		data shall15sa; set shall15s;
		link=compress(cat(org,std_num));
		yearx1=year*1;
		run;

		data link1; set link;
		if AorD="A" then total=total;
		if AorD="D" then total=total*-1;
		mergeyear=year(asu_eff_date);
		if asuyear1 gt mergeyear then mergeyear=asuyear1;
		run;



		

		
		data link1z; set link1;
		if link1="fas141(r)" then link1="fas141r";
		if link1="fas123(r)" then link1="fas123r";
		if link1="fas132(r)" then link1="fas132r";
		run;


		proc sql; create table shall15t as select
		a.*, b.topic, b.subtopic,b.section,b.paragraph,b.total
		from shall15sa as a  left join link1z as b
		on a.link=b.link1 and a.yearx1>=b.mergeyear
		order by standard, year;
		quit;





		proc sql; create table shall15u as select distinct
		filename, org,stddev,stditr,year,
						sum(total) as ASUrest

		from shall15t group by filename,org,stddev,stditr,year
		order by filename,org,stddev,stditr,year;
		quit;



		proc sql; create table shall15v as select
		a.*, b.ASUrest
		from shall15sa as a  left join shall15u as b
		on a.org=b.org and a.stddev=b.stddev and a.year=b.year
		order by standard, year;
		quit;

		proc sort data=shall15v out=shall15w noduprecs; by standard year; run;


		data shall15x; set shall15w;
		if asurest eq . then asurest=0;
		total_modal=totr+asurest;
		run;

		proc sort data=shall15x out=shall16x nodupkey; by org1 std_num iter1 year;run;




		data shal; set shall16x;
		drop ig iglink;
		run;


		proc sql; create table shal1 as select
		a.*, b.*
		from shal as a left join shall7 b
		on lowcase(a.org)=lowcase(b.org)
		and a.std_num eq b.std_num and a.iter1 eq b.iter1
		order by org, std_num, stditr, year;
		quit;





		 data shal2; set shal1;
		IG1=lowcase(compress(ig));
		if ig1 eq "" then ig1='xrxyz';
		if ig1 =: 'ain-apb26'  then ig1='ain_apb26';
		if ig1 =: 'ain-apb4'  then ig1='ain_apb4';
		if ig1 =: 'ain-apb9'  then ig1='ain_apb9';
		if ig1 =: 'ain-apb16'  then ig1='ain_apb16';
		if ig1 =: 'ain-apb17'  then ig1='ain_apb17';
		if ig1 =: 'ain-apb18'  then ig1='ain_apb18';
		if ig1 =: 'ain-apb20'  then ig1='ain_apb20';
		if ig1 =: 'ain-apb21'  then ig1='ain_apb21';
		if ig1 =: 'ain-apb23'  then ig1='ain_apb23';
		if ig1 =: 'ain-apb25'  then ig1='ain_apb25';
		if ig1 =: 'ain-apb30'  then ig1='ain_apb30';
		if ig1 =: 'ain-arb51'  then ig1='ain_arb51';
		if  ig1 = 'd-74' then ig1='appd74';
		if  ig1 = 'd-1' then ig1='appd1';
		if  ig1 =: 'eitfd' then ig1=cat('appd',substr(ig1,7,length(ig1)-6));
		if ig1= 'eitf01-08' then ig1='eitf01-8';
		if ig1= 'fsp94-6-1' then ig1='fspsop94-6-1';
		if ig1= 'ftb85-2(supersededbyfas125)' then ig1='ftb85-2';

		ig1=lowcase(ig1);
		if ig1 =: "eitf" then ig1=tranwrd(ig1,"-","_");
		if ig1 =: "sop" then ig1=tranwrd(ig1,"-","_");
		if ig1 =: "appd" then ig1=tranwrd(ig1,"appd","eitfd_");
		if ig1 =: "ain" then ig1=compress(tranwrd(ig1,"_",""));
		if ig1 ="fsp115-1/124-1"  then ig1=compress(tranwrd(ig1,"fsp","fspfas"));
		if ig1 ='ftb80-2' then ig1="ftb80-02";
		run;

		proc sql; create table shal3 as select
		a.*, b.topic, b.subtopic,b.section,b.paragraph,b.total as asuigr
		from shal2 as a  left join link1 as b
		on a.ig1=b.link1 and a.yearx1>=b.mergeyear
		order by standard, year;
		quit;







		data shal4; set shal3;
		if asuigr=. then asuigr=0;
		run;

		proc sort data=shal4 out=shal5; by org std_num iter year ig1 descending asuigr;run;
		proc sort data=shal5 out=shal6 nodupkey; by org std_num iter year ig1;run;



		proc sql; create table shal7 as select distinct
		org,std_num,iter1,year,
						sum(asuigr) as sumigr
		from shal6 group by org, std_num, iteration, year
		order by year;
		quit;



		proc sql; create table shal8 as select
		a.*, b.sumigr
		from shal6 as a left join shal7 b
		on a.std_num=b.std_num and a.org=b.org and a.iter1=b.iter1 and a.year=b.year
		order by org, std_num, stditr, year;
		quit;

		proc sort data=shal8 out=shal9 nodupkey; by org std_num iter1 year;
		run;


		data shal10; set shal9;
		if sumigr eq . then sumigr=0;
		tmod=total_modal+sumigr;
		run;



		data shall15ot; set shal10;
		TOTR=tmod;
		run;




		data shall17; set shall15ot;
		if year ne .;
		edt=input(eff_dt,9.)-1;
		edt1=intnx('YEAR',edt,-60);
		month=month(edt);
		day=day(edt);
		year1=year(edt1);
		eff_date=mdy(month,day,year1);
		format edt edt1 eff_date MMDDYY10.;
		run;



		data shall18; set shall17;
		keep org std_num stditr1 iteration end_dt eff_date year rest_words restrict igr1 arnew totr yearx total_modal;
		yearx=year(end_dt);
		run;

		proc sort data=shall18 out=shall19 nodupkey; by org std_num year yearx;run;
		proc sort data=shall19 out=shall20 nodupkey; by org std_num year;run;


		data shall21; set shall20;
		drop yearx;
		run;

		data dperm.shall21rraz; set shall21;
		run;
	/*END:i. Create shall21rraz*/
	/*BEGIN: j. Create alternative measure recognition only*/
		
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		/*bring in word count data*/


		data ps8; set dperm.rel_imp;run;

		/*below code brings in the count of shall,should must */

		/*brings in raw word counts...This brings in the word counts
		from standards but not ASUS*/
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\modal_words.xlsx'
		DBMS = xlsx OUT = mwords;run;

		data dperm.words1; set mwords;run;
		data words; set dperm.words1;
		drop sentence n o p q r s t u v w;
		run;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
		DBMS = xlsx OUT = rbc;run;
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
		DBMS = xlsx OUT = rbc2;run;



		/*rbc2 contains which standards are effective in which years some of the 
		iteration variables are whole numbers and some are decimals. i.e. iteration 1 is 
		sometimes represented as 1 and sometimes represented as .1 so I altered them to all be
		whole numbers*/




		data rbc2; set rbc2;
		iter=iteration;
		if iteration =: '0.' then iter=iteration*10;
		if iteration =: '0.91' then iter=iteration*100;
		if iteration =: '0.92' then iter=iteration*100;
		if iteration =: '0.93' then iter=iteration*100;
		if iteration =: '0.94' then iter=iteration*100;
		if iteration =: '.94' then iter=iteration*100;
		if iteration =: '0.95' then iter=iteration*100;
		if iteration =: '0.96' then iter=iteration*100;
		if iteration =: '0.15' then iter=iteration*100;
		if iteration =: '0.11' then iter=iteration*100;
		if iteration =: '0.12' then iter=iteration*100;
		if iteration =: '0.13' then iter=iteration*100;
		if iteration =: '0.14' then iter=iteration*100;
		if iteration =: '0.16' then iter=iteration*100;
		if iteration =: '0.17' then iter=iteration*100;
		if iteration =: '0.18' then iter=iteration*100;
		if iteration =: '0.19' then iter=iteration*100;
		orgx=compress(cat(org,std_num));
		if org='apb' and std_num='15' and year=1996 then matchv=1;
		run;

		data rbc1; set rbc;
		yeary=year*1;
		if standard='apb15' and year=1997 then yeary=1996;
		if standard='arb43_11b' and year ge 2006 then yeary=2005;
		run;

		proc sql; create table rbc3 as select
		a.*, b.*
		from rbc2 as a left join rbc1 b
		on b.standard=a.orgx and a.year=b.yeary
		order by org, std_num,year, iteration;
		quit;


		/*data test; set rbc2;
		keep org iter iteration std_num;
		run;


		proc sort data=test out=test2 nodupkey; by iter;run;*/

		/*we only want to keep the word counts for a subset of words*/

		proc sort data=words out=words1 nodupkey; by filename org stddev stditr word;run;


		data shall; set words1;
		where word in ('shall','must','should');
		run;

		proc sort data=shall out=shalln nodupkey; by filename;run;




		data shall21; set dperm.shall21rraz;
		run;

		/*I need to combine with reliance data and then orthogonalize
		with complexity*/




		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\rbc_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = rbcm ;run;
		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\complexity_ready_to_merge.xlsx' 
		DBMS = xlsx OUT = compm ;run;

		data shall21a; set shall21;
		linkz=compress(cat(org,std_num));
		run;

		proc sql; create table shall21b as select
		a.*, b.complex1,b.complex2
		from shall21a as a  left join compm as b
		on a.linkz=b.link
		order by org, std_num, year;
		quit;

		data shall21c; set shall21b;
		linky=compress(cat(year,org,std_num));
		run;

		proc sql; create table shall21d as select
		a.*, b.rbc1,b.rbc2
		from shall21c as a  left join rbcm as b
		on a.linky=b.link
		order by org, std_num, year;
		quit;

		data shall21e; set shall21d;
		drop linkz linky;
		if complex1 eq . then complex1=0;
		if complex2 eq . then complex2=0;
		iteration1=iteration*1;
		run;








		data shallna; set shalln;
		if org="sop" then stddev=tranwrd(stddev,"-","_");
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stddev="97_2";
		if filename="sop 97-2 ammend for 12151998 fiscal year ends or later.txt"  then stditr="0.1";
		org1=lowcase(org);
		if org="SAB" and stddev="01A" then stddev="101A";
		if org="SAB" and stddev="01B" then stddev="101B";
		std_num=lowcase(stddev);
		stditr1=stditr*1;
		if org="fas" and stditr ge 1 then stditr1=stditr/10;
		if org="fas" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stditr ge 1 then stditr1=stditr/10;
		if org="apb" and stditr ge 10 then stditr1=stditr/100;
		if org="apb" and stddev=1 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=1 and stditr eq 2 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 1 then stditr1=stditr*1;
		if org="apb" and stddev=5 and stditr eq 2 then stditr1=stditr*1;
		if filename="apb9.1.5.txt" then stditr1="0.15";
		if org1="arb" and stditr ge 1 then stditr1=stditr/10;
		if stddev="43_2A" then stddev=std_num;
		if stddev="43_2B" then stddev=std_num;
		if filename="abs00-21.txt" then org1="eitf";
		if filename="abs00-21.txt" then stddev=tranwrd(stddev,"-","_");
		if org="fas" and stddev="141ri" then stddev="141r";
		if org="fas" and stddev="158i" then stddev="158";
		if org="fas" and stddev="159i" then stddev="159";
		if org="fas" and stddev="160i" then stddev="160";
		if org="fas" and stddev="161a" then stddev="161";
		if org="fas" and stddev="162i" then stddev="162";
		if org="fas" and stddev="163i" then stddev="163";
		if org="fas" and stddev="164i" then stddev="164";
		if org="fas" and stddev="165i" then stddev="165";
		if org="fas" and stddev="166i" then stddev="166";
		if org="fas" and stddev="167i" then stddev="167";
		if org1="fas" and stddev="44" then stditr1=stditr/10;

		run;


		proc sql; create table length as select
		a.*, b.totalword as length
		from shall21e as a left join shallna b
		on a.org=b.org1 and a.std_num=b.stddev and a.iteration1=b.stditr1
		order by org, std_num, stditr;
		quit;


		/*I manually had to gather these word lengths*/
		data length1; set length;
		if org=:"eitf" and std_num=:"94_3" then length=5306;
		if org="fas" and std_num="68" then length=1816; 
		if org="arb" and std_num="43_3b" and iteration=0 then length=584; 
		if org="fas" and std_num="113" and iteration=0.3 then length=5955; 
		if org="fas" and std_num="15" and iteration=0.93 then length=5042;
		if org="fas" and std_num="156" and iteration=0.1 then length=40929;
		if org="fas" and std_num="67" and iteration=0.6 then length=3497;
		if org="fas" and std_num="53"  then length=3942;/**/
		*stm=total_modal/length;
		run;

		/*****this section adds in the changes in length in the post codification period*******/
		data shall15o; set dperm.shall15rra;
		yearz=year*1;
		run;

		proc sort data=shall15o out=shall15m; by standard descending year; run;
		proc sort data=shall15m out=shall15n nodupkey; by standard; run;

		data shall15p; set shall15n;
		if year=2009;
		run;

		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\myear.xlsx' 
		DBMS = xlsx OUT = myear ;run;


		proc sql; create table shall15q as select
		a.*, b.*
		from myear as a , shall15p b
		order by standard, myear;
		quit;

		data shall15r; set shall15q;
		if myear ne 2009;
		year=myear;
		drop myear;
		run;

		data shall15s; set shall15o shall15r;run;

		proc sort data=shall15s; by standard year;run;

		data link; set dperm.cod_link;
		link1=lowcase(compress(link));
		asuyear1=asuyear*1;
		if link1 =: "eitf" then link1=tranwrd(link1,"-","_");
		if link1 =: "sop" then link1=tranwrd(link1,"-","_");
		run;

		proc sort data=link; by link1;run;

		data shall15sa; set shall15s;
		link=compress(cat(org,std_num));
		yearx1=year*1;
		run;

		data link1; set link;
		if AorD="A" then total=total;
		if AorD="D" then total=total*-1;
		mergeyear=year(asu_eff_date);
		if asuyear1 gt mergeyear then mergeyear=asuyear1;
		run;



		
		
		data link1z; set link1;
		if link1="fas141(r)" then link1="fas141r";
		if link1="fas123(r)" then link1="fas123r";
		if link1="fas132(r)" then link1="fas132r";
		run;

		proc import datafile = ' C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\wcasu.xlsx' 
		DBMS = xlsx OUT = wcasu1 ;run;


		proc sql; create table lz1 as select
		a.*, b.wcasu
		from link1z as a  left join wcasu1 as b
		on a.filename=b.filename ;
		quit;

		data lz2; set lz1;
		if AorD="A" then wcasu=wcasu;
		if AorD="D" then wcasu=wcasu*-1;
		run;



		proc sql; create table shall15t as select
		a.*, b.topic, b.subtopic,b.section,b.paragraph,b.wcasu
		from shall15sa as a  left join lz2 as b
		on a.link=b.link1 and a.yearx1>=b.mergeyear
		order by standard, year;
		quit;





		proc sql; create table shall15u as select distinct
		filename, org,stddev,stditr,year,
						sum(wcasu) as wcASUt

		from shall15t group by filename,org,stddev,stditr,year
		order by filename,org,stddev,stditr,year;
		quit;



		proc sql; create table l1 as select
		a.*, b.wcASUt
		from shall15sa as a  left join shall15u as b
		on a.org=b.org and a.stddev=b.stddev and a.year=b.year
		order by standard, year;
		quit;

		proc sort data=l1 out=shall15w noduprecs; by standard year; run;


		proc sql; create table l1 as select
		a.*, b.wcASUt
		from shall15sa as a  left join shall15u as b
		on a.org=b.org and a.stddev=b.stddev and a.year=b.year
		order by standard, year;
		quit;

		proc sql; create table l2 as select
		a.*, b.wcASUt
		from length1 as a  left join l1 as b
		on a.org=b.org and a.std_num=b.std_num and a.year=b.year
		order by standard, year;
		quit;


		data length2; set l2;
		if wcasut eq . then wcasut=0;
		tlength=length+wcasut;
		stm=total_modal/tlength;
		run;



		/************/




		proc reg data=length2 ;
		model stm= complex1 complex2;
		output out=ds
		p=predicted
		r=residual;
		run;quit;

		proc sort data=ds; by org std_num year;run;

		data dperm.lengthrraz; set ds;
		keep org std_num iteration year end_dt stditr1 igr1 restrict arnew total_modal stm eff_date complex1 complex2 length org1 iteration1 totr predicted residual rbc1 rbc2 tlength;
		run;


		Proc export data=dperm.lengthrraz
		outfile='C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\lengthrraz.xlsx'
		dbms=xlsx
		replace;
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\imp1_lengthrraz.xlsx'
		dbms=xlsx OUT = imp1;run;

		data ps9; set ps8;
		if fyear ne . then year=fyear;
		if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then year=year(datadate);
		run;

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
		dbms=xlsx OUT = mdataa;run;

		data mdata3; set mdataa;
		/*I added this line to include fas141r which is included
		in the word counts of 141*/
		max_fas141=max_fas141r;
		id=1;
		if min_apb2 ne .;
		drop ko kp;
		run;
		data ps9; set ps9;
		id=1;
		run;

		proc sql; create table ps10 as select
		a.*, b.*
		from ps9 as a left join mdata3 b
		on a.id=b.id
		order by cik, fyear;
		quit;

		data ps11 ; set ps10;
		if fyear lt min_apb25 then ri_apb25=0;
		if fyear gt max_apb25 then ri_apb25=0;

		if fyear lt min_apb4 then ri_apb4=0;
		if fyear gt max_apb4 then ri_apb4=0;

		if fyear lt min_apb9 then ri_apb9=0;
		if fyear gt max_apb9 then ri_apb9=0;

		if fyear lt min_apb14 then ri_apb14=0;
		if fyear gt max_apb14 then ri_apb14=0;

		if fyear lt min_apb16 then ri_apb16=0;
		if fyear gt max_apb16 then ri_apb16=0;

		if fyear lt min_apb17 then ri_apb17=0;
		if fyear gt max_apb17 then ri_apb17=0;

		if fyear lt min_apb18 then ri_apb18=0;
		if fyear gt max_apb18 then ri_apb18=0;

		if fyear lt min_apb20 then ri_apb20=0;
		if fyear gt max_apb20 then ri_apb20=0;

		if fyear lt min_apb21 then ri_apb21=0;
		if fyear gt max_apb21 then ri_apb21=0;

		if fyear lt min_apb23 then ri_apb23=0;
		if fyear gt max_apb23 then ri_apb23=0;

		if fyear lt min_apb26 then ri_apb26=0;
		if fyear gt max_apb26 then ri_apb26=0;

		if fyear lt min_apb29 then ri_apb29=0;
		if fyear gt max_apb29 then ri_apb29=0;

		if fyear lt min_apb30 then ri_apb30=0;
		if fyear gt max_apb30 then ri_apb30=0;

		if fyear lt min_arb45 then ri_arb45=0;
		if fyear gt max_arb45 then ri_arb45=0;

		if fyear lt min_arb51 then ri_arb51=0;
		if fyear gt max_arb51 then ri_arb51=0;

		if fyear lt min_arb43_2a then ri_arb43_2a=0;
		if fyear gt max_arb43_2a then ri_arb43_2a=0;

		if fyear lt min_arb43_3a then ri_arb43_3a=0;
		if fyear gt max_arb43_3a then ri_arb43_3a=0;

		if fyear lt min_arb43_3b then ri_arb43_3b=0;
		if fyear gt max_arb43_3b then ri_arb43_3b=0;

		if fyear lt min_arb43_4 then ri_arb43_4=0;
		if fyear gt max_arb43_4 then ri_arb43_4=0;

		if fyear lt min_arb43_7a then ri_arb43_7a=0;
		if fyear gt max_arb43_7a then ri_arb43_7a=0;

		if fyear lt min_arb43_7b then ri_arb43_7b=0;
		if fyear gt max_arb43_7b then ri_arb43_7b=0;

		if fyear lt min_arb43_9a then ri_arb43_9a=0;
		if fyear gt max_arb43_9a then ri_arb43_9a=0;

		if fyear lt min_arb43_9b then ri_arb43_9b=0;
		if fyear gt max_arb43_9b then ri_arb43_9b=0;

		if fyear lt min_arb43_10a then ri_arb43_10a=0;
		if fyear gt max_arb43_10a then ri_arb43_10a=0;

		if fyear lt min_arb43_11a then ri_arb43_11a=0;
		if fyear gt max_arb43_11a then ri_arb43_11a=0;

		if fyear lt min_arb43_11b then ri_arb43_11b=0;
		if fyear gt max_arb43_11b then ri_arb43_11b=0;

		if fyear lt min_arb43_11c then ri_arb43_11c=0;
		if fyear gt max_arb43_11c then ri_arb43_11c=0;

		if fyear lt min_arb43_12 then ri_arb43_12=0;
		if fyear gt max_arb43_12 then ri_arb43_12=0;

		if fyear lt min_con5_6 then ri_con5_6=0;
		if fyear gt max_con5_6 then ri_con5_6=0;

		if fyear lt min_eitf00_21 then ri_eitf00_21=0;
		if fyear gt max_eitf00_21 then ri_eitf00_21=0;

		if fyear lt min_eitf94_3 then ri_eitf94_03=0;
		if fyear gt max_eitf94_3 then ri_eitf94_03=0;

		if fyear lt min_fas2 then ri_fas2=0;
		if fyear gt max_fas2 then ri_fas2=0;

		if fyear lt min_fas5 then ri_fas5=0;
		if fyear gt max_fas5 then ri_fas5=0;

		if fyear lt min_fas7 then ri_fas7=0;
		if fyear gt max_fas7 then ri_fas7=0;

		if fyear lt min_fas13 then ri_fas13=0;
		if fyear gt max_fas13 then ri_fas13=0;

		if fyear lt min_fas15 then ri_fas15=0;
		if fyear gt max_fas15 then ri_fas15=0;

		if fyear lt min_fas16 then ri_fas16=0;
		if fyear gt max_fas16 then ri_fas16=0;

		if fyear lt min_fas19 then ri_fas19=0;
		if fyear gt max_fas19 then ri_fas19=0;

		if fyear lt min_fas34 then ri_fas34=0;
		if fyear gt max_fas34 then ri_fas34=0;

		if fyear lt min_fas35 then ri_fas35=0;
		if fyear gt max_fas35 then ri_fas35=0;

		if fyear lt min_fas43 then ri_fas43=0;
		if fyear gt max_fas43 then ri_fas43=0;

		if fyear lt min_fas45 then ri_fas45=0;
		if fyear gt max_fas45 then ri_fas45=0;

		if fyear lt min_fas47 then ri_fas47=0;
		if fyear gt max_fas47 then ri_fas47=0;

		if fyear lt min_fas48 then ri_fas48=0;
		if fyear gt max_fas48 then ri_fas48=0;

		if fyear lt min_fas49 then ri_fas49=0;
		if fyear gt max_fas49 then ri_fas49=0;

		if fyear lt min_fas50 then ri_fas50=0;
		if fyear gt max_fas50 then ri_fas50=0;

		if fyear lt min_fas51 then ri_fas51=0;
		if fyear gt max_fas51 then ri_fas51=0;

		if fyear lt min_fas52 then ri_fas52=0;
		if fyear gt max_fas52 then ri_fas52=0;

		if fyear lt min_fas53 then ri_fas53=0;
		if fyear gt max_fas53 then ri_fas53=0;

		if fyear lt min_fas57 then ri_fas57=0;
		if fyear gt max_fas57 then ri_fas57=0;

		if fyear lt min_fas60 then ri_fas60=0;
		if fyear gt max_fas60 then ri_fas60=0;

		if fyear lt min_fas61 then ri_fas61=0;
		if fyear gt max_fas61 then ri_fas61=0;

		if fyear lt min_fas63 then ri_fas63=0;
		if fyear gt max_fas63 then ri_fas63=0;

		if fyear lt min_fas65 then ri_fas65=0;
		if fyear gt max_fas65 then ri_fas65=0;

		if fyear lt min_fas66 then ri_fas66=0;
		if fyear gt max_fas66 then ri_fas66=0;

		if fyear lt min_fas67 then ri_fas67=0;
		if fyear gt max_fas67 then ri_fas67=0;

		if fyear lt min_fas68 then ri_fas68=0;
		if fyear gt max_fas68 then ri_fas68=0;

		if fyear lt min_fas71 then ri_fas71=0;
		if fyear gt max_fas71 then ri_fas71=0;

		if fyear lt min_fas77 then ri_fas77=0;
		if fyear gt max_fas77 then ri_fas77=0;

		if fyear lt min_fas80 then ri_fas80=0;
		if fyear gt max_fas80 then ri_fas80=0;

		if fyear lt min_fas86 then ri_fas86=0;
		if fyear gt max_fas86 then ri_fas86=0;

		if fyear lt min_fas87 then ri_fas87=0;
		if fyear gt max_fas87 then ri_fas87=0;

		if fyear lt min_fas88 then ri_fas88=0;
		if fyear gt max_fas88 then ri_fas88=0;

		if fyear lt min_fas97 then ri_fas97=0;
		if fyear gt max_fas97 then ri_fas97=0;

		if fyear lt min_fas101 then ri_fas101=0;
		if fyear gt max_fas101 then ri_fas101=0;

		if fyear lt min_fas105 then ri_fas105=0;
		if fyear gt max_fas105 then ri_fas105=0;

		if fyear lt min_fas106 then ri_fas106=0;
		if fyear gt max_fas106 then ri_fas106=0;

		if fyear lt min_fas107 then ri_fas107=0;
		if fyear gt max_fas107 then ri_fas107=0;

		if fyear lt min_fas109 then ri_fas109=0;
		if fyear gt max_fas109 then ri_fas109=0;

		if fyear lt min_fas113 then ri_fas113=0;
		if fyear gt max_fas113 then ri_fas113=0;

		if fyear lt min_fas115 then ri_fas115=0;
		if fyear gt max_fas115 then ri_fas115=0;

		if fyear lt min_fas119 then ri_fas116=0;
		if fyear gt max_fas119 then ri_fas116=0;

		if fyear lt min_fas121 then ri_fas121=0;
		if fyear gt max_fas121 then ri_fas121=0;

		if fyear lt min_fas123 then ri_fas123=0;
		if fyear gt max_fas123 then ri_fas123=0;

		if fyear lt min_fas123r then ri_fas123r=0;
		if fyear gt max_fas123r then ri_fas123r=0;

		if fyear lt min_fas125 then ri_fas125=0;
		if fyear gt max_fas125 then ri_fas125=0;

		if fyear lt min_fas130 then ri_fas130=0;
		if fyear gt max_fas130 then ri_fas130=0;

		if fyear lt min_fas132 then ri_fas132=0;
		if fyear gt max_fas132 then ri_fas132=0;

		if fyear lt min_fas132r then ri_fas132r=0;
		if fyear gt max_fas132r then ri_fas132r=0;

		if fyear lt min_fas133 then ri_fas133=0;
		if fyear gt max_fas133 then ri_fas133=0;

		if fyear lt min_fas140 then ri_fas140=0;
		if fyear gt max_fas140 then ri_fas140=0;

		if fyear lt min_fas141 then ri_fas141=0;
		if fyear gt max_fas141 then ri_fas141=0;

		if fyear lt min_fas142 then ri_fas142=0;
		if fyear gt max_fas142 then ri_fas142=0;

		if fyear lt min_fas143 then ri_fas143=0;
		if fyear gt max_fas143 then ri_fas143=0;

		if fyear lt min_fas144 then ri_fas144=0;
		if fyear gt max_fas144 then ri_fas144=0;

		if fyear lt min_fas146 then ri_fas146=0;
		if fyear gt max_fas146 then ri_fas146=0;

		if fyear lt min_fas150 then ri_fas150=0;
		if fyear gt max_fas150 then ri_fas150=0;
		if fyear lt min_fas154 then ri_fas154=0;
		if fyear gt max_fas154 then ri_fas154=0;
		if fyear lt min_sab101 then ri_sab101=0;
		if fyear gt max_sab101 then ri_sab101=0;
		if fyear lt min_sop97_2 then ri_sop97_2=0;
		if fyear gt max_sop97_2 then ri_sop97_2=0;
		if fyear lt 2009 then ri_asu2009_17=0;
		if fyear lt 2011 then ri_asu2011_08=0;
		if fyear lt 2012 then ri_asu2012_01=0;
		if fyear lt 2012 then ri_asu2012_02=0;
		run;


		proc sql; create table ds1 as select
		a.*, b.*
		from ps11 as a left join imp1 b
		on a.year=b.year
		order by cik, fyear;
		quit;


		data ds1a; set ds1;
		if ri_apb25 eq . then  ri_apb25=0;    
		if apb25 eq . then  apb25=0; 
		if ri_apb2  eq . then  ri_apb2=0;           
		if apb2 eq . then  apb2=0; 
		if ri_apb4 eq . then  ri_apb4=0;          
		if apb4 eq . then  apb4=0; 
		if ri_apb9 eq . then  ri_apb9=0;          
		if apb9 eq . then  apb9=0; 
		if ri_apb14 eq . then  ri_apb14=0;           
		if apb14 eq . then apb14=0; 
		if ri_apb16 eq . then  ri_apb16=0;          
		if apb16 eq . then apb16=0; 
		if ri_apb17 eq . then  ri_apb17=0;         
		if apb17 eq . then apb17=0; 
		if ri_apb18 eq . then  ri_apb18=0;         
		if apb18 eq . then  apb18=0; 
		if ri_apb20 eq . then  ri_apb20=0;          
		if apb20 eq . then  apb20=0; 
		if ri_apb21 eq . then  ri_apb21=0;          
		if apb21 eq . then  apb21=0; 
		if ri_apb23 eq . then  ri_apb23=0;          
		if apb23 eq . then  apb23=0; 
		if ri_apb26 eq . then  ri_apb26=0;          
		if apb26 eq . then  apb26=0; 
		if ri_apb29 eq . then  ri_apb29=0;          
		if apb29 eq . then  apb29=0; 
		if ri_apb30 eq . then  ri_apb30=0;          
		if apb30 eq . then  apb30=0; 
		if ri_arb45 eq .  then ri_arb45=0;        
		if arb45  eq . then arb45=0;
		if ri_arb51  eq . then ri_arb51=0;
		if arb51  eq . then arb51=0;
		if ri_arb43_2a  eq . then ri_arb43_2a=0;        
		if arb43_2a eq . then arb43_2a=0;    
		if ri_arb43_3a eq . then ri_arb43_3a=0;              
		if arb43_3a  eq . then arb43_3a=0;  
		if ri_arb43_3b eq . then ri_arb43_3b=0;            
		if arb43_3b  eq . then arb43_3b=0;  
		if ri_arb43_4  eq . then ri_arb43_4=0;           
		if arb43_4  eq . then arb43_4=0;  
		if ri_arb43_7a eq . then ri_arb43_7a=0;           
		if arb43_7a  eq . then arb43_7a=0;  
		if ri_arb43_7b eq . then ri_arb43_7b=0;            
		if arb43_7b  eq . then arb43_7b=0;  
		if ri_arb43_9a eq . then ri_arb43_9a=0;            
		if arb43_9a  eq . then arb43_9a=0;  
		if ri_arb43_9b eq . then ri_arb43_9b=0;            
		if arb43_9b  eq . then arb43_9b=0;  
		if ri_arb43_10a  eq . then ri_arb43_10a=0;           
		if arb43_10a  eq . then arb43_10a=0;  
		if ri_arb43_11a  eq . then ri_arb43_11a=0;            
		if arb43_11a  eq . then arb43_11a=0;  
		if ri_arb43_11b  eq . then ri_arb43_11b=0;           
		if arb43_11b  eq . then arb43_11b=0;  
		if ri_arb43_11c  eq . then ri_arb43_11c=0;          
		if arb43_11c  eq . then arb43_11c=0;  
		if ri_arb43_12   eq . then ri_arb43_12=0;          
		if arb43_12  eq . then arb43_12=0;  
		if ri_con5_6     eq . then ri_con5_6=0;       
		if con5_6  eq . then con5_6=0;  
		if ri_eitf00_21  eq . then ri_eitf00_21=0;           
		if abs00_21  eq . then abs00_21=0;  
		if ri_eitf94_03  eq . then ri_eitf94_03=0;           
		if abs94_03  eq . then abs94_03=0;  
		if ri_fas2       eq . then ri_fas2=0;      
		if fas2  eq . then fas2=0;  
		if ri_fas5       eq . then ri_fas5=0;      
		if fas5  eq . then fas5=0;  
		if ri_fas7       eq . then ri_fas7=0;      
		if fas7  eq . then fas7=0;  
		if ri_fas13      eq . then ri_fas13=0;       
		if fas13  eq . then fas13=0;  
		if ri_fas15      eq . then ri_fas15=0;       
		if fas15  eq . then fas15=0;  
		if ri_fas16      eq . then ri_fas16=0;      
		if fas16  eq . then fas16=0;  
		if ri_fas19      eq . then ri_fas19=0;       
		if  fas19  eq . then fas19=0;  
		if ri_fas34      eq . then ri_fas34=0;      
		if fas34  eq . then fas34=0;  
		if ri_fas35      eq . then ri_fas35=0;      
		if fas35  eq . then fas35=0;  
		if ri_fas43      eq . then ri_fas43=0;       
		if fas43  eq . then fas43=0;  
		if ri_fas45      eq . then ri_fas45=0;      
		if fas45  eq . then fas45=0;  
		if ri_fas47      eq . then ri_fas47=0;       
		if fas47  eq . then fas47=0;  
		if ri_fas48      eq . then ri_fas48=0;      
		if fas48  eq . then fas48=0;  
		if ri_fas49      eq . then ri_fas49=0;      
		if fas49  eq . then fas49=0;  
		if ri_fas50      eq . then ri_fas50=0;      
		if fas50  eq . then fas50=0;  
		if ri_fas51      eq . then ri_fas51=0;      
		if fas51  eq . then fas51=0;  
		if ri_fas52      eq . then ri_fas52=0;      
		if fas52  eq . then fas52=0;  
		if ri_fas53      eq . then ri_fas53=0;       
		if fas53  eq . then fas53=0;  
		if ri_fas57      eq . then ri_fas57=0;      
		if fas57  eq . then fas57=0;  
		if ri_fas60      eq . then ri_fas60=0;      
		if fas60  eq . then fas60=0;  
		if ri_fas61      eq . then ri_fas61=0;       
		if fas61  eq . then fas61=0;  
		if ri_fas63      eq . then ri_fas63=0;       
		if fas63  eq . then fas63=0;  
		if ri_fas65      eq . then ri_fas65=0;       
		if fas65  eq . then fas65=0;  
		if ri_fas66      eq . then ri_fas66=0;       
		if fas66  eq . then fas66=0;  
		if ri_fas67      eq . then ri_fas67=0;       
		if fas67  eq . then fas67=0;  
		if ri_fas68      eq . then ri_fas68=0;       
		if fas68  eq . then fas68=0;  
		if ri_fas71      eq . then ri_fas71=0;       
		if fas71  eq . then fas71=0;  
		if ri_fas77      eq . then ri_fas77=0;       
		if fas77  eq . then fas77=0;  
		if ri_fas80      eq . then ri_fas80=0;       
		if fas80  eq . then fas80=0;  
		if ri_fas86      eq . then ri_fas86=0;       
		if fas86  eq . then fas86=0;  
		if ri_fas87      eq . then ri_fas87=0;       
		if fas87  eq . then fas87=0;  
		if ri_fas88      eq . then ri_fas88=0;      
		if fas88  eq . then fas88=0;  
		if ri_fas97      eq . then ri_fas97=0;       
		if fas97  eq . then fas97=0;  
		if ri_fas101     eq . then ri_fas101=0;        
		if fas101  eq . then fas101=0;  
		if ri_fas105     eq . then ri_fas105=0;        
		if fas105  eq . then fas105=0;  
		if ri_fas106     eq . then ri_fas106=0;        
		if fas106  eq . then fas106=0;  
		if ri_fas107     eq . then ri_fas107=0;        
		if fas107  eq . then fas107=0;  
		if ri_fas109     eq . then ri_fas109=0;        
		if fas109  eq . then fas109=0;  
		if ri_fas113     eq . then ri_fas113=0;        
		if fas113  eq . then fas113=0;  
		if ri_fas115     eq . then ri_fas115=0;        
		if fas115  eq . then fas115=0;  
		if ri_fas116     eq . then ri_fas116=0;        
		if fas116  eq . then fas116=0;  
		if ri_fas119     eq . then ri_fas119=0;        
		if fas119  eq . then fas119=0;  
		if ri_fas121     eq . then ri_fas121=0;        
		if fas121  eq . then fas121=0;  
		if ri_fas123     eq . then ri_fas123=0;       
		if fas123  eq . then fas123=0;  
		if ri_fas123r    eq . then ri_fas123r=0;       
		if fas123r  eq . then fas123r=0;  
		if ri_fas125     eq . then ri_fas125=0;        
		if fas125  eq . then fas125=0;  
		if ri_fas130     eq . then ri_fas130=0;        
		if fas130  eq . then fas130=0;  
		if ri_fas132     eq . then ri_fas132=0;        
		if fas132  eq . then fas132=0;  
		if ri_fas132r    eq . then ri_fas132r=0;        
		if fas132r  eq . then fas132r=0;  
		if ri_fas133     eq . then ri_fas133=0;       
		if fas133  eq . then fas133=0;  
		if ri_fas140     eq . then ri_fas140=0;        
		if fas140  eq . then fas140=0;  
		if ri_fas141     eq . then ri_fas141=0;       
		if fas141  eq . then fas141=0;  
		if ri_fas142     eq . then ri_fas142=0;       
		if fas142  eq . then fas142=0;  
		if ri_fas143     eq . then ri_fas143=0;       
		if fas143  eq . then fas143=0;  
		if ri_fas144     eq . then ri_fas144=0;       
		if fas144  eq . then fas144=0;  
		if ri_fas146     eq . then ri_fas146=0;       
		if fas146  eq . then fas146=0;  
		if ri_fas150     eq . then ri_fas150=0;       
		if fas150  eq . then fas150=0;  
		if ri_fas154     eq . then ri_fas154=0;       
		if fas154  eq . then fas154=0;  
		if ri_sab101 eq . then ri_sab101=0;  
		if sab101  eq . then sab101=0;  
		if ri_sop97_2 eq . then ri_sop97_2=0;  
		if sop97_2  eq . then sop97_2=0;  
		run;


		data ds2; set ds1a;
		Dscore=-1*(ri_apb25*apb25+
		ri_apb2*apb2+
		ri_apb4*apb4+
		ri_apb9*apb9+
		ri_apb14*apb14+
		ri_apb16*apb16+
		ri_apb17*apb17+
		ri_apb18*apb18+
		ri_apb20*apb20+
		ri_apb21*apb21+
		ri_apb23*apb23+
		ri_apb26*apb26+
		ri_apb29*apb29+
		ri_apb30*apb30+
		ri_arb45*arb45+
		ri_arb51*arb51+
		ri_arb43_2a*arb43_2a+
		ri_arb43_3a*arb43_3a+
		ri_arb43_3b*arb43_3b+
		ri_arb43_4*arb43_4+
		ri_arb43_7a*arb43_7a+
		ri_arb43_7b*arb43_7b+
		ri_arb43_9a*arb43_9a+
		ri_arb43_9b*arb43_9b+
		ri_arb43_10a*arb43_10a+
		ri_arb43_11a*arb43_11a+
		ri_arb43_11b*arb43_11b+
		ri_arb43_11c*arb43_11c+
		ri_arb43_12*arb43_12+
		ri_con5_6*con5_6+
		ri_eitf00_21*abs00_21+
		ri_eitf94_03*abs94_03+
		ri_fas2*fas2+
		ri_fas5*fas5+
		ri_fas7*fas7+
		ri_fas13*fas13+
		ri_fas15*fas15+
		ri_fas16*fas16+
		ri_fas19*fas19+
		ri_fas34*fas34+
		ri_fas35*fas35+
		ri_fas43*fas43+
		ri_fas45*fas45+
		/*ri_fas47*fas47+*/
		ri_fas48*fas48+
		ri_fas49*fas49+
		ri_fas50*fas50+
		ri_fas51*fas51+
		ri_fas52*fas52+
		ri_fas53*fas53+
		/*ri_fas57*fas57+*/
		ri_fas60*fas60+
		ri_fas61*fas61+
		ri_fas63*fas63+
		ri_fas65*fas65+
		ri_fas66*fas66+
		ri_fas67*fas67+
		ri_fas68*fas68+
		ri_fas71*fas71+
		ri_fas77*fas77+
		ri_fas80*fas80+
		ri_fas86*fas86+
		ri_fas87*fas87+
		ri_fas88*fas88+
		ri_fas97*fas97+
		ri_fas101*fas101+
		/*ri_fas105*fas105+*/
		ri_fas106*fas106+
		/*ri_fas107*fas107+*/
		ri_fas109*fas109+
		ri_fas113*fas113+
		ri_fas115*fas115+
		ri_fas116*fas116+
		/*ri_fas119*fas119+*/
		ri_fas121*fas121+
		ri_fas123*fas123+
		ri_fas123r*fas123r+
		ri_fas125*fas125+
		ri_fas130*fas130+
		ri_fas132*fas132+
		ri_fas132r*fas132r+
		ri_fas133*fas133+
		ri_fas140*fas140+
		ri_fas141*fas141+
		ri_fas142*fas142+
		ri_fas143*fas143+
		ri_fas144*fas144+
		ri_fas146*fas146+
		ri_fas150*fas150+
		ri_fas154*fas154+
		ri_sab101*sab101+
		ri_sop97_2*sop97_2);
		run;

		data dperm.dscore_recogn_only; set ds2;
		run;

		data dperm.dscore_limited_recogn_only; set ds2;
		keep cik datadate fyear permno gvkey year dscore;
		run;

	/*END: j. Create alternative measure recognition only*/


/*END:1. Create Limit_Discr (called dscore in code)*/
/*BEGIN:2. SAS CREATE DATA FOR MAIN TESTS */




	/*BEGIN:a. Main_tests*/


		*Basic Initializations;
		%let wrds = wrds.wharton.upenn.edu 4016;
		options comamid=TCP remote=wrds;
		signon username=_prompt_;
		Libname rwork slibref=work server=wrds;


		/*ASSIGN LIBRARIES*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
		libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";

		data ds2; set data.dscore_limited;
		run;

		
		data accruals; set dperm.accruals;
		run;

		proc sql; create table ds3 as select
		a.*, b.datadate, b.dcamodjones1991 as DAcc
		from ds2 as a left join accruals b
		on a.gvkey=b.gvkey and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\pscore1.xlsx'
		DBMS = xlsx OUT = pscore1;run;

		data ds3; set ds3;
		gvkey1=gvkey/1;
		run;

		proc sql; create table ds4 as select
		a.*, b.pscore
		from ds3 as a left join pscore1 b
		on a.gvkey1=b.gvkey and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;

		proc sort data=ds4 out=ds4 ;by cik fyear;run;
		proc sort data=ds4 out=ds5 nodupkey;by cik fyear;run;

		/*ibes quidance database*/
		data guid; set dperm.det_guidance_1_29_2017;
		run;

		/*link table*/
		data link; set byu.gvkey_permno_link2017nov30;
		cik1=cik/1;
		fyear=.;
		if fyear eq . and month(datadate) le 5 then fyear=year(datadate)-1;
		if fyear eq . and month(datadate) gt 5 then fyear=year(datadate);
		run;

		rsubmit;
		proc download data=ibes.id out=iid;run;
		proc download data=crsp.stocknames out=cid;run;
		endrsubmit;
		%ICLINK (IBESID=iID,CRSPID=cid,OUTSET=ICLINK);

		proc sql; create table ds6 as select
		a.*, b.ticker
		from ds5 as a left join iclink b
		on a.permno=b.permno
		order by gvkey, datadate;
		quit;

		proc sort data=ds6 out=ds6a; by cik fyear descending ticker;run;
		proc sort data=ds6a out=ds6b nodupkey; by cik fyear;run;

		proc sql; create table ds6c as select
		a.*, b.tic,b.cusip, b.cik1, b.datadate as d1
		from ds6b as a left join link b
		on a.gvkey=b.gvkey and intnx('day',a.datadate,-20)<=b.datadate<=intnx('day',a.datadate,20)
		order by gvkey, datadate;
		quit;

		data ds6d;set ds6c;
		dist=datadate-d1;
		f_ftype=compress(tranwrd(f_ftype,"-",""));
		run;

		proc sort data=ds6d out=ds6e ;by cik fyear dist;run;

		proc sort data=ds6e out=ds7 nodupkey;by cik fyear;run;

		data aa; set dperm.aa_filedate;
		if form_fkey =: "10-K";
		cik=company_fkey/1;
		form_fkey=compress(tranwrd(form_fkey,"-",""));
		run;

		proc sql; create table ds6x as select
		a.*, b.file_date as file_datea
		from ds7 as a left join aa as b
		on a.cik=b.cik and year(a.datadate)=year(b.fiscal_year_end_op) and a.f_ftype=b.form_fkey
		order by gvkey, datadate;
		quit;

		proc sort data=ds6x out=gro; by cik fyear descending file_datea;
		run;
		proc sort data=gro out=gro1 nodupkey; by cik fyear ;
		run;



		proc sql; create table ds6aa as select
		a.*, b.file_date as fdate1
		from gro1 as a left join aa as b
		on a.cik=b.cik and year(a.datadate)=year(b.fiscal_year_end_op)+1
		order by gvkey, datadate;
		quit;

		proc sort data=ds6aa out=gro2; by cik fyear descending fdate1;
		run;
		proc sort data=gro2 out=gro3 nodupkey; by cik fyear ;
		run;

		proc sql; create table ds6b as select
		a.*, b.numest
		from ds6aa as a left join wrds.ibes_statsum as b
		on a.ticker=b.ticker and year(a.datadate)=year(b.fpedats)
		order by gvkey, datadate;
		quit;

		proc sort data=ds6b out=gro4; by cik fyear descending numest;
		run;
		proc sort data=gro4 out=ds6c nodupkey; by cik fyear;run;

		proc sql; create table ds6bb as select
		a.*, b.numest as numest1
		from ds6c as a left join wrds.ibes_statsum as b
		on a.ticker=b.ticker and year(a.datadate)=year(b.fpedats)+1
		order by gvkey, datadate;
		quit;

		proc sort data=ds6bb out=gro5; by cik fyear descending numest1;
		run;
		proc sort data=gro5 out=ds6cc nodupkey; by cik fyear;run;

		PROC IMPORT OUT= WORK.LMa
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\LM_first_half.csv"
		      DBMS=csv REPLACE;
		      GETNAMES=YES;
		  guessingrows=10000;
		RUN;

		PROC IMPORT OUT= WORK.LM2
		      DATAFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\LM_second_half.csv"
		      DBMS=csv REPLACE;
		      GETNAMES=YES;
		  guessingrows=10000;
		RUN;

		data lm; set lma lm2;run;

		data bill3; set lm;
		if f_ftype ="10-K" or f_ftype ="10-K405" or f_ftype ="10-KSB" or f_ftype ="10-KT" or f_ftype ="10KSB" or f_ftype ="10KSB40" or f_ftype ="10KT405";
		run;


		data bill4; set bill3;
		dyear=substr(conf_per_rpt,5,4);
		dmonth=substr(conf_per_rpt,9,2);
		dday=substr(conf_per_rpt,11,2);
		ddate=mdy(dmonth,dday,dyear);
		format ddate mmddyy10.;
		f_ftype=compress(tranwrd(f_ftype,"-",""));
		run;

		proc sql;create table billx as select 
		a.*, b.f_fdate as filedate
		from ds6cc as a left join bill4 as b
		on a.cik=b.f_cik and intnx('day',b.ddate,-20)<=a.datadate<=intnx('day',b.ddate,20) and a.f_ftype=b.f_ftype
		order by gvkey, datadate;
		quit;

		proc sort data=billx out=billx1; by cik fyear descending filedate;run;
		proc sort data=billx1 out=billx2 nodupkey; by cik fyear;run;


		data billb; set billx2;
		year2=substr(filedate,5,4);
		day2=substr(filedate,11,2);
		month2=substr(filedate,9,2);
		bdate=mdy(month2,day2,year2);
		format bdate mmddyy10.;
		run;
		data bills; set billb;
		filedate1=bdate;
		format filedate1 mmddyy10.;
		run;
		data bil; set bills;
		run;

		data bi; set bil;
		if filedate1 ne .;
		run;


		data ds6d; set bi;
		fdatex=filedate1-365;
		format fdatex mmddyy10.;
		lfdate=fdatex;
		format lfdate mmddyy10.;
		run;



		proc sql; create table ds7 as select
		a.*, b.*
		from ds6d as a left join guid b
		on a.ticker=b.ticker and a.filedate1<=b.anndats<=intnx('month',a.filedate1,13)-1 and b.pdicity='ANN'
		order by gvkey, datadate;
		quit;

		proc sql; create table ds7l as select
		a.*, b.*
		from ds6d as a left join guid b
		on a.ticker=b.ticker and a.fdatex<=b.anndats<=intnx('month',a.fdatex,13)-1 and b.pdicity='ANN'
		order by gvkey, datadate;
		quit;


		data ds7a; set ds7;
		if anndats ne . ;
		run;
		data ds7al; set ds7l;
		if anndats ne . ;
		run;


		data dperm.ds7a_chris; set ds7a;
		run;

		proc sql; create table ds8 as select distinct
		gvkey, datadate,
						count(anndats) as n_guid
		from ds7a group by gvkey, datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table ds8l as select distinct
		gvkey, datadate,
						count(anndats) as n_guid
		from ds7al group by gvkey, datadate
		order by gvkey, datadate;
		quit;



		proc sql; create table ds9 as select
		a.*, b.n_guid
		from ds7 as a left join ds8 b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=ds9 out=ds9a ; by cik fyear  anndats descending n_guid;run;
		proc sort data=ds9a out=ds9b nodupkey; by cik fyear;run;

		proc sql; create table ds9bl as select
		a.*, b.n_guid as nguid1
		from ds9b as a left join ds8l b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=ds9bl out=ds9al ; by cik fyear anndats  descending n_guid;run;
		proc sort data=ds9al out=ds9xl nodupkey; by cik fyear;run;



		proc sql; create table ds10 as select
		a.*, b.sale as asale, b.at, b.csho,b.dltt,b.dlc,
			b.prcc_f, b.ceq, b.ib, b.seq,b.spi,b.sich,b.lt
		from ds9xl as a left join wrds.comp as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=ds10 out=ds10a ; by cik fyear descending asale;run;
		proc sort data=ds10a out=ds11 nodupkey; by cik fyear;run;

		proc sql; create table ds11a as select
		a.*, b.sale as asale1, b.at as at1, b.csho as csho1,b.dltt as dltt1,b.dlc as dlc1,
			b.prcc_f as prcc_f1, b.ceq as ceq1, b.ib as ib1, b.seq as seq1 ,b.spi as spi1,b.lt as lt1
		from ds11 as a left join wrds.comp as b
		on a.gvkey=b.gvkey and year(a.datadate)=year(b.datadate)+1
		order by gvkey, datadate;
		quit;


		proc sort data=ds11a out=ds11b ; by cik fyear descending asale1;run;
		proc sort data=ds11b out=ds11c nodupkey; by cik fyear;run;

		%ff48(data=ds11c,newvarname=industry,sic=sich,out=ds12);




		data ds12a; set ds12;
		roa=ib/at;
		roa1=ib1/at1;
		MVE = CSHO*PRCC_F;
		MVE1 = CSHO1*PRCC_F1;
		size = log(MVE);	
		size1 = log(MVE1);	
		MTB = ((CSHO*PRCC_F)+lt)/at ;
		MTB1 = ((CSHO1*PRCC_F1)+lt1)/at1 ;
		loss=0;
		loss1=0;
		special=spi/at;
		special1=spi1/at1;
		if ib lt 0 then loss=1;
		if ib1 lt 0 then loss1=1;
		leverage=(dltt+dlc)/at;
		leverage1=(dltt1+dlc1)/at1;
		*if aroa ne .;
		*if amtb ne .;
		run;

		proc sql; create table ds13a as select distinct
		industry, year,
						avg(roa) as indroa, avg(roa1) as indroa1
		from ds12a group by industry, year
		order by industry, year;
		quit;

		proc sql; create table ds14 as select
		a.*, b.indroa, b.indroa1
		from ds12a as a left join ds13a b
		on a.industry=b.industry and a.year=b.year
		order by gvkey, datadate;
		quit;

		data ds14a; set ds14;
		Adjroa=roa-indroa;
		Adjroa1=roa1-indroa1;
		run;


		data ds14c; set ds14a;
		if n_guid eq . then n_guid=0;
		if numest eq . then numest=0;
		if nguid1 eq . then nguid1=0;
		if numest1 eq . then numest1=0;
		 run;



		/*calculate std_ret*/
		data comp25; set ds14c;
		m5=datadate;
		month=month(datadate);
		day=day(datadate);
		year=(year(datadate))-1;
		lagm5=mdy(month,day,year);
		format lagm5 mmddyy10.;
		run;

		data dperm.comp25axx; set comp25;run;
		data comp25; set dperm.comp25axx;run;

		proc sql;
			create table		comp28
			as select 	a.*, std(b.ret) as std_ret,exp(sum(log(1+b.ret))) - exp(sum(log(1+b.vwretd))) as bhar
								
			from				comp25 as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and a.lagm5<=b.date<=a.m5
			group by			a.permno, a.datadate;
		quit;

		proc sort data=comp28 out=comp29 nodupkey; by cik fyear gvkey datadate tic sich permno  m5 lagm5;
		run;

		data comp29y; set comp29;
		m5=datadate;
		month=month(datadate);
		day=day(datadate);
		year=(year(datadate))-2;
		lagm52=mdy(month,day,year);
		format lagm52 mmddyy10.;
		run;

		proc sql;
			create table		comp29x
			as select 	a.*, std(b.ret) as std_ret1,exp(sum(log(1+b.ret))) - exp(sum(log(1+b.vwretd))) as bhar1
								
			from				comp29y as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and a.lagm52<=b.date<=a.lagm5
			group by			a.permno, a.datadate;
		quit;

		proc sort data=comp29x out=comp29z nodupkey; by cik fyear gvkey datadate tic sich permno  m5 lagm5;
		run;


		data comp29a; set comp29z;
		*delay=anndats-file_date;
		if n_guid eq . then n_guid=0;
		if numest eq . then numest=0;
		if nguid1 eq . then nguid1=0;
		if numest1 eq . then numest1=0;
		run;


		proc sort data=comp29a; by cik fyear;run;
		proc printto  log=junk; run;
		proc expand data=comp29a out=comp29b method=none;
		 
		convert dscore = Dscore1 / transform=(lag 1);
			
		convert year = L1Year / transform=(lag 1);
		convert fyear = L1fyear / transform=(lag 1);
		by cik;
		id fyear;
		run;	
		proc printto; run;


		data comp29c; set comp29b;
		dguid=n_guid-nguid1;
		dnum=numest-numest1;
		ddscore=dscore-dscore1;
		dsize=size-size1;
		dleverage=leverage-leverage1;
		dmtb=mtb-mtb1;
		dspecial=special-special1;
		dloss=loss-loss1;
		dstdret=std_ret-std_ret1;
		dbhar=bhar-bhar1;
		*ddelay1=delay-delay1;
		droa=adjroa-adjroa1;
		d=1;
		run;

		%WT(data=comp29c, out=comp29d, byvar=d, vars=n_guid  dscore size adjroa leverage special mtb nguid1  dscore1 size1 adjroa1 leverage1 special1 mtb1, type = W, pctl = 1 99, drop= N);

		data dperm.comp29kxxx; set comp29d;run;
		data comp29d; set dperm.comp29kxxx;run;

		data comp29e; set comp29d;
		if n_guid ne .;
		if numest ne .;
		if dscore ne .;
		if size ne .;
		if roa ne .;
		if leverage ne .;
		if mtb ne .;
		if special ne .;
		if loss ne .;
		if std_ret ne .;
		if bhar ne .;
		delay=anndats-file_date;
		dumG=0;
		if n_guid gt 0 then dumg=1;
		run;




		rsubmit;
		proc download data=crsp.stocknames out=linknames; run;
		endrsubmit;

		data dperm.linknames; set linknames;run;
		data linknames; set dperm.linknames;run;

		proc sql;
			create table disp1 as
			select distinct a.*, b.Permno
			from dperm.analyst_disp1 as a left join iclink as b
			on a.ticker=b.ticker ;
			quit;


		proc sql; create table comp30 as select
		a.*, b.*
		from comp29e as a left join disp1 b
		on a.permno=b.permno and year(a.datadate)= year(b.fpedats)
		order by gvkey, datadate;
		quit;

		proc sql; create table comp31 as select distinct
		gvkey, datadate,
						avg(dispersionforecast) as ana_disp
		from comp30 group by gvkey, datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table comp32 as select
		a.*, b.*
		from comp30 as a left join comp31 b
		on a.gvkey=b.gvkey and a.datadate= b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=comp32 out=comp33 nodupkey; by gvkey datadate;run;
		/*this measure of bidask not used in paper, updated measure is calculated later*/
		proc sql;
			create table		comp34
			as select 	a.*, avg((b.ask-b.bid)/a.prcc_f) as bidask, avg((abs(b.ret)/b.vol)*10) as illiquid
								
			from				comp33 as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and a.filedate1<=b.date<=intnx('weekday',a.filedate1,1)
			group by			a.permno, a.datadate;
		quit;

		proc sort data=comp34 out=comp35; by gvkey datadate descending bidask;
		run;
		proc sort data=comp35 out=comp36 nodupkey; by gvkey datadate;
		run;

		proc sql;
			create table		comp37
			as select 	a.*, avg((b.ask-b.bid)/a.prcc_f) as bidask1, avg((abs(b.ret)/b.vol)*10) as illiquid1
								
			from				comp36 as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and intnx('weekday',a.filedate1,-50)<=b.date<=intnx('weekday',a.filedate1,-5)
			group by			a.permno, a.datadate;
		quit;

		proc sort data=comp37 out=comp38; by gvkey datadate descending bidask1;
		run;
		proc sort data=comp38 out=comp39 nodupkey; by gvkey datadate;
		run;
		
		proc sql;
			create table		comp40
			as select 	a.*, b.DA_pmKothari, b.ABSDA_pmKothari
			from				comp39 as a left join  dperm.e_wins as b
			on				(a.gvkey=b.gvkey) and a.datadate=b.datadate
			order by			a.gvkey, a.datadate;
		quit;

		proc sort data=comp40 out=comp41; by gvkey datadate descending da_pmkothari;
		run;
		proc sort data=comp41 out=comp42 nodupkey; by gvkey datadate;
		run;

		data dperm.comp42zxxx; set comp42;
		dba=bidask-bidask1;
		dliq=illiquid-illiquid1;
		run;
		data comp42; set dperm.comp42zxxx;run;

		%WT(data=comp42, out=comp42x, byvar=fyear, vars=bhar std_ret, type = W, pctl = 1 99, drop= N);


		data comp42a; set comp42x;
		dscorex=dscore*-1;
		abdacc=abs(dacc);
		pmdacc=DA_pmKothari;
		abpmdacc=ABSDA_pmKothari;
		lnprc=log(prcc_f);
		pscorex=pscore*-1;
		run;


		proc rank data=comp42a out=comp42b groups=10;
		var  lnprc abpmdacc pmdacc dliq abdacc dacc numest dscorex pscorex bidask dba adjroa size  leverage mtb special loss std_ret bhar;
		ranks rlnprc rabpmdacc rpmdacc rdliq rabdacc rdacc rnumest rdscorex rpscorex rba rdba rroa rsize rleverage rmtb rspecial rloss rstd_ret rbhar;
		run;



		data comp42c; set comp42b;
		drlnprc=rlnprc*.1111111111111111;
		drabpmdacc=rabpmdacc*.1111111111111111;
		drpmdacc=rpmdacc*.1111111111111111;
		drdliq=rdliq*.1111111111111111;
		drabdacc=rabdacc*.1111111111111111;
		drdacc=rdacc*.1111111111111111;
		drnumest=rnumest*.1111111111111111;
		drdscorex=rdscorex*.1111111111111111;
		drba=rba*.1111111111111111;
		DRDBA=rdba*.1111111111111111;
		DRroa=rroa*.1111111111111111;
		DRsize=rsize*.1111111111111111;
		DRleverage=rleverage*.1111111111111111;
		DRmtb=rmtb*.1111111111111111;
		DRspecial=rspecial*.1111111111111111;
		DRloss=rloss*.1111111111111111;
		DRstd_ret=rstd_ret*.1111111111111111;
		DRbhar=rbhar*.1111111111111111;
		drpscorex=rpscorex/9;
		if fyear le 2016;
		run;

		data dperm.stata1zxxx; set comp42c;
		run;

		proc export data=dperm.stata1zxxx outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\stataxxx.dta" replace;
		run;

		/*get institutional ownership*/

		proc sql;
			create table		comp42d
			as select 	a.*, b.cshr
			from				comp42c as a left join  wrds.comp as b
			on				(a.gvkey=b.gvkey) and a.datadate=b.datadate
			order by			a.gvkey, a.datadate;
		quit;

		proc sort data=comp42d out=comp42e; by gvkey datadate descending cshr;
		run;
		proc sort data=comp42e out=comp42f nodupkey; by gvkey datadate;
		run;



		proc sql;
			create table		comp42f
			as select 	a.*, b.perc_inst_own as PIO
			from				comp42f as a left join  dperm.inst_own as b
			on				(a.gvkey=b.gvkey) and a.datadate=b.datadate
			order by			a.gvkey, a.datadate;
		quit;

		proc sort data=comp42f out=comp42g; by gvkey datadate descending cshr;
		run;
		proc sort data=comp42g out=comp42h nodupkey; by gvkey datadate;
		run;




		data comp42ha; set comp42h;
		lnown=log(cshr);
		if pio eq . then pio=0;
		run;
		%WT(data=comp42ha, out=comp42hi, byvar=fyear, vars=lnown pio, type = W, pctl = 1 99, drop= N);


		proc rank data=comp42hi out=comp42i groups=10;
		var lnown pio;
		ranks rlnown rpio;
		run;

		data comp42i; set comp42i;
		drlnown=rlnown*.1111111111111111;
		drpio=rpio*.1111111111111111;
		if drpio eq . then drpio=0;
		inc_ana=0;
		if numest > numest1 then inc_ana=1;
		inc_disc=0;
		if  n_guid > nguid1  then inc_disc=1;
		mpio=pio;
		if pio eq . then mpio=0;
		run;

		/*bring in fog data...This fog data is incomplete for our sample period so we
		recreate the scores manually for the entire sample*/
		data fog; set dperm.fogdata_pre04 dperm.fogdata_05_07 dperm.fogdata_08_09 dperm.fogdata_10_11;
		run;



		proc sql; create table comp43 as select
		a.*, b.fog
		from comp42i as a left join fog b
		on a.gvkey=b.gvkey2 and year(b.filedate)=year(a.filedate1)
		order by gvkey, datadate;
		quit;



		proc sort data=comp43 out=comp43a; by gvkey datadate descending fog;run;
		proc sort data=comp43a out=comp43b nodupkey; by gvkey datadate;run;

		proc rank data=comp43b out=comp44 groups=10;
		var fog ;
		ranks rfog;
		run;

		data comp44; set comp44;
		drfog=rfog/9;
		run;

		/*scaled by length*/

		proc sql; create table ds3 as select
		a.*, b.dscore*-1 as dscorexl
		from comp44 as a left join data.dscore_limited_length as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=ds3 out=ds3a; by cik datadate descending dscorexl;run;
		proc sort data=ds3a out=ds3b nodupkey; by cik datadate;run;

		proc rank data=ds3b out=ds3x groups=10;
		var dscorexl;
		ranks rdscorexl;
		run;

		data ds3y; set ds3x;
		drdscorexl=rdscorexl/9;
		run;


		/*Alt word choice*/


		proc sql; create table ds3za as select
		a.*, b.dscore*-1 as dscorexlz
		from ds3y as a left join data.dscore_limited_alt as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=ds3za out=ds3zaa; by cik datadate descending dscorexl;run;
		proc sort data=ds3zaa out=ds3zab nodupkey; by cik datadate;run;


		proc rank data=ds3zab out=ds3zax groups=10;
		var dscorexlz;
		ranks rdscorexlz;
		run;

		data ds3zay; set ds3zax;
		drdscorexlz=rdscorexlz/9;
		run;


		/*interact with those that disclosed and did 
		not disclose last period*/
		data D; set ds3zay;
		du=0;
		if nguid1 ge 1 then du=1;
		run;



		proc sql; create table prop1 as select
		a.*, b.xrd
		from d as a left join wrds.comp as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=prop1 out=prop1a ; by cik fyear descending xrd;run;
		proc sort data=prop1a out=prop2 nodupkey; by cik fyear;run;

		proc sql; create table prop2a as select
		a.*, (b.intan/b.at) as intan
		from prop2 as a left join wrds.comp as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=prop2a out=prop2b ; by cik fyear descending intan;run;
		proc sort data=prop2b out=prop2c nodupkey; by cik fyear;run;

		proc sql; create table prop2d as select
		a.*, (b.xad/b.sale) as ad
		from prop2c as a left join wrds.comp as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=prop2d out=prop2e ; by cik fyear descending ad;run;
		proc sort data=prop2e out=prop2f nodupkey; by cik fyear;run;

		data prop3; set prop2f;
		if xrd eq . then xrd=0;
		if intan eq . then intan=0;
		if ad eq . then ad=0;
		rd=xrd/asale;
		run;

		proc rank data=prop3 out=prop4 groups=10;
		var rd intan ad;
		ranks rrd rintan rad;
		run;

		data prop5; set prop4;
		drad=rad/9;
		drrd=rrd/9;
		drintan=rintan/9;
		run;


		proc sql; create table l1 as select
		a.*, b.excl,b.excld,b.exclp
		from prop5 as a left join dperm.non_gaap1 as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data lb; set l1;
		e=abs(excl);
		ed=abs(excld);
		ep=abs(exclp);
		if ed eq 0 then edum=0;
		*edum=0;
		if ed gt 0 then edum=1;
		run;




		/*10k length*/


		proc sql; create table t1 as select
		a.*, b.len
		from lb as a left join data.tenK_wordcounts as b
		on a.cik=b.cik and a.file_date=b.file_date
		order by gvkey, datadate;
		quit;

		proc sort data=t1 out=t2 nodupkey; by cik file_date ;run;

		proc rank data=t2 out=t3 groups=10;
		var len;
		ranks rlen;
		run;

		data t4; set t3;
		drlen=rlen/9;
		run;

		/*number of standards*/

		proc sql; create table x1 as select
		a.*, b.*
		from t4 as a left join data.n_stand as b
		on a.cik=b.cik and a.file_date=b.file_date
		order by gvkey, datadate;
		quit;


		proc sort data=x1 out=x2 nodupkey; by cik file_date ;run;


		proc rank data=x2 out=x3 groups=10;
		var n_stand;
		ranks rn;
		run;

		data x4; set x3;
		drn=rn/9;
		run;

		data dperm.final_dataxxx; set x4;run;
		data final; set dperm.final_dataxxx;
		d=0;
		if nguid1 gt 0 then d=1;
		run;

		proc sql; create table finalrr as select
		a.*, b.dscore*-1 as dscoreRR
		from final as a left join data.dscore_limited_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr; by cik datadate descending dscorerr;run;
		proc sort data=finalrr out=finalrr1 nodupkey; by cik datadate;run;
		/*main measure used in paper...all other alternative measures not used
		in paper provide similar inferences*/
		proc sql; create table finalrr2 as select
		a.*, b.dscore*-1 as dscoreRRL
		from finalrr1 as a left join data.dscore_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr2; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr2 out=finalrr3 nodupkey; by cik datadate;run;

		proc sql; create table finalrr4 as select
		a.*, b.dscore*-1 as dscorerrl_alt
		from finalrr3 as a left join data.dscore_alt_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr4; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr4 out=finalrr5 nodupkey; by cik datadate;run;

		proc sql; create table finalrr6 as select
		a.*, b.mgr_exclude
		from finalrr5 as a left join dperm.gee_data as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table finalrr7 as select
		a.*, b.dscore*-1 as dscorerrl_orth
		from finalrr6 as a left join data.dscore_limited_orthlength_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr7; by cik datadate descending dscorerrl_orth;run;
		proc sort data=finalrr7 out=finalrr8 nodupkey; by cik datadate;run;

		proc sql; create table finalrr9 as select
		a.*, b.dscore*-1 as dscorerrl_rbc
		from finalrr8 as a left join data.dscore_limited_orthrbc_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr9; by cik datadate descending dscorerrl_rbc;run;
		proc sort data=finalrr9 out=finalrr10 nodupkey; by cik datadate;run;

		PROC UNIVARIATE data=finalrr10 NOPRINT; by cik;
		VAR dscorerrl;
		OUTPUT OUT = univ mean=mean_dscore ; run;

		proc sql; create table finalrr10a as select
		a.*, b.mean_dscore
		from finalrr10 as a left join univ as b
		on a.cik=b.cik 
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10a; by cik datadate descending mean_dscore;run;
		proc sort data=finalrr10a out=finalrr10b nodupkey; by cik datadate;run;

		
		proc sql;create table finalrr10c as select 
		a.*, b.nonstick, b.decile_nonstick
		from finalrr10b as a left join data.nonstick as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10c; by cik datadate descending nonstick; run;
		proc sort data=finalrr10c out=finalrr10d nodupkey; by cik datadate ; run;
		
		proc sql;create table finalrr10de as select 
		a.*, b.nonstick as nonstickd, b.decile_nonstick as decile_nonstickd
		from finalrr10d as a left join data.nonstickd as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10de; by cik datadate descending nonstickd; run;
		proc sort data=finalrr10de out=finalrr10df nodupkey; by cik datadate ; run;
		
		proc sql; create table l3z as select
		a.*, b.excl as excl1,b.excld as excld1,b.exclp as exclp1
		from finalrr10df as a left join dperm.non_gaap as b
		on a.gvkey=b.gvkey and year(a.datadate)=year(b.datadate)+1
		order by gvkey, datadate;
		quit;

		proc sort data=l3z; by cik datadate descending exclp; run;
		proc sort data=l3z out=l3za nodupkey; by cik datadate ; run;

		data l4za; set l3za;
		e1=abs(excl1);
		ed1=abs(excld1);
		ep1=abs(exclp1);
		if ed1 eq 0 then edum1=0;
		*edum=0;
		if ed1 gt 0 then edum1=1;
		run;


		proc rank data=l4za out=frr4 groups=10;
		var dscorerr dscorerrl dscorerrl_alt dscorerrl_orth dscorerrl_rbc mean_dscore;
		ranks rdscorerr rdscorerrl rdscorerrl_alt rdscorerrl_orth rdscorerrl_rbc rmean_dscore;
		run;

		data final1; set frr4;
		drdscorerr=rdscorerr/9;
		drdscorerrl=rdscorerrl/9;
		drdscorerrl_alt=rdscorerrl_alt/9;
		drdscorerrl_rbc=rdscorerrl_rbc/9;
		drdscorerrl_orth=rdscorerrl_orth/9;
		drmean_dscore=rmean_dscore/9;
		run;



		proc export data=final1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxxxz.dta" replace;
		run;

		
		proc means data=final1 n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid numest dscorerrl size roa leverage mtb special loss std_ret bhar dba dliq abpmdacc mpio ;
		run;

		%corrps(dset=final1,vars= n_guid edum dscorex numest   size roa leverage mtb special loss std_ret bhar dba dliq abpmdacc pio);



		/*Columns 1 and 2 of panel c of table 2*/
		proc sort data=final1 out=fols3b;by industry;run;
		proc means data=fols3b  mean std ;by industry;
		var  dscorerrl ;
		run;



		/*Columns 3 of panel c of table 2*/
		proc sql; create table fols3b1 as select
		a.*, b.dscore*-1 as dscoreRRL_LAG
		from fols3b as a left join data.dscore_limited_length_rr1az as b
		on a.cik=b.cik and year(a.datadate)=year(b.datadate)+1
		order by gvkey, datadate;
		quit;


		proc sort data=fols3b1; by cik datadate descending dscorerrl_lag; run;
		proc sort data=fols3b1 out=fols3b2 nodupkey; by cik datadate ; run;

		proc sort data=fols3b2; by industry ; run;

		proc reg data=fols3b2;by industry;
		model dscorerrl= dscorerrl_lag;
		run;

		
		data fols3b3; set fols3b2;
		keep cik datadate gvkey;
		run;

		proc sql; create table fols3b4 as select
		a.*, b.*
		from fols3b3 as a left join data.components_of_dscore as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=fols3b4; by cik datadate descending delta_dscore; run;
		proc sort data=fols3b4 out=fols3b5 nodupkey; by cik datadate ; run;

		

		/*create histogram*/
		data hist; set data.nonstickd_hist;
		run;




		proc sql; create table fols3b6 as select
		a.*, b.*
		from fols3b5 as a left join hist as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=fols3b6; by cik datadate descending ns; run;
		proc sort data=fols3b6 out=fols3b7 nodupkey; by cik datadate ; run;


		data out; set fols3b7;
		keep cik datadate _TEMA001--_TEMA092 nonstick;
		run;

		/*this data is used to create figures 2a, 2b ,2c*/
		proc export 
		  data=out 
		  dbms=xlsx 
		  outfile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rel_imp_histogram_data.xlsx" 
		  replace;
		run;


		









		/* non-GAAP  PART OF PAPER*/


		
		data final1a; set final1;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		indyear=cat(industry,year)*1;
		decile_nonstickde=decile_nonstickd/9;
		if drn eq . then drn=0;
		run;
		data l2; set final1a;
		if edum ne .;
		run;

		proc means data=l2 n mean std p5 p25 median p75 p90 p95 p99;
		var edum excl excld;
		run;
		proc means data=final1a n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid edum dscorerrl numest size roa leverage mtb special loss std_ret bhar intan lit neg_surprise  dba dliq abpmdacc mpio ;
		run;
		%corrps(dset=final1a,vars= n_guid edum  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan lit neg_surprise dba dliq abpmdacc pio);



		data finalxza; set final1a;
		if year gt 1997;
		if drn eq . then drn=0;
		run;
		proc means data=finalxza n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid;
		run;

		/*table sent to chris for random sampling*/
		data forChris; set finalxza;
		if n_guid gt 0;
		keep n_guid cik fyear filedate1 datadate permno gvkey ticker tic cusip;
		run;

		proc sql; create table fc1 as select
		a.*, b.pdicity,b.measure,b.actdats,b.anndats,b.mod_date,b.acttims,b.anntims,b.mod_time,b.prd_yr,b.prd_mon,b.eefymo,b.val_1,b.val_2,b.mean_at_date
		from forchris as a left join ds7a as b
		on a.cik=b.cik and a.filedate1=b.filedate1
		order by gvkey, datadate;
		quit;

		proc sql; create table fc2 as select distinct
		gvkey, datadate,
						count(anndats) as bob
		from fc1 group by gvkey, datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table fc3 as select
		a.*, b.bob
		from forchris as a left join fc2 as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data tester5; set fc3;
		if bob ne n_guid;
		dum=1;
		run;

		proc sql; create table fc4 as select
		a.*, b.dum
		from fc1 as a left join tester5 as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data fc5; set fc4;
		if dum eq .;
		run;

		data dperm.forchris; set fc5;
		drop dum;
		rename n_guid=MGR_Forecast;
		run;



		/*this is just to get the correlation table to view.
		correlations presented in paper are calculated in the MD&A code*/
		data corrs; set final1a;
		if year le 1997 then n_guid=.;
		run;
		%corrps(dset=corrs,vars= n_guid edum  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan lit neg_surprise dba dliq  pio);



		proc export data=finalxza outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_mgr.dta" replace;
		run;
		/*THE below FILES CONTRIBUTE TO TABLES IN PAPER*/
		proc export data=final1a outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta" replace;
		run;

		/*updated bidask measure*/
		proc sql; create table bamz1 as select
		a.*, b.drdbax,b.dbax
		from final1a as a left join dperm.ba7 as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

				/*THE below FILES CONTRIBUTE TO TABLES IN PAPER*/
		proc export data=bamz1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\bamz1.dta" replace;
		run;



		proc sort data=final1 out=test nodupkey; by gvkey;run;

		/*playground*/
		data l2a; set l2;
		d93=0;d94=0;d95=0;d96=0;d97=0;d98=0;d99=0;d00=0;d01=0;d02=0;d03=0;d04=0;d05=0;d06=0;d07=0;d08=0;d09=0;d10=0;d11=0;d12=0;d13=0;d14=0;d15=0;d16=0;
		if year eq 1993 then d93=1;if year eq 1994 then d94=1;if year eq 1995 then d95=1;if year eq 1996 then d96=1;if year eq 1997 then d97=1;if year eq 1998 then d98=1;if year eq 1999 then d99=1;if year eq 2000 then d00=1;if year eq 2001 then d01=1;if year eq 2002 then d02=1;if year eq 2003 then d03=1;if year eq 2004 then d04=1;if year eq 2005 then d05=1;if year eq 2006 then d06=1;if year eq 2007 then d07=1;if year eq 2008 then d08=1;if year eq 2009 then d09=1;if year eq 2010 then d10=1;if year eq 2011 then d11=1;if year eq 2012 then d12=1;if year eq 2013 then d13=1;if year eq 2014 then d14=1;if year eq 2015 then d15=1;if year eq 2016 then d16=1;
		i1=0;i2=0;i3=0;i4=0;i5=0;i6=0;i7=0;i8=0;i9=0;i10=0;i11=0;i12=0;i13=0;i14=0;i15=0;i16=0;i17=0;i18=0;i19=0;i20=0;i21=0;i22=0;i23=0;i24=0;i25=0;i26=0;i27=0;i28=0;i29=0;i30=0;i31=0;i32=0;i33=0;i34=0;i35=0;i36=0;i37=0;i38=0;i39=0;i40=0;i41=0;i42=0;i43=0;i44=0;i45=0;i46=0;i47=0;
		if industry=1 then i1=1;if industry=2 then i2=1;if industry=3 then i3=1;if industry=4 then i4=1;if industry=5 then i5=1;if industry=6 then i6=1;if industry=7 then i7=1;if industry=8 then i8=1;if industry=9 then i9=1;if industry=10 then i10=1;if industry=11 then i11=1;if industry=12 then i12=1;if industry=13 then i13=1;if industry=14 then i14=1;if industry=15 then i15=1;if industry=16 then i16=1;if industry=17 then i17=1;if industry=18 then i18=1;if industry=19 then i19=1;if industry=20 then i20=1;if industry=21 then i21=1;if industry=22 then i22=1;if industry=23 then i23=1;if industry=24 then i24=1;if industry=25 then i25=1;if industry=26 then i26=1;if industry=27 then i27=1;if industry=28 then i28=1;if industry=29 then i29=1;if industry=30 then i30=1;if industry=31 then i31=1;if industry=32 then i32=1;if industry=33 then i33=1;if industry=34 then i34=1;if industry=35 then i35=1;if industry=36 then i36=1;if industry=37 then i37=1;if industry=38 then i38=1;if industry=39 then i39=1;if industry=40 then i40=1;if industry=41 then i41=1;if industry=42 then i42=1;if industry=43 then i43=1;if industry=44 then i44=1;if industry=45 then i45=1;if industry=46 then i46=1;if industry=47 then i47=1;
		run;

		 

		proc sql; create table l3 as select
		a.*, b.excl as excl1,b.excld as excld1,b.exclp as exclp1
		from l2a as a left join dperm.non_gaap as b
		on a.gvkey=b.gvkey and year(a.datadate)=year(b.datadate)+1
		order by gvkey, datadate;
		quit;

		proc sort data=l3 out=l3a nodupkey; by gvkey datadate;run;


		data l4; set l3a;
		e1=abs(excl1);
		ed1=abs(excld1);
		ep1=abs(exclp1);
		edum1=0;
		if ed1 gt 0 then edum1=1;
		run;

		data l4y; set l4;;
		d=0;
		if edum1=1 then d=1;
		run;

		






		
		proc sql; create table l1 as select
		a.*, b.dscore*-1 as dscorexla
		from final as a left join data.dscore_limited_lengtha as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=l1 ; by cik datadate descending dscorexla;run;
		proc sort data=l1 out=l1a nodupkey; by cik datadate;run;

		%WT(data=l1a, out=l1b, byvar=d, vars=dscorexla, type = W, pctl = 1 99, drop= N);


		proc rank data=l1b out=l1c groups=10;
		var dscorexla;
		ranks rdscorexla;
		run;

		data l2a; set l1c;
		drdscorexla=rdscorexla/9;
		run;




		/*eps v gps section*/
		data finalxzaa; set final1a;
		if year le 1997 then n_guid=.;
		if drn eq . then drn=0;
		run;


		data finalxzaj; set finalxzaa;
		drop pdicity measure curr units range_desc diff_code
		 act_std action guidance_code actdats anndats mod_date 
		acttims anntims mod_time prd_yr prd_mon eefymo val_1 val_2 mean_at_date usfirm;
		run;

		proc sql; create table ds7g as select
		a.*, b.*
		from finalxzaj as a left join guid b
		on a.ticker=b.ticker and a.filedate1<=b.anndats<=intnx('month',a.filedate1,13)-1 and b.pdicity='ANN'
		order by gvkey, datadate;
		quit;

		data ds7ag; set ds7g;
		if anndats ne . ;
		GPS=0;
		if measure="GPS" then GPS=1;

		run;

		/* This just shows me that 2002 is the first instance of GPS
		data guid1;set guid;
		year=year(anndats);
		run;
		proc sort data=guid1 nodupkey; by year measure ;
		run;*/


		proc sql; create table ds8g as select distinct
		gvkey, datadate,GPS,
						count(anndats) as n_guid
		from ds7ag group by gvkey, datadate, GPS
		order by gvkey, datadate;
		quit;

		data ds8gg; set ds8g;
		if gps=1 then n_guid_G=n_guid;
		if gps=0 then n_guid_E=n_guid;
		run;

		proc sql; create table ds9g as select
		a.*, b.n_guid_G
		from finalxzaa as a left join ds8gg b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data ds9ga; set ds9g;
		if n_guid_g=. then n_guid_g=0;
		run;

		proc sort data=ds9ga; by cik datadate descending n_guid_g;run;
		proc sort data=ds9ga out=ds9gb nodupkey; by cik datadate;run;


		proc sql; create table ds9gs as select
		a.*, b.n_guid_e
		from ds9gb as a left join ds8gg b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data ds9gas; set ds9gs;
		if n_guid_e=. then n_guid_e=0;
		run;

		proc sort data=ds9gas; by cik datadate descending n_guid_e;run;
		proc sort data=ds9gas out=ds9gbs nodupkey; by cik datadate;run;

		data ds7ags; set ds7g;
		if measure="EPS";
		run;



		proc sql; create table ds8gs as select distinct
		gvkey, datadate,
						count(anndats) as n_guid
		from ds7ags group by gvkey, datadate
		order by gvkey, datadate;
		quit;



		data ds8ggs; set ds8gs;
		n_guid_E_only=n_guid;
		run;

		proc sql; create table ds9gg as select
		a.*, b.n_guid_e_only
		from ds9gbs as a left join ds8ggs b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data ds9gag; set ds9gg;
		if n_guid_e_only=. then n_guid_e_only=0;
		run;

		proc sort data=ds9gag; by cik datadate descending n_guid_e_only;run;
		proc sort data=ds9gag out=ds9gbg nodupkey; by cik datadate;run;


		data EPSvGPS; set ds9gbg;
		if year le 1997 then n_guid_e=.;
		if year le 1997 then n_guid_g=.;
		if year le 1997 then n_guid_e_only=.;
		d=1;
		run;




		%WT(data=EPSvGPS, out=EPSvGPS1, byvar=d, vars=n_guid_e n_guid_e_only n_guid_g  , type = W, pctl = 1 99, drop= N);


		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=EPSvGPS1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\EvGx.dta" replace;
		run;



		data epsvgps2; set epsvgps1;
		if year(filedate1) ge 2002;
		d_g=0;
		d_e=0;
		if n_guid_e gt 0 then d_e=1;
		if n_guid_g gt 0 then d_g=1;
		run;
		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=EPSvGPS2 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\EvG1.dta" replace;
		run;



		data view; set epsvgps1;
		keep gvkey datadate n_guid n_guid_e n_guid_g n_guid_e_only;
		run;


		/*mgr_forecast = restrict in sample of non-gaap issuers based on IBES*/
		data h1; set EPSvGPS1;
		if year le 1997 then n_guid=.;
		run;

		data h1a; set h1;
		if edum=1;
		run;



		data h1c; set h1;
		if edum=0;
		run;


		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=h1a outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\h1a.dta" replace;
		run;



		proc export data=h1c outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\h1c.dta" replace;
		run;

		/*recognition only standards*/
		proc sql; create table recogn_only as select
		a.*, b.dscore*-1 as dscorerrl_ronly
		from EPSvGPS1 as a left join data.dscore_limited_recogn_only as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=recogn_only; by cik datadate descending dscorerrl_ronly;run;
		proc sort data=recogn_only out=recogn_only1 nodupkey; by cik datadate;run;


		proc rank data=recogn_only1 out=recogn_only2 groups=10;
		var dscorerrl_ronly;
		ranks rdscorerrl_ronly;
		run;

		data recogn_only3; set recogn_only2;
		drdscorerrl_ronly=dscorerrl_ronly/9;
		run;

		data dperm.recogn_only3; set recogn_only3;
		run;

		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=recogn_only3 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\ronly.dta" replace;
		run;


		/*update bidask measure*/
		proc sql;
			create table		ba1
			as select 	a.*, avg((b.ask-b.bid)/(abs(b.prc))) as bidaskx
								
			from				EPSvGPS1 as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and a.filedate1<=b.date<=intnx('weekday',a.filedate1,1)
			group by			a.permno, a.datadate;
		quit;

		proc sort data=ba1; by gvkey datadate descending bidaskx;
		run;
		proc sort data=ba1 out=ba2 nodupkey; by gvkey datadate;
		run;

		
		proc sql;
			create table		ba3
			as select 	a.*, avg((b.ask-b.bid)/(abs(b.prc))) as bidaskx1
								
			from				ba2 as a left join  wrds.crsp as b
			on				(a.permno=b.permno) and intnx('weekday',a.filedate1,-50)<=b.date<=intnx('weekday',a.filedate1,-5)
			group by			a.permno, a.datadate;
		quit;

		proc sort data=ba3; by gvkey datadate descending bidaskx1;
		run;
		proc sort data=ba3 out=ba4 nodupkey; by gvkey datadate;
		run;
		

		data ba5; set ba4;
		dbax=bidaskx-bidaskx1;
		d=1;
		run;




		proc rank data=ba5 out=ba6 groups=10;
		var   dbax;
		ranks  rdbax ;
		run;



		data ba7; set ba6;
		drdbax=rdbax*.1111111111111111;
		run;

		data dperm.ba7; set ba7;
		run;

		%WT(data=ba7, out=ba8, byvar=d, vars=dbax, type = W, pctl = 1 99, drop= N);

		/*this goes into the descriptives*/
		proc means data=ba8 n mean std p5 q1 median q3 p90 p95 p99;
		var  dbax ;
		run;

		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=ba7 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rbax.dta" replace;
		run;




		/*BEGIN:i.create non_gaap1*/
			*Basic Initializations;
			%let wrds = wrds.wharton.upenn.edu 4016;
			options comamid=TCP remote=wrds;
			signon username=_prompt_;
			Libname rwork slibref=work server=wrds;


			/*ASSIGN LIBRARIES*/
			libname perm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets';
			libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';libname wrds 'C:\Users\spencer\OneDrive - University of Arizona\U of A\WRDS\WRDS';
			libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
			%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";



			data comp; set wrds.comp;
			keep gvkey datadate cusip tic epsfx epspx;
			run;

			rsubmit;
			proc download data=ibes.id out=iid;run;
			proc download data=crsp.stocknames out=cid;run;
			endrsubmit;
			%ICLINK (IBESID=iID,CRSPID=cid,OUTSET=ICLINK);


			data link; set byu.gvkey_permno_link2017nov30;
			cik1=cik/1;
			run;

			proc sql; create table comp1 as select
			a.*, b.*
			from comp as a left join link b
			on a.gvkey=b.gvkey and a.datadate=b.datadate
			order by gvkey, datadate;
			quit;

			proc sort data=comp1 out=comp2 nodupkey;by gvkey datadate;run;

			data actu; set perm.ibes_actu;
			run;

			proc sort data=perm.ibes_detu out=detu; by ticker fpedats pdf descending anndats;run;
			proc sort data=detu out=detu1 nodupkey; by ticker fpedats pdf ;run;


			proc sql; create table actu1 as select
			a.*, b.pdf, b.value as forecast_value
			from actu as a left join detu1 as b
			on a.ticker=b.ticker and year(a.pends)=year(b.fpedats) 
			order by ticker, fpedats;
			quit;

			data actu2; set actu1;
			if value ne .;
			diff=value-forecast_value;
			run;


			/*it is unclear if the actual value is diluted or undiluted
			so I bring in forecasts that have diluted and undiluted flags, I
			use the latest forecast of diluted and undiluted and compare how
			closely they come to the actual eps value reported, I assign diluted or 
			undiluted flags based on if the closest forecast is diluted or undiluted
			*/
			proc sql; create table actu3 as select
			a.*, b.diff as diff_other, b.pdf as pdf_other
			from actu2 as a left join actu2 as b
			on a.ticker=b.ticker and year(a.pends)=year(b.pends) and a.pdf<>b.pdf and a.pdf ne ""
			order by ticker, pends;
			quit;


			data actu4; set actu3;
			If pdf ne "" and diff_other=. then pdf_final=pdf;
			if pdf ne "" and diff_other ne . and abs(diff) ge abs(diff_other) then pdf_final=pdf_other;
			if pdf ne "" and diff_other ne . and abs(diff) lt abs(diff_other) then pdf_final=pdf;
			run;

			proc sort data=actu4 out=actu5 nodupkey;by ticker pends;run;

			proc sql;
			create table actu6 as
			select distinct a.*, b.PERMNO
			from actu5 as a join iclink as b
			on a.ticker = b.ticker ;
			quit;






			proc sql; create table comp3 as select
			a.*, b.value as NG_EPS, b.pdf_final
			from comp2 as a left join actu6 as b
			on a.permno eq b.permno and a.datadate-7<=b.pends<=a.datadate+7
			order by gvkey, datadate;
			quit;



			/*excl drops firms without the diluted or undiluted flags
			excld assumes that firms without the flag used diluted and
			exclp assumes that firms without the flag used undiluted

			excld is used in the paper but results remain consistent if
			exclp is used to determine non-gaap issuance*/
			data comp4; set comp3;
			if ng_eps ne .;
			if pdf_final="P" then excl=ng_eps-epspx;
			if pdf_final="D" then excl=ng_eps-epsfx;
			if pdf_final="P" then excld=ng_eps-epspx;
			if pdf_final="D" then excld=ng_eps-epsfx;
			if pdf_final="" then excld=ng_eps-epsfx;
			if pdf_final="P" then exclp=ng_eps-epspx;
			if pdf_final="D" then exclp=ng_eps-epsfx;
			if pdf_final="" then exclp=ng_eps-epspx;
			run;

			/*17646 of 128399 end up needing to be classified iwthout pdf_final*/
			data testh; set comp4;
			if (excl ne excld or excl ne exclp or excld ne exclp);
			run;
			/*3724 of 128399 have different values of excld and exclp where
			data is available to compare*/
			data testh1; set testh;
			if excld ne exclp;
			if excld ne . and exclp ne .;
			run;
			/* of these 3724 the diluted compustat value (epsfx) is equal to
			ng_eps for 1689, undiluted (epspx) is equal to ng_eps for 356 and 1679
			are neither results are the same using excld or exclp*/
			data testh2; set testh1;
			if epsfx=ng_eps then d=1;
			if epspx=ng_eps then d=0;
			run;



			data perm.non_gaap1; set comp4;
			run;


		/*END: i.create non_gaap1*/
		/*BEGIN: ii.create inst_own*/
							*********************************************************************************
					*							INITIATION SECTION		-Code borrowed from SAS CAMP* 						*
					*********************************************************************************;

			* Create a library where you will store all of your data (8 characters or less);
			libname saved "C:\Users\spencer\Documents\U of A\Projects\Mei Cheng\Data";
			libname wrds 'C:\Users\spencer\Documents\U of A\WRDS\WRDS';

			* Set the SAS system and macro options;
				options errors=3 ls=78 msglevel=i nocenter nodate noovp ps=max source;
				options mprint symbolgen;

			* Open MACROS file;
			* Macros provide a shortcut to running extensive code;
			* They allow the user to enter a single line of code versus having to run multiple lines;
			%include "C:\Users\spencer\Documents\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";

			* WRDS Login Code;
			%let wrds = wrds.wharton.upenn.edu 4016; 
			options comamid=TCP remote=WRDS;
			signon username=_prompt_;
			Libname rwork slibref=work server=wrds;
											
					*****************************************************************************
					*							AZ DATAGUIDE PROGRAM							*
					*				CH. 5 - TFN INSTITUTIONAL OWNERSHIP DATA					*
					*****************************************************************************;
			/*obtain data*/

			rsubmit;
				data SAMPLE_DATA;
					set	comp.funda
					(where = ( fyear GE 1983)
					keep = tic fyear gvkey datadate csho indfmt datafmt popsrc consol);
					if indfmt='INDL';
					if datafmt='STD';
					if popsrc='D';
					if consol='C';
					drop indfmt datafmt popsrc consol;
				run;

				proc sql;
					create table SAMPLE_DATA2
					as select	a.*, b.*
					from		SAMPLE_DATA as a
					left join	TFN.S34 as b
					on			a.tic=b.ticker and a.datadate=b.rdate;
				quit;

				proc sort
					data	= SAMPLE_DATA2;
					by		datadate csho;
				run; 

			proc sort data=sample_data2; by gvkey datadate;run;

				proc means
					data	= SAMPLE_DATA2
					noprint;
					by		 gvkey datadate csho;
					output	out = SAMPLE_DATASET sum(shares) = /autoname;
				run; 

				proc download
					data = SAMPLE_DATASET;
				run; quit;
			endrsubmit;

			/*create IO*/

			data	Ex2_dataset;
				set		SAMPLE_DATASET;
				PERC_INST_OWN = shares_Sum / (csho*1000000);
			run; quit;

				
			data saved.inst_own; set ex2_dataset;
			if perc_inst_own ne .;run;

			proc rank data=ex2_dataset out=e3 groups=10; 
			var perc_inst_own;
			ranks rankIO;
			run;

			data saved.inst_own; set e3;
			if perc_inst_own ne .;run;

		/*END: ii.create inst_own*/

	/*END: a.Main_tests*/
	/*BEGIN:b. Main_robustness*/


			*Basic Initializations;
		%let wrds = wrds.wharton.upenn.edu 4016;
		options comamid=TCP remote=wrds;
		signon username=_prompt_;
		Libname rwork slibref=work server=wrds;


		/*ASSIGN LIBRARIES*/
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
		libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";

		data dperm.final_dataxxx_rob; set x4;run;
		data final; set dperm.final_dataxxx_rob;
		d=0;
		if nguid1 gt 0 then d=1;
		run;

		proc sql; create table finalrr as select
		a.*, b.dscore*-1 as dscoreRR
		from final as a left join data.dscore_limited_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr; by cik datadate descending dscorerr;run;
		proc sort data=finalrr out=finalrr1 nodupkey; by cik datadate;run;

		proc sql; create table finalrr2 as select
		a.*, b.dscore*-1 as dscoreRRL
		from finalrr1 as a left join data.dscore_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr2; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr2 out=finalrr3 nodupkey; by cik datadate;run;

		proc sql; create table finalrr4 as select
		a.*, b.dscore*-1 as dscorerrl_alt
		from finalrr3 as a left join data.dscore_alt_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr4; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr4 out=finalrr5 nodupkey; by cik datadate;run;

		proc sql; create table finalrr6 as select
		a.*, b.mgr_exclude
		from finalrr5 as a left join dperm.gee_data as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table finalrr7 as select
		a.*, b.dscore*-1 as dscorerrl_orth
		from finalrr6 as a left join data.dscore_limited_orthlength_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr7; by cik datadate descending dscorerrl_orth;run;
		proc sort data=finalrr7 out=finalrr8 nodupkey; by cik datadate;run;

		proc sql; create table finalrr9 as select
		a.*, b.dscore*-1 as dscorerrl_rbc
		from finalrr8 as a left join data.dscore_limited_orthrbc_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr9; by cik datadate descending dscorerrl_rbc;run;
		proc sort data=finalrr9 out=finalrr10 nodupkey; by cik datadate;run;

		PROC UNIVARIATE data=finalrr10 NOPRINT; by cik;
		VAR dscorerrl;
		OUTPUT OUT = univ mean=mean_dscore ; run;

		proc sql; create table finalrr10a as select
		a.*, b.mean_dscore
		from finalrr10 as a left join univ as b
		on a.cik=b.cik 
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10a; by cik datadate descending mean_dscore;run;
		proc sort data=finalrr10a out=finalrr10b nodupkey; by cik datadate;run;


		proc sql;create table finalrr10c as select 
		a.*, b.nonstick, b.decile_nonstick
		from finalrr10b as a left join data.nonstick as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10c; by cik datadate descending nonstick; run;
		proc sort data=finalrr10c out=finalrr10d nodupkey; by cik datadate ; run;

		proc sql;create table finalrr10de as select 
		a.*, b.nonstick as nonstickd, b.decile_nonstick as decile_nonstickd
		from finalrr10d as a left join data.nonstickd as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10de; by cik datadate descending nonstickd; run;
		proc sort data=finalrr10de out=finalrr10df nodupkey; by cik datadate ; run;

		proc sql; create table l3z as select
		a.*, b.excl as excl1,b.excld as excld1,b.exclp as exclp1
		from finalrr10df as a left join dperm.non_gaap as b
		on a.gvkey=b.gvkey and year(a.datadate)=year(b.datadate)+1
		order by gvkey, datadate;
		quit;

		proc sort data=l3z; by cik datadate descending exclp; run;
		proc sort data=l3z out=l3za nodupkey; by cik datadate ; run;

		data l4za; set l3za;
		e1=abs(excl1);
		ed1=abs(excld1);
		ep1=abs(exclp1);
		if ed1 eq 0 then edum1=0;
		*edum=0;
		if ed1 gt 0 then edum1=1;
		run;


		proc rank data=l4za out=frr4 groups=10;
		var dscorerr dscorerrl dscorerrl_alt dscorerrl_orth dscorerrl_rbc mean_dscore;
		ranks rdscorerr rdscorerrl rdscorerrl_alt rdscorerrl_orth rdscorerrl_rbc rmean_dscore;
		run;

		data final1; set frr4;
		drdscorerr=rdscorerr/9;
		drdscorerrl=rdscorerrl/9;
		drdscorerrl_alt=rdscorerrl_alt/9;
		drdscorerrl_rbc=rdscorerrl_rbc/9;
		drdscorerrl_orth=rdscorerrl_orth/9;
		drmean_dscore=rmean_dscore/9;
		run;



		proc export data=final1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxxxz.dta" replace;
		run;


		proc means data=final1 n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid numest dscorerrl size roa leverage mtb special loss std_ret bhar dba dliq abpmdacc mpio ;
		run;



		%corrps(dset=final1,vars= n_guid edum dscorex numest   size roa leverage mtb special loss std_ret bhar dba dliq abpmdacc pio);


		/*MAIN MGRFORECAST RESULTS*/
		/*SEE STATA CODE*/


		
		data final1a; set final1;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		indyear=cat(industry,year)*1;
		decile_nonstickde=decile_nonstickd/9;
		run;
		data l2; set final1a;
		if edum ne .;
		run;

		data finalxza; set final1a;
		if year gt 1997;
		run;







		/*bring in FOG measure for entire sample*/

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\readability_10k_10k.xlsx'
		DBMS = xlsx OUT = FOGGGG;run;


		data dx; set data.tenk_wordcounts;run;

		proc sql; create table finalz as select
		a.*, b.fog
		from dx as a left join FOGGGG as b
		on a.accession_id=b.accession_id 
		order by accession_id;
		quit;

		proc sql; create table finalz1 as select
		a.*, b.fog as MUS_FOG
		from final1a as a left join finalz as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalz1; by cik datadate descending mus_fog;run;
		proc sort data=finalz1 out=finalz2 nodupkey; by cik datadate;run;

		proc corr data=finalz2;
		var fog mus_fog;
		run;


		proc rank data=finalz2 out=finalz3 groups=10;
		var mus_fog ;
		ranks rfogm;
		run;

		data finalz4; set finalz3;
		drfog_m=rfogm/9;
		run;

		data dperm.finalz4_fog1; set finalz4;
		run;


		data finalxza4; set finalz4;
		if year gt 1997 ;
		run;


		proc import out=epps datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta";
		run;

		proc sql; create table epps1 as select
		a.*, b.n_guid_g,b.n_guid_e,b.n_guid_e_only
		from finalxza4 as a left join epps as b
		on a.cik=b.cik and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;


		/*These tables contribute to the paper via stata*/
		proc export data=epps1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxzabcdefzj_rob_fog_mgr1.dta" replace;
		run;
		proc export data=finalz4 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxzabcdefzj_rob_fog.dta" replace;
		run;



	/*END:b. Main_robustness*/
	/*BEGIN: c. MD&A Tests*/
		
		/*1. Obtain necessary data */
		libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		libname ds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\Dealscan';
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";
		libname mda 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data';

		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data\output_mda_std_hits_no_standard_names.xlsx" out=sy dbms=xlsx replace;
		    getnames=yes;
		run;


		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Debt Contracts\Data\import_std_year.xlsx" out=styear dbms=xlsx replace;
		    getnames=yes;
		run;

		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data\fog_7.xlsx" out=fog dbms=xlsx replace;
		    getnames=yes;
		run;

		proc sql; create table sya as select
			a.*, b.*
			from sy as a left join fog as b			/*The "as" statements are optional*/
			on a.accession=b.accession_id 					/*you can set multiple match conditions using 'AND'*/
			order by cik,fyenddt;
			quit;

		proc sort data=sya ; by cik fyenddt accession descending fog ;run;
		proc sort data=sya out=syb nodupkey; by cik fyenddt accession;run;

		data styear1; set styear;
		keep  abs94_03  apb16 apb17 year fas141 fas123 fas123r apb30 fas121 fas144 apb17 fas142 fas146 apb26 fas76 fas125 fas140;
		run;

		data sy1; set syb;
		rename word_count=mword_count;
		rename fog=mfog;
		run;
		data sy1; set sy1;
		keep cik fyenddt accession len mfog mword_count unique_word_count eitf94_03  apb16 apb17 year fas141 fas123 fas123r apb30 fas121 fas144 apb17 fas142 fas146 apb26 fas76 fas125 fas140;
		run;

		data ri; set data.rel_imp;
		gvkeyn=gvkey*1;
		run;

		proc sql; create table acc4b as select
			a.*, b.ri_fas123,b.ri_fas123r,b.ri_apb30, b.ri_apb16, b.ri_apb17,b.ri_fas140,b.ri_apb26,
		b.ri_fas146,b.ri_eitf94_03,b.ri_fas141,b.ri_fas142,b.ri_fas144,b.ri_fas142,b.ri_fas125,b.ri_fas121					/*These are the variables you want to keep*/
			from sy1 as a left join ri as b			/*The "as" statements are optional*/
			on a.cik=b.cik and a.fyenddt=b.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4b ; by cik fyenddt descending ri_apb30 ;run;
		proc sort data=acc4b out=acc4 nodupkey; by cik fyenddt ;run;



		data final; set dperm.final_dataxxx;
		d=0;
		if nguid1 gt 0 then d=1;
		run;

		proc sql; create table finalrr as select
		a.*, b.dscore*-1 as dscoreRR
		from final as a left join data.dscore_limited_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr; by cik datadate descending dscorerr;run;
		proc sort data=finalrr out=finalrr1 nodupkey; by cik datadate;run;

		proc sql; create table finalrr2 as select
		a.*, b.dscore*-1 as dscoreRRL
		from finalrr1 as a left join data.dscore_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr2; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr2 out=finalrr3 nodupkey; by cik datadate;run;

		proc sql; create table finalrr4 as select
		a.*, b.dscore*-1 as dscorerrl_alt
		from finalrr3 as a left join data.dscore_alt_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr4; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr4 out=finalrr5 nodupkey; by cik datadate;run;

		proc sql; create table finalrr6 as select
		a.*, b.mgr_exclude
		from finalrr5 as a left join dperm.gee_data as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table finalrr7 as select
		a.*, b.dscore*-1 as dscorerrl_orth
		from finalrr6 as a left join data.dscore_limited_orthlength_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr7; by cik datadate descending dscorerrl_orth;run;
		proc sort data=finalrr7 out=finalrr8 nodupkey; by cik datadate;run;

		proc sql; create table finalrr9 as select
		a.*, b.dscore*-1 as dscorerrl_rbc
		from finalrr8 as a left join data.dscore_limited_orthrbc_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr9; by cik datadate descending dscorerrl_rbc;run;
		proc sort data=finalrr9 out=finalrr10 nodupkey; by cik datadate;run;

		PROC UNIVARIATE data=finalrr10 NOPRINT; by cik;
		VAR dscorerrl;
		OUTPUT OUT = univ mean=mean_dscore ; run;

		proc sql; create table finalrr10a as select
		a.*, b.mean_dscore
		from finalrr10 as a left join univ as b
		on a.cik=b.cik 
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10a; by cik datadate descending mean_dscore;run;
		proc sort data=finalrr10a out=finalrr10b nodupkey; by cik datadate;run;

		proc sql;create table finalrr10c as select 
		a.*, b.nonstick, b.decile_nonstick
		from finalrr10b as a left join data.nonstick as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10c; by cik datadate descending nonstick; run;
		proc sort data=finalrr10c out=finalrr10d nodupkey; by cik datadate ; run;

		proc sql;create table finalrr10de as select 
		a.*, b.nonstick as nonstickd, b.decile_nonstick as decile_nonstickd
		from finalrr10d as a left join data.nonstickd as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10de; by cik datadate descending nonstick; run;
		proc sort data=finalrr10de out=finalrr10df nodupkey; by cik datadate ; run;



		proc rank data=finalrr10df out=frr4 groups=10;
		var dscorerr dscorerrl dscorerrl_alt dscorerrl_orth dscorerrl_rbc mean_dscore ;
		ranks rdscorerr rdscorerrl rdscorerrl_alt rdscorerrl_orth rdscorerrl_rbc rmean_dscore ;
		run;

		data final1; set frr4;
		drdscorerr=rdscorerr/9;
		drdscorerrl=rdscorerrl/9;
		drdscorerrl_alt=rdscorerrl_alt/9;
		drdscorerrl_rbc=rdscorerrl_rbc/9;
		drdscorerrl_orth=rdscorerrl_orth/9;
		drmean_dscore=rmean_dscore/9;
		decile_nonstickde=decile_nonstickd/9;
		drfogm=rfogm/9;
		run;

		proc sql; create table acc4d as select
			a.*, b.*,b.len as mlen
		from acc4 as a left join final1 as b			/*The "as" statements are optional*/
			on a.cik=b.cik and a.fyenddt=b.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4d ; by cik fyenddt descending gvkey ;run;
		proc sort data=acc4d out=acc4e nodupkey; by cik fyenddt ;run;


		data acc4f; set acc4e;
		llen=log(len);
		llenK=log(mlen);
		run; 


		%WT(data=acc4f, out=acc4fa, byvar=d, vars=  len llen mfog, type = W, pctl = 1 99, drop= N);


		/*just to get descriptives*/
		proc sql; create table acc4dx as select
			a.*, b.*,b.len as blen
		from final1 as a left join acc4 as b			/*The "as" statements are optional*/
			on a.cik=b.cik and b.fyenddt=a.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4dx ; by cik datadate descending blen ;run;
		proc sort data=acc4dx out=acc4ex nodupkey; by cik datadate ;run;


		%WT(data=acc4ex, out=acc4fax, byvar=none, vars=  blen  mfog, type = W, pctl = 1 99, drop= N);

		data acc4fax1; set acc4fax;
		if mfog eq . then blen=.;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		if year le 1997 then n_guid=.;
		run;



		%corrps(dset=acc4fax1,vars= n_guid edum blen mfog  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan  lit neg_surprise  dba dliq  pio);


		proc import out=epps datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta";
		run;

		proc sql; create table epps1a as select
		a.*, b.n_guid_g,b.n_guid_e,b.n_guid_e_only
		from acc4fax1 as a left join epps as b
		on a.cik=b.cik and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;

		/*THIS CONTRIBUTES DESCRIPTIVES TO THE PAPER*/
		proc means data=epps1a n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid_e edum blen mfog dscorerrl numest size roa leverage mtb special loss std_ret bhar lit neg_surprise intan   dba dliq  mpio ;
		run;

		%corrps(dset=epps1a,vars= n_guid_E edum blen mfog  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan  lit neg_surprise  dba dliq  pio);


		/***end of descriptives***/



		proc rank data=acc4fa out=a1 groups=10;
		var mlen len mfog;
		ranks rmlen rlen rmfog;
		run;

		data a2; set a1;
		drlenK=rmlen/9;
		drmfog=rmfog/9;
		drlen=rlen/9;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		indyear=cat(industry,year)*1;
		run;






		/*export cross-sections of above tests*/
		/*This contributes to the paper via stata*/
		proc export data=a2 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj.dta" replace;
		run;

		
		/*recognition only standards*/
		proc sql; create table recogn_onlyx as select
		a.*, b.drdscorerrl_ronly
		from a2 as a left join dperm.recogn_only3 as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=recogn_onlyx; by cik fyenddt descending drdscorerrl_ronly;run;
		proc sort data=recogn_onlyx out=recogn_onlyx1 nodupkey; by cik fyenddt;run;

		data a3b; set recogn_onlyx1;
		if drdscorerrl_ronly ne .;
		run;

		/*this table contributes via stata code*/
		proc export data=a3b outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\ronly1.dta" replace;
		run;

		/*updated bidask measure*/
		proc sql; create table bam1 as select
		a.*, b.drdbax,b.dbax
		from a2 as a left join dperm.ba7 as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;
		
		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA CODE*/
		proc export data=bam1 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rbax1.dta" replace;
		run;



		/*descriptives with updated bidask measure*/

		proc sql; create table bamx1 as select
		a.*, b.drdbax,b.dbax
		from epps1a as a left join dperm.ba7 as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		data bamx1; set bamx1;
		d=1;
		run;

		%WT(data=bamx1, out=bamx2, byvar=d, vars=dbax, type = W, pctl = 1 99, drop= N);


		%corrps(dset=bamx2,vars= n_guid_E edum blen mfog  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan  lit neg_surprise  dbax dliq  pio);


		/****************************************
		DIFF IN DIFF SECTION BELOW
		******************************************/



		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\standard changes.xlsx'
		DBMS = xlsx OUT = stda;run;






		proc sql; create table pf1 as select
		a.*, b.*
		from a2 as a left join stda b
		on a.cik ne .
		order by year, gvkey;
		quit;

		proc sql; create table pf1a as select
		a.*, b.r_fas146 as mi_fas146 ,b.r_fas141 as mi_fas141, b.r_fas142 as mi_fas142,
		b.r_fas123r as mi_fas123r, b.r_apb16 as mi_apb16,b.r_apb17 as mi_apb17,
		b.r_fas123 as mi_fas123, b.r_eitf94_03 as mi_eitf94_03
		from pf1 as a left join data.rel_imp_mda_nomin as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=pf1a; by cik datadate descending mi_fas146;run;
		proc sort data=pf1a out=pf1b nodupkey; by cik datadate;run;


		data comp; set wrds.comp;
		cikn=cik*1;
		run;


		proc sql; create table pf2c as select
		a.*, b.aqc
		from pf1b as a left join comp b
		on a.cik eq b.cikn and a.f141p=b.fyear
		order by cik,fyear;
		quit;

		proc sort data=pf2c out=pf2d; by cik fyear descending aqc;
		run;
		proc sort data=pf2d out=pf2e nodupkey; by cik fyear;run;


		proc sql; create table pf2f as select
		a.*, b.gdwl
		from pf2e as a left join comp b
		on a.cik eq b.cikn and a.f142p=b.fyear
		order by cik,fyear;
		quit;

		proc sort data=pf2f out=pf2g; by cik fyear descending gdwl;
		run;
		proc sort data=pf2g out=pf2h nodupkey; by cik fyear;run;

		proc sql; create table pf2i as select
		a.*, b.rceps
		from pf2h as a left join comp b
		on a.cik eq b.cikn and a.f146p=b.fyear
		order by cik,fyear;
		quit;

		proc sort data=pf2i out=pf2j; by cik fyear descending rceps;
		run;
		proc sort data=pf2j out=pf2k nodupkey; by cik fyear;run;



		proc sql; create table pf2l as select
		a.*, b.stkco
		from pf2k as a left join comp b
		on a.cik eq b.cikn and a.f123rp=b.fyear
		order by cik,fyear;
		quit;

		proc sort data=pf2l out=pf2m; by cik fyear descending stkco;
		run;
		proc sort data=pf2m out=pf2n nodupkey; by cik fyear;run;




		data pf2na; set pf2n;
		if rceps eq . then rceps=0;
		if stkco eq . then stkco=0;
		if aqc eq . then aqc=0;
		if gdwl eq . then gdwl=0;
		rceps1=abs(rceps);
		stkco1=abs(stkco);
		aqc1=abs(aqc);
		gdwl1=abs(gdwl);
		run;

		proc rank data=pf2na out=p groups=2;
		var ri_fas141 ri_fas142 ri_fas146 ri_fas123r;
		ranks r141 r142 r146 r123r;
		run;




		proc rank data=p out=p groups=2;
		var rceps1 aqc1 stkco1 gdwl1;
		ranks rest MA stock rgdwl;
		run;

		proc corr data=p;
		var  r141 r142 r146 r123r rest MA stock rgdwl;
		run;



		/*reference guide:
		t1= 141
		t3=Goodwill impairments
		t4=Restructuring
		t5=writedowns
		t6= debt extinguishments*/

		data p141a; set p;
		/*fas141*/
		/*DV*/
		if year le f141p then words=(mi_apb16)*-1;
		if year gt f141p  then words=(mi_fas141)*-1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample for diff in diff*/
		if year gt f141c and year lt f141p then drop=1;
		if year gt f141p then drop=1;
		if year lt f141c then drop=1;
		if drop ne 1;
		/*treat*/
		if MA eq 0 then treat=0;
		if MA eq 1 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 1 then treat1=1;
		rel=r141;
		st=1;
		inc=0;
		if fyear ne .;
		run;

		data p142; set p;
		/*DV*/
		if year le f142p then words=(mi_apb17);
		if year gt f142p  then words=(mi_fas142);
		/*post*/
		post=0;
		if year ge f142p then post=1;
		/*post*/
		post=0;
		if year ge f142p then post=1;
		/*limit sample for diff in diff*/
		if year gt f142c and year lt f142p then drop=1;
		if year gt f142p then drop=1;
		if year lt f142c then drop=1;
		if drop ne 1;
		/*treat*/
		if rgdwl eq 0 then treat=0;
		if rgdwl eq 1 then treat=1;
		if ra142 eq 0 then treat1=0;
		if ra142 eq 1 then treat1=1;
		rel=r142;
		st=2;
		inc=1;
		if fyear ne .;
		run;

		data p123r; set p;
		/*DV*/
		if year le f123rp then words=(mi_fas123);
		if year gt f123rp  then words=(mi_fas123r);
		/*post*/
		post=0;
		if year ge f123rp then post=1;
		/*limit sample for diff in diff*/
		if year gt f123rc and year lt f123rp then drop=1;
		if year gt f123rp then drop=1;
		if year lt f123rc then drop=1;
		if drop ne 1;
		/*treat*/
		if stock eq 0 then treat=0;
		if stock eq 1 then treat=1;
		if ra123r eq 0 then treat1=0;
		if ra123r eq 1 then treat1=1;
		rel=r123r;
		st=3;
		inc=1;
		if fyear ne .;
		run;

		data p146; set p;
		/*DV*/
		if year le f146p then words=(mi_eitf94_03);
		if year gt f146p  then words=(mi_fas146);
		/*post*/
		post=0;
		if year ge f146p then post=1;
		/*limit sample for diff in diff*/
		if year gt f146c and year lt f146p then drop=1;
		if year gt f146p then drop=1;
		if year lt f146c then drop=1;
		if drop ne 1;
		/*treat*/
		if rest eq 0 then treat=0;
		if rest ge 1 then treat=1;
		if ra146 eq 0 then treat1=0;
		if ra146 eq 1 then treat1=1;
		rel=r146;
		st=4;
		inc=1;
		if fyear ne .;
		run;


		proc sort data=p141a; by fyear;run;
		proc sort data=p142; by fyear;run;
		proc sort data=p123r; by fyear;run;
		proc sort data=p146; by fyear;run;









		data test; set p123r p142 p141a p146;
		if post ne .;
		if treat ne .;
		d06=0;
		if year=2006 then d06=1;
		d03=0;
		if year=2003 then d03=1;
		d98=0;
		if year=1998 then d98=1;
		d02=0;
		if year=2002 then d02=1;
		d04=0;
		if year=2004 then d04=1;
		d99=0;
		if year=1999 then d99=1;
		s1=0;
		if st=1 then s1=1;
		s2=0;
		if st=2 then s2=1;
		s3=0;
		if st=3 then s3=1;
		s4=0;
		if st=4 then s4=1;
		s5=0;
		if st=5 then s5=1;
		sta=cat(cusip,"ST",st);
		run;




		data bob; set test;
		if words ne . and drmfog eq .;run;



		/*THIS CONTRIBUTES TO THE PAPER VIA STATA*/
		proc export data=test outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjz.dta" replace;
		run;





		data xp123r; set p123r ;
		if post ne .;
		if treat ne .;
		run;

		data xp142; set p142 ;
		if post ne .;
		if treat ne .;
		run;

		data xp141a; set p141a ;
		if post ne .;
		if treat ne .;
		run;

		data xp146; set p146 ;
		if post ne .;
		if treat ne .;
		run;

		/*THIS CONTRIBUTES TO THE PAPER VIA STATA*/
		proc export data=xp123r outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s1tatamda3zjz.dta" replace;
		run;
		proc export data=xp142 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s2tatamda3zjz.dta" replace;
		run;
		proc export data=xp141a outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s3tatamda3zjz.dta" replace;
		run;
		proc export data=xp146 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s4tatamda3zjz.dta" replace;
		run;









		/*descriptives table*/






		data p141a; set p;
		/*fas141*/
		/*DV*/
		if fyear le f141p then words=(mi_apb16);
		if fyear gt f141p  then words=(mi_fas141);
		/*post*/
		post=0;
		if fyear ge f141p then post=1;
		/*limit sample to get t stats*/
		*if fyear gt f141c and fyear lt f141p then dropx=1;
		if fyear lt 1997 then dropx=1;
		if fyear gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if ma eq 0 then treat=0;
		if ma eq 1 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 1 then treat1=1;
		rel=r141;
		st=1;
		inc=0;
		if fyear ne .;
		/**/
		if treat=1;
		run;

		data p142; set p;
		/*DV*/
		if fyear le f142p then words=(mi_apb17);
		if fyear gt f142p  then words=(mi_fas142);
		/*post*/
		post=0;
		if fyear ge f142p then post=1;
		/*post*/
		post=0;
		if fyear ge f142p then post=1;
		/*limit sample to get t stats*/
		*if fyear gt f142c and fyear lt f142p then dropx=1;
		if fyear lt 1997 then dropx=1;
		if fyear gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if rgdwl eq 0 then treat=0;
		if rgdwl eq 1 then treat=1;
		if ra142 eq 0 then treat1=0;
		if ra142 eq 1 then treat1=1;
		rel=r142;
		st=2;
		inc=1;
		if fyear ne .;
		/**/
		if treat=1;
		run;

		data p123r; set p;
		/*DV*/
		if fyear le f123rp then words=(mi_fas123);
		if fyear gt f123rp  then words=(mi_fas123r);
		/*post*/
		post=0;
		if fyear ge f123rp then post=1;
		/*limit sample to get t stats*/
		*if fyear gt f123rc and fyear lt f123rp then dropx=1;
		if fyear lt 1997 then dropx=1;
		if fyear gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if stock eq 0 then treat=0;
		if stock eq 1 then treat=1;
		if ra123r eq 0 then treat1=0;
		if ra123r eq 1 then treat1=1;
		rel=r123r;
		st=3;
		inc=1;
		if fyear ne .;
		/**/
		if treat=1;
		run;

		data p146; set p;
		/*DV*/
		if fyear le f146p then words=(mi_eitf94_03);
		if fyear gt f146p  then words=(mi_fas146);
		/*post*/
		post=0;
		if fyear ge f146p then post=1;
		/*limit sample to get t stats*/
		*if fyear gt f146c and fyear lt f146p then dropx=1;
		if fyear lt 1997 then dropx=1;
		if fyear gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if rest eq 0 then treat=0;
		if rest ge 1 then treat=1;
		if ra146 eq 0 then treat1=0;
		if ra146 eq 1 then treat1=1;
		rel=r146;
		st=4;
		inc=1;
		if fyear ne .;
		/**/
		if treat=1;
		run;


		proc sort data=p141a; by fyear;run;
		proc sort data=p142; by fyear;run;
		proc sort data=p123r; by fyear;run;
		proc sort data=p146; by fyear;run;



		data acc5; set p141a p142 p123r p146 ;
		lr=log(restrict);
		run;
	/*this gives table 9 panel a*/
		proc means data=p141a;by fyear;var words;run;
		proc means data=p142;by fyear;var words;run;
		proc means data=p123r;by fyear;var words;run;
		proc means data=p146;by fyear;var words;run;

		/*THIS CONTRIBUTES TO THE PAPER */
		proc sort data=p141a; by post;run;
		proc ttest data=p141a;class post;
		var words;run;

		proc sort data=p142; by post;run;
		proc ttest data=p142;class post;
		var words;run;

		proc sort data=p123r; by post;run;
		proc ttest data=p123r;class post;
		var words;run;

		proc sort data=p146; by post;run;
		proc ttest data=p146;class post;
		var words;run;







		/* examine joint disclosure decisions*/

		data a2a; set a2;
		if year le 1997 then n_guid=.;
		run;

		data b1; set a2a;
		if llen ne .;
		if mfog ne .;
		if n_guid ne .;
		if edum ne .;
		run;

		proc rank data=b1 out=b2 groups=2;
		var llen mfog;
		ranks rllen rxmfog;
		run;



		proc import out=epps datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta";
		run;

		proc sql; create table epps1 as select
		a.*, b.n_guid_g,b.n_guid_e,b.n_guid_e_only
		from b2 as a left join epps as b
		on a.cik=b.cik and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;



		data b3; set epps1;
		if rxmfog=1 then mfog_indicator=0;
		if rxmfog=0 then mfog_indicator=1;
		if n_guid_E=0 then guid_indicator=0;
		if n_guid_e gt 0 then guid_indicator=1;
		sum_DV=guid_indicator+edum+rllen+mfog_indicator;
		mDA=0;
		if mfog_indicator=1 and rllen=1 then mda=1;
		sum_dv1=guid_indicator+edum+mda;
		vd1=0;
		vd2=0;
		vd3=0;
		if sum_dv1 eq 1 then vd1=1;
		if sum_dv1 eq 2 then vd2=1;
		if sum_dv1 eq 3 then vd3=1;
		vard=drdscorerrl*9;
		run;



		proc rank data=b3 out=b3x groups=10;
		var dscorerrl;
		ranks xdscorerrl;
		run;

		data k; set b3x;
		keep drdscorerrl vard xdscorerrl;
		run;

		/*This contributes to the paper...table 3 and 4 panel a */
		data testerf; set b3x;
		if xdscorerrl=8;
		*if guid_indicator=1; 
		*if edum=1; 
		*if mda=1; 

		*if mda=0 and guid_indicator=0 and edum=0;
		*if mda=0 and guid_indicator=1 and edum=0;
		*if mda=0  and guid_indicator=0 and edum=1;
		*if mda=1  and guid_indicator=0 and edum=0;

		*if mda=0 and guid_indicator=1 and edum=1;
		*if mda=1 and guid_indicator=1 and edum=0;
		*if mda=1 and guid_indicator=0 and edum=1;
		*if mda=1  and guid_indicator=1 and edum=1;
		run;

	

		
		/*t-tests pre post*/
		data ttest; set b3x;
		*if xdscorerrl eq 0 or xdscorerrl eq 9;
		c1=0;c2=0;c3=0;c4=0;c5=0;c6=0;c7=0;c8=0;
		x1=0;x2=0;x3=0;
		x0=0;
		if sum_dv1=0 then x0=1;
		if  guid_indicator=1  then x1=1;
		if  edum=1 then x2=1;
		if mda=1   then x3=1;
		if mda=0 and guid_indicator=0 and edum=0 then c1=1;
		if mda=0 and guid_indicator=1 and edum=0 then c2=1;
		if mda=0  and guid_indicator=0 and edum=1 then c3=1;
		if mda=1  and guid_indicator=0 and edum=0 then c4=1;

		if mda=0 and guid_indicator=1 and edum=1 then c5=1;
		if mda=1 and guid_indicator=1 and edum=0 then c6=1;
		if mda=1 and guid_indicator=0 and edum=1 then c7=1;
		if mda=1  and guid_indicator=1 and edum=1 then c8=1;
		run;

		proc surveyreg data=ttest;
		model x0=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model x1=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model x2=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model x3=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model c5=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model c6=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model c7=xdscorerrl;
		run;
		proc surveyreg data=ttest;
		model c8=xdscorerrl;
		run;



		data b4; set b3;
		if sum_dv1 eq 0 or sum_dv1 eq 1;
		run;



		data b5; set b3;
		if sum_dv1 eq 0 or sum_dv1 eq 2;
		run;



		data b6; set b3;
		if sum_dv1 eq 0 or sum_dv1 eq 3;
		run;


		/*these tests are run in the mda Robustness stata code*/
		proc export data=b3 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb3.dta" replace;
		run;
		proc export data=b4 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb4x.dta" replace;
		run;
		proc export data=b5 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb5x.dta" replace;
		run;
		proc export data=b6 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb6x.dta" replace;
		run;


		proc sql; create table recogn_onlyxa as select
		a.*, b.drdscorerrl_ronly
		from b3 as a left join dperm.recogn_only3 as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=recogn_onlyxa; by cik fyenddt descending drdscorerrl_ronly;run;
		proc sort data=recogn_onlyxa out=b3a nodupkey; by cik fyenddt;run;


		data b4x; set b3a;
		if sum_dv1 eq 0 or sum_dv1 eq 1;
		run;



		data b5x; set b3a;
		if sum_dv1 eq 0 or sum_dv1 eq 2;
		run;



		data b6x; set b3a;
		if sum_dv1 eq 0 or sum_dv1 eq 3;
		run;


		/*these tests are run in the mda Robustness stata code for recognition only*/
		proc export data=b3a outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb3xa.dta" replace;
		run;
		proc export data=b4x outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb4xxa.dta" replace;
		run;
		proc export data=b5x outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb5xxa.dta" replace;
		run;
		proc export data=b6x outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb6xxa.dta" replace;
		run;



	/*END: c. MD&A Tests*/
	/*BEGIN: d. MD&A Robustness*/
			/*********************************************************



		/*1. Obtain necessary data */
		libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		libname ds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\Dealscan';
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";
		libname mda 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data';

		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data\output_mda_std_hits_no_standard_names.xlsx" out=sy dbms=xlsx replace;
		    getnames=yes;
		run;


		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Debt Contracts\Data\import_std_year.xlsx" out=styear dbms=xlsx replace;
		    getnames=yes;
		run;

		proc import datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\data\fog_7.xlsx" out=fog dbms=xlsx replace;
		    getnames=yes;
		run;

		proc sql; create table sya as select
			a.*, b.*
			from sy as a left join fog as b			/*The "as" statements are optional*/
			on a.accession=b.accession_id 					/*you can set multiple match conditions using 'AND'*/
			order by cik,fyenddt;
			quit;

		proc sort data=sya ; by cik fyenddt accession descending fog ;run;
		proc sort data=sya out=syb nodupkey; by cik fyenddt accession;run;

		data styear1; set styear;
		keep  abs94_03  apb16 apb17 year fas141 fas123 fas123r apb30 fas121 fas144 apb17 fas142 fas146 apb26 fas76 fas125 fas140;
		run;

		data sy1; set syb;
		rename word_count=mword_count;
		rename fog=mfog;
		run;
		data sy1; set sy1;
		keep cik fyenddt accession len mfog mword_count unique_word_count eitf94_03  apb16 apb17 year fas141 fas123 fas123r apb30 fas121 fas144 apb17 fas142 fas146 apb26 fas76 fas125 fas140;
		run;

		data ri; set data.rel_imp;
		gvkeyn=gvkey*1;
		run;

		proc sql; create table acc4b as select
			a.*, b.ri_fas123,b.ri_fas123r,b.ri_apb30, b.ri_apb16, b.ri_apb17,b.ri_fas140,b.ri_apb26,
		b.ri_fas146,b.ri_eitf94_03,b.ri_fas141,b.ri_fas142,b.ri_fas144,b.ri_fas142,b.ri_fas125,b.ri_fas121					/*These are the variables you want to keep*/
			from sy1 as a left join ri as b			/*The "as" statements are optional*/
			on a.cik=b.cik and a.fyenddt=b.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4b ; by cik fyenddt descending ri_apb30 ;run;
		proc sort data=acc4b out=acc4 nodupkey; by cik fyenddt ;run;



		data final; set dperm.final_dataxxx;
		d=0;
		if nguid1 gt 0 then d=1;
		run;

		proc sql; create table finalrr as select
		a.*, b.dscore*-1 as dscoreRR
		from final as a left join data.dscore_limited_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr; by cik datadate descending dscorerr;run;
		proc sort data=finalrr out=finalrr1 nodupkey; by cik datadate;run;

		proc sql; create table finalrr2 as select
		a.*, b.dscore*-1 as dscoreRRL
		from finalrr1 as a left join data.dscore_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalrr2; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr2 out=finalrr3 nodupkey; by cik datadate;run;

		proc sql; create table finalrr4 as select
		a.*, b.dscore*-1 as dscorerrl_alt
		from finalrr3 as a left join data.dscore_alt_limited_length_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr4; by cik datadate descending dscorerrl;run;
		proc sort data=finalrr4 out=finalrr5 nodupkey; by cik datadate;run;

		proc sql; create table finalrr6 as select
		a.*, b.mgr_exclude
		from finalrr5 as a left join dperm.gee_data as b
		on a.gvkey=b.gvkey and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sql; create table finalrr7 as select
		a.*, b.dscore*-1 as dscorerrl_orth
		from finalrr6 as a left join data.dscore_limited_orthlength_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr7; by cik datadate descending dscorerrl_orth;run;
		proc sort data=finalrr7 out=finalrr8 nodupkey; by cik datadate;run;

		proc sql; create table finalrr9 as select
		a.*, b.dscore*-1 as dscorerrl_rbc
		from finalrr8 as a left join data.dscore_limited_orthrbc_rr1az as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr9; by cik datadate descending dscorerrl_rbc;run;
		proc sort data=finalrr9 out=finalrr10 nodupkey; by cik datadate;run;

		PROC UNIVARIATE data=finalrr10 NOPRINT; by cik;
		VAR dscorerrl;
		OUTPUT OUT = univ mean=mean_dscore ; run;

		proc sql; create table finalrr10a as select
		a.*, b.mean_dscore
		from finalrr10 as a left join univ as b
		on a.cik=b.cik 
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10a; by cik datadate descending mean_dscore;run;
		proc sort data=finalrr10a out=finalrr10b nodupkey; by cik datadate;run;

		proc sql;create table finalrr10c as select 
		a.*, b.nonstick, b.decile_nonstick
		from finalrr10b as a left join data.nonstick as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10c; by cik datadate descending nonstick; run;
		proc sort data=finalrr10c out=finalrr10d nodupkey; by cik datadate ; run;

		proc sql;create table finalrr10de as select 
		a.*, b.nonstick as nonstickd, b.decile_nonstick as decile_nonstickd
		from finalrr10d as a left join data.nonstickd as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;

		proc sort data=finalrr10de; by cik datadate descending nonstick; run;
		proc sort data=finalrr10de out=finalrr10df nodupkey; by cik datadate ; run;



		proc rank data=finalrr10df out=frr4 groups=10;
		var dscorerr dscorerrl dscorerrl_alt dscorerrl_orth dscorerrl_rbc mean_dscore ;
		ranks rdscorerr rdscorerrl rdscorerrl_alt rdscorerrl_orth rdscorerrl_rbc rmean_dscore ;
		run;

		data final1; set frr4;
		drdscorerr=rdscorerr/9;
		drdscorerrl=rdscorerrl/9;
		drdscorerrl_alt=rdscorerrl_alt/9;
		drdscorerrl_rbc=rdscorerrl_rbc/9;
		drdscorerrl_orth=rdscorerrl_orth/9;
		drmean_dscore=rmean_dscore/9;
		decile_nonstickde=decile_nonstickd/9;
		drfogm=rfogm/9;
		run;

		proc sql; create table acc4d as select
			a.*, b.*,b.len as mlen
		from acc4 as a left join final1 as b			/*The "as" statements are optional*/
			on a.cik=b.cik and a.fyenddt=b.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4d ; by cik fyenddt descending gvkey ;run;
		proc sort data=acc4d out=acc4e nodupkey; by cik fyenddt ;run;


		data acc4f; set acc4e;
		llen=log(len);
		llenK=log(mlen);
		run; 


		%WT(data=acc4f, out=acc4fa, byvar=d, vars=  len llen mfog, type = W, pctl = 1 99, drop= N);


		/*just to get descriptives*/
		proc sql; create table acc4dx as select
			a.*, b.*,b.len as blen
		from final1 as a left join acc4 as b			/*The "as" statements are optional*/
			on a.cik=b.cik and b.fyenddt=a.file_date					/*you can set multiple match conditions using 'AND'*/
			order by gvkey, datadate;
			quit;

		proc sort data=acc4dx ; by cik datadate descending blen ;run;
		proc sort data=acc4dx out=acc4ex nodupkey; by cik datadate ;run;


		%WT(data=acc4ex, out=acc4fax, byvar=none, vars=  blen  mfog, type = W, pctl = 1 99, drop= N);

		data acc4fax1; set acc4fax;
		if mfog eq . then blen=.;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		run;

		proc means data=acc4fax1 n mean std p5 q1 median q3 p90 p95 p99;
		var n_guid edum blen mfog dscorerrl numest size roa leverage mtb special loss std_ret bhar lit neg_surprise intan   dba dliq abpmdacc mpio ;
		run;

		%corrps(dset=acc4fax1,vars= n_guid edum blen mfog  dscorerrl numest  size roa leverage mtb special loss std_ret bhar intan  lit neg_surprise  dba dliq abpmdacc pio);


		/***end of descriptives***/

		data acc4fa; set acc4fa;
		drop n_stand rn drn;
		run;

		proc sql; create table x1 as select
		a.*, b.*
		from acc4fa as a left join data.n_stand as b
		on a.cik=b.cik and a.file_date=b.file_date
		order by gvkey, datadate;
		quit;

		proc sort data=x1 ; by cik datadate descending n_stand ;run;
		proc sort data=x1 out=x2 nodupkey; by cik datadate ;run;



		proc rank data=x2 out=x3 groups=10;
		var n_stand;
		ranks rn;
		run;

		data x4; set x3;
		drn=rn/9;
		run;


		proc rank data=x4 out=a1 groups=10;
		var mlen len mfog;
		ranks rmlen rlen rmfog;
		run;

		data a2; set a1;
		drlenK=rmlen/9;
		drmfog=rmfog/9;
		drlen=rlen/9;
		lit=0;
		if sich ge 2833 and sich le 2836 then lit=1;
		if sich ge 8731 and sich le 8734 then lit=1;
		if sich ge 3570 and sich le 3577 then lit=1;
		if sich ge 7370 and sich le 7374 then lit=1;
		if sich ge 3600 and sich le 3674 then lit=1;
		if sich ge 5200 and sich le 5961 then lit=1;
		spec=0;
		if spi gt 0 then spec=1;
		neg_surprise=0;
		dib=ib-ib1;
		if dib lt 0 then neg_surprise=1;
		indyear=cat(industry,year)*1;
		if drn eq . then drn=0;
		run;



		/*This table contributes to the paper via stata*/
		proc export data=a2 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj_ROBa.dta" replace;
		run;





		proc sql; create table finalz1 as select
		a.*, b.drfog_m
		from a2 as a left join dperm.finalz4_fog as b
		on a.cik=b.cik and a.datadate=b.datadate
		order by gvkey, datadate;
		quit;


		proc sort data=finalz1; by cik datadate descending drfog_m;run;
		proc sort data=finalz1 out=finalz2 nodupkey; by cik datadate;run;




		/*This table contributes to the paper via stata*/
		proc export data=finalz2 outfile= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj_ROB_fog.dta" replace;
		run;



	/*END: d. MD&A Robustness*/
	/*BEGIN:e. Validate D_SCORE/Non-GAAP Difference in Difference*/

		/*ASSIGN LIBRARIES*/
		libname perm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
		libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
		/*libname byu 'C:\Users\spencer\Documents\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
		libname wrds 'C:\Users\spencer\Documents\U of A\WRDS\WRDS';
		libname bob'C:\Users\spencer\Documents\U of A\Dissertation\Data';*/

		%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";


		data ds2; set dperm.dscore_limited_length_rr1az;
		run;


		proc sql;
			create table		ds3
			as select 	a.*, b.DA_pmKothari, b.ABSDA_pmKothari, b.datadate
			from				ds2 as a left join  perm.e_wins as b
			on				(a.gvkey=b.gvkey) and a.fyear=b.fyear
			order by			a.gvkey, a.fyear;
		quit;

		proc sort data=ds3 out=ds3a; by cik gvkey fyear descending DA_pmkothari;run;
		proc sort data=ds3a out=ds3b nodupkey; by cik gvkey fyear;run;


		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\pscore1.xlsx'
		DBMS = xlsx OUT = pscore1;run;

		data ds3c; set ds3b;
		gvkey1=gvkey/1;
		run;

		proc sql; create table ds4 as select
		a.*, b.pscore
		from ds3c as a left join pscore1 b
		on a.gvkey1=b.gvkey and a.fyear=b.fyear
		order by gvkey, datadate;
		quit;

		data corr; set ds4;
		*if pscore ne .;
		if dscore ne .;
		pmdacc=DA_pmKothari;
		abpmdacc=ABSDA_pmKothari;
		run;


		proc sql;
			create table corr1 as select a.*, b.ddaq
			from corr as a left join perm.ddaq as b
			on a.gvkey=b.gvkey and a.datadate=b.datadate;
		quit; 
		data fog; set perm.fogdata_pre04 perm.fogdata_05_07;
		run;


		proc sql; create table corr2 as select
		a.*, b.fog
		from corr1 as a left join fog b
		on a.gvkey=b.gvkey2 and a.datadate=b.fiscdate
		order by gvkey, datadate;
		quit;

		proc sort data=corr2 out=corr2a; by cik gvkey fyear datadate descending fog;run;
		proc sort data=corr2a out=corr2b nodupkey; by cik gvkey fyear datadate;run;

		data corr2c; set corr2b;
		restrict=dscore*-1;
		run;

		%corrps(dset=corr2c,vars= restrict abpmdacc pscore ddaq fog);

		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public1.xlsx'
		DBMS = xlsx OUT = rbc;run;
		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Datasets\RBC\rbc_public2.xlsx'
		DBMS = xlsx OUT = rbc2;run;

		data shall21; set dperm.lengthrraz;
		standard=compress(cat(org,std_num));
		run;

		data rbc; set rbc ;
		year1=year*1;
		run;

		proc sql; create table shall as select
		a.*, b.rbc1,b.rbc2
		from shall21 as a left join rbc b
		on a.standard=b.standard and a.year=b.year1
		order by standard, year;
		quit;
		proc sort data=shall; by standard year descending rbc1;run;
		proc sort data=shall out=shall1 nodupkey; by standard year;run;

		data shall1; set shall1;
		length1=length*1;
		run;
		/*table B3 panel a*/
		%corrps(dset=shall1,vars= total_modal stm residual length1  rbc1 );

		proc sql; create table shallx1 as select
		a.*, b.total_modal as ltm,b.length as llength,b.stm as lstm,b.residual as lresidual
		from shall1 as a left join shall1 b
		on a.standard=b.standard and a.year=b.year+1
		order by standard, year;
		quit;


		proc sql; create table shallx2 as select
		a.*, b.rbc1 as lrbc1 ,b.rbc2 as lrbc2
		from shallx1 as a left join rbc b
		on a.standard=b.standard and a.year=b.year1+1
		order by standard, year;
		quit;
		proc sort data=shallx2; by standard year descending rbc1;run;
		proc sort data=shallx2 out=shallx3 nodupkey; by standard year;run;

		data shallx4; set shallx3;
		dtm=total_modal-ltm;
		dlen=length-llength;
		dstm=stm-lstm;
		dres=residual-lresidual;
		drbc1=rbc1-lrbc1;
		drbc2=rbc2-lrbc2;
		run;
		/*table b3 panel b*/
		%corrps(dset=shallx4,vars= dtm dstm dres dlen   drbc1 );











		/*Pro Forma validations Code below creates datasets for diff in diff*/

		/*create impairment variable*/
		data pf; set perm.completepfsample;
		imp=0;
		exp_other1=lowcase(exp_other);
		if find(exp_other1,'impair','i') then imp=1;
		if find(exp_other1,'write-down','i') then imp=1;
		if find(exp_other1,'impairment','i') then imp=1;
		if find(exp_other1,'write','i') and  find(exp_other1,'down','i') then imp=1;
		run;


		proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\standard changes.xlsx'
		DBMS = xlsx OUT = stda;run;




		proc sql; create table pfa as select
		a.*, b.stock_comp as sc1,b.amort_dep as ad1,b.merge as m1,b.iprd as rd1, b.restruct as rest1, b.other as other1
		from pf as a left join pf b
		on a.gvkey=b.gvkey and a.permno=b.permno and month(b.fqenddt)-1<=month(a.fqenddt)<=month(b.fqenddt)+1 and a.year=b.year+1
		order by year, gvkey;
		quit;


		proc sql; create table pf1 as select
		a.*, b.*
		from pfa as a left join stda b
		on a.gvkey ne ""
		order by year, gvkey;
		quit;

		proc sql; create table pf2 as select
		a.*, b.ri_fas141,b.ri_fas142,b.ri_fas146,b.ri_fas123r
		from pf1 as a left join dperm.rel_imp b
		on a.gvkey eq b.gvkey and a.year=b.fyear
		order by year, gvkey;
		quit;

		proc sort data=pf2 out=pf2a; by gvkey year qtr descending ri_fas141;
		run;
		proc sort data=pf2a out=pf2b nodupkey; by gvkey year qtr;run;

		proc sql; create table pf2c as select
		a.*, b.ri_fas141 as i141
		from pf2b as a left join dperm.rel_imp b
		on a.gvkey eq b.gvkey and a.f141p=b.fyear
		order by year, gvkey;
		quit;

		proc sort data=pf2c out=pf2d; by gvkey year qtr descending i141;
		run;
		proc sort data=pf2d out=pf2e nodupkey; by gvkey year qtr;run;


		proc sql; create table pf2f as select
		a.*, b.ri_fas142 as i142
		from pf2e as a left join dperm.rel_imp b
		on a.gvkey eq b.gvkey and a.f142p=b.fyear
		order by year, gvkey;
		quit;

		proc sort data=pf2f out=pf2g; by gvkey year qtr descending i142;
		run;
		proc sort data=pf2g out=pf2h nodupkey; by gvkey year qtr;run;

		proc sql; create table pf2i as select
		a.*, b.ri_fas146 as i146
		from pf2h as a left join dperm.rel_imp b
		on a.gvkey eq b.gvkey and a.f146p=b.fyear
		order by year, gvkey;
		quit;

		proc sort data=pf2i out=pf2j; by gvkey year qtr descending i146;
		run;
		proc sort data=pf2j out=pf2k nodupkey; by gvkey year qtr;run;

		proc sql; create table pf2l as select
		a.*, b.ri_fas123r as i123r
		from pf2k as a left join dperm.rel_imp b
		on a.gvkey eq b.gvkey and a.f123rp=b.fyear
		order by year, gvkey;
		quit;

		proc sort data=pf2l out=pf2m; by gvkey year qtr descending i123r;
		run;
		proc sort data=pf2m out=pf2n nodupkey; by gvkey year qtr;run;


		proc rank data=pf2n out=p groups=3;
		var ri_fas141 ri_fas142 ri_fas146 ri_fas123r;
		ranks r141 r142 r146 r123r;
		run;

		proc rank data=p out=p groups=3;
		var i141 i142 i146 i123r;
		ranks ra141 ra142 ra146 ra123r;
		run;



		data p141a; set p;
		/*DV*/
		adj=0;
		if merge=1 then adj=1;
		adj1=0;
		if merge=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample*/
		if year gt f141c and year lt f141p then drop=1;
		if year gt f141p then drop=1;
		if year lt f141c then drop=1;
		if drop ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=1;
		inc=0;
		run;
		data p141b; set p;
		/*DV*/
		adj=0;
		if iprd=1 then adj=1;
		adj1=0;
		if iprd=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample*/
		if year gt f141c and year lt f141p then drop=1;
		if year gt f141p then drop=1;
		if year lt f141c then drop=1;
		if drop ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=2;
		inc=0;
		run;

		data p142; set p;
		/*DV*/
		adj=amort_dep;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f142p then post=1;
		/*limit sample*/
		if year gt f142c and year lt f142p then drop=1;
		if year gt f142p then drop=1;
		if year lt f142c then drop=1;
		if drop ne 1;
		/*treat*/
		if r142 eq 0 then treat=0;
		if r142 eq 2 then treat=1;
		if ra142 eq 0 then treat1=0;
		if ra142 eq 2 then treat1=1;
		rel=r142;
		st=3;
		inc=1;
		run;
		data p146; set p;
		/*DV*/
		adj=restruct;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f146p then post=1;
		/*limit sample*/
		if year gt f146c and year lt f146p then drop=1;
		if year gt f146p then drop=1;
		if year lt f146c then drop=1;
		if drop ne 1;
		/*treat*/
		if r146 eq 0 then treat=0;
		if r146 eq 2 then treat=1;
		if ra146 eq 0 then treat1=0;
		if ra146 eq 2 then treat1=1;
		rel=r146;
		st=4;
		inc=1;
		run;
		data p123R; set p;
		/*DV*/
		adj=stock_comp;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f123rp then post=1;
		/*limit sample*/
		if year gt f123rc and year lt f123rp then drop=1;
		if year gt f123rp then drop=1;
		if year lt f123rc then drop=1;
		if drop ne 1;
		/*treat*/
		if r123r eq 0 then treat=0;
		if r123r eq 2 then treat=1;
		if ra123r eq 0 then treat1=0;
		if ra123r eq 2 then treat1=1;
		rel=r123r;
		st=5;
		inc=1;
		run;



		proc sort data=p141a; by post;run;
		proc ttest data=p141a;class post;
		var adj;run;

		proc sort data=p141b; by post;run;
		proc ttest data=p141b;class post;
		var adj;run;

		proc sort data=p142; by post;run;
		proc ttest data=p142;class post;
		var adj;run;

		proc sort data=p146; by post;run;
		proc ttest data=p146;class post;
		var adj;run;

		proc sort data=p123r; by post;run;
		proc ttest data=p123r;class post;
		var adj;run;




		



		data test; set p123r p142 p141a p141b p146;
		if post ne .;
		if treat1 ne .;
		d06=0;
		if year=2006 then d06=1;
		d03=0;
		if year=2003 then d03=1;
		d98=0;
		if year=1998 then d98=1;
		d02=0;
		if year=2002 then d02=1;
		d04=0;
		if year=2004 then d04=1;
		d99=0;
		if year=1999 then d99=1;
		s1=0;
		if st=1 then s1=1;
		s2=0;
		if st=2 then s2=1;
		s3=0;
		if st=3 then s3=1;
		s4=0;
		if st=4 then s4=1;
		s5=0;
		if st=5 then s5=1;
		sta=cat(cusip,"ST",st);
		run;





		data xp141a; set p141a;
		if post ne .;
		if treat1 ne .;
		run;

		data xp141b; set p141b;
		if post ne .;
		if treat1 ne .;
		run;

		data xp142; set p142;
		if post ne .;
		if treat1 ne .;
		run;

		data xp146; set p146;
		if post ne .;
		if treat1 ne .;
		run;

		data xp123r; set p123r;
		if post ne .;
		if treat1 ne .;
		run;


		PROC EXPORT DATA= WORK.test
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_formaxza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xp141a
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_forma1xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xp141b
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_forma2xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xp142
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_forma3xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xp146
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_forma4xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xp123r
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\pro_forma5xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;



		/*get sample for chris*/
		data forchris_NG; set test;
		keep cusip ibes_ticker  tic fqenddt prodate rdqe gvkey year permno;
		run;

		proc sort data=forchris_ng nodupkey; by cusip ibes_ticker tic fqenddt prodate rdqe gvkey year permno;
		run;

		data final; set perm.final_dataxxx;
		d=0;
		if nguid1 gt 0 then d=1;
		run;


		proc sql; create table fcng as select
		a.*, b.n_guid
		from forchris_ng as a left join final b
		on a.gvkey eq b.gvkey and a.year=b.fyear
		order by year, gvkey;
		quit;

		data fcng1; set fcng;
		if n_guid ge 1;
		run;

		proc sql; create table fcng2 as select
		a.*, b.pdicity,b.measure,b.actdats,b.anndats,b.mod_date,b.acttims,b.anntims,b.mod_time,b.prd_yr,b.prd_mon,b.eefymo,b.val_1,b.val_2,b.mean_at_date
		from fcng1 as a left join perm.ds7a_chris b
		on a.gvkey eq b.gvkey and a.year=b.fyear
		order by year, gvkey;
		quit;


		proc sql; create table fc3 as select distinct
		gvkey, fqenddt,
						count(anndats) as bob
		from fcng2 group by gvkey, fqenddt
		order by gvkey, fqenddt;
		quit;

		proc sql; create table fc4 as select
		a.*, b.bob
		from fcng1 as a left join fc3 as b
		on a.gvkey=b.gvkey and a.fqenddt=b.fqenddt
		order by gvkey, fqenddt;
		quit;

		data tester5; set fc4;
		if bob ne n_guid;
		dum=1;
		run;

		proc sql; create table fc5 as select
		a.*, b.dum
		from fcng2 as a left join tester5 as b
		on a.gvkey=b.gvkey and a.fqenddt=b.fqenddt
		order by gvkey, fqenddt;
		quit;

		data fc6; set fc5;
		if dum eq .;
		run;



		data perm.forchris_ng1; set fc6;
		drop dum;
		run;


		proc sql; create table f1 as select
		a.*, b.n_guid
		from test as a left join final b
		on a.gvkey eq b.gvkey and a.year=b.fyear
		order by year, gvkey;
		quit;

		data f2; set f1;
		if n_guid ge 1;
		run;

		PROC EXPORT DATA= WORK.f2
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\f2.dta" 
		            DBMS=STATA  REPLACE;
		RUN;



		/*get unconditional means by year*/
		proc sort data=pf; by year;run;

		proc means data=pf; by year;
		vars stock_comp amort_dep iprd restruct merge other;
		output out=pfx;
		run;
		/*keep means*/
		data pfx1; set pfx;
		if _stat_ eq "MEAN";
		run;

		proc print data=pfx1;run;



		data testa; set p123r p142 p146;
		run;
		data testb; set  p141a p141b;
		run;


		
		proc surveylogistic data=testa;
		model adj1(descending)= post treat post*treat1/rsq;
		estimate post 1 post*treat1 1;
		run;
		proc surveylogistic data=testb;
		model adj1(descending)= post treat post*treat1/rsq;
		estimate post 1 post*treat1 1;
		run;

		/*DiD in paper is below*/
		/*by quarter only*/
		proc sort data=p out=p1; by cusip year qtr;run;
		proc sort data=p1 out=p1a nodupkey; by cusip year ;run;

		proc sort data=p out=p2; by cusip year descending qtr;run;
		proc sort data=p2 out=p2a nodupkey; by cusip year ;run;


		data pb; set p1a p2a;run;

		proc sort data=pb noduprecs;by cusip year;run;
		data ap141a; set pb;
		/*DV*/
		adj=0;
		if merge=1 then adj=1;
		adj1=0;
		if merge=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample*/
		if year gt f141c and year lt f141p then drop=1;
		if year gt f141p then drop=1;
		if year lt f141c then drop=1;
		if drop ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=1;
		inc=0;
		run;
		data ap141b; set pb;
		/*DV*/
		adj=0;
		if iprd=1 then adj=1;
		adj1=0;
		if iprd=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample*/
		if year gt f141c and year lt f141p then drop=1;
		if year gt f141p then drop=1;
		if year lt f141c then drop=1;
		if drop ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=2;
		inc=0;
		run;

		data ap142; set pb;
		/*DV*/
		adj=amort_dep;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f142p then post=1;
		/*limit sample*/
		if year gt f142c and year lt f142p then drop=1;
		if year gt f142p then drop=1;
		if year lt f142c then drop=1;
		if drop ne 1;
		/*treat*/
		if r142 eq 0 then treat=0;
		if r142 eq 2 then treat=1;
		if ra142 eq 0 then treat1=0;
		if ra142 eq 2 then treat1=1;
		rel=r142;
		st=3;
		inc=1;
		run;
		data ap146; set pb;
		/*DV*/
		adj=restruct;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f146p then post=1;
		/*limit sample*/
		if year gt f146c and year lt f146p then drop=1;
		if year gt f146p then drop=1;
		if year lt f146c then drop=1;
		if drop ne 1;
		/*treat*/
		if r146 eq 0 then treat=0;
		if r146 eq 2 then treat=1;
		if ra146 eq 0 then treat1=0;
		if ra146 eq 2 then treat1=1;
		rel=r146;
		st=4;
		inc=1;
		run;
		data ap123R; set pb;
		/*DV*/
		adj=stock_comp;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f123rp then post=1;
		/*limit sample*/
		if year gt f123rc and year lt f123rp then drop=1;
		if year gt f123rp then drop=1;
		if year lt f123rc then drop=1;
		if drop ne 1;
		/*treat*/
		if r123r eq 0 then treat=0;
		if r123r eq 2 then treat=1;
		if ra123r eq 0 then treat1=0;
		if ra123r eq 2 then treat1=1;
		rel=r123r;
		st=5;
		inc=1;
		run;



		data atest; set ap123r ap142 ap141a ap141b ap146;
		if post ne .;
		if treat1 ne .;
		d06=0;
		if year=2006 then d06=1;
		d03=0;
		if year=2003 then d03=1;
		d98=0;
		if year=1998 then d98=1;
		d02=0;
		if year=2002 then d02=1;
		d04=0;
		if year=2004 then d04=1;
		d99=0;
		if year=1999 then d99=1;
		s1=0;
		if st=1 then s1=1;
		s2=0;
		if st=2 then s2=1;
		s3=0;
		if st=3 then s3=1;
		s4=0;
		if st=4 then s4=1;
		s5=0;
		if st=5 then s5=1;
		sta=cat(cusip,"ST",st);
		run;


		data xAp141a; set Ap141a;
		if post ne .;
		if treat1 ne .;
		run;

		data xap141b; set ap141b;
		if post ne .;
		if treat1 ne .;
		run;

		data xap142; set ap142;
		if post ne .;
		if treat1 ne .;
		run;

		data xap146; set ap146;
		if post ne .;
		if treat1 ne .;
		run;

		data xap123r; set ap123r;
		if post ne .;
		if treat1 ne .;
		run;

		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA*/
		PROC EXPORT DATA= WORK.atest
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_formaxza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xap141a
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma1xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xap141b
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma2xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xap142
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma3xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xap146
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma4xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;
		PROC EXPORT DATA= WORK.xap123r
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma5xza.dta" 
		            DBMS=STATA  REPLACE;
		RUN;





		/*new did with forecast sample*/
		data final; set perm.final_dataxxx;
		d=0;
		if nguid1 gt 0 then d=1;
		run;


		proc import out=epps datafile="C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta";
		run;

		proc sql; create table f1 as select
		a.*, b.n_guid_e
		from atest as a left join epps b
		on a.gvkey eq b.gvkey and a.year=b.fyear
		order by year, gvkey;
		quit;

		data f2a; set f1;
		if n_guid_e ge 1;
		run;
		/*THESE TABLES CONTRIBUTE TO PAPER VIA STATA*/
		PROC EXPORT DATA= WORK.f2a
		            OUTFILE= "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\f2ax.dta" 
		            DBMS=STATA  REPLACE;
		RUN;











		
		data test; set p123r p142  p141b p146;
		if post ne .;
		if treat ne .;
		d06=0;
		if year=2006 then d06=1;
		d03=0;
		if year=2003 then d03=1;
		d98=0;
		if year=1998 then d98=1;
		d02=0;
		if year=2002 then d02=1;
		d04=0;
		if year=2004 then d04=1;
		d99=0;
		if year=1999 then d99=1;
		s1=0;
		if st=1 then s1=1;
		s2=0;
		if st=2 then s2=1;
		s3=0;
		if st=3 then s3=1;
		s4=0;
		if st=4 then s4=1;
		s5=0;
		if st=5 then s5=1;
		run;



		/*GET DESCRIPTIVES*/
		data p141a; set p;
		/*DV*/
		adj=0;
		if merge=1 then adj=1;
		adj1=0;
		if merge=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample to get t stats*/
		*if year gt f141c and year lt f141p then dropx=1;
		if year lt 1997 then dropx=1;
		if year gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=1;
		inc=0;
		if treat1=1;
		run;
		data p141b; set p;
		/*DV*/
		adj=0;
		if iprd=1 then adj=1;
		adj1=0;
		if iprd=0 then adj1=1;
		/*post*/
		post=0;
		if year ge f141p then post=1;
		/*limit sample to get t stats*/
		*if year gt f141c and year lt f141p then dropx=1;
		if year lt 1997 then dropx=1;
		if year gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if r141 eq 0 then treat=0;
		if r141 eq 2 then treat=1;
		if ra141 eq 0 then treat1=0;
		if ra141 eq 2 then treat1=1;
		rel=r141;
		st=2;
		inc=0;
		if treat1=1;
		run;

		data p142; set p;
		/*DV*/
		adj=amort_dep;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f142p then post=1;
		/*limit sample to get t stats*/
		*if year gt f142c and year lt f142p then dropx=1;
		if year lt 1997 then dropx=1;
		if year gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if r142 eq 0 then treat=0;
		if r142 eq 2 then treat=1;
		if ra142 eq 0 then treat1=0;
		if ra142 eq 2 then treat1=1;
		rel=r142;
		st=3;
		inc=1;
		if treat1=1;
		run;
		data p146; set p;
		/*DV*/
		adj=restruct;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f146p then post=1;
		/*limit sample to get t stats*/
		*if year gt f146c and year lt f146p then dropx=1;
		if year lt 1997 then dropx=1;
		if year gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if r146 eq 0 then treat=0;
		if r146 eq 2 then treat=1;
		if ra146 eq 0 then treat1=0;
		if ra146 eq 2 then treat1=1;
		rel=r146;
		st=4;
		inc=1;
		if treat1=1;
		run;
		data p123R; set p;
		/*DV*/
		adj=stock_comp;
		adj1=adj;
		/*post*/
		post=0;
		if year ge f123rp then post=1;
		/*limit sample*/
		*if year gt f123rc and year lt f123rp then dropx=1;
		if year lt 1997 then dropx=1;
		if year gt 2007 then dropx=1;
		/*dont use following line for yearly means*/
		if dropx ne 1;
		/*treat*/
		if r123r eq 0 then treat=0;
		if r123r eq 2 then treat=1;
		if ra123r eq 0 then treat1=0;
		if ra123r eq 2 then treat1=1;
		rel=r123r;
		st=5;
		inc=1;
		if treat1=1;
		run;
	/*table 8 panel a*/
		proc sort data=p141a; by year;run;
		proc sort data=p141b; by year;run;
		proc sort data=p142; by year;run;
		proc sort data=p123r; by year;run;
		proc sort data=p146; by year;run;



		proc means data=p141a;by year;var adj;run;
		proc means data=p141b;by year;var adj;run;
		proc means data=p142;by year;var adj;run;
		proc means data=p123r;by year;var adj;run;
		proc means data=p146;by year;var adj;run;



		/*this contributes to the paper*/
		proc sort data=p141a; by post;run;
		proc ttest data=p141a;class post;
		var adj;run;


		proc sort data=p141b; by post;run;
		proc ttest data=p141b;class post;
		var adj;run;

		proc sort data=p142; by post;run;
		proc ttest data=p142;class post;
		var adj;run;

		proc sort data=p123r; by post;run;
		proc ttest data=p123r;class post;
		var adj;run;

		proc sort data=p146; by post;run;
		proc ttest data=p146;class post;
		var adj;run;

	/*END:e. Validate D_SCORE/Non-GAAP Difference in Difference*/

	/*BEGIN:f. Appendix B of paper*/
		/*BEGIN: i. Table B1*/
						
			/*ASSIGN LIBRARIES*/
			libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
			libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\data';
			libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
			libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
			%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";


			proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\appendix_aidz.xlsx'
			DBMS = xlsx OUT = appa;run;

			data app1; set appa;
			std=cat(org,std_num);
			length1=length*1;
			run;
			proc sort data=app1; by std;run;
			proc means data=app1 mean ; by std;
			output out=app2;run;

			data app3; set app2;
			if _stat_ eq "MEAN";
			run;

			proc print data=app3;
			run;
		/*END: i. Table B1*/

		/*BEGIN: ii. TABLE B4*/
						
			*for pc;
			libname saveData 'C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\DATA';
			%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";

			*import comment letter counts using Loughran and McDonald Constrain words;
			PROC IMPORT OUT= WORK.Data1
				DATAFILE= "C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\resultsLM.csv" 
				DBMS=csv REPLACE;
				GETNAMES=YES;
				DATAROW=2; 
				Guessingrows = max;
			RUN;

			*get rid of the .txt on the filename to merge constituent groups;
			data Data1b; set data1;
			   cl_title = substr(filename, 1, length(filename)-4);
			   put cl_title;
			run;

			*import key;
			PROC IMPORT OUT= WORK.DataKey
				DATAFILE= "C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\searchrestrictterms.csv" 
				DBMS=csv REPLACE;
				GETNAMES=YES;
				DATAROW=2; 
				Guessingrows = max;
			RUN;

			data datakey; set datakey;
			total=flexible+_flexibility+_judgement+_judgment+_restrict+_restricted+_narrow+_reduc+_constrain+_limit+_mandat+_dictat+_forc+_requir+_singlemethod+_prescri;
			run;


			*merge key;
			Proc sql;
				create table data1keya
				as select a.*, b.key,b.total
				from data1b as a
				left join datakey as b
				on a.filename=b.filename;
			quit;

			proc sort data=data1keya; by filename descending total;run;
			proc sort data=data1keya out=data1key nodupkey; by filename; run;


			data test; set data1key;
				if key = "";
			run;

			data data1key; set data1key;
				if key = "" then key = "fas123r";
			run;

			data test; set data1key;
				if key = "";
			run;


			*import wordcount;
			PROC IMPORT OUT= WORK.LIWC
				DATAFILE= "C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\LIWCrestrict.csv" 
				DBMS=csv REPLACE;
				GETNAMES=YES;
				DATAROW=2; 
				Guessingrows = max;
			RUN;

			*merge wordcount;
			Proc sql;
				create table Data1WC
				as select a.*, b.wc
				from data1key as a
				left join LIWC as b
				on a.filename=b.filename;
			quit;

			*import constituent group;
			PROC IMPORT OUT= WORK.DataConstituent
				DATAFILE= "C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\constituent.csv" 
				DBMS=csv REPLACE;
				GETNAMES=YES;
				DATAROW=2; 
				Guessingrows = max;
			RUN;

			*merge constituent type for each cl;
			Proc sql;
				create table data1con
				as select a.*, b.type
				from data1wc as a
				left join dataconstituent as b
				on a.cl_title=b.cl_title;
			quit;

			proc sort data = data1con out = test nodupkey;
				by type;
			quit;

			data data1con; set data1con;
				prep = 0;
				if type = 'PREP' then prep =1;
				if type = 'prep' then prep =1;
			run;


			PROC IMPORT OUT= WORK.Data2
				DATAFILE= "C:\Users\spencery\Dropbox\Hribar, Mergenthaler, Roeschley, Young, Zhao\Comment Letters\Validation of Restrict DATA\uploadrestrict.csv" 
				DBMS=csv REPLACE;
				GETNAMES=YES;
				DATAROW=2; 
				Guessingrows = max;
			RUN;

			data data2; set data2;
				keep standard scalemodal pctchgmodal count;
			run;

			Proc sql;
				create table data3x
				as select a.*, b.*
				from data1con as a
				left join data2 b
				on a.key=b.standard;
			quit;
			proc sort data=data3x; by filename descending count;run;
			proc sort data=data3x out=data3 nodupkey; by filename; run;



			data Data3; set Data3;
				keep pctchgmodal scalemodal total SumConstrain SumConstrain2 reqwords key prep wc filename impairment obligation obligations pledges pledge;
			run;

			data Data3; set Data3;
				scaleConstrain = SumConstrain/wc;
				scaleConstrain2 = (SumConstrain2)/(wc);
			run;


			/*table b4 column 1*/
			proc surveyreg data=data3 ;
			cluster key;
			model scaleconstrain= pctchgmodal/adjrsq noint;
			run;
			/*table b4 column 2*/
			proc surveyreg data=data3 ;
			cluster key;
			model sumconstrain= pctchgmodal/adjrsq noint;
			run;



			Proc sql;
				create table data3b
				as select a.*, b.*
				from data3 as a
				left join datakey as b
				on a.filename=b.filename;
			quit;
			proc sort data=data3b; by filename descending total;run;
			proc sort data=data3b out=data3a nodupkey; by filename; run;




			/*tests for scalemodal*/

			data data3x; set data3;
			if scaleconstrain ne .;
			run;

			/*table b4 column 3*/
			proc surveyreg data=data3x ;
			cluster key;
			model scaleconstrain= scalemodal/adjrsq noint;
			run;
			/*table b4 column 4*/
			proc surveyreg data=data3x;
			cluster key;
			model sumconstrain= scalemodal/adjrsq noint;
			run;


		/*END: ii.TABLE B4*/
	/*END:f. Appendix B of paper*/

	/*BEGIN:g. Replicate Folsom et al.*/
		/*BEGIN:i.create limit_discr for Folsom sample*/
			/*BEGIN:x.Create rel_imp for folsom sample*/
				libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
				libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
				libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
				/*bring in word count data*/

				data wc; set dperm.tenK_wordcounts;
				if datadate ne .;
				run;

				proc sort data=wc; by cik datadate descending len;run;
				proc sort data=wc out=wca nodupkey; by cik datadate ;run;



				/*create Rel_imp measure*/


				data link; set byu.gvkey_permno_link2017nov30;
				cik1=cik/1;
				run;

				proc sql; create table link1 as select
				a.*, b.fyear
				from link as a left join wrds.comp b
				on a.gvkey=b.gvkey
				and a.datadate eq b.datadate
				order by gvkey, datadate;
				quit;

				proc sort data=link1 out=link2 nodupkey; by gvkey datadate;
				run;

				data  wc6; set wca;
				if fyear eq . and month(datadate) le 5 then fyear=year(datadate)-1;
				if fyear eq . and month(datadate) gt 5 then fyear=year(datadate);
				run;

				proc sql; create table ps1 as select
				a.*, b.permno, b.gvkey,b.fyear as fyear1, b.datadate as datadate1
				from wc6 as a left join link2 as b
				on a.cik=b.cik1
				and (a.fyear eq b.fyear or (intnx('day',a.datadate,-20) <= b.datadate <= intnx('day',a.datadate,20)))
				order by cik, datadate;
				quit;


				/*create annual average count and annual std_dev(firm_count)*/
				/*WARNING: the word counts for a standard can be positive prior
				to the standard being passed*/
				proc sql; create table ps2 as select distinct
				fyear,
								avg(apb25) as avg_apb25, std(apb25) as std_apb25,
								avg(apb2) as avg_apb2, std(apb2) as std_apb2,
								avg(apb4) as avg_apb4, std(apb4) as std_apb4,
								avg(apb9) as avg_apb9, std(apb9) as std_apb9,
								avg(apb14) as avg_apb14, std(apb14) as std_apb14,
								avg(apb16) as avg_apb16, std(apb16) as std_apb16,
								avg(apb17) as avg_apb17, std(apb17) as std_apb17,
								avg(apb18) as avg_apb18, std(apb18) as std_apb18,
								avg(apb20) as avg_apb20, std(apb20) as std_apb20,
								avg(apb21) as avg_apb21, std(apb21) as std_apb21,
								avg(apb23) as avg_apb23, std(apb23) as std_apb23,
								avg(apb26) as avg_apb26, std(apb26) as std_apb26,
								avg(apb29) as avg_apb29, std(apb29) as std_apb29,
								avg(apb30) as avg_apb30, std(apb30) as std_apb30,
								avg(arb45) as avg_arb45, std(arb45) as std_arb45,
								avg(arb51) as avg_arb51, std(arb51) as std_arb51,
								avg(arb43_2a) as avg_arb43_2a, std(arb43_2a) as std_arb43_2a,
								avg(arb43_3a) as avg_arb43_3a, std(arb43_3a) as std_arb43_3a,
								avg(arb43_3b) as avg_arb43_3b, std(arb43_3b) as std_arb43_3b,
								avg(arb43_4) as avg_arb43_4, std(arb43_4) as std_arb43_4,
								avg(arb43_7a) as avg_arb43_7a, std(arb43_7a) as std_arb43_7a,
								avg(arb43_7b) as avg_arb43_7b, std(arb43_7b) as std_arb43_7b,
								avg(arb43_9a) as avg_arb43_9a, std(arb43_9a) as std_arb43_9a,
								avg(arb43_9b) as avg_arb43_9b, std(arb43_9b) as std_arb43_9b,
								avg(arb43_10a) as avg_arb43_10a, std(arb43_10a) as std_arb43_10a,
								avg(arb43_11a) as avg_arb43_11a, std(arb43_11a) as std_arb43_11a,
								avg(arb43_11b) as avg_arb43_11b, std(arb43_11b) as std_arb43_11b,
								avg(arb43_11c) as avg_arb43_11c, std(arb43_11c) as std_arb43_11c,
								avg(arb43_12) as avg_arb43_12, std(arb43_12) as std_arb43_12,
								avg(con5_6) as avg_con5_6, std(con5_6) as std_con5_6,
								avg(eitf00_21) as avg_eitf00_21, std(eitf00_21) as std_eitf00_21,
								avg(eitf94_03) as avg_eitf94_03, std(eitf94_03) as std_eitf94_03,
								avg(fas2) as avg_fas2, std(fas2) as std_fas2,
								avg(fas5) as avg_fas5, std(fas5) as std_fas5,
								avg(fas7) as avg_fas7, std(fas7) as std_fas7,
								avg(fas13) as avg_fas13, std(fas13) as std_fas13,
								avg(fas15) as avg_fas15, std(fas15) as std_fas15,
								avg(fas16) as avg_fas16, std(fas16) as std_fas16,
								avg(fas19) as avg_fas19, std(fas19) as std_fas19,
								avg(fas34) as avg_fas34, std(fas34) as std_fas34,
								avg(fas35) as avg_fas35, std(fas35) as std_fas35,
								avg(fas43) as avg_fas43, std(fas43) as std_fas43,
								avg(fas45) as avg_fas45, std(fas45) as std_fas45,
								avg(fas47) as avg_fas47, std(fas47) as std_fas47,
								avg(fas48) as avg_fas48, std(fas48) as std_fas48,
								avg(fas49) as avg_fas49, std(fas49) as std_fas49,
								avg(fas50) as avg_fas50, std(fas50) as std_fas50,
								avg(fas51) as avg_fas51, std(fas51) as std_fas51,
								avg(fas52) as avg_fas52, std(fas52) as std_fas52,
								avg(fas53) as avg_fas53, std(fas53) as std_fas53,
								avg(fas57) as avg_fas57, std(fas57) as std_fas57,
								avg(fas60) as avg_fas60, std(fas60) as std_fas60,
								avg(fas61) as avg_fas61, std(fas61) as std_fas61,
								avg(fas63) as avg_fas63, std(fas63) as std_fas63,
								avg(fas65) as avg_fas65, std(fas65) as std_fas65,
								avg(fas66) as avg_fas66, std(fas66) as std_fas66,
								avg(fas67) as avg_fas67, std(fas67) as std_fas67,
								avg(fas68) as avg_fas68, std(fas68) as std_fas68,
								avg(fas71) as avg_fas71, std(fas71) as std_fas71,
								avg(fas77) as avg_fas77, std(fas77) as std_fas77,
								avg(fas80) as avg_fas80, std(fas80) as std_fas80,
								avg(fas86) as avg_fas86, std(fas86) as std_fas86,
								avg(fas87) as avg_fas87, std(fas87) as std_fas87,
								avg(fas88) as avg_fas88, std(fas88) as std_fas88,
								avg(fas97) as avg_fas97, std(fas97) as std_fas97,
								avg(fas101) as avg_fas101, std(fas101) as std_fas101,
								avg(fas105) as avg_fas105, std(fas105) as std_fas105,
								avg(fas106) as avg_fas106, std(fas106) as std_fas106,
								avg(fas107) as avg_fas107, std(fas107) as std_fas107,
								avg(fas109) as avg_fas109, std(fas109) as std_fas109,
								avg(fas113) as avg_fas113, std(fas113) as std_fas113,
								avg(fas115) as avg_fas115, std(fas115) as std_fas115,
								avg(fas116) as avg_fas116, std(fas116) as std_fas116,
								avg(fas119) as avg_fas119, std(fas119) as std_fas119,
								avg(fas121) as avg_fas121, std(fas121) as std_fas121,
								avg(fas123) as avg_fas123, std(fas123) as std_fas123,
								avg(fas123r) as avg_fas123r, std(fas123r) as std_fas123r,
								avg(fas125) as avg_fas125, std(fas125) as std_fas125,
								avg(fas130) as avg_fas130, std(fas130) as std_fas130,
								avg(fas132) as avg_fas132, std(fas132) as std_fas132,
								avg(fas132r) as avg_fas132r, std(fas132r) as std_fas132r,
								avg(fas133) as avg_fas133, std(fas133) as std_fas133,
								avg(fas140) as avg_fas140, std(fas140) as std_fas140,
								avg(fas141) as avg_fas141, std(fas141) as std_fas141,
								avg(fas142) as avg_fas142, std(fas142) as std_fas142,
								avg(fas143) as avg_fas143, std(fas143) as std_fas143,
								avg(fas144) as avg_fas144, std(fas144) as std_fas144,
								avg(fas146) as avg_fas146, std(fas146) as std_fas146,
								avg(fas150) as avg_fas150, std(fas150) as std_fas150,
								avg(fas154) as avg_fas154, std(fas154) as std_fas154,
								avg(sab101) as avg_sab101, std(sab101) as std_sab101,
								avg(sop97_2) as avg_sop97_2, std(sop97_2) as std_sop97_2,
								avg(asu2009_17) as avg_asu2009_17, std(asu2009_17) as std_asu2009_17,
								avg(asu2011_08) as avg_asu2011_08, std(asu2011_08) as std_asu2011_08,
								avg(asu2012_01) as avg_asu2012_01, std(asu2012_01) as std_asu2012_01,
								avg(asu2012_02) as avg_asu2012_02, std(asu2012_02) as std_asu2012_02
								

				from ps1 group by fyear
				order by fyear;
				quit;

				proc sql; create table ps3 as select
				a.*, b.*
				from ps1 as a left join ps2 as b
				on a.fyear eq b.fyear
				order by cik, fyear;
				quit;

				/*create raw rel_imp*/

				data ps4; set ps3;
				r_apb25= (apb25 -avg_apb25)/std_apb25;
				r_apb2= (apb2 -avg_apb2)/std_apb2;
				r_apb4= (apb4 -avg_apb4)/std_apb4;
				r_apb9= (apb9 -avg_apb9)/std_apb9;
				r_apb14= (apb14 -avg_apb14)/std_apb14;
				r_apb16= (apb16 -avg_apb16)/std_apb16;
				r_apb17= (apb17 -avg_apb17)/std_apb17;
				r_apb18= (apb18 -avg_apb18)/std_apb18;
				r_apb20= (apb20 -avg_apb20)/std_apb20;
				r_apb21= (apb21 -avg_apb21)/std_apb21;
				r_apb23= (apb23 -avg_apb23)/std_apb23;
				r_apb26= (apb26 -avg_apb26)/std_apb26;
				r_apb29= (apb29 -avg_apb29)/std_apb29;
				r_apb30= (apb30 -avg_apb30)/std_apb30;
				r_arb45= (arb45 -avg_arb45)/std_arb45;
				r_arb51= (arb51 -avg_arb51)/std_arb51;
				r_arb43_2a= (arb43_2a -avg_arb43_2a)/std_arb43_2a;
				r_arb43_3a= (arb43_3a -avg_arb43_3a)/std_arb43_3a;
				r_arb43_3b= (arb43_3b -avg_arb43_3b)/std_arb43_3b;
				r_arb43_4= (arb43_4 -avg_arb43_4)/std_arb43_4;
				r_arb43_7a= (arb43_7a -avg_arb43_7a)/std_arb43_7a;
				r_arb43_7b= (arb43_7b -avg_arb43_7b)/std_arb43_7b;
				r_arb43_9a= (arb43_9a -avg_arb43_9a)/std_arb43_9a;
				r_arb43_9b= (arb43_9b -avg_arb43_9b)/std_arb43_9b;
				r_arb43_10a= (arb43_10a -avg_arb43_10a)/std_arb43_10a;
				r_arb43_11a= (arb43_11a -avg_arb43_11a)/std_arb43_11a;
				r_arb43_11b= (arb43_11b -avg_arb43_11b)/std_arb43_11b;
				r_arb43_11c= (arb43_11c -avg_arb43_11c)/std_arb43_11c;
				r_arb43_12= (arb43_12 -avg_arb43_12)/std_arb43_12;
				r_con5_6= (con5_6 -avg_con5_6)/std_con5_6;
				r_eitf00_21= (eitf00_21 -avg_eitf00_21)/std_eitf00_21;
				r_eitf94_03= (eitf94_03 -avg_eitf94_03)/std_eitf94_03;
				r_fas2= (fas2 - avg_fas2)/std_fas2;
				r_fas5= (fas5 - avg_fas5)/std_fas5;
				r_fas7= (fas7 - avg_fas7)/std_fas7;
				r_fas13= (fas13 - avg_fas13)/std_fas13;
				r_fas15= (fas15 - avg_fas15)/std_fas15;
				r_fas16= (fas16 - avg_fas16)/std_fas16;
				r_fas19= (fas19 - avg_fas19)/std_fas19;
				r_fas34= (fas34 - avg_fas34)/std_fas34;
				r_fas35= (fas35 - avg_fas35)/std_fas35;
				r_fas43= (fas43 - avg_fas43)/std_fas43;
				r_fas45= (fas45 - avg_fas45)/std_fas45;
				r_fas47= (fas47 - avg_fas47)/std_fas47;
				r_fas48= (fas48 - avg_fas48)/std_fas48;
				r_fas49= (fas49 - avg_fas49)/std_fas49;
				r_fas50= (fas50 - avg_fas50)/std_fas50;
				r_fas51= (fas51 - avg_fas51)/std_fas51;
				r_fas52= (fas52 - avg_fas52)/std_fas52;
				r_fas53= (fas53 - avg_fas53)/std_fas53;
				r_fas57= (fas57 - avg_fas57)/std_fas57;
				r_fas60= (fas60 - avg_fas60)/std_fas60;
				r_fas61= (fas61 - avg_fas61)/std_fas61;
				r_fas63= (fas63 - avg_fas63)/std_fas63;
				r_fas65= (fas65 - avg_fas65)/std_fas65;
				r_fas66= (fas66 - avg_fas66)/std_fas66;
				r_fas67= (fas67 - avg_fas67)/std_fas67;
				r_fas68= (fas68 - avg_fas68)/std_fas68;
				r_fas71= (fas71 - avg_fas71)/std_fas71;
				r_fas77= (fas77 - avg_fas77)/std_fas77;
				r_fas80= (fas80 - avg_fas80)/std_fas80;
				r_fas86= (fas86 - avg_fas86)/std_fas86;
				r_fas87= (fas87 - avg_fas87)/std_fas87;
				r_fas88= (fas88 - avg_fas88)/std_fas88;
				r_fas97= (fas97 - avg_fas97)/std_fas97;
				r_fas101= (fas101 - avg_fas101)/std_fas101;
				r_fas105= (fas105 - avg_fas105)/std_fas105;
				r_fas106= (fas106 - avg_fas106)/std_fas106;
				r_fas107= (fas107 - avg_fas107)/std_fas107;
				r_fas109= (fas109 - avg_fas109)/std_fas109;
				r_fas113= (fas113 - avg_fas113)/std_fas113;
				r_fas115= (fas115 - avg_fas115)/std_fas115;
				r_fas116= (fas116 - avg_fas116)/std_fas116;
				r_fas119= (fas119 - avg_fas119)/std_fas119;
				r_fas121= (fas121 - avg_fas121)/std_fas121;
				r_fas123= (fas123 - avg_fas123)/std_fas123;
				r_fas123r= (fas123r - avg_fas123r)/std_fas123r;
				r_fas125= (fas125 - avg_fas125)/std_fas125;
				r_fas130= (fas130 - avg_fas130)/std_fas130;
				r_fas132= (fas132 - avg_fas132)/std_fas132;
				r_fas132r= (fas132r - avg_fas132r)/std_fas132r;
				r_fas133= (fas133 - avg_fas133)/std_fas133;
				r_fas140= (fas140 - avg_fas140)/std_fas140;
				r_fas141= (fas141 - avg_fas141)/std_fas141;
				r_fas142= (fas142 - avg_fas142)/std_fas142;
				r_fas143= (fas143 - avg_fas143)/std_fas143;
				r_fas144= (fas144 - avg_fas144)/std_fas144;
				r_fas146= (fas146 - avg_fas146)/std_fas146;
				r_fas150= (fas150 - avg_fas150)/std_fas150;
				r_fas154= (fas154 - avg_fas154)/std_fas154;
				r_sab101= (sab101 - avg_sab101)/std_sab101;
				r_sop97_2= (sop97_2 - avg_sop97_2)/std_sop97_2;
				r_asu2009_17 = (asu2009_17 - avg_asu2009_17)/std_asu2009_17;
				r_asu2011_08 = (asu2011_08 - avg_asu2011_08)/std_asu2011_08;
				r_asu2012_01 = (asu2012_01 - avg_asu2012_01)/std_asu2012_01;
				r_asu2012_02 = (asu2012_02 - avg_asu2012_02)/std_asu2012_02;
								
				run;


				/*create minimum rel_imp per year*/

				proc sql; create table ps5 as select distinct
				fyear,
								min(r_apb25) as min_apb25, 
								min(r_apb2) as min_apb2, 
								min(r_apb4) as min_apb4, 
								min(r_apb9) as min_apb9, 
								min(r_apb14) as min_apb14, 
								min(r_apb16) as min_apb16, 
								min(r_apb17) as min_apb17,				
								min(r_apb18) as min_apb18, 
								min(r_apb20) as min_apb20, 
								min(r_apb21) as min_apb21, 
								min(r_apb23) as min_apb23, 
								min(r_apb26) as min_apb26, 
								min(r_apb29) as min_apb29, 
								min(r_apb30) as min_apb30, 
								min(r_arb45) as min_arb45, 
								min(r_arb51) as min_arb51, 
						min(r_arb43_2a) as min_arb43_2a,
						min(r_arb43_3a) as min_arb43_3a, 
						min(r_arb43_3b) as min_arb43_3b, 
						min(r_arb43_4) as min_arb43_4, 
						min(r_arb43_7a) as min_arb43_7a, 
						min(r_arb43_7b) as min_arb43_7b,
						min(r_arb43_9a) as min_arb43_9a, 
						min(r_arb43_9b) as min_arb43_9b, 
						min(r_arb43_10a) as min_arb43_10a, 
						min(r_arb43_11a) as min_arb43_11a,
						min(r_arb43_11b) as min_arb43_11b, 
						min(r_arb43_11c) as min_arb43_11c, 
						min(r_arb43_12) as min_arb43_12, 
						min(r_con5_6) as min_con5_6, 
						min(r_eitf00_21) as min_eitf00_21, 
						min(r_eitf94_03) as min_eitf94_03, 
								min(r_fas2) as min_fas2, 
								min(r_fas5) as min_fas5, 
								min(r_fas7) as min_fas7, 
								min(r_fas13) as min_fas13, 
								min(r_fas15) as min_fas15, 
								min(r_fas16) as min_fas16, 
								min(r_fas19) as min_fas19, 
								min(r_fas34) as min_fas34, 
								min(r_fas35) as min_fas35, 
								min(r_fas43) as min_fas43, 
								min(r_fas45) as min_fas45, 
								min(r_fas47) as min_fas47, 
								min(r_fas48) as min_fas48, 
								min(r_fas49) as min_fas49, 
								min(r_fas50) as min_fas50, 
								min(r_fas51) as min_fas51, 
								min(r_fas52) as min_fas52, 
								min(r_fas53) as min_fas53, 
								min(r_fas57) as min_fas57, 
								min(r_fas60) as min_fas60, 
								min(r_fas61) as min_fas61, 
								min(r_fas63) as min_fas63, 
								min(r_fas65) as min_fas65, 
								min(r_fas66) as min_fas66, 
								min(r_fas67) as min_fas67, 
								min(r_fas68) as min_fas68, 
								min(r_fas71) as min_fas71, 
								min(r_fas77) as min_fas77, 
								min(r_fas80) as min_fas80, 
								min(r_fas86) as min_fas86, 
								min(r_fas87) as min_fas87, 
								min(r_fas88) as min_fas88,				
								min(r_fas97) as min_fas97, 
								min(r_fas101) as min_fas101, 
								min(r_fas105) as min_fas105, 
								min(r_fas106) as min_fas106, 
								min(r_fas107) as min_fas107, 
								min(r_fas109) as min_fas109, 
								min(r_fas113) as min_fas113, 
								min(r_fas115) as min_fas115, 
								min(r_fas116) as min_fas116, 
								min(r_fas119) as min_fas119, 
								min(r_fas121) as min_fas121, 
								min(r_fas123) as min_fas123, 
							min(r_fas123r) as min_fas123r, 
								min(r_fas125) as min_fas125, 
								min(r_fas130) as min_fas130,				
								min(r_fas132) as min_fas132, 
							min(r_fas132r) as min_fas132r, 
								min(r_fas133) as min_fas133, 
								min(r_fas140) as min_fas140, 
								min(r_fas141) as min_fas141, 
								min(r_fas142) as min_fas142,				
								min(r_fas143) as min_fas143, 
								min(r_fas144) as min_fas144, 
								min(r_fas146) as min_fas146, 
								min(r_fas150) as min_fas150, 
								min(r_fas154) as min_fas154, 
								min(r_sab101) as min_sab101, 
								min(r_sop97_2) as min_sop97_2,
				min(r_asu2009_17)  as min_asu2009_17,
				min(r_asu2011_08) as min_asu2011_08,
				min(r_asu2012_01) as min_asu2012_01,
				min(r_asu2012_02) as min_asu2012_02
					 

				from ps4 group by fyear
				order by fyear;
				quit;


				proc sql; create table ps6 as select
				a.*, b.*
				from ps4 as a left join ps5 as b
				on a.fyear eq b.fyear
				order by cik, fyear;
				quit;

				/*subtract minimum to get final rel_imp*/

				data ps7; set ps6;
				ri_apb25= r_apb25 - min_apb25;
				ri_apb2= r_apb2 -min_apb2;
				ri_apb4= r_apb4 -min_apb4;
				ri_apb9= r_apb9 -min_apb9;
				ri_apb14= r_apb14 -min_apb14;
				ri_apb16= r_apb16 -min_apb16;
				ri_apb17= r_apb17 -min_apb17;
				ri_apb18= r_apb18 -min_apb18;
				ri_apb20= r_apb20 -min_apb20;
				ri_apb21= r_apb21 -min_apb21;
				ri_apb23= r_apb23 -min_apb23;
				ri_apb26= r_apb26 -min_apb26;
				ri_apb29= r_apb29 -min_apb29;
				ri_apb30= r_apb30 -min_apb30;
				ri_arb45= r_arb45 -min_arb45;
				ri_arb51= r_arb51 -min_arb51;
				ri_arb43_2a= r_arb43_2a -min_arb43_2a;
				if ri_arb43_2a eq . then ri_arb43_2a=0;
				ri_arb43_3a= r_arb43_3a -min_arb43_3a;
				ri_arb43_3b= r_arb43_3b -min_arb43_3b;
				ri_arb43_4= r_arb43_4 -min_arb43_4;
				ri_arb43_7a= r_arb43_7a -min_arb43_7a;
				ri_arb43_7b= r_arb43_7b -min_arb43_7b;
				ri_arb43_9a= r_arb43_9a -min_arb43_9a;
				ri_arb43_9b= r_arb43_9b -min_arb43_9b;
				ri_arb43_10a= r_arb43_10a -min_arb43_10a;
				ri_arb43_11a= r_arb43_11a -min_arb43_11a;
				ri_arb43_11b= r_arb43_11b -min_arb43_11b;
				ri_arb43_11c= r_arb43_11c -min_arb43_11c;
				ri_arb43_12= r_arb43_12 -min_arb43_12;
				ri_con5_6= r_con5_6 -min_con5_6;
				ri_eitf00_21= r_eitf00_21 -min_eitf00_21;
				ri_eitf94_03= r_eitf94_03 -min_eitf94_03;
				ri_fas2= r_fas2 - min_fas2;
				ri_fas5= r_fas5 - min_fas5;
				ri_fas7= r_fas7 - min_fas7;
				ri_fas13= r_fas13 - min_fas13;
				ri_fas15= r_fas15 - min_fas15;
				ri_fas16= r_fas16 - min_fas16;
				ri_fas19= r_fas19 - min_fas19;
				ri_fas34= r_fas34 - min_fas34;
				ri_fas35= r_fas35 - min_fas35;
				ri_fas43= r_fas43 - min_fas43;
				ri_fas45= r_fas45 - min_fas45;
				ri_fas47= r_fas47 - min_fas47;
				ri_fas48= r_fas48 - min_fas48;
				ri_fas49= r_fas49 - min_fas49;
				ri_fas50= r_fas50 - min_fas50;
				ri_fas51= r_fas51 - min_fas51;
				ri_fas52= r_fas52 - min_fas52;
				ri_fas53= r_fas53 - min_fas53;
				ri_fas57= r_fas57 - min_fas57;
				ri_fas60= r_fas60 - min_fas60;
				ri_fas61= r_fas61 - min_fas61;
				ri_fas63= r_fas63 - min_fas63;
				ri_fas65= r_fas65 - min_fas65;
				ri_fas66= r_fas66 - min_fas66;
				ri_fas67= r_fas67 - min_fas67;
				ri_fas68= r_fas68 - min_fas68;
				ri_fas71= r_fas71 - min_fas71;
				ri_fas77= r_fas77 - min_fas77;
				ri_fas80= r_fas80 - min_fas80;
				ri_fas86= r_fas86 - min_fas86;
				ri_fas87= r_fas87 - min_fas87;
				ri_fas88= r_fas88 - min_fas88;
				ri_fas97= r_fas97 - min_fas97;
				ri_fas101= r_fas101 - min_fas101;
				ri_fas105= r_fas105 - min_fas105;
				ri_fas106= r_fas106 - min_fas106;
				ri_fas107= r_fas107 - min_fas107;
				ri_fas109= r_fas109 - min_fas109;
				ri_fas113= r_fas113 - min_fas113;
				ri_fas115= r_fas115 - min_fas115;
				ri_fas116= r_fas116 - min_fas116;
				ri_fas119= r_fas119 - min_fas119;
				ri_fas121= r_fas121 - min_fas121;
				ri_fas123= r_fas123 - min_fas123;
				ri_fas123r= r_fas123r - min_fas123r;
				ri_fas125= r_fas125 - min_fas125;
				ri_fas130= r_fas130 - min_fas130;
				ri_fas132= r_fas132 - min_fas132;
				ri_fas132r= r_fas132r - min_fas132r;
				ri_fas133= r_fas133 - min_fas133;
				ri_fas140= r_fas140 - min_fas140;
				ri_fas141= r_fas141 - min_fas141;
				ri_fas142= r_fas142 - min_fas142;
				ri_fas143= r_fas143 - min_fas143;
				ri_fas144= r_fas144 - min_fas144;
				ri_fas146= r_fas146 - min_fas146;
				ri_fas150= r_fas150 - min_fas150;
				ri_fas154= r_fas154 - min_fas154;
				ri_sab101= r_sab101 - min_sab101;
				ri_sop97_2= r_sop97_2 - min_sop97_2;

				ri_asu2009_17=r_asu2009_17 -min_asu2009_17;
				ri_asu2011_08=r_asu2011_08 -min_asu2011_08;
				ri_asu2012_01=r_asu2012_01- min_asu2012_01;
				ri_asu2012_02=r_asu2012_02 -min_asu2012_02;
					 

				run;

				data ps8; set ps7;
				keep gvkey cik fyear datadate permno ri_apb25 ri_apb2 file_date f_ftype
				ri_apb4 ri_apb9 ri_apb14 ri_apb16 ri_apb17 ri_apb18 ri_apb20 ri_apb21 ri_apb23 ri_apb26 ri_apb29 ri_apb30 ri_arb45 ri_arb51 ri_arb43_2a ri_arb43_3a 
				ri_arb43_3b ri_arb43_4 ri_arb43_7a ri_arb43_7b ri_arb43_9a ri_arb43_9b ri_arb43_10a ri_arb43_11a ri_arb43_11b ri_arb43_11c ri_arb43_12 ri_con5_6 ri_eitf00_21 ri_eitf94_03 ri_fas2 ri_fas5 
				ri_fas7 ri_fas13 ri_fas15 ri_fas16 ri_fas19 ri_fas34 ri_fas35 ri_fas43 ri_fas45 ri_fas47 ri_fas48 ri_fas49 ri_fas50 ri_fas51 ri_fas52 ri_fas53 
				ri_fas57 ri_fas60 ri_fas61 ri_fas63 ri_fas65 ri_fas66 ri_fas67 ri_fas68 ri_fas71 ri_fas77 ri_fas80 ri_fas86 ri_fas87 ri_fas88 ri_fas97 ri_fas101 
				ri_fas105 ri_fas106 ri_fas107 ri_fas109 ri_fas113 ri_fas115 ri_fas116 ri_fas119 ri_fas121 ri_fas123 ri_fas123r ri_fas125 ri_fas130 ri_fas132 ri_fas132r ri_fas133 
				ri_fas140 ri_fas141 ri_fas142 ri_fas143 ri_fas144 ri_fas146 ri_fas150 ri_fas154 ri_sab101 ri_sop97_2
				ri_asu2009_17 ri_asu2011_08 ri_asu2012_01 ri_asu2012_02;
				run;

				data dperm.rel_imp_longest; set ps8;run;
				data ps8; set dperm.rel_imp_longest;run;


			/*END:x.Create rel_imp for folsom sample*/
			/*BEGIN:xx.create limit_discr*/
				libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data';
				libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
				libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
				/*bring in word count data*/


				data ps8; set dperm.rel_imp_longest;run;


				proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\imp1_lengthrraz.xlsx'
				dbms=xlsx OUT = imp1;run;

				data ps9; set ps8;
				if fyear ne . then year=fyear;
				if fyear eq . and month(datadate) le 5 then year=year(datadate)-1;
				if fyear eq . and month(datadate) gt 5 then year=year(datadate);
				run;

				proc import datafile = 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\Data\mdata2.xlsx'
				dbms=xlsx OUT = mdataa;run;

				data mdata3; set mdataa;
				/*I added this line to include fas141r which is included
				in the word counts of 141*/
				max_fas141=max_fas141r;
				id=1;
				if min_apb2 ne .;
				drop ko kp;
				run;
				data ps9; set ps9;
				id=1;
				run;

				proc sql; create table ps10 as select
				a.*, b.*
				from ps9 as a left join mdata3 b
				on a.id=b.id
				order by cik, fyear;
				quit;

				data ps11 ; set ps10;
				if fyear lt min_apb25 then ri_apb25=0;
				if fyear gt max_apb25 then ri_apb25=0;

				if fyear lt min_apb4 then ri_apb4=0;
				if fyear gt max_apb4 then ri_apb4=0;

				if fyear lt min_apb9 then ri_apb9=0;
				if fyear gt max_apb9 then ri_apb9=0;

				if fyear lt min_apb14 then ri_apb14=0;
				if fyear gt max_apb14 then ri_apb14=0;

				if fyear lt min_apb16 then ri_apb16=0;
				if fyear gt max_apb16 then ri_apb16=0;

				if fyear lt min_apb17 then ri_apb17=0;
				if fyear gt max_apb17 then ri_apb17=0;

				if fyear lt min_apb18 then ri_apb18=0;
				if fyear gt max_apb18 then ri_apb18=0;

				if fyear lt min_apb20 then ri_apb20=0;
				if fyear gt max_apb20 then ri_apb20=0;

				if fyear lt min_apb21 then ri_apb21=0;
				if fyear gt max_apb21 then ri_apb21=0;

				if fyear lt min_apb23 then ri_apb23=0;
				if fyear gt max_apb23 then ri_apb23=0;

				if fyear lt min_apb26 then ri_apb26=0;
				if fyear gt max_apb26 then ri_apb26=0;

				if fyear lt min_apb29 then ri_apb29=0;
				if fyear gt max_apb29 then ri_apb29=0;

				if fyear lt min_apb30 then ri_apb30=0;
				if fyear gt max_apb30 then ri_apb30=0;

				if fyear lt min_arb45 then ri_arb45=0;
				if fyear gt max_arb45 then ri_arb45=0;

				if fyear lt min_arb51 then ri_arb51=0;
				if fyear gt max_arb51 then ri_arb51=0;

				if fyear lt min_arb43_2a then ri_arb43_2a=0;
				if fyear gt max_arb43_2a then ri_arb43_2a=0;

				if fyear lt min_arb43_3a then ri_arb43_3a=0;
				if fyear gt max_arb43_3a then ri_arb43_3a=0;

				if fyear lt min_arb43_3b then ri_arb43_3b=0;
				if fyear gt max_arb43_3b then ri_arb43_3b=0;

				if fyear lt min_arb43_4 then ri_arb43_4=0;
				if fyear gt max_arb43_4 then ri_arb43_4=0;

				if fyear lt min_arb43_7a then ri_arb43_7a=0;
				if fyear gt max_arb43_7a then ri_arb43_7a=0;

				if fyear lt min_arb43_7b then ri_arb43_7b=0;
				if fyear gt max_arb43_7b then ri_arb43_7b=0;

				if fyear lt min_arb43_9a then ri_arb43_9a=0;
				if fyear gt max_arb43_9a then ri_arb43_9a=0;

				if fyear lt min_arb43_9b then ri_arb43_9b=0;
				if fyear gt max_arb43_9b then ri_arb43_9b=0;

				if fyear lt min_arb43_10a then ri_arb43_10a=0;
				if fyear gt max_arb43_10a then ri_arb43_10a=0;

				if fyear lt min_arb43_11a then ri_arb43_11a=0;
				if fyear gt max_arb43_11a then ri_arb43_11a=0;

				if fyear lt min_arb43_11b then ri_arb43_11b=0;
				if fyear gt max_arb43_11b then ri_arb43_11b=0;

				if fyear lt min_arb43_11c then ri_arb43_11c=0;
				if fyear gt max_arb43_11c then ri_arb43_11c=0;

				if fyear lt min_arb43_12 then ri_arb43_12=0;
				if fyear gt max_arb43_12 then ri_arb43_12=0;

				if fyear lt min_con5_6 then ri_con5_6=0;
				if fyear gt max_con5_6 then ri_con5_6=0;

				if fyear lt min_eitf00_21 then ri_eitf00_21=0;
				if fyear gt max_eitf00_21 then ri_eitf00_21=0;

				if fyear lt min_eitf94_3 then ri_eitf94_03=0;
				if fyear gt max_eitf94_3 then ri_eitf94_03=0;

				if fyear lt min_fas2 then ri_fas2=0;
				if fyear gt max_fas2 then ri_fas2=0;

				if fyear lt min_fas5 then ri_fas5=0;
				if fyear gt max_fas5 then ri_fas5=0;

				if fyear lt min_fas7 then ri_fas7=0;
				if fyear gt max_fas7 then ri_fas7=0;

				if fyear lt min_fas13 then ri_fas13=0;
				if fyear gt max_fas13 then ri_fas13=0;

				if fyear lt min_fas15 then ri_fas15=0;
				if fyear gt max_fas15 then ri_fas15=0;

				if fyear lt min_fas16 then ri_fas16=0;
				if fyear gt max_fas16 then ri_fas16=0;

				if fyear lt min_fas19 then ri_fas19=0;
				if fyear gt max_fas19 then ri_fas19=0;

				if fyear lt min_fas34 then ri_fas34=0;
				if fyear gt max_fas34 then ri_fas34=0;

				if fyear lt min_fas35 then ri_fas35=0;
				if fyear gt max_fas35 then ri_fas35=0;

				if fyear lt min_fas43 then ri_fas43=0;
				if fyear gt max_fas43 then ri_fas43=0;

				if fyear lt min_fas45 then ri_fas45=0;
				if fyear gt max_fas45 then ri_fas45=0;

				if fyear lt min_fas47 then ri_fas47=0;
				if fyear gt max_fas47 then ri_fas47=0;

				if fyear lt min_fas48 then ri_fas48=0;
				if fyear gt max_fas48 then ri_fas48=0;

				if fyear lt min_fas49 then ri_fas49=0;
				if fyear gt max_fas49 then ri_fas49=0;

				if fyear lt min_fas50 then ri_fas50=0;
				if fyear gt max_fas50 then ri_fas50=0;

				if fyear lt min_fas51 then ri_fas51=0;
				if fyear gt max_fas51 then ri_fas51=0;

				if fyear lt min_fas52 then ri_fas52=0;
				if fyear gt max_fas52 then ri_fas52=0;

				if fyear lt min_fas53 then ri_fas53=0;
				if fyear gt max_fas53 then ri_fas53=0;

				if fyear lt min_fas57 then ri_fas57=0;
				if fyear gt max_fas57 then ri_fas57=0;

				if fyear lt min_fas60 then ri_fas60=0;
				if fyear gt max_fas60 then ri_fas60=0;

				if fyear lt min_fas61 then ri_fas61=0;
				if fyear gt max_fas61 then ri_fas61=0;

				if fyear lt min_fas63 then ri_fas63=0;
				if fyear gt max_fas63 then ri_fas63=0;

				if fyear lt min_fas65 then ri_fas65=0;
				if fyear gt max_fas65 then ri_fas65=0;

				if fyear lt min_fas66 then ri_fas66=0;
				if fyear gt max_fas66 then ri_fas66=0;

				if fyear lt min_fas67 then ri_fas67=0;
				if fyear gt max_fas67 then ri_fas67=0;

				if fyear lt min_fas68 then ri_fas68=0;
				if fyear gt max_fas68 then ri_fas68=0;

				if fyear lt min_fas71 then ri_fas71=0;
				if fyear gt max_fas71 then ri_fas71=0;

				if fyear lt min_fas77 then ri_fas77=0;
				if fyear gt max_fas77 then ri_fas77=0;

				if fyear lt min_fas80 then ri_fas80=0;
				if fyear gt max_fas80 then ri_fas80=0;

				if fyear lt min_fas86 then ri_fas86=0;
				if fyear gt max_fas86 then ri_fas86=0;

				if fyear lt min_fas87 then ri_fas87=0;
				if fyear gt max_fas87 then ri_fas87=0;

				if fyear lt min_fas88 then ri_fas88=0;
				if fyear gt max_fas88 then ri_fas88=0;

				if fyear lt min_fas97 then ri_fas97=0;
				if fyear gt max_fas97 then ri_fas97=0;

				if fyear lt min_fas101 then ri_fas101=0;
				if fyear gt max_fas101 then ri_fas101=0;

				if fyear lt min_fas105 then ri_fas105=0;
				if fyear gt max_fas105 then ri_fas105=0;

				if fyear lt min_fas106 then ri_fas106=0;
				if fyear gt max_fas106 then ri_fas106=0;

				if fyear lt min_fas107 then ri_fas107=0;
				if fyear gt max_fas107 then ri_fas107=0;

				if fyear lt min_fas109 then ri_fas109=0;
				if fyear gt max_fas109 then ri_fas109=0;

				if fyear lt min_fas113 then ri_fas113=0;
				if fyear gt max_fas113 then ri_fas113=0;

				if fyear lt min_fas115 then ri_fas115=0;
				if fyear gt max_fas115 then ri_fas115=0;

				if fyear lt min_fas119 then ri_fas116=0;
				if fyear gt max_fas119 then ri_fas116=0;

				if fyear lt min_fas121 then ri_fas121=0;
				if fyear gt max_fas121 then ri_fas121=0;

				if fyear lt min_fas123 then ri_fas123=0;
				if fyear gt max_fas123 then ri_fas123=0;

				if fyear lt min_fas123r then ri_fas123r=0;
				if fyear gt max_fas123r then ri_fas123r=0;

				if fyear lt min_fas125 then ri_fas125=0;
				if fyear gt max_fas125 then ri_fas125=0;

				if fyear lt min_fas130 then ri_fas130=0;
				if fyear gt max_fas130 then ri_fas130=0;

				if fyear lt min_fas132 then ri_fas132=0;
				if fyear gt max_fas132 then ri_fas132=0;

				if fyear lt min_fas132r then ri_fas132r=0;
				if fyear gt max_fas132r then ri_fas132r=0;

				if fyear lt min_fas133 then ri_fas133=0;
				if fyear gt max_fas133 then ri_fas133=0;

				if fyear lt min_fas140 then ri_fas140=0;
				if fyear gt max_fas140 then ri_fas140=0;

				if fyear lt min_fas141 then ri_fas141=0;
				if fyear gt max_fas141 then ri_fas141=0;

				if fyear lt min_fas142 then ri_fas142=0;
				if fyear gt max_fas142 then ri_fas142=0;

				if fyear lt min_fas143 then ri_fas143=0;
				if fyear gt max_fas143 then ri_fas143=0;

				if fyear lt min_fas144 then ri_fas144=0;
				if fyear gt max_fas144 then ri_fas144=0;

				if fyear lt min_fas146 then ri_fas146=0;
				if fyear gt max_fas146 then ri_fas146=0;

				if fyear lt min_fas150 then ri_fas150=0;
				if fyear gt max_fas150 then ri_fas150=0;
				if fyear lt min_fas154 then ri_fas154=0;
				if fyear gt max_fas154 then ri_fas154=0;
				if fyear lt min_sab101 then ri_sab101=0;
				if fyear gt max_sab101 then ri_sab101=0;
				if fyear lt min_sop97_2 then ri_sop97_2=0;
				if fyear gt max_sop97_2 then ri_sop97_2=0;
				if fyear lt 2009 then ri_asu2009_17=0;
				if fyear lt 2011 then ri_asu2011_08=0;
				if fyear lt 2012 then ri_asu2012_01=0;
				if fyear lt 2012 then ri_asu2012_02=0;
				run;


				proc sql; create table ds1 as select
				a.*, b.*
				from ps11 as a left join imp1 b
				on a.year=b.year
				order by cik, fyear;
				quit;


				data ds1a; set ds1;
				if ri_apb25 eq . then  ri_apb25=0;    
				if apb25 eq . then  apb25=0; 
				if ri_apb2  eq . then  ri_apb2=0;           
				if apb2 eq . then  apb2=0; 
				if ri_apb4 eq . then  ri_apb4=0;          
				if apb4 eq . then  apb4=0; 
				if ri_apb9 eq . then  ri_apb9=0;          
				if apb9 eq . then  apb9=0; 
				if ri_apb14 eq . then  ri_apb14=0;           
				if apb14 eq . then apb14=0; 
				if ri_apb16 eq . then  ri_apb16=0;          
				if apb16 eq . then apb16=0; 
				if ri_apb17 eq . then  ri_apb17=0;         
				if apb17 eq . then apb17=0; 
				if ri_apb18 eq . then  ri_apb18=0;         
				if apb18 eq . then  apb18=0; 
				if ri_apb20 eq . then  ri_apb20=0;          
				if apb20 eq . then  apb20=0; 
				if ri_apb21 eq . then  ri_apb21=0;          
				if apb21 eq . then  apb21=0; 
				if ri_apb23 eq . then  ri_apb23=0;          
				if apb23 eq . then  apb23=0; 
				if ri_apb26 eq . then  ri_apb26=0;          
				if apb26 eq . then  apb26=0; 
				if ri_apb29 eq . then  ri_apb29=0;          
				if apb29 eq . then  apb29=0; 
				if ri_apb30 eq . then  ri_apb30=0;          
				if apb30 eq . then  apb30=0; 
				if ri_arb45 eq .  then ri_arb45=0;        
				if arb45  eq . then arb45=0;
				if ri_arb51  eq . then ri_arb51=0;
				if arb51  eq . then arb51=0;
				if ri_arb43_2a  eq . then ri_arb43_2a=0;        
				if arb43_2a eq . then arb43_2a=0;    
				if ri_arb43_3a eq . then ri_arb43_3a=0;              
				if arb43_3a  eq . then arb43_3a=0;  
				if ri_arb43_3b eq . then ri_arb43_3b=0;            
				if arb43_3b  eq . then arb43_3b=0;  
				if ri_arb43_4  eq . then ri_arb43_4=0;           
				if arb43_4  eq . then arb43_4=0;  
				if ri_arb43_7a eq . then ri_arb43_7a=0;           
				if arb43_7a  eq . then arb43_7a=0;  
				if ri_arb43_7b eq . then ri_arb43_7b=0;            
				if arb43_7b  eq . then arb43_7b=0;  
				if ri_arb43_9a eq . then ri_arb43_9a=0;            
				if arb43_9a  eq . then arb43_9a=0;  
				if ri_arb43_9b eq . then ri_arb43_9b=0;            
				if arb43_9b  eq . then arb43_9b=0;  
				if ri_arb43_10a  eq . then ri_arb43_10a=0;           
				if arb43_10a  eq . then arb43_10a=0;  
				if ri_arb43_11a  eq . then ri_arb43_11a=0;            
				if arb43_11a  eq . then arb43_11a=0;  
				if ri_arb43_11b  eq . then ri_arb43_11b=0;           
				if arb43_11b  eq . then arb43_11b=0;  
				if ri_arb43_11c  eq . then ri_arb43_11c=0;          
				if arb43_11c  eq . then arb43_11c=0;  
				if ri_arb43_12   eq . then ri_arb43_12=0;          
				if arb43_12  eq . then arb43_12=0;  
				if ri_con5_6     eq . then ri_con5_6=0;       
				if con5_6  eq . then con5_6=0;  
				if ri_eitf00_21  eq . then ri_eitf00_21=0;           
				if abs00_21  eq . then abs00_21=0;  
				if ri_eitf94_03  eq . then ri_eitf94_03=0;           
				if abs94_03  eq . then abs94_03=0;  
				if ri_fas2       eq . then ri_fas2=0;      
				if fas2  eq . then fas2=0;  
				if ri_fas5       eq . then ri_fas5=0;      
				if fas5  eq . then fas5=0;  
				if ri_fas7       eq . then ri_fas7=0;      
				if fas7  eq . then fas7=0;  
				if ri_fas13      eq . then ri_fas13=0;       
				if fas13  eq . then fas13=0;  
				if ri_fas15      eq . then ri_fas15=0;       
				if fas15  eq . then fas15=0;  
				if ri_fas16      eq . then ri_fas16=0;      
				if fas16  eq . then fas16=0;  
				if ri_fas19      eq . then ri_fas19=0;       
				if  fas19  eq . then fas19=0;  
				if ri_fas34      eq . then ri_fas34=0;      
				if fas34  eq . then fas34=0;  
				if ri_fas35      eq . then ri_fas35=0;      
				if fas35  eq . then fas35=0;  
				if ri_fas43      eq . then ri_fas43=0;       
				if fas43  eq . then fas43=0;  
				if ri_fas45      eq . then ri_fas45=0;      
				if fas45  eq . then fas45=0;  
				if ri_fas47      eq . then ri_fas47=0;       
				if fas47  eq . then fas47=0;  
				if ri_fas48      eq . then ri_fas48=0;      
				if fas48  eq . then fas48=0;  
				if ri_fas49      eq . then ri_fas49=0;      
				if fas49  eq . then fas49=0;  
				if ri_fas50      eq . then ri_fas50=0;      
				if fas50  eq . then fas50=0;  
				if ri_fas51      eq . then ri_fas51=0;      
				if fas51  eq . then fas51=0;  
				if ri_fas52      eq . then ri_fas52=0;      
				if fas52  eq . then fas52=0;  
				if ri_fas53      eq . then ri_fas53=0;       
				if fas53  eq . then fas53=0;  
				if ri_fas57      eq . then ri_fas57=0;      
				if fas57  eq . then fas57=0;  
				if ri_fas60      eq . then ri_fas60=0;      
				if fas60  eq . then fas60=0;  
				if ri_fas61      eq . then ri_fas61=0;       
				if fas61  eq . then fas61=0;  
				if ri_fas63      eq . then ri_fas63=0;       
				if fas63  eq . then fas63=0;  
				if ri_fas65      eq . then ri_fas65=0;       
				if fas65  eq . then fas65=0;  
				if ri_fas66      eq . then ri_fas66=0;       
				if fas66  eq . then fas66=0;  
				if ri_fas67      eq . then ri_fas67=0;       
				if fas67  eq . then fas67=0;  
				if ri_fas68      eq . then ri_fas68=0;       
				if fas68  eq . then fas68=0;  
				if ri_fas71      eq . then ri_fas71=0;       
				if fas71  eq . then fas71=0;  
				if ri_fas77      eq . then ri_fas77=0;       
				if fas77  eq . then fas77=0;  
				if ri_fas80      eq . then ri_fas80=0;       
				if fas80  eq . then fas80=0;  
				if ri_fas86      eq . then ri_fas86=0;       
				if fas86  eq . then fas86=0;  
				if ri_fas87      eq . then ri_fas87=0;       
				if fas87  eq . then fas87=0;  
				if ri_fas88      eq . then ri_fas88=0;      
				if fas88  eq . then fas88=0;  
				if ri_fas97      eq . then ri_fas97=0;       
				if fas97  eq . then fas97=0;  
				if ri_fas101     eq . then ri_fas101=0;        
				if fas101  eq . then fas101=0;  
				if ri_fas105     eq . then ri_fas105=0;        
				if fas105  eq . then fas105=0;  
				if ri_fas106     eq . then ri_fas106=0;        
				if fas106  eq . then fas106=0;  
				if ri_fas107     eq . then ri_fas107=0;        
				if fas107  eq . then fas107=0;  
				if ri_fas109     eq . then ri_fas109=0;        
				if fas109  eq . then fas109=0;  
				if ri_fas113     eq . then ri_fas113=0;        
				if fas113  eq . then fas113=0;  
				if ri_fas115     eq . then ri_fas115=0;        
				if fas115  eq . then fas115=0;  
				if ri_fas116     eq . then ri_fas116=0;        
				if fas116  eq . then fas116=0;  
				if ri_fas119     eq . then ri_fas119=0;        
				if fas119  eq . then fas119=0;  
				if ri_fas121     eq . then ri_fas121=0;        
				if fas121  eq . then fas121=0;  
				if ri_fas123     eq . then ri_fas123=0;       
				if fas123  eq . then fas123=0;  
				if ri_fas123r    eq . then ri_fas123r=0;       
				if fas123r  eq . then fas123r=0;  
				if ri_fas125     eq . then ri_fas125=0;        
				if fas125  eq . then fas125=0;  
				if ri_fas130     eq . then ri_fas130=0;        
				if fas130  eq . then fas130=0;  
				if ri_fas132     eq . then ri_fas132=0;        
				if fas132  eq . then fas132=0;  
				if ri_fas132r    eq . then ri_fas132r=0;        
				if fas132r  eq . then fas132r=0;  
				if ri_fas133     eq . then ri_fas133=0;       
				if fas133  eq . then fas133=0;  
				if ri_fas140     eq . then ri_fas140=0;        
				if fas140  eq . then fas140=0;  
				if ri_fas141     eq . then ri_fas141=0;       
				if fas141  eq . then fas141=0;  
				if ri_fas142     eq . then ri_fas142=0;       
				if fas142  eq . then fas142=0;  
				if ri_fas143     eq . then ri_fas143=0;       
				if fas143  eq . then fas143=0;  
				if ri_fas144     eq . then ri_fas144=0;       
				if fas144  eq . then fas144=0;  
				if ri_fas146     eq . then ri_fas146=0;       
				if fas146  eq . then fas146=0;  
				if ri_fas150     eq . then ri_fas150=0;       
				if fas150  eq . then fas150=0;  
				if ri_fas154     eq . then ri_fas154=0;       
				if fas154  eq . then fas154=0;  
				if ri_sab101 eq . then ri_sab101=0;  
				if sab101  eq . then sab101=0;  
				if ri_sop97_2 eq . then ri_sop97_2=0;  
				if sop97_2  eq . then sop97_2=0;  
				run;


				data ds2; set ds1a;
				Dscore=-1*(ri_apb25*apb25+
				ri_apb2*apb2+
				ri_apb4*apb4+
				ri_apb9*apb9+
				ri_apb14*apb14+
				ri_apb16*apb16+
				ri_apb17*apb17+
				ri_apb18*apb18+
				ri_apb20*apb20+
				ri_apb21*apb21+
				ri_apb23*apb23+
				ri_apb26*apb26+
				ri_apb29*apb29+
				ri_apb30*apb30+
				ri_arb45*arb45+
				ri_arb51*arb51+
				ri_arb43_2a*arb43_2a+
				ri_arb43_3a*arb43_3a+
				ri_arb43_3b*arb43_3b+
				ri_arb43_4*arb43_4+
				ri_arb43_7a*arb43_7a+
				ri_arb43_7b*arb43_7b+
				ri_arb43_9a*arb43_9a+
				ri_arb43_9b*arb43_9b+
				ri_arb43_10a*arb43_10a+
				ri_arb43_11a*arb43_11a+
				ri_arb43_11b*arb43_11b+
				ri_arb43_11c*arb43_11c+
				ri_arb43_12*arb43_12+
				ri_con5_6*con5_6+
				ri_eitf00_21*abs00_21+
				ri_eitf94_03*abs94_03+
				ri_fas2*fas2+
				ri_fas5*fas5+
				ri_fas7*fas7+
				ri_fas13*fas13+
				ri_fas15*fas15+
				ri_fas16*fas16+
				ri_fas19*fas19+
				ri_fas34*fas34+
				ri_fas35*fas35+
				ri_fas43*fas43+
				ri_fas45*fas45+
				ri_fas47*fas47+
				ri_fas48*fas48+
				ri_fas49*fas49+
				ri_fas50*fas50+
				ri_fas51*fas51+
				ri_fas52*fas52+
				ri_fas53*fas53+
				ri_fas57*fas57+
				ri_fas60*fas60+
				ri_fas61*fas61+
				ri_fas63*fas63+
				ri_fas65*fas65+
				ri_fas66*fas66+
				ri_fas67*fas67+
				ri_fas68*fas68+
				ri_fas71*fas71+
				ri_fas77*fas77+
				ri_fas80*fas80+
				ri_fas86*fas86+
				ri_fas87*fas87+
				ri_fas88*fas88+
				ri_fas97*fas97+
				ri_fas101*fas101+
				ri_fas105*fas105+
				ri_fas106*fas106+
				ri_fas107*fas107+
				ri_fas109*fas109+
				ri_fas113*fas113+
				ri_fas115*fas115+
				ri_fas116*fas116+
				ri_fas119*fas119+
				ri_fas121*fas121+
				ri_fas123*fas123+
				ri_fas123r*fas123r+
				ri_fas125*fas125+
				ri_fas130*fas130+
				ri_fas132*fas132+
				ri_fas132r*fas132r+
				ri_fas133*fas133+
				ri_fas140*fas140+
				ri_fas141*fas141+
				ri_fas142*fas142+
				ri_fas143*fas143+
				ri_fas144*fas144+
				ri_fas146*fas146+
				ri_fas150*fas150+
				ri_fas154*fas154+
				ri_sab101*sab101+
				ri_sop97_2*sop97_2);
				run;

				data dperm.dscore_length_rr1z_folsom; set ds2;
				run;

				data dperm.dscore_limited_rr1z_folsom; set ds2;
				keep cik datadate fyear permno gvkey year dscore;
				run;

			/*END:xx.create limit_discr*/
		/*END:i.create limit_discr for Folsom sample*/
		/*BEGIN:ii. create dataset exported to stata*/
				

			/*ASSIGN LIBRARIES*/
			libname dperm 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data';
			libname data 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Create D-SCORE\data';
			libname byu 'C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\BYU SAS Boot Camp\BYU SAS Boot Camp Files - 2014 (original)';
			libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
			libname folsom 'C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\RR round 1\FOLSOM DATA';
			%include "C:\Users\spencery\OneDrive - University of Arizona\U of A\SAS Camp\OLD SAS FILES\SAS\Macros\MacroRepository.sas";

			/*data hsb2 obtained from correspondence with kyle peterson in june 2019*/
			proc import out= hsb2 datafile = "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\RR round 1\FOLSOM DATA\finaldataw.dta";
			run;

			proc sql; create table finalrr2 as select
			a.*, b.dscore*-1 as dscoreRRL
			from hsb2 as a left join data.dscore_limited_length_rr1az as b
			on a.cik=b.cik and a.fyear=b.fyear
			order by gvkey, datadate;
			quit;


			proc sort data=finalrr2; by cik datadate descending dscorerrl;run;
			proc sort data=finalrr2 out=finalrr3 nodupkey; by cik datadate;run;

			proc sql; create table finalrr3a as select
			a.*, b.dscore*-1 as dscoreRRLf
			from finalrr3 as a left join data.dscore_limited_rr1z_folsom as b
			on a.cik=b.cik and a.fyear=b.fyear
			order by gvkey, datadate;
			quit;


			proc sort data=finalrr3a; by cik datadate descending dscorerrlf;run;
			proc sort data=finalrr3a out=finalrr3b nodupkey; by cik datadate;run;


			proc rank data=finalrr3b out=final4 groups=10;
			var dscorerrl dscorerrlf;
			ranks rdscorerrl rdscorerrlf;
			run;

			data final5; set final4;
			drdscorerrl=rdscorerrl/9;
			drdscorerrlf=rdscorerrlf/9;
			run;
			/*this table contributes to paper via stata*/
			proc export data= final5 outfile = "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\RR round 1\FOLSOM DATA\finaldatawdscore1abz.dta";
			run;



		/*END:ii. create dataset exported to stata*/
	/*END:g. Replicate Folsom et al.*/
	/*BEGIN: h. examine what types of forecasts are most prevalent*/
		libname wrds 'C:\Users\spencery\OneDrive - University of Arizona\U of A\WRDS\WRDS';
		

		/*ibes quidance database*/
		data guid; set wrds.det_guidance_1_29_2017;
		year=year(anndats);
		if year ge 2002;
		run;

		proc sort data= guid; by measure year;
		run;

		data g1; set guid;
		if measure = "CPX" then d=1;
		if measure = "DPS" then d=2;
		if measure = "EBS" then d=3;
		if measure = "EBS" then d=3;
		if measure = "EBT" then d=4;
		if measure = "EPS" then d=5;
		if measure = "FFO" then d=6;
		if measure = "GRM" then d=7;
		if measure = "NET" then d=8;
		if measure = "OPR" then d=9;
		if measure = "PRE" then d=10;
		if measure = "ROE" then d=11;
		if measure = "ROA" then d=12;
		if measure = "SAL" then d=13;
		if measure = "GPS" then d=14;
		if measure = "GPSPAR" then d=15;
		ID=CAT(MEASURE,TICKER,"xxxxx",ANNDATS,"zzzzz",ANNTIMS);
		run;



		proc sql; create table G2 as select distinct
		D, 
		count(ID) as COUNTID

		from G1 group by  D
		order by  D ;
		quit;

		PROC PRINT DATA=G2; RUN;
	/*END: h. examine what types of forecasts are most prevalent*/
	
/*END: 2. SAS CREATE DATA FOR MAIN TESTS */
/*BEGIN: 3. STATA CODE*/
	/*Provided in seperate stata file*/
/*END: 3. STATA CODE*/


		
