%% Train the Market Simulation model using historical data

%% PJM
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
filename = 'PJM_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

% There are a few rows where data is missing for genertions expect brown
% coal
G_total = sum(data_file(:,:),2);
index = G_total >0;
% Initialization
Mode = struct('Threshold_peak',0.1, 'Threshold_base',0.9, 'nb_intervals',20, 'Threshold_Eco_min',0.95, 'Threshold_Eco_max',0.05, 'type','inflex');

G_nondispatch = zeros(Ti,1);
G_inflex = zeros(Ti,1);
G_flex = zeros(Ti,1);
G_peak = zeros(Ti,1);
C_inflex = zeros(Ti,1);
C_flex = zeros(Ti,1);
C_peak = zeros(Ti,1);

Type = {'inflex','inflex','flex','inflex','inflex','inflex','inflex','non','non','non','non','non'};

for si = 1:Si
    Mode.type = Type{si};
    if strcmp(Type{si},'non')
        G_nondispatch = G_nondispatch + data_file(:,si);
    else
        [FLEX] = FlexAnalyze (data_file(index,si), Mode);
        for ti = 2:Ti
            c_inflex = FlexEnvelopMatch(data_file(ti,si),FLEX.Capacity_inflex,FLEX.Capacity_benchmark);
            c_flex = FlexEnvelopMatch(data_file(ti,si),FLEX.Capacity_flex,FLEX.Capacity_benchmark);
            c_peak = FlexEnvelopMatch(data_file(ti,si),FLEX.Capacity_peak,FLEX.Capacity_benchmark);
            C_inflex(ti) = C_inflex(ti) + c_inflex;
            C_flex(ti) = C_flex(ti) + c_flex;
            C_peak(ti) = C_peak(ti) + c_peak;
        end
        C_inflex(1) = C_inflex(2);
        C_flex(1) = C_flex(2);
        C_peak(1) = C_peak(2);
    end
end
G_residual = G_total - G_nondispatch;
%% Get price data
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
% Exchange rate
EX = 1;
Year = 2016;
delta_t = 1;
PJM_data = xlsread('PJM_2016_EN_REG.xlsx');
time_vector = datetime(Year,01,01,00,30,00):(1/24*delta_t):datetime(Year,12,31,23,59,59);
time_vector = time_vector';

P_E_DA = PJM_data(1:length(time_vector),1)*EX;
%% Original data
figure;
scatter(G_total(index),P_E_DA(index));
title('Germany Day-Ahead Market Data 2016','FontSize',18);
xlabel('Volume (MWh)','FontSize',16);
ylabel('Price($/MWh)','FontSize',16);

%% Classification
index_inflex = G_residual <= C_inflex;
index_inflex = index_inflex & index;
G_inflex = C_inflex - G_residual;
index_flex = G_residual > C_inflex & G_residual < (C_inflex+C_flex);
index_flex = index_flex & index;
G_flex = G_residual - C_inflex;
index_peak = G_residual >=(C_inflex+C_flex);
index_peak = index_peak & index;
G_peak = G_residual - C_inflex - C_flex;

% Result
figure;
%subplot(2,1,1)
scatter((1+G_peak(index_peak) ./ C_peak(index_peak)),P_E_DA(index_peak));
hold on
scatter(G_flex(index_flex) ./ C_flex (index_flex), P_E_DA(index_flex));
scatter(-(G_inflex(index_inflex) ./ C_inflex(index_inflex)),P_E_DA(index_inflex));
title('Processed Day-Ahead Market Data','FontSize',18);
ylabel('Price($/MWh)','FontSize',16);
xlabel('Ratio of Production to Available Capacity','FontSize',16);
figure;
%subplot(2,1,2)
scatter(G_total(index_peak),P_E_DA(index_peak));
hold on
scatter(G_total(index_flex),P_E_DA(index_flex));
scatter(G_total(index_inflex),P_E_DA(index_inflex));
title('Classification of Day-Ahead Market Data','FontSize',18);
xlabel('Volume (MWh)','FontSize',16);
ylabel('Price($/MWh)','FontSize',16);
legend('Peak','Mid.','Inflex.','Location','southeast')

