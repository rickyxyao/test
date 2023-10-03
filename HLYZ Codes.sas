***************************************************************************************************************************************************************************************;
***************************************************************************************************************************************************************************************;

* Code for Huang, Li, Yu, and Zhou (2020): The Effect of Managerial Litigation Risk on Earnings Warnings: Evidence from a Natural Experiment

* This code converts the raw data to the final matched sample used in the main analysis. The code shows how the raw data was transformed to produce the main sample used in the paper, which corresponds to the list of firms in the attached file labeled "firm list".

* The code is comprised of several smaller parts, detailed as follows:

	(1) Construct control variables
	(2) Construct test variable
	(3) Construct ud law variables
	(4) Merge and construct the sample

***************************************************************************************************************************************************************************************;
***************************************************************************************************************************************************************************************;

libname data 'location on computer';

libname final 'location on computer';


***************************************************************************************************************************************************************************************;

* Part (1) Construct control variables

- lmv 
- bm
- roa
- loss
- abret
- dma
- stdroa
- earn_surprise
- io
- seg
- litrisk

***************************************************************************************************************************************************************************************;

***** Calculate lmv, bm, roa, loss;
data c1;
set data.compustat_fundq;
monthindex=12*year(datadate)+month(datadate);
qtrindex=4*year(datadate)+qtr(datadate);
if fyearq>=1990 and fyearq<=2012;
sic4=sic+0;
keep gvkey fyearq fqtr datadate monthindex qtrindex ibq atq sic4 prccq cshoq ceqq;
run;

proc sort data=c1 nodupkey;
by gvkey datadate;run;

data c1;
set c1;
lmv=log(prccq*cshoq);
bm=ceqq/(prccq*cshoq);
if ceqq=0 then bm=.;
roa=ibq/atq;
if ibq<0 then loss=1;
else loss=0;
if atq>1;
run;

proc sort data=c1 nodup;
by gvkey monthindex;
run;

data qtr_control;
set c1;
by gvkey monthindex;
roa_1=lag(roa);
loss_1=lag(loss);
lmv_1=lag(lmv);
bm_1=lag(bm);
if gvkey^=lag(gvkey) or monthindex^=lag(monthindex)+3 then do;
roa_1=.;loss_1=.;lmv_1=.;bm_1=.;end;
run;


***** Calculate abret;
proc sql;
create table qtr_control
as select a.*, b.lpermno as permno
from qtr_control as a 
left join data.ccmxpf_linktable as b 
on a.gvkey=b.gvkey 
and (a.datadate>=b.linkdt or b.linkdt=.B) and (a.datadate<=b.linkenddt or b.linkenddt=.E)
and b.linktype in ("LU", "LC", "LD", "LF", "LN", "LO", "LS", "LX") and b.usedflag=1;
quit;

data qtr_control;
set qtr_control;
if permno^=.;
run;

proc sort data=qtr_control nodup;
by gvkey datadate;
run;

proc sort data=qtr_control nodupkey;
by gvkey datadate;
run;

data r1;
set data.crsp_msf;
monthindex=12*year(date)+month(date);
keep permno date monthindex ret vwretd;
run;

proc sort data=r1 nodupkey;
by permno date;
run;

proc sql;create table r2
as select a.*, log(1+b.ret) as ret, log(1+b.vwretd) as mret, b.date
from qtr_control a left join r1 b
on a.permno=b.permno
and a.monthindex>=b.monthindex
and a.monthindex-2<=b.monthindex;
quit;

proc sort data=r2 nodupkey;
by gvkey datadate date;run;

proc means data=r2 noprint;
var ret mret;
by gvkey datadate;
output out=r2 sum=ret mret;
run;

data r2;
set r2;
abret=exp(ret)-exp(mret);
monthindex=12*year(datadate)+month(datadate);
run;

proc sql;create table qtr_control 
as select a.*, b.abret
from qtr_control a left join r2 b 
on a.gvkey=b.gvkey
and a.datadate=b.datadate;
quit;

proc sql;create table qtr_control 
as select a.*, b.abret as abret_1
from qtr_control a left join r2 b 
on a.gvkey=b.gvkey
and a.monthindex=b.monthindex+3;
quit;


