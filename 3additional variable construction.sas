
*********************************************************************************************************************
** Complementary versus Substitute
********************************************************************************************************************;

%let wrds = wrds.wharton.upenn.edu 4016;
options comamid=TCP;
signon wrds username=_prompt_;

**data from compustat quarterly;
rsubmit;
data comp;
	set comp.fundq;
	keep gvkey fyearq fqtr datadate saleq niq sich;
	if indfmt="INDL" and datafmt="STD" and  popsrc="D" and  consol="C" ;
	if fyearq > = 1990 and fyearq <= 2013;
	if atq>0 and atq~=. and saleq~=. and saleq>0 and fyearq~=. and fqtr~=.;
	proc sort ;by gvkey fyearq fqtr descending datadate;
	proc sort nodupkey;by gvkey fyearq fqtr;run;
proc sql;
	create table comp as
	select a.*,substr(b.sic,1,3) as sic3
	from comp a left join comp.names b
	on a.gvkey=b.gvkey;
	quit;
**create quarter index;
proc sort data = comp out = index (keep=fyearq fqtr) nodupkey;by fyearq fqtr;
data index;set index;qtrnum=_N_;run;

proc sql;
	create table comp as 
	select *
	from comp a, index b
	where a.fyearq=b.fyearq and a.fqtr=b.fqtr;
	quit;
proc print data = comp  (obs=100);run;

endrsubmit;

rsubmit; 
**get the industry average sales;
proc sql;
	create table comp2 as
	select distinct a.*,avg(b.saleq) as saleq_j
	from comp a left join comp b
	on a.sic3 = b.sic3 and a.fyearq = b.fyearq and a.fqtr=b.fqtr and a.gvkey~=b.gvkey 
	group by a.gvkey,a.fyearq,a.fqtr
	order by a.gvkey,a.fyearq,a.fqtr;
	quit;

proc print data = comp2 (obs=100);run;

endrsubmit;

**create variables for regresssion, 
equation (2) of Kedia (2006 JBF)
Estimating product market competition: Methodology and application;
rsubmit;
proc sort data = comp2 ; by gvkey qtrnum;
data comp3;
	set comp2;
	by gvkey qtrnum;
	dpi_i=niq-lag(niq);
	dxi_i=saleq-lag(saleq);
	dx_j =saleq_j-lag(saleq_j);
	if gvkey~=lag(gvkey) or qtrnum~=lag(qtrnum)+1 then do;
	dpi_i=.;dxi_i=.;dx_j=.;end;
	y=dpi_i/dxi_i;
	dy=y-lag(y);
	xidxi=saleq*dxi_i;
	xidxj=saleq*dx_j;
	keep gvkey sic3 fyearq fqtr qtrnum saleq dy xidxi dxi_i xidxj dx_j saleq_j niq;
	run;
endrsubmit;

rsubmit; 
proc print data = comp3 (obs=1000);var gvkey fyearq fqtr dx_j saleq_j niq qtrnum;run; 
endrsubmit;

***winsorization;

rsubmit;
/* invoke macro to winsorize */
%macro winsor(dsetin=, dsetout=, byvar=none, vars=, type=winsor, pctl=1 99);
  
%if &dsetout = %then %let dsetout = &dsetin;
     
%let varL=;
%let varH=;
%let xn=1;
  
%do %until ( %scan(&vars,&xn)= );
    %let token = %scan(&vars,&xn);
    %let varL = &varL &token.L;
    %let varH = &varH &token.H;
    %let xn=%EVAL(&xn + 1);
%end;
  
%let xn=%eval(&xn-1);
  
data xtemp;
    set &dsetin;
    run;
  
%if &byvar = none %then %do;
  
    data xtemp;
        set xtemp;
        xbyvar = 1;
        run;
  
    %let byvar = xbyvar;
  
%end;
  
proc sort data = xtemp;
    by &byvar;
    run;
  
proc univariate data = xtemp noprint;
    by &byvar;
    var &vars;
    output out = xtemp_pctl PCTLPTS = &pctl PCTLPRE = &vars PCTLNAME = L H;
    run;
  
