#Author: Sam Lee
#Date: 04/13/2024

#This script was originally used to test the formulas outlined in MacKinnon et. al (2022).
#This script is not used in the paper.

cluster.robust <- function(g.map, X, Y, cr=1){
  
  beta.hat <- solve(t(X)%*%X)%*%t(X)%*%Y
  k = ncol(X)-1
  n = nrow(X)
  
  y.hat <- X%*%beta.hat
  u <- y.hat-Y
  
  g.start = lag(g.map$g.index, default=0)+1
  
  if(cr == 1){
    group.s <- function(X,u.hat=u,g){
      X.g <- X[g,]
      u.g <- u.hat[g]
      
      s.g <- t(X.g)%*%u.g
      
      return(s.g%*%t(s.g))
    }
    
    cv.1.sigma <- matrix(0, k+1, k+1)
    for(i in length(g.map$g.index)){
      cv.1.sigma <- cv.1.sigma+group.s(X, g=g.start[i]:g.map$g.index[i])
    }
    
    CV.1 = ((G*(n-1))/((G-1)*(n-k)))*solve(t(X)%*%X)%*%
      cv.1.sigma%*%solve(t(X)%*%X)
    
    #95% Confidence Interval
    return(beta.hat[1,]+c(-1,1)*qt(0.975, G-1)*sqrt(CV.1[1,1]))
  } else if (cr == 2){
    grave.s <- function(X,u.hat=u,g){
      X.g = X[g,]
      M = I(nrow(X.g))-X.g%*%solve(t(X)%*%X)%*%t(X.g)
      s.g = t(X.g)%*%matrixsqrtinv(M)%*%u.hat[g]
      s.g.prod <- (s.g)%*%t(s.g)
      #print(s.g.prod[1,1])
      return(s.g.prod)
    }
    
    cv.2.sigma <- matrix(0, k+1, k+1)
    for(i in length(g.map$g.index)){
      cv.2.sigma <- cv.2.sigma+grave.s(X, g=g.start[i]:g.map$g.index[i])
    }
    
    CV.2 = solve(t(X)%*%X)%*%
      cv.2.sigma%*%solve(t(X)%*%X)
    
    return(beta.hat[1,]+c(-1,1)*qnorm(0.975)*sqrt(CV.2[1,1]))
  } else if(cr == 3){
    acute.s <- function(X,u.hat=u,g){
      X.g = X[g,]
      M = I(nrow(X.g))-X.g%*%solve(t(X)%*%X)%*%t(X.g)
      s.g = t(X.g)%*%solve(M)%*%u.hat[g]
      s.g.prod <- (s.g)%*%t(s.g)
      #print(s.g.prod[1,1])
      return(s.g.prod)
    }
    
    cv.3.sigma <- matrix(0, k+1, k+1)
    for(i in length(g.map$g.index)){
      cv.3.sigma <- cv.3.sigma+acute.s(X, g=g.start[i]:g.map$g.index[i])
    }
    
    CV.3 = ((G-1)/G)*solve(t(X)%*%X)%*%
      cv.3.sigma%*%solve(t(X)%*%X)
    
    # betags <- matrix(0, k+1, G)
    # for(g in 1:G){
    #   cluster = g.start[g]:g.map$g.index[g]
    #   betags[,g] <- solve(t(X)%*%X-t(X[-cluster,])%*%
    #                         X[-cluster,])%*%
    #     (t(X)%*%Y-t(X[-cluster,])%*%Y[-cluster,])
    # }
    # sigma <- (betags[,1]-beta.hat)%*%t(betags[,1]-beta.hat)
    # for(g in 2:G){
    #   sigma <- sigma+(betags[,2]-beta.hat)%*%t(betags[,1]-beta.hat)
    # }
    # CV.3 <- (G-1)/G*sigma
    
    return(beta.hat[1,]+c(-1,1)*qt(0.975, G-1)*sqrt(CV.3[1,1]))
  }
}