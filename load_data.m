function data = load_data(filename,time_end,res1,res2)
info = imfinfo(filename);
data = zeros(4000,res1,res2,10,'uint16');
index = 0;
if time_end ~= 0
   last_frame = time_end*2;
else
    last_frame = numel(info);
end
for j=1:2:last_frame
   index = index + 1;
   data(index,:,:,:) = imread(filename,'Index',j,'Info',info);
   disp([int2str(i) '_' int2str(j)]);
end
