*SAS Code for Analysis of Management forecasts and CDS;
options nodate pageno=1 linesize=100 pagesize=100;
options noxwait fullstimer;

libname pay1 'Directory for management forecast data from First Call';
libname fc 'Director for Other data from First Call';
libname ibes 'Directory for management forecast data from IBES';
libname cds "Directory for data for CDS data and for the final test sample";
libname raw "Directory for supplementary raw data";
libname SEO "Directory for Equity offering data from SDC";
libname ACQ "Directory board and blockholding data from Corporate Library";

*Macro to winsorize variables of continuous type;
%macro Wins(raw_dset,input_dset,var,p1, p2);
proc univariate data=&input_dset noprint; *percentile*;
where not missing(&var);
var &var; 
by w;
output out=&input_dset._1 
    &p1= p1_&var
    &p2= p2_&var
run;

data &raw_dset ; * data winsorization;
merge &raw_dset &input_dset._1;
by w;
if &var =. then &var._w = .;
else if &var ne . and &var =< p1_&var then                    &var._w = p1_&var; 
else if &var ne . and &var >= p2_&var then                    &var._w = p2_&var;
else if &var ne . and &var > p1_&var and  &var < p2_&var then &var._w = &var;
drop p1_&var p2_&var;
run;
%mend Wins;

*Part A: to obtain control variables from Compustat, CRSP, 13F, IBES;
*(A-1) compustat data
SIC code, total ssets, MTB, ROA, Big4 Dummy;

signoff;
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
  options comamid=TCP remote=WRDS;
  signon username=_prompt_;

rsubmit;

options source nocenter ls=72 ps=max;
title 'Compustat North America data extract';
libname comp '/wrds/comp/sasdata/naa';

proc sql; create table a1
as select a.*
from comp.funda as a
where a.datadate >= '01JAN1994'd and 
      a.indfmt='INDL' and a.datafmt='STD' and a.popsrc='D' and a.consol='C';
run;

proc sort data=a1;   by gvkey datadate;
run;
endrsubmit; 

rsubmit;
proc sql; create table a2
as select a.*
from comp.funda_fncd as a
where a.datadate >= '01JAN1994'd and
      a.indfmt='INDL' and a.datafmt='STD' and a.popsrc='D' and a.consol='C';;
run;

proc sort data=a2;   by gvkey datadate;
run;
endrsubmit; 

* SQL left join used to combine the sets into a single SAS dataset;
* The screen for indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' 
* makes it unneccesary to combine based on these codes;
rsubmit;
proc sql;
  create table a3
    as select *
    from a1 as a
    left join a2 as b
      on a.gvkey=b.gvkey and a.datadate=b.datadate
     and a.indfmt=b.indfmt and a.datafmt=b.datafmt 
     and a.popsrc=b.popsrc and a.consol=b.consol
	order by a.gvkey, a.datadate;
quit;

data a4;
set a3;
where consol = "C"
    and popsrc = "D"
    and datafmt = "STD"
    and indfmt = "INDL";

	*if AT>0;
	if year(datadate)>=1994;
	if fyear^=.;
	format datadate yymmdd10. ;

keep CIK gvkey cusip sich fyear datadate final UPD costat  fyr TIC EMP
     AT LT ACT LCT INVT RECT OIADP  AU AUOP AUOPIC        FCA  NI   CSHO PRCC_F CEQ   XIDO  SSTK DLTIS        IB EMP SALE
     AT_DC LT_DC ACT_DC LCT_DC INVT_DC RECT_DC OIADP_DC AUOP_DC AUOP_FN FCA_DC NI_DC  CSHO_DC CEQ_DC XIDO_DC SSTK_DC DLTIS_DC   IB_DC EMP_DC EMP_FN SALE_DC
     XRD XRD_DC
;
run;
endrsubmit; 

*Add CRSP-COMP link;
rsubmit;
libname ccm '/wrds/crsp/sasdata/a_ccm';

proc sort data=ccm.CCMXPF_LINKTABLE out=link;
by gvkey lpermno lpermco linkdt linkenddt;
run;

/*=======		Step 1: use most restrictive criteria 		================*/
proc sort data=a4; by gvkey datadate; run;

proc sql;
	create table a4 as select a.*, b.lpermno
	from a4(sortedby=gvkey datadate) a 
	left join link(sortedby=gvkey) b
	on a.gvkey=b.gvkey and
	b.linktype in ("LC" "LU" "LX" "LS") and
	b.linkprim in ("P" "C") and
	b.usedflag=1 and
	b.lpermno^=. and
	(b.linkdt<=a.datadate or b.linkdt=.B) and 
	(b.linkenddt>=a.datadate or b.linkenddt=.E);
quit;

data a5;
	set a4;
	if lpermno^=.;
run;

proc sort data=a4 nodupkey; by gvkey datadate; run;

/*=======		If Step 1 didn't find a link then do 		================*/
/*=======		Step 2: use less restrictive criteria 		================*/
proc sql;
	create table a4 as select a.*, b.lpermno as lpermno2
	from a4(sortedby=gvkey datadate) a 
	left join link(sortedby=gvkey) b
	on a.gvkey=b.gvkey and
	b.linktype in ("LC" "LU" "LX" "LD" "LS" "LN") and
	b.usedflag=1 and
	a.lpermno=. and b.lpermno^=. and
	(b.linkdt<=a.datadate or b.linkdt=.B) and 
	(b.linkenddt>=a.datadate or b.linkenddt=.E);
quit;

data a5;
	set a4;
	if lpermno2^=.;
run;

proc sort data=a4 nodupkey; by gvkey datadate; run;

/*=====		If Steps 1 and 2 didn't find a link then do 		============*/
/*========		Step 3: use least restrictive criteria 		================*/
proc sql;
	create table a4 as select a.*, b.lpermno as lpermno3
	from a4(sortedby=gvkey datadate) a 
	left join link(sortedby=gvkey) b
	on a.gvkey=b.gvkey and
	b.linktype in ("LC" "LU" "LX" "LD" "LS" "LN") and
	a.lpermno=. and a.lpermno2=. and b.lpermno^=. and
	(b.linkdt<=a.datadate or b.linkdt=.B) and 
	(b.linkenddt>=a.datadate or b.linkenddt=.E);
quit;

data a5;
	set a4;
	if lpermno3^=.;
run;

data a6;
	set a4;
	if lpermno=. and lpermno2^=. then lpermno=lpermno2;
	if lpermno=. and lpermno3^=. then lpermno=lpermno3;
	drop lpermno2 lpermno3;
run;

proc download data=a6 out=aud_0_0; run;
endrsubmit; 

proc sort data=aud_0_0 nodupkey; by gvkey datadate;run;

data aud_0_1;
set aud_0_0;
permno = lpermno;

LNTA = log(AT*1000);
SQEMPLS = sqrt(EMP);
DA = LT / AT;
LIQ = ACT / LCT;
INVREC = (INVT + RECT) / AT;
ROA = OIADP / AT;
if not missing(FCA) then FOROPS = 1; else FOROPS = 0;

MVE = CSHO*PRCC_F;

BM = CEQ / MVE;
if XIDO ne 0 then XDOPS = 1; else XDOPS = 0;
PB_raw = -4.336 - 4.513*(NI/AT) + 5.679*(LT/AT) + 0.004*(ACT / LCT);
PB = CDF('NORMAL',PB_raw);
if SSTK > 10 then NEW_FIN_r =1;
else if DLTIS > 1 then NEW_FIN_r =1;
else NEW_FIN_r = 0;

Auditor = input(au, comma9.);
if auditor > 0 and auditor < 9 then Big5 =1; else Big5=0;

Aud_Op = input(AUOP, comma9.);
run;

data aud_0_2;
set aud_0_1;

lag_gvkey = lag1(gvkey);
lag_fyear = lag1(fyear);

lag_NI = lag1(NI);
lag_SALE = lag1(SALE);
lag_PB = lag1(PB);
lag_Auditor = lag1(Auditor);
lag_Aud_Op = lag1(Aud_Op);

if gvkey ne lag_gvkey or fyear ne lag_fyear + 1 then do;
lag_NI = .;
lag_SALE = .;
lag_PB = .;
lag_Auditor = .;
lag_Aud_Op = .;

end;

GR_SALES = (SALE - lag_SALE) / lag_SALE;
Chg_PB = PB - lag_PB;
if NI < 0 or lag_NI < 0 then LOSS = 1; else LOSS = 0;

if Aud_Op = 2 or lag_Aud_Op = 2 then OPINION = 1; else OPINION = 0;
if not missing(Auditor) and not missing(lag_Auditor) and lag_Auditor ne 0 and Auditor ne 0 and Auditor ne lag_Auditor then Chg_Auditor = 1;
else Chg_Auditor = 0;
drop lag_NI lag_SALE lag_PB;
run;

data aud_0_2_1;
set aud_0_2;

lag_gvkey = lag1(gvkey);
lag_fyear = lag1(fyear);
lag_Chg_Auditor = lag1(Chg_Auditor);

if gvkey ne lag_gvkey or fyear ne lag_fyear + 1 then lag_Chg_Auditor = .;
if Chg_Auditor = 1 or lag_Chg_Auditor = 1 then INITIAL = 1;
run;

proc sort data=aud_0_2_1 nodupkey; by gvkey descending datadate;run;

data aud_0_3;
set aud_0_2_1;
for_gvkey = lag1(gvkey);
for_fyear = lag1(fyear);
for_NEW_FIN_r = lag1(NEW_FIN_r);

if gvkey ne for_gvkey or fyear ne for_fyear -1 then for_NEW_FIN_r = .;
if NEW_FIN_r = 1 or for_NEW_FIN_r = 1 then NEW_FIN = 1;
else NEW_FIN = 0;
run;

proc sort data=aud_0_3 nodupkey; by gvkey datadate;run;

*(A-2) Stock return data from CRSP: 1-year return, market adjusted return, variance from the market model;
proc sort data=aud_0_3 out=permnos(keep = permno fyear datadate) nodupkey;
where not missing(permno);
by permno fyear;
run;

data permnos;
set permnos;
Ret_Beg = intnx('month',datadate, -11,'beginning'); format Ret_Beg YYMMDD10.;
Ret_End = intnx('day',datadate, 0,'end'); format Ret_End YYMMDD10.;
ID = _n_;
run;

data permnos_1;
set permnos;
*if ID < 75000;
if ID >= 75000;
run;


signoff;
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP;
signon wrds username=_prompt_;

rsubmit;
libname crsp '/wrds/crsp/sasdata/a_stock ';

proc upload data= permnos_1 out=permnos; run;

proc sql; create table Ret_1
as select  b.id, b.Ret_Beg, b.Ret_End, b.permno, b.datadate, a.RET, a.date 
from crsp.dsf as a, permnos as b
where a.permno=b.permno and a.date >= b.Ret_Beg and a.date <= b.Ret_End;
run;

proc sort data=Ret_1;
 by permno date;
run;
endrsubmit;

rsubmit;
proc sql; create table Ret_2
as select a.*, b.DLRET
from Ret_1 a left join crsp.dseall b
on a.permno=b.permno and a.date = b.date;
run;

proc sql;
       create table Ret_3
       as select a.*,b.VWRETD
       from Ret_2 a  left join crsp.dsi b
       on a.date = b.date; 
quit; 
endrsubmit;

rsubmit;
data Ret_4;
set Ret_3;
if missing(RET) and not missing(DLRET) then RET = DLRET;
if missing(ret) then VWRETD = .;
run;

proc sort data = Ret_4 out=Ret_5 nodupkey;
by ID date;
run; 
endrsubmit;

