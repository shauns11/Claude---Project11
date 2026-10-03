/*===========================================================================================================
    Project:    Survey_estimation
    Author:     Shaun Scholes
    Date:       October 2026
    Purpose:    Mean systolic blood pressure (omsysval) for men and women
    Input:      Survey_data
    Output:     Estimates (results.log, results.txt)
	Location:   "C:/CLAUDE/Projects/Project11/code/results.do"
	============================================================================================================*/

*set working directory.
cd "C:/CLAUDE/Projects/Project11/"

*open a log file in output folder
capture log close
log using "./output/results.log", replace

*load survey_data:
use "./data/survey_data.dta", clear

*confirm variables exist before proceeding (design variables, outcome and group):
describe wt_nurse psu strata omsysval sex
summarize wt_nurse psu strata omsysval
tab sex, missing

*set negative values on all variables to missing
mvdecode _all, mv(-9/-1)
misstable summarize

*check nurse weight after recoding (missing = did not attend nurse visit / invalid)
summarize wt_nurse
count if missing(wt_nurse)
count if wt_nurse <= 0 & !missing(wt_nurse)
count if missing(omsysval)
count if missing(omsysval) & !missing(wt_nurse)

*===================================
*Nurse visit: svyset with wt_nurse
*===================================

svyset, clear
svyset psu [pweight=wt_nurse], strata(strata)
svyset
svydes
svydes, single

*mean SBP (overall)
svy: mean omsysval
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f)) cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", replace)

*mean SBP separately for men and women
svy: mean omsysval, over(sex)
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f)) cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)

*test of difference between men and women
test _b[c.omsysval@0bn.sex] = _b[c.omsysval@1.sex]
lincom _b[c.omsysval@1.sex] - _b[c.omsysval@0bn.sex]

*Capture date and time, display them, then close the log file.
local date `c(current_date)'
local time `c(current_time)'
display _newline "Run `date' at `time'"

log close