***** Calculate dma;
data ma;
set data.compustat_fundq;
if fyearq>=1990 and fyearq<=2012;
monthindex=12*year(datadate)+month(datadate);
if aqaq^=. then dma=1; 
keep gvkey monthindex dma;
run;

proc sort data=ma nodupkey;
by gvkey monthindex;
run;

proc sql;create table qtr_control
as select a.*, b.dma
from qtr_control a left join ma b 
on a.gvkey=b.gvkey 
and a.monthindex=b.monthindex;
quit;

proc sql;create table qtr_control
as select a.*, b.dma as dma_1
from qtr_control a left join ma b 
on a.gvkey=b.gvkey 
and a.monthindex=b.monthindex+3;
quit;

data qtr_control;
set qtr_control;
if dma=. then dma=0;
if dma_1=. then dma_1=0;
run;

***** Calculate stdroa;
data s1;
set data.compustat_fundq;
roa=ibq/atq;
monthindex=12*year(datadate)+month(datadate);
if roa^=.;
keep gvkey roa monthindex;
run;

proc sort data=s1 nodupkey;
by gvkey monthindex;
run;

data copy;
set s1;
run;

proc sql;
create table s2
as select a.*, b.roa as roa2, b.monthindex as monthindex2 
from s1 a 
left join copy b 
on a.gvkey=b.gvkey 
and a.monthindex-b.monthindex>=3
and a.monthindex-b.monthindex<=60;* past five years starting from one quarter prior to current quarter;
quit;

proc sort data=s2 nodupkey;
by gvkey monthindex monthindex2;
run;

proc means data=s2 noprint;
var roa2;
by gvkey monthindex;
output out=s3 std=stdroa;
run;

proc sql;create table qtr_control 
as select a.*, b.stdroa, b._freq_ as stdroa_nmiss
from qtr_control  a left join s3 b 
on a.gvkey=b.gvkey 
and a.monthindex=b.monthindex;
quit;


***** Calculate earn_surprise;
data a0;
set data.compustat_fundq;
monthindex=12*year(datadate)+month(datadate);
if ajexq=. then ajexq=1;
price=prccq/ajexq;
keep gvkey monthindex price rdq;
run;

proc sort data=a0 nodupkey;
by gvkey monthindex;
run;

data a0;
set a0;
by gvkey monthindex;
price_1=lag(price);
rdq_1=lag(rdq);
if gvkey^=lag(gvkey) or monthindex^=lag(monthindex)+3 then do;
price_1=.;rdq_1=.;end;
format rdq_1 yymmddn8.;
run;

proc sql;create table a1
as select a.*, b.rdq, b.rdq_1, b.price, b.price_1
from qtr_control a left join a0 b
on a.gvkey=b.gvkey 
and a.monthindex=b.monthindex;
quit;

data iclink;
set data.link_ibes_crsp_2016;
keep ticker permno score;
run;

proc sort data=iclink nodup;
by ticker score;
run;

proc sort data=iclink nodupkey;
by ticker;
run;

proc sql;create table a1
as select a.*, b.ticker
from a1 a left join iclink b 
on a.permno=b.permno;
quit;

proc sort data=a1 nodupkey;
by gvkey datadate;
run;

data a1;
set a1;
if rdq^=. and rdq_1^=. and ticker^="";
keep gvkey datadate rdq rdq_1 ticker price_1;
run;

data analyst2;
set data.analyst_detail_072718;
if measure="EPS" and (FPI="6" or FPI="7" or FPI="8" or FPI="9");
keep ticker fpedats anndats value estimator analys actual;
run;

proc sql;
create table a2 
as select a.*, b.estimator, b.analys, b.anndats, b.value, b.actual
from a1 a 
left join analyst2 b
on a.ticker=b.ticker 
and a.datadate=b.fpedats
and a.rdq_1<b.anndats
and b.anndats<=a.rdq_1+30;
quit;

data a2;
set a2;
if value^=.;
run;

proc sort data=a2 nodup;
by gvkey datadate estimator analys descending anndats;
run;