data &dsetout;
    merge xtemp xtemp_pctl;
    by &byvar;
    array trimvars{&xn} &vars;
    array trimvarl{&xn} &varL;
    array trimvarh{&xn} &varH;
  
    do xi = 1 to dim(trimvars);
  
        %if &type = winsor %then %do;
            if not missing(trimvars{xi}) then do;
              if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = trimvarl{xi};
              if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = trimvarh{xi};
            end;
        %end;
  
        %else %do;
            if not missing(trimvars{xi}) then do;
              if (trimvars{xi} < trimvarl{xi}) then delete;
              if (trimvars{xi} > trimvarh{xi}) then delete;
            end;
        %end;
  
    end;
    drop &varL &varH xbyvar xi;
    run;
  
%mend winsor;
endrsubmit;

rsubmit;
%winsor(dsetin=comp3, dsetout=comp2_w, byvar=none, vars=dy xidxi dxi_i xidxj dx_j, type=winsor, pctl=1 99);
 endrsubmit;

***estimate Beta_3*x_i + Beta_4 for each firm-year, using the data in previous 16 quarters
Beta_3 is the coefficient of x_idxj, and Beta_4 is the coefficient of dx_j
 x_i is the average sales in previous 16 quarters;
rsubmit;
%macro bc(); 
proc sql;drop table COS;quit;
%do year = 1994 %to 2012;
data tmp;
	set comp2_w;
	if fyearq<=&year and fyearq>=&year-3; 
	proc sort;by gvkey; 
options nonotes; 
proc reg data=tmp edf outest=_params (
    keep= gvkey xidxj dx_j  _p_ _edf_) noprint; 
    by gvkey;
    model dy = xidxi dxi_i xidxj dx_j /noint;
  quit;  
options notes; 
data _params;set _params;
	obs = _p_+_edf_; 
	run; 
proc means data = tmp noprint;
	by gvkey;id sic3; var saleq;output out = msale(keep=gvkey sic3 saleq)
	mean(saleq) = saleq;run;
proc sql;
	create table msale2 as
	select a.gvkey,a.sic3,a.saleq*xidxj+dx_j as COS,saleq,obs
	from msale a left join _params b
	on a.gvkey = b.gvkey;quit;
data msale2;set msale2;year = &year;
proc append data = msale2 base = COS;run;
%end;
%mend; 
%bc;
endrsubmit;

rsubmit;
proc download data = cos out = cos;run;
endrsubmit;

data cos2;
	set cos;
	if obs>=16;   
	if cos~=.;run;
proc sort data = cos2;by sic3  ;
**compute the industry median of Beta_3*x_i + Beta_4 ;
proc means data = cos2 noprint;
	by sic3  year ;
	var cos;
	output out = ind_subs(keep=sic3  year  cos)
	median(cos)=cos;
	run;
data ind_subs (drop = cos);set ind_subs;bertrand=(cos>0 and cos~=.); 
run;
proc export
	data = ind_subs
	file = "~\cournot.dta"
	replace;
	run;


*********************************************************************************************************************
** Presence of public firms
********************************************************************************************************************;
**Census Concentration data.dta is the census data of manufacuturing industries collected from US census. 
ic is the industry code (NAICS after 1997, and SIC before 1997), year is the census year (1992, 1997, 2002, 2007),
total_sales is the total sales in the industry, total_comps is the number of firms in the industry;
proc import file="~\Census Concentration data.dta" out=census replace;run; 
%let i = 3;
data census (keep = ic year total_sales total_comps);
	set census;
	if year>=1997;
	if digits = &i;
	run;
proc sort data = census;by ic year;run;
proc sort data = census out = ind(keep=ic) nodupkey;by ic;run;
data year;
	input year @@;
	cards;
	1997 1998 1999 2000 2001 2002 2003 2004 2005
	2006 2007 2008 2009 2010 2011 2012
	;
	run;
proc sql;
	create table indyear as
	select * from ind,year;quit;
proc sort data = indyear;by ic year;run;
data indyear;merge indyear census;by ic year;run;
 *Linear Approach to fill in missing value 
(e.g.US census only provide data for industry i in census year 2002 and year 2007.
We use a linear approach to fill in the value for 2003-2006); 
data nomissing;
      set indyear;
	  if total_sales ~=.; 
	  run;

proc sql;
      create table panel2
	  as select a.*,b.year as left_year,b.total_sales as left_total_sales
      from indyear a left join nomissing b
      on a.ic=b.ic and (b.year<=a.year)
      group by a.ic,a.year
      having b.year=max(b.year);
quit; 

