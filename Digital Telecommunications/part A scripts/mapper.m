function symbols = mapper(bit_sequence, g, M)

if M==8
sym_seq_len = floor((length(bit_sequence)/3));
elseif M==2
  sym_seq_len = floor((length(bit_sequence)/2));
else
    msg='Not programmed to do anything else';
    error(msg)
end

symbol_sequence = zeros(sym_seq_len, 1);

j = 1;

if M==8
    for i=1:3:length(bit_sequence)
    symbol_sequence(j) = bit_sequence(i)+2*bit_sequence(i+1)+4*bit_sequence(i+2);
    
        j = j + 1;
    end
else 
    
    for i=1:2:length(bit_sequence)
    symbol_sequence(j) = 2*bit_sequence(i) + bit_sequence(i + 1);
    j = j + 1;
    end
end

if g==1
symbols= bin2gray(symbol_sequence,'pam',M);
else symbols= symbol_sequence;
end




end
