/*===========================================================================================================
    Project:    Survey_estimation
    Author:     Shaun Scholes
    Date:       August 2026
    Purpose:    Creation of a complex survey dataset
    Input:      Simulated data
    Output:     Dataset
	Location:   "C:/CLAUDE/Projects/Project11/code/dataset_creation.do"
	============================================================================================================*/
	
cd "C:/CLAUDE/Projects/Project11/data"

clear
set obs 2000
set seed 12345
gen id=_n

* Survey design variables
gen psu = ceil(_n/10)                 // Primary sampling units
gen strata = mod(psu, 5) + 1          // 5 strata
gen wt_int = runiform(0.5, 2.5)        // Sampling weights
gen wt_nurse = runiform(0.5, 2.5)        // Sampling weights

* Demographic variables
gen sex = (runiform() > 0.5)           // 0 = female, 1 = male
label define sexlbl 0 "Female" 1 "Male"
label values sex sexlbl

gen age = round(runiform(18, 65))

* Positive outcome variable (e.g., income, expenditure, exposure)
gen income = exp(rnormal(8, 0.6))      // log-normal distribution
gen wealth = exp(rnormal(8, 0.6))      // log-normal distribution

* Height in centimetres: mean 170 cm, SD 10 cm
generate height_cm = rnormal(170, 10)

* Weight in kilograms: mean 70 kg, SD 15 kg
generate weight_kg = rnormal(70, 15)

* Convert height to metres
generate height_m = height_cm / 100

* Calculate BMI
generate bmi = weight_kg / (height_m^2)

label variable income "Monthly income"
label variable wealth "Household wealth"
label variable wt_int "Survey weight"
label variable psu "Primary sampling unit"
label variable strata "Stratum"

replace income = -8 if _n==1
replace income = -1 if _n==2
replace wealth = -8 if _n==1
replace wealth = -1 if _n==2
replace bmi = -8 if _n<10

gen bmivg52=-2
replace bmivg52=1 if inrange(bmi,0.02,18.499)
replace bmivg52=2 if inrange(bmi,18.5,24.999)
replace bmivg52=3 if inrange(bmi,25,29.999)
replace bmivg52=4 if inrange(bmi,30,109.999)
label define bmivg52lbl 1 "underweight" 2 "normal weight" 3 "overweight" 4 "obese"
label values bmivg52 bmivg52lbl
tab1 bmivg52

gen employed = (runiform() > 0.7)   
gen smoker = (runiform() > 0.1)          


generate omsysval = rnormal(130, 15)
replace omsysval = -8 if _n<15

generate omdiaval = rnormal(90, 10)
replace omdiaval = -8 if _n<15

replace wt_nurse = -1 if _n<15
replace smoker = -8 if _n<5

gen male=sex==1
gen female=sex==0
tab male female

summ income
svyset [pw=wt_int],psu(psu) strata(strata)
keep id psu strata wt_int sex age income wealth bmi bmivg52 employed omsysval omdiaval wt_nurse male female smoker
save "./survey_data.dta", replace
























