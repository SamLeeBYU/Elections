---
title: "Closing the Gender Gap in Climate"
subtitle: "Can Electing More Women into Office Narrow the Climate Divide?"
author: "Sam Lee"
---

# (1) Applied Analysis

## Introduction

I seek to identify the causal effect that electing higher proportions of women in national legislatures in African and Arab nations has on yearly per capita $CO_2$ emissions. I utilize a two-stage difference-in-difference approach on 64 different countries throughout Africa and the Middle-East from 1998-2022. To eliminate the potential endogeneity in using the proportion of women in national legislature as a treatment on per capita $CO_2$ emissions, I use years since women were granted suffrage in each respective country as an instrumental variable. One nominal paper in the literature has shown evidence that increased proportions of women in parliaments is more than likely causally related to stricter climate policies (Mavisakalyan & Tarverdi, 2019). However, this paper does not take into account how carbon emissions and women in government have evolved over time. To my knowledge, little research has been done to show a causal link between women in parliaments and its effects on climate *over time*. I expand on this research by showing how carbon emissions have changed over time to elicit a local average treatment effect between changes in gender compositions at the national legislature level. When the average proportion of women in national legislatures in African and Arab countries increase by 1%, I find a significant effect that total yearly (gigatons of) $CO_2$ emissions per capita decrease by 1.08 (-1.64, -0.51), on average. To enforce the credibility of significance, I run a placebo regression, using the number of natural disasters (as classified and recorded by the Centre for Research on the Epidemiology of Disasters) that occur within a country at a particular year as an effective placebo.

The results of the applied analysis are discussed in [Report.pdf](Report.pdf).

---

# Reproduce Empirical Results

1) Clone the Repository (Download the Files)

For git users:
- Run the following command in your directory of choice
```
git clone "https://github.com/SamLeeBYU/Elections"
```
- Alternatively, you can just download the files manually
2) Navigate into the project directory
```
cd Elections
```
3) Change the Working Directories
 - In each of the Stata files change the first lines to reflect the directory that you downloaded the files into.
(line 9 in [Scripts/DataWrangle.do](Scripts/DataWrangle.do), line 9 in [Scripts/analysis.do](Scripts/analysis.do), and line 13 [Scripts/placebo.do](Scripts/placebo.do); this should be the same directory that you navigate into in step 2).
4) Run [Scripts/analysis.do](Scripts/analysis.do) in Stata
```
do Scripts/analysis.do
```
- This will run [DataWrangle.do](Scripts/DataWrangle.do) first, which merges in all the raw files and prepares an analytical sample for analysis. This will also save the regression results into [regression_results_raw.tex](regression_results_raw.tex) and the placebo results into [placebo_results_raw.tex](placebo_results_raw.tex) after running [placebo.do](Scripts/placebo.do), which the script will also call simultaneously.

---

# (2) Cluster Robust Variance Estimators for Instrumental Variables and Monte Carlo Analysis

## Introduction

The theoretical portion of this project assesses the asymptotic properties of cluster-robust variance estimators (CRVEs) in a GMM framework for instrumental variables. I use the data from the applied example of examining of what the effect of electing higher proportions of women in African and Arab nations has on yearly $CO_2$ emissions per capita using years since suffrage as an instrumental variable. I discuss three feasible CRVEs proposed in the literature and use the empirical example to illustrate the long-run rejection rates of the CRVEs. The data-generating process, estimation using GMM, and implications for cluster-robust variance estimators are also discussed. The paper includes a Monte Carlo analysis to evaluate the performance of the CRVEs, with implications for the findings from the applied example. The paper aims to assess the reliability of the inference drawn from the empirical analysis.

The findings for the theoretical paper are discussed in detail in [Simulation.pdf](Simulation.pdf)

---

# Reproduce Monte Carlo Results

The code to reproduce the Monte Carlo analysis (Table 4 in [Simulation.pdf](Simulation.pdf)) was written in R. This includes the functions written for the proposed cluster robust variance estimators as defined in the paper. All regression calculations were done using matrix algebra. All R code can be found in the [CRVE](CRVE/) directory.

1) Run [main.R](CRVE/main.R)

(in the terminal)
```
Rscript CRVE/main.R
```

