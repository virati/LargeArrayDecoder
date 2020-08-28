function [inter_dist,templ_idist] = decode(symbl,disp_own_fig,n_bins,x_lim)
templ = 'GGGCGAATTGGGTACCGGGCCCCCCCTCGAGGTCGACGGTATCGATAAGCTTGATATCGAATTCCACCACCACCACGGATCTCTAGCTAGTGGTGGTGGTGCAATTCCACCACCACCACGGATCTCTAGCTAGTGGTGGTGGTGCAATTCCACCACCACCACGGATCTCTAGCTAGTGGTGGTGGTGCAATTCCACCACCACCACGGATCTCTAGCTAGTGGTGGTGGTGCAATTCCACCACCACCACGGATCTCTAGCTAGTGGTGGTGGTGCAATTCCTGCAGCCCGGGGGATCCACTAGTTCTAGAGCGGCCGCCACCGCGGTGGAGCTCCAGCTTTTGTTCCCTTTAGTGAGGGTTAATTTCGAGCTTGGCGTAATCATGGTCATAGCTGTTTCCTGTGTGAAATTGTTATCCGCTCACAATTCCACACAACATACGAGCCGGAAGCATAAAGTGTAAAGCCTGGGGTGCCTAATGAGTGAGCTAACTCACATTAATTGCGTTGCGCTCACTGCCCGCTTTCCAGTCGGGAAACCTGTCGTGCCAGCTGCATTAATGAATCGGCCAACGCGCGGGGAGAGGCGGTTTGCGTATTGGGCGCTCTTCCGCTTCCTCGCTCACTGACTCGCTGCGCTCGGTCGTTCGGCTGCGGCGAGCGGTATCAGCTCACTCAAAGGCGGTAATACGGTTATCCACAGAATCAGGGGATAACGCAGGAAAGAACATGTGAGCAAAAGGCCAGCAAAAGGCCAGGAACCGTAAAAAGGCCGCGTTGCTGGCGTTTTTCCATAGGCTCCGCCCCCCTGACGAGCATCACAAAAATCGACGCTCAAGTCAGAGGTGGCGAAACCCGACAGGACTATAAAGATACCAGGCGTTTCCCCCTGGAAGCTCCCTCGTGCGCTCTCCTGTTCCGACCCTGCCGCTTACCGGATACCTGTCCGCCTTTCTCCCTTCGGGAAGCGTGGCGCTTTCTCATAGCTCACGCTGTAGGTATCTCAGTTCGGTGTAGGTCGTTCGCTCCAAGCTGGGCTGTGTGCACGAACCCCCCGTTCAGCCCGACCGCTGCGCCTTATCCGGTAACTATCGTCTTGAGTCCAACCCGGTAAGACACGACTTATCGCCACTGGCAGCAGCCACTGGTAACAGGATTAGCAGAGCGAGGTATGTAGGC';
%Find hits based on templ
hit_box = zeros(1,length(templ)-3);
for i=1:length(templ)-3
   if templ(i:i+2) == 'CAC'
       hit_box(i) = 1;
   end
end

hit_box_discrete = zeros(3,ceil(length(templ)/3));
for i=0:2
    for j=0:3:length(templ)
        if j+i+3 <= length(templ)
            if templ(j+i+1:j+i+3) == 'CAC'
                hit_box_discrete(i+1,j+1)=1; 
            end
        end
    end
end

%%find histo for template
templ_events = find(hit_box == 1);
templ_idist = diff(templ_events);


% times = find(hit_box_discrete(1,:) == 1);
% times = times .* 3;

%Find inter event distances and make histogram
events = find(symbl==1);
inter_dist = diff(events);
if disp_own_fig
    figure;
    subplot(3,1,1);
    stem(symbl,'fill','.','MarkerSize',2);
    subplot(3,1,2);
    hist(inter_dist,n_bins);
    if x_lim ~= 0
        axis([0 x_lim 0 10]);
    end
    subplot(3,1,3);
    hist(templ_idist,n_bins);
end

%%Do sweeps
% divs = 10;
% div_size = floor(length(symbl)/divs);
% for j=1:divs
%     frame = symbl((j-1)*div_size+1:div_size*(j)-1);
%     resultant(j,:) = cross_corr(frame,hit_box);
% end
% 
% resultant = resultant./(div_size);
% 
% disp('done');


%%Display Hits
% figure;
% for i=1:length(hit_box)
%    if hit_box(i)==1
%        line([i i],[0 10],'Color','r');
%    end
% end
