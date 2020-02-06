function r_dem= demodulator(r,M)
T_c= 4;
f_c=1/T_c;
T_symbol=40;

E_s=1;
g_t = sqrt((2 * E_s) / T_symbol);

A=sqrt((M^2-1)/3);
Am_demodulator=((r + (M+1))/2)*A;


r_dem= Am_demodulator*(g_t*cos(2*pi*f_c*(1:T_symbol))');

end
