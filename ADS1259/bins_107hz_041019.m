clear all; clc; close all;
%global l0 l1 l2 l3 lt0 lt1 lt2 lt3 K  b11 b12 b13 b21 b22 b23 b31 b32 b33 lnor 
%l0=1;l1=0;l2=0;l3=0;
PI=pi; mka=0.009589*1.005; % m/sec2
mkg=0.00875; % gr/sec
g=9.81; 
dt=1/107.11; RG=pi/180; GR=180/pi;
K=RG*0; Te=RG*0; Ga=RG*0;
Fi=RG*0;
mkg=0.00875*RG*1;
l0=cos(K/2)*cos(Ga/2)*cos((Te-Fi)/2)+sin(K/2)*sin(Ga/2)*sin((Fi+Te)/2);
l1=cos(K/2)*sin(Ga/2)*cos((Te-Fi)/2)-sin(K/2)*cos(Ga/2)*sin((Fi+Te)/2);
l2=cos(K/2)*sin(Ga/2)*sin((Te-Fi)/2)-sin(K/2)*cos(Ga/2)*cos((Fi+Te)/2);
l3=cos(K/2)*cos(Ga/2)*sin((Te-Fi)/2)+sin(K/2)*sin(Ga/2)*cos((Fi+Te)/2);
% Create a serial port object. COM port may vary. 
% ====== Формирование параметров для расчета истинных значений
Wzem=(15.04/3600)*pi/180;
Psi = 0;Lambda_0=0;
siF = sin(Fi);       coF = cos(Fi);
siL = sin(Lambda_0);   coL = cos(Lambda_0);
wked_0 = [ Wzem*coF*coL; Wzem*siF; -Wzem*coF*siL ];
%wked_0 = [ Wzem*coF; Wzem*siF; 0 ];
F2 = 0.5*Fi;          K = 0.5*Psi;
coF2 = cos(F2);       siF2 = sin(F2);       
cK   = cos(K);        sK  = sin(K);
a1 = coF2*cK; a2 = siF2*sK; a3 = coF2*sK; a4 = siF2*cK;

P1 = [a1; a1; a4; -a3];
P2 = [a2; -a2; -a3; -a4];
X1=[l0 l1 l2 l3];
Wzem=(15.04/3600)*pi/180;
obj1 = serial('COM13', 'BaudRate', 500000);
%voltarr = zeros(21,1);
%obj = instrfind('Type', 'serial', 'Port', 'COM2', 'Tag', '');
fopen(obj1); voltarr=zeros(100000,7);
%A=16*7+8; fwrite(obj1,A)% start 0.05
%pause(2);
A=16*7+2; fwrite(obj1,A)% start

%A=16*7+10; fwrite(obj1,A)% start 0.05
%A=16*3+1; fwrite(obj1,A)% start 0.1
%A=16*3+3; fwrite(obj1,A)% start 0.3
%A=16*3+4; fwrite(obj1,A)% start 0.6
%A=16*3+5; fwrite(obj1,A)% start 0.9
d = size(obj1);
 for i=1:100
%     %fprintf(obj1, 'MEAS:VOLT?');
  currvolt = str2num(fscanf(obj1));
%     %display('MEAS:VOLT? = '+currvolt);
  voltarr(i,1:length(currvolt)) = currvolt;
% % t = voltarr(i,1);
%     %plot(voltarr,'DisplayName','voltarr','YDataSource','voltarr');figure(gcf);
%     %plot(i,voltarr)
%     %pause(60);
         wx=voltarr(i,2);wy=voltarr(i,3);wz=voltarr(i,4);%T=voltarr(i,4);
         ax=voltarr(i,5);ay=voltarr(i,6);az=voltarr(i,7);Temp=voltarr(i,1);
%    wx=voltarr(i,3); wy=voltarr(i,4); wz=voltarr(i,5);
%    ax=voltarr(i,5); ay=voltarr(i,6); az=voltarr(i,7);         
    wxx1(i)=wx; wyy1(i)=wy; wzz1(i)=wz;
    axx1(i)=ax; ayy1(i)=ay; azz1(i)=az;Tempp(i)=Temp;
 end
 n1=100;
 mwx=mean(wxx1(10:n1)'); mwy=mean(wyy1(10:n1)'); mwz=mean(wzz1(10:n1)');
 max=mean(axx1(10:n1)'); may=1*mean(ayy1(10:n1)'); maz=mean(azz1(10:n1)');
% %currdate = {date};
% %fileloc = ['C:\Test Data\battery_test.xls'];

% % Receive response from the power supply, obj1 
% %idn = fscanf(obj1);
% % Print text to command window 
% % Set the current of the power supply, obj1 
% %fprintf(obj1, 'CURR 6');
% %display('OUTP:START');
% % Start the power supply output, obj1 
% %fprintf(obj1, 'OUTP:START');
% % Measure the voltage at the output of the power supply for 20 mins 
% kurs=0; kurs1=0; kren=0; kren1=0; diff=0 ;diff1=0;
lt0=0; lt1=0; lt2=0; lt3=0; skn=1; lnorr=0;
% 
a=0;
 sigmaPsi=1.0; sigmaEta=0.5; Kalm=1;
 %sigmaPsi=0.2; sigmaEta=2; Kalm=1;
 xOpt(1)=0; eOpt(1)=sigmaEta; K1=0; KK(1)=0;
%k=1:N
%x=k
x(1)=0; z=0;
%z(1)=x(1)+normrnd(0,sigmaEta);
%for t=1:(N-1)
%  x(t+1)=x(t)+a*t+normrnd(0,sigmaPsi); 
 %  z(t+1)=x(t+1)+normrnd(0,sigmaEta);
%end;

%A11=A(1,:);A12=A(2,:);A13=A(3,:)
%yaw = GR*90; pitch = GR*0; roll = GR*0;
%XX=[1 2];YY=[1 2];ZZ=[2 2];A=[XX; YY; ZZ];dcm = angle2dcm( yaw, pitch, roll )
%dcmA=dcm*A;dcmA=A1(1,:);dcmA=A1(2,:);dcmA=A1(3,:);
%plot3(A21, A22, A23);axis([0 5 0 3 0 3]);
%plot3(X,Y,Z);
dt=1./107;
nk1=1/dt*20; tic; 
Vx=0; Vy=0; V1z=0; Ks=0; Et=0; Dz=0; Vxn=0;
xvx = zeros(10); yvx = zeros(10);
xvy = zeros(10); yvy = zeros(10);
xvz = zeros(10); yvz = zeros(10);
wxn=0; wyn=0; wzn=0; 
axn=0; ayn=0; azn=0; 
skn=1; 
l00=1; l10=0; l20=0; l30=0;

ax1=0; ax2=0; Vx1=0; Vx2=0;
ay1=0; ay2=0; Vy1=0; Vy2=0;
az1=0; az2=0; Vz1=0; Vz2=0;

Ks1=0; Et1=0; Dz1=0; 
Vxn=0; Vyn=0; Vzn=0;xxk=0;vk=0;
xkp=0; xk=0; vkp=0; rk=0; xm=0; alpha=0.85; beta=0.01; 
vkpp=0;xkpp=0; xx=0,yy=0;zz=0;kint=0.10;

%nk1 = 200;
for i=1:nk1
    
   currvolt = str2num(fscanf(obj1));
   voltarr(i,1:length(currvolt)) = currvolt;
%    v=voltarr(i,1); zx = voltarr(i,2);
    wx=voltarr(i,2); wy=voltarr(i,3); wz=voltarr(i,4);
    ax=voltarr(i,5); ay=voltarr(i,6); az=voltarr(i,7);
   Temp = voltarr(i,1)-voltarr(1,1); tim(i) = Temp;
   wx=mkg*(wx - mwx); wy=mkg*(wy - mwy); wz=mkg*(wz - mwz);
   ax=mka*(ax-max)*0.181; ay=mka*(ay-may)*0.181; az=mka*(az-maz)*0.181;
   wxx(i)=wx;wyy(i)=wy;wzz(i)=wz;axx(i)=ax;ayy(i)=ay;azz(i)=az;
   WWW=[wxx;wyy;wzz]'; AAA=[axx;ayy;azz]';
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % wxk= wx - xx; xx=xx+dt*wxk*kint; wwxx(i)=wxk;wx=wxk;
   %wyk= wy - yy; yy=yy+dt*wyk*kint; wwyy(i)=wyk;wy=wyk;
   %wzk= wz - zz; zz=zz+dt*wzk*kint; wwzz(i)=wzk;wz=wzk;WWWk=[wwxx;wwyy;wwzz]';
fprintf('%10.5f %10.5f  %10.5f %10.5f %10.5f %10.5f %8.3f \n',wx*GR,wy*GR,wz*GR,ax,ay,az,Temp);   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
%    Filter GYR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   xvx(1) = xvx(2); xvx(2) = wx/3.076521397; yvx(1) = yvx(2); 
   %  yvx(2) = (xvx(2) + xvx(1))+ (0.3499151339 * yvx(1));wx=yvx(2);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %  xvy(1) = xvy(2); xvy(2) = wy/3.076521397; yvy(1) = yvy(2); 
   %  yvy(2) = (xvy(2) + xvy(1))+ (0.3499151339 * yvy(1));wy=yvy(2);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %  xvz(1) = xvz(2); xvz(2) = wz/3.076521397; yvz(1) = yvz(2); 
   %  yvz(2) = (xvz(2) + xvz(1))+ (0.3499151339 * yvz(1));wz=yvz(2);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%mkg=1;
%mka=mka.;
      
%      xkp = xk + dt * xxk;         % update estimated state x from the system
%      vkp = xxk;                   % update estimated velocity
%      rk = wx - xkp; wxx(i)=wx;             % residual error
%      xkp = xkp + alpha * rk;     % update our estimates 
%      vkp = vkp + (beta * rk)/dt;   %    given residual error
%     vkpp(i)=vkp; xkpp(i)=xkp;
%      WT=[t1; wxx; wyy; wzz]';
%     wx=wx*RG*mkg;wy=wy*RG*mkg;wz=wz*RG*mkg;
%      wx=wxn+(dt/0.1)*(wx-wxn);wxn=wx;wwxx(i)=wx;
%      wy=wyn+(dt/0.1)*(wy-wyn);wyn=wy;wwyy(i)=wy;
%      wz=wzn+(dt/0.1)*(wz-wzn);wzn=wz;wwzz(i)=wz;WWxyz=[wwxx;wwyy;wwzz]';
    
    %Wxyz(i)=[wxx; wyy; wzz]';
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %wx=0.000;wy=0.000;wz=0.000;
    %l0=l0 + 0.5*(-l1*wx-l2*wy-l3*wz)*dt;
    %l1=l1 + 0.5*( l0*wx-l3*wy+l2*wz)*dt;
    %l2=l2 + 0.5*( l3*wx+l0*wy-l1*wz)*dt;
    %l3=l3 + 0.5*(-l2*wx+l1*wy+l0*wz)*dt;
 % 210516   
     l0=l0+0.5*(-l1*wx-l2*wy-l3*wz)*dt; 
     l1=l1+0.5*( l0*wx-l3*wy+l2*wz)*dt;
     l2=l2+0.5*( l3*wx+l0*wy-l1*wz)*dt;
     l3=l3+0.5*(-l2*wx+l1*wy+l0*wz)*dt;
    
%     l0=l00+0.5*(-l10*wx-l20*wy-l30*wz)*dt; 
%     l1=l10+0.5*( l00*wx-l30*wy+l20*wz)*dt;
%     l2=l20+0.5*( l30*wx+l00*wy-l10*wz)*dt;
%     l3=l30+0.5*(-l20*wx+l10*wy+l00*wz)*dt;
%     l00=l0; l10=l1; l20=l2; l30=l3;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %fprintf('%9.8f %9.8f %9.8f %9.8f\n',l0,l1,l2,l3);
     l0=l0+lt0; l1=l1+lt1; l2=l2+lt2; l3=l3+lt3;
     lnor = sqrt(l0.^2 + l1.^2 + l2.^2 + l3.^2); lnorr(i)=lnor;
    % l0=l0/lnor; l1=l1/lnor; l2=l2/lnor; l3=l3/lnor;
%     ll0(i)=l0; ll1(i)=l1; ll2(i)=l2; ll3(i)=l3;
    %LLL=[ll0;ll1;ll2;ll3]';
    %fprintf('%8.5f  %8.5f  %8.5f %8.5f %8.5f %8.5f %8.5f\n', wxx,wyy,wzz,l0,l1,l2,l3);
   %
    %b11=l0*l0+l1*l1-l2*l2-l3*l3 ; b12=2*l1*l2+2*l0*l3         ; b13=2*l1*l3-2*l0*l2  ;
    %b21=2*l1*l2-2*l0*l3         ; b22=l0*l0-l1*l1+l2*l2-l3*l3 ; b23=2*l2*l3+2*l0*l1  ;
    %b31=2*l0*l2+2*l1*l3         ; b32=2*l2*l3-2*l0*l1         ; b33=l0*l0-l1*l1-l2*l2+l3*l3;
   % Таблица 5 (направляющие косинусы b11..b33)
     b11=2*l0*l0+2*l1*l1-1; b12=2*l1*l2-2*l0*l3  ; b13=2*l1*l3+2*l0*l2  ;   
     b21=2*l1*l2+2*l0*l3  ; b22=2*l0*l0+2*l2*l2-1; b23=2*l2*l3-2*l0*l1  ;
     b31=2*l1*l3-2*l0*l2  ; b32=2*l2*l3+2*l0*l1  ; b33=2*l0*l0+2*l3*l3-1;
%  %           (направляющие косинусы a11..a33) (географич.)
     a11=2*l0*l0+2*l1*l1-1; a12=2*l1*l2+2*l0*l3  ; a13=2*l1*l3-2*l0*l2  ;   
     a21=2*l1*l2-2*l0*l3  ; a22=2*l0*l0+2*l2*l2-1; a23=2*l2*l3+2*l0*l1  ;
     a31=2*l1*l3+2*l0*l2  ; a32=2*l2*l3-2*l0*l1  ; a33=2*l0*l0+2*l3*l3-1;
     % Курс, крен, дифферент
     Te= asin(a12);          Tee(i)= Te*180/3.14159;;
     Ga=-atan(a32/a22);      Gaa(i)= Ga*180/3.14159;;
     K1 =-atan2(a13,a11);    KK(i) = K1*180/3.14159;
%     KK3(i)=a13; KK4(i)=a11; KK3=KK3'; KK4=KK4';
     dK=K1-K; K=K1;  %kurs
     if (dK < -0.1) K=K-2*PI;   end
     if (dK > 0.1)  K=K+2*PI;   end
%     %KK2(i)=K1;KK4=[KK2' KK3'];
%     %Te(i)= asin(b12)         ;     %diff
%     %Ga(i)=-atan2(b32,b22); 		%kren
%     %K1(i) = K;K =-atan2(b13,b11);
%     %dK=K1-K;   %kurs
%     %if (dK < -0.1) K=K-2*PI;   end
%     %if (dK > 0.1)  K=K+2*PI;   end
%     kurs = kurs+wy*dt; kurs1(i) = kurs;
%     kren = kren+wx*dt; kren1(i) = kren;
%     diff = diff+wz*dt; diff1(i) = diff;
%     KKD1 = GR*[kurs1;kren1;diff1]';
%     %kalman filter
% 
   xOpt(i) = KK(i);
   eOpt(i+1) = sqrt((sigmaEta^2)*(eOpt(i)^2+sigmaPsi^2)/(sigmaEta^2+eOpt(i)^2+sigmaPsi^2));
   Kalm(i+1) = (eOpt(i+1))^2/sigmaEta^2;
%   %if(i>1)
   xOpt(i+1) = (xOpt(i)+a*i)*(1-Kalm(i+1))+Kalm(i+1)*z;
   z = xOpt(i+1);
   Kopt(i+1) = xOpt(i+1);
%   
% %end
     KKD = GR*[KK;Gaa;Tee]';
    %KKD(i+1)=Kopt(i+1);
    %figure(1)
    %plot(KKD,'DisplayName','voltarr','YDataSource','voltarr','LineWidth',2);figure(gcf);
    %subplot(3,1,1);plot(KKD,'LineWidth',1);figure(gcf);
    %subplot(3,1,2);plot(WWW,'LineWidth',1);figure(gcf);
    %subplot(3,1,3);plot(AAA,'LineWidth',1);figure(gcf);
    %plot(KKD);
    %plot(KKD,'LineWidth',2),hold on;
    %fprintf('%8.5f  %8.5f  %8.5f %8.5f %8.5f %8.5f %8.5f\n', wxx,wyy,wzz,l0,l1,l2,l3);
    %drawnow;
    % Скорость полюса в осях XYZ
   % mka=mka*1.001;
   
   %     AKS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %xvx(3) = xvx(4); xvx(4) = wx/3.076521397; yvx(3) = yvx(4); 
      %yvx(4) = (xvx(4) + xvx(3))+ (0.3499151339 * yvx(3));ax=yvx(4);axxx(i)=yvx(4);
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %xvy(3) = xvy(4); xvy(4) = ay/3.076521397; yvy(3) = yvy(4); 
      %yvy(4) = (xvy(4) + xvy(3))+ (0.3499151339 * yvy(3));ay=yvy(4);
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %xvz(3) = xvz(4); xvz(4) = az/3.076521397; yvz(3) = yvz(4); 
      %yvz(4) = (xvz(4) + xvz(3))+ (0.3499151339 * yvz(3));az=yvz(4);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ax=mka*(ax-0);ay=mka*ay;az=mka*(az-0);
%Axx(i) = ax; Ayy(i) = ay; Azz(i)=az; 
%ax=0.005*sin(6.28*2*dt*i);Axx(i)=ax;
%ax=randn*0.002;Axx(i)=ax;
%------------------------------- BEGIN CODE -------------------------------
     alpha=0.85; beta=0.01;         % alpha=0.85; beta=0.001; 
     xkp = xk + dt * vk;         % update estimated state x from the system
     vkp = vk;                   % update estimated velocity
     rk = ay - xkp;              % residual error
     xkp = xkp + alpha * rk;     % update our estimates 
     vkp = vkp + beta/dt * rk;   %    given residual error
     xk = xkp; vk = vkp; xkpp(i)=xkp; vkpp(i)=vkp;rkp(i)=rk;
     
    %ax=axn*0.9+0.1*ax;axn=ax;Axx(i)=ax;
    %ay=ayn+(dt/1)*(ay-ayn);ayn=ay;aayy(i)=ay;
    %az=azn+(dt/1)*(az-azn);azn=az;aazz(i)=az;AAxyz=[aaxx;aayy;aazz]';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ax1=ax-0*wy*Vz+0*wz*Vy-0*g*a12;
%     Vx=Vx1+(ax1+ax2)*0.5*dt;ax2=ax1;Vx1=Vx;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ay1=ay+0*wx*Vz-0*wz*Vx-0*g*a22;
%     Vy=Vy1+(ay1+ay2)*0.0*dt;ay2=ay1;Vy1=Vy;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     az1=az-0*wx*Vy+0*wy*Vx-0*g*a32;
%     Vz=Vz1+(az1+az2)*0.0*dt;az2=az1;Vz1=Vz;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Vz=Vz+(az-0*wx*Vy+0*wy*Vx-0*g*a32)*dt;   
%     Vxx(i)=Vx;Vyy(i)=Vy;Vzz(i)=Vz;Vxx(i)=Vx;Axyz=[Axx;Ayy;Azz]';Vxyz=[Vxx;Vyy;Vzz]';
    %ax=0.005*sin(6.28*2*dt*i);Axx(i)=ax;
    %ax=randn*0.002;Axx(i)=ax;
    %Vx=Vx1+0.5*dt*(ax+axn*1);axn=ax;Vx1=Vx;  
    %fprintf('%10.5f %10.5f  %10.5f %10.5f %10.5f %10.5f %8.3f \n',wx*GR,wy*GR,wz*GR,ax,ay,az,Temp);
    %plot(Vxyz,'LineWidth',2);figure(gcf);
 % Cкорость полюса в инерциальных осях
%     Vk=Vx*b11+Vy*b12+Vz*b13;
%     Ve=Vx*b21+Vy*b22+Vz*b23;
%     Vd=Vx*b31+Vy*b32+Vz*b33;
 % Координаты полюса в инерциальных осях
%     Ks=Ks+Vk*dt;           Ksp(i)=Ks;
%     Et=Et+Ve*dt;           Etp(i)=Et;
%     Dz=Dz+Vd*dt;           Dzp(i)=Dz; Dxyz=[Ksp;Etp;Dzp]';
    % Координаты полюса в инерциальных осях
%     Ks=Ks+Vx*dt;           Ksp(i)=Ks;
%     Et=Et+Vy*dt;           Etp(i)=Et;
%     Dz=Dz+Vz*dt;           Dzp(i)=Dz; Dxyz=[Ksp;Etp;Dzp]';tt(i)=dt*i;
%     Ks=Ks1+(Vx+Vxn)*dt*0.5; Vxn=Vx; Ks1=Ks;         Ksp(i)=Ks;
%     Et=Et1+(Vy+Vyn)*dt*0.5; Vyn=Vy; Et1=Et;         Etp(i)=Et;
%     Dz=Dz1+(Vz+Vzn)*dt*0.5; Vzn=Vz; Dz1=Dz;         Dzp(i)=Dz;
%     Dxyz=[Ksp;Etp;Dzp]';tt(i)=dt*i;
%     
%     xm(i) = randn*0.002; 
%     AVD=[tt;Axx;Vxx;Ksp;xm]';AVD1=[Axx;Vxx;Ksp]';
    %fprintf('%8.5f %8.5f  %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n',ax,ay,az,Vx,Vy,Vz,Ks,Et,Dz);
%   fprintf('%8.5f %8.5f  %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f \n',ax,ay,az,Vx,Vy,Vz,Ks,Et,Dz);
    %figure(3)
  %fprintf('%8.5f %8.5f  %8.5f \n',KK,Tee,Gaa);
  %KKD=[KK;Gaa;Tee]';
  %XX=[1 2];YY=[1 2];ZZ=[2 2];A=[5; 3; 2];
  %dcm = angle2dcm( K1,Te,Ga);
  %dcmA=dcm*A;
  %knots=5;
  %[x1,y1] = pol2cart(K1,knots);
 
   %compass(cosd(KK),sind(KK));
    %drawnow;
  %AA21=dcmA(1,:);AA22=dcmA(2,:);AA23=dcmA(3,:);
 %fprintf('%8.5f %8.5f  %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n',dcmA(1,1),dcmA(1,2),dcmA(1,3),dcmA(2,1),dcmA(2,2),dcmA(2,3),dcmA(3,1),dcmA(3,2),dcmA(3,3),KK,Gaa,Tee);
  %plot3(AA21, AA22, AA23);axis([0 5 0 3 0 3]);figure(gcf);
  %Axyz=[Axx;Ayy;Azz]';
  %figure(3)
    %plot(Dxyz);figure(gcf);
    %subplot(3,1,1);plot(Vxyz,'LineWidth',1);figure(gcf);
    %subplot(3,1,2);plot(Dxyz,'LineWidth',1);figure(gcf);
    %subplot(3,1,3);plot(AAA,'LineWidth',1);figure(gcf);
    % Вычисление широты и долготы места
 %   r0=sqrt(Ks*Ks+Et*Et+Dz*Dz);
 %   La=atan(Dz/Et);        Lap(i)=La; % долгота 
 %   Fi=asin(Ks/r0);        Fip(i)=Fi; % широта
 
    
    
   
     
end



A=16*7+3; fwrite(obj1,A)% stop
fclose(obj1); delete(obj1);

tim=toc;
time=toc/nk1;
fd=1/time;
T=time*(1:nk1);
WWWT=[0.01*T' WWW];AAAT=[T' AAA];

%   figure(2)
% plot(wyy*57.1,'LineWidth',2),hold on;
% %  figure(3) plot(timer_i2,'LineWidth',2),hold on;
%   figure(4)
% plot(timer_i1,timer_i2),hold on;
   figure(5)
% plot(KK,'LineWidth',2),hold on;

 Koptt=Kopt(1:nk1);
 KKK=[KK; Koptt]';
 T=[KK; Tee; Gaa]'; VXX=[axx; vkpp; xkpp; rkp]';
 VX=[wxx; wyy; wzz]';
  plot(KKK,'LineWidth',2)
  figure(6)
  plot(T,'LineWidth',2)
 %figure(7)
 %plot(AVD1,'LineWidth',2)
%figure(7)
  %plot(VX,'LineWidth',2)
%   figure(8)
%   plot(90*cosd(KK),90*sind(KK),'LineWidth',2); grid on;
% 
%   KK1=[KK(1) KK(1418)];
%   figure(9)
%   compass(cosd(KK1),sind(KK1));grid on;
  %compass(cosd(KK(1418)),sind(KK(1418)));grid on;
 % plot(VXX,'LineWidth',2)
%display(['Data written to: ',fileloc]);


  y=axx;n=length(y);
% % %save WWW.dat y -ascii
  Ts=1/fd;T=Ts*n;
  Fs = 1/Ts;                    % Sampling frequency
  T = 1/Fs;                     % Sample time
  L = n;                     % Length of signal
%  %t = (0:L-1)*T;                % Time vector
%  %t = 0 : Ts : T;
  NFFT = 2^nextpow2(L); % Next power of 2 from length of y
  Y = fft(y,NFFT)/L; f = Fs/2*linspace(0,1,NFFT/2+1);
  figure(12);
% % % % Plot single-sided amplitude spectrum.
  plot(f,2*abs(Y(1:NFFT/2+1))) 
  title('Single-Sided Amplitude Spectrum of y(t)')
  xlabel('Frequency (Hz)'); ylabel('|Y(f)|');grid on;
% %for i=1:n/10-2
% %    ww(i)=sum(w(10*(i-1)+1:10*i));
w0=1.4;
yy=ayy/(6.28*6.28*w0*w0);

figure(13);
plot(yy')
% s=[];
% x=[];
% wxs=GR*WWW(:,1);wys=GR*WWW(:,2);wzs=GR*WWW(:,3);
WWW=WWW';
 %save WW1.txt WWWT  -ascii
 %save('pqfile.txt', 'wxx',  '-ASCII');
 %save AAA.txt AAA  -ascii
% n=length(y);tau0=0.0186;
% jj=floor( log((n-1)/3)/log(2) );
% 
% for j=0:jj
%     fprintf('.');
%     m=2^j;
%     tau(j+1)=m*tau0;
%     D=zeros(1,n-m+1);
%     for i=1:n-m+1
%         D(i)=sum(y(i:i+m-1))/m;
%     end
%     %N sample 
%     sig(j+1)=std(D(1:m:n-m+1));
%     %AVAR 
%     %sig2(j+1)=sqrt(0.5*mean((diff(D(1:m:n-m+1)).^2)));
%     %OVERAVAR
%     %z1=D(m+1:n+1-m);
%     %z2=D(1:n+1-2*m);
%     %u=sum((z1-z2).^2);
%     %osig(j+1)=sqrt(u/(n+1-2*m)/2);
%     
%     %MVAR
%     %u=zeros(1,n+2-3*m);
%     %for L=0:n+1-3*m
%       %  z1=D(1+L:m+L);
%       %  z2=D(1+m+L:2*m+L);
%        % u(L+1)=(sum(z2-z1))^2;
%    % end
%     
%    % uu=mean(u);
%    % msig(j+1)=sqrt(uu/2)/m;
%     
%     %TVAR
%     %tsig(j+1)=tau(j+1)*msig(j+1)/sqrt(3);
%     
% end
% % figure(10)
% %  loglog(tau,sig)
% %  grid on;
%clear all;clc;close all;
%t1 = 0:.001:1;
%x1 = sin(t1); 
%y = awgn(x1,100,'measured');

% N=length(wxx);  % number of samples
% a=0.0; % acceleration
% sigmaPsi=0.002;
% sigmaEta=.02;
% k=1:N;
% x=k;A0=0.00;
% x(1)=0; z(1)=x(1)+normrnd(0,sigmaEta);
% for t=1:N-1
%   x(t+1)=x(t)+a*t +normrnd(0,sigmaPsi); 
%   %x(t+1)=x(t) + A0*sin(0.1*t)  + normrnd(0,sigmaPsi); 
%   %z(t+1)=x(t+1)+normrnd(0,sigmaEta);
%   z(t+1)=x(t+1)+wxx(t+0);
% end;
% %kalman filter
% xOpt(1)=z(1);
% eOpt(1)=sigmaEta; % eOpt(t) is a square root of the error dispersion (variance). It's not a random variable. 
% for t=1:(N-1)
%   eOpt(t+1)=sqrt((sigmaEta^2)*(eOpt(t)^2+sigmaPsi^2)/(sigmaEta^2+eOpt(t)^2+sigmaPsi^2));
%   K(t+1)=(eOpt(t+1))^2/sigmaEta^2;
%  xOpt(t+1)=(xOpt(t)+a*t)*(1-K(t+1))+K(t+1)*z(t+1);
%  %xOpt(t+1)=(xOpt(t) + A0*sin(0.1*t))*(1-K(t+1))+K(t+1)*z(t+1);
% end;
% plot(k,xOpt,k,z,k,x,k,wxx)
% %save('pqfile.txt', 'k',  '-ASCII');
 
