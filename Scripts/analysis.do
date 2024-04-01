/*
Author: Sam Lee
03.31.2024

This script performs an econometric analysis to identify the causal effect that electing more women in African and Arab countries has on CO2 emissions per capita
*/

do Scripts/DataWrangle.do

//Format it into panel data
sort countrycode year
egen countryid = group(countrycode)
xtset countryid year

//Create lags
local lag_vars womenrep gdp population gdppercapita z
foreach var of local lag_vars {
	gen `var'_lag = L.`var'
}

//Create dummies for countries and year
xi i.countrycode i.year, noomit
drop _Icountryco_1
drop _Icountryco_2
forvalues i = 1985/1998 {
	drop _Iyear_`i'
}
drop if womenrep_lag == .

//Two-stage diff-in-diff regression
ivregress 2sls co2 gdppercapita_lag _Iyear* _Icountry* (womenrep_lag=z_lag), cluster(countryid)

//Save results to a latex table
//ssc install estout
esttab using "regression_results.tex", replace ci

//Two-stage diff-in-diff (Asymptotic Normality Variance Matrix needs to be adjusted--i.e. standard errors are underestimated)
// reg womenrep_lag z_lag gdp_lag population_lag _Iyear* _Icountry*, cluster(countryid)
// predict wtilde
// reg co2 wtilde gdp_lag population_lag _Iyear* _Icountry*, cluster(countryid)