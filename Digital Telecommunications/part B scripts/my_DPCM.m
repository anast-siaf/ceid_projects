function y_rec=my_DPCM(p,N) 

x1= load('source.mat');
x=x1.t;

len_x=length(x);

r=zeros(length(p),1);
%Dianysma aftosysxetisis
for i=1:p
    sum= 0;
    for n=p+1:len_x
        sum=sum+ x(n)*x(n-i);
    end
    r(i)=(1/(len_x-p))*sum;
end


%Pinakas aftosysxetisis
R=zeros(length(p),length(p));
for i=1:p
        for j=1:p
            sum=0;
            for n=p:len_x
            sum= sum+ x(n-j+1)*x(n-i+1);
            end
         R(i,j)=(1/(len_x-p+1))*sum;
        end
end

%syntelestes filtrou provlepsis
a=R\r';

%kvantisi syntelestwn
a_quantum=my_quantizer(a,8,-2,2)';


mem(1:p)=x(1:p)';

%filtro provlepsis
pred= zeros(len_x,1);   %provlepsi deigmatos
err=zeros(len_x,1);      %sfalma provlepsis
err_q=zeros(len_x,1);%kvantisi sfalmatos
%y_rec=zeros(N,1); %anakataskevasmeno sima
for j= p+1:len_x
    sum=0;
        for i=1:p
            sum= sum+ a_quantum(i)* mem(j-i);
        end
    
    %Provlepsi deigmatos
    pred(j)=sum;
    
    %Ypologismos sfalmatos provlepsis
    err(j)=x(j)- pred(j);
    
    %Kvantopoihsh tou sfalmatos provlepsis
    err_q(j)= my_quantizer(err(j),N,-3.5,3.5)';
    
    %anakataskevi tou deigmatos sto dekti
    y_rec(j)=err_q(j)+pred(j);
    mem(j)=y_rec(j);
end


%plot~~~~~ erotima 2
%  plot(x,'b--'); hold on;
%  plot(err,'r:');hold off;
%  grid on;
%  legend('Input Signal','Prediction Error');
 
 % plot~~~~~erotima 4
plot(x,'b--'); hold on;
plot( y_rec,'m--');hold off;
grid on;
legend('Input Signal','Rebuild signal');

end


 
 