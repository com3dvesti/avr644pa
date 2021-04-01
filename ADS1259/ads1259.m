clear all;close all;clc; format long e;
load ADS1259_1.txt; A=ADS1259_1;nk=length(A);k1=1000;
data=A(:,2);
ma1=mean(data(10:2000));
std_a1=std(data(10:2000));
ma2=mean(data(4500:5400));
std_a2=std(data(4500:5400));
figure(1)
plot(data)
figure(2)
hist(data)