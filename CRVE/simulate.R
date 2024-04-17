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

rejection <- function(sims){
  rejections = c()
  k = 1
  for(i in 1:(ncol(sims)/2)){
    rejections[i] = sum(0 < sims[,k] & 0 < sims[,k+1] | 
                         (0 > sims[,k] & 0 > sims[,k+1]))/nrow(sims)
    k = k+2
  }
  names(rejections) = colnames(sims) %>%
    unique()
  return(rejections)
}

#Return the results as a a table as seen in Table 4
to_latex <- function(sims, save=F){
  if(save){
    #Save the simulations as a R data object to be used later
    save(sims, file="CRVE/sims.RData")
  }
  
  latex.table <- paste("\\begin{table}[ht]",
                       "  \\caption{Simulation Results: Two Stage Difference-in-Difference Regression Results of $\\hat{\\delta}$}",
                       "  \\centering",
                       "  \\begin{tabular}{rrrrrrrrr}",
                       "      \\hline",
                       "      &\\multicolumn{2}{c}{$\\overset{iv}{CV}_{1}$} &\\multicolumn{2}{c}{$\\overset{iv}{CV}_{2}$} &\\multicolumn{2}{c}{$\\overset{iv}{CV}_{3}$} &\\multicolumn{2}{c}{2SLS} \\\\",
                       "      &\\multicolumn{2}{c}{(2.5\\%, 97.5\\%)} &\\multicolumn{2}{c}{(2.5\\%, 97.5\\%)} &\\multicolumn{2}{c}{(2.5\\%, 97.5\\%)} &\\multicolumn{2}{c}{(2.5\\%, 97.5\\%)}\\\\",
                       "      \\hline",
                       sep = "\n")
  data <- c()
  for(i in 0:15){
    if(i > 10){
      j <- 9995+(i-10)
    } else {
      j <- i+1
    }
    if(i == 10){
      content <- str_c("...", " & ", paste0(rep("...", 8), collapse = " & "))
    } else {
      content <- str_c(j, " & ", paste0(round(sims[j,],2), collapse = " & "))
    }
    row <- str_c("      ", content, " \\\\")
    data <- c(data, row)
  }
  data <- c(data, "      \\hline")
  rejection.rates <- rejection(sims)
  rejection.rates.row <- c(str_c("      ", "Empirical Rejection & ", 
                               paste(c(str_c("\\multicolumn{2}{c}{", rejection.rates[1:3], "} & "),
                                       str_c("\\multicolumn{2}{c}{", rejection.rates[4], "} ")), collapse = ""),
                               "\\\\") , "      \\hline")
  table.end <- c("    \\end{tabular}", "\\end{table}")
  latex.table <- c(latex.table, data, rejection.rates.row, table.end)
  return(paste(latex.table, sep="\n"))
}
