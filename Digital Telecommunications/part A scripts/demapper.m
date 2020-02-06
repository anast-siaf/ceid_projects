function bit_sequence = demapper(detector_symbols,g,M)

    if M==8
        bit_seq_len = 3*length(detector_symbols);
    else
        bit_seq_len = 2*length(detector_symbols);
    end
    
    if g==1
        symbols = gray2bin(detector_symbols,'pam',M);
    else
        symbols=detector_symbols;
    end

bit_sequence = zeros(bit_seq_len, 1);

j = 1;
%~~~~~~~8-PAM~~~~~~~~~~
if M==8
    for i=1:3:bit_seq_len
        bit_sequence(i)= ceil(rem(symbols(j),2));
        bit_sequence(i+1)= floor((rem(symbols(j),4))/2);
        bit_sequence(i+2)=floor(symbols(j)/4);
    
    
        j = j + 1;
    end
 %~~~~~~~2-PAM~~~~~~~~~~   
else              
    for i=1:2:bit_seq_len
        bit_sequence(i) = floor(symbols(j)/2);
        bit_sequence(i + 1) = rem(symbols(j), 2);
              
        j = j + 1;
    end
end
end