*to calculate compound returns;
rsubmit;
proc sql;
       create table Ret_6
	   as select ID, 
	   exp(sum(log(1+ret))) - 1 as Com_Ret, n(ret) as N_Ret, nmiss(ret) as N_Miss,  std(ret) as RET_STD,
	   exp(sum(log(1+VWRETD))) - 1 as Com_MkRet

	   from Ret_5 (keep=id ret Ret_Beg Ret_End date VWRETD)
	   where Ret_Beg <= date <= Ret_End 
	   group by ID;
run;

proc sql;
       create table Ret_7
       as select a.*,b.*
       from permnos a  left join Ret_6 b
       on a.ID = b.ID; 
quit; 

proc download data=Ret_7 out=aud_0_4_2; run;
endrsubmit;

*proc download data=Ret_7 out=aud_0_4_1; run;
*endrsubmit;

data aud_0_4;
set aud_0_4_1 aud_0_4_2;
run;

*to add;
proc sql;
       create table permnos_2
       as select a.*,b.*
       from permnos a  left join aud_0_4 b
       on a.ID = b.ID; 
quit; 

*to add;
proc sql;
       create table aud_0_5
       as select a.*,b.Com_Ret, b.N_Ret, b.RET_STD, b.Com_MkRet
       from aud_0_3 a  left join permnos_2 b
       on a.permno = b.permno and a.datadate=b.datadate; 
quit; 

* (A-3) Institutional holdings: based on tfnhsum2.sas at the beginning of the year t;
rsubmit;
libname tfn '/wrds/tfn/sasdata/s34';

* Items that can be changed;
%let tfn_ds= tfn.s34;              * The TFN dataset to be used ;
%let ds_save= work.s34hsum1;       * holds results of summary stats;
%let ikey= mgrno;                  * Investment company ID-- S34 set uses MGRNO, S12 uses FUNDNO;

%let year1 =  1994;                * First year (used to calculate date1 below) ;
%let year2 =  2015;                * Last year (used to calculate date2 below);

%let date1 = "01jan&year1"d ;      * Start of date range, Jan1 of year1;
%let date2 = "31dec&year2"d ;      * End of date range, Dec31 of year2;

* Step 1-- Pullout data, using proc sort step;
* And sort into the right order to sum shares by rdate within a cusip group; 
proc sort data=&tfn_ds 
     (keep= rdate cusip ticker shrout1 shrout2 prc shares &ikey)
     out=temp1; 
  where  (&date1 <= rdate <= &date2) ;
  by cusip rdate;
run;

* Last Step-- Sum up shares for each CUSIP, compute summary stats and create (output) results; 
*  The sum of shares is computed until the last case for the RQDATE, and then a single; 
*  observation for each RQDATE is put into the final data set;

data temp2;
  set temp1; 
  by cusip  rdate;
  if first.rdate then do;
    shares_held=0;
    n_held=0;
  end;

  if shares gt 0 then do;
    n_held + 1;
    shares_held + shares;
  end; 

  if last.rdate then do;
    total_shares_out= shrout1 * 1000000; *shrout1 is in millions; 
    if shrout2 gt 0 then total_shares_out= shrout2 * 1000; *shrout2 is in thousands; 
    if total_shares_out gt 0 then held_pct= shares_held / total_shares_out;
    if prc > 0 then do;
      total_market_value = prc * total_shares_out;
      held_value = prc * shares_held;
    end;
    output;
  end;
 keep cusip ticker rdate shares_held n_held total_shares_out total_market_value held_value held_pct;
run;

proc download data= temp2 out=aud_0_6; run;
endrsubmit;

*to obtain the ncusip (historical cusip) since TFN provides only historical cusips while compustat uses current cusip (cusip header);
rsubmit;
libname crsp '/wrds/crsp/sasdata/a_stock ';
proc download data= crsp.STOCKNAMES out=STOCKNAMES; run;
endrsubmit;

proc sql;
       create table aud_0_6_1
       as select a.*, b.PERMNO, b.ncusip, b.CUSIP as c_cusip
       from aud_0_6 a left join STOCKNAMES b
       on not missing(a.cusip) and a.cusip = b.ncusip and a.rdate >= b.NAMEDT and a.rdate <= b.NAMEENDDT;
quit; 

proc sort data=aud_0_6_1 out = aud_0_6_2 nodupkey;
by cusip rdate;
run;

*to obtain institutional ownership at the beginning of year year t;
data aud_1_0;
set aud_0_5;
Y_Beg = intnx('month',datadate, -11,'beginning'); format Y_Beg YYMMDD10.;
Y_End = intnx('day',datadate, 0,'end'); format Y_End YYMMDD10.;
cusip8 = substr(cusip, 1, 8);
keep tic datadate GVKEY Fyear Y_Beg Y_End cusip permno cusip8;
run;

proc sort data=aud_1_0;
by cusip8 datadate;
run;

proc sql;
       create table aud_1_1
       as select a.*, b.rdate, b.held_pct, b.ncusip
       from aud_1_0 a left join aud_0_6_2 b
       on a.Tic = b.Ticker and a.cusip8 = b.c_cusip and a.Y_Beg >= b.rdate and a.Y_Beg -  365 <= b.rdate ;
quit; 

proc sort data=aud_1_1 nodupkey out=aud_1_2;
WHERE not missing(held_pct);
by cusip8 DATADATE rdate;
run;

data aud_1_3;
set aud_1_2;
by cusip8 DATADATE rdate;
INSTIT_PCT = held_pct*100;
if last.datadate;
run;

*to add;
proc sql;
       create table aud_1_4
       as select a.*, b.INSTIT_PCT , b.rdate
       from aud_0_5 a left join aud_1_3 b
       on not missing(a.cusip) and a.cusip = b.cusip and a.datadate = b.datadate;
quit; 

proc sort data=aud_1_4 nodupkey;
by gvkey fyear;
run;

*to fill out SICH code;
signoff;
%let wrds = wrds.wharton.upenn.edu 4016;
  options comamid=TCP remote=WRDS;
  signon username=_prompt_;

rsubmit;
options source nocenter ls=72 ps=max;
title 'Compustat North America data extract';
libname comp '/wrds/comp/sasdata/naa';

proc sql; create table a1
as select a.gvkey, a.cusip, a.sich, a.fyear, a.datadate 
from comp.funda as a
where a.indfmt='INDL' and a.datafmt='STD' and a.popsrc='D' and a.consol='C';
run;

proc sort data=a1;   by gvkey datadate;
run;

proc download data=a1 out=sich;
run;
endrsubmit; 

proc sort data=sich nodupkey;
by gvkey datadate;
run;

data sich_1;
set sich;
by gvkey;  
retain last_valid_sich;  ** Do not automatically reset to missing **;  
last_valid_sich=coalesce(lag(sich),last_valid_sich);  
if first.gvkey then last_valid_sich=.;  
sich_revised=coalesce(sich,last_valid_sich);  
drop last_valid_sich;
run;

proc sort data=sich_1 out=sich_2 nodupkey;
where not missing(gvkey);
by gvkey datadate;
run;

proc sql;
       create table aud_1_4_1
       as select a.*, b.sich_revised
       from aud_1_4 a left join sich_2 b
       on a.gvkey = b.gvkey and a.fyear = b.fyear;
quit; 

*to fill out the missing SIC code by using CRSP and SIC header from Compustat;
*To obtain Compustat Name data (most recent SIC);
signoff;
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
  options comamid=TCP remote=WRDS;
  signon username=_prompt_;

rsubmit;
options source nocenter ls=72 ps=max;
title 'Compustat North America data extract';
libname comp '/wrds/comp/sasdata/naa';

proc download data=comp.names out=names;
run;
endrsubmit;

*To obtain CRSP SIC code;
rsubmit;
libname crsp '/wrds/crsp/sasdata/a_stock';

proc download data=crsp.stocknames out=stocknames;
run;
endrsubmit;

proc sort data=aud_1_4_1 out=tmpa_0_1 (keep=gvkey fyear datadate sich sich_revised lpermno) nodupkey;
by gvkey datadate;
run;

*to add CRSP SIC code;
proc sql;
       create table tmpa_0_2
       as select a.*,b.SICCD
       from tmpa_0_1 a  left join stocknames b
       on a.lPERMNO = b.PERMNO and a.datadate >= b.NAMEDT and a.datadate <= b.NAMEENDDT; 
quit; 

proc sql;
       create table tmpa_0_3
       as select a.*,b.SIC as SIC_Header
       from tmpa_0_2 a  left join names b
       on a.gvkey = b.gvkey and year(a.datadate) >= b.year1 and year(a.datadate) <= b.year2; 
quit; 

data tmpa_0_4;
set tmpa_0_3;
if not missing(SICH) then do;
SIC = SICH;
R_SIC = 1;
end;

if missing(sich) and not missing(sich_revised) then do;
SIC = sich_revised;
R_SIC = 2;
end;

if missing(sich) and missing(sich_revised) and not missing(SICCD) then do;
SIC = SICCD;
R_SIC = 3;
end;

if missing(sich) and missing(sich_revised) and missing(SICCD) and not missing(SIC_Header) then do;
SIC = SIC_Header;
R_SIC = 4;
end;
run;

proc freq data=tmpa_0_4;
where year(datadate) > 1993;
table R_SIC;
run;

proc sort data=tmpa_0_4 nodupkey;
by gvkey datadate;
run;

data aud_1_4_2;
set aud_1_4_1;
run;

proc sql;
       create table aud_1_5
       as select a.*,b.SICCD, b.SIC_Header, b.SIC as SIC_f, b.R_SIC
       from aud_1_4_2 a  left join tmpa_0_4 b
       on a.gvkey = b.gvkey and a.datadate = b.datadate; 
quit; 

proc sort data=aud_1_5 out=aud_1_6 nodupkey;
by gvkey fyear;
run;

*(A-4) To add IBES data : the number of analysts and forecast dispersion;
proc sort data=aud_1_6 out=ibes_0_0(keep=gvkey datadate fyear tic cusip cik permno) nodupkey;
where not missing(permno);
by gvkey datadate;
run;

*to add IBES_Ticker;
data ibes_0_1;
set raw.Cibeslnk_xpf_2015_01;
if ldate =.E then ldate ='31DEC2015'd ;
run;

*to add the IBES ticker;
proc sql;
       create table ibes_0_2
       as select a.*,b.TICKER as IBES_Ticker
       from ibes_0_0 a left join ibes_0_1 b
       on a.gvkey= b.gvkey and b.fdate <= a.datadate <=b.ldate;
quit; 

proc sort data=ibes_0_2 out=ibes_0_3 nodupkey;
where not missing(ibes_ticker);
by gvkey datadate;
run;

data ibes_0_4;
set ibes_0_3;
IBES_date = intnx('month',datadate, 0,'end'); 
format datadate YYMMDD10. IBES_date YYMMDD10.;
run;

signoff;

%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP;
signon wrds username=_prompt_;

rsubmit;
libname IBES '/wrds/ibes/sasdata';
proc upload data= ibes_0_4 out = ibes_0_4; run;

proc sql; 
       create table ibes_0_5 
       as select a.*, b.*
       from ibes_0_4 a left join ibes.STATSUMU_EPSUS b  
       on a.IBES_Ticker = b.TICKER and a.datadate = b.FPEDATS and b.STATPERS <= a.IBES_date  and b.STATPERS >= a.IBES_date - 90 and 
             b.FPI = '1' and b.MEASURE ='EPS';
quit; 

proc sort data=ibes_0_5 out=ibes_0_6 nodupkey;
by gvkey datadate descending STATPERS;
run;

proc download data=ibes_0_6 out=ibes_0_6; run;
endrsubmit;

