/*
Author: Sam Lee
03.31.2024

This script performs an econometric analysis to identify the local average treatment effect that electing more women in African and Arab countries has on CO2 emissions per capita
*/

cd "C:\Users\slee039\Box\ECON 398\Final Project"

//clean and load in the data for analysis
do Scripts/DataWrangle.do

gen lgdp = ln(gdp)
gen lpopulation = ln(population)

//Format it into panel data
sort countrycode year
egen countryid = group(countrycode)
xtset countryid year

//Create lags
local lag_vars womenrep z
foreach var of local lag_vars {
	gen `var'_lag = L.`var'
}

//Create covariate X matrix
local lag_effect = 5
foreach var of varlist lgdp lpopulation {
    forvalues p = 2/`lag_effect' {
        gen `var'`p'_lag = L`p'.`var'
    }
	drop `var'
}
//Drop missing values
 forvalues p = 2/`lag_effect' {
	drop if lgdp`p'_lag == .
	drop if lpopulation`p'_lag == .
 }

drop if womenrep_lag == .

//Create dummies for countries and year
xi i.countrycode i.year, noomit

//Drop Qatar and Iraq, and 1998 year dummies due to colinearity
drop _Icountryco_46 _Icountryco_27 _Iyear_1998

//Save data for analysis
save Data/regression_matrix.dta, replace

//First stage to show relevance
reg womenrep_lag z_lag lgdp* lpopulation* _Iyear* _Icountry*

//Two-stage diff-in-diff regression (Main regression to derive delta)
ivregress 2sls co2 lgdp* lpopulation* _Iyear* _Icountry* (womenrep_lag=z_lag)

//Save results to a latex table
ssc install estout
esttab using "regression_results_raw.tex", replace ci

sort countryid
gen rsamp = floor(_N * runiform())+1
gen cl_bootstrap = co2[rsamp]
drop rsamp

//placebo regression
ivregress 2sls cl_bootstrap lgdp* lpopulation* _Iyear* _Icountry* (womenrep_lag=z_lag)

/*one way CV1 and CV3 */
adopath + "C:\Users\slee039\Box\ECON 398\Final Project\Resources\MNW-guide-replic-do-files"

summclust womenrep_lag, yvar(co2) xvar(lgdp* lpopulation*) fevar(_Iyear* _Icountry*) ///
 cluster(countryid) rho(0.5) jack 

//Run placebo test
do Scripts/placebo.do