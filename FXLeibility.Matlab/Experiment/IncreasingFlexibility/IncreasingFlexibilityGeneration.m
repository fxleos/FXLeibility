%% Flexibility penetration
main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/';
CaseName = 'Germany_DA_ESS';
%% Market re-simulation
cd(strcat(main_path,'Cases/'));
load(strcat(CaseName,'.mat'))
% Germany
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
load('DE_MarketSimulation.mat');
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);
MSOption = struct();
MSOption.consumption = 1;
MSOption.flex = 1;
MSOption.inflex = 1;
MSOption.inflex2flex = [0.05,0.1,0.15,0.2,0.25];
MSOption.nondispatch = 1;
p_sim = zeros(Ti,length(MSOption.inflex2flex));

% There are a few rows where data is missing for genertions expect brown
% coal
G_total = sum(data_file(:,:),2);
Data_missing = sum(data_file(:,:),2)-data_file(:,2);
index = Data_missing >0;
for ti = 1:Ti
    if ~index(ti)
        data_file(ti,:) = data_file(ti-168,:);
    end
end
Consumption = sum(data_file(:,:),2)*MSOption.consumption;

% Initialization
Mode = struct('Threshold_peak',0.1, 'Threshold_base',0.9, 'nb_intervals',20, 'Threshold_Eco_min',0.95, 'Threshold_Eco_max',0.05, 'type','inflex');

G_nondispatch = zeros(Ti,1);
G_inflex = zeros(Ti,1);
G_flex = zeros(Ti,1);
G_peak = zeros(Ti,1);
C_inflex = zeros(Ti,1);
C_flex = zeros(Ti,1);
C_peak = zeros(Ti,1);
if strcmp (Regime, 'PJM')
    Type = {'inflex','inflex','flex','inflex','inflex','inflex','inflex','non','non','non','non','non'};
else
    Type = {'flex','inflex','inflex','non','non','inflex','non','non','non','non','flex','inflex'};
end
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
C_peak = (C_inflex*MSOption.inflex + C_flex * MSOption.flex)/(C_inflex+C_flex)*C_peak;



for i_renew = 1 : length(MSOption.inflex2flex)
    C_inflex2flex_i = C_inflex * MSOption.inflex2flex(i_renew);
    C_inflex_i = C_inflex*MSOption.inflex - C_inflex2flex_i;
    C_flex_i = C_flex * MSOption.flex + C_inflex2flex_i;
    

    G_residual = Consumption - G_nondispatch;

    Data= struct();
    for ti = 1:Ti
        if index(ti)
            Data.C_inflex = C_inflex_i(ti);
            Data.C_flex = C_flex_i(ti);
            Data.C_peak = C_peak(ti);
            Data.G_residual = G_residual(ti);
            p_sim(ti,i_renew) = MarketSimulation(Data,Mdl_merit);
        else
            p_sim(ti,i_renew) = 0;
        end
    end


end
if strcmp (Regime, 'PJM')
    p_sim (p_sim >1000) = 1000;
    p_sim (p_sim <0) = 0;
else
    p_sim (p_sim >3600) = 3600;
    p_sim (p_sim <-600) = -600;
end

P_forplot = [];
for i_renew = 1:length(MSOption.nondispatch)
    cd(strcat(main_path,'duration_plot'));
    DP = duration_plot(p_sim(:,i_renew));
    close
    P_forplot = [P_forplot, DP.percentiles(:,2)];
end
DP = duration_plot(p_sim);
close
P_forplot = [P_forplot, DP.percentiles(:,2)];

%% This is the main for valuation of flexibility market
cd(main_path)

% Get EV parameters
cd(strcat(main_path,'EVanalysis'))
load('EV_State.mat')
s_0 = Parameters.s_0;
% n_plus and n_minus are calibrated such that N is sustain over a cycle
n_minus = n_minus * mean(n_plus)/mean(n_minus);

% Get data
cd(main_path)
cd ..
Directory = strcat('Data/',Regime,'/',num2str(Year));
cd(Directory)
DATA = struct();
if strcmp(Regime,'PJM')
    EX = 1.0;
elseif strcmp(Regime,'DE') || strcmp(Regime,'Germany')
    EX = 1.2; %2018-01-01
else
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