This script loads in [setup.R](setup.R), [DGP.R](CRVE/DGP.R), [regression.R](CRVE/regression.R), [simulate.R](CRVE/simulate.R), runs the simulation 10,000 times (this can be changed) by calling the data-generating function to generate a new response variable (Y), and then estimates $\delta$ and standard errors for $\delta$ using the proposed cluster-robust variance estimators as discussed in the paper. It saves the simulated results to an [RData object](CRVE/sims.RData), calculates the empirical rejection rate, and then formats everything into a latex table as seen in Table 4 (formatted latex results are saved in [sim-results.tex](CRVE/sim-results.tex)). A seed is set in [main.R](CRVE/main.R) to yield the same results every run through.

---

# Data

## Raw Data Files

#### Number of Women in National Legislature within Country Over Time [IPU.csv](Data/IPU.csv)

This data set was web-scraped from the IPU, which publicly maintains this maintains this data. This file comes as a result of running [ipu_scraper.py](Scripts/ipu_scraper.py).

#### Number of Natural Disasters within Country Over Time [disasters.xlsx](Data/disasters.xlsx)

This data set was publicly obtained through Centre for Research on the Epidemiology of Disasters at [https://www.emdat.be/](https://www.emdat.be/). All definitions and classifications of natural disasters are defined by CRED.

#### Total Yearly Per-Capita $CO_2$ Emissions within Country [emissions.csv](Data/emissions.csv)

This data set was web-scraped from the Emissions Database for Global Atmospheric Research (EDGAR). This file is the output from running the script [co2_scraper.py](Scripts/co2_scraper.py). Data specifically comes from this report from the European Commission at [https://edgar.jrc.ec.europa.eu/](https://edgar.jrc.ec.europa.eu/).

#### Regional Classifications [regions.csv](Data/regions.csv)

This .csv file contains the regional definitions for how I classify a country as either African or Arab. These definitions were web-scraped from U.S. Department of State's site: [https://www.state.gov/countries-and-areas-list/](https://www.state.gov/countries-and-areas-list/). This file is the result of running of [regions_scraper.py](Scripts/regions_scraper.py).

#### Suffrage [suffrage.csv](Data/suffrage.csv)

This data set contains panel data from the Harvard Dataverse (Skaaning et. al, 2015) yielding a set of year-country combinations, which among other democratic characteristics, maintains a dummy indicating 1 if the country had suffrage during that year; 0 otherwise. I use the most updated version (updated in March 29th, 2020).

#### World Bank Data [worldbank.csv](Data/worldbank.csv)

This data was directly (and publicly) downloaded from the World Bank's Open Data bank at [https://databank.worldbank.org](https://databank.worldbank.org). This data set contains panel covariate information pertaining to economic indicators such as GDP, population, and GDP per capita for each country over time.

## Processed Data Files

#### Analytic Sample [womenrep.csv](Data/womenrep.csv)

This is the final wrangled, cleaned data file saved by [DataWrangle.do](Scripts/DataWrangle.do) (in .csv format--there's an equivalent file with .dta extension). This file is then pulled into [analysis.do](Scripts/analysis.do) and [placebo.do](Scripts/analysis.do) for appropriate regression analysis.

Note: All other files with the .dta extension are simply the cleaned or processed files by [DataWrangle.do](Scripts/DataWrangle.do).

---

# Scripts

#### [DataWrangle.do](Scripts/DataWrangle.do)

This script reads in all the raw data files (IPU.csv, emissions.csv, disasters.xlsx, regions.csv, suffrage.csv, and worldbank.csv), cleans them, and merges them into a analytic sample file called [womenrep.dta](Data/womenrep.dta) (also available with .csv extension). Extensive documentation is also available within this Stata file.

#### [analysis.do](Scripts/analysis.do)

This script runs [DataWrangle.do](Scripts/DataWrangle.do) to read in the analytic sample, and prepares a few more things for the analysis such as logging GDP and population, lagging covariates, creating saturated dummies for country-specific and year-specific fixed effects, and dropping colinear terms. This script saves the regression matrix (with fixed effects, lags, etc.) to [regression_matrix.dta](Data/regression_matrix.dta). This script also runs the main regression for identification (a two-stage difference-in-differences) and saves the results to [regression_results_raw.tex](regression_results_raw.tex) (although, I format the latex into a nicer formatted [regression_results.tex](regression_results.tex)). Finally, this script calls [placebo.do](Scripts/placebo.do). Extensive documentation is also available in this Stata file.

#### [co2_scraper.py](Scripts/co2_scraper.py)

This script uses dynamic web-scraping techniques (via the Selenium library in Python) to iteratively queue through all the available years on the EDGAR database to obtain per capita $CO_2$ emissions in every year for each country. The script saves the result to [emissions.csv](emissions.csv).

#### [country_code.py](Scripts/country_code.py)

This script uses the [Rest Countries API](https://restcountries.com) to find country (ISO) codes for country (string) names in files in which the ISO codes aren't readily available. Since different sources will spell countries differently, it is more reliable to join countries based on their ISO country code (this is what I do in [DataWrangle.do](Scripts/DataWrangle.do)). I also use `difflib` to find the closest matched string in the json API response. I use this script to find corresponding ISO codes for both the IPU data set and the suffrage data set.

#### [ipu_scraper.py](Scripts/ipu_scraper.py)

This script is extremely similar to [co2_scraper.py](Scripts/co2_scraper.py) in that it uses the same dynamic web-scraping techniques. It iteratively loops through each available date the IPU has on both their archives and their up-to-date data base, concatenates data (the number of women in each house of legislature, as well as the total number of seats for each country and year), and finally saves it to [IPU.csv](Data/IPU.csv).

#### [placebo.do](Scripts/placebo.do)

This script is called by [analysis.do](Scripts/analysis.do), but can also be ran independently. This script performs the placebo regression discussed in the [Report.pdf](Report.pdf). This script merges the cleaned disasters data (prepared by [DataWrangle.do](Scripts/DataWrangle.do)) and runs the same (two-stage difference-in-differences) regression in [analysis.do](Scripts/analysis.do), but replaces $CO_2$ emissions per capita with the number of natural disasters. This script saves the regression matrix (with fixed effects, lags, etc.) to [disasters_regression_matrix.dta](Data/disasters_regression_matrix.dta). Finally, this script saves the results to [placebo_results_raw.tex](placebo_results_raw.tex).

#### [regions_scraper.py](Scripts/regions_scraper.py)

This is a static web-scraping script that reads in the HTML from the U.S. Department of State's website ([https://www.state.gov/countries-and-areas-list/](https://www.state.gov/countries-and-areas-list/)), and formats it into a nicely arrayed csv called [regions.csv](Data/regions.csv). This is what defines what I count as either an African or Arab nation.

## Scripts for Monte Carlo Analysis & Theoretical Paper

#### [cluster.robust.R](CRVE/cluster.robust.R)

This script defines a function to evaluate the proposed formulas for the cluster robust variance estimators in R. The function returns a 95% confidence interval on the estimated $\delta$ (presumed to be the first column of $X$).

#### [DGP.R](CRVE/DGP.R)

This script defines a function to generate new values of the response variable given the data-generating process defined in the paper.

#### [regression.R](CRVE/regression.R)

This script defines two functions, one for instrumental variables and one for OLS. These functions calculate the coefficient estimates and standard errors using matrix algebra and standard GMM theory. My IV function assumes homoskedasticity. OLS can be calculated either with homoskedastic or robust standard errors.

#### [setup.R](CRVE/setup.R)

This script loads in the data from Stata used in the applied example (see [analysis.do](Scripts/analysis.do)), partials out the fixed effects, and prepares empirical X and Y matrices used by the other R scripts in this analysis.

#### [simulate.R](CRVE/simulate.R)

This script contains three functions:

1) *simulate.CRVE* - This function runs the Monte Carlo analysis $n$ times (drawing new vectors for $Y$ $n$ times). It takes a vector $Y$ as an argument--this is the vector that is replaced (or sampled from to be replaced) in the DGP. It also takes *clusters* as an argument, which specify the cluster indices (a vector for where the clusters are located and how many observations are in each cluster); this argument is defined in [setup.R](CRVE/setup.R). The function outputs a matrix, where each set of two rows is the (2.5%, 97.%) C.I. surrounding the estimate for $\delta$ for that specific generation.

2) *rejection* - Given a matrix of simulations (given by the output of *simulate.CRVE*), calculates the empirical rejection rates of each of the variance estimators. Outputs a named vector.

3) *to_latex* - Given a matrix of simulations (given by the output of *simulate.CRVE*), formats the matrix into a nicely organized latex table for display (saved to [sim-results.tex](CRVE/sim-results.tex)). This function also saves the simulation matrix to an external RData object ([sims.RData](CRVE/sims.RData)).

#### [main.R](CRVE/main.R)

This script loads in all the scripts above and runs the Monte Carlo analysis. It sets a seed for exact replication. It make take about 10 minutes to run. It saves the results to a latex table using *to_latex(.)* from [simulate.R](CRVE/simulate.R).

---

# References

Bertrand, M., Duflo, E., & Mullainathan, S. (2004). How much should we
trust differences-in-differences estimates?
<https://www.jstor.org/stable/25098683>

Bell, R.M.m McCaffrey, D.F., (2002). Bias reduction in standard errors for linear regression with multi-stage samples. Surv. Methodol. 28, 169-181.

Centre for Research on the Epidemiology of Disasters (CRED). (2023). EM-DAT: The Emergency Events Database [database]. Retrieved [03.29.2024], from [https://www.emdat.be/](https://www.emdat.be/)

Emissions Database for Global Atmospheric Research (EDGAR). (n.d.). Edgar online. Retrieved from [https://edgar.jrc.ec.europa.eu/](https://edgar.jrc.ec.europa.eu/)

European Commission, Joint Research Centre (JRC). (2023). Emissions gap report 2023. Publications Office of the European Union. doi:10.2760/481442 [https://edgar.jrc.ec.europa.eu/report_2023](https://edgar.jrc.ec.europa.eu/report_2023)

Grier, R., & Maldonado, B. (2015). Electoral experience, institutional quality, and economic development in Latin America. Oxford Development Studies, 43(2), 253-280.

Hicks, D. L., Hicks, J. H., & Maldonado, B. (2016). Women as policy makers and donors: Female legislators and foreign aid. European Journal of Political Economy, 44(2), 118-135. doi: 10.1016/j.europoleco.2015.12.004

Inter-Parliamentary Union (IPU). (n.d.). Women in national parliaments. [Data set]. Retrieved from [https://data.ipu.org/womon-ranking](https://data.ipu.org/womon-ranking)

MacKinnon, J. G., Nielsen, M. Ø., & Webb, M. D. (2023). Cluster-robust inference: A guide to empirical practice. Journal of Econometrics, 47(4), 414–4561

Mavisakalyan, A., & Tarverdi, Y. (2019). Gender and climate change: Do female parliamentarians make a difference? Global Labor Organization (GLO) Discussion Paper No. 221. [https://www.sciencedirect.com/science/article/pii/S0176268017304500](https://www.sciencedirect.com/science/article/pii/S0176268017304500)

Medlicott, E. (2021, March 8). The five devastating reasons climate change affects women more than men. Retrieved from [https://www.euronews.com/green/2021/11/09/the-five-devastating-reasons-climate-change-affects-women-more-than-men](https://www.euronews.com/green/2021/11/09/the-five-devastating-reasons-climate-change-affects-women-more-than-men)

Mirziyoyeva, N., & Salahodjaev, D. (2023). Does representation of women in parliament promote economic growth? Considering evidence from Europe and Central Asia. Frontiers in Political Science, 4(2). [DOI: 10.3389/fpos.2023.1203221] [https://www.frontiersin.org/articles/10.3389/fpos.2023.1120287/full](https://www.frontiersin.org/articles/10.3389/fpos.2023.1120287/full)

Schaeffer, Katherine (2020, October 5). Pew Research Center. Key facts about women's suffrage around the world, a century after U.S. ratified 19th Amendment. Retrieved April 1, 2024, from [https://www.pewresearch.org/short-reads/2020/10/05/key-facts-about-womens-suffrage-around-the-world-a-century-after-u-s-ratified-19th-amendment/](https://www.pewresearch.org/short-reads/2020/10/05/key-facts-about-womens-suffrage-around-the-world-a-century-after-u-s-ratified-19th-amendment/)

Sellers, S. (2016). Gender and climate change: A closer look at existing evidence. Global Gender and Climate Alliance (GGCA). [https://wedo.org/gender-and-climate-change-a-closer-look-at-existing-evidence-ggca/](https://wedo.org/gender-and-climate-change-a-closer-look-at-existing-evidence-ggca/)

Skaaning, Svend-Erik; John Gerring; Henrikas Bartusevicius, 2015, "A Lexicial Index of Electoral Democracy", [https://doi.org/10.7910/DVN/29106](https://doi.org/10.7910/DVN/29106), Harvard Dataverse, V6

United Nations Development Programme (UNDP). (2022, March 8). International Women’s Day 2022 “Gender equality today for a sustainable tomorrow”. Retrieved from [https://www.undp.org/speeches/undp-administrators-statement-international-womens-day-2023-8-march](https://www.undp.org/speeches/undp-administrators-statement-international-womens-day-2023-8-march)

U.S. Department of State. (n.d.). Countries and Areas List. Retrieved from [https://www.state.gov/countries-and-areas-list/](https://www.state.gov/countries-and-areas-list/)

The World Bank. (n.d.). World Bank Open Data. Retrieved from [https://databank.worldbank.org](https://databank.worldbank.org)