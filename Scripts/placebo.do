/*
Author: Sam Lee
04.05.2024

This script estimates the effect that women in national legislature have on the frequency of natural disasters within a country. While there is evidence from the IPCC, that the frequency (and intensity) of natural disasters are increasing over time due to the externalities of climate change, with year fixed effects, this should partial out the effect that women in national legislature have on the frequency.

I employ a two-stage least squares regression, after partialling out fixed effects, to estimate the effect on delta using the number of natural disasters per year within a country as a placebo.

Theoretically, with this as a placebo, there should be a very weak/zero effect. I provide this as evidence that my results are significant.
*/

//Set working directory
cd "C:\Users\slee039\Box\ECON 398\Final Project"

use Data/womenrep.dta, clear

gen lgdp = ln(gdp)
gen lpopulation = ln(population)

//Format it into panel data
sort countrycode year
egen countryid = group(countrycode)
xtset countryid year

//Create covariate X matrix
local lag_effect = 5
foreach var of varlist lgdp lpopulation {
    forvalues p = 2/`lag_effect' {
        gen `var'`p'_lag = L`p'.`var'
    }
	drop `var'
}

local lag_vars womenrep z
foreach var of local lag_vars {
	gen `var'_lag = L.`var'
}

keep if year >= 1997

merge m:1 countrycode year using Data/disasters.dta

//These are the countries in that aren't in our sample (Saudi Arabia, UAE)
drop if _merge == 2
drop _merge

//If no events were recorded for that country during that year, then (an estimated) 0 natural disasters happened during that year for that country
replace n_disasters = cond(n_disasters == ., 0, n_disasters)

//Create dummies for countries and year
xi i.countrycode i.year, noomit
drop _Icountryco_46 _Icountryco_27 _Iyear_1997 _Iyear_1998

//Save regression matrix
save Data/disasters_regression_matrix.dta, replace

//Two-stage regression on placebo (poisson-distributed)
qui ivregress 2sls n_disasters lgdp* lpopulation* _I* (womenrep_lag=z_lag), cluster(countryid)

//Partial out regressor and regressand
qui reg n_disasters _I* if e(sample)
qui predict ytilde, res

local covariates lgdp* lpopulation*
foreach xvar of varlist `covariates' {
	qui reg `xvar' _I* if e(sample)
	qui predict xtilde_`xvar', res
}

//Partial out treatment variable and instrument
foreach var of varlist womenrep_lag z_lag {
	qui reg `var' _I* if e(sample)
	qui predict `var'_tilde, res
}

//Placebo regression on partialled-out placebo
ivregress 2sls ytilde xtilde* (womenrep_lag_tilde=z_lag_tilde), cluster(countryid)

esttab using "placebo_results_raw.tex", replace ci