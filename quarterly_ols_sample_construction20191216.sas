proc datasets lib=work kill nolist memtype=data;
quit;

/*************************************************************************************/

/* This file creates quarterly sample of earnings forecast decision. 
This is the first file that needs to be run to produce the regression sample. 

A different file, similary named as quarterly_ols_sample_construction20191216_pseudordq, 
produces guidance decisions using pseudo rdq date (Section 9.3 Table 12).

The first step is to combine IBES Guidance data, which contains management forecasts issued after November 1992 till now, 
with Compustat CRSP Merged data (CCM).

*/

%let pathraw=//Mac/Dropbox/My Projects/data/RawData;
%let path=//Mac/Dropbox/My Projects/Disclosure/datafinal;
libname rawdata "&pathraw";
%let ccmq_vars=permno gvkey datadate fqtr rdq;






/*****************************************************************************************/

/*Step I: IBES Guidance intitial cleaning*/

data guide; set rawdata.det_guidance; run;






/* 1.1 keep only us currency and us firms */

data guide; set guide; if curr ~= 'USD' | usfirm ~= 1 then delete;
run;
data guide; set guide; where year(anndats)>=2002 and year(anndats)<=2017; run;
*470,205 observations after deleting non-US firms;













/* 1.2 Obtain permno for IBES Guidance using ibes_crsp linking file */

* import ibes ticker data;
proc import DATAFILE = "&pathraw/IBESCRSPLINK.dta"
	out = ibesid
	dbms = dta replace;
run;

proc import DATAFILE = "&pathraw/IBESGuideCRSPLINK.dta"
	out = ibesguidanceid 
	dbms = dta replace;
run;
data ibesid; set ibesid ibesguidanceid; run;
data ibesid; set ibesid; where score<=1; run; 
proc sort data=ibesid nodupkey; by ticker permno; run;


* Obtain permno for IBES Guidance data. Each permno might correspond to multiple ticker and vice versa.
We have variables indicating the date range for a valid PERMNO-ticker pair;

proc sql; create table cigpermno as 
	select guide.*, ibesid.permno from guide inner join ibesid 
	on guide.ticker = ibesid.ticker
	order by ticker, anndats, permno; 
quit;
* 513,485;













/* 1.3 Assign management forecast to each fiscal year*/

/* Some firms have missing rdqs or have large difference between adjacent rdqs due to restatements. */


/* 1.3.1 import ccm quarterly */
data ccmq; set rawdata.ccmq00to17_20180227(keep=&ccmq_vars); where year(datadate) >=2002 and year(datadate)<=2017; run;
* 432736 obvervations;
data ccmq; set ccmq; 
	rename datadate = datadateq;
run; 
proc sort data = ccmq nodupkey;
	by permno datadateq;
run;
* 432,736 obvervations dropping duplicates;


* lagged rdq;
data ccmq; set ccmq;
	by permno;
	rdqlag = lag(rdq);
	datadateqlag = lag(datadateq);
	if first.permno then do;
		rdqlag = .;
		datadateqlag = .;
		* this step is necessary otherwise the result will be the difference between the first and the last obs;
	end;
	format rdqlag date9.;
	format datadateqlag date9.;
run;

* forward rdq;
proc sort data = ccmq;
	by permno descending datadateq;
run;

data ccmq; set ccmq;
	by permno;
	rdqF = lag(rdq);
	datadateqF = lag(datadateq);
	if first.permno then do;
		rdqF =.;
		datadateqF = .;
		* this step is necessary otherwise the result will be the difference between the first and the last obs;
	end;
	format rdqF date9.;
	format datadateqF date9.;
run;

proc sort data = ccmq;
	by permno datadateq;
run;






/* 1.3.2 delete firms with missing rdq */

* locate firms with missing rdq, variable misrdq = 1 if rdq is missing;

data ccmq; set ccmq;
	misrdq = missing(rdq);
run;

