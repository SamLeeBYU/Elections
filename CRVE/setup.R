#Author: Sam Lee
#Date: 04/13/2024

#This script loads in the regression matrix from STATA from the applied exampled
#and partials out the fixed effects

library(tidyverse)
library(haven)

women <- read_dta("Data/regression_matrix.dta")
X.covariates = colnames(women)[str_detect(colnames(women), "lgdp|lpopulation")]
fixed.effects = colnames(women)[str_detect(colnames(women), "_I")]

women.cleaned = women[complete.cases(women[c(X.covariates,
                                             fixed.effects,
                                             "womenrep_lag", "z_lag")]),]

#First Stage
W.ct1 = women.cleaned$womenrep_lag
Z.ct1 = women.cleaned$z_lag

X.covariates = as.matrix(women.cleaned[X.covariates])
fixed.effects = as.matrix(women.cleaned[fixed.effects])

# fs <- lm(W.ct1 ~ Z.ct1 + X.covariates + fixed.effects)

Y = as.matrix(women.cleaned$co2)

#Partial out regressors
Y.tilde = fixed.effects%*%(solve(t(fixed.effects)%*%fixed.effects)%*%t(fixed.effects)%*%Y)-Y

X.tilde <- c()
for(i in 0:(length(colnames(X.covariates))+1)){
  if(i == 0){
    covariate = W.ct1
  } else if (i == length(colnames(X.covariates))+1){
    covariate = rep(1, nrow(X.covariates))
  } else {
    covariate = X.covariates[,colnames(X.covariates)[i]]
  }
  X.tilde <- cbind(X.tilde,
                   fixed.effects%*%(solve(t(fixed.effects)%*%fixed.effects)%*%t(fixed.effects)%*%
                                      covariate)-covariate)
}
colnames(X.tilde) <- c("W.ct1", colnames(X.covariates), "Intercept")

#Partial out instrument
Z.ct1.tilde <- fixed.effects%*%(solve(t(fixed.effects)%*%fixed.effects)%*%t(fixed.effects)%*%
                                  Z.ct1)-Z.ct1

Z.tilde <- cbind(Z.ct1.tilde, X.tilde[, 2:ncol(X.tilde)])

X <- cbind(W.ct1, X.covariates, fixed.effects, 1)
Z <- cbind(Z.ct1, X.covariates, fixed.effects, 1)

#Set cluster indices
clusters <- women.cleaned %>% group_by(countrycode) %>%
  summarize(
    n = n()
  ) %>% pull(n)