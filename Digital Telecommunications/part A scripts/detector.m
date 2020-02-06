function detector_symbols= detector(r_dem,M)


if M==2 
s_m = cos((2*pi*(0:3)')/4);
else
 s_m=(0:7)';
end

vect_dist = zeros(length(s_m), 1);
detector_symbols= zeros(length(r_dem),1);


for j=1:length(r_dem)
    for i=1:length(vect_dist)
        vect_dist(i) = norm(r_dem(j) - s_m(i));
    end
    [~, pos] = min(vect_dist);
    detector_symbols(j) = pos - 1;
end
