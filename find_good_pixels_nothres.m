function [total_ticks,times] = find_good_pixels_nothres(signal)

%First find all the peaks for each channel
[n2,peaks2,pt2] = find_peaks2(signal(:,2),0,1);
[n3,peaks3,pt3] = find_peaks2(signal(:,3),0,1);
[n4,peaks4,pt4] = find_peaks2(signal(:,4),0,1);

ticks = floor((pt2 + pt3 + pt4)./3);

[n7,peaks7,pt7] = find_peaks2(signal(:,7),0,1);
[n8,peaks8,pt8] = find_peaks2(signal(:,8),0,1);
[n9,peaks9,pt9] = find_peaks2(signal(:,9),0,1);

anti_ticks = floor((pt7+pt8+pt9)./3);

total_ticks = ticks - anti_ticks;


times = find(total_ticks==1);