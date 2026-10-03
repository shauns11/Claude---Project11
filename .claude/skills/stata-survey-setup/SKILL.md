---
name: stata-survey-setup
description: Set up a Stata dataset (.dta) for design-based estimation (complex surveys). Use this specific skill when the user needs to identify or specify survey/sampling weights, primary sampling units (PSUs), strata, to construct an appropriate `svyset` command before estimating survey statistics such as mean, tabulate and regress. The data to be analysed is from cross-sectional nationally-representative health examination surveys such as the Health Survey for England (HSE) and the US National Health and Nutrition Examination Survey (NHANES), and the NHANES weight variable should be confirmed for the analytic subsample.
---

# Stata Survey Setup

After opening the dataset in Stata, help users to correctly specify the survey design before performing design-based estimation.

## Core principle

Always distinguish between:

•	survey/sampling weights
•	primary sampling units (PSUs or clusters)
•	strata

Do not assume that a variable in the dataset is sampling weight, PSU, or strata merely because of its name alone. Use name patterns only as candidates and require explicit confirmation before finalizing roles.

## Workflow

### Step 1: Identify the survey design variables

Ask for or inspect:

•	sampling weight variable
•	PSU variable
•	stratum variable

The user must explicitly confirm which variable serves each role. If unsure, ask the user to run `describe` and share the variable names and Stata variable labels so roles can be verified.

- In the HSE, common candidates are: (1) sampling weight (`wt_int` or `wt_nurse` or `wt_blood` depending on analytic subsample), (2) PSU (often `psu`), and (3) strata (often `strata`), but still confirm each role with the user.

- In NHANES, common design variables are typically: (1) sampling weight (e.g., `WTMEC2YR` or `WTINT2YR` depending on subsample), (2) PSU (`SDMVPSU`), and (3) strata (`SDMVSTRA`). Always confirm with the user which weight variable is appropriate for the analytic subsample.

### Step 2: Check the variables

Before writing `svyset`, check that the variables exist in the dataset:

```stata
describe wt_int psu strata 
summarize wt_int
```

Replace variable names with the actual variables identified in Step 1.

Look for:
•	missing sampling weights
•	zero or negative sampling weights

Do not silently repair a problematic survey design. In the HSE, observations will have missing `wt_nurse` or `wt_blood` if the participant did not attend the nurse visit or blood sample. In NHANES, observations will have missing `WTMEC2YR` if the participant did not attend the mobile examination center (MEC). If any of these issues are present, explain to the user that the survey design is incomplete and that variance estimates may be affected.

### Step 3: Construct svyset

Typical examples:

```stata
svyset psu [pweight=wt_int], strata(strata)
svyset psu [pweight=wt_nurse], strata(strata)
svyset psu [pweight=wt_blood], strata(strata)
svyset SDMVPSU [pweight=WTMEC2YR], strata(SDMVSTRA)
```
### Step 4: Verify the sampling design

After svyset, run this command to report the current settings:

```stata
svyset
```

Then perform a basic check:

```stata
svy: mean some_variable
```

# Important rules

•	Never treat survey weights as ordinary frequency weights. These are not equivalent. Correct weight is `pweight` in `svyset`.
•	Never invent a PSU or stratum variable.
•	If no PSU variable is available (e.g., suppressed in a public-use file), explain that PSU information is missing and variance estimates will be affected. Show the fallback `svyset [pweight=<weight_variable>], strata(strata)` and warn that standard errors may be underestimated.
•	Never drop observations with missing survey-design variables without explaining the consequence.
•	If the survey design is unclear, state what information is missing.


# Output style

When the survey design is sufficiently known, provide:

•	the svyset command
•	a short explanation of each component
•	basic diagnostic commands
•	any assumptions or unresolved design issues

Examples:

```stata
svyset psu [pweight=wt_int], strata(strata)
svyset SDMVPSU [pweight=WTMEC2YR], strata(SDMVSTRA)
```
Explain:

•	psu = PSU
•	wt_int = sampling weight
•	strata = sampling stratum

Do not claim that estimates are valid until the survey design has been adequately identified.

# Analytic subsample weights

When the user is analyzing a subsample of the survey (e.g., only participants who attended a nurse visit or provided a blood sample), confirm that the correct weight variable is used for that subsample. For example, in HSE, use `wt_nurse` for analyses restricted to the nurse visit subsample and `wt_blood` for analyses restricted to the blood sample subsample. In NHANES, use `WTMEC2YR` for analyses of participants who attended the mobile examination center.


Examples:

```stata
svyset, clear
svyset psu [pweight=wt_nurse], strata(strata)
```


 