proc sort data=a2 nodupkey;
by gvkey datadate estimator analys;
run;

proc means data=a2 noprint;
var value actual;
by gvkey datadate;
id price_1;
output out=a3 median=medest actual;
run;

proc sql;create table qtr_control 
as select a.*, (b.actual-b.medest)/b.price_1 as earn_surprise
from qtr_control a left join a3 b 
on a.gvkey=b.gvkey 
and a.datadate=b.datadate;
quit;


***** Calculate io;
data io;set data.io_wrds;
monthindex=12*year(rdate)+month(rdate);
run;
* io_wrds is obtained by running the code from wrds:https://wrds-www.wharton.upenn.edu/pages/support/applications/institutional-ownership-research/institutional-ownership-concentration-and-breadth-ratios/;

proc sql;create table qtr_control
as select a.*, b.io
from qtr_control a left join io b
on a.permno=b.permno
and a.monthindex>=b.monthindex>a.monthindex-3;
quit;

proc sort data=qtr_control nodupkey;
by gvkey monthindex;
run;

data qtr_control;
set qtr_control;
by gvkey monthindex;
io_1=lag(io);
if gvkey^=lag(gvkey) or monthindex^=lag(monthindex)+3 then io_1=.;
run;

data qtr_control;
set qtr_control;
if io=. then io=0;
if io_1=. then io_1=0;
run;


***** Calculate seg;
data segment1;
set data.wrds_segmerged;
run;

proc sort data=segment1;
by gvkey datadate stype descending srcdate sics1;
run;

proc sort data=segment1 nodupkey;
by gvkey datadate stype sid;
run;

data segment1;
set segment1;
if stype="BUSSEG" then bseg=1;else bseg=0;
if stype="GEOSEG" then gseg=1;else gseg=0;
run;

proc sort data=segment1 nodup;
by gvkey datadate;
run;

proc means data=segment1 noprint;
var bseg gseg;
by gvkey datadate;
output out=segment2 sum=bseg gseg;
run;

data segment2;
set segment2;
if month(datadate)<6 then fyear=year(datadate)-1;
else fyear=year(datadate);
run;

proc sort data=segment2 nodup;
by gvkey fyear;
run;

proc sort data=segment2 nodupkey;
by gvkey fyear;
run;

proc sql;create table qtr_control
as select a.*, b.bseg, b.gseg
from qtr_control a left join segment2 b 
on a.gvkey=b.gvkey 
and a.fyearq=b.fyear;
quit;

proc sql;create table qtr_control
as select a.*, b.bseg as bseg_1, b.gseg as gseg_1
from qtr_control a left join segment2 b 
on a.gvkey=b.gvkey 
and a.fyearq=b.fyear+1;
quit;

data qtr_control;
set qtr_control;
if bseg=. then bseg=1;
if gseg=. then gseg=1;
if bseg_1=. then bseg_1=1;
if gseg_1=. then gseg_1=1;
seg=bseg+gseg;
seg_1=bseg_1+gseg_1;
run;


***** Calculate litrisk;
data a1;set data.compustat_funda;
if 1990<=fyear<=2012;
monthindex=12*year(datadate)+month(datadate);
keep gvkey fyear datadate sich monthindex;
run;

proc sql;
create table a1
as select a.*, b.lpermno as permno
from a1 as a 
left join data.ccmxpf_linktable as b 
on a.gvkey=b.gvkey 
and (a.datadate>=b.linkdt or b.linkdt=.B) and (a.datadate<=b.linkenddt or b.linkenddt=.E)
and b.linktype in ("LU", "LC", "LD", "LF", "LN", "LO", "LS", "LX") and b.usedflag=1;
quit;

data a1;
set a1;
if permno^=.;
run;

proc sort data=a1 nodup;
by gvkey datadate;
run;

proc sort data=a1 nodupkey;
by gvkey datadate;
run;

data a2;set a1;
litigate=0; if 
(sich>=2833 and sich<=2836)or
(sich>=8731 and sich<=8734)or 
(sich>=3570 and sich<=3577)or
(sich>=7370 and sich<=7374)or
(sich>=3600 and sich<=3674)or
(sich>=5200 and sich<=5961)then litigate=1;
run;

