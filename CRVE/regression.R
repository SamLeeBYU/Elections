#Author: Sam Lee
#Date: 04/13/2024

#This script defines functions for regression, including two-stage least squares
#regression and OLS using matrix multiplication

#Returns 95% C.I. on beta[1] (treatment effect)

twosls <- function(X, Y, Z){
  n <- nrow(X)
  if(ncol(X) == ncol(Z)){
    #Just Identified
    beta.hat <- solve(t(Z)%*%X)%*%t(Z)%*%Y
  } else {
    #Assume homoskedasticity
    W <- solve(t(Z)%*%Z)
    beta.hat <- solve(t(X)%*%Z%*%W%*%t(Z)%*%X)%*%
      t(X)%*%Z%*%W%*%t(Z)%*%Y
  }
  sigma2 = (1/n)*sum((Y-X%*%beta.hat)^2) 
  #Variance-Covariance Matrix
  V <- sigma2*solve((t(X)%*%Z)%*%(solve(t(Z)%*%Z))%*%
                      t(t(X)%*%Z))
  
  #95% C.I.
  beta.hat[1,1]+c(-1,1)*qnorm(0.975)*sqrt(diag(V)[1])
}

#These two are the same via the Frisch-Waugh Theorem
#twosls(X, Z, Y)
#twosls(X.tilde, Y.tilde, Z.tilde)


#OLS 
ols <- function(X, Y, robust=F){
  n = nrow(X)
  k = ncol(X)-1
  beta.hat <- solve(t(X)%*%X)%*%t(X)%*%Y
  
  if(robust){
    u.hat = (X%*%beta.hat-Y)^2
    sigma <- matrix(0, k+1, k+1)
    for(i in 1:nrow(u.hat)){
      sigma <- sigma+(X[i,]%*%t(X[i,]))*u.hat[i]
    }
    V <- (n^2)/((n-k))*solve(t(X)%*%X)%*%sigma%*%t(solve(t(X)%*%X))
    #95% C.I. for delta
    beta.hat[1] + c(-1,1)*qnorm(0.975)*sqrt(n^-1*V[1,1])
  } else {
    epsilon <- sum((X%*%beta.hat-Y)^2)
    #DF correction
    sigma <- epsilon/(n-k)*(t(X)%*%X)
    V <- solve(t(X)%*%X)%*%sigma%*%solve(t(X)%*%X)
    #95% C.I. for delta
    beta.hat[1] + c(-1,1)*qnorm(0.975)*sqrt(V[1,1])
  }
}

# ols(X, Y, robust=F)
# ols(X, Y, robust=T)