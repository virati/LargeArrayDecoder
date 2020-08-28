function sweep = sweep_channels(signal,window)
sweep = zeros(length(signal)-window,1);

for i=1:length(signal)-window
   for j=1:3
      sweep(i) = sweep(i) + sum(signal(i:i+window,j+1));
   end
end