data a2b;
set data.crsp_msf;
monthindex=12*year(date)+month(date);
keep permno date monthindex ret vwretd;
run;

proc sort data=a2b nodupkey;
by permno date;
run;

proc sql;create table a2c 
as select a.*, log(1+ret) as ret,log(1+vwretd) as mret, b.date
from a2 a left join a2b b
on a.permno=b.permno
and a.monthindex>=b.monthindex>a.monthindex-12;
quit;

proc sort data=a2c nodupkey;
by gvkey fyear date;run;

proc means data=a2c noprint;
var ret mret;
by gvkey fyear;
output out=a2c sum=ret mret;run;

data a2c;
set a2c;
abret=exp(ret)-exp(mret);
run;

proc sql;create table a3 
as select a.*, b.abret
from a2 a left join a2c b 
on a.gvkey=b.gvkey
and a.fyear=b.fyear;
quit;

data a3b;
set data.compustat_funda;
if at<=0 then at=.;
lat=log(at);
keep gvkey fyear datadate lat sale at;run;

proc sort data=a3b nodup;
by gvkey fyear;
run;

data a3b;set a3b;
by gvkey fyear;
sg=(sale-lag(sale))/lag(at);
if gvkey^=lag(gvkey) or fyear^=lag(fyear)+1 or lag(at)<=0 then sg=.;
run;

proc sql;create table a3
as select a.*, b.*
from a3 a left join a3b b 
on a.gvkey=b.gvkey
and a.fyear=b.fyear;
quit;

proc sort data=a3 nodup;
by gvkey fyear;
run;

data a3;set a3;
by gvkey fyear;
end=datadate;
beg=lag(datadate);
if gvkey^=lag(gvkey) or fyear^=lag(fyear)+1 
then beg=intnx("month",datadate,-12,"end");
format beg end yymmddn8.;
run;

data c1;set a3;
keep permno fyear beg end;
run;

proc sort data=c1 nodup;
by permno fyear;
run;

proc sql;create table c2 
as select a.*, (b.vol*b.cfacshr) as vol, (b.shrout*b.cfacshr) as shrout, b.ret, b.date 
from c1 a left join data.crsp_msf b 
on a.permno=b.permno and a.beg<b.date<=a.end;
quit;

proc sort data=c2 nodupkey;
by permno fyear date;
run;

proc means data=c2 noprint;
var ret vol;
by permno fyear;
output out=c3 sum(vol)=vol
std(ret)=std_ret skewness(ret)=skew_ret;
run;

proc sort data=c2 nodup;
by permno fyear date;
proc sort data=c2 nodupkey;
by permno fyear;
run;

proc sql;create table c3 as select a.*, b.shrout 
from c3 a left join c2 b 
on a.permno=b.permno and a.fyear=b.fyear;
quit;

data c3;set c3;
turnover=vol*100/(shrout*1000);
run;

proc sql;create table c4
as select a.*, b.*
from a3 a left join c3 b
on a.permno=b.permno
and a.fyear=b.fyear;
quit;

data c4;set c4;
litrisk=1/(1+exp(-(-7.883+litigate*0.566+lat*0.518+sg*0.982+abret*0.379-skew_ret*0.108+std_ret*25.635+turnover*0.00007/1000)));
run;

proc sql;create table litrisk
as select a.*, b.litrisk
from a3 a left join c4 b 
on a.gvkey=b.gvkey
and a.fyear=b.fyear+1;
quit;

proc sql;create table qtr_control
as select a.*, b.litrisk
from qtr_control a left join litrisk b
on a.gvkey=b.gvkey
and a.fyearq=b.fyear;
quit;

proc sql;create table qtr_control
as select a.*, b.litrisk as litrisk_1
from qtr_control a left join litrisk b
on a.gvkey=b.gvkey
and a.fyearq=b.fyear+1;
quit;

data final.qtr_control;
set qtr_control;
run;

***************************************************************************************************************************************************************************************;