proc means data = ccmq noprint;
	var misrdq;
	class permno;
	output out = rdqmissing sum = TotalMissing;
run;
* proc means produces a row that indicates the total number of missing rdq and assign the row to a missing rdq;
* drop the summary row explained above;
data rdqmissing; set rdqmissing;
	if ~missing(permno);
run;

* delete firms with missing rdq;
proc sql; create table ccmq1 as
	select ccmq.*, rdqmissing.TotalMissing from ccmq inner join rdqmissing
	on ccmq.permno = rdqmissing.permno;
quit;
data ccmq1; set ccmq1;
	if TotalMissing > 0 then delete;
run;
* 319,268 observations;







/* 1.3.3 deal with missing quarter info */

* Some firms might have missing quarter information;
* For instance, it is possible that a firm only has 1st and 3rd quarter data in ccm, which implies that the two rdq dates
would be at least 180 days away;
* We do not want these firms because we do not know what happens to the missing quarters;
* For example, firm operation could be halted, firm might not report earnings, firm might change quarter end dates;
* Such events are mostly predictable and market reaction could happen at any point but has nothing to do with lack of disclosure;

data ccmq1; set ccmq1;
	 deltadatadate = datadateq - datadateqlag;
	 largedeltadatadate = deltadatadate >= 120;
run;

proc means data = ccmq1 noprint;
	var largedeltadatadate;
	class permno;
	output out = largedeltadatadatefirm sum = largedeltadatadatefirm;
run; 

proc sql;
	create table ccmq2 as
		select ccmq1.*, largedeltadatadatefirm.largedeltadatadatefirm from ccmq1 inner join largedeltadatadatefirm
		on ccmq1.permno = largedeltadatadatefirm.permno;
quit;

data ccmq2; set ccmq2;
	if largedeltadatadatefirm > 0 then delete;
run;

* from 319,268 to 310,422 observations;





/* 1.3.4 deal with earnings announcement dates that are too far away from fiscal quarter end date (120 days)*/
* Many firms announce earnings 3 months after the fiscal quarter end, particularly for the 4th quarter;
* e.g. permno = 10016 and datadateq = 31dec1993;
* If earnings announcement occurs more than 120 days after fiscal quarter end, then it is indicative of a pontential issue;
* We choose to delete the entire firm to be conservative and deletion does not result in great loss of observations (see below);

* compute the difference from the previous quarter end date and report the distribution;
 
data ccmq2; set ccmq2;
	deltardq = rdq - rdqlag;
	deltardqf = rdqF - rdq;
	deltardq1 = rdq - datadateq; *variable of interest is this one;
run;

* locate and delete firms with late rdq;

data ccmq2; set ccmq2;
	laterdq = deltardq1 >= 120;
run;
	
proc means data = ccmq2 noprint;
	class permno;
	var laterdq;
	output out = laterdqfirm sum = laterdqfirm;
run;

proc sql;
	create table ccmq3 as
		select ccmq2.*, laterdqfirm.laterdqfirm from ccmq2 inner join laterdqfirm
		on ccmq2.permno = laterdqfirm.permno;
quit;

data ccmq3; set ccmq3;
	if laterdqfirm > 0 then delete;
run;

* from 310,422 to 286,950 observations;






/* 1.3.5 deal with small and large interval between adjacent rdqs */

* adjacent rdq can have negative difference. possibly restatements;

data check; set ccmq3;
	if ( deltardq <=28 or deltardq >= 180) and ~missing(deltardq);
	* 4 weeks;
run;
* 333 observations;

* locate firms with small rdq difference, i.e. at least 4 weeks;
data ccmq3; set ccmq3;
	irregulardeltardq = ( deltardq <=28 or deltardq >= 180) & ~missing(deltardq);
run;

proc means data = ccmq3 noprint;
	var irregulardeltardq;
	class permno;
	output out = irregulardeltardqfirm sum=irregulardeltardqfirm;
