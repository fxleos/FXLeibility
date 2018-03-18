main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab';
case_path = strcat(main_path,'/Cases/');
result_path = strcat(main_path,'/Experiment/LowerBounds/Predictability/Backcast/');
cd(case_path);
list = dir;
%{
CaseNames = cell(0);
for i = 1:size(list,1)
    if list(i).isdir && ~strcmp(list(i).name,'.') && ~strcmp(list(i).name,'..')
        CaseNames{end+1} = list(i).name;
    end
end
%}
CaseNames = {'PJM_RegA_ESS','PJM_DA_EV2G','PJM_DA-RT_EV2G'};
if_exist = 0;
SUMMARY = [];
for i_list = 1: size(CaseNames,2)
    Summary = struct();
    CaseName = CaseNames{i_list};
    CaseFolderName = strcat(case_path,CaseName);
    cd(result_path);
    % 7 days
    NewName = strcat(CaseName,'-Backcast');
    NewFolderName = strcat(result_path,NewName);
    cd(case_path);
    load(strcat(CaseNames{i_list},'.mat'));
    cd(result_path);
    if_exist = exist(NewName);
    cd(case_path);
    load(strcat(CaseName,'.mat'));
    cd(main_path)
    Result
    
    if ~if_exist
        cd(result_path);
        mkdir(NewFolderName);
        CaseName = NewName
        save(strcat(CaseName,'.mat'), 'CaseName','Year', 'Regime', 'Parameters','Cost','Option');
        for i_case = 1:length(Parameters.r)
            cd(CaseFolderName)
            filename = strcat(num2str(i_case),'.mat');
            load(filename)
            T_lag = 24*7/Parameters.delta_t;
            % Predicted price signal lags behind actual price signal for one week
            % So alternatively, the plan can be deemed as lead for 7 days
            temp1 = E_C((end-T_lag+1):end,:);
            E_C((T_lag+1):end,:) = E_C(1:(end-T_lag),:);
            E_C(1:T_lag,:) = temp1;
            temp1 = E_D((end-T_lag+1):end,:);
            E_D((T_lag+1):end,:) = E_D(1:(end-T_lag),:);
            E_D(1:T_lag,:) = temp1;
            temp1 = R((end-T_lag+1):end,:);
            R((T_lag+1):end,:) = R(1:(end-T_lag),:);
            R(1:T_lag,:) = temp1;
            cd(NewFolderName)
            save(filename,'E_D','E_C','R','Parameters','MP','S_driving','n_window','n_window_nan')
        end
    end
    % 1 day
    NewName = strcat(CaseName,'-Backcast1');
    NewFolderName = strcat(result_path,NewName);
    cd(case_path);
    load(strcat(CaseNames{i_list},'.mat'));
    cd(result_path);
    if_exist = exist(NewName);
    cd(case_path);
    load(strcat(CaseName,'.mat'));
    if ~if_exist && ~exist(NewName)
        cd(result_path);
        mkdir(NewFolderName);
        temp = CaseName;
        CaseName = NewName;
        save(strcat(CaseName,'.mat'), 'CaseName','Year', 'Regime', 'Parameters','Cost','Option');
        CaseName = temp;
        for i_case = 1:length(Parameters.r)
            cd(CaseFolderName)
            filename = strcat(num2str(i_case),'.mat');
            load(filename)
            T_lag = 24*1/Parameters.delta_t;
            % Predicted price signal lags behind actual price signal for one week
            % So alternatively, the plan can be deemed as lead for 7 days
            temp1 = E_C((end-T_lag+1):end,:);
            E_C((T_lag+1):end,:) = E_C(1:(end-T_lag),:);
            E_C(1:T_lag,:) = temp1;
            temp1 = E_D((end-T_lag+1):end,:);
            E_D((T_lag+1):end,:) = E_D(1:(end-T_lag),:);
            E_D(1:T_lag,:) = temp1;
            temp1 = R((end-T_lag+1):end,:);
            R((T_lag+1):end,:) = R(1:(end-T_lag),:);
            R(1:T_lag,:) = temp1;
            cd(NewFolderName)
            save(filename,'E_D','E_C','R','Parameters','MP','S_driving','n_window','n_window_nan')
        end
    end
    cd(case_path)
    load(strcat(CaseName,'.mat'));
    cd(main_path)
    Result
    Summary.CaseName = CaseName;
    Summary.max_Revenue_o = Result_summary(1,1);
    Summary.max_Profitability_Ratio_o = Result_summary(6,3)/(Result_summary(6,1)-Result_summary(6,3));
    cd(result_path)
    temp1 = case_path;
    temp2 = CaseName
    CaseName = strcat(CaseName,'-Backcast');
    case_path = result_path;
    load(strcat(CaseName,'.mat'));
    cd(main_path)
    Result
    case_path = temp1;
    CaseName = temp2;
    Summary.CaseName = CaseName;
    Summary.max_Revenue_7 = Result_summary(1,1);
    Summary.max_Profitability_Ratio_7 = Result_summary(6,3)/(Result_summary(6,1)-Result_summary(6,3));
    cd(result_path)
    temp1 = case_path;
    temp2 = CaseName;
    CaseName = strcat(CaseName,'-Backcast-Backcast1');
    case_path = result_path;
    try
        load(strcat(temp2,'-Backcast1','.mat'));
    catch
        load(strcat(temp2,'-Backcast-Backcast1','.mat'));
    end
    cd(main_path)
    Result
    case_path = temp1;
    CaseName = temp2;
    Summary.CaseName = CaseName;
    Summary.max_Revenue_1 = Result_summary(1,1);
    Summary.max_Profitability_Ratio_1 = Result_summary(6,3)/(Result_summary(6,1)-Result_summary(6,3));
    SUMMARY = [SUMMARY, Summary];
