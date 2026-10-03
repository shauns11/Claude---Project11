---
name: references
description: this references file contains a compact reference for conducting survey estimation using Stata rather than putting every command into SKILL.md
---

This reference supports the stata-survey-estimation skill. It is intended for simple design-based survey estimation in Stata using the `svy` commands.

1. Core principle

Use Stata's survey (`svy`) commands when estimating population quantities from complex survey samples such as 
the Health Survey for England (HSE) and the US National Health and Nutrition Examination Survey (NHANES).

A survey design can involve the following characteristics (represented by variables):
•	survey/sampling weights (probability weights: pw)
•	primary sampling units (PSUs)
•	strata

The `svy` framework uses this design information to produce design-based point estimates and variance 
estimates (SEs and confidence intervals). Do not treat a sampling weight as sufficient information about 
the survey design. Clustering (nesting of participants within PSUs) is very important for variance estimation.
________________________________________
2. Inspect the data before estimation

Survey datasets contain missing data. E.g., not all participants may have taken part in the nurse visit or 
blood sample collection. Set all negative values (-9 to -1) on the variables (reflecting refusals, don’t knows or 
not applicables) to missing using the `mvdecode` command. Use the following command:

```stata
	mvdecode _all,mv(-9/-1)
```
Inspect candidate survey-design variables:
```stata
desc wt_int psu strata
```
Do not delete observations with missing survey-design variables. 
________________________________________
3. Specify the survey design with svyset:
```stata
svyset psu [pweight=wt_int], strata(strata)
svyset psu [pweight=wt_nurse], strata(strata)
```
Verify the design:
```stata
svyset
```
________________________________________
4. Sampling weights
Use sampling weights as pweight:
svyset psu [pweight=wt_int], strata(strata)

Do not substitute:
summarize income [fw=wt_int]
or:
summarize income [aw=wt_int]
for design-based survey estimation.

Likewise, this:
summarize income [pw=wt_int]
does not generally reproduce the variance estimates from:
svy: mean income
when the sample has clustering or stratification. Survey commands must use the `svy` prefix.
________________________________________
5. Basic means
Estimate a population mean:
svy: mean income
The output typically provides:
•	estimated mean
•	standard error
•	95% confidence interval
•	survey design information (e.g., unweighted and weighted sample sizes)
The mean is a population estimate under the specified sampling design, not simply the unweighted sample mean.

For subgroup estimation:
svy: mean income,over(sex)
This estimates the mean income separately for men and women.

For domain estimation:
svy,subpop(employed): mean income
Equivalently:
svy,subpop(if employed==1): mean income

This estimates the mean income only for those currently in employment.

________________________________________
6. Proportions
For a binary indicator coded 0/1:
svy: mean employed
If employed equals 1 for employed people and 0 otherwise, the estimated mean is the estimated 
population proportion employed.

________________________________________
7. Categorical variables
For categorical variables use tabulate:
svy: tab education

For examining the distribution of educational status separately by sex:
svy: tab education sex, column perc

This command will estimate the percentage of males with high educational status and the percentage of females 
with high educational status.

________________________________________
8. Totals
A total is fundamentally different from a mean or proportion.
For example:
•	mean income = average population income
•	proportion employed = population share employed
•	total income = estimated aggregate population income

________________________________________
9. Ratios
Stata can estimate ratios using:
svy: ratio numerator/denominator
For example:
svy: ratio expenditure/income
The numerator and denominator should correspond to the quantities for which the ratio is substantively meaningful.
For example, this ratio represents the proportion of income that is spent. If the ratio is 0.5, then 
half of income is spent.

________________________________________
10. Domain estimation using `subpop`

For survey data, distinguish domain estimation from physically restricting the sample (using if command).
Preferred approach:
svy, subpop(if employed == 1): mean income
This estimates the mean income for those in employment while retaining the full survey 
design for variance estimation. Avoid replacing it mechanically with:
preserve
keep if employed == 1
svy: mean income
restore

Why subpop() matters:
Variance estimation for a domain can depend on observations outside the domain 
(e.g., those not currently employed) because the original survey design determines the variance estimator.

# Estimation for groups
Rather than use subpop(), estimate the mean income separately for males and females using the `over` 
option. `over` can not be used for regression. Use the `subpop` option to run a regression separately for males and females:

svy, subpop(if female == 1): regress income c.age c.bmi
svy, subpop(if male == 1): regress income c.age c.bmi


______________________________________________
11. Estimates by groups

