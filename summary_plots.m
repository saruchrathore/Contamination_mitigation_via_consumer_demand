clc;
clear all;
close all;


load('50_summary.mat')
load('75_summary.mat')
load('100_summary.mat')


%% Plotting the summary statistics results using box plots

set(0, 'DefaultLineLineWidth',2);
set(0, 'DefaultaxesLineWidth',1);
set(0, 'DefaultaxesFontSize',12);
set(0, 'DefaultTextFontSize',12);
set(0, 'DefaultAxesFontName','Times');


blue=[0    0.4470    0.7410];
orange=[0.9290    0.6940    0.1250];
C=[blue;orange;blue;orange;blue;orange];

% Box plot for percentage change in the contaminated water consumed

con_water_comb=[-BF_contaminant_100;-SP_contaminant_100;...
    -BF_contaminant_75;-SP_contaminant_75;...
    -BF_contaminant_50;-SP_contaminant_50];

group = [ones(length(BF_contaminant_100),1); 2*ones(length(SP_contaminant_100),1);...
    3*ones(length(BF_contaminant_75),1); 4*ones(length(SP_contaminant_75),1);...
    5*ones(length(BF_contaminant_50),1); 6*ones(length(SP_contaminant_50),1)];

group_name=[repmat("BF (100%)", length(BF_contaminant_100), 1); repmat("SP (100%)", length(SP_contaminant_100), 1);...
    repmat("BF (75%)", length(BF_contaminant_75), 1); repmat("SP (75%)", length(SP_contaminant_75), 1);...
    repmat("BF (50%)", length(BF_contaminant_50), 1); repmat("SP (50%)", length(SP_contaminant_50), 1)];

grouporder={'BF (100%)','SP (100%)','BF (75%)','SP (75%)','BF (50%)','SP (50%)'};



figure
violinplot(con_water_comb,group_name,'GroupOrder',grouporder,'ViolinColor',{C},'MedianMarkerSize',100);
ylim([-100 max(con_water_comb)+5])
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the contaminated water consumed');

figure
boxplot(con_water_comb,group,'Labels',{'BF (100%)','SP (100%)','BF (75%)','SP (75%)','BF (50%)','SP (50%)'})
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the contaminated water consumed');



% Box plot for percentage change in the time until the network is
% contaminant-free
time_comb=[-BF_time_100;-SP_time_100;...
    -BF_time_75;-SP_time_75;...
    -BF_time_50;-SP_time_50];
figure
violinplot(time_comb,group_name,'GroupOrder',grouporder,'ViolinColor',{C},'MedianMarkerSize',100);
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the time until the network is contaminant-free');

figure
boxplot(time_comb,group,'Labels',{'BF (100%)','SP (100%)','BF (75%)','SP (75%)','BF (50%)','SP (50%)'})
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the time until the network is contaminant-free');


% Box plot for percentage change in the consumption
consumption_comb=[-BF_demand_100;-SP_demand_100;...
    -BF_demand_75;-SP_demand_75;...
    -BF_demand_50;-SP_demand_50];

figure
violinplot(consumption_comb,group_name,'GroupOrder',grouporder,'ViolinColor',{C},'MedianMarkerSize',100);
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the consumption')

figure
boxplot(consumption_comb,group,'Labels',{'BF (100%)','SP (100%)','BF (75%)','SP (75%)','BF (50%)','SP (50%)'})
xlabel('Pressure constraint identification approaches with different percentages of freedom on demand regulation');ylabel('Percentage change')
title('Percentage change in the consumption')