%% Post - analysis

% Get the case file
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases
CaseFileName = strcat(CaseName,'.mat');
load(CaseFileName);

% Get data
Directory = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data','/',Regime,'/',num2str(Year));
cd(Directory)
DATA = struct();
DATA.PI_e_I = xlsread('Pi_E_I.xlsx');
DATA.PI_e_J = xlsread('Pi_E_J.xlsx');
DATA.PI_r_J = xlsread('Pi_R_J.xlsx');
DATA.DELTA_J = xlsread('Delta_J.xlsx');
DATA.DELTA_PLUS_J = xlsread('Delta_p_J.xlsx');
DATA.DELTA_MINUS_J = xlsread('Delta_n_J.xlsx');
DATA.e_hat = xlsread('E-hat_I.xlsx');
DATA.r_hat = xlsread('R-hat_J.xlsx');
time_vector = datetime(Year,01,01,00,30,00):(1/24*Parameters.delta_t):datetime(Year,12,31,23,59,59);
time_vector = time_vector';
DATA.time_vector = time_vector;

% Go the result file

CaseFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases/',CaseName);

%% Calculate
r_list = Parameters.r;

% The revenue and cost line (power capacity,  energy capacity, Revenue,
% Degradation Cost, Fixed Cost, EV energy cost for driving
Result_rev_cost = zeros(length(r_list),6);
for i_case =1:length(r_list)
    cd(CaseFolderName)
    CaseResultFileName = strcat(num2str(i_case),'.mat');
    load(CaseResultFileName);
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
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
    Result_rev_cost(i_case, 6) = S_driving * mean(DATA.PI_e_I(1));
end


%TechOutput = Technology (Parameters, DATA, Option.type);