proc sql;
      create table panel2
	  as select a.*,b.year as right_year,b.total_sales as right_total_sales
      from panel2 a left join nomissing b
      on a.ic=b.ic and (b.year>=a.year) 
      group by a.ic,a.year
      having b.year=min(b.year);
quit;

data  panel3(drop=  left_total_sales right_total_sales left_year right_year);
      set panel2;
      if  total_sales = . then do;
	  if left_year~=. and right_year~=. then
	     total_sales =((right_total_sales/left_total_sales)**(1/(right_year-left_year)))**(year-left_year)*left_total_sales;
		 else if left_year~=. and right_year=. then total_sales =left_total_sales;
		 else if left_year=. and right_year~=. then total_sales =right_total_sales;
		 end;
	  run;
 
***now go to COMPUSTAT and CRSP to estimate sales by public firms;
 %let wrds=wrds.wharton.upenn.edu 4016;options comamid=TCP remote=WRDS;
	signon username=_prompt_; 
rsubmit;

proc sql;
create table data
	  as select  c.gvkey,datadate,fyear,c.naics,f.sale
	  from comp.company as c, comp.funda as f
	  where f.gvkey = c.gvkey
	  and datadate>='01JAN1997'd
	  and f.indfmt='INDL' and f.datafmt='STD' and f.popsrc='D' and f.consol='C' and f.curcd="USD"  ;
	quit;  	
					proc sort data=crsp.ccmxpf_linktable out=lnk;
  					where LINKTYPE in ("LU", "LC", "LD", "LF", "LN", "LO", "LS", "LX") and
       					(2017 >= year(LINKDT) or LINKDT = .B) and (1950 <= year(LINKENDDT) or LINKENDDT = .E);
  					by GVKEY LINKDT; run;	    
					proc sql; create table temp as select a.lpermno as permno,b.*
						from lnk a,data b where a.gvkey=b.gvkey 
						and (LINKDT <= b.datadate or LINKDT = .B) and (b.datadate <= LINKENDDT or LINKENDDT = .E) and lpermno ne . and not missing(b.gvkey);
					quit;  
					data temp;
						set temp;
						where not missing(permno);
					run;  	
					*======================================

						Screen on Stock market information: common stocks and major exchanges

					=======================================;
					*----------------------screen for only NYSE, AMEX, NASDAQ, and common stock-------------;
					proc sort data=crsp.mseall(keep=date permno exchcd shrcd siccd) out=mseall nodupkey;
						where exchcd in (1,2,3) or shrcd in (10,11,12);
						by permno exchcd date; run;
					proc sql; create table mseall as 
						select *,min(date) as exchstdt,max(date) as exchedt
						from mseall group by permno,exchcd; quit;    
					proc sort data=mseall nodupkey;
						by permno exchcd; run;
					proc sql; create table temp as select *
						from temp as a left join mseall as b
						on a.permno=b.permno 
						and exchstdt<=datadate<= exchedt; 
					quit; 
					data temp; 
						set temp;
					   	where exchcd in (1,2,3) and shrcd in (10,11) and not missing(permno);
						drop shrcd date siccd exchstdt exchedt;
					run;  			
					proc sort data=temp nodupkey;
						by gvkey datadate;
					run; 
data temp (keep=gvkey fyear datadate permno naics sale);set temp;
run;
proc download data=temp out=naics_firm;run;
endrsubmit;
data naics_firm2;set naics_firm;ic=substr(naics,1,&i);if length(ic)=&i;run;
proc sort data = naics_firm2;by ic fyear;run;
proc means data = naics_firm2 noprint;
	var sale;
	by ic fyear;
	output out = naicsale (keep= ic fyear pubsale)
	sum(sale)=pubsale;
	where sale>0;
	run;
proc sql;
      create table pct_pubfirm&i. as
	  select a.ic as naics_&i.digit,a.fyear+1 as year,a.pubsale/b.total_sales*1000  as pct_pubfirm&i.d
	  from naicsale a left join panel3 b
	  on a.ic=substr(b.ic,1,&i) and a.fyear=b.year;
	  quit; 
proc export data =  pct_pubfirm&i. 
    file="~\pctpublicfirm&i.d_s.dta" replace;
	run;
 

