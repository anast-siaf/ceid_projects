function y_q= my_quantizer(y,N,min_value,max_value)

%Epipeda kvantismou
quant_levels=2^N;

%Arxikopoihsh tou y_q
y_q= zeros(length(y),1);

%vima kvantismou Ä
quant_step= (abs(min_value)+max_value)/quant_levels;

%ypologismos twn kentrwn
centers=zeros(quant_levels,1);


centers(1)=max_value-(quant_step/2);
centers(quant_levels)= min_value+(quant_step/2);
  
    for i= 2: (quant_levels-1)
        centers(i) = centers(i-1)-quant_step;
    end

%Ypologismos simatos eksodou kvantisti

for j=1:length(y)
    if y(j)<= min_value
        y_q(j)=quant_levels;
    elseif y(j)>= max_value
        y_q(j)=1;
    else
        if y(j)<0
            y(j) = max_value + abs(y(j));
        elseif y(j)>=0
            y(j) = max_value - y(j);
        end
        y_q(j) = floor(y(j)/quant_step)+1;
    end
    
y_q(j)=centers(y_q(j));


end
end



