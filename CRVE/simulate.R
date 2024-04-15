#Author: Sam Lee
#Date: 04/14/2024

#This script runs a bunch of monte-carlo simulation and calculates the
#empirical coverage associated with each formula used.

simulate.CRVE <- function(n, Y, clusters, bootstrap.cluster=F){
  n.sims <- n
  sims.ci <- matrix(0, nrow=n.sims, ncol=2*4)
  for(i in 1:n.sims){
    Y.new = DGP(clusters, Y, cluster=bootstrap.cluster) %>% as.matrix()
    for(j in 1:4){
      if(j == 4){
        sims.ci[i,(j+(j-1)):(j+(j-1)+1)] = twosls(X.tilde, Y.new, Z.tilde)
      } else {
        sims.ci[i,(j+(j-1)):(j+(j-1)+1)] =
          cluster.robust.iv(X.tilde, Y.new, Z.tilde, clusters, cr=j)
      }
    }
  }
  colnames(sims.ci) <- c(rep(str_c("CR", 1:3), each=2), rep("2SLS", 2))
  return(sims.ci)
}

coverage <- function(sims){
  coverages = c()
  k = 1
  for(i in 1:(ncol(sims)/2)){
    coverages[i] = sum(0 < sims[,k] & 0 < sims[,k+1] | 
                         (0 > sims[,k] & 0 > sims[,k+1]))/nrow(sims)
    k = k+2
  }
  names(coverages) = colnames(sims) %>%
    unique()
  return(coverages)
}