run;

proc sql;
	create table ccmq4 as
		select ccmq3.*, irregulardeltardqfirm.irregulardeltardqfirm from ccmq3 inner join irregulardeltardqfirm
		on ccmq3.permno = irregulardeltardqfirm.permno;
quit;

data ccmq4; set ccmq4;
	if irregulardeltardqfirm > 0 then delete;
run;

* from 286,950 to 276,403;







/* 1.3.6 Merge with ibes guidance data using ccmq4: guidance announcement dates are assigned according to rqd dates */

* We proceed as follows:
For example, if a forecast is issued between 2006.02.03 (rdq for 2005.12.13) and 2006.04.15 
(rdq for 2006.3.31) (the first quarter), the date variable is assigned to be 2006.03.31, the first quarter. 
So guidance = 1 for date 2006.03.31 means that a forecast is issued between the rdq of 2005.12.31 and 
the rdq of 2006.12.31 (the first quarter); 
* Firms OFTEN issue guidance ON earnings announcement dates. We assign such guidance to the rdq date that the guidance
announcement is made for, e.g., 2006.04,15.
* We reduce rdqlag and rdq by one day to accomodate the possiblity of date entry errors, e.g., guidance date is on rdqlag but 
is entered as rdqlag - 1;


proc sql; create table guidedata as
	select ccmq4.*, cigpermno.* from ccmq4 left join cigpermno(drop = usfirm curr action act_std ticker)
	on ccmq4.permno = cigpermno.permno & ccmq4.rdqlag - 1 <= cigpermno.anndats < ccmq4.rdq - 1
	order by permno, datadateq;
quit;
* 573,046 observations, note this includes duplicate guidance decisions, because a quarter may have multiple guidance cases;

data guidedata; set guidedata;
	if missing( datadateqlag ) then delete;
run;

* Keep observations after 2002 when IBES Guidance is more comprehensive (Zhou (2015, JMP));
data guidedata; set guidedata(drop = TotalMissing deltadatadate largedeltadatadate largedeltadatadatefirm deltardqf deltardq1 laterdq laterdqfirm irregulardeltardq irregulardeltardqfirm);
	if datadateq > '31dec2002'D;
run;
* 555,773 observations;

proc delete data = ccmq ccmq1 ccmq2 ccmq3 ccmq4 check ibesguidanceid ibesid
largedeltadatadatefirm guide cigpermno laterdqfirm rdqmissing irregulardeltardqfirm (gennum = all); run;






/* 1.3.7 Create guide dummy */

* create guide dummy: guide = 1 if a forecast is issued, i.e. anndats is non-missing;

data guidedata; set guidedata;
	guide = 0;
	if anndats ~=. then guide = 1;
run;

proc export data = guidedata
	dbms = dta
	outfile = "&path/GUIDECCM20191216.dta"
replace;
run;
* 555,773 observations;











/*************************************************************************************/

* Step II: obtain daily stock return;

proc import 
	DATAFILE = "&path/GUIDECCM20191216.dta"
	out = guidedata1
	dbms=dta
	replace;
run;

proc sort data = guidedata1( keep = permno datadateq rdq rdqlag datadateqlag rdqF datadateqF) 
    out = crspdate nodupkey;
	by permno datadateq;
run;
* 251,745 obs;

data dsf; set rawdata.dsf02to17_20181016; run;

proc sql; 
	create table crspdateprice as
		select a.date, a.prc, a.ret, a.vol, a.shrout, a.cfacpr, a.cfacshr, a.numtrd, a.bid, a.ask, a.cusip, b.*
		from dsf a inner join crspdate b
		on a.permno = b.permno and a.date >= b.rdqlag-5 and a.date <= b.rdq + 90
		order by permno, datadateq, date;
quit;

proc export data=crspdateprice outfile= "&path/crspdateprice_bundled_20191216.dta" dbms=dta replace;
run;
