#Data-Generating Process for Monte-Carlo Simulation

#Bootstrap a given Y vector (draw values of Y based on a uniform distribution)
DGP <- function(clusters, Y, cluster=F){
  G = length(clusters)
  if(cluster){
    return(Y[unlist(sapply(1:G, function(g){
      lag(cumsum(clusters), default=0)[g]+
        floor(clusters[g]*runif(clusters[g]))+1
    }))])
  } else {
    return(Y[floor(length(Y)*runif(length(Y)))+1])
  }
}
