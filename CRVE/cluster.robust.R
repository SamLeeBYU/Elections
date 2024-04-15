#Author: Sam Lee
#Date: 04/13/2024

#Proposed formulas for CRVE in a GMM framework

library(MultBiplotR)

cluster.robust.iv <- function(X, Y, Z, clusters, cr=1){ #Assumes data is sorted
  n <- nrow(X)
  k <- ncol(X)
  G <- length(clusters)
  if(ncol(X) == ncol(Z)){
    #Just Identified
    beta.hat <- solve(t(Z)%*%X)%*%t(Z)%*%Y
  }
  u.hat <- X%*%beta.hat - Y
  
  
  xtz <- t(X)%*%Z
  
  Sigma <- matrix(0, k, k)
  
  if(cr == 1){
    for(g in 1:G){
      cluster = (lag(cumsum(clusters), default = 0)[g]+1):cumsum(clusters)[g]
      zeta.g <- t(Z[cluster,])%*%u.hat[cluster]
      Sigma <- Sigma + zeta.g%*%t(zeta.g)
    }
    V <- G*(n-1)/((G-1)*(n-k))*solve(n^-1*xtz%*%solve(n^-1*Sigma)%*%t(n^-1*xtz))
  }
  
  if(cr == 2){
    for(g in 1:G){
      cluster = (lag(cumsum(clusters), default = 0)[g]+1):cumsum(clusters)[g]
      M.z <- matrixsqrtinv(diag(1, clusters[g])-
                     Z[cluster,]%*%solve(t(Z)%*%Z)%*%t(Z[cluster,]))
      zeta.g <- t(Z[cluster,])%*%M.z%*%u.hat[cluster]
      Sigma <- Sigma+zeta.g%*%t(zeta.g)
    }
    V <- solve(n^-1*xtz%*%solve(n^-1*Sigma)%*%t(n^-1*xtz))
  }
  
  if(cr == 3){
    for(g in 1:G){
      cluster = (lag(cumsum(clusters), default = 0)[g]+1):cumsum(clusters)[g]
      M.z <- solve(diag(1, clusters[g])-
                     Z[cluster,]%*%solve(t(Z)%*%Z)%*%t(Z[cluster,]))
      zeta.g <- t(Z[cluster,])%*%M.z%*%u.hat[cluster]
      Sigma <- Sigma+zeta.g%*%t(zeta.g)
    }
    V <- (G-1)/G*solve(n^-1*xtz%*%solve(n^-1*Sigma)%*%t(n^-1*xtz))
  }
  
  #95% C.I.
  beta.hat[1,]+c(-1,1)*qnorm(0.975)*sqrt(n^-1*V[1,1])
}
