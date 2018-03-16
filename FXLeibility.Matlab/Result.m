%% Post - analysis

% Get the case file
try
    cd(case_path);
catch
    main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab';
    case_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/';
    cd(case_path);
end
CaseFileName = strcat(CaseName,'.mat');
load(CaseFileName);

% Get data
Directory = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data','/',Regime,'/',num2str(Year));
cd(Directory)
DATA = struct();
if strcmp(Regime,'PJM')
    MP = 30331401;
    EX = 1.0;
elseif strcmp(Regime,'DE') || strcmp(Regime,'Germany')
    MP = 51869730;
    EX = 1.2; %2018-01-01
else
    MP = 3364428;
    EX = 0.78;
end
try
    DATA.PI_e_I = xlsread('Pi_E_I.xlsx')*EX;
end
try
    DATA.PI_e_J = xlsread('Pi_E_J.xlsx')*EX;
end
try
    DATA.PI_r_J = xlsread('Pi_R_J.xlsx')*EX;
end
try
    DATA.DELTA_J = xlsread('Delta_J.xlsx');
    DATA.DELTA_PLUS_J = xlsread('Delta_p_J.xlsx');
    DATA.DELTA_MINUS_J = xlsread('Delta_n_J.xlsx');
end
try
    DATA.e_hat = xlsread('E-hat_I.xlsx');
end
try
    DATA.r_hat = xlsread('R-hat_J.xlsx');
end

time_vector = datetime(Year,01,01,00,30*Parameters.delta_t,00):(1/24*Parameters.delta_t):datetime(Year,12,31,23,59,59);
time_vector = time_vector';
DATA.time_vector = time_vector;

% Go the result file

CaseFolderName = strcat(case_path,CaseName);

%% Calculate
r_list = Parameters.r;

