dm 'output; clear; log; clear';
dm 'odsresults; clear';
run;
options ls=256 ps=10000 nocenter;

proc datasets lib=work kill nolist memtype=data; run; quit;

**** ENTER PATH TO FOLDER WHERE YOU HAVE SAVED ALL DATA FILES ****;

libname file '\path\to\folder\';

**** GAIN ACCESS TO THE WRDS SERVER ****;

%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=USERNAME password='PASSWORD';
rsubmit;

options ls=256 ps=10000 nocenter;

**** DEFINE LIBRARY NAMES FOR THE DATASETS YOU WANT TO ACCESS ****;

libname crsp '/wrds/crsp/sasdata/q_stock';
libname tmp '/path/to/WRDS/tmp/folder';

proc upload data=file.initial_sample_10K out=tmp.sample; run;

data sample; set tmp.sample;

**** INCLUDE TRADING DATES ****;

data tradingdates; set crsp.dsi; tradingdate = date; format tradingdate mmddyy10.; keep tradingdate;
proc sort data=tradingdates nodupkey; by tradingdate; run;

proc sort data=tradingdates; by descending tradingdate; run;

data tradingdates;
	set tradingdates;
	tradingdate_plus1 = lag1(tradingdate);
	format tradingdate_plus1 mmddyy10.;

proc sort data=tradingdates; by tradingdate; run;

data tradingdates;
	set tradingdates;
	tradingdate_6 = lag6(tradingdate);
	tradingdate_252 = lag252(tradingdate);
	format tradingdate_6 mmddyy10.;
	format tradingdate_252 mmddyy10.;
	
proc sql;
	create table sample1 as
	select a.permno, a.date_filed, b.tradingdate, b.tradingdate_plus1, b.tradingdate_6, b.tradingdate_252
	from sample as a, tradingdates as b
	where a.date_filed <= b.tradingdate <= intnx('weekday',a.date_filed,+10);
	quit;

data sample1; set sample1; id = cat(permno,date_filed);
proc sort data=sample1; by id tradingdate; run;
data sample1; set sample1; by id; if first.id; drop id; * choose the next available trading date on or after the date_filed;

proc sort data=sample; by permno date_filed; run;
proc sort data=sample1; by permno date_filed; run;

data sample; merge sample sample1; by permno date_filed;

**** SHARE TURNOVER and PRE ALPHA FOLLOWING LOUGHRAN AND MCDONALD 2011 ****;

proc sql;
	create table temp as
	select a.permno, a.date_filed, b.date, b.vol, b.ret
	from sample as a, crsp.dsf as b
	where a.permno=b.permno and a.tradingdate_252 <= b.date <= a.tradingdate_6 and (ret ne . and ret ne .B and ret ne .C);
	quit;

* turnover;

proc sql;
	create table shrout as
	select a.permno, a.date_filed, b.shrout
	from sample as a, crsp.dsf as b
	where a.permno=b.permno and a.tradingdate = b.date and (ret ne . and ret ne .B and ret ne .C);
	quit;

proc sort data=temp; by permno date_filed date; run;

proc means data=temp noprint;
by permno date_filed;
var vol;
output out=volume sum=volume;
run;

data volume;
	set volume;
	if _FREQ_ >= 60;

proc sort data=shrout nodupkey; by permno date_filed; run;
proc sort data=volume; by permno date_filed; run;

data turnover;
	merge volume shrout;
	by permno date_filed;
	
data tmp.turnover;
	set turnover;
	turnover = volume/shrout;
	keep permno date_filed volume shrout turnover;
	run;
	quit;

* pre_alpha;

data factors; set ff.factors_daily;

proc sort data=temp; by date; run;
proc sort data=factors; by date; run;

data temp;
	merge temp(in=a) factors(in=b);
	by date;
	if a eq 1 and b eq 1 then output temp;

data temp;
	set temp;
	ret_rf = ret-rf;

proc sort data=temp; by permno date_filed; run;

proc reg data=temp noprint outest=tmp.famafrench;
by permno date_filed;
model ret_rf = mktrf smb hml;
run;

data tmp.pre_alpha; set tmp.famafrench; pre_alpha = Intercept; keep permno date_filed pre_alpha;

**** NASDAQ DUMMY FOLLOWING LOUGHRAN AND MCDONALD 2011 ****;

data tmp.nasdaq;
	set crsp.dsfhdr;
	if hexcd = 3 then nasdaq = 1; else nasdaq = 0;
	keep permno nasdaq;

**** CALCULATE CAR 01 ****;

proc sql;
	create table temp as
	select a.permno, a.date_filed, b.date, b.ret
	from sample as a, crsp.dsf as b
	where a.permno=b.permno and a.tradingdate <= b.date <= a.tradingdate_plus1 and (ret ne . and ret ne .B and ret ne .C);
	quit;

data vwretd;
	set crsp.dsi;
	keep date vwretd;

proc sort data=temp; by date; run;
proc sort data=vwretd; by date; run;

data temp;
	merge temp(in=a) vwretd(in=b);
	by date;
	if a eq 1 and b eq 1 then output temp;

data temp;
	set temp;
	ln_ret = log(ret+1);
	ln_vwretd = log(vwretd+1);

proc sort data=temp; by permno date_filed; run;

proc means data=temp noprint;
by permno date_filed;
var ln_ret ln_vwretd;
output out=temp sum=sum_ln_ret sum_ln_vwretd;
run;

data tmp.car01;
	set temp;
	ret = exp(sum_ln_ret)-1;
	vwretd = exp(sum_ln_vwretd)-1;
	car01 = ret - vwretd;
	keep permno date_filed car01;
	run;
	quit;

**** COMBINE ALL CRSP DATA ****;

data turnover; set tmp.turnover; keep permno date_filed volume shrout turnover;
data pre_alpha; set tmp.pre_alpha; keep permno date_filed pre_alpha;
data nasdaq; set tmp.nasdaq; keep permno nasdaq;
data car01; set tmp.car01; keep permno date_filed car01;

proc sort data=turnover; by permno date_filed; run;
proc sort data=pre_alpha; by permno date_filed; run;
proc sort data=nasdaq; by permno; run;
proc sort data=car01; by permno date_filed; run;

data crspdata; merge turnover pre_alpha; by permno date_filed; run;
data crspdata; merge crspdata nasdaq; by permno; run;
data crspdata; merge crspdata car01; by permno date_filed; run;

data crspdata;
	set crspdata;
	if car01 ne .;
	if turnover ne .;
	if pre_alpha ne .;
	if nasdaq ne .;

proc download data=crspdata out=file.crspdata_10K; run;

proc print data=crspdata(obs=100); run;
