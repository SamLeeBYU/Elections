% Project Directory
cd('C:\Users\slee039\Box\ECON 398\Final Project')

% Load data
women = readtable('Data/womenrep.csv');

women.Properties.VariableNames{'countrycode'} = categorical(women.countrycode);
women.Properties.VariableNames{'year'} = categorical(women.year);
womenrep_lag = lag(women.womenrep);
z_lag = lag(women.z);
women.countrycode = reordercats(women.countrycode, 'AGO');
women = women(women.year >= 1998, :);
women.year = reordercats(women.year, '1998');