L_b = 10002;
SNR = (0:2:20);
BER_temp_variable = zeros(length(SNR),3);
BER = zeros(length(SNR),3);
bit_tr = randsrc(L_b,1,[0 1]);
symbols = mapper(bit_tr,1,8);  %(bit_tr,gray_or_not,M)
signal_pam = modulator(symbols, 8); %(symbols,M)


%~~~~~~~Ypologismos BER gia 8-PAM Gray encoded symbols~~~~~~~
for i=1:length(SNR)
    signal_tr = AWGN_channel(signal_pam, SNR(i),8);
    
    signal_dem = demodulator(signal_tr,8);
    symbols_det = detector(signal_dem,8); %(signal_dem,M)
 
    bit_rc = demapper(symbols_det,1,8); %symbols_det,gray,8-PAM
    
    BER_temp_variable(i,1) = biterr(bit_tr, bit_rc)/L_b;
    
    BER(i, 1) =BER_temp_variable(i,1)*(1/(10^(SNR(i)/10)));
    

end

%~~~~~Ypologismos BER gia 8-PAM xoris Gray encoded symbols~~~~~
symbols=mapper(bit_tr,0,8);
signal_pam = modulator(symbols,8);
for i=1:length(SNR)
    signal_tr = AWGN_channel(signal_pam, SNR(i),8);

    signal_dem = demodulator(signal_tr,8);
    symbols_det = detector(signal_dem,8);
 
    bit_rc = demapper(symbols_det,0,8); %symbols_det,NO-gray,8-PAM
   
    BER_temp_variable(i,2) = biterr(bit_tr, bit_rc)/L_b;
    BER(i, 2) =BER_temp_variable(i,2) *(1/(10^(SNR(i)/10)));
    
end

 

%~~~~~~~Ypologismos BER gia 2-PAM~~~~~~~
symbols=mapper(bit_tr,0,2);
signal_pam = modulator(symbols,2);
for i=1:length(SNR)
    signal_tr = AWGN_channel(signal_pam, SNR(i),2);
    signal_dem = demodulator(signal_tr,2);
    symbols_det = detector(signal_dem,2);
 
    bit_rc = demapper(symbols_det,0,2); %symbols_det,NO-gray,8-PAM
   
     BER_temp_variable(i,3) = biterr(bit_tr, bit_rc)/L_b;
     BER(i, 3) =BER_temp_variable(i,3) *(1/(10^(SNR(i)/10)));
     
     
end


%aksonas x grafikis parastasis
x_axe=zeros(length(SNR),1);
for k=1:length(SNR)
    x_axe(k)=10*log10(10^(SNR(k)/10));
end
    
%Sxediasmos grafikis anaparastasis
semilogy(x_axe, BER(:,1),'go-');hold on;
semilogy(x_axe, BER(:, 2), 'b*-'); hold on;
semilogy(x_axe, BER(:, 3), 'r--'); hold off;
grid on;

legend('8-PAM/Gray','8-PAM', '2-PAM');

ylabel('Bit Error Rate');
