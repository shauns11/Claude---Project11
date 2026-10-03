---
name: stata-survey-estimation
description: Perform simple design-based survey estimation in Stata using `svy` commands. Use for weighted means, proportions, frequencies, two-way distributions, totals, confidence intervals, standard errors, and simple subgroup estimates from complex survey samples. Use after survey design variables (sampling weight, PSU, and strata) have been identified and svyset has been specified.
---

# Survey Estimation in Stata

Only use Stata's survey commands (`svy` commands) for estimation of survey statistics. The `svy` commands account for the survey design in variance estimation. Do not manually calculate a conventional standard error using only the sampling weights.

## Prerequisite

Before performing estimation, confirm that the sampling design has been specified with `svyset`

Check with:

```stata
svyset
```

If the sampling design is not specified, use the stata-survey-setup workflow first.

### Missing values

Set all negative values on the variables (reflecting refusals, don’t knows or not applicables) to missing using the `mvdecode` command. Use the following command:

```stata
mvdecode _all,mv(-9/-1)
```

Observations with missing data will then be correctly excluded from the estimation: e.g, the mean income will be estimated using only observations with non-missing income values (including zeros).

### Basic estimates

For a continuous variable estimate the mean:

```stata
svy: mean income
```

For a binary indicator coded 0/1 also estimate the mean. The mean of a 0/1 variable is the estimated proportion.

```stata
svy: mean binary_variable
```

For a categorical variable (such as continuous bmi grouped into categories) use one-way tabulate:

```stata
svy: tab categorical_variable
```

Use total when the user wants a population total rather than a population mean

```stata
svy: total income
```

### Confidence intervals

Stata's survey commands report:
•	point estimate
•	standard error
•	95% confidence interval

Do not manually calculate a conventional standard error using only the sampling weights.
Survey standard errors must account for the specified survey design. The purpose of `svy` is to account for the survey design in variance estimation.

### Estimation for subgroups

The user may request reporting the mean of a continuous variable separately for different groups (e.g. mean income separately for males and females). For subgroup estimation, use the `over` option. 
Never use the if qualifier when using Stata's `svy` commands.

Example:
```stata
svy: mean income, over(sex)
svy: mean income, over(region)
```
For a categorical variable use two-way tabulate to report the distribution of a categorical variable for different groups. E.g., to report the distribution of a categorical variable (e.g. bmi categories) for males and females, use the following:

```stata
svy: tab categorical_variable sex, column perc
```
For regression-style analysis use the regress command

```stata
svy: regress income i.female c.age
```
For post-estimation tests using lincom, use the following:

```stata
svy: regress income i.female c.age
test 1.sex
lincom 1.sex
```

### Domain estimation

To estimate the mean income only for those currently employed, use the `subpop` option. Never use the if qualifier when using Stata's `svy` commands.
```stata
svy, subpop(employed): mean income
```
The variable specified in the `subpop()` option must be a 0/1 indicator variable. The subpopulation is defined as those observations with a value of 1 on that variable.

### Estimation for those who attended a nurse visit or provided a blood sample

When the user is analyzing a subsample of the survey (e.g., only participants who attended a nurse visit or provided a blood sample), confirm that the correct weight variable is used for that subsample. In Health Survey for England (HSE) analysis, use `wt_nurse` for analyses restricted to the nurse visit subsample and `wt_blood` for analyses restricted to the blood sample subsample. In NHANES, use `WTMEC2YR` for analyses of participants who attended the mobile examination center (MEC). For now, we are just using survey estimation for a dataset set up similar to the HSE.


Example:
```stata
svyset, clear
svyset psu [pweight=wt_nurse], strata(strata)
svy: mean omsysval
```














