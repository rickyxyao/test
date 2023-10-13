dm 'output; clear; log; clear';
dm 'odsresults; clear';
ods graphics off;
run;
options ls=256 ps=10000 nocenter;

proc datasets lib=work kill nolist memtype=data; run; quit;

**** ENTER PATH TO FOLDER WHERE YOU HAVE SAVED ALL DATA FILES ****;

libname file '\path\to\folder\';

**** PREPARE QUARTERLY DATA ****;

data sample;
	set file.initial_sample_cc;
    if '1jan2001'd <= datadate <= '31dec2020'd;
    prccq = abs(prccq);
    mve = prccq*cshoq;
    btm = ceqq/mve;

**** INCLUDE CRSP DATA ****;

data crspdata; set file.crspdata_cc;

proc sort data=sample; by permno confcalldate; run;
proc sort data=crspdata; by permno confcalldate; run;

data sample1 sample2;
	merge sample(in=a) crspdata(in=b);
	by permno confcalldate;
	if a eq 1 and b eq 1 then output sample1;
	if a eq 1 and b eq 0 then output sample2;

data sample; set sample1 sample2;

**** INCLUDE TONE ****;

data tone;
infile '\path\to\tone_cc.txt' delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=2 ;
informat filename $200.;
informat tone_pos best32.;
informat tone_neg best32.;
informat tone best32.;
informat tone_posharvard best32.;
informat tone_negharvard best32.;
informat tone_harvard best32.;
format filename $200.;
format tone_pos best12.;
format tone_neg best12.;
format tone best12.;
format tone_posharvard best12.;
format tone_negharvard best12.;
format tone_harvard best12.;
input filename $ tone_pos tone_neg tone tone_posharvard tone_negharvard tone_harvard;
run; quit;

proc sort data=tone; by filename; run;
proc sort data=sample; by filename; run;

data sample1 sample2;
	merge sample(in=a) tone(in=b);
	by filename;
	if a eq 1 and b eq 1 then output sample1;
	if a eq 1 and b eq 0 then output sample2;

data sample; set sample1 sample2; run; quit;

**** INCLUDE ML FILES ****;

%macro import_data(predicted=,path=);

data predicted;
infile &path delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=1 ;
informat filename $200.;
informat actual best32.;
informat predicted best32.;
format filename $200.;
format actual best12.;
format predicted best12.;
input filename $ actual predicted;
run;

data predicted;
        set predicted;
        &predicted = predicted;
        keep filename &predicted;

proc sort data=sample; by filename; run;
proc sort data=predicted nodupkey; by filename; run;

data sample1 sample2;
        merge sample(in=a) predicted(in=b);
        by filename;
        if a eq 1 and b eq 1 then output sample1;
        if a eq 1 and b eq 0 then output sample2;

data sample; set sample1 sample2;
run;
quit;

%mend;

%import_data(predicted=rfpred_car01,path='\path\to\mloutput_rf_car01.txt');
%import_data(predicted=svrpred_car01,path='\path\to\mloutput_svr_car01.txt');
%import_data(predicted=sldapred_car01,path='\path\to\mloutput_slda_car01.txt');

data sample;
	set sample;
	year = year(confcalldate);
	ln_mve = log(mve);
	if mve ne .;
	if btm ne .;
	if tone ne .;
	if instown ne .;
	if earnsurp ne .;
	if pre_alpha ne .;
	if turnover ne .;
	if car01 ne .;
	if rfpred_car01 ne .;
	if svrpred_car01 ne .;
	if sldapred_car01 ne .;
	run; quit;

**** CREATE FACTOR PRED FOR EACH OBSERVATION BASED ON LAST 12 MONTHS OF OTHER FIRMS ****;

data savesample; set sample; keep gvkey confcalldate svrpred_car01 rfpred_car01 sldapred_car01; run; quit;

%macro factor_rolling(year=);

PROC PRINTTO LOG='test1.log' NEW;
RUN;
data test; set savesample;
data test1; set test;
proc sql;
        create table fa as
        select a.gvkey, a.confcalldate,
				b.gvkey as gvkey1, b.confcalldate as confcalldate1, 
				b.svrpred_car01, b.rfpred_car01, b.sldapred_car01
        from test as a, test1 as b
        where intnx('year',a.confcalldate,-1,'same') < b.confcalldate <= a.confcalldate
		and year(a.confcalldate) = &year;
        quit;

