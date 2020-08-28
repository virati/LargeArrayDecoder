function returnvar = raw_convert(file,res1,res2)
clear img_stack;
num=['data/' file];
img_stack = load_data([num '.lsm'],4000,res1,res2);
fid = fopen([num '_matlab.bin'],'w');
fwrite(fid,img_stack,'uint16');
fclose(fid);
returnvar = 1;