*right before the fiscal year end;
data ibes_0_7;
set ibes_0_6;
where not missing(NUMEST);
by gvkey datadate descending STATPERS;
if first.datadate = 1;
NUM_ANAL = NUMEST;
FOR_STD = STDEV;
FOR_MEAN = MEANEST;
DISPERSION = FOR_STD / abs(FOR_MEAN);
format IBES_date yymmdd10. STATPERS yymmdd10.;
run;

*to add IBES data;
proc sql;
       create table aud_1_7
       as select a.*,b.NUM_ANAL, b.FOR_MEAN, b.FOR_STD, b.DISPERSION
       from aud_1_6 a left join ibes_0_7 b
       on a.GVKEY = b.GVKEY and a.fyear = b.fyear + 1;
quit; 

*to calculate the lagged at and lagged mtb;
proc sort data=aud_1_7 nodupkey; by gvkey datadate;run;

data aud_1_8;
set aud_1_7;
if CEQ > 0 then MTB = MVE / CEQ; 
if missing(XRD) then XRD = 0;
RD = XRD / AT;
drop roa;
run;

data aud_1_9;
set aud_1_8;
ROA = IB / AT;
lag_AT = lag1(AT);
lag_MTB = lag1(MTB);

lag_gvkey = lag1(gvkey);
lag_fyear = lag1(fyear);

if gvkey ne lag_gvkey or fyear ne lag_fyear + 1 then do;
lag_AT = .;
lag_MTB = .;
end;

Leverage = DA;
big4 = big5;
drop lag_gvkey lag_fyear;

*High litigation risk industry;
if r_sic < 4 then do;
if sic_f >= 2833 and sic_f <= 2936 then LIT=1;
else if sic_f >= 3570 and sic_f <= 3577 then LIT=1;
else if sic_f >= 7370 and sic_f <= 7374 then LIT=1;
else if sic_f >= 3600 and sic_f <= 3674 then LIT=1;
else if sic_f >= 5200 and sic_f <= 5961 then LIT=1;
else if sic_f >= 8731 and sic_f <= 8734 then LIT=1;
else LIT=0;
end;

if missing(lit) then lit = 0;
run;

/*
data cds.aud_1_9_ver_2015_11;
set aud_1_9;
run;
* this has compustat data & return & Ibes data (up to 2014);
*/

data aud_1_9;
set cds.aud_1_9_ver_2015_11;
run;

*(A-5) to add SEO Equity Issuance data from SDC data to the dataset of other variables;
data seo_0_0;
set seo.raw_ver_2013_08;
if not missing(filing_date) and not missing(issue_date) and not missing(cusip_6);
keep SDC_ID filing_date issue_date Deal_Number Ticker_Symbol cusip_6 cusip_9 cusip_8;
run;

data seo_0_1;
set cds.Sdc_equity_issue90to15sep;
if not missing(filing_date) and not missing(issue_date) and not missing(cusip6);
keep SDC_ID filing_date issue_date Deal_Number Ticker_Symbol cusip6 cusip9;
run;

data seo_0_1_a;
set seo_0_0 seo_0_1;
run;

proc sort data=seo_0_1_a out=seo_0_1_b nodupkey;
by SDC_ID filing_date issue_date Deal_Number;
run;

*to obtain permno by using ncusip;
proc sort data=raw.stocknames_ver_2015_11 out=seo_0_2 nodupkey;
where not missing(NCUSIP);
by permno NAMEDT NAMEENDDT NCUSIP TICKER;
run;

proc sql;
       create table seo_0_3
       as select a.*, b.PERMNO
       from seo_0_1_b a left join seo_0_2 b 
       on (a.Ticker_Symbol = b.TICKER)and a.Issue_Date >= b.NAMEDT and a.Issue_Date <= b.NAMEENDDT;
quit; 

proc sort data=seo_0_3 out=seo_0_4 nodupkey;
by SDC_ID filing_date issue_date Deal_Number;
run;

data seo_0_5;
set seo_0_4;
where not missing(permno);
ISS = 1;
run;

*to identify the firm-year with equity issuance;
proc sort data=cds.aud_1_9_ver_2015_11 out=seo_1_0 (keep=gvkey permno datadate fyear) nodupkey;
where not missing(permno);
by permno datadate;
run;

data seo_1_1;
set seo_1_0;
Ret_Beg = intnx('month',datadate, -11,'beginning'); format Ret_Beg YYMMDD10.;
Ret_End = intnx('day',datadate, 0,'end'); format Ret_End YYMMDD10.;
run;

proc sql;
       create table seo_1_2
       as select a.*, b.ISS
       from seo_1_1 a left join seo_0_5 b 
       on a.permno = b.permno and b.Issue_Date >= a.Ret_Beg and b.Issue_Date <= a.Ret_End;
quit; 

data seo_1_2;
set seo_1_2;
if missing(ISS) then ISS = 0;
run;

proc sort data=seo_1_2; by gvkey fyear;
run;

proc means data=seo_1_2 noprint;
by gvkey fyear;
var ISS;
output out=seo_1_3
sum = s_ISS;
run;

data seo_1_4;
set seo_1_3;
if s_iss > 0 then EQ_ISS = 1; else EQ_ISS = 0;
run;

*to add SEO data;
proc sql;
       create table aud_2_0
       as select a.*, b.EQ_ISS
       from cds.aud_1_9_ver_2015_11 a left join seo_1_4 b
       on a.gvkey = b.gvkey and a.fyear = b.fyear;
quit; 

data aud_2_1;
set aud_2_0;
if missing(EQ_ISS) then EQ_ISS = 0;
run;

proc sort data=aud_2_1 nodupkey;
by gvkey datadate;
run;

*(A-6) To measure the comprehensive set of control variables;
data tmp_0_1;
set aud_2_1;
if fyear > 1995;
cusip8 = substr(cusip, 1, 8);

RET = Com_Ret - Com_MkRet;
if RET < 0 then Neg_RET = 1; else Neg_RET = 0;

if N_Ret < 245 then do;
Com_Ret = .;
RET_STD = .;
Com_MkRet = .;
RET = .;
Neg_RET = .;
end;
run;


*Part B: to obtain CDS data: 
(to calculate the trading of CDS and liquidity: from new CDS data with MR and XR clause);
*(B-1) data clearning;
data tmp_0_2_0;
set cds.cds01_14;
format date yymmdd10.;
if ccy = 'USD';
if DocClause = 'XR' or DocClause = 'MR';
run;

/* data check;
proc sort data=tmp_0_2_0 out=check (keep=date) nodupkey;
by date;
run;
*period: from 2001-01-02 to 2014-12-31;
*/

data tmp_0_2_1;
set tmp_0_2_0;
if not missing(gvkey);
run;
* 6,783,135 --> 5,935,548;

data tmp_0_2_2;
set tmp_0_2_1;
if missing(Spread6m) and missing(Spread1y) and missing(Spread2y) and missing(Spread3y) and missing(Spread4y) and missing(Spread5y) and missing(Spread7y) and 
   missing(Spread10y) and missing(Spread15y) and missing(Spread20y) and missing(Spread30y) then delete;

if not missing(Spread6m) then term_0 = 1; else term_0 = 0;
if not missing(Spread1y) then term_1 = 1; else term_1 = 0;
if not missing(Spread2y) then term_2 = 1; else term_2 = 0;
if not missing(Spread3y) then term_3 = 1; else term_3 = 0;
if not missing(Spread4y) then term_4 = 1; else term_4 = 0;
if not missing(Spread5y) then term_5 = 1; else term_5 = 0;
if not missing(Spread7y) then term_6 = 1; else term_6 = 0;
if not missing(Spread10y) then term_7 = 1; else term_7 = 0;
if not missing(Spread15y) then term_8 = 1; else term_8 = 0;
if not missing(Spread20y) then term_9 = 1; else term_9 = 0;
if not missing(Spread30y) then term_10 = 1; else term_10 = 0;

Term_Count = term_0 + term_1 + term_2 + term_3 + term_4 + term_5 + term_6 + term_7 + term_8 + term_9 + term_10;
run;
* 5,935,548  -->5,531,579  ;

proc sort data=tmp_0_2_2 out=tmp_0_2_3;
by gvkey date DocClause Tier;
run;

proc means data=tmp_0_2_3 noprint;
by gvkey date DocClause;
var CompositeDepth5y Term_Count;
output out=tmp_0_3
mean = d_avg_CompositeDepth5y d_avg_Term_Count 
median = d_med_CompositeDepth5y d_med_Term_Count
max = d_max_CompositeDepth5y d_max_Term_Count
n = n_obs_1 n_obs_2;
run;
 
*to identify the first trading day;
proc sort data=tmp_0_3 out=tmp_0_3_3 nodupkey;
by gvkey date;
run;

*to create a dummy for CDS_traded;
proc sort data=tmp_0_3_3 out=tmp_0_4 (keep=gvkey) nodupkey;
by gvkey;
run;
*# of firms = 1,336;

data tmp_0_4;
set tmp_0_4;
CDS_Traded = 1;
run;
*for these firms, if I can't find first_cds_trade date, I should delete these firms from the non-CDS firms;

*(B-2) to identify the first trading day;
proc sort data=tmp_0_3_3 out=tmp_0_5 (keep=gvkey spread5y date term_count) nodupkey;
by gvkey date;
run;

data tmp_0_6;
set tmp_0_5;
by gvkey date;
if first.gvkey=1;
CDS_First_Date = date;
format CDS_First_Date yymmdd10.;
keep gvkey CDS_First_Date;
run;

*data check;
proc sort data=tmp_0_6 out=check (keep=CDS_First_Date) nodupkey;
by CDS_First_Date;
run;
*period: from 2001-01-02 to 2014-08-22;

*to include firm-years from compustat to tmp_0_4;
proc sql;
       create table tmp_0_7
       as select a.*, b.datadate, b.fyear
       from tmp_0_4 a left join tmp_0_1 b
       on a.gvkey  = input(b.gvkey, comma8.) ;
quit; 

proc sort data=tmp_0_7 nodupkey;
by gvkey datadate;
run;

data tmp_0_7_1;
set tmp_0_7;
FYE_Beg = intnx('month',datadate, -11,'beginning'); format FYE_Beg YYMMDD10.;
FYE_End = intnx('day',datadate, 0,'end'); format FYE_End YYMMDD10.;
run;

data tmp_0_8;
set tmp_0_7_1;
if not missing(datadate);
run;

*(B-3) to include all of the CDS trade data over a fiscal year;
proc sql;
       create table tmp_0_9
       as select a.*, b.date, b.DocClause, b.d_avg_CompositeDepth5y, b.d_med_CompositeDepth5y, b.d_max_CompositeDepth5y,  b.n_obs_1,
	                   b.n_obs_2, b.d_avg_Term_Count, b.d_med_Term_Count, b.d_max_Term_Count 
       from tmp_0_8 a left join tmp_0_3 b
       on a.gvkey  = b.gvkey and a.FYE_Beg <= b.date and a.FYE_End >= b.date;
quit;

*(B-4) CDS liquidity over a fiscal year using the max number on a particular date;
proc sort data=tmp_0_9 out=tmp_1_0 nodupkey;
by gvkey fyear date DocClause  ;
run;

proc means data=tmp_1_0 noprint;
by gvkey fyear date;
var d_max_Term_Count d_max_CompositeDepth5y;
output out= tmp_1_1
max = d_max_Term_Count d_max_CompositeDepth5y;
run;

data tmp_1_1_1;
set tmp_1_1;
if missing(d_max_Term_Count) and missing(d_max_CompositeDepth5y) then delete;
run;

proc means data=tmp_1_1_1 noprint;
by gvkey fyear;
var d_max_Term_Count d_max_CompositeDepth5y;
output out= tmp_1_1_2
mean = mean_term_count mean_CompositeDepth5y 
n = freq_term_count freq_CompositeDepth5y;
run;

