function [ticks,times,high_times] = find_good_pixels_lax(signal,high_thresh)

signal_dims = size(signal);

ticks = 0;
times = [];
high_times = [];

for i=1:signal_dims(1)-1
    sig_coef = (signal(i,2) > high_thresh) + (signal(i,3) > high_thresh) + (signal(i,4) > high_thresh);
    sig_2coef = (signal(i+1,2) < -high_thresh) + (signal(i+1,3) < -high_thresh) + (signal(i+1,3) < -high_thresh);
    
    if sig_coef + sig_2coef > 5
       ticks = ticks + 1; 
       times = [times i];
    end
end


% %Signal is going to be data for 1 pixel, all time, and all channels
% times = [];
% high_times = [];
% high_ticks = 0;
% ticks = 0;
% 
% high_sig = [];
% low_sig = [];
% 
% signal_dims = size(signal);
% 
% for i=1:signal_dims(1)
%     sig_coef = (signal(i,2) > high_thresh) + (signal(i,3) > high_thresh) + (signal(i,4) > high_thresh);
%     anti_sig_coef = (signal(i,7) < low_thresh) + (signal(i,8) < low_thresh) + (signal(i,9) < low_thresh);
%     
%     high_sig = [high_sig sig_coef];
%     low_sig = [low_sig anti_sig_coef];
% end
% 
% for i=1:signal_dims(1)
%     if high_sig(i) == 3 && low_sig(i) == 3
%         ticks = ticks + 1;
%         if signal(i,2) > high_thresh * 10 && signal(i,3) > high_thresh * 10 && signal(i,4) > high_thresh * 10
%            high_times = [high_times i]; 
%         else
%             times = [times i];
%         end
%     end
% end