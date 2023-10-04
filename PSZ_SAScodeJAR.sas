/********************************************************************
This file creates the sample used in 

"Facilitating Tacit Collusion through Voluntary Disclosure: 
Evidence from Common Ownership" by Pawliczek, Skinner and Zechman 

Program last edited: August 10, 2021
********************************************************************/

libname ibes 		'/wrds/ibes/sasdata/guidance';
libname ibesa		'/wrds/ibes/sasdata';
libname compm		'/wrds/comp/sasdata/naa';
libname excomp		'/wrds/comp/sasdata/execcomp';
libname temp		'YOUR DIRECTORY';


/********************************************************************
PART 1: Download Compustat sample, and calculate basic controls
********************************************************************/

data comp (keep = fyearq fqtr datafqtr datacqtr datadate APDEDATEQ gvkey conm cusip sich cik atq ppegtq ppentq cshoq prccq ltq seqq txdbq ibq rdq niq revtq saleq); set compm.fundq ; 
	where	(curncdq = 'USD')
	and fyearq > 1999
	and atq ne .; 

*eliminate duplicates;  
proc sort data = comp; 
by gvkey datadate descending atq; 
proc sort data = comp nodupkey; 
by gvkey datadate; 


data comp1; set comp; 	
	*calculate controls, clean up dates + identifiers; 
	mve = cshoq*prccq;
	mtb = (mve+ltq)/atq; 
	if txdbq = . then txdbq = 0; 
	lev = (ltq-txdbq)/atq;
	cusip_8 = substr(cusip,1,8);
	gvkey1 = gvkey*1;
	cik1=cik*1;
	
	*create lagged quarter identifiers, code calendar date (including lags); 
	fqtr_lag = fqtr - 1; 
	fyearq_lag = fyearq; 
	if fqtr_lag = 0 then fyearq_lag = fyearq -1; 
	if fqtr_lag = 0 then fqtr_lag = 4;
	cqtr = (substr(datacqtr,6,1))*1; 
	cyear = (substr(datacqtr,1,4))*1; 
	cmo = 3; 
	cday = 31; 
	if cqtr = 2 then cmo = 6;
	if cqtr = 3 then cmo = 9;
	if cqtr = 4 then cmo = 12;
	if cqtr = 2 then cday = 30; 
	if cqtr = 3 then cday = 30; 
	cdate = mdy(cmo,cday,cyear); 
	cdate_2lag = intnx('year', cdate, -2, 'same');
	format cdate date9.;
	gvkey1 = gvkey*1;
	year = year(cdate);
	disc_date = mdy(6,30,year); 
	if mdy(3,31,year) < cdate <= mdy(6,30,year) then disc_date = mdy(9,30,year) ; 
	if mdy(6,30,year) < cdate <= mdy(9,30,year) then disc_date = mdy(12,31,year) ; 
	if mdy(9,30,year) < cdate <= mdy(12,31,year) then disc_date = mdy(3,31,year+1); 
	format disc_date date9.;
		
	run;


*merge industry;
*s1 is a list of sample identifiers with clean sic codes. specifically, we export sic codes for these firms from compustat, and then clean and backfill SICs with hand collected SIC codes for our final sample firms where necessary, given the importance of SIC codes to our study's inferences;
proc sql; create table comp1a as select distinct 
a.*, b. sic, b. sic2d
from comp1 as a left join temp.s1 as b 
on a. gvkey1 = b. gvkey1 and a. datadate = b. datadate; 

proc means data = comp1a; run; quit;

data comp1a; set comp1a; 
if sic = . then delete; 

proc means data = comp1a; 

*save identifiers for use in calculating IO/CO vars in PART 4.;
data temp.hhi_compustat (keep = gvkey sic saleq datacqtr cusip); set comp1a; 
proc means data =temp.hhi_compustat; 
run; quit; 


*calculate AbsChange_Income;
proc sql; create table comp2 as select distinct 
a.*, abs(a. ibq- b. ibq)/a. atq as abschange
from comp1a as a left join comp1 as b
on a. gvkey = b. gvkey and a. fyearq_lag = b. fyearq and a. fqtr_lag = b. fqtr; 
run; 

proc means data = comp2; 
run; quit; 

proc sort data = comp2; by descending abschange;
by gvkey cdate; 
proc sort data = comp2 nodupkey; 
by gvkey cdate; 

*calculate std performance;
proc sql; create table comp3 as select 
a. *, b. ibq as lagsofibq, b. revtq as lagsofrev
from comp2 as a left join comp2 as b 
on a. gvkey = b. gvkey and a. cdate_2lag < b. cdate <= a. cdate;  

proc sql; create table comp4 as select distinct 
*, std(lagsofibq) as stdev, n(lagsofibq) as n_qtr, std(lagsofrev) as stdev_rev
from comp3 
group by gvkey, cdate; 

proc sort data = comp4; by descending n_qtr;
by gvkey cdate; 
proc sort data = comp4 nodupkey; 
by gvkey cdate;

*calculate industry ppe and merge into sample;
data barrier(keep = sic datacqtr gvkey ppegtq ppentq); set comp4; 

proc sql; create table barrier1 as select distinct 
*, mean(ppegtq) as mean_ppe, median(ppegtq) as med_ppe
from barrier 
group by sic, datacqtr;

proc sort data = barrier1; by descending mean_ppe; 
proc sort data = barrier1 nodupkey; 
by sic datacqtr; 

proc sql; create table comp5 as select 
a. *, b. mean_ppe as ind_ppe_mean, b. med_ppe as ind_ppe_med
from comp4 as a left join barrier1 as b 
on a. sic = b. sic and a. datacqtr = b. datacqtr; 

