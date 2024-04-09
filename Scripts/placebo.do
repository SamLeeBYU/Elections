/*
Author: Sam Lee
04.05.2024

This script estimates the effect that women in national legislature have on the frequency of natural disasters within a country.

Theoretically, with this as a placebo, there should be a very weak/zero effect. I provide this as evidence that my results are significant.
*/

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

//Poisson Regression
ivpoisson gmm (womenrep_lag=z_lag) n_disasters lgdp* lpopulation* _I*

//Or roughly equivalently to
gen ln_disasters = ln(0.5+n_disasters)
ivregress 2sls ln_disasters lgdp* lpopulation* _I* (womenrep_lag=z_lag), cluster(country)

esttab using "placebo_results_raw.tex", replace ci