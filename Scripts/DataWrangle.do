//Data for war/conflict across different countries over time
import excel "InternalDisplacement.xlsx", firstrow clear
sum G

//Data for women participation in national government over time
import delimited IPU_Archive.csv, varnames(1) clear

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

gen lowerpercwomen = lowerwomen/lowerseats
gen upperpercwomen = upperwomen/upperseats

sum lowerpercwomen
sum upperpercwomen

save IPU_Archive.dta, replace

//Data for youth education metrics over time
import excel "unicef.xlsx", cellrange(A4:H198) clear

rename A country
rename B year
drop C
rename D youthlit
rename E complower
rename F compupper
rename G outofschoollower
rename H outofschoolupper

local educ_vars youthlit complower compupper outofschoollower outofschoolupper
foreach var of local educ_vars {
    gen `var'_numeric = real(`var') if regexm(`var', "^[0-9.]+$") | missing(`var')
    drop `var'
    rename `var'_numeric `var'
}

sum youthlit

save unicef.dta, replace