%% Regression
modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
% Peak
x_peak = 1 - G_peak(index_peak) ./ C_peak(index_peak);
y_peak = P_E_DA(index_peak);
rng('default')
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
beta0 = [30;1000;4];
beta_peak = nlinfit(x_peak,y_peak,modelfun,beta0,opts);
error_peak = y_peak - modelfun(beta_peak, x_peak);

% Inflex
%{
x_inflex = 1 - G_inflex(index_inflex) ./ C_inflex(index_inflex);
%i = x<0.95;
%x = x(i);
y_inflex = P_E_DA(index_inflex);
%y = y(i);
rng('default')
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
beta_inflex = nlinfit(x_inflex,y_inflex,modelfun,beta0);
error_inflex = y_inflex - modelfun(beta_inflex, x_inflex);
%}
load('DE_MarketSimulation.mat');
beta_inflex = Mdl_merit.beta_inflex;
% Mid
modelmid = @(b,x)(b(1)*x+b(2));

x = G_flex(index_flex) ./ C_flex (index_flex);

i = x <= 0.3;
x_1 = x(i);

y = P_E_DA(index_flex) - max (modelfun(beta_inflex,x));
b_1 = [x(i)\y(i);max(modelfun(beta_inflex,x))];
error_1 = y(i) - modelmid(b_1,x(i));

i = x >= 0.5;
y = min(modelfun(beta_peak,x)) - P_E_DA(index_flex);
b_3 = [(1-x(i))\y(i); min(modelfun(beta_peak,x))-(1-x(i))\y(i)];
error_3 = y(i) - modelmid(b_3,x(i));

b_2 = [(modelmid(b_1,0.35) - modelmid(b_3,0.65)); 0.35*modelmid(b_3,0.65) - 0.65*modelmid(b_1,0.35)]/(-0.3);
error_2 = y(i) - modelmid(b_2,x(i));

% Result
figure;
%subplot(2,1,1)
scatter((1+G_peak(index_peak) ./ C_peak(index_peak)),P_E_DA(index_peak));%,'MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[0 0.4470 0.7410]);
hold on
scatter(G_flex(index_flex) ./ C_flex (index_flex), P_E_DA(index_flex));%,'MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[0 0.4470 0.7410]);
scatter(-(G_inflex(index_inflex) ./ C_inflex(index_inflex)),P_E_DA(index_inflex));%,'MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[0 0.4470 0.7410]);
plot(2-sort(x_peak),modelfun(beta_peak, sort(x_peak)), 'Color','r','LineWidth',3)
plot(sort(x(x<=0.35)),modelmid(b_1,sort(x(x<=0.35))), 'Color','r','LineWidth',3);
plot(sort(x(x>0.35 & x < 0.65)),modelmid(b_2,sort(x(x>0.35 & x < 0.65))), 'Color','r','LineWidth',3);
plot(sort(x(x>=0.65)),modelmid(b_3,sort(x(x>=0.65))), 'Color','r','LineWidth',3);
plot(sort(x_inflex)-1,modelfun(beta_inflex, sort(x_inflex)), 'Color','r','LineWidth',3)
title('Regressed merit-order curve','FontSize',18);
ylabel('Price($/MWh)','FontSize',16);
xlabel('Ratio of Production to Available Capacity','FontSize',16);

Parameters = struct('beta_inflex',beta_inflex, 'b_1',b_1, 'b_2',b_2, 'b_3', b_3,'beta_peak',beta_peak);
price_sim = zeros(Ti,1);
Data= struct();
for ti = 1:Ti
    if index(ti)
        Data.C_inflex = C_inflex(ti);
        Data.C_flex = C_flex(ti);
        Data.C_peak = C_peak(ti);
        Data.G_residual = G_residual(ti);
        price_sim(ti) = MarketSimulation(Data,Parameters);
    else
        price_sim(ti) = 0;
    end
end