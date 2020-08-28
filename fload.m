function returnvar = fload(fname,res,time)
num=['data/' fname];
fid = fopen([num '_matlab.bin']);
img_stack = fread(fid,'*uint16');
fclose(fid);

img_stack = reshape(img_stack,time,res(1),res(2),10); 

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
        sig = squeeze(img_stack(:,i,j,:));
        [ticks,times] = find_good_pixels_nothres(sig);
        figure;
        plot(sig(:,2),'r');hold all;
        plot(sig(:,3),'g');plot(sig(:,4),'b');
        for w=times
            line([w w],[-900 -550],'Color','b');
        end
    end
end