function G = gmmG(data,b)
% calculates Jacobian
theta=b(1);
delta=b(2);

c = data(:,2);
w = data(:,3);
d = data(:,4);
r = data(:,5);
constant=1+0*c;

n = length(c);

Z=[constant(1:n-1),c(1:n-1),w(1:n-1),d(1:n-1)];

G1= Z.*((1+r(1:n-1))./(1+delta).*(c(1:n-1)./c(2:n)).^theta.*log(c(1:n-1)./c(2:n)));
G2 = -Z.*((1+r(1:n-1))./(1+delta)^2.*(c(1:n-1)./c(2:n)).^theta);

G = [sum(G1)/(n-1);sum(G2)/(n-1)]';
end