*********************************************************************************************************************
** Number of patents owned by a median firm in an industry
********************************************************************************************************************;
*the patent data patents.csv is obtained from https://iu.app.box.com/v/patents;
data WORK.PATENTS    ;
 %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
 infile '~\patents.csv' delimiter = ',' MISSOVER DSD lrecl=32767  firstobs=2 ;
	 informat patnum best32. ;
	 informat fdate mmddyy10. ;
	 informat idate mmddyy10. ;
	 informat pdate $6. ;
	 informat permno $10. ;
	 informat class $10. ;
	 informat subclass $10. ;
	 informat ncites $10. ;
	 informat xi $10. ;
	 format patnum best12. ;
	 format fdate mmddyy10. ;
	 format idate mmddyy10. ;
	 format pdate $6. ;
	 format permno $10. ;
	 format class $10. ;
	 format subclass $10. ;
	 format ncites $10. ;
	 format xi $10. ;
	 input
	 patnum
	 fdate
	 idate
	 pdate $
	 permno $
	 class $
	 subclass $
	 ncites $
	 xi $
	 ;
 if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 run;
data PATENTS;set PATENTS;
	if permno~="";
	year=year(idate);
	if year>=1995;
	proc sort;by permno year;
 **the following macro calculate the number of patents owned by a firm from 1995 to the year;
%macro m;
proc sql;drop table numpatent;run;
%do year = 2000 %to 2012;
data tmp;set patents;
	if year<=&year;
	proc sort;by permno year;
proc means noprint;
	by permno  ;var year;
	output out = numpatent0 (keep=permno   numpatent)
	N=numpatent;run;
data numpatent0;set numpatent0;year = &year;
proc append base = numpatent data = numpatent0;run;
%end;
%mend;
%m;

**obtain the industry for each firm (Permno) from CRSP;
rsubmit;
libname cs '/wrds/crsp/sasdata/a_stock';
data mse (keep=permno year sic);
	set cs.mse;
	year = year(date);
	if year(date)>=1999 and year(date)<=2012;
	sic = siccd;
	if sic=. then sic=hsiccd;
	proc sort nodupkey;by permno year;
proc download data = mse  out = mse;run;
endrsubmit;

proc sql;
	create table mse2 as
	select * from mse a ,numpatent b
		where  put(a.permno,best5.) =   b.permno
		and a.year = b.year;
	quit;
data mse2;set mse2;if numpatent = . then numpatent = 0;sic2 = int(sic/100);if year>=2000 and year<=2012;run;
proc sort data = mse2;by sic2 year;
proc means data=mse2 noprint;
	by sic2 year ;var numpatent;
	output out = indpatent (keep=sic2  year p50patent)
	median(numpatent)=p50patent;
	where sic2~=.  ;
	run;  
proc export data =indpatent file = "~\patent_industry_level.dta"
	replace;run;
 
*********************************************************************************************************************
** stock returns in a calendar year
********************************************************************************************************************;
**this code borrows largely from the SAS code provided by 
Green, Hand and Zhang (2017), The Characteristics that Provide Independent Information about Average U.S. Monthly Stock Returns. The Review of Financial Studie;
rsubmit;

proc sql;
create table data as
      select gvkey,datadate,fyear, year(datadate) as cyear 
	  from comp.funda as f
	  where 
	  not missing(at)  and not missing(prcc_f)  and datadate>='01JAN1993'd and datadate<='01DEC2013'd 
	  and f.indfmt='INDL' and f.datafmt='STD' and f.popsrc='D' and f.consol='C';
	quit;  

