function q = gmmobj(b,data,W)

m=gmmm(data,b);
mbar = sum(m)'/size(m,1);
q = mbar'*W*mbar;

end