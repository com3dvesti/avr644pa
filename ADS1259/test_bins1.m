%clear all; clc; close all; load test_vel_4.txt; A=test_vel_4;n=length(A)
%clear all; clc; close all; load test_vel_5.txt; A=test_vel_5;n=length(A)
%clear all; clc; close all; load test_bins1.txt; A=test_bins1;n=length(A)
clear all; clc; close all; load test_vel_61.txt; A=test_vel_61;n=length(A)
n1=1;n2=n;
NN=A(n1:n2,1);
wx0=A(n1:n2,2);wy0=A(n1:n2,3);wz0=A(n1:n2,4);
wx1=A(n1:n2,5);wy1=A(n1:n2,6);wz1=A(n1:n2,7);
% wx2=A(n1:n2,8);wy2=A(n1:n2,9);wz2=A(n1:n2,10);
% wx3=A(n1:n2,11);wy3=A(n1:n2,12);wz3=A(n1:n2,13);
% wx=A(n1:n2,14);wy=A(n1:n2,15);wz=A(n1:n2,16);
 WW=[ wx0 wy0 wz0]*0.00875;figure(1);plot(WW);
 AA=[ wx1 wy1 wz1]*0.001845;figure(2);plot(AA)
% WWx=[ (wx0-wx1)*0.5 (wx2-wx3)*0.5]*0.00875;figure(2);plot(WWx);
% WWy=[ (wy0-wy1)*0.5 (wy2-wy3)*0.5]*0.00875;figure(3);plot(WWy);
% WWz=[ (wz0-wz1)*0.5 (wz2-wz3)*0.5]*0.00875;figure(4);plot(WWz)
% W1=[wx1 wy1 wz1];W0=[wx0 wy0 wz0];W2=[wx2 wy2 wz2];W3=[wx3 wy3 wz3];
% for i=1:n
%     
%   
% end
% 
% % dww=dw(1:n-1);
% % B=[wyy(1:n-1)  dww];
% % nn=length(wyy);wy=NN(1:nn-1);
% % dwy=dwy(1:nn-1);
% %Wyy1=WWy(1:5000,1);Wyy2=WWy(1:5000,2);
%   % figure(2)
%   % histfit(wx*180/pi)
%    figure(5);plot(W0);
%    figure(6);plot(W1)
%    figure(7);plot(W2)
%    figure(8);plot(W3)
%    
% %   plot(dif0)
%   %figure(4)
  