data tmp_1_1_3;
set tmp_1_1_2;
if freq_term_count = 0 and freq_CompositeDepth5y = 0 then delete;
run;
*# of firm-years: 10,268;

proc sort data=tmp_1_1_3 out=check(keep=gvkey) nodupkey;
by gvkey;
run;
*# of firms = 1,218;

data tmp_1_2;
set tmp_1_1_3;
if missing(mean_term_count) then mean_term_count=0;
if missing(mean_CompositeDepth5y) then mean_CompositeDepth5y=0;
drop _TYPE_ _FREQ_;
run;

*(B-5) to combine CDS data as the firm-year level;
proc sql;
       create table tmp_1_3
       as select a.*, b.CDS_First_Date
       from tmp_0_8 a left join tmp_0_6 b
       on a.gvkey  = b.gvkey;
quit; 

proc sql;
       create table tmp_1_4
       as select a.*, b.*
       from tmp_1_3 a left join tmp_1_2 b
       on a.gvkey  = b.gvkey and a.fyear = b.fyear;
quit; 

proc sort data=tmp_1_4 nodupkey;
by gvkey fyear;
run;

data tmp_1_5;
set tmp_1_4;
if not missing(FYE_End);
if not missing(FYE_End) and not missing(CDS_First_Date) and FYE_End >= CDS_First_Date then CDS = 1;
if not missing(FYE_End) and not missing(CDS_First_Date) and FYE_End < CDS_First_Date then CDS = 0;
if not missing(CDS_First_Date) and FYE_End >= CDS_First_Date and FYE_Beg =< CDS_First_Date then First_CDS_Year = fyear;
run;

/*
data cds.tmp_1_5_ver_2016_11_23;
set tmp_1_5;
run;
*/

*(b-6) to combine this CDS data to the data of control variables;
proc sql;
       create table tmp_1_6_1
       as select a.*, b.CDS_Traded
       from tmp_0_1 a left join tmp_0_4 b
       on b.gvkey  = input(a.gvkey, comma8.);
quit; 

proc sql;
       create table tmp_1_6_2
       as select a.*, b.CDS_First_Date
       from tmp_1_6_1 a left join tmp_0_6 b
       on b.gvkey  =  input(a.gvkey, comma8.);
quit; 

*CDS data is from the previous year;
proc sql;
       create table tmp_1_6_3
       as select a.*, b.CDS, b.fyear as CDS_year, b.datadate as CDS_datadate, b.First_CDS_Year,
                      b.mean_term_count, b.mean_CompositeDepth5y, b.freq_term_count, b.freq_CompositeDepth5y
       from tmp_1_6_2 a left join tmp_1_5 b
       on b.gvkey  =  input(a.gvkey, comma8.) and a.fyear = b.fyear + 1;
quit; 

data tmp_1_7;
set tmp_1_6_3;
if missing(CDS_Traded) then CDS_Traded = 0;

if missing(CDS) then do;
if not missing(datadate) and not missing(CDS_First_Date) and intnx('month',datadate, -11,'beginning') >= CDS_First_Date then CDS = 1;
if not missing(datadate) and not missing(CDS_First_Date) and intnx('month',datadate, -11,'beginning') < CDS_First_Date then CDS = 0;
end;

if missing(CDS) then CDS = 0;
if missing(mean_term_count) then mean_term_count=0;  if missing(freq_term_count) then freq_term_count=0;
if missing(mean_CompositeDepth5y) then mean_CompositeDepth5y=0;  if missing(freq_CompositeDepth5y) then freq_CompositeDepth5y=0;
run;

proc sort data=tmp_1_7 nodupkey;
by gvkey fyear;
run;

/*
data cds.tmp_1_7_ver_2015_11_21;
set tmp_1_7;
run;
*/

data tmp_1_7;
set cds.tmp_1_7_ver_2015_11_21;
run;

*Part C: to obtain managment forecast data;

*(C-1) up to 2010 from first call;;
*first, to get firms that exist fc.actual and analyst;
proc sort data=fc.actuals out=tmp_1_8_1 (keep=CUSIP) nodupkey;
where not missing(CUSIP) and year(FPE) > 1996;
by cusip;
run;

proc sort data=fc.sum out=tmp_1_8_2 (keep=CUSIP) nodupkey;
where not missing(CUSIP) and year(FPE) > 1996;
by cusip;
run;

data tmp_1_8_3;
merge tmp_1_8_1 (in=a) tmp_1_8_2 (in=b);
by cusip;
if a= 1 and b=1;
FC =1 ;
run;

proc sql; create table tmp_1_8_5
as select a.*, b.FC 
from tmp_1_7 as a
left join tmp_1_8_3 as b
on not missing(a.cusip) and a.cusip8=b.cusip;
run; quit;

data tmp_1_8_6;
set tmp_1_8_5;
if missing(FC) then FC = 0;
if fyear < 2011;
run;

proc sql; create table tmp_1_8_7
as select a.*, b.D_MF1, b.Num_MF1
from tmp_1_8_6 as a
left join pay1.rogers_mgmt_forecast as b
on not missing(a.cusip) and a.cusip8=b.cusip and a.fyear = b.fyear;
run; quit;

data tmp_1_8_8;
set tmp_1_8_7;

if missing(D_MF1) then D_MF1 = 0;
if missing(Num_MF1) then Num_MF1 = 0;
run;

*(C-2) from 2011 to to 2014 from IBES;
data tmp_1_8_9_0;
set tmp_1_7;
if fyear >= 2011 and fyear <= 2014;
run;

*to add IBES_Ticker;
data ibes_0_1;
set raw.Cibeslnk_xpf_2015_01;
if ldate =.E then ldate ='31DEC2015'd ;
run;

*to add the IBES ticker;
proc sql;
       create table tmp_1_8_9_1
       as select a.*,b.TICKER as IBES_Ticker
       from tmp_1_8_9_0 a left join ibes_0_1 b
       on a.gvkey= b.gvkey and b.fdate <= a.datadate <=b.ldate;
quit; 

proc sql; create table tmp_1_8_9_2
as select a.*, b.D_MF1, b.Num_MF1
from tmp_1_8_9_1 as a
left join ibes.rogers_forecast_issuance_v_15_11 as b
on not missing(a.IBES_Ticker) and a.IBES_Ticker=b.ticker and a.fyear = b.fyear;
run; quit;

data tmp_1_8_9_3;
set tmp_1_8_9_2;
if missing(D_MF1) then D_MF1 = 0;
if missing(Num_MF1) then Num_MF1 = 0;
run;

data tmp_1_8_9_4;
set tmp_1_8_8 tmp_1_8_9_3;
run;

proc sort data=tmp_1_8_9_4 out=tmp_1_9 nodupkey;
by gvkey fyear;
run;

*Part D: To measure the main variables + addiitional variables for cross-sectional tests;
data tmp_2_0;
set tmp_1_9;
RVOL = RET_STD*100; *to make the coefficient comparable to others;
Following =NUM_ANAL; 
Log_Following = log(1+Following);
log_AT = log(lag_AT);

INST_OWN = INSTIT_PCT;

if missing(INST_OWN) then INST_OWN = 0;
if INST_OWN > 100 then INST_OWN = 100;
if missing(lag_AT) or missing(lag_MTB) or missing(ROA) or missing(Big4) or missing(RET) or missing(RET_STD) or missing(EQ_ISS) or
   missing(NUM_ANAL) or missing(DISPERSION) then delete;
run;

proc sort data=tmp_2_0 out=tmp_2_0_1 nodupkey;
by fyear gvkey ;
run;
*# of firm-years = 58,232;

data tmp_2_0_2;
set tmp_2_0_1;
if fyear > 1996 and fyear < 2015;

log_num_mf1 = log(1+num_mf1);
w=1;
run;
*# of firm-years = 54,883;


*(D-1) Data Clearning - 1: delete CDS initiation in 2000;
proc sort data=tmp_1_5 out=tmp_2_1_0_1(keep=gvkey fyear cds_traded CDS_First_Date CDS First_CDS_Year) nodupkey;
where cds_traded = 1; 
by gvkey fyear;
run;

data tmp_2_1_0_2;
set tmp_2_1_0_1;
if not missing(First_CDS_Year);
if First_CDS_Year = 2000;
exclusion_1 = 1;
run;
*these fims should be deleted = 20;

*to check the firm-years from these firms;
proc sql; create table sample_check_1
as select a.*, b.fyear as ffyear
from tmp_2_1_0_2 as a
left join tmp_2_0_2 as b
on a.gvkey = input(b.gvkey,comma8.);
run; quit;
*# of firm-years = 281;

proc sort data=sample_check_1 out=sample_check_2 nodupkey;
where not missing(ffyear);
by gvkey ffyear;
run;
*# of firm-years = 280;

proc sort data=sample_check_2 out=sample_check_3 nodupkey;
by gvkey;
run;
*these fims should be deleted = 19;

*(D-2) to check the CDS distribution for firms with CDS_Traded = 1 to delete such cases # of years with CDS=1 = 0 and # of years with CDS=0 = 0;
*CDS distribution of # of years available;
proc sort data=tmp_2_0_2 out=tmp_2_1_1_1 (keep=gvkey fyear cds_traded cds w) nodupkey;
where cds_traded = 1;
by gvkey fyear;
run;

proc sort data=tmp_2_1_1_1 out=tmp_2_1_1_2 (keep=gvkey) nodupkey;
by gvkey;
run;
*the number of firms = 1,093;

proc sort data=tmp_2_1_1_1 out=tmp_2_1_1_3;
by gvkey cds  fyear;
run;
* # of firm-years = 13,399;

proc freq data=tmp_2_1_1_3 noprint; 
by gvkey cds;
table w / out=tmp_2_1_1_4;
run; 

data tmp_2_1_1_5;
set tmp_2_1_1_4;
where cds = 0;
num_noncds_years = COUNT;
keep gvkey num_noncds_years;
run;

data tmp_2_1_1_6;
set tmp_2_1_1_4;
where cds = 1;
num_cds_years = COUNT;
keep gvkey num_cds_years;
run;

data tmp_2_1_1_7;
merge tmp_2_1_1_5 tmp_2_1_1_6;
by gvkey;
if missing(num_noncds_years) then num_noncds_years = 0;
if missing(num_cds_years) then num_cds_years = 0;
num_total_years = num_noncds_years + num_cds_years;
Percent_cds_years = (num_cds_years / num_total_years)*100;

gvkey_n = input(gvkey, comma8.);
if num_cds_years = 0 then exclusion_2 = 1; else exclusion_2 = 0;
if num_noncds_years = 0 then exclusion_3 = 1; else exclusion_3 = 0;

if num_cds_years = 0 or num_noncds_years = 0 then exclusion_4 = 1; else exclusion_4 = 0;
run;

data tmp_2_1_1_8;
set tmp_2_1_1_7;
drop gvkey;
run;

data tmp_2_1_1_8;
set tmp_2_1_1_8;
rename gvkey_n = gvkey;
run;

data tmp_2_1_3;
merge tmp_2_1_0_2(keep=gvkey exclusion_1 ) tmp_2_1_1_8;
if missing(exclusion_1) then exclusion_1=0;
by gvkey;
run;

*to add this dummy to the dataset;
proc sql;
       create table tmp_2_1_4
       as select a.*,  b.exclusion_1, b.exclusion_2, b.exclusion_3, b.exclusion_4, b.num_total_years
       from tmp_2_0_2 a left join tmp_2_1_3 b
       on b.gvkey  =  input(a.gvkey, comma8.);
quit; 