* Part (2) Construct test variable

- warn

***************************************************************************************************************************************************************************************;

** read in first call data;
data a1;
set data.cig;
run;

** define good/bad news by analysts forecasts;
data analyst1;
set data.analyst_usummary_eps;
if fiscalp="QTR" then periodicity="Q";
else if fiscalp="ANN" then periodicity="A";
else periodicity="";
if periodicity^="";
keep cusip ticker cname periodicity statpers medest meanest stdev fpedats;
run;

proc sort data=analyst1 nodupkey;
by cusip fpedats periodicity statpers;
run;

proc sql;
create table a2
as select *
from a1 a 
left join analyst1 b 
on a.cusipg=b.cusip 
and a.periodicity=b.periodicity
and a.fpe=b.fpedats
and a.anndate>b.statpers;
quit;

data a2;
set a2;
if medest^=.;
run;

proc sort data=a2 nodup;
by cusipg anndate fpe periodicity descending statpers;
run;

proc sort data=a2 nodupkey;
by cusipg anndate fpe periodicity;
run;

data a3;
set a2;
if CIGCODEQ in ("A", "Z", "F") then surp=est_1-medest;
else if CIGCODEQ="B" then surp=(est_1+est_2)/2-medest;
else if CIGCODEQ="G" then surp=est_1-medest;
else if CIGCODEQ="H" then surp=est_2-medest;
else if CIGCODEQ in ("1", "2", "4", "6", "8", "L", "U", "W") and est_1>medest then surp=0;
else if CIGCODEQ in ("1", "2", "4", "6", "8", "L", "U", "W") and est_1<=medest then surp=-100;
else if CIGCODEQ="X" and medest<0 then surp=0;
else if CIGCODEQ="X" and medest>=0 then surp=-100;
else if CIGCODEQ in ("3", "7", "C", "E", "M", "V") and est_1<medest then surp=0;
else if CIGCODEQ in ("3", "7", "C", "E", "M", "V") and est_1>=medest then surp=100;
else if CIGCODEQ="Y" and medest>0 then surp=0;
else if CIGCODEQ="Y" and medest<=0 then surp=100;
else if CIGCODEQ in ("5", "P", "Q") then surp=100;
else if CIGCODEQ in ("D", "J", "K", "R", "T") then surp=-100; 
else if CIGCODEQ in ("O", "N") then surp=0;
run;

data a3;
set a3;
if surp>0 then news_analyst=1;
else if surp<0 then news_analyst=-1;
else if surp=0 then news_analyst=0;
run;

data date;
set data.compustat_fundq; 
monthindex=12*year(datadate)+month(datadate);
keep gvkey datadate monthindex fyearq fqtr rdq;
run;

proc sort data=date nodupkey;
by gvkey datadate;
run;

data date;
set date;
by gvkey datadate;
rdq_1=lag(rdq);
format rdq_1 yymmddn8.;
if gvkey^=lag(gvkey) or monthindex^=lag(monthindex)+3
then do;rdq_1=.;end;
run;

proc sql;
create table a4
as select a.*, b.*
from a3 a left join date b 
on a.gvkey=b.gvkey 
and a.fpe=b.datadate;
quit;

proc sort data=a4 nodupkey;
by cusipg anndate fpe periodicity est_1 est_2;
run;

***** Calculate warn;
data a5;
set a4;
if anndate>=rdq_1+30 and anndate<rdq then warn=1;else warn=0;
if data_type="EPS" and periodicity="Q";
if news_analyst=-1;
run;

proc sort data=a5 nodup;
by gvkey fyearq fqtr;
run; 

proc means data=a5 noprint;
var warn;
by gvkey fyearq fqtr;
output out=a6 sum=warn;
run;

data final.firstcall_forecast;
set a6;
run;


***************************************************************************************************************************************************************************************;

* Part (3) Construct ud law variables

- treat
- post

***************************************************************************************************************************************************************************************;

data cstate1;
set data.compustat_funda;
where consol="C" and indfmt="INDL" and datafmt="STD" and popsrc="D" and curcd="USD";
keep gvkey fyear datadate incorp state;
run;

