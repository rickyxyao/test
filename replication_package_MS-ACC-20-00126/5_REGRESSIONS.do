set more off
local regtype "reg"
local options "robust cluster(gvkey)"
local tableoptions "excel dec(3) tstat bdec(3) tdec(3) rdec(3) adec(5) alpha(.01, .05, .1) addstat(Adj. R-squared, e(r2_a))"

**** 10-K SAMPLE ****

clear

import sas using "\path\to\finaldata_10k.sas7bdat"

local controls "ln_mve btm turnover pre_alpha instown nasdaq"

**** RUN 10-K REGRESSIONS FOR <= 2008 ****

`regtype' car01 tone `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' replace

`regtype' car01 tone_pos `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_neg `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_harvard `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_posharvard `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_negharvard `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 rfpred_car01 `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 svrpred_car01 `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 sldapred_car01 `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 factorpred_car01 `controls' if year <= 2008, `options'
outreg2 using TABLE_10K_PRE, ctitle(CAR[0 1]) `tableoptions' append

**** RUN REGRESSIONS FOR FULL SAMPLE ****

`regtype' car01 tone `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' replace

`regtype' car01 tone_pos `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_neg `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_harvard `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_posharvard `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_negharvard `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 rfpred_car01 `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 svrpred_car01 `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 sldapred_car01 `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 factorpred_car01 `controls', `options'
outreg2 using TABLE_10K_FULL, ctitle(CAR[0 1]) `tableoptions' append
adfadsf

**** CONFERENCE CALL SAMPLE ****

clear

import sas using "\path\to\finaldata_cc.sas7bdat"

local controls "earnsurp ln_mve btm turnover pre_alpha instown nasdaq"

`regtype' car01 tone `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' replace

`regtype' car01 tone_pos `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_neg `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_harvard `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_posharvard `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 tone_negharvard `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 rfpred_car01 `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 svrpred_car01 `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 sldapred_car01 `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append

`regtype' car01 factorpred_car01 `controls', `options'
outreg2 using table_CC, ctitle(CAR[0 1]) `tableoptions' append


