function interd = find_inter(symbs)
siz = size(symbs);
for i=1:siz(1)
   sym = symbs(i,:);
   times = find(sym==1);
   dtimes = diff(times);
   interd{i} = dtimes;
end