proc sort data=cstate1 nodupkey;
by gvkey fyear;
run;

** historical state from bill mcdonald's web *****;
proc import out=hstate1 datafile="C:\D\UD and warnings\raw data\LM_EDGAR_10X_Header_1994_2017.csv" replace;
run;

data hstate1;
set hstate1;
hincorp=state_of_incorp;
hdq=ba_state;
date=conf_per_rpt;
keep cik hincorp hdq date;run;

proc sort data=hstate1 nodup;
by cik date;
run;

data hstate2;
set hstate1;
year=int(date/10000);
month=int((date-year*10000)/100);
datadate=intnx("month",mdy(month,1,year),0,"end");
format datadate yymmddn8.;
run;

data link1;
set data.wrds_cik_gvkey_link_2017;
numcik=input(cik,10.);
format datadate1 yymmddn8.;
format datadate2 yymmddn8.;
keep numcik gvkey datadate1 datadate2;
run;

proc sort data=link1 nodupkey;
by numcik gvkey;
run;

proc sql;
create table hstate3
as select a.*, b.gvkey
from hstate2 a 
left join link1 b 
on a.cik=b.numcik
and b.datadate1<=a.datadate<=b.datadate2;
quit;

** drop invalid state names;
data all_state;
set data.all_state_name_dummy;
run;

data hstate3;
set hstate3;
hincorp=upcase(hincorp);
hdq=upcase(hdq);
run;

proc sql;
create table hstate3 
as select a.*, b.dummy as valid1
from hstate3 a 
left join all_state b 
on a.hincorp=b.state;
quit;

proc sql;
create table hstate3 
as select a.*, b.dummy as valid2
from hstate3 a 
left join all_state b 
on a.hdq=b.state;
quit;

data hstate4;
set hstate3;
if valid1^=. and gvkey^="";
keep gvkey datadate hincorp;
run;

proc sort data=hstate4 nodup;
by gvkey datadate;
run;

proc sort data=hstate4 nodupkey;
by gvkey datadate;
run;

proc sort data=cstate1 nodupkey;
by gvkey fyear;
run;

data cstate1;
set cstate1;
by gvkey fyear;
beg=lag(datadate);
if gvkey^=lag(gvkey) or fyear^=lag(fyear)+1 then beg=.;
format beg yymmddn8.;
run;

proc sql;
create table cstate2 
as select a.*, b.hincorp, b.datadate as datadate2
from cstate1 a 
left join hstate4 b
on a.gvkey=b.gvkey 
and a.beg<b.datadate<=a.datadate;
quit;

data hstate5;
set hstate3;
if valid2^=. and gvkey^="";
keep gvkey datadate hdq;
run;

proc sort data=hstate5 nodup;
by gvkey datadate;
run;

proc sort data=hstate5 nodupkey;
by gvkey datadate;
run;

proc sql;
create table cstate2 
as select a.*, b.hdq
from cstate2 a
left join hstate5 b
on a.gvkey=b.gvkey 
and a.beg<b.datadate<=a.datadate;
quit;

proc sort data=cstate2 nodup;
by gvkey fyear;
run;

proc sort data=cstate2 nodup;
by gvkey fyear descending datadate2;
run;

proc sort data=cstate2 nodupkey;
by gvkey fyear;
run;

data cstate3;
set cstate2;
incorp_adjust=hincorp;
if fyear<1993 then incorp_adjust="";
run;

data cstate3;
set cstate3;
if incorp_adjust="" then incorp_adjust=incorp;
run;

proc sort data=cstate3 nodupkey;
by gvkey fyear;
run;

data ud1;
set data.ud_state_list;
run;

proc sql;
create table ud2
as select a.*, b.year as event_year
from cstate3 a 
left join ud1 b 
on a.incorp_adjust=b.state;
quit;

** define treat post;
data ud2;
set ud2;
if incorp_adjust^="";
if event_year^=. then treat=1;else treat=0;
if event_year^=. and fyear>=event_year then post=1;else post=0;
run;

data final.event_dummy;
set ud2;
run;

***************************************************************************************************************************************************************************************;

