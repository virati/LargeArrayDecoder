dir_list = {'nocac','4cac','wash','other';[1,2,3],[4,5,6],[4,5,6],[1,2,3]};


for i=1:length(dir_list)
    for j=dir_list{2,i}
        test = analysis_v2(dir_list{1,i},int2str(j));
    end
end