end



%{
%% Predictability
% Backcast / lag for 7 days
CaseFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/',CaseName);
NewName = strcat(CaseName,'-Backcast');
CaseName = NewName;
filename = strcat(CaseName,'.mat');
save(filename, 'CaseName','Year', 'Regime', 'Parameters','Cost','Option');

NewFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/',NewName);
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/
if ~exist(NewFolderName)
    mkdir(NewFolderName)
    for i_case = 1:length(Parameters.r)
        cd(CaseFolderName)
        filename = strcat(num2str(i_case),'.mat');
        load(filename)
        T_lag = 24*7/Parameters.delta_t;
        % Predicted price signal lags behind actual price signal for one week
        % So alternatively, the plan can be deemed as lead for 7 days
        temp = E_C((end-T_lag+1):end,:);
        E_C((T_lag+1):end,:) = E_C(1:(end-T_lag),:);
        E_C(1:T_lag,:) = temp;
        temp = E_D((end-T_lag+1):end,:);
        E_D((T_lag+1):end,:) = E_D(1:(end-T_lag),:);
        E_D(1:T_lag,:) = temp;
        temp = R((end-T_lag+1):end,:);
        R((T_lag+1):end,:) = R(1:(end-T_lag),:);
        R(1:T_lag,:) = temp;
        cd(NewFolderName)
        save(filename,'E_D','E_C','R','Parameters','MP','S_driving','n_window','n_window_nan')
    end
end

cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/
load(CaseFileName);
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab
Result
Revenue_original = Result_Revenue;
SystemSize_original = Result_SystemSize;
OperatingProfit_original = Result_OperatingProfit;
Profit_original = Result_Profit;
FixedCost_original = Result_FixedCost;
OperatingCost_original = Result_OperatingCost;
EVDrivingCost_original = Result_EVDrivingCost;

cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/
load(strcat(NewName,'.mat'))
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab
Result

hold on
plot(SystemSize_original/1000,Revenue_original/1000000,'LineWidth',2)
plot(Result_SystemSize/1000,Result_Revenue/1000000,'LineWidth',2)
title(strcat('Effect of predictibility'),'FontSize',18);
if strcmp(Option.type,'ESS')
    xlabel('System Size (MW)','FontSize',16);
else
    xlabel('Number of EV (k)','FontSize',16);
end
ylabel('Revenue(mUSD)','FontSize',16);
yyaxis right
plot(Result_SystemSize/1000,Result_Revenue ./ Revenue_original,'LineWidth',2)
ylabel('Ratio','FontSize',16);
legend({'Orginal','Backcast','Ratio'},'FontSize',16,'Location','southeast')
ylim([0,1])
%}

