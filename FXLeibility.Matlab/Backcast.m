cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/
CaseName = 'Germany_B_ESS';
CaseFileName = strcat(CaseName,'.mat');
load(CaseFileName)

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