proc sort data=fa; by gvkey confcalldate; run;

proc factor data=fa out=fa nfactors=1 rotate=v noprint;
by gvkey confcalldate;
var svrpred_car01 rfpred_car01 sldapred_car01;
run;

data fa;
	set fa;
	where gvkey = gvkey1 and confcalldate = confcalldate1;
	factorpred_car01 = factor1;
	keep gvkey confcalldate factorpred_car01;
	run; quit;

data factor_&year; set fa; run; quit;

PROC PRINTTO LOG=LOG;
RUN; 

%mend;

%factor_rolling(year=2003);
%factor_rolling(year=2004);
%factor_rolling(year=2005);
%factor_rolling(year=2006);
%factor_rolling(year=2007);
%factor_rolling(year=2008);
%factor_rolling(year=2009);
%factor_rolling(year=2010);
%factor_rolling(year=2011);
%factor_rolling(year=2012);
%factor_rolling(year=2013);
%factor_rolling(year=2014);
%factor_rolling(year=2015);
%factor_rolling(year=2016);
%factor_rolling(year=2017);
%factor_rolling(year=2018);
%factor_rolling(year=2019);

data factors;
	set factor_2003 factor_2004 factor_2005 factor_2006 factor_2007 factor_2008 factor_2009 factor_2010 factor_2011 factor_2012 factor_2013 factor_2014 factor_2015 factor_2016 factor_2017 factor_2018 factor_2019;
	run; quit;

proc sort data=factors; by gvkey confcalldate; run;
proc sort data=sample; by gvkey confcalldate; run;

data sample1 sample2;
	merge sample(in=a) factors(in=b);
	by gvkey confcalldate;
	if a eq 1 and b eq 1 then output sample1;
	if a eq 1 and b eq 0 then output sample2;

data sample;
	set sample1 sample2;
	if factorpred_car01 ne .;

**** WINSORIZE THE DATA ****;

%macro WT(data=_last_, out=, byvar=none, vars=, type = W, pctl = 1 99, drop= N);

	%if &out = %then %let out = &data;
    
	%let varLow=;
	%let varHigh=;
	%let xn=1;

	%do %until (%scan(&vars,&xn)= );
    	%let token = %scan(&vars,&xn);
    	%let varLow = &varLow &token.Low;
    	%let varHigh = &varHigh &token.High;
    	%let xn = %EVAL(&xn + 1);
	%end;

	%let xn = %eval(&xn-1);

	data xtemp;
   	 	set &data;

	%let dropvar = ;
	%if &byvar = none %then %do;
		data xtemp;
        	set xtemp;
        	xbyvar = 1;

    	%let byvar = xbyvar;
    	%let dropvar = xbyvar;
	%end;

	proc sort data = xtemp;
   		by &byvar;

	/*compute percentage cutoff values*/
	proc univariate data = xtemp noprint;
    	by &byvar;
    	var &vars;
    	output out = xtemp_pctl PCTLPTS = &pctl PCTLPRE = &vars PCTLNAME = Low High;

	data &out;
    	merge xtemp xtemp_pctl; /*merge percentage cutoff values into main dataset*/
    	by &byvar;
    	array trimvars{&xn} &vars;
    	array trimvarl{&xn} &varLow;
    	array trimvarh{&xn} &varHigh;

    	do xi = 1 to dim(trimvars);
			/*winsorize variables*/
        	%if &type = W %then %do;
            	if trimvars{xi} ne . then do;
              		if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = trimvarl{xi};
              		if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = trimvarh{xi};
            	end;
        	%end;
			/*truncate variables*/
        	%else %do;
            	if trimvars{xi} ne . then do;
              		if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = .T;
              		if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = .T;
            	end;
        	%end;

			%if &drop = Y %then %do;
			   if trimvars{xi} = .T then delete;
			%end;

		end;
    	drop &varLow &varHigh &dropvar xi;

	/*delete temporary datasets created during macro execution*/
	proc datasets library=work nolist;
		delete xtemp xtemp_pctl; quit; run;

%mend;

%WT(data=sample, vars= car01 ln_mve btm turnover pre_alpha instown earnsurp svrpred_car01 rfpred_car01 sldapred_car01 factorpred_car01, type = W, pctl = 1 99);

**** SAVE TO OUTPUT FILE ****;

data file.finaldata_cc; set sample; run; quit;

