
% https://ch.mathworks.com/help/econ/arima-class.html
% https://ch.mathworks.com/help/econ/arima.forecast.html
% https://ch.mathworks.com/help/econ/arima.estimate.html
% https://ch.mathworks.com/help/econ/arima.simulate.html#inputarg_Mdl


error = price_sim - P_E_DA;

Mdl = arima('Constant',0,'ARLags',[1,2],'SARLags',[24,168],'D',0,...
'Seasonality',0,'MALags',[1,2],'SMALags',168);
[EstMdl,EstParamCov] = estimate(Mdl,error(171:end),'Y0',error(1:170));

hold on
for i = 1:20
    [Y1,E1] = simulate(EstMdl,480);
    plot(price_sim(1:480)+Y1(1:480)*0.5,'c');
end
plot(P_E_DA(1:480),'r');




