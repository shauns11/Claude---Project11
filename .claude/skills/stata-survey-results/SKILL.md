---
name: stata-survey-results
description: Report survey estimation results. Use when the user requests publication-ready tables in output files (e.g. txt).
---

# Reporting Survey Estimates

Report the design-based survey estimates produced by Stata in publication-ready tables. The Stata commands `etable` and `dtable` can be used to create tables of estimation results, which can then be exported to output files (e.g., txt) for reporting purposes. The `etable` command is used to report survey estimation results from commands such as `svy: mean`, and `svy: regress`. Output is exported to a text file for further use. After the first export, subsequent exports must be appended to the same file (`append`). The `dtable` command is used to report survey estimation results from commands such as `svy: tab`. The `etable` and `dtable` commands are relatively new and contain many options for customization. See the Stata documentation for more details. In this skill, we will keep the examples simple and focus on the workflow for reporting survey estimation results.

## Examples (continuous variable)

```stata
svy: mean income
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f)) cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", replace)
svy: mean income, over(sex)
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)
```
## Examples (categorical variable)

```stata
*one-way tabulate 
dtable, svy factor(bmivg52) export("./output/results.txt", append)
*two-way tabulate 
dtable, svy factor(bmivg52) by(sex) export("./output/results.txt", append)
```
## Examples (regression)

```stata
svy: regress income c.age i.sex
etable, cstat(_r_b, nformat(%7.2f)) cstat(_r_ci, nformat(%7.2f)) cstat(_r_se, nformat(%7.2f)) export("./output/results.txt", append)
```



 










