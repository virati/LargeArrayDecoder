function [peak_num,peak_times,t_array] =  find_peaks2(fns, thresh, window)
peak_num = 0;
peak_times = [];
t_array = zeros(length(fns),1);

for i=window+1:length(fns)-window
    if fns(i) > max(fns(i-window:i-1)) && fns(i) > max(fns(i+1:i+window)) && fns(i) > thresh
        peak_num = peak_num + 1;
        peak_times = [peak_times i];
        t_array(i) = 1;
    end
end