% The revenue and cost line (power capacity,  energy capacity, Revenue,
% Degradation Cost, Fixed Cost, EV energy cost for driving
Result_rev_cost = zeros(length(r_list),6);
N_window = zeros(length(r_list),1);
N_window_nan = zeros(length(r_list),1);
for i_case =1:length(r_list)
    cd(CaseFolderName)
    CaseResultFileName = strcat(num2str(i_case),'.mat');
    load(CaseResultFileName);
    cd(main_path);
    N_window = n_window;
    N_window_nan(i_case) = n_window_nan;
    f_Revenue = Revenue(DATA,Parameters);
    f_Degradation = Degradation(DATA,Parameters);
    X = [];
    for i = 1:length(Parameters.I)
        X = [X;E_D(:,i)];
    end
    for i = 1:length(Parameters.I)
        X = [X;E_C(:,i)];
    end
    for j = 1:length(Parameters.J)
        X = [X;R(:,j)];
    end
    
    Result_rev_cost(i_case, 1) = Parameters.r(i_case) * MP; %kW or number of EVs
    Result_rev_cost(i_case, 2) = Parameters.r(i_case) * MP * Parameters.E2P_ratio;
    Result_rev_cost(i_case, 3) = f_Revenue * X;
    Result_rev_cost(i_case, 4) = f_Degradation * X;
    Result_rev_cost(i_case, 5) = FixCost(Parameters,Cost, Result_rev_cost(i_case, 1), Option.type);
    if ~strcmp(Regime,'AEMO-NSW')
        Result_rev_cost(i_case, 6) = S_driving * mean(DATA.PI_e_I(:,1));
    else
        Result_rev_cost(i_case, 6) = S_driving * mean(DATA.PI_e_I(:,2));
    end
end

Result_SystemSize = Result_rev_cost(:,1);
Result_Revenue = Result_rev_cost(:,3)-Result_rev_cost(:,6);
Result_OperatingProfit = Result_rev_cost(:,3) -Result_rev_cost(:,4)-Result_rev_cost(:,6);
Result_Profit = Result_rev_cost(:,3) -Result_rev_cost(:,4)-Result_rev_cost(:,5)-Result_rev_cost(:,6);
Result_FixedCost = Result_rev_cost(:,5);
Result_OperatingCost = Result_rev_cost(:,4);
Result_EVDrivingCost = -Result_rev_cost(:,6);

Scenarios= cell(0);
%% Summary
Result_summary = zeros(6,4);
% Max Revenue
for i_case =2:length(r_list)
    i_s = 1;
    if (Result_Revenue(i_case)/Result_Revenue(i_case-1)-1 )/(Result_SystemSize(i_case)/ Result_SystemSize(i_case-1)-1) < 0.05
        Scenarios{end+1} = 'Max Revenue';
        Result_summary(i_s,1) = Result_Revenue(i_case-1);
        Result_summary(i_s,2) = Result_OperatingProfit(i_case-1);
        Result_summary(i_s,3) = Result_Profit(i_case-1);
        Result_summary(i_s,4) = Result_SystemSize(i_case-1);
        break
    elseif i_case == length(r_list)
        Scenarios{end+1} = 'Max Revenue (not ultimate)';
        Result_summary(1,1) = Result_Revenue(i_case);
        Result_summary(1,2) = Result_OperatingProfit(i_case);
        Result_summary(1,3) = Result_Profit(i_case);
        Result_summary(1,4) = Result_SystemSize(i_case);
        break
    end
end
% Max profitable size
for i_case = 1:length(r_list)
    if Result_Profit(i_case) < 0
        if i_case == 1
            Scenarios{end+1} = 'Max Profitable Size (no result)';
            Result_summary(2,1) = 0;
            Result_summary(2,2) = 0;
            Result_summary(2,3) = 0;
            Result_summary(2,4) = 0;
            break
        else
            Scenarios{end+1} = 'Max Profitable Size';
            x1 = Result_SystemSize(i_case-1);
            x2 = Result_SystemSize(i_case,1);
            y1 = Result_Profit(i_case-1);
            y2 = Result_Profit(i_case);
            x = (x2*y1-x1*y2)/(y1-y2);
            Result_summary(2,1) = (Result_Revenue(i_case)-Result_Revenue(i_case-1))/(x2-x1)*x+Result_Revenue(i_case-1);
            Result_summary(2,2) = (Result_OperatingProfit(i_case) - Result_OperatingProfit(i_case-1))/(x2-x1)*x + Result_OperatingProfit(i_case-1);
            Result_summary(2,3) = 0;
            Result_summary(2,4) = x;
            break
        end
    end
end
%Max Profit
if strcmp(Scenarios{end},'Max Profitable Size (no result)')
    Scenarios{end+1} = 'Max Profit (no result)';
    Result_summary(3,1) = 0;
    Result_summary(3,2) = 0;
    Result_summary(3,3) = 0;
    Result_summary(3,4) = 0;
else
    max_profit = 0;
    for i_case =1:length(r_list)
        if Result_Profit(i_case) < max_profit
            Scenarios{end+1} = 'Max Profit';
            Result_summary(3,1) = Result_Revenue(i_case-1);
            Result_summary(3,2) = Result_OperatingProfit(i_case-1);
            Result_summary(3,3) = max_profit;
            Result_summary(3,4) = Result_SystemSize(i_case -1);
            break
        else
            max_profit = Result_Profit(i_case);
        end
    end
end
% Max Operating-Profitable Size
for i_case = 1:length(r_list)
    if Result_OperatingProfit(i_case) < 0
        if i_case == 1
            Scenarios{end+1} = 'Max Operating-Profitable Size (no result)';
            Result_summary(4,1) = 0;
            Result_summary(4,2) = 0;
            Result_summary(4,3) = 0;
            Result_summary(4,4) = 0;
            break
        else
            Scenarios{end+1} = 'Max Operating-Profitable Size';
            x1 = Result_SystemSize(i_case-1);
            x2 = Result_SystemSize(i_case,1);
            y1 = Result_OperatingProfit(i_case-1);
            y2 = Result_OperatingProfit(i_case);
            x = (x2*y1-x1*y2)/(y1-y2);
            Result_summary(4,1) = (Result_Revenue(i_case)-Result_Revenue(i_case-1))/(x2-x1)*x+Result_Revenue(i_case-1);
            Result_summary(4,2) = 0;
            Result_summary(4,3) = (Result_Profit(i_case) - Result_Profit(i_case-1))/(x2-x1)*x + Result_Profit(i_case-1);
            Result_summary(4,4) = x;
            break
        end
    elseif i_case == length(r_list)
        Scenarios{end+1} = 'Max Operating-Profitable Size (not ultimate)';
        Result_summary(4,1) = Result_Revenue(i_case);
        Result_summary(4,2) = Result_OperatingProfit(i_case);
        Result_summary(4,3) = Result_Profit(i_case);
        Result_summary(4,4) = Result_SystemSize(i_case);
        break
    end
end

if strcmp(Scenarios{end},'Max Operating-Profitable Size (no result)')
    Scenarios{end+1} = 'Max Operating Profit (no result)';
    Result_summary(5,1) = 0;
    Result_summary(5,2) = 0;
    Result_summary(5,3) = 0;
    Result_summary(5,4) = 0;
else
    for i_case =2:length(r_list)
        if (Result_OperatingProfit(i_case)/Result_OperatingProfit(i_case-1)-1 )/(Result_SystemSize(i_case)/ Result_SystemSize(i_case-1)-1) < 0.05
            Scenarios{end+1} = 'Max Operating Profit';
            Result_summary(5,1) = Result_Revenue(i_case-1);
            Result_summary(5,2) = Result_OperatingProfit(i_case-1);
            Result_summary(5,3) = Result_Profit(i_case-1);
            Result_summary(5,4) = Result_SystemSize(i_case -1);
            break
        elseif i_case == length(r_list)
            Scenarios{end+1} = 'Max Operating Profit (not ultimate)';
            Result_summary(5,1) = Result_Revenue(i_case);
            Result_summary(5,2) = Result_OperatingProfit(i_case);
            Result_summary(5,3) = Result_Profit(i_case);
            Result_summary(5,4) = Result_SystemSize(i_case);
            break
        end
    end
end

Result_summary(1:5,1:3) = round(Result_summary(1:5,1:3)/1000000); %mUSD
Result_summary(1:5,4) = round(Result_summary(1:5,4)/1000); %MW or k
% Small Size
Scenarios{end+1} = 'Small Size';
Result_summary(6,1) = Result_Revenue(1)/1000000;
Result_summary(6,2) = Result_OperatingProfit(1)/1000000;
Result_summary(6,3) = Result_Profit(1)/1000000;
Result_summary(6,4) = Result_SystemSize(1)/1000;

%{
plot(Result_SystemSize/1000, Result_Revenue/1000000,'LineWidth',3);
hold on
plot(Result_SystemSize/1000, Result_OperatingProfit/1000000,'LineWidth',3);
plot(Result_SystemSize/1000, Result_Profit/1000000,'LineWidth',3);
plot(Result_SystemSize/1000, (Result_OperatingProfit - Result_Profit)/1000000,'LineWidth',3);
xlim([0,max(Result_SystemSize/1000)])
legend({'Revenue','Operating Profit','Profit','Fixed Cost'},'FontSize',14,'Location','southeast')
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
set(gca,'YTick',[0:200:800],'ylim',[0,800])
ylabel('Revenue or cost (mUSD)','FontSize',16);
xlabel('System Size (MW)','FontSize',16);

xlim([0,300])
ylim([0,80])


plot(Result_SystemSize/1000, Result_Revenue/1000000,'LineWidth',8);
hold on
plot(Result_SystemSize/1000, Result_OperatingProfit/1000000,'LineWidth',8);
plot(Result_SystemSize/1000, Result_Profit/1000000,'LineWidth',8);
plot(Result_SystemSize/1000, (Result_OperatingProfit - Result_Profit)/1000000,'LineWidth',8);
xlim([0,250])
ylim([0 70])
set(gca,'linewidth',8)
set(gca, 'FontSize', 28)
%}