proc sort data=tmp_2_1_4 out=tmp_2_1_4_2 nodupkey;
by gvkey fyear;
run;

data tmp_2_2;
set tmp_2_1_4_2;
if exclusion_4 = 1 then delete;
if num_total_years = 1 then delete;
run;
* 54,883 --> 53,636 (when exclusion 2 and 3 are imposed);

data check;
set tmp_2_1_4_2;
if exclusion_4 = 1 or num_total_years = 1;
run;
*1,247;

proc sort data=check out=check_2 nodupkey;
by gvkey;
run;
*237;

proc sort data=tmp_2_2 out=check(keep=gvkey) nodupkey;
by gvkey;
run;
*# of firms = 8,122;


*(D-3) to identify CDS firms whose first cds trading date in January 2001;
*(a) adjustment for the first year of CDS trading;
proc sort data=tmp_2_2 out=check (keep=gvkey fyear cds first_cds_year cds_traded) nodupkey;
where cds_traded=1;
by gvkey fyear;
run;

proc sort data=check out=check_1 nodupkey;
where not missing(first_cds_year);
by gvkey;
run;

proc sort data=tmp_2_2 out=check_2 (keep=gvkey cds_traded cds_first_date) nodupkey;
where cds_traded=1;
by gvkey;
run;

data check_3;
merge check_1 check_2 ;
by gvkey;
run;

proc sort data=check_3 nodupkey;
by gvkey;
run;

data check_4;
set check_3;
if missing(first_cds_year);
keep gvkey cds_first_date;
format cds_first_date yymmdd10.;
run;

*(b) to find the first year of trading;
proc sql;
       create table check_4_1
       as select a.*, b.datadate, b.fyear
       from check_4 a left join tmp_0_1 b
       on a.gvkey  = b.gvkey  and abs(year(a.cds_first_date) - year(b.datadate)) <6;
quit; 

proc sort data=check_4_1 out=check_4_2 nodupkey;
by gvkey fyear;
run;

data check_4_3;
set check_4_2;
FYE_Beg = intnx('month',datadate, -11,'beginning'); format FYE_Beg YYMMDD10.;
FYE_End = intnx('day',datadate, 0,'end'); format FYE_End YYMMDD10.;

if cds_first_date <= datadate and FYE_Beg <= cds_first_date then first_cds_year = fyear;

if not missing(first_cds_year);
run;

proc sql;
       create table check_4_4
       as select a.*, b.first_cds_year
       from check_4 a left join check_4_3 b
       on a.gvkey  = b.gvkey;
quit; 

data check_4_5;
set check_3;
if not missing(first_cds_year);
keep gvkey cds_first_date first_cds_year;
format cds_first_date yymmdd10.;
run;

data check_5;
set check_4_4 check_4_5;
run;

proc sort data=check_5 nodupkey;
by gvkey;
run;

proc sql;
       create table tmp_2_2_1
       as select a.*, b.first_cds_year as co_first_cds_year
       from tmp_2_2 a left join check_5 b
       on a.gvkey  = b.gvkey;
quit; 

data tmp_2_2_2;
set tmp_2_2_1;
if cds_traded=1 then do;
if missing(first_cds_year) then first_cds_year = co_first_cds_year;
end;
drop co_first_cds_year;
run;

*(c) to add the first date of cds trading;
proc sort data=tmp_2_2_2 out=tmp_2_2_3 (keep=gvkey cds cds_traded first_cds_year cds_first_date fyear) nodupkey;
where not missing(first_cds_year);
by gvkey;
run;

proc sql;
       create table tmp_2_2_4
       as select a.*, b.cds_first_date as ori_cds_first_date
       from tmp_2_2_2 a left join tmp_2_2_3 b
       on a.gvkey  =  b.gvkey and a.cds_traded=1;
quit; 

data tmp_2_2_5;
set tmp_2_2_4;
if not missing(ori_cds_first_date) and ori_cds_first_date <= '31JAN2001'd then pre_2001 = 1; else pre_2001 = 0;
run;

proc sort data=tmp_2_2_5 out=tmp_2_3 nodupkey;
by gvkey fyear;
run;


*(D-4) to add additional control variables: lag_leverage and Mid-Zscore;
*(a) to add the lag_leverage;
proc sql;
       create table tmp_2_3_1
       as select a.*, b.leverage as lag_leverage
       from tmp_2_3 a left join tmp_1_7 b
       on a.gvkey  =  b.gvkey and a.fyear -1 = b.fyear;
quit; 

*(b)to add mid-zcore;
*(b-1) to obtain data for Z-Score;
signoff;
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
  options comamid=TCP remote=WRDS;
  signon username=_prompt_;

rsubmit;

options source nocenter ls=72 ps=max;
title 'Compustat North America data extract';
libname comp '/wrds/comp/sasdata/naa';

proc sql; create table a1
as select a.*
from comp.funda as a
where a.datadate >= '01JAN1994'd and 
      a.indfmt='INDL' and a.datafmt='STD' and a.popsrc='D' and a.consol='C';
run;

proc sort data=a1;   by gvkey datadate;
run;

rsubmit;
data a2;
set a1;
where consol = "C"
    and popsrc = "D"
    and datafmt = "STD"
    and indfmt = "INDL";

	*if AT>0;
	if year(datadate)>=1994;
	if fyear^=.;
	format datadate yymmdd10. ;

z_score = 1.2*(act-lct)/at + 1.4*(re/at) + 3.3*(ni+xint+txt)/at + 0.6*(csho*PRCC_F)/lt + 0.999*(sale/at);
keep gvkey fyear datadate
     act act lct at re ni xint txt  csho prcc_f lt sale z_score
      ;
run;

proc download data=a2 out=cds.z_score_ver_2016_01_02; run;
endrsubmit; 

*to include z-score;
proc sort data=cds.z_score_ver_2016_01_02 out=tmp_2_3_2 nodupkey;
by gvkey fyear;
run;

data tmp_2_3_2_1;
set tmp_2_3_2;
*Altman's Z-score;
if missing(act) then act=0;
if missing(lct) then lct = 0;
if missing(re) then re =0;
if missing(OIBDP) then OIBDP = 0;
if missing(DP) then DP =0;

Z_score = 1.2*((ACT-LCT)/AT) + 1.4*(RE/AT) +  3.3*((OIBDP - DP)/AT)
         + 0.6*(PRCC_F * CSHO / LT) +  0.999*(SALE/AT);
keep gvkey fyear z_score;
run;

proc sql;
       create table tmp_2_3_2_2
       as select a.*, b.z_score
       from tmp_2_3_1 a left join tmp_2_3_2_1 b
      on a.gvkey  = b.gvkey and a.fyear -1 = b.fyear;
quit; 

proc sort data=tmp_2_3_2_2 out=tmp_2_3_2_3 nodupkey;
by fyear gvkey ;
run;

data tmp_2_3_2_4;
set tmp_2_3_2_3;
z_score_a = z_score;
if missing(z_score_a) then z_score_a = 0;
run;

proc rank data=tmp_2_3_2_4 out=tmp_2_3_2_5
groups = 5;
by fyear;
var z_score_a;
ranks r5_z_score_a;
run; 

data tmp_2_3_3;
set tmp_2_3_2_5;
if r5_z_score_a = 2 then mid_zscore = 1; else mid_zscore = 0;
run;

proc sort data=tmp_2_3_3 out=tmp_2_4 nodupkey;
by gvkey fyear ;
run;


*(D-5) Data winsorizition;
*Wins(raw_data, input_data, variable, p1, p99);
%Wins(tmp_2_4, tmp_2_4, Num_MF1, p1, p99);
%Wins(tmp_2_4, tmp_2_4, log_num_mf1, p1, p99);

%Wins(tmp_2_4, tmp_2_4, log_AT, p1, p99);
%Wins(tmp_2_4, tmp_2_4, lag_MTB, p1, p99);
%Wins(tmp_2_4, tmp_2_4, ROA, p1, p99);
%Wins(tmp_2_4, tmp_2_4, INST_OWN, p1, p99);
%Wins(tmp_2_4, tmp_2_4, Log_Following, p1, p99);
%Wins(tmp_2_4, tmp_2_4, Following, p1, p99);
%Wins(tmp_2_4, tmp_2_4, RVOL, p1, p99);
%Wins(tmp_2_4, tmp_2_4, DISPERSION, p1, p99);
%Wins(tmp_2_4, tmp_2_4, lag_leverage, p1, p99);
%Wins(tmp_2_4, tmp_2_4, lag_AT, p1, p99);


*(D-6) Post_FD variable;
data tmp_2_5;
set tmp_2_4;

gvkey_n = input(gvkey, comma8.);

if fyear > 2000 then post_fd = 1; else post_fd = 0;

if missing(lag_leverage) then do;
lag_leverage = 0; lag_leverage_w = 0;

end;
run;

*(D-7) Additional Cross-sectional variables: lead arrangers' share, financial covenant, credit derivative protection, board independence, blockholder ownership;
*(a) lead arrangers' share and financial covenants;
data tmp_2_5_1;
set tmp_2_5;

FYE_Beg = intnx('month',datadate, -11,'beginning'); 
FYE_End = datadate;

Last_FYE_Beg = intnx('month',FYE_Beg, -12,'beginning'); 
Last_FYE_End = intnx('month',FYE_End, -12,'ending'); 

keep gvkey_n gvkey fyear fye_beg fye_end last_fye_beg last_fye_end;
format FYE_Beg YYMMDD10. FYE_End YYMMDD10. Last_FYE_Beg YYMMDD10. Last_FYE_End YYMMDD10. ;
run;

*raw data of bank loan;
data tmp_2_5_2;
set cds.loans_data;
m1 = input(substr(FacilityStartDate, 1, 2), 2.);
d1 = input(substr(FacilityStartDate, 4, 2), 2.);
y1 = input(substr(FacilityStartDate, 7, 4), 4.);

m2 = input(substr(FacilityEndDate, 1, 2), 2.);
d2 = input(substr(FacilityEndDate, 4, 2), 2.);
y2 = input(substr(FacilityEndDate, 7, 4), 4.);

if missing(FacilityEndDate) then do;
m2 = 12; d2 = 31; y2 = 2020;
end;

Facility_Beg_Date = mdy(m1,d1, y1); format Facility_Beg_Date yymmdd10.;
Facility_End_Date = mdy(m2,d2, y2); format Facility_End_Date yymmdd10.;
drop m1 d1 y1 m2 d2 y2 inst_inv;
run;

proc sort data=tmp_2_5_2 out=tmp_2_5_3 nodupkey;
by gvkey lenderid Facility_Beg_Date Facility_End_Date Lender;
run;

proc sql;
       create table tmp_2_5_4
       as select a.*, b.*
       from tmp_2_5_1 a left join tmp_2_5_3 b
       on a.gvkey_n = b.gvkey and a.fye_beg >= b.Facility_Beg_Date  and a.fye_beg <= b.Facility_End_Date;
quit; 

proc sql;
       create table tmp_2_5_5
       as select a.*, b.*
       from tmp_2_5_1 a left join tmp_2_5_3 b
       on a.gvkey_n = b.gvkey and a.fye_end >= b.Facility_Beg_Date  and a.fye_end <= b.Facility_End_Date;
quit; 

data tmp_2_5_6;
set tmp_2_5_4 tmp_2_5_5;
run;

proc sort data=tmp_2_5_6 out=tmp_2_5_7 nodupkey;
where not missing(lenderid);
by gvkey fyear  lenderid Facility_Beg_Date Facility_End_Date Lender;
run;

*average of bank_allocation & average # of covenants;
proc means data=tmp_2_5_7 noprint;
by gvkey fyear;
var BankAllocation fincov_number;
output out=tmp_2_5_8
  n = n1 n2 n3
  mean = avg_bankallocation avg_fincov_number;
