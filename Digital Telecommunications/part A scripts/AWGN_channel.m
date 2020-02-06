function r = AWGN_channel(s, SNR,M)

 [L_s, T_symbol] = size(s);
 variance= 1/(2*log2(M)*(10^(SNR/10))); %variance= ó^2
 
 noise = sqrt(variance)*randn(L_s, T_symbol); 
 r = s + noise;
 
end