* Part (4) Merge and construct the main sample

***************************************************************************************************************************************************************************************;

** merge data;
proc sql;
create table m1 as select a.*, b.*
from final.qtr_control a left join final.event_dummy b 
on a.gvkey=b.gvkey 
and a.fyearq=b.fyear;
quit;

proc sql;
create table m1 as select a.*, b.*
from m1 a left join final.firstcall_forecast b 
on a.gvkey=b.gvkey
and a.fyearq=b.fyearq
and a.fqtr=b.fqtr;
quit;

data m1;
set m1;
if warn=. then warn=0;
if warn>0 then occur=1;else occur=0;
run;

**  firms that change treatment status;
data treat1;
set m1;
if treat^=.;
keep gvkey treat;
run;

proc sort data=treat1 nodup;
by gvkey treat;
run;

proc sort data=treat1 nodupkey dupout=treat2;
by gvkey;
run;

proc sql;
create table m1 
as select a.*, b.gvkey as chtreat
from m1 a 
left join treat2 b
on a.gvkey=b.gvkey;
quit;


** unmatched full sample;
data m2;set m1;
if chtreat="" and 1995<=fyearq<=2010 and incorp_adjust^="";
if nmiss(treat, post, io, abret, roa, loss, stdroa, lmv, bm, seg, earn_surprise, litrisk)=0;
if nmiss(io_1, abret_1, roa_1, loss_1, stdroa, lmv_1, bm_1, seg_1, litrisk_1)=0;
if stdroa_nmiss>=10;
if ((sic4>=4000 and sic4<=4999) or (sic4>=6000 and sic4<=6999)) then delete ;
if incorp_adjust in ("GA","MI","FL","WI","MT","VA","UT","NH","MS","NC") then delete;
if sic4^=. & hdq^="";
run; 

%INC"C:\D\DATA\data\winsor.SAS";
%WINSOR(DSETIN=m2,DSETOUT=m3,BYVAR=fyearq,VARS=io_1 io abret_1 abret roa_1 roa stdroa lmv_1 lmv bm_1 bm seg_1 seg litrisk_1 litrisk earn_surprise,TYPE=winsor,PCTL=1 99);
proc export data=m3 outfile="location on computer\merged_sample.dta" replace;run;


/** calculate pscore in STATA;

use "location on computer\merged_sample.dta", clear
ffind sic4, newvar(ff) type(48)
keep if earn_surprise<=-0.01
xi: psmatch2 treat lmv_1 bm_1 io_1 abret_1 roa_1 loss_1 earn_surprise stdroa seg_1 dma_1 litrisk_1, out(occur) logit noreplacement ate
save "location on computer\warn_pscore.dta", replace

*/

** bad news matched sample;
proc import out=p1 datafile="location on computer\warn_pscore.dta" replace;run;

data treat1;
set p1;
where treat=1;
keep gvkey datadate fyearq fqtr post ff _pscore event_year;
run;

data control1;
set p1;
where treat=0; 
keep gvkey datadate fyearq fqtr post ff _pscore;
run;

proc sql;
create table match1
as select a.*, b.gvkey as gvkey2, b._pscore as _pscore2
from treat1 a 
left join control1 b
on a.ff=b.ff
and a.datadate=b.datadate;
quit;

data match2;
set match1;
diff=abs(_pscore-_pscore2);
if diff^=. ;
if diff<=0.05;
run;

proc sort data=match2 nodup;
by gvkey datadate diff;
run;

proc sort data=match2 nodupkey;
by gvkey datadate;
run;

data treat2;
set match2;
treat=1;
keep gvkey datadate fyearq fqtr treat post event_year;
run;

data control2;
set match2;
gvkey=gvkey2;
treat=0;
keep gvkey datadate fyearq fqtr treat post event_year;
run;

data match3;
set treat2 control2;
run;

proc sql;
create table match4
as select a.*, b.*
from match3 a 
left join p1 b 
on a.gvkey=b.gvkey
and a.datadate=b.datadate;
quit; 

proc export data=match4 outfile="location on computer\match_sample.dta" replace;run;




