/*
Author: Sam Lee
03.30.2024

This script takes in all of our data sets and merges them into one cleaned data set for data analysis
*/

//Set working directory
cd "C:\Users\slee039\Box\ECON 398\Final Project"

//Load in suffrage data for each country to create instrument
import delimited "Data/suffrage.csv", varnames(1) clear
sort  countryn year

//We need to figure out the first year that each country granted women suffrage
//NOTE: This excludes countries that don't give women suffrage (as of 2019): UAE, Saudi Arabia
// bysort countryn : egen suffrage = max(female_suffrage)
// keep if suffrage == 0
// keep countryn suffrage
// duplicates drop

keep if female_suffrage == 1
//Find the first year where female_suffrage == 1
bysort countryn : egen suffrage = min(year)
keep countryn countrycode suffrage

duplicates drop
keep if length(countrycode) >= 1

keep countrycode suffrage
//There are some countries that split due to civil wars and other historic events: i.e. Vietnam into South Vietnam and North Vietnam;
//Hence, these observations are given the same country code. We will keep the suffrage years of when the 'original' country first gave women suffrage.
//NOTE: This is actually irrelevant to our study because within the countries identified in the Harvard dataverse data set, each country actually is given a unique country code and hence, we are able to map it uniquely to our final data set.
collapse (min) suffrage, by(countrycode)

save Data/suffrage.dta, replace

//Data for CO2 emissions across African and Arab countries over time (EDGAR - Emissions Database for Global Atmospheric Research)
import delimited "Data/emissions.csv", varnames(1) clear

//Response variable is totalco2cap - Total CO2 emissions per capita

keep region country countrycode year totalco2
keep if year >= 1985 //this is the smallest year for which we have covariate data

rename totalco2 co2
sort countrycode year

save Data/emissions.dta, replace

//Data for women participation in national government over time (IPU DATA)
import delimited "Data/IPU.csv", varnames(1) clear

//Clean the numeric variables
drop lowerpercwomen
drop upperpercwomen

local varlist lowerseats lowerwomen upperseats upperwomen

foreach var of local varlist {
    gen `var'_numeric = real(`var') if regexm(`var', "^[0-9.]+$") | missing(`var')
    drop `var'
    rename `var'_numeric `var'
}

//There was a data entry error here
replace lowerwomen = 1 if country == "Saint Vincent & the Grenadines" & ipuupdate == "2002-02-04"

//Clean the date columns
gen ipuupdate_date = date(ipuupdate, "YMD")
format ipuupdate_date %td
drop ipuupdate
rename ipuupdate_date ipuupdate

gen upperhousesenate_date = date(upperhousesenate, "MY") if upperhousesenate != "---"
format upperhousesenate_date %td
drop upperhousesenate
rename upperhousesenate_date upperhousesenate

gen lowerelection_date = date(lowerelection, "DMY")
gen lowerelection_m_date = date(lowerelection, "MY")
replace lowerelection_date = lowerelection_m_date if lowerelection_date == .
format lowerelection_date %td
drop lowerelection_m_date lowerelection
rename lowerelection_date lowerelection

//This is the year we will group by
//We want to know what the what the composition of the legislature is like at a specific year
gen year = year(ipuupdate)
keep if countrycode != ""

/*
In order to match up with our other data,
which only keeps track of emission or population data by the year for each country, we need the year and country to uniquely identify the observation. Hence, we will select the earliest time in each set of country, year groups to yield us data for women empowerment--although some countries have elections throughout the year.
*/
local election_vars lowerwomen upperwomen lowerseats upperseats
foreach var of local election_vars {
	bysort country year : egen mean`var' = mean(`var')
}
//Treatment variable: Since some countries have multiple elections throughout the year, we are going to standardize it in the sense that we are going to take the 'average' proportion of women representation (total number of women in power divided by the total number of seats in national legislature) throughout the year
gen womenrep = (cond(meanlowerwomen == ., 0, meanlowerwomen) +cond(meanupperwomen == ., 0, meanupperwomen))/(cond(meanlowerwomen == ., 0, meanlowerseats)+cond(meanupperwomen == ., 0, meanupperseats))

foreach var of local election_vars {
	drop mean`var'
}

keep countrycode year womenrep
duplicates drop

//Some countries in the IPU data set were recorded 'twice' in the sense whereonce was there traditional election composition (baseline), and the other observation during the same year was a special case where the president or some other organization appointed a group of extra delegates (consisting of women) that increased the women representation for that year/time period.
//To account for this and to make it so each observation can be uniquely identified by year and country (time-subject identification), we will just combine the baseline compositions with the compositions where these unique cases occured by taking the mean of the women representation proportion

collapse (mean) womenrep, by(countrycode year)

sort countrycode year

save Data/IPU.dta, replace

//Load is disasters data for placebo test
import excel using "Data/disasters.xlsx", sheet("EM-DAT Data") firstrow clear

//This includes things like epidemics and viral diseases, which may be influenced by the number of women in legislature if women enact specific policies that influence vaccines, health outcomes, the likelihood of infections, etc.
drop if DisasterSubgroup == "Biological"

rename StartYear year
rename ISO countrycode

keep countrycode year

gen n_disasters = 1
//The number of natural disasters that happened in each country during each year
collapse (sum) n_disasters, by (countrycode year)

save Data/disasters.dta, replace

//Covariate Data from the World Bank
import delimited "Data/worldbank.csv", varnames(1) rowrange(1:652) clear

drop seriesname

//Format the years as rows
reshape long yr, i(countryname seriescode) j(year)

//Put the metrics as columns
rename yr value
replace seriescode = "gdp" if seriescode == "NY.GDP.MKTP.CD"
replace seriescode = "gdppercapita" if seriescode == "NY.GDP.PCAP.CD"
replace seriescode = "population" if seriescode == "SP.POP.TOTL"
reshape wide value, i(countryname year) j(seriescode) string

rename valuegdp gdp
rename valuegdppercapita gdppercapita
rename valuepopulation population

//Clean numeric data
local metrics gdp gdppercapita population
foreach var of local metrics {
    gen `var'_numeric = real(`var') if regexm(`var', "^[0-9]") | missing(`var')
    drop `var'
    rename `var'_numeric `var'
}

save Data/worldbank.dta, replace

//Merge the data sets

//Merge covariates with emissions data
sort countrycode year
merge 1:1 countrycode year using Data/emissions.dta
//All the country codes in the emissions data set match (which is what we want. The worldbank data also includes data from countries outside of the regions of interest)
keep if _merge == 3
drop _merge

drop country //country name from emissions data set
rename countryname country

merge 1:1 year countrycode using Data/IPU.dta

keep if _merge == 3 | _merge == 1
drop _merge

sort countrycode year

//Join suffrage data and create instrument
merge m:1 countrycode using Data/suffrage.dta
//These are countries that are not African or Arab
drop if _merge == 2
drop _merge

//Instrument: years from when country granted suffrage
gen z = year - suffrage

drop if z == .
//This drops Saudi Arabia and UAE:
//Saudia Arabia only holds local elections (which women were enfranchised in 2015)
//UAE doesn't grant universal suffrage for women (or anyone), and only recently held national elections in 2006, allowing a small number of voters to participate.

//NOTE: The womenrep data for years 1985-1996 will be missing for every country since that data wasn't provided by the IPU. We keep these rows in here anyhow because we might want previous years to verify the parallel trends assumption and to use lags from other variables.
save Data/womenrep.dta, replace
export delimited using "Data/womenrep.csv", replace