proc sort data = data ; by gvkey fyear descending datadate;
proc sort data = data nodupkey;by gvkey fyear;run;
*Create merge with CRSP
					*======================GET CRSP IDENTIFIER=============================;
					proc sort data=crsp.ccmxpf_linktable out=lnk;
  					where LINKTYPE in ("LU", "LC", "LD", "LF", "LN", "LO", "LS", "LX") and
       					(2017 >= year(LINKDT) or LINKDT = .B) and (1950 <= year(LINKENDDT) or LINKENDDT = .E);
  					by GVKEY LINKDT; run;	    
					proc sql; create table temp as select a.lpermno as permno,b.*
						from lnk a,data b where a.gvkey=b.gvkey 
						and (LINKDT <= b.datadate or LINKDT = .B) and (b.datadate <= LINKENDDT or LINKENDDT = .E) and lpermno ne . and not missing(b.gvkey);
					quit;  
					data temp;
						set temp;
						where not missing(permno);
					run;  	
					*======================================

						Screen on Stock market information: common stocks and major exchanges

					=======================================;
					*----------------------screen for only NYSE, AMEX, NASDAQ, and common stock-------------;
					proc sort data=crsp.mseall(keep=date permno exchcd shrcd siccd) out=mseall nodupkey;
						where exchcd in (1,2,3) or shrcd in (10,11,12);
						by permno exchcd date; run;
					proc sql; create table mseall as 
						select *,min(date) as exchstdt,max(date) as exchedt
						from mseall group by permno,exchcd; quit;    
					proc sort data=mseall nodupkey;
						by permno exchcd; run;
					proc sql; create table temp as select *
						from temp as a left join mseall as b
						on a.permno=b.permno 
						and exchstdt<=datadate<= exchedt; 
					quit; 
					data temp; 
						set temp;
					   	where exchcd in (1,2,3) and shrcd in (10,11) and not missing(permno);
						drop shrcd date siccd exchstdt exchedt;
					run;  			
					proc sort data=temp nodupkey;
						by gvkey datadate;
					run;

*==========================================================================================================
=========================================================================================================;
*---------------------------add returns and monthly CRSP data we need later-----------------------------;	
* we use the returns during a calendar year since our treatment measure is at the calendar year level;	
proc sql;
	create table temp2
	as select a.*,b.ret,abs(prc) as prc,shrout,vol,b.date
	from temp a left join crsp.msf b
	on a.permno=b.permno and MDY(1,1,fyear)<=b.date<=MDY(12,31,fyear);
	quit;
							*-----------Included delisted returns in the monthly returns--------------------;
							proc sql;
						 	  create table temp2
							      as select a.*,b.dlret,b.dlstcd,b.exchcd
 							     from temp2 a left join crsp.mseall b
							      on a.permno=b.permno and a.date=b.date;
							      quit;	
							data temp2;
								set temp2;
 								if missing(dlret) and (dlstcd=500 or (dlstcd>=520 and dlstcd<=584))
									and exchcd in (1,2) then dlret=-.35;
 								if missing(dlret) and (dlstcd=500 or (dlstcd>=520 and dlstcd<=584))
									and exchcd in (3) then dlret=-.55; *see Johnson and Zhao (2007), Shumway and Warther (1999) etc.;
								if not missing(dlret) and dlret<-1 then dlret=-1;
								if missing(dlret) then dlret=0;
								ret=ret+dlret;
								if missing(ret) and dlret ne 0 then ret=dlret;
								run;
							proc sort data=temp2;
								by permno date descending datadate;
								run;
							proc sort data=temp2 nodupkey;
								by permno date;
							run;	 
 
data temp2(keep=gvkey permno fyear date ret);set temp2;run;

proc download data = temp2 out = stockreturn;run;

endrsubmit;
 

***obtain the return for each portfolio (size);
rsubmit;

PROC SQL;
  create table decileData as
  select b.permno,b.date, b.ret, b.decret, capn
  from  crsp.ermport1  b
  where '01JAN1992'd<=b.date-1 <= '31DEC2013'd ;
  quit;
proc sort data=decileData nodupkey;by permno date;run;
proc download data=decileData out= decilereturn;
run;
endrsubmit;

proc sql;
create table temp as
select a.gvkey,a.date,year(a.date) as year,log(1+a.ret-b.decret) as ret_sizeadj,log(1+a.ret) as ret
from stockreturn a left join decilereturn b
on a.permno=b.permno and a.date=b.date;
quit;

proc sort data = temp; by gvkey year;run;

proc means noprint data = temp;
    by gvkey year;
	output out= yearret
	(keep = gvkey year lnret lnret_sizeadj OBS_ret OBS_ret_sizeadj)
	sum(ret ret_sizeadj) = lnret lnret_sizeadj
    N(ret ret_sizeadj)=OBS_ret OBS_ret_sizeadj
    ;
	run;

data yearret(keep=gvkey year BHAR BHAR_sizeadj);
     set yearret;
	 BHAR = exp(lnret)-1;
	 BHAR_sizeadj=exp(lnret_sizeadj)-1;
	 if OBS_ret_sizeadj=12;
	 run;

proc export data = yearret
     file = "~\stockreturn.dta" replace;
	 run;