For estimates by categories:
svy: mean income, over(region)
For a binary group:
svy: mean income, over(sex)
For proportions by group, an indicator can be used:
svy: mean employed, over(region)

For two-categorical variables use two-way tabulate:
svy: tab education sex, column perc

In this example we want to compare the percentage of men and women with high educational status. 
Therefore we specify the outcome variable first (education); the group variable second (sex), and request 
column percentages.

When the objective is to formally test differences, use a design-based hypothesis test rather 
than comparing confidence intervals visually.
________________________________________
12. Survey regression

Simple survey-weighted regression:
svy: regress income age i.female i.region

Categorical predictors should generally be specified using factor-variable notation. The default is 
that the lowest category is the reference.

svy: regress outcome i.education i.region age
Do not interpret regression coefficients causally.
________________________________________
13. Testing differences

For a regression coefficient:
svy: regress outcome i.group

To test a group coefficient use `test`:
test 1.group
For linear combinations use `lincom`:
lincom 1.group

For differences between estimated quantities, formulate the appropriate contrast using `lincom` 
rather than comparing whether two confidence intervals overlap. 
A non-overlap/overlap check is not a substitute for a formal statistical test.
________________________________________
14. Confidence intervals

Stata's survey commands report design-based standard errors and confidence intervals.
For example:
svy: mean income
Interpret a 95% confidence interval as an interval produced by the specified survey variance estimator.
Preferred wording:
The estimated population mean was 25,400, with a 95% confidence interval of 24,100 to 26,700.

________________________________________
14. Survey degrees of freedom
Survey inference often depends on the number of PSUs and strata, rather than simply the number of observations.
Pay attention to output showing:
•	number of observations
•	number of PSUs
•	number of strata
•	design degrees of freedom
A very large sample size does not necessarily imply highly precise survey estimates if the design has 
few PSUs or substantial clustering.
________________________________________
15. Singleton strata
Stata may report a problem when a stratum contains only one sampled PSU. Variance estimation requires at 
least two PSUs per stratum.
Do not automatically suppress or ignore the problem.
First determine whether:
•	the survey genuinely has singleton strata using `svydes, single`

Possible treatments depend on the survey design and the intended variance estimator.
Never choose a singleton-stratum adjustment solely to make Stata run.

________________________________________
16. Common survey commands
Mean:
svy: mean varlist
Proportion (0/1):
svy: mean varlist
Total:
svy: total varlist
Ratio:
svy: ratio numerator/denominator
Regression:
svy: regress y x1 x2 i.group
Tabulation:
svy: tabulate outcome group, column perc

When producing percentages, specify column percentage as options.
Do not assume the default is the desired statistic.
________________________________________
17. over() versus subpop()
Use over() when the objective is to display estimates separately by categories.
Example:
svy: mean income, over(region)

Use subpop() when the objective is a domain estimate:
svy, subpop(if employed == 1): mean income
svy, subpop(if employed == 1): regress income i.sex

