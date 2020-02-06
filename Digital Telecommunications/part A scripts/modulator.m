function s=modulator(symbols,M)

T_c=4;
f_c=1/T_c;
T_symbol= 40;

E_s=1;
g_t = sqrt((2 * E_s) / T_symbol);

A=sqrt(3/(M^2-1)); %Eaverage=Eg(M^2-1)/3=1 (proakis sel 392)
Am = (2*symbols-(M+1))*A;
s = Am*g_t*cos(2*pi*f_c*(1:T_symbol));


end