run;

*to add the new data to the main dataset;
proc sql;
       create table tmp_2_5_9
       as select a.*, b.avg_bankallocation, b.avg_fincov_number
       from tmp_2_5 a left join tmp_2_5_8 b
       on a.gvkey = b.gvkey and a.fyear = b.fyear;
quit; 

data tmp_2_6_0;
set tmp_2_5_9;
label avg_bankallocation = 'avg_bankallocation';

if missing(avg_bankallocation) then miss_avg_bankallocation = 1; else miss_avg_bankallocation = 0;
if missing(avg_fincov_number) then miss_avg_fincov_number = 1; else miss_avg_fincov_number = 0;

cik_n=input(cik, 11.);

run;

proc sort data=tmp_2_6_0 out=tmp_2_6_1 nodupkey;
by  gvkey fyear;
run;

*(b) credit derivative protection;
*raw bank data;
proc sort data=cds.bank_data_may25 out=tmp_2_6_2 nodupkey;
by gvkey yr lenderid;
run;

data tmp_2_6_3;
set tmp_2_6_2;
rel_cds_protect = cds_protect / bank_assets;
run;

*Aggregate at the firm-year level;
proc means data=tmp_2_6_3 noprint;
by gvkey yr;
var rel_cds_protect;
output out = tmp_2_6_4
mean = avg_rel_cds_protect;
run;

*to include cds_protect from the last year (i.e., CDS year);
proc sql;
       create table tmp_2_6_5
       as select a.*, b.avg_rel_cds_protect
       from tmp_2_6_1 a left join tmp_2_6_4 b
       on a.gvkey_n  = b.gvkey and a.fyear - 1 = b.yr;
quit; 

proc sort data=tmp_2_6_5 out=tmp_2_7 nodupkey;
by gvkey fyear;
run;

*(c) to add board independence and blockholding from coproate library database;
proc sql;
       create table tmp_2_7_1
       as select a.*, b.BD_IND, b.BLOCKHOLDINGS
       from tmp_2_7 a  left join acq.tmp_c_4_1_ver_2016_12 b
       on a.cik_n = b.cik_n and a.fyear  = b.fis_year; 
quit; 

proc sort data=tmp_2_7_1 out=tmp_2_7_2 nodupkey;
by gvkey fyear  ;
run;

data tmp_2_7_2;
set tmp_2_7_2;
if not missing(BLOCKHOLDINGS) then do;
if BLOCKHOLDINGS >= 5 then D_BLOCK = 1; else D_BLOCK = 0;
end;

*since blcok holding data is not avaialble from corporate libry up to 2001, to obtain the data from WRDS - Blockholder (Legacy) data;
data blk_0;
set cds.Data_blockholding_ver_2017_03_27;
run;

proc sort data=blk_0 out=check (keep=IRRCYEAR) nodupkey;
by IRRCYEAR;
run;
*from 1996 to 2001;

proc sort data = blk_0 out= blk_1 nodupkey;
by TICKER IRRCYEAR  FIRM_ID;
run;

*to have a permno from CRSP data;
proc sql;
       create table blk_2
       as select a.*,b.PERMNO
       from blk_1 a  left join raw.Crsp_stocknames b
       on a.TICKER = b.ticker and   a.MTGDATE >= b.NAMEDT and a.MTGDATE <= b.NAMEENDDT; 
quit; 

data blk_3;
set blk_2;
BLOCKHOLDINGS_raw = SUMBLKS;
run;

proc sort data=blk_3 out=blk_4 nodupkey;
where not missing(permno);
by permno IRRCYEAR;
run;

proc sql;
       create table tmp_2_7_3
       as select a.*,b.BLOCKHOLDINGS_raw 
       from tmp_2_7_2 a  left join blk_4 b
       on a.permno = b.permno and a.fyear = b.IRRCYEAR; 
quit;

data tmp_2_7_4;
set tmp_2_7_3;

BLOCKHOLDINGS_f = BLOCKHOLDINGS;

if fyear < 2002 and missing(BLOCKHOLDINGS) then do;
BLOCKHOLDINGS_f = BLOCKHOLDINGS_raw;
if BLOCKHOLDINGS_raw >= 5 then D_BLOCK = 1; else D_BLOCK = 0;
end;

run;

proc sort data=tmp_2_7_4 out=tmp_2_8 nodupkey;
by fyear gvkey;
run;


*(D-8) to measure high variables for cross-sectional analyses;
*(a) variables used for the all firm-years;
proc rank data=tmp_2_8 out=tmp_2_8_1
groups = 2;
by fyear;
var avg_bankallocation avg_fincov_number lag_leverage inst_own_w;
    
ranks r2_bksh r2_fincov r2_lag_leverage r2_inst_own;
run; 

*to measure various interaction terms with CDS variable;
data tmp_2_8_2;
set tmp_2_8_1;

*bankallocation;
if miss_avg_bankallocation = 0 then do;
if r2_bksh = 1 then h2_bksh = 1; else h2_bksh = 0;
cds_h2_bksh = cds*h2_bksh;
end;

*fincov_number;
if miss_avg_fincov_number = 0 then do;
if r2_fincov = 1 then h2_fincov = 1; else h2_fincov = 0;
cds_h2_fincov = cds*h2_fincov;
end;

*distress risk;
if r2_lag_leverage = 1 then h2_lag_leverage = 1; else h2_lag_leverage = 0;
cds_h2_lag_leverage = cds*h2_lag_leverage;

*institutional ownership;
if D_BLOCK = 1 then Non_Blk = 0; else Non_Blk = 1;
if  r2_inst_own = 1 and Non_Blk = 1 then comb_ins_blk_2 = 1; else comb_ins_blk_2 = 0;
cds_comb_ins_blk_2 = cds*comb_ins_blk_2;

*board independence;
if not missing(BD_IND) then do;
if BD_IND >= 60 then high_bd = 1; else high_bd = 0;
end;

if fyear < 2003 then high_bd = .; *only for post-SOX period;
cds_High_BD = cds*High_BD;
run;

*(b) variables used for only CDS group;
data tmp_2_8_3;
set tmp_2_8_2;

*replacement with zero for missing;
avg_rel_cds_protect_a = avg_rel_cds_protect; if missing(avg_rel_cds_protect) then avg_rel_cds_protect_a = 0;
run;

proc rank data=tmp_2_8_3 out=tmp_2_8_4
groups = 2;
where CDS = 1 and pre_2001 = 0;
by fyear;
var mean_CompositeDepth5y mean_term_count  avg_rel_cds_protect_a ;
ranks r1s r2s r3s;
run; 

data tmp_2_8_5;
set tmp_2_8_4;

if r1s = 1 then high_cds_1 = 1; else high_cds_1 = 0; 
if r1s = 0 then low_cds_1 = 1;  else low_cds_1 = 0; 

if r2s = 1 then high_cds_2 = 1; else high_cds_2 = 0; 
if r2s = 0 then low_cds_2 = 1;  else low_cds_2 = 0; 

if r3s = 1 then high_rel_cds_protect = 1; else high_rel_cds_protect = 0;
if r3s = 0 then low_rel_cds_protect = 1;  else low_rel_cds_protect = 0;
run;

*to combine the cds only data;
proc sql;
       create table tmp_2_8_6
       as select a.*, b.high_cds_1, b.low_cds_1, b.high_cds_2, b.low_cds_2, b.high_rel_cds_protect, b.low_rel_cds_protect
       from tmp_2_8_3 a left join tmp_2_8_5 b
      on a.gvkey  = b.gvkey and a.fyear = b.fyear;
quit; 

*for various combinations for join test;
data tmp_2_8_7;
set tmp_2_8_6;

if cds=0 then do;
high_cds_1 = 0; low_cds_1 = 0; 
high_cds_2 = 0; low_cds_2 = 0;
high_rel_cds_protect = 0; low_rel_cds_protect = 0;
end;

*(1) cds liquidity & institutional ownership (no block) & lead lenders' share;
if cds = 1 and high_cds_1 = 1 and comb_ins_blk_2 = 1 and h2_bksh = 0 then cds_high_all_1 = 1; else cds_high_all_1 = 0;
if cds = 1 and high_cds_1 = 0 and comb_ins_blk_2 = 0 and h2_bksh = 1 then cds_low_all_1 = 1; else cds_low_all_1 = 0;
if cds = 1 and cds_high_all_1 = 0 and cds_low_all_1 = 0 then cds_other_1 = 1; else cds_other_1 = 0;
if high_cds_1 = . or comb_ins_blk_2 = . or h2_bksh  = . then high_all_1_miss = 1; else high_all_1_miss = 0;

*(2) cds liquidity & institutional ownership (no block) & financial covenants;
if cds = 1 and high_cds_1 = 1 and comb_ins_blk_2 = 1 and h2_fincov = 0 then cds_high_all_2 = 1; else cds_high_all_2 = 0;
if cds = 1 and high_cds_1 = 0 and comb_ins_blk_2 = 0 and h2_fincov = 1 then cds_low_all_2 = 1; else cds_low_all_2 = 0;
if cds = 1 and cds_high_all_2 = 0 and cds_low_all_2 = 0 then cds_other_2 = 1; else cds_other_2 = 0;
if high_cds_1 = . or comb_ins_blk_2 = . or h2_fincov = . then high_all_2_miss = 1; else high_all_2_miss = 0;

run;

proc sort data=tmp_2_8_7 out=tmp_2_8_8 nodupkey;
by gvkey fyear;
run;

*(D-9) to delete the CDS firms whose first trading date is in January 2001;
data tmp_2_9;
set tmp_2_8_8;
if pre_2001 = 1 then delete;
run;

*Part E: final sample for main tests;
proc export data=tmp_2_9
    outfile="C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta" 
    replace;
quit; 


*Part F: Table 6: PSM test for CDS Initiation;
*(F-1)PSM variables;
data tmr_0_4;
set cds.tmr_0_4_ver_2016_01_15;
gvkey_n = input(gvkey, comma8.);
profit_margin = ni/sale;
run;
*this dataset has variables for the 1st stage model except for credit ratings;

*to add credit rating variable;
data tmr_0_5;
set cds.ratings_jan2016;
run;

proc sort data=tmr_0_5 out=tmr_0_5_1 nodupkey;
by gvkey year month;
run;

proc means data=tmr_0_5_1 noprint;
by gvkey year;
var rating_complete;
output out=tmr_0_5_2
mean = avg_rating
sum = sum_rating
n = n_rating;
run;

data tmr_0_5_3;
set tmr_0_5_2;
if sum_rating > 0 then rated = 1; else rated=0;
if avg_rating <= 10 then INV_GRADE = 1; else INV_GRADE = 0;
if avg_rating > 10 then  HY_GRADE = 1;  else HY_GRADE = 0;
if avg_rating >= 9 and avg_rating <= 11 then IG_HY = 1; 
if not missing(avg_rating) and missing(IG_HY) then IG_HY = 0;
run;

proc sql;
       create table tmr_0_5_4
       as select a.*, b.sum_rating, b.avg_rating, b.rated, b.INV_GRADE, b.HY_GRADE, b.IG_HY
       from tmr_0_4 a left join tmr_0_5_3 b
       on a.gvkey_n = b.gvkey and a.fyear  = b.year;
quit; 

*return volatility;
proc sql;
       create table tmr_0_5_5
       as select a.*, b.RET_STD as ret_volatility, b.N_Ret as n_ret_volatility
       from tmr_0_5_4 a left join cds.aud_1_9_ver_2015_11 b
       on a.gvkey = b.gvkey and a.fyear  = b.fyear;
quit;

