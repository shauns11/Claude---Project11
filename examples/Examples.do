/*===========================================================================================================
    Project:    Survey_estimation
    Author:     Shaun Scholes
    Date:       August 2026
    Purpose:    Examples of survey_estimation in Stata
    Input:      Survey_data
    Output:     Estimates
	Location:   "C:/CLAUDE/Projects/Project11/examples/Examples.do"
	============================================================================================================*/

*set working directory.

cd "C:/CLAUDE/Projects/Project11/"
	
*open a log file in output folder
log using "./output/results.log", replace

*load survey_data:
use "./data/survey_data.dta", clear

*confirm variables exists before proceeding:
describe income wealth sex wt_int psu strata bmi bmivg52 employed

*set negative values on all variables to missing
mvdecode _all,mv(-9/-1)
misstable summarize

*'svyset' the data:
svyset [pw=wt_int],psu(psu) strata(strata)
svydes
svydes, single

*===========================
*estimate survey statistics:
*mean for continuous variables.
*tabulate for categorical variables.
*regress for regression
*============================

*mean income
svy:mean income
*publish the output using `etable`' and save in a .txt file
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", replace)

*mean wealth: 
svy:mean wealth
*publish the output
etable, cstat(_r_b,nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)

*ratio
svy:ratio income/wealth
etable, cstat(_r_b,nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)

*===================================
*Domain estimation using svy subpop
*===================================

*mean wealth: 
svy,subpop(employed):mean wealth

*===========================
*Estimation for groups 
*============================

*estimate mean income separately by sex
svy:mean income,over(sex)
*publish the output 
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)

*categorical variable (bmi status)
svy: tab bmivg52                                  // one-way tabulate
svy: tab bmivg52 sex, column percent ci           // two-way tabulate
di "Pearson p-value = " %9.3f e(p_Pear)           // p-value for test of association

*publish output of one-way tabulate using the dtable command 
dtable, svy factor(bmivg52) export("./output/results.txt", append)
*publish output of two-way tabulate using the dtable command 
dtable, svy factor(bmivg52) by(sex) export("./output/results.txt", append)
	 
*perform svy regression to examine sex differences in income after adjustment for age
svy:regress income i.sex c.age
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)
test 1.sex
lincom 1.sex


*Domain estimation: regression
svy, subpop(if employed == 1): regress income c.age c.bmi

 
*===================================
*Nurse visit
*===================================

svyset, clear
svyset [pw=wt_nurse],psu(psu) strata(strata)
svydes
svydes, single

*mean SBP 
svy:mean omsysval
etable, cstat(_r_b,nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)
svy:mean omsysval,over(sex)
etable, cstat(_r_b,nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f))  cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)

*Capture date and time, display them, then close the log file.

local date `c(current_date)'
local time `c(current_time)'
display _newline "Run `date' at `time'"

log close















