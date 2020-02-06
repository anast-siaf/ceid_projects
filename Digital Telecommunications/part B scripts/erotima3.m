x1= load('source.mat');
x=x1.t;
%~~~~~~~~~~~~~p=5~~~~~~~~~~~~~
ya=zeros(20000,3);
i=0;
for N=1:3
    i=i+1;
    ya(:,i)=my_DPCM (5,N);
end
mtsp1=zeros(3,1);
for k=1:3
    for j=1:length(x)
        ya(j,k)=((ya(j,k)-x(j))^2);
    end
      
end
 mtsp1=sum(ya,1)./length(x); 

%~~~~~~~~~~~~~p=6~~~~~~~~~~~~~
 yb=zeros(20000,3);
 i=0;
for N=1:3
    i=i+1;
    yb(:,i)=my_DPCM (6,N);
end
mtsp2=zeros(3,1);
for k=1:3
    for j=1:length(x)
        yb(j,k)=((yb(j,k)-x(j))^2);
    end
      
end
 mtsp2=sum(yb,1)./length(x); 

%~~~~~~~~~~~~~p=7~~~~~~~~~~~~~
 yc=zeros(20000,3);
 i=0;
for N=1:3
    i=i+1;
    yc(:,i)=my_DPCM (7,N);
end
mtsp3=zeros(3,1);
for k=1:3
    for j=1:length(x)
        yc(j,k)=((yc(j,k)-x(j))^2);
    end
      
end
 mtsp3=sum(yc,1)./length(x); 
 
%~~~~~~~~~~~~~p=8~~~~~~~~~~~~~
 yd=zeros(20000,3);
 i=0;
for N=1:3
    i=i+1;
    yd(:,i)=my_DPCM (8,N);
end
mtsp4=zeros(3,1);
for k=1:3
    for j=1:length(x)
        yd(j,k)=((yd(j,k)-x(j))^2);
    end
      
end
 mtsp4=sum(yd,1)./length(x);
 
 %~~~~~~~~~~~~~p=9~~~~~~~~~~~~~
  ye=zeros(20000,3);
 i=0;
for N=1:3
    i=i+1;
    ye(:,i)=my_DPCM (9,N);
end
mtsp5=zeros(3,1);
for k=1:3
    for j=1:length(x)
        ye(j,k)=((ye(j,k)-x(j))^2);
    end
      
end
 mtsp5=sum(ye,1)./length(x);
 
%~~~~~~~~~~~~~p=10~~~~~~~~~~~~~
  yf=zeros(20000,3);
 i=0;
for N=1:3
    i=i+1;
    yf(:,i)=my_DPCM (10,N);
end
mtsp6=zeros(3,1);
for k=1:3
    for j=1:length(x)
        yf(j,k)=((yf(j,k)-x(j))^2);
    end
      
end
 mtsp6=sum(yf,1)./length(x);
 
%~~~~~~~~~~~~~plot~~~~~~~~~~~~~
 plot(mtsp1,'b-');hold on;
 plot(mtsp2,'g-');hold on;
 plot(mtsp3,'r-');hold on;
 plot(mtsp4,'k-');hold on;
 plot(mtsp5,'m-');hold on;
 plot(mtsp6,'y-');hold off;
 grid on;
 
legend('p=5','p=6','p=7','p=8','p=9','p=10');
xlabel('N');
ylabel('Μέσο τετραγωνικό σφάλμα πρόβλεψης');
 
 
 

 
 
        
