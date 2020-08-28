clear;
raw = round(rand(1,40));
raw = [ 0 1 0 0 0 0 1 0 0 0 1 0 1 1 0 0 1 1 1 0 1 0 0 1];
x = raw(1:20);
y = raw(3:24);

figure;plot(x);hold all;plot(y);


figure;
cc = xcorr(x,y);
plot(cc);

figure;
[cA,cD] = dwt(cc,'db2');
plot(cD);