proc sort data=tmr_0_5_5 out=tmr_0_6 nodupkey;
by gvkey fyear;
run;


*(F-2) to add PSM determinants of cds trading to the main dataset: determinansts from two-year from MF year (i.e., one-year prior to CDS year);
data tmr_0_6_1;
set tmr_0_6;
if R_SIC < 4;
if fyear > 1994; 
if missing(at) or at = 0 then delete;
if n_ret_volatility < 126 then ret_volatility = .;
run;

proc sql;
       create table tmr_0_6_2
       as select a.*, b.sum_rating as pre_sum_rating, b.avg_rating as pre_avg_rating, b.rated as pre_rated, b.INV_GRADE as pre_INV_GRADE,
                 b.LEVERAGE as pre_LEVERAGE, b.profit_margin as pre_profit_margin, b.LOG_TA as pre_LOG_TA, b.ret_volatility as pre_ret_volatility,
				 b.MTB as pre_MTB
       from tmp_2_8_8 a left join tmr_0_6_1 b
       on a.gvkey = b.gvkey and a.fyear - 2  = b.fyear;
quit; 

proc sort data=tmr_0_6_2 out=tmr_0_6_3  nodupkey;
by fyear gvkey;
run; 

data tmr_0_6_4;
set tmr_0_6_3;
if pre_sum_rating > 0 then pre_rated=1; else pre_rated =0;
if missing(pre_INV_GRADE) then pre_INV_GRADE = 0;

*adjustment of credit ratings;
if pre_sum_rating > 0 then pre_rated = 1; else pre_rated = 0;

if not missing(pre_avg_rating) and pre_avg_rating <= 10 then pre_INV_GRADE = 1; else pre_INV_GRADE = 0;
run;

%Wins(tmr_0_6_4, tmr_0_6_4, pre_LEVERAGE, p1, p99);
%Wins(tmr_0_6_4, tmr_0_6_4, pre_MTB, p1, p99);
%Wins(tmr_0_6_4, tmr_0_6_4, pre_LOG_TA, p1, p99);
%Wins(tmr_0_6_4, tmr_0_6_4, pre_ret_volatility, p1, p99);
%Wins(tmr_0_6_4, tmr_0_6_4, pre_profit_margin, p1, p99);

*First for PSM model;
data tmr_0_6_5;
set tmr_0_6_4;
if missing(pre_rated) or missing(pre_INV_GRADE) or missing(pre_LEVERAGE) or missing(pre_profit_margin) or missing(pre_LOG_TA) or missing(pre_MTB) or 
   missing(pre_ret_volatility) then delete;

cik_n=input(cik, 11.);
cusip8 = substr(cusip, 1, 8);
run;
*53,636 --> 48,654;
 
proc sort data=tmr_0_6_5 out=tmr_0_7 nodupkey;
by gvkey fyear;
run;


*(F-3) Dataset for CDS initiation probit model;
data check;
set tmr_0_7;
if cds_traded=1;
keep gvkey fyear cds_year first_cds_year ori_first_cds_year cds;
run;

proc sort data=check out=check_1 (keep=gvkey first_cds_year) nodupkey;
by gvkey first_cds_year;
run;

proc sort data=check_1;
by first_cds_year;
run;

proc freq data=check_1;
table first_cds_year;
run;
*cds-first year: 2000 to 2013;

*for non-firms with CDS traded = 0;
data tmr_0_8;
set tmr_0_7;
if cds_traded = 0;
cds_initiation = 0;
run;

*for CDS traded=1, only firm-years prior to the onset of CDS trade are included;
data tmr_0_9_0;
set tmr_0_7;
if cds_traded=1;

if cds_year > first_cds_year then delete;
if cds_year = first_cds_year then cds_initiation = 1; else cds_initiation = 0;

run;

data tmr_0_9_1;
set tmr_0_9_0;
if first_cds_year >= 2013 then delete;
run;
*Note: since we are comparing five-year period: t-5 ~ t-1 vs t ~ t+4;

