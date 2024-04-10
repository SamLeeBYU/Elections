% Illustrate GMM using Hansen Singleton consumption example

% load data
opts=detectImportOptions('gmmdata.xlsx');
%opts.SelectedVariableNames=[1:5];
%opts.DataRange='2:31';
data=readmatrix('gmmdata.xlsx',opts);

% example risk aversion parameter:
theta = .2;
% example discount rate:
delta = .07;
% put them together in a vector
b = [theta,delta];

% example evaluation of moment function:
m = gmmm(data,b);
mbar = sum(m)'/size(m,1);

% now do GMM
% first with identity weighting matrix:
W=eye(length(mbar));
[bhat,~]=fminsearch(@(x) gmmobj(x,data,W),[.5,.5])

% now with optimal weighting matrix
mstar = gmmm(data,bhat);
Sigma = (mstar'*mstar)/size(mstar,1);
Wopt=inv(Sigma);
[bhat,qstar]=fminsearch(@(x) gmmobj(x,data,Wopt),[.5,.5]);

% now test restrictions
teststat = size(mstar,1)*qstar;
pvalue = 1-chi2cdf(teststat,length(mbar)-length(bhat))

% now do inference
% calculate variance covariance matrix
mstar = gmmm(data,bhat);
Sigma = (mstar'*mstar)/size(mstar,1);
G = gmmG(data,bhat);
V = inv(G'*inv(Sigma)*G)
n = size(data,1)-1;
standarderrors = sqrt(diag(V/n))






