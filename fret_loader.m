function returnvar = fret_loader(dir, file,res,time)
clear img_stack;close all;
%File Loading from bin
num=['data/' file];
fid = fopen([num '_matlab.bin']);
img_stack = fread(fid,'*uint16');
fclose(fid);

%res = [20 20];

%Reshape to desired shape             
img_stack = reshape(img_stack,time,res(1),res(2),10);                                                                                                                                                                                                                                                        

mkdir([dir '/pics'])
condit = [dir '/pics/' file];

        %Thresholds!!
         gp_high = 30;
         gp_low = 400;
         peaks_high = 100;
       % gp_high = 1.5e4;
       % gp_low = 1e4;
       % peaks_high = 1.5e4;
 
%Prep stuff ie mean subtraction
for i=1:res(1)
    for j=1:res(2)
        for k=1:10
            curr_mean = mean(img_stack(:,i,j,k));
            img_stack(:,i,j,k) = img_stack(:,i,j,k) - curr_mean;
        end
    end
end

for i=1:res(1)
    for j=1:res(2)
        signaloi = squeeze(img_stack(:,i,j,:));
        signal_1 = sum(signaloi(:,2:4),2);
        signal_2 = sum(signaloi(:,7:9),2);
        
        %Find avgs and means and put into mask
        pix_mean(i,j) = mean(signal_1);
        pix_std(i,j) = std(signal_1);
        
        %Pixel Checks
        [ticks, times,htimes] = find_good_pixels_lax(signaloi,gp_high,gp_low);
        pix_ticks(i,j) = ticks;
        
        %Mask of peak #
        [pts,ptimes] = find_peaks2(signal_1,peaks_high,1);
        pix_peaks(i,j) = pts;
    end
end

%Label good pix
pix_thresh = 45;
good_pix = zeros(res(1)*res(2),1);
good_pix(pix_ticks>pix_thresh) = 1;
mask=reshape(good_pix,res(1),res(2));

%Setup vars (ie for symbs)
symbs = [];
%Cycle through good pix and find metrics of interest
for i=1:res(1)
    for j=1:res(2)
        if mask(i,j) == 1
            %Make summed sig for curr pix
            summed_sig = squeeze(sum(img_stack(:,i,j,2:4),4));
            %Find peaks
            [peaks,ptimes] = find_peaks2(summed_sig,peaks_high,1);
            signaloi = squeeze(img_stack(:,i,j,:));
            [ticks, times, htimes] = find_good_pixels_lax(signaloi,gp_high,gp_low);
            
            %Plot the peaks
            %If you want summed signal
            %figure;plot(summed_sig);hold all;
            
            %If you want each 3
            figure;plot(signaloi(:,2));hold all;
            plot(signaloi(:,3),'g');plot(signaloi(:,4),'r');
            for w=times
                line([w w],[-500 0],'Color','b');
            end
            for w=htimes
                line([w w],[-500 0],'Color','r');
            end
            title(['Firstside ' int2str(i) ' ' int2str(j)]);
            
            %[oticks,otimes] = find_good_pixels_otherside(signaloi,gp_high,gp_low);
            
            %figure;plot(signaloi(:,7));hold all;
            %plot(signaloi(:,8));plot(signaloi(:,9));
            %for w=times
            %    line([w w],[-500 0],'Color','b');
            %end
            %title(['Otherside for ' int2str(i) int2str(j)]);
            
            
            %Filter? On just summed signal
            [cA,cD] = dwt(summed_sig,'db2');
            %figure;plot(cD);title('Filtered');
            
            %Ratio Signal
            ratio_sig = summed_sig ./ (squeeze(sum(img_stack(:,i,j,7:9),4)));
            %Wavelet transform of ratio-d signal
            %figure;wt = cwt(ratio_sig,2:2:128,'db4','plot');title('Wavelet');
            
            %Symbolize peaks
            sym = zeros(1,4000);
            sym([times htimes]) = 1;
            symbs = [symbs;sym];          
        end
    end
end

%%Write Symbs to file
dlmwrite([condit '_symbol.txt'],symbs,'delimiter',' ');

%Symbol Comparison Stuff now
good_pix_num = sum(mask(:));
for i=1:good_pix_num
    %symbs(i,:) = c
   tes = decode(symbs(i,:)); 
   % figure;
   % plot(tes');title('xcorrs with template');
end

%Time between peaks

%%TESTING
%good_pix_num = sum(mask(:));
% good_pix_num = 2;
% 
% %Cycle and find patterns
% %First generate normalizing pfunc
% p1 = [1:4000];
% p2 = [3999:-1:1];
% pfunc = [p1 p2];
% for i=1:good_pix_num
%     for j=i:good_pix_num
%         if i~=j
%             patt_sim = xcorr(symbs(i,:),symbs(j,:));
%             normed_patt = patt_sim ./ pfunc;
%             %figure;plot(normed_patt);
%         end
%     end
% end

returnvar = 0;