proc sort data=tmr_0_9_1 out=check_1 nodupkey;
where cds_initiation =1;
by gvkey;
run;
*793 --> 789 firms (due to exclusion of cds initiation in 2012 and 2013;

data tmr_1_0;
set tmr_0_9_1 tmr_0_8;
year_cds_match = fyear-1;
run;

*PSM sample period should be over 1997 to 2012;
data check_2;
set tmr_1_0;
where cds_traded=1;
keep gvkey fyear cds_year first_cds_year first_cds_year cds year_cds_match cds_initiation;
run;

proc sort data=check_2 out=check_3(keep=year_cds_match) nodupkey;
by year_cds_match;
run;

data tmr_1_0_1;
set tmr_1_0;
if year_cds_match >= 1997 and year_cds_match <= 2012;

run;

proc sort data=out=tmr_1_0_1 out=tmr_1_1  nodupkey;
by gvkey fyear ;
run; 

*this is for PSM of CDS initiation;
proc export data=tmr_1_1
    outfile="C:\My_Works\Research_1\CDS_Information_Environment\Data\data_2_ver_2017_11.dta" 
    replace;
quit;


*(F-4) to obtain PSM matched sample ;
*to obtain the PSM sample;
libname in xport "C:\My_Works\Research_1\CDS_Information_Environment\Data\psm_1st.xpt" /*directory path where file is located/SAS export file nam*/;

data tmr_1_2_raw;
set in.psm_1st;
run;

data tmr_1_2;
set tmr_1_2_raw;
rename CDS_TRAD = cds_traded  CDS_FIRS = CDS_FIRST_date FIRST_CD = first_cds_year 
       PRE_RATE = pre_rated PRE_INV_ = pre_inv_grade PRE_LEVE = pre_leverage_w PRE_MTB_ = pre_mtb_w PRE_LOG_ = pre_log_ta_w 
       PRE_RET_ = pre_ret_volatility_w PRE_PROF = pre_profit_margin_w CDS_INIT = cds_initiation YEAR_CDS = year_cds_match          
;
run;

*CDS firms in the year prior to the cds initiation year;
data tmr_1_3;
set tmr_1_2;
if cds_initiation = 1 and year_cds_match = first_cds_year;

if cds_first_date <= '31JAN2001'd then pre_2001 = 1; else pre_2001 = 0;
run;

proc sort data=tmr_1_3;
by _id;
run;

data tmr_1_4;
set tmr_1_2;
if cds_initiation = 0;
run;

data check;
set tmr_1_4;
if cds_traded =1;
run;

proc sort data=tmr_1_4;
by _id;
run;

*to identify three closest matching firms;
proc sql;
       create table tmr_1_4_1
       as select a.*, b.gvkey as m_gvkey, b.year_cds_match as m_year_cds_match, b.PSCORE as m_PSCORE, b._id as m_id
       from tmr_1_3 a left join tmr_1_4 b 
       on a._N1 = b._ID;
quit; 

data tmr_1_4_1_1;
set tmr_1_4_1;
cds_gvkey = gvkey;
gvkey = m_gvkey;
m_sample = 1;

if missing(_N1) then delete;

if abs(pscore - m_PSCORE) / pscore > 0.25 then delete;

keep gvkey cds_gvkey cds_initiation first_cds_year pscore m_sample m_gvkey m_year_cds_match m_PSCORE m_id cds_first_date pre_2001;
run;

proc sql;
       create table tmr_1_4_2
       as select a.*, b.gvkey as m_gvkey, b.year_cds_match as m_year_cds_match, b.PSCORE as m_PSCORE, b._id as m_id 
       from tmr_1_3 a left join tmr_1_4 b 
       on a._N2 = b._ID;
quit; 

data tmr_1_4_2_1;
set tmr_1_4_2;
m_sample = 2;
cds_gvkey = gvkey;
gvkey = m_gvkey;

if missing(_N2) then delete;

if abs(pscore - m_PSCORE) / pscore > 0.25 then delete;

keep gvkey cds_gvkey cds_initiation first_cds_year pscore m_sample m_gvkey m_year_cds_match m_PSCORE m_id cds_first_date pre_2001;
run;

proc sql;
       create table tmr_1_4_3
       as select a.*, b.gvkey as m_gvkey, b.year_cds_match as m_year_cds_match, b.PSCORE as m_PSCORE, b._id as m_id  
       from tmr_1_3 a left join tmr_1_4 b 
       on a._N3 = b._ID;
quit; 

data tmr_1_4_3_1;
set tmr_1_4_3;
m_sample = 3;
cds_gvkey = gvkey;
gvkey = m_gvkey;

if missing(_N3) then delete;

if abs(pscore - m_PSCORE) / pscore > 0.25 then delete;

keep gvkey cds_gvkey cds_initiation first_cds_year pscore m_sample m_gvkey m_year_cds_match m_PSCORE m_id cds_first_date pre_2001;
run;

data tmr_1_3_1;
set tmr_1_3;
m_sample = 0;
cds_gvkey = gvkey;
m_id = _id;
keep gvkey cds_gvkey cds_initiation first_cds_year pscore m_sample m_id cds_first_date pre_2001;
run;

data tmr_1_4_4;
set tmr_1_4_1_1 tmr_1_4_2_1 tmr_1_4_3_1  tmr_1_3_1;
label m_gvkey = 'm_gvkey' m_year_cds_match = 'm_year_cds_match' m_PSCORE = 'm_PSCORE' m_id = 'm_id';
run;

proc sort data=tmr_1_4_4 out=tmr_1_4_5 nodupkey;
by cds_gvkey first_cds_year m_sample;
run;

*check for the duplicate of m_gvkey fyear;
proc sort data=tmr_1_4_5 out=check nodupkey;
by m_gvkey m_year_cds_match;
run;
*1,108 firm-years are duplicated!;

proc sort data=tmr_1_4_5 out=check_1 nodupkey;
by m_gvkey;
run;
*634 firms;

*to add firms' data from t-5 to t+4: t-5, t-4, t-3, t-2, t-1 vs t t+1 t+2 t+3 t+4 where t = cds initiation year;
proc sql;
       create table tmr_1_4_6
       as select a.*, b.fyear, b.d_mf1, b.num_mf1, b.num_mf1_w, b.cds, b.cds_traded, b.log_at_w, b.lag_mtb_w, b.roa_w, b.inst_own_w, b.log_following_w, 
                  b.rvol_w, b.eq_iss, b.lit, b.mid_zscore, b.lag_leverage_w, b.log_num_mf1_w, b.post_fd
       from tmr_1_4_5 a left join tmp_2_8_8 b
       on a.gvkey = b.gvkey;
quit; 

proc sort data=tmr_1_4_6 out=tmr_1_4_7 nodupkey;
by cds_gvkey first_cds_year m_sample fyear;
run;

*pre vs post-CDS initiation using the original cds first year of cds firms;
data tmr_1_4_8;
set tmr_1_4_7;
if fyear < first_cds_year then post = 0; else post = 1;
diff_year = fyear - first_cds_year;

if diff_year = 0 then chg_cds = 1; else chg_cds =0;
run;

*to limit to obs from t-5 to t+4;
data tmr_1_4_9;
set tmr_1_4_8;
if diff_year >= -5 and diff_year <= 4 ;
w=1;
run;

proc means data=tmr_1_4_9 noprint;
by cds_gvkey first_cds_year m_sample post;
var w;
output out=tmr_1_5_0
n = n_obs;
run;

data tmr_1_5_0_1;
set tmr_1_5_0;
if post=0;
n_pre_obs = _FREQ_;
keep cds_gvkey first_cds_year m_sample n_pre_obs cds_first_date pre_2001;
run;

data tmr_1_5_0_2;
set tmr_1_5_0;
if post=1;
n_post_obs = _FREQ_;
keep cds_gvkey first_cds_year m_sample n_post_obs cds_first_date pre_2001;
run;

data tmr_1_5_1;
merge tmr_1_5_0_1 tmr_1_5_0_2;
by cds_gvkey first_cds_year m_sample;

if missing(n_pre_obs) then n_pre_obs = 0;
if missing(n_post_obs) then n_post_obs = 0;

if n_pre_obs = 0 or n_post_obs = 0 then ex=1; else ex=0;

run;

data tmr_1_5_2;
set tmr_1_5_1;
if ex=1 then delete;
run;

*to obtain the CDS initiation sample only;
data tmr_1_5_3;
set tmr_1_5_2;
if m_sample = 0;
run;

*to add m_gvkey information for these cds initiation sample;
proc sql;
       create table tmr_1_5_3_1
       as select a.cds_gvkey, a.first_cds_year, b.m_sample, b.n_pre_obs, b.n_post_obs, b.ex
       from tmr_1_5_3 a left join tmr_1_5_2 b
       on a.cds_gvkey = b.cds_gvkey and a.first_cds_year = b.first_cds_year and b.m_sample ne 0;
quit; 

*to make sure at least one m_gvkey for cds initiation sample;
proc sort data=tmr_1_5_3_1 out=tmr_1_5_3_2 nodupkey;
where not missing(m_sample);
by cds_gvkey first_cds_year m_sample;
run;

proc sort data=tmr_1_5_3_2 out=tmr_1_5_3_3 (keep=cds_gvkey first_cds_year) nodupkey;
by cds_gvkey first_cds_year;
run;
*this is the group of cds firm with at least one matched firm;

*to combine cds initiation sample and non-cds initiation sample;
*(i) CDS firms;
data tmr_1_5_4_1;
merge tmr_1_5_3_3 (in=a) tmr_1_5_3;
by cds_gvkey first_cds_year;
if a=1;
run;

*(ii) non-CDS firms;
data tmr_1_5_4_2;
merge tmr_1_5_3_3 (in=a) tmr_1_5_3_2;
by cds_gvkey first_cds_year;
if a=1;
run;

data tmr_1_5_4_3;
set tmr_1_5_4_1 tmr_1_5_4_2;
run;

*to add the first_trading date;
proc sql;
       create table tmr_1_5_4_4
       as select a.*, b.cds_first_date, b.pre_2001
       from tmr_1_5_4_3 a left join tmr_1_3_1 b
       on a.cds_gvkey  =  b.cds_gvkey;
quit; 

proc sort data=tmr_1_5_4_4 out=tmr_1_5_5 nodupkey;
by cds_gvkey first_cds_year m_sample;
run;

*to add variables;
proc sql;
       create table tmr_1_5_6
       as select b.*, a.*
       from tmr_1_5_5 a left join tmr_1_4_9 b
       on a.cds_gvkey = b.cds_gvkey and a.first_cds_year = b.first_cds_year and a.m_sample = b.m_sample;
quit; 

proc sort data=tmr_1_5_6 nodupkey;
by cds_gvkey first_cds_year m_sample fyear;
run;

data tmr_1_5_7;
set tmr_1_5_6;
if m_sample = 0 then psm_cds = 1; else psm_cds = 0;
psm_cds_chg_cds = psm_cds*chg_cds;

psm_cds_post = psm_cds*post;
run;

*to make sure that no duplekite for matched firm;
data tmr_1_5_7_1;
set tmr_1_5_7;
if m_sample ne 0;
run;

proc sort data=tmr_1_5_7_1 out=tmr_1_5_7_2 nodupkey;
by gvkey fyear;
run;

data tmr_1_5_7_3;
set tmr_1_5_7;
if m_sample = 0;
run;

data tmr_1_6;
set tmr_1_5_7_3 tmr_1_5_7_2;

if pre_2001 = 1 then delete;
run;

*(F-5) final sample for PSM tests;
proc export data=tmr_1_6
    outfile="C:\My_Works\Research_1\CDS_Information_Environment\Data\data_3_ver_2017_11.dta" 
    replace;
quit;

*test for difference in pscore and other determinants;;
proc sql;
       create table tmr_1_6_1
       as select  a.*, b.m_id
       from tmr_1_5_5 a left join tmr_1_4_5 b
       on a.cds_gvkey = b.cds_gvkey and a.first_cds_year = b.first_cds_year and a.m_sample = b.m_sample;
quit;

proc sql;
       create table tmr_1_6_2
       as select  a.*, b.gvkey, b.year_cds_match, b.pscore, b.cds_initiation, b.pre_rated, b.pre_inv_grade, b.pre_leverage_w, b.pre_profit_margin_w, b.pre_log_ta_w,
                  b.pre_ret_volatility_w, b.pre_mtb_w, b.cds_first_date
       from tmr_1_6_1 a left join tmr_1_2 b
       on a.m_id  = b._id;
quit;

proc sort data=tmr_1_6_2 out=tmr_1_6_3 nodupkey;
where pre_2001 = 0;
by cds_initiation cds_gvkey first_cds_year m_sample;
run;

data tmr_1_6_4;
set tmr_1_6_3;
w=1;
run;

%Wins(tmr_1_6_4, tmr_1_6_4, pscore, p1, p99);

*t-test;
proc ttest data=tmr_1_6_4;
class cds_initiation;
var  pscore_w pre_rated pre_inv_grade pre_leverage_w pre_profit_margin_w pre_log_ta_w pre_ret_volatility_w pre_mtb_w;
run;


*Part G: CDS Trading initiation - change analysis;
proc sort data=tmp_2_8_8 out = tmr_1_7_0 nodupkey;
by gvkey cds fyear;
run;

*(G-1) to measure varibles in change form;
data tmr_1_7_1;
set tmr_1_7_0;

*change variables;
lag_log_at_w = lag1(log_at_w);
lag_lag_mtb_w = lag1(lag_mtb_w);
lag_roa_w = lag1(roa_w);
lag_inst_own_w = lag1(inst_own_w);
lag_log_following_w = lag1(log_following_w);
lag_rvol_w = lag1(rvol_w);
lag_lit = lag1(lit);
lag_eq_iss = lag1(eq_iss);
lag_mid_zscore = lag1(mid_zscore);
lag_lag_leverage_w = lag1(lag_leverage_w);
lag_d_mf1 = lag1(d_mf1);
lag_num_mf1 = lag1(num_mf1);
lag_num_mf1_w = lag1(num_mf1_w);

if lag1(gvkey)^=gvkey or lag1(fyear)^=fyear-1 then do;
lag_log_at_w = .;
lag_lag_mtb_w = .;
lag_roa_w = .;
lag_inst_own_w = .;
lag_log_following_w = .;
lag_rvol_w = .;
lag_lit = .;
lag_eq_iss = .;
lag_mid_zscore = .;
lag_lag_leverage_w = .;
lag_d_mf1 = .;
lag_num_mf1 = .;
lag_num_mf1_w = .;
end;

chg_log_at_w = log_at_w - lag_log_at_w;
chg_lag_mtb_w = lag_mtb_w - lag_lag_mtb_w;
chg_roa_w = roa_w - lag_roa_w;
chg_inst_own_w = inst_own_w - lag_inst_own_w;
chg_log_following_w = log_following_w - lag_log_following_w;
chg_rvol_w = rvol_w - lag_rvol_w;
chg_lit = lit  - lag_lit ;
chg_eq_iss = eq_iss  - lag_eq_iss ;
chg_d_mf1 = d_mf1 - lag_d_mf1;
chg_num_mf1_w = num_mf1_w - lag_num_mf1_w;
chg_log_num_mf1 = log(1+num_mf1) - log(1+lag_num_mf1);

if missing(lag_mid_zscore) then lag_mid_zscore = 0; chg_mid_zscore = mid_zscore - lag_mid_zscore;
if missing(lag_lag_leverage_w) then lag_lag_leverage_w = 0; lagchg_leverage_w = lag_leverage_w - lag_lag_leverage_w;

if fyear < first_cds_year then post = 0; else post = 1;
diff_year = fyear - first_cds_year;
if diff_year = 0 then chg_cds = 1; else chg_cds =0;

log_lag_num_mf1_w = log(1+lag_num_mf1_w);
run;

proc sort data=tmr_1_7_1 out=tmr_1_7_2;
by gvkey fyear;
run;

data tmr_1_7_3;
set tmr_1_7_2;

if missing(chg_num_mf1_w) or missing(chg_log_at_w) or missing(chg_lag_mtb_w) or missing(chg_roa_w) or missing(chg_inst_own_w) or missing(chg_log_following_w) or 
   missing(chg_rvol_w) or missing(chg_eq_iss) or missing(chg_lit) or missing(chg_mid_zscore) or missing(lagchg_leverage_w) then delete;
run;

proc sort data=tmr_1_7_3 nodupkey;
by gvkey fyear;
run;

%Wins(tmr_1_7_3, tmr_1_7_3, chg_log_num_mf1, p1, p99);

*only for cds firms;
data tmr_1_7_4;
set tmr_1_7_3;

if cds_traded=1;
if first_cds_year < 2001  then delete;
if first_cds_year > 2013  then delete;
run;

*(G-2) to obtain firm-years from t-5 to t+4;
data tmr_1_7_5;
set tmr_1_7_4;
 
if diff_year = 0;
year_cds_ext = 1;
keep gvkey year_cds_ext;
run;

data tmr_1_7_6_1;
set tmr_1_7_4;

if diff_year = 0 then delete;
if diff_year >= -5 and diff_year <= 4 ;
run;

proc means data=tmr_1_7_6_1 noprint;
by gvkey post;
var w;
output out=tmr_1_7_6_2
n = n_obs;
run;

data tmr_1_7_6_3;
set tmr_1_7_6_2;
if post=0;
n_pre_obs = _FREQ_;
keep gvkey n_pre_obs;
run;

data tmr_1_7_6_4;
set tmr_1_7_6_2;
if post=1;
n_post_obs = _FREQ_;
keep gvkey n_post_obs;
run;

data tmr_1_7_7;
merge tmr_1_7_6_3 tmr_1_7_6_4;
by gvkey;

if missing(n_pre_obs) then n_pre_obs = 0;
if missing(n_post_obs) then n_post_obs = 0;
run;

data tmr_1_7_8;
set tmr_1_7_7;

if n_pre_obs < 3 or n_post_obs < 2 then ex=1; else ex=0;
run;

proc sql;
       create table tmr_1_7_9
       as select a.*, b.*
       from tmr_1_7_5 a left join tmr_1_7_8 b
       on a.gvkey  =  b.gvkey;
quit; 

data tmr_1_8_0;
set tmr_1_7_9;
if ex=1 then delete;
run;

data tmr_1_8_1;
set tmr_1_7_4;

if diff_year >= -5 and diff_year <= 4;
run;

proc sql;
       create table tmr_1_8_2
       as select a.*, b.*
       from tmr_1_8_0 a left join tmr_1_8_1 b
       on a.gvkey  =  b.gvkey;
quit; 

*to include prior years change in mf;
proc sql;
       create table tmr_1_8_3
       as select a.*, b.chg_log_num_mf1_w as pre_chg_log_num_mf1_w
       from tmr_1_8_2 a left join tmr_1_7_4 b
       on a.gvkey  =  b.gvkey and a.fyear -1 = b.fyear;
quit; 

data tmr_1_8_4;
set tmr_1_8_3;

if pre_2001 = 1 then delete;
run;

proc sort data=tmr_1_8_4 out = tmr_1_9 nodupkey;
by gvkey fyear;
run;

*(G-4) final sample for change analysis;
proc export data=tmr_1_9
    outfile="C:\My_Works\Research_1\CDS_Information_Environment\Data\data_4_ver_2017_11.dta" 
    replace;
quit;
