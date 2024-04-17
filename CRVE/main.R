#Author: Sam Lee
#Date: 04/14/2024

#This script compiles all the dependent scripts and runs
#the monte-carlo analysis for the applied example

set.seed(04142024)

#Load in the data matrices for the applied example
source("CRVE/setup.R")
#Load in cluster robust formula
source("CRVE/cluster.robust.R")
#Load in function for data-generating bootstrap process
source("CRVE/DGP.R")
#Load in function to calculate 2sls regression
source("CRVE/regression.R")
#Function to run simulations
source("CRVE/simulate.R")

#Run simulation
sims <- simulate.CRVE(10000, Y.tilde, clusters, bootstrap.cluster = F)
#Format table to latex and save as a file
cat(to_latex(sims, save=T), sep="\n", file="CRVE/sim-results.tex")
