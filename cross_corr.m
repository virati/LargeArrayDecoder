function corrvect = cross_corr(x,y)
xs = length(x);
ys = length(y);

if ys > xs
    major = y;
    minor = x;
else
    major = x;
    minor = y;
end

frames = length(major) - length(minor) + 1;

corrvect = zeros(frames,1);
for i=1:frames
   frame = major(i:i+length(minor)-1);
   
   corrvect(i) = sum(frame == minor);
end