cd(main_path)
% For Germany we take the total consumption (generation instead of DA
% exchange limit
if strcmp(Regime,'DE') || strcmp(Regime,'Germany')
    filename = strcat('DE_',num2str(Year),'_GEN.xlsx');
    DATA.e_hat(:,1) = sum(xlsread(filename),2);
end
%Initialization
%Y = [];
nb_scenario = 100;
max_revenue = zeros(nb_scenario,length(MSOption.inflex2flex));
profitability_ratio = zeros(nb_scenario,length(MSOption.inflex2flex));
payment = zeros(nb_scenario,length(MSOption.inflex2flex));

for i_scenario = 1:nb_scenario
    %[Y1,E1] = simulate(EstMdl_stochastic,length(time_vector));
    %Y = [Y,Y1];
    Y1 = Y(:,i_scenario);
    for i_renew = 1:length(MSOption.inflex2flex)
        DATA.PI_e_I(:,1) = p_sim(:,i_renew)+Y1*0.9;
        payment(i_scenario,i_renew) = DATA.PI_e_I(:,1)' * DATA.e_hat(:,1);
        % Market simulation
        DATA.e_peak = G_nondispatch*MSOption.nondispatch + C_inflex + C_flex;
        DATA.e_base = G_nondispatch*MSOption.nondispatch + C_inflex*(1-MSOption.inflex2flex);
        
        for i_case =1:length(Parameters.r)
            if i_case == 1 || i_case ==length(Parameters.r)
                E_D = zeros(length(time_vector),length(Parameters.I));
                E_C = zeros(length(time_vector),length(Parameters.I));
                R = zeros(length(time_vector),length(Parameters.J));
                S_driving = 0;
                n_window = 0;
                n_window_nan = 0;
                if strcmp(Regime,'PJM')
                    MP = 30331401;
                elseif strcmp(Regime,'DE') || strcmp(Regime,'Germany')
                    MP = 51869730;
                else
                    MP = 3364428;
                end
                if strcmp(Option.type,'ESS')
                    Parameters.r_max = Parameters.r(i_case)*MP/1000;
                    Parameters.s_0 = s_0*Parameters.r_max*Parameters.E2P_ratio;
                else
                    % r_max is per EV
                    Parameters.r_max = Parameters.BpEV/1000;
                    % number of EV
                    Parameters.n_plus = Parameters.r(i_case)*MP*n_plus;%%%%
                    Parameters.n_minus = Parameters.r(i_case)*MP*n_minus;%%%%
                    Parameters.n_0 = Parameters.r(i_case)*MP; % Assume all car online at time 0
                    % s is per EV
                    Parameters.s_plus = Parameters.BpEV*Parameters.E2P_ratio*s_plus/1000;
                    Parameters.s_minus = Parameters.BpEV*Parameters.E2P_ratio*s_minus/1000;
                    % S_0
                    Parameters.s_0 = s_0*Parameters.r_max*Parameters.E2P_ratio*Parameters.n_0;
                end

                Date = floor(datenum(DATA.time_vector(1)));
                fixed_cost = 0;
                operating_cost = 0;
                operating_profit = 0;
                while (Date + Parameters.T*Parameters.delta_t/24) <= floor(datenum(DATA.time_vector(end)))
                    n_window = n_window+1;
                    % Define simulation scope
                    index = datenum(DATA.time_vector) < (Date + Parameters.T*Parameters.delta_t/24) & datenum(DATA.time_vector) >= Date;
                    % Rescope the data
                    Data = struct();
                    data_list = fieldnames(DATA);
                    for i_list = 1:length(data_list)
                        Data.(data_list{i_list}) = DATA.(data_list{i_list})(index,:);
                    end
                    ObjFun = zeros(1,(length(Parameters.I)*2+length(Parameters.J))*Parameters.T);
                    if Option.Revenue 
                        f_Revenue = Revenue(Data,Parameters);
                        ObjFun = ObjFun + f_Revenue;
                    end
                    if Option.Cost
                        f_Degradation = Degradation(Data,Parameters);
                        ObjFun = ObjFun - f_Degradation;
                    end
                    % Constraints
                    if Option.TechnologyConstraints
                        TechOutput = Technology (Parameters, Data, Option.type);
                        [A1, RHS1, Sense1] = TechConstraints(Parameters, TechOutput, Option.type);
                        if strcmp(Option.type,'EV2G')
                            S_driving = S_driving + TechOutput.S_driving;
                        end
                    else
                        A1 = [];
                        RHS1 = [];
                        Sense1 = [];
                    end
                    if Option.MarketConstraints
                        [A2, RHS2, Sense2] = MarketConstraints(Parameters, Data, Regime);
                    else
                        A2 = [];
                        RHS2 = [];
                        Sense2 = [];
                    end
                    try
                        clear model;
                        model.A = sparse([A1;A2]);
                        model.obj = ObjFun;
                        model.rhs = [RHS1;RHS2];
                        model.sense = [Sense1;Sense2];
                        model.vtype = 'C';
                        model.modelsense = 'max';

                        clear params;
                        params.outputflag = 0;
                        %params.resultfile = 'mip1.lp';

                        result = gurobi(model, params);

                        %disp(result)

                        %fprintf('Obj: %e\n', result.objval);

                    catch gurobiError
                        'Error reported\n'
                    end
                    if strcmp(result.status,'INF_OR_UNBD')
                        result.x = zeros((2*length(Parameters.I)+length(Parameters.J))*Parameters.T,1);
                        result.objval = 0;
                        'No result for this period'
                        n_window_nan = n_window_nan +1;
                        if Option.TechnologyConstraints && strcmp(Option.type,'EV2G')
                            S_driving = S_driving - TechOutput.S_driving;
                        end
                    end
                    for i = 1:length(Parameters.I)
                        E_D(index,i) = result.x(((i-1)*Parameters.T+1):(i*Parameters.T));
                        E_C(index,i) = result.x(((i-1)*Parameters.T+1+length(Parameters.I)*Parameters.T):((i+length(Parameters.I))*Parameters.T));
                    end
                    for j = 1:length(Parameters.J)
                        R(index,j) = result.x(((j-1)*Parameters.T+1+length(Parameters.I)*Parameters.T*2):((j+length(Parameters.I)*2)*Parameters.T));
                    end
                    Date = Date+ Parameters.T*Parameters.delta_t/24;
                    if i_case ==length(Parameters.r)
                        max_revenue(i_scenario,i_renew) = max_revenue(i_scenario,i_renew) + f_Revenue * result.x;
                    elseif i_case == 1
                        operating_cost = operating_cost + f_Degradation * result.x;
                        operating_profit = operating_profit + result.objval;
                    end
                end
                if i_case ==length(Parameters.r)
                    max_revenue;
                elseif i_case == 1
                    fixed_cost = FixCost(Parameters,Cost, Parameters.r(i_case) * MP, Option.type);
                    profitability_ratio(i_scenario,i_renew) = (operating_profit - fixed_cost)/(fixed_cost+operating_cost);
                end
            end
        end
    end
    i_scenario
    payment(i_scenario,:)
    max_revenue(i_scenario,:)
    profitability_ratio(i_scenario,:)
end
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Experiment/IncreasingFlexibility
mkdir(CaseName);
%CaseFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/ProCases/',CaseName);
%cd(CaseFolderName);
%save(strcat(CaseName,'-result.mat'),'payment','max_revenue','profitability_ratio');
%{
payment_plot = median(payment);
payment_plot = payment_plot - payment_plot(4);
payment_plot = payment_plot / 59138;
bar(MSOption.MSOption.,payment_plot,'FaceColor',[ 0    0.4470    0.7410],'EdgeColor',[ 0    0.4470    0.7410])
set(gca,'XTick',[0.85:0.05:1.15],'xlim',[0.8,1.2])
set(gca,'YTick',[-150000:50000:150000], 'ylim',[-150000 150000])
set(gca,'linewidth',2)
set(gca, 'FontSize', 14)
legend({'Change of total payment in day-ahead market'},'Location','northeast','FontSize',16)
ylabel('USD/(a-MW consumption)','FontSize',16);
xlabel('Change of Renewable Capacity','FontSize',16);
set(gca, 'YTickLabel', [-150000 -100000 -50000 0 50000 100000 150000]);

max_revenue_plot = median(max_revenue);
max_revenue_plot = max_revenue_plot/max_revenue_plot(4)*239000000;
max_revenue_plot = max_revenue_plot / 59138;
bar(MSOption.nondispatch,max_revenue_plot,'FaceColor',[0.3010    0.7450    0.9330],'EdgeColor',[ 0.3010    0.7450    0.9330])
set(gca,'YTick',[0:4000:16000],'ylim',[0,16000])
hold on
yyaxis right
plot(MSOption.nondispatch,median(profitability_ratio),'LineWidth',3, 'Color', [0.8500    0.3250    0.0980])
set(gca,'YTick',[-1:0.25:0],'ylim',[-1,0])
set(gca,'XTick',[0.85:0.05:1.15],'xlim',[0.8,1.2])
set(gca,'YColor','k')
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
legend({'Maximum arbitrage revenue','Maximum profitability ratio'},'Location','northwest','FontSize',14)
ylabel('Profitability ratio','FontSize',16);
yyaxis left
ylabel('USD/(a-MW consumption)','FontSize',16);
xlabel('Change of renewable capacity','FontSize',16);
%}