*calculate total industry sales/quarter; 
proc sql; create table comp6 as select distinct 
cdate, sic, sum(saleq) as ind_sale, cdate_2lag
from comp5
group by cdate, sic; 

proc sql; create table comp6a as select distinct 
a. *, b. ind_sale as lagsofindsale
from comp6 as a left join comp6 as b 
on a. sic = b. sic and a. cdate_2lag < b. cdate <= a. cdate;  

proc sql; create table comp6b as select distinct 
*, std(lagsofindsale) as std_ind_sale, n(lagsofindsale) as n_qtrs
from comp6a 
group by sic, cdate; 

proc sort data = comp6b; by descending n_qtrs;
proc sort data = comp6b nodupkey; 
by sic cdate;

proc sql; create table comp7 as select distinct 
a.*, b.* 
from comp5 as a left join comp6b as b 
on a. sic = b. sic and a. cdate = b. cdate; 

*merge in sich as backup; 
proc sql; create table comp7 as select distinct 
a.*, b. sich 
from comp7 as a left join comp.funda as b 
on a. gvkey = b. gvkey and a. fyearq = b. fyear; 


proc print data = comp7 (obs = 10); 
proc means data = comp7;
proc contents data = comp7;


/********************************************************************
PART 2: Download IBES data and calculate IBES measures
********************************************************************/

*IBES; 
data ibes; set ibesa.det_epsus;
where fpedats ne . ;
year = year(fpedats); 

proc sort data = ibes nodupkey; 
by year ticker analys; 

proc sql; create table ibes1 as select distinct  
year, ticker, cusip, n(analys) as num_analysts
from ibes 
group by year, ticker; 

proc sort data = ibes1 nodupkey; 
by year ticker; 

proc print data =ibes1(obs=10);

proc sql; create table comp8 as select distinct 
a. *, b. ticker, b. num_analysts
from comp7 as a left join ibes1 as b 
on a. cusip_8 = b. cusip and (a. cyear -1) = b. year;

*pull guidance data for forecast indicator;
data guide; set ibes.det_guidance; 
ann_year =year(anndats);
ann_mo = month(anndats);
if ann_year < 1999 then delete;
ann_qtr = 1;
if ann_mo =4 then ann_qtr = 2;
if ann_mo =5 then ann_qtr = 2;
if ann_mo =6 then ann_qtr = 2;
if ann_mo =7 then ann_qtr = 3;
if ann_mo =8 then ann_qtr = 3;
if ann_mo =9 then ann_qtr = 3;
if ann_mo =10 then ann_qtr = 4;
if ann_mo =11 then ann_qtr = 4;
if ann_mo =12 then ann_qtr = 4;
FC = 1; 
qtr_end = mdy(3,31,ann_year);
if ann_qtr = 2 then qtr_end = mdy(6,30,ann_year);
if ann_qtr = 3 then qtr_end = mdy(9,30,ann_year);
if ann_qtr = 4 then qtr_end = mdy(12,31,ann_year); 
qtr_beg = intnx('month', qtr_end, -3, 'end');
run;

proc sql; create table guide1 as select distinct 
ticker, ann_qtr, ann_year, max(FC) as FC_ind, qtr_end, qtr_beg
from guide
group by ticker, ann_qtr, ann_year; 

proc sql; create table comp9 as select distinct 
a. *, b. *
from comp8 as a left join guide1 as b
on a. TICKER = b. ticker and a. cdate = b. qtr_beg;

data temp.controls_sample (drop=ppegtq ppentq fyearq fqtr cusip apdedateq rdq niq fqtr_lag fyear_lag cqtr0 cyear0 cyear cqtr cmo cday ibq_lag lagsofibq lagsofrev) ; set comp9;

proc means data= temp.controls_sample; 

/********************************************************************
PART 3: MERGE ALL NON-CO MEASURES TO CREATE A FINAL DATASET
********************************************************************/

*s1 is the list of sample identifiers with clean sic codes.; 
proc sql; create table sample as select distinct 
a.* , b. * 
from temp.s1 as a left join temp.controls_sample as b 
on a. gvkey1 = b. gvkey1 and a. datadate = b. datadate; 

proc means data = sample; 


*eas2 contains data collected from earnings announcement 8ks using traditional natural language processing techniques; 
proc sql; create table sample1 as select distinct 
a. *, b. revguide, b. totalwords_EA
from sample as a left join temp.eas2 as b 
on a. cik1 = b. CIK and a. disc_date = b. disc_date; 

*call contains data measuring basic characteristics of firms' quarterly conference calls, collected from S&P Global conference calls, using traditional natural language processing techniques; 
proc sql; create table sample2 as select distinct 
a. *, b. *
from sample1 as a left join temp.calls2 as b 
on a. gvkey1 = gvkeycc and a. disc_date = b. disc_date; 

*the cto data contains data collected from firms' SEC EDGAR filings, which we use to calculate NoCTO. 
proc sql; create table sample3 as select distinct 
a. *, b. *
from sample2 as a left join temp.cto3 as b 
on a. cik1 = b. CIK and a. disc_date = b. disc_date; 


data sample3; set sample3; 
year = year(cdate); 
proc freq data = sample3; 
tables year; 

*final cleaning steps; 
data sample3; set sample3; 
if ctof_ind =. then ctof_ind  =0; 
if nctof  =. then nctof  =0; 
if cto8k_ind  =. then cto8k_ind  =0; 
if ncto8k  =. then ncto8k  =0; 
if cto10kq_ind  =. then cto10kq_ind  =0; 
if FC_ind = . then FC_ind = 0; 
bs_date = cdate; 
if disc_date = . then disc_date = intnx('month', cdate, 3, 'end');
cQTR = 1; 
if month(cdate) = 6 then cQTR = 2; 
if month(cdate) = 9 then cQTR = 3; 
if month(cdate) = 12 then cQTR = 4; 

proc sort data = sample3; 
by descending atq; 

proc sort data= sample3 nodupkey; 
by gvkey datadate; 

proc means data = sample3; 
proc print data = sample3 (obs=10); 

data temp.pszsample; set sample3; 

run; quit; 


/********************************************************************
PART 4: CALCULATE Institutional/Common Ownership VARIABLES 
********************************************************************/


****working locally after this point****
*****downloaded hhi_compustat and PSZsample from WRDS to "main" library****

*****Create Data Set with Market Shares and HHI needed to calculate common ownership variables;
*****Working on local server*******;
libname main 'insert path for where data is saved';
libname share1 'insert path to save final data sets';
libname covar 'insert path to where data sets are saved from running loop';


data main.hhi;
set main.hhi_compustat;
if sic = . then delete;
if curcdq="CAD" then delete;
if saleq<0 then saleq=0;
run;

proc sort data=main.hhi;
by sic datacqtr;
run;

*calculate market size by industry , calendar quarter;
proc sql;
create table work.herfindahl1 as
  select gvkey, datacqtr, sic, saleq, sum(saleq) as market_size, count(sic) as firm_num
  from main.hhi
  group by datacqtr, sic
  ;
quit;

*get the market share squares;
data work.herfindahl2;
set work.herfindahl1;
if sic = . then delete;
if market_size = 0 or market_size = . then delete;
market_share_sqr = (saleq/market_size)*(saleq/market_size);
market_share=saleq/market_size;
run;

*calculate the herfindahl index by sic;
proc sql;
create table work.herfindahl3 as
  select gvkey, datacqtr, sic, saleq, firm_num, market_size, market_share, market_share_sqr, sum(market_share_sqr) as Herfindahl
  from work.herfindahl2
  group by datacqtr, sic
  ;
quit;

data herfindahl3;
set herfindahl3;
year=SUBSTR(datacqtr, 1, 4);
year=year*1;
quarter=SUBSTR(datacqtr, 6, 1);
if quarter=4 then month=12;
if quarter=3 then month=9;
if quarter=2 then month=6;
if quarter=1 then month=3;
run;

data herfindahl3;
set herfindahl3;
if quarter=. then delete;
run;

proc sql undo_policy = none;
	create table herfindahl4 as select distinct 
	a.*, b.cusip
	from herfindahl3 a left join main.hhi b
	on (a.gvkey=b.gvkey) and (a.datacqtr=b.datacqtr);
quit;

data herfindahl4;
set  herfindahl4;
cusip8=substr(cusip, 1, 8);
format cusip8 $char8.;
year1=input(year, 6.);
run;

data herfindahl4;
set  herfindahl4;
id1=sic*1000000+year*10+month/3;
run;

*****s34 is a download of full s34 database from Thomson Reuters on WRDS*****;
data ownershipper;
set main.s34;
ownper=shares/(shrout2*1000);
if ownper=. then ownper=shares/(shrout1*1000000);
run;


*******create set to combine blackrock*****;
****Blackrock listed under multiple manager numbers in S34 data***;
data br_ownershipper;
set ownershipper;
br=0;
if mgrno = 11386 then br = 1;
if mgrno = 12588 then br = 1;
if mgrno = 9385 then br = 1;
if mgrno = 39539 then br = 1;
if mgrno = 91430 then br = 1;
if mgrno = 56790 then br = 1;
if br=0 then delete;
run;

proc sort data=br_ownershipper;
by cusip rdate;
run;

proc means noprint data=br_ownershipper;
var prc shrout1 shrout2 ownper shares;
output out=br_consol mean(prc)=prc mean(shrout1)=shrout1
mean(shrout2)=shrout2 sum(shares)=shares sum(ownper)=ownper 
;
by cusip rdate;
run;

data br_consol;
set br_consol;
mgrno=9385;
run;

data ownershipper_new;
set ownershipper;
br=0;
if mgrno = 11386 then br = 1;
if mgrno = 12588 then br = 1;
if mgrno = 9385 then br = 1;
if mgrno = 39539 then br = 1;
if mgrno = 91430 then br = 1;
if mgrno = 56790 then br = 1;
if br=1 then delete;
run;

****add combined blackrock onwership under single manager number;
proc append base=ownershipper_new data=br_consol force;
run;


data ownershipper_new;
set ownershipper_new;
month=month(rdate);
year=year(rdate);
drop reportdate;
run;

****add sic, firm_num (number of firms in industry) to ownership data*****;
proc sql undo_policy = none;
	create table ownershipper_new as select distinct 
	a.*, b.market_share, b.sic, b.firm_num
	from ownershipper_new a left join herfindahl4 b
	on (a.cusip=b.cusip8) and (a.year=b.year1) and (a.month=b.month);
quit;

***Create unique ID for each SIC-quarter***;
data ownershipper2;
set ownershipper_new;
id1=sic*1000000+year*10+month/3;
run;

data ownershipper2;
set ownershipper2;
if id1<1 then delete;
if year<2000 then delete;
if year>2015 then delete;
if firm_num<2 then delete;
run;

proc sort data=ownershipper2;
by rdate;
run;


data loop1;
set ownershipper2;
run;

proc sort data=loop1 nodupkey;
by id1;
run;

***Create consecutive IDS (idcount) for each SIC-Quarter combo with data*****;
****To be used in loop to calculate common ownership variables***;
data loop1;
set loop1;
idcount=_n_;
keep id1 sic year month idcount;
run;


proc sql undo_policy = none;
	create table ownershipper2 as select distinct 
	a.*, b.idcount
	from ownershipper2 a left join loop1 b
	on (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table loop1 as select distinct 
	a.*, b.firm_num
	from loop1 a left join herfindahl4 b
	on (a.id1=b.id1);
quit;

proc sort data=loop1 nodupkey;
by id1;
run;

********create datasets to save common ownership values;
libname share1 'D:\Users\anpa2590\Documents\CO Variables\add6020';
****this variable is not used in final dataset****;
data share1.mhhifinal;
id1=9999999999;
mhhi=0;
mhhi_m1=0;
mhhi_m2=0;
_freq_=0;
run;

****this variable is not used in final dataset****;
data share1.mhhifinal_bh;
id1=9999999999;
mhhi_bh=0;
mhhi_m1_bh=0;
mhhi_m2_bh=0;
overlapshare=0;
_freq_=0;
run;

data share1.mhhifirmfinal;
id1=9999999999;
firmmhhi=0;
firmmhhi_m2=0;
cusip='A9999999';
_freq_=0;
run;

data share1.mhhifirmfinal_bh;
id1=9999999999;
firmmhhi_bh=0;
firmoverlap=0;
cusip='A9999999';
_freq_=0;
run;

*have log print to file- otherwise screen fills;
Proc printto log='templog.log' new;
Run;


****Code set off by row of stars loops through industyr quarters to calculate common ownership variables*****
****Takes a long time to run - run on a server*****
***For industries with many firm may take >2hours per quarter
***after %to insert the highest value of idcount in dataset
***can restart loop as needed by adjusting k=# to desired start
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************;
*loop1a is main loop through industyr quarters to calculate common ownership variables;
%macro loop1a;
*select firms in industry-year-quarter;
%do k=1 %to 18820;
data ownershipper_id;
set ownershipper2;
if idcount^=&k then delete;
call symput('idnumber', id1); 
run;
%put =&idnumber;


*get set for ms;
data market_share;
set ownershipper_id;
keep cusip market_share;
run;

*remove dups;
proc sort data=market_share nodupkey;
by cusip;
run;


*get set ready to transpose;
data ownershipper_id_v2;
set ownershipper_id;
keep cusip mgrno ownper;
run;

*remove dups;
proc sort data=ownershipper_id_v2 nodupkey;
by cusip mgrno;
run;

*transpose - one row per company;
proc transpose data=ownershipper_id_v2
out=tranpose_id
name=ownper;
by cusip;
id mgrno;
run;

*fill missing data with 0s;
data tranpose_id;
set tranpose_id;
options missing = '0'; 
run;

*count number of observations;
data matrix1;
set tranpose_id;
combo=_N_;
keep combo; 
call symput('nobs1', Combo); 
run;

*count number of distint managers (variables);
data action;
Set tranpose_id;
Array nums(*) _numeric_ ;
number_of_numerics = dim( nums );
call symput('numbernum', number_of_numerics); 
run;

%put =&nobs1;
%put =&numbernum;

*create matrix with all combinations of firms;
data count;
%put &=nobs1;
    do r1 = 1 to &nobs1*&nobs1;
        output;
    end;
run;

data count;
set count;
comp1=ceil(r1/&nobs1);
comp2=mod(r1,&nobs1)+1;
run;

*create matrix of squares (denominator);
data action1;
Set tranpose_id;
Array nums(*) _numeric_ ;
do i=1 to &numbernum;
nums[i]=nums[i]*nums[i]; 
end;
*drop i;
denom=sum(of nums[*]); 
run;

*rename instit ownership variables to bring in for second firm;
%macro rename(lib,dsn,newname);
*proc contents data=&lib..&dsn;
*title 'before renaming';
*run; 

proc sql noprint; 
 select nvar into :num_vars
 from dictionary.tables
 where libname="&LIB" and memname="&DSN";
 select distinct(name) into :var1-:var%trim(%left(&num_vars))
 from dictionary.columns
 where libname="&LIB" and memname="&DSN";
 quit;
run;
proc datasets library = &LIB noprint;
modify &DSN;
rename
%do i = 1 %to &num_vars.;
&&var&i = &newname._&&var&i.
%end;
;
quit;
run;
*proc contents data=&lib..&dsn.;
*title 'after renaming';
*run;
%mend rename;

DATA action2;
set tranpose_id;
run;
%rename(WORK,ACTION2,A); 

proc sort data=tranpose_id nodupkey;
by cusip;
run;

data tranpose_id;
set tranpose_id;
counter=_N_;
run;

proc sort data=action2 nodupkey;
by cusip;
run;

data action2;
set action2;
counter=_N_;
rename a_cusip=cusip;
drop a_ownper;
run;

*match firms to count;
proc sql undo_policy = none;
	create table count as select distinct 
	a.*, b.cusip as cusip1
	from count a left join tranpose_id b
	on (a.comp1=b.counter);
quit;

proc sql undo_policy = none;
	create table count as select distinct 
	a.*, b.cusip as cusip2
	from count a left join action2 b
	on (a.comp2=b.counter);
quit;

*bring in instit own for firm 1;
proc sql undo_policy = none;
	create table count as select distinct 
	a.*, b.*
	from count a left join tranpose_id b
	on (a.cusip1=b.cusip);
quit;

*bring in instit own for firm 2;
proc sql undo_policy = none;
	create table count as select distinct 
	a.*, b.*
	from count a left join action2 b
	on (a.cusip2=b.cusip);
quit;

*create products of instit own - numerator;
DATA count2;
SET count;
FILE PRINT;
ARRAY X[*] A: ;
ARRAY Y[*] _: ;
do i=1 to &numbernum;
x[i]=x[i]*y[i]; 
end;
*drop i;
numerator=sum(of x[*]);
RUN;

 
proc sql undo_policy = none;
	create table count2 as select distinct 
	a.*, b.denom
	from count2 a left join action1 b
	on (a.cusip1=b.cusip);
quit;

proc sql undo_policy = none;
	create table count2 as select distinct 
	a.*, b.market_share as ms1
	from count2 a left join market_share b
	on (a.cusip1=b.cusip);
quit;

proc sql undo_policy = none;
	create table count2 as select distinct 
	a.*, b.market_share as ms2
	from count2 a left join market_share b
	on (a.cusip2=b.cusip);
quit;

data tranpose_id2;
set tranpose_id;
drop counter;
run;

data tranpose_id2;
set tranpose_id2;
total1 = sum(of _numeric_);
run;

proc sql undo_policy = none;
	create table count2 as select distinct 
	a.*, b.total1 as totalio
	from count2 a left join tranpose_id2 b
	on (a.cusip1=b.cusip);
quit;

*calculate mhhi terms;
data count2;
set count2;
sumterm=numerator/denom;
if sumterm>1 then sumterm=1;
if denom=0 then sumterm=0;
othero=1-totalio;
if othero<0 then othero=0;
otherosq=othero*othero;
pmhhi=ms1*ms2*numerator/denom;
pmhhi_m1=ms1*ms2*sumterm;
pmhhi_m2=ms1*ms2*numerator/(denom+otherosq);
if cusip1=cusip2 then delete;
run;

*calculate mhhi; 
proc means data=count2 noprint;
var pmhhi pmhhi_m1 pmhhi_m2;
output out=mhhi
sum(pmhhi)=mhhi sum(pmhhi_m1)=mhhi_m1 sum(pmhhi_m2)=mhhi_m2
;
run;

*add id number;
data mhhi;
set mhhi;
id1=&idnumber;
run;

*add to final data set;
proc append base=share1.mhhifinal  data=mhhi force;
run;



*only blockholders;
**********;
**********;
*change holding less than 5% to 0;
data transpose_id_bh;
Set tranpose_id;
Array nums(*) _numeric_ ;
do i=1 to &numbernum;
if nums[i]<0.05 then nums[i]=0; 
end;
drop i;
drop counter;
run;

data matrix1_bh;
set transpose_id_bh;
combo=_N_;
keep combo; 
call symput('nobs1', Combo); 
run;

*count number of distint managers (variables);
data action1_bh;
Set transpose_id_bh;
Array nums(*) _numeric_ ;
number_of_numerics = dim( nums );
call symput('numbernum', number_of_numerics); 
run;

%put =&nobs1;
%put =&numbernum;

*create matrix with all combinations of firms;
data count_bh;
%put &=nobs1;
    do r1 = 1 to &nobs1*&nobs1;
        output;
    end;
run;

data count_bh;
set count_bh;
comp1=ceil(r1/&nobs1);
comp2=mod(r1,&nobs1)+1;
run;

*create matrix of squares (denominator);
data action1_bh;
Set transpose_id_bh;
Array nums(*) _numeric_ ;
do i=1 to &numbernum;
nums[i]=nums[i]*nums[i]; 
end;
*drop i;
denom=sum(of nums[*]); 
run;

*rename instit ownership variables to bring in for second firm;
%macro rename(lib,dsn,newname);
*proc contents data=&lib..&dsn;
*title 'before renaming';
*run; 

proc sql noprint; 
 select nvar into :num_vars
 from dictionary.tables
 where libname="&LIB" and memname="&DSN";
 select distinct(name) into :var1-:var%trim(%left(&num_vars))
 from dictionary.columns
 where libname="&LIB" and memname="&DSN";
 quit;
run;
proc datasets library = &LIB noprint;
modify &DSN;
rename
%do i = 1 %to &num_vars.;
&&var&i = &newname._&&var&i.
%end;
;
quit;
run;
*proc contents data=&lib..&dsn.;
*title 'after renaming';
*run;
%mend rename;

DATA action2_bh;
set transpose_id_bh;
run;
%rename(WORK,ACTION2_BH,A); 

proc sort data=transpose_id_bh nodupkey;
by cusip;
run;

data transpose_id_bh;
set transpose_id_bh;
counter=_N_;
run;

proc sort data=action2_bh nodupkey;
by cusip;
run;

data action2_bh;
set action2_bh;
counter=_N_;
rename a_cusip=cusip;
drop a_ownper;
run;

*match firms to count;
proc sql undo_policy = none;
	create table count_bh as select distinct 
	a.*, b.cusip as cusip1
	from count_bh a left join transpose_id_bh b
	on (a.comp1=b.counter);
quit;

proc sql undo_policy = none;
	create table count_bh as select distinct 
	a.*, b.cusip as cusip2
	from count_bh a left join action2_bh b
	on (a.comp2=b.counter);
quit;

*bring in instit own for firm 1;
proc sql undo_policy = none;
	create table count_bh as select distinct 
	a.*, b.*
	from count_bh a left join transpose_id_bh b
	on (a.cusip1=b.cusip);
quit;

*bring in instit own for firm 2;
proc sql undo_policy = none;
	create table count_bh as select distinct 
	a.*, b.*
	from count_bh a left join action2_bh b
	on (a.cusip2=b.cusip);
quit;

*create products of instit own - numerator;
DATA count2_bh;
SET count_bh;
FILE PRINT;
ARRAY X[*] A: ;
ARRAY Y[*] _: ;
do i=1 to &numbernum;
x[i]=x[i]*y[i]; 
end;
*drop i;
numerator=sum(of x[*]);
RUN;

 
proc sql undo_policy = none;
	create table count2_bh as select distinct 
	a.*, b.denom
	from count2_bh a left join action1_bh b
	on (a.cusip1=b.cusip);
quit;

proc sql undo_policy = none;
	create table count2_bh as select distinct 
	a.*, b.market_share as ms1
	from count2_bh a left join market_share b
	on (a.cusip1=b.cusip);
quit;

proc sql undo_policy = none;
	create table count2_bh as select distinct 
	a.*, b.market_share as ms2
	from count2_bh a left join market_share b
	on (a.cusip2=b.cusip);
quit;

data transpose_id2_bh;
set transpose_id_bh;
drop counter;
run;

data transpose_id2_bh;
set transpose_id2_bh;
total1 = sum(of _numeric_);
run;

proc sql undo_policy = none;
	create table count2_bh as select distinct 
	a.*, b.total1 as totalio
	from count2_bh a left join transpose_id2_bh b
	on (a.cusip1=b.cusip);
quit;

*calculate mhhi terms;
data count2_bh;
set count2_bh;
sumterm=numerator/denom;
if sumterm>1 then sumterm=1;
if denom=0 then sumterm=0;
othero=1-totalio;
if othero<0 then othero=0;
otherosq=othero*othero;
pmhhi=ms1*ms2*numerator/denom;
pmhhi_m1=ms1*ms2*sumterm;
pmhhi_m2=ms1*ms2*numerator/(denom+otherosq);
poverlapshare=ms1*ms2/2;
if numerator=0 then poverlapshare=0;
if cusip1=cusip2 then delete;
run;

*calculate mhhi; 
proc means data=count2_bh noprint;
var pmhhi pmhhi_m1 pmhhi_m2 poverlapshare;
output out=mhhi_bh
sum(pmhhi)=mhhi_bh sum(pmhhi_m1)=mhhi_m1_bh sum(pmhhi_m2)=mhhi_m2_bh sum(poverlapshare)=overlapshare
;
run;

*add id number;
data mhhi_bh;
set mhhi_bh;
id1=&idnumber;
run;

*add to final data set;
proc append base=share1.mhhifinal_bh  data=mhhi_bh force;
run;

*firm specific calcs;
%macro firm1a;
*select firm;
%do q=1 %to &nobs1;
data firmcalcs;
set count2;
if comp1^=&q then delete; 
run;

data firmcalcs;
set firmcalcs;
share1=ms2*sumterm;
share2=ms2*numerator/(denom+otherosq);
call symput('cusipfirm', cusip1); 
run;
%put =&cusipfirm;
*calculate mhhi; 
proc means data=firmcalcs noprint;
var ms1 share1 share2;
output out=firmmhhi
sum(share1)=share1t sum(share2)=share2t mean(ms1)=ms1
;
run;

data firmmhhi;
set firmmhhi;
firmmhhi=share1t/(1-ms1);
firmmhhi_m2=share2t/(1-ms1);
id1=&idnumber;
firmid=&q;
run;

proc sql undo_policy = none;
	create table firmmhhi as select distinct 
	a.*, b.cusip1 as cusip
	from firmmhhi a left join count2 b
	on (b.comp1=a.firmid);
quit;


proc append base=share1.mhhifirmfinal data=firmmhhi force;
run;



%end;
%mend firm1a;

%firm1a;


*firm specific calcs - blockholder;
%macro firm1a_bh;
*select firm;
%do t=1 %to &nobs1;
data firmcalcs_bh;
set count2_bh;
if comp1^=&t then delete; 
run;

data firmcalcs_bh;
set firmcalcs_bh;
share1=ms2*sumterm;
overlapfirm=ms2;
if numerator=0 then overlapfirm=0;
call symput('cusipfirm', cusip1); 
run;
%put =&cusipfirm;

*calculate mhhi; 
proc means data=firmcalcs_bh noprint;
var ms1 share1 overlapfirm;
output out=firmmhhi_bh
sum(share1)=share1t sum(overlapfirm)=overlapfirm mean(ms1)=ms1
;
run;

data firmmhhi_bh;
set firmmhhi_bh;
firmmhhi_bh=share1t/(1-ms1);
firmoverlap=overlapfirm/(1-ms1);
id1=&idnumber;
firmid=&t;
run;

proc sql undo_policy = none;
	create table firmmhhi_bh as select distinct 
	a.*, b.cusip1 as cusip
	from firmmhhi_bh a left join count2_bh b
	on (b.comp1=a.firmid);
quit;


proc append base=share1.mhhifirmfinal_bh data=firmmhhi_bh force;
run;



%end;
%mend firm1a_bh;

%firm1a_bh;

%end;
%mend loop1a;

%loop1a;
run;


*****End of Loop*********************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************
**************************
***************************;


****bring back log to display on screen;
proc printto; 
run;

****Calculate 3rd common ownership measure (final name: top5_value)******
****Create Data Set with Top 5 ownership (top5_val)***;
libname main 'D:\Users\anpa2590\Documents';

****Calculate top 5 ownership****;
data ownershipper2_top5;
set ownershipper;
run;

proc sort data= ownershipper2_top5;
by cusip id1 ownper;
run;

***identify top 5 owners by % fo each firm***;
proc rank data=ownershipper2_top5 out=owner_ranks ties=low descending;
   by cusip id1;
   var ownper;
   ranks OwnperRank;
run;

data owner_ranks;
set owner_ranks;
if OwnperRank>5 then delete;
if OwnperRank=. then delete;
run;

****firm quarter dataset***;
data firms;
set herfindahl4;
run;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.mgrno as owner1, b.ownper as ownper1, b.prc as price1, b.shares as shares1, b.shrout1 as shrout1_1, b.shrout2 as shrout2_1
	from firms a left join owner_ranks b
	on (a.cusip8=b.cusip) and (a.id1=b.id1) and (ownperrank=1);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.mgrno as owner2, b.ownper as ownper2, b.shares as shares2
	from firms a left join owner_ranks b
	on (a.cusip8=b.cusip) and (a.id1=b.id1) and (ownperrank=2);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.mgrno as owner3, b.ownper as ownper3, b.shares as shares3
	from firms a left join owner_ranks b
	on (a.cusip8=b.cusip) and (a.id1=b.id1) and (ownperrank=3);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.mgrno as owner4, b.ownper as ownper4,  b.shares as shares4
	from firms a left join owner_ranks b
	on (a.cusip8=b.cusip) and (a.id1=b.id1) and (ownperrank=4);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.mgrno as owner5, b.ownper as ownper5, b.shares as shares5
	from firms a left join owner_ranks b
	on (a.cusip8=b.cusip) and (a.id1=b.id1) and (ownperrank=5);
quit;

data firms;
set firms;
if year<2000 then delete;
run;

data firms;
set firms;
mve=shrout2_1*price1;
if shrouth2_1=. then mve=shrout1_1*price1*1000;
run;


 *******prepare industry files*******;
***calculate sum of MVE;
proc sort data=firms;
by id1;
run;

*******calculate mve for entire SIC quarter&+******;
proc means noprint data=firms;
var mve;
output out=mve_sicquater sum(mve)=market_mve 
;
by id1;
run;

*****merge marketmve into firm file******;
proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_mve 
	from firms a left join mve_sicquater b
	on (a.id1=b.id1) ;
quit;

****calculate sum of ownership *****
*******% and dollar ownership for SIC and quarter******;

data ownershipper2_top5;
set ownershipper2_top5;
dollarown=shares*prc;
run;

***consolidate to manager-sic-quarter level****;
proc sort data= ownershipper2_top5;
by id1 mgrno;
run;

proc means noprint data=ownershipper2_top5;
var ownper dollarown;
output out=market_own sum(ownper)=market_ownper sum(dollarown)=market_dollarown
;
by id1 mgrno;
run;

******merge market data into firm data******;
proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_ownper as market_ownper1, b.market_dollarown as market_dollarown1  
	from firms a left join market_own b
	on (a.owner1=b.mgrno) and (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_ownper as market_ownper2, b.market_dollarown as market_dollarown2  
	from firms a left join market_own b
	on (a.owner2=b.mgrno) and (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_ownper as market_ownper3, b.market_dollarown as market_dollarown3  
	from firms a left join market_own b
	on (a.owner3=b.mgrno) and (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_ownper as market_ownper4, b.market_dollarown as market_dollarown4  
	from firms a left join market_own b
	on (a.owner4=b.mgrno) and (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table firms as select distinct 
	a.*, b.market_ownper as market_ownper5, b.market_dollarown as market_dollarown5  
	from firms a left join market_own b
	on (a.owner5=b.mgrno) and (a.id1=b.id1);
quit;


******Calculate top5_val own (final variable name = top5_value)****;
data firms;
set firms;
if owner1<>. & owner2=. then ownper2=0;
if owner1<>. & owner2=. then shares2=0;
if owner1<>. & owner2=. then market_dollarown2=0;
if owner1<>. & owner2=. then market_ownper2=0;
if owner1<>. & owner3=. then ownper3=0;
if owner1<>. & owner3=. then shares3=0;
if owner1<>. & owner3=. then market_dollarown3=0;
if owner1<>. & owner3=. then market_ownper3=0;
if owner1<>. & owner4=. then ownper4=0;
if owner1<>. & owner4=. then shares4=0;
if owner1<>. & owner4=. then market_dollarown4=0;
if owner1<>. & owner4=. then market_ownper4=0;
if owner1<>. & owner5=. then ownper5=0;
if owner1<>. & owner5=. then shares5=0;
if owner1<>. & owner5=. then market_dollarown5=0;
if owner1<>. & owner5=. then market_ownper5=0;
dollarown_top5=(shares1+shares2+shares3+shares4+shares5)*price1;
market_dollarown=market_dollarown1+market_dollarown2+market_dollarown3+market_dollarown4+market_dollarown5;
dollarown_fin=market_dollarown-dollarown_top5;
top5_value=(dollarown_fin/1000)/(market_mve-mve);
run;


****create dataset to merge with final sample***;
data ownershipper3;
set ownershipper2;
id1=sic*1000000+year*10+month/3;
run;

data ownershipper3;
set ownershipper3;
if id1<1 then delete;
if year<2000 then delete;
run;

proc sort data=ownershipper3;
by rdate;
run;

data mhhi_calcs;
set ownershipper3;
run;

proc sort data=mhhi_calcs nodupkey;
by id1;
run;

data mhhi_calcs;
set mhhi_calcs;
keep sic rdate firm_num id1 month year;
run;


proc sql undo_policy = none;
	create table mhhi_calcs as select distinct 
	a.*, b.datacqtr, b.market_size, b.herfindahl
	from mhhi_calcs a left join herfindahl4 b
	on (a.id1=b.id1);
quit;

proc sql undo_policy = none;
	create table mhhi_merge as select distinct 
	a.*, b.rdate
	from herfindahl4 a left join mhhi_calcs b
	on (a.id1=b.id1);
quit;


proc sql undo_policy = none;
	create table mhhi_merge as select distinct 
	a.*, b.firmoverlap
	from mhhi_merge a left join covar.mhhifirmfinal_bh b
	on (a.id1=b.id1) and (a.cusip8=b.cusip);
quit;

proc sql undo_policy = none;
	create table mhhi_merge as select distinct 
	a.*, b.firmmhhi, b._freq_
	from mhhi_merge a left join covar.mhhifirmfinal b
	on (a.id1=b.id1) and (a.cusip8=b.cusip);
quit;


proc sql undo_policy = none;
	create table mhhi_merge as select distinct 
	a.*, b.top5_value
	from mhhi_merge a left join main.firms b
	on (a.id1=b.id1) and (a.cusip8=b.cusip8);
quit;


data main.mhhi_merge;
set mhhi_merge;
run;

data main.mhhi_merge;
set main.mhhi_merge;
if year<2000 then delete;
run;

********Institutional Ownership Calcs********;

data ownershipper_a;
set ownershipper2;
blockholder=0;
if ownper>0.05 then blockholder=1;
blockown=ownper*blockholder;
run;

proc sort data=ownershipper_a;
by cusip rdate;
run;


proc means data=ownershipper_a noprint;
var ownper blockholder blockown;
output out=inowntots
sum(ownper)=totalinown sum(blockholder)=blockholders sum(blockown)=totalbhown
;
BY cusip rdate;
run;

proc sql undo_policy = none;
	create table inownfinal as select distinct 
	a.*, b.rdate
	from herfindahl4 a left join mhhi_calcs b
	on (a.id1=b.id1);
quit;

data inownfinal;
set inownfinal;
if rdate=. then delete;
run;

proc sql undo_policy = none;
	create table inownfinal as select distinct 
	a.*, b.totalinown, b.blockholders, b.totalbhown
	from inownfinal a left join inowntots b
	on (a.cusip8=b.cusip) and (a.rdate=b.rdate);
quit;

data main.inownfinal;
set inownfinal;
run;

***merge institutional ownership into sample file***;
proc sql undo_policy = none;
	create table main.sample1 as select distinct 
	a.*, b.totalinown, b.blockholders, b.totalbhown
	from main.d_prelimsample_a a left join main.inownfinal b
	on (a.gvkey=b.gvkey) and (a.datacqtr=b.datacqtr);
quit;


data main.mhhi_merge2;
set main.mhhi_merge;
run;

proc sort data=main.mhhi_merge3 nodupkey;
by gvkey id1;
run;

****merge ownership data into main sample file****;
*****pszsample is downloaded from WRDS server to local server directory main before merge;

proc sql undo_policy = none;
	create table share1.pszsample1 as select distinct 
	a.*, b.*
	from main.pszsample a left join main.mhhi_merge2 b
	on (a.datacqtr=b.datacqtr) and (a.gvkey=b.gvkey);
quit;
***************************************************;
******Expert file to Stata*******;
PROC EXPORT DATA= share1.pszsample1
            OUTFILE= "Enter File Path\pszsample.dta" 
            DBMS=STATA REPLACE;
RUN;


/********************************************************************
PART 5: STATA Data Set (Run in .do file)
********************************************************************/
***Enter path to stata pszsample1.dta file****
use "Enter Path\pszsample1.dta"

****Check capitalization in exported file****
*****Make variable names lowercase****
rename SIC sic
rename Herfindahl herfindahl

destring sic, replace
gen sic2=int(sic/100)

gen fyear=substr(datafqtr, 1, 4)
gen fqtr=substr(datafqtr, 6, 1)
destring fyear, replace
destring fqtr, replace
gen yearquarter=fyear*4+fqtr

sort gvkey1 yearquarter type gvkeycc
sort gvkey1 yearquarter
duplicates drop gvkey1 yearquarter, force

***firm count***
gen firm_count1= _freq_+1

**institutional ownership****
gen totalinown2=totalinown
replace totalinown2=1 if totalinown2>1
replace totalinown2=. if totalinown==.
gen totalbhown2=totalbhown
replace totalbhown2=1 if totalbhown2>1
replace totalbhown2=. if totalbhown==.

gen nonbhin=totalinown2-totalbhown2

****ROA****
gen roa_a=ibq/atq

****If not analysts set to 0***
gen num_analysts2=num_analysts
replace num_analysts2=0 if num_analysts==.

*****Logged Variables*****
gen logindppe=ln(ind_ppe_med)
gen logms=ln(market_size)
gen logmtb=ln(mtb)
gen logmve=ln(mve)

*****Drop Obs with Missing Data******

gen allvar=1
replace allvar=0 if fc_ind==.
replace allvar=0 if logmtb==.
replace allvar=0 if logmve==.
replace allvar=0 if lev==.
replace allvar=0 if stdev==.
replace allvar=0 if roa==.
replace allvar=0 if abschange==.
replace allvar=0 if herfindahl==.
replace allvar=0 if num_analysts2==.
replace allvar=0 if totalinown2==.
replace allvar=0 if ind_ppe_med==.
replace allvar=0 if std_ind_sale==.

replace allvar=0 if logms==.
replace allvar=0 if fyear==1999
replace allvar=0 if fyear==2016
replace allvar=0 if mean_io==.
replace allvar=0 if allvar==.

replace allvar=0 if firmmhhi==.
replace allvar=0 if firmoverlap==.
replace allvar=0 if top5_value==.
replace allvar=0 if fyear==.
drop if allvar==0

*****Rename variables based on names used in manuscript*****
rename (firmmhhi firm overlap top5_value fc_ind stddev abschange herfindahl nonbhin totalbhown2 mean_io num_analysts2  std_ind_sal  ind_ppe_med logms) ///
(mhhi_overlap bh_overlap_pct top5_own fc_indicator stddev_sales abschange_Income hhi nobh_instown bhown_total mean_instown analyst_following stddev_ind_sales industry_ppe industry_sales)


****Additional Notes*****
****Logged values logmtb and logmve are used in analysis******
****firm_count1 is the variable used to split the sample by the number of firms in the industry (Table 4).****
***
For analysis related to CoLocation (Table 6), we download data of firms' headquarters location (Metropolitan Statistical Area) by gvkey and year using Loughran and McDonald's header data (https://sraf.nd.edu/data/augmented-10-x-header-data/) and merge this data into our sample. We then calculate the percentage of firms within the same SIC (4 digit) that are located in the same MSA for each firm to calculate Colocation. We exclude firms for which MSA is not defined (i.e., missing or international, MSA=-99) from this analysis
******
***We winsorize all variables at 1% and 99% using the winsor command****