If the user wants estimates for every region, over(region) is often convenient.
If the user wants a specific domain estimate (e.g., test for sex differences in income in region 1) with 
the full survey design retained for variance estimation, subpop() is generally appropriate. 
When using the `subpop` option note that 1 = the domain of interest.
________________________________________
18. Missing values
In this repository missing data (e.g., refusals, don't knows and not applicables) are represented by 
negative values on the variables (-9 to -1). Inspect variables before estimation. 
Code all negative values as missing using the `mvdecode` command.

________________________________________
19. Indicator variables
For a binary outcome:
generate employed = employment_status == 1 if !missing(employment_status)
Then:
svy: mean employed
The estimated mean of the indicator is the estimated population proportion satisfying the condition.

________________________________________
20. Population restrictions
There is an important distinction between:
svy, subpop(if age >= 18): mean employed
and estimating on a dataset that has already been restricted to adults.

In practice we will perform survey estimation only on datasets that have been restricted to adults. 
________________________________________
21. Weighted versus unweighted statistics
Always distinguish between:
summarize income
and:
svy: mean income

The first describes the unweighted sample.
The second estimates a population quantity under the survey design.

If the survey has sampling weights, report clearly whether an N is:
•	unweighted sample size
•	weighted sample size

E.g., using `svy: mean`, the "Number of obs" refers to the unweighted sample size of the analytical 
sample size. The "Population size" refers to the weighted size of the analytical sample. 
________________________________________
22. Effective sample size
A complex survey can contain many observations while providing substantially less statistical information 
than a simple random sample of the same size. Unequal weights and clustering can reduce effective precision.
Do not calculate an effective sample size and then substitute it for the survey design in Stata.
Use the survey design for estimation and use effective sample size only as a supplementary 
descriptive concept when appropriate.

________________________________________
23. Diagnostics before reporting results
A minimal workflow is:
describe
summarize
misstable summarize
svyset
svy: mean outcome
For a domain:
svy, subpop(if domain == 1): mean outcome
For group comparisons:
svy: mean outcome, over(group)
Then perform a formal test (e.g. using `lincom`) if the research question requires one.
________________________________________
24. Reproducible workflow
A recommended analysis do-file should follow this order:

* 1. Open log file
* 2. Set the working directory.
* 3. Load data
use "survey_data.dta", clear
* 4. Inspect variables
describe
* 5. Missing data
mvdecode _all,mv(-9/-1)
* 6. Inspect survey-design variables
summarize wt_int psu strata
* 7. Specify survey design
svyset psu [pweight=wt_int], strata(strata)
* 8. Verify survey design
svyset
* 9. Estimate main outcomes
svy: mean outcome
svy: tabulate category
svy: total population_variable
svy: ratio numerator/denominator
* 10. Estimate domains
svy, subpop(if eligible == 1): mean outcome
* 11. Estimate group-specific results
svy: mean outcome, over(group)
svy: tabulate category group, column perc
* 12. Formal comparison if required
svy: regress outcome i.group
test 1.group
lincom 1.group
Adapt every variable and design specification to the actual survey documentation.

________________________________________
25. Common errors to avoid

Error: treating sampling weights as frequency weights
Incorrect for design-based inference:
summarize income [fw=weight]
Preferred:
svy: mean income
after correctly specifying `svyset`.

Error: ignoring the PSU
If the survey used clustered sampling, specifying only the weight can underestimate uncertainty.

Error: using if instead of subpop()
For a survey domain estimate, prefer:
svy, subpop(if condition==1): mean outcome
rather than physically dropping the rest of the sample using if qualifier.

Error: inventing design variables
Never infer that a variable is a PSU or stratum merely because its name contains cluster, region, area, or strata.

Error: treating weighted estimates as causal
Survey weighting addresses aspects of the sampling design. It does not automatically eliminate:
•	nonresponse bias
•	measurement error
•	coverage error
•	confounding
•	model misspecification

________________________________________
26. Interpretation template
When interpreting a simple estimate, use:

Estimate
State the population quantity being estimated.

Precision
Report the standard error and/or confidence interval.

Design
Mention that the estimate accounts for the survey design when it was produced using `svy`.

Substantive interpretation
Translate the numerical estimate into the units of the research question.

Example:
The estimated proportion of adults who were employed was 72.4% (95% CI: 70.8%–74.0%). The estimate and 
confidence interval account for the survey's specified sampling weights, clustering, and stratification. 
This is a descriptive population estimate and should not be interpreted as a causal effect.
________________________________________
27. Decision rules for Claude

When a user asks for a simple survey estimate:
1.	Determine the target quantity: mean, total, distribution, ratio, subgroup estimate, regression coefficients.
2.	Determine whether svyset has already been specified.
3.	If not, identify the required survey-design variables.
4.	Use svy: estimation, not manually weighted calculations.
5.	Use subpop() for survey domain estimation.
6.	Preserve the survey design when estimating subgroup quantities.
7.	Report the point estimate and uncertainty.
8.	Do not fabricate missing design information.
9.	Do not silently alter weights or recode special missing values.
10.	Flag uncertainty about the survey design before presenting results as definitive.
30. Minimal command reference

Task	                           Stata
Specify survey design	           svyset psu [pweight=<wt_name>], strata(strata)
Display design	                   svyset
Survey mean	                       svy: mean y
Survey proportion	               svy: mean x
Survey total	                   svy: total y
Survey ratio	                   svy: ratio y/x
Mean by group	                   svy: mean y, over(group)
Domain mean	                       svy, subpop(if condition==1): mean y
Survey regression	               svy: regress y x1 x2
Linear contrast	                   lincom ...
Hypothesis test	                   test ...
Inspect missingness	               misstable summarize

31. Final safety check
Before reporting the task as complete, verify:
•	Is the survey design known?
•	Are missing codes handled correctly?
•	Is the requested quantity a mean, distribution for a categorical variable, total, ratio, 
regression coefficient, or comparison using formal tests?
•	Does the proposed command produce design-based uncertainty (95% confidence intervals)?
•	Are the interpretation and units clear?

If any essential design information is unknown, say so explicitly rather than guessing.









