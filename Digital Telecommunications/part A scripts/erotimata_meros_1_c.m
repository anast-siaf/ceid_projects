L_b = 10002;
SNR = (0:2:20);
SER = zeros(length(SNR),2);
SER_temp_variable = zeros(length(SNR),2);
bit_tr = randsrc(L_b,1,[0 1]);


%~~~~~Ypologismos SER gia 8-PAM xoris Gray encoded symbols~~~~~
symbols=mapper(bit_tr,0,8);
signal_pam = modulator(symbols,8);
for i=1:length(SNR)
    signal_tr = AWGN_channel(signal_pam, SNR(i),8);
   
    signal_dem = demodulator(signal_tr,8);
    symbols_det = detector(signal_dem,8);
 
    bit_rc = demapper(symbols_det,0,8); %symbols_det,NO-gray,8-PAM
   
   SER_temp_variable(i,1) = symerr(symbols, symbols_det)/L_b;
   SER(i, 1) =SER_temp_variable(i,1)*(1/(10^(SNR(i)/10)));
    
end

%~~~~~~~Ypologismos SER gia 2-PAM~~~~~~~
symbols=mapper(bit_tr,0,2);
signal_pam = modulator(symbols,2);
for i=1:length(SNR)
    signal_tr = AWGN_channel(signal_pam, SNR(i),2);
   
    signal_dem = demodulator(signal_tr,2);
    symbols_det = detector(signal_dem,2);
 
    bit_rc = demapper(symbols_det,0,2); %symbols_det,NO-gray,8-PAM
   
       SER_temp_variable(i,2) = symerr(symbols, symbols_det)/L_b;
       SER(i, 2) =SER_temp_variable(i,2)*(1/(10^(SNR(i)/10)));
     
end

%aksonas x grafikis parastasis
x_axe=zeros(length(SNR),1);
for k=1:length(SNR)
    x_axe(k)=10*log10(10^(SNR(k)/10));
end

%Sxediasmos grafikis anaparastasis
semilogy(x_axe, SER(:,1),'go-');hold on;
semilogy(x_axe, SER(:, 2), 'b*-'); hold off;
grid on;

legend('8-PAM', '2-PAM');

ylabel('Symbol Error Rate');