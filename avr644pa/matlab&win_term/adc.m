clear all; close,clc;
load adc_test1.t;A=adc_test1;A1=A(:,1);A2=A(:,2);
figure(1)
plot([A1 A2*0.001+1.0] )