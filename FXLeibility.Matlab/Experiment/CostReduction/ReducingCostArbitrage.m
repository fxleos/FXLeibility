%% Cost reduction

main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab';

%% This is the main for valuation of flexibility market
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab

% Get EV parameters
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/EVanalysis
load('EV_State.mat')
s_0 = Parameters.s_0;
% n_plus and n_minus are calibrated such that N is sustain over a cycle
n_minus = n_minus * mean(n_plus)/mean(n_minus);


% Get data
Directory = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data','/',Regime,'/',num2str(Year));
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
% Market simulation
[e_peak, e_base] = Market_Simulation_basic(Regime,Year,DATA);
DATA.e_peak = e_peak;
DATA.e_base = e_base;
%Initialization
cost_reduction_rate = [0.81];
nb_scenario = length(cost_reduction_rate);
profit_ratio = zeros(size(cost_reduction_rate));
profitable_size = zeros(size(cost_reduction_rate));
InvE_ini = Cost.InvE;
RepE_ini = Cost.InvE;
zeta_ini = Parameters.zeta;
for i_scenario = 1:nb_scenario
    Cost.InvE = (1-cost_reduction_rate(i_scenario))*InvE_ini;
    Cost.RepE = (1-cost_reduction_rate(i_scenario))*RepE_ini;
    Parameters.zeta = (1-cost_reduction_rate(i_scenario))*zeta_ini;
    Profit = zeros(1,length(Parameters.r));
    REV = zeros(1,length(Parameters.r));
    Size = zeros(1,length(Parameters.r));
    for i_case =1:length(Parameters.r)
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
        Size(i_case) = Parameters.r(i_case)*MP;
        Date = floor(datenum(DATA.time_vector(1)));
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
                ObjFun = ObjFun + Revenue(Data,Parameters);
            end
            if Option.Cost
                ObjFun = ObjFun - Degradation(Data,Parameters);
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
        end
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
        REV(i_case) = f_Revenue * X;
        OpEx = f_Degradation * X;
        CapEx = FixCost(Parameters,Cost, Size(i_case), Option.type);
        Profit(i_case) = REV(i_case) - OpEx - CapEx;
        if i_case == 1
            profit_ratio(i_scenario) = Profit(i_case)/(CapEx+OpEx)
            if Profit(i_case)<0
                profitable_size(i_scenario) = 0;
                break
            end
        elseif Profit(i_case)<0
            y1 = Profit(i_case-1);
            y2 = Profit(i_case);
            x1 = Size(i_case-1);
            x2 = Size(i_case);
            profitable_size(i_scenario) = (x2*y1-x1*y2)/(y1-y2)
            break
        elseif (REV(i_case)/ REV(i_case -1) -1)/(Size(i_case)/ Size(i_case -1) -1) < 0.05
            profitable_size(i_scenario) = Size(i_case-1)
            break
        elseif i_case == length(Parameters.r)
            profitable_size(i_scenario) = Size(i_case)
            break
        end
    end
end
%{
load('Germany_ESS_CostReduction.mat')
cost_reduction_rate = [0,cost_reduction_rate];
profit_ratio = [-0.9248,profit_ratio]; % PJM: -0.87546 NSW:-0.7057
profitable_size = [0,profitable_size];
max_size = 129674*1000; %NSW: 67289 %PJM: 75829
base = 59138; %NSW: 7978 %PJM: 87793

plot(cost_reduction_rate,profit_ratio,'LineWidth',3);
hold on
yyaxis right
plot(cost_reduction_rate,profitable_size/max_size,'LineWidth',3,'Color',[0.8500    0.3250    0.0980]);
plot([cost_reduction_rate(end),1],[profitable_size(end),max_size]/max_size,':','LineWidth',3,'Color',[0.8500    0.3250    0.0980]);

set(gca,'YColor','k')
set(gca,'linewidth',2)
set(gca, 'FontSize', 14)
xlabel('Cost reduction ratio','FontSize', 16)
ylabel('Revenue ratio','FontSize', 16)
set(gca,'YTick',[-0.6:0.3:1.2],'ylim',[-0.6,1.2])
yyaxis left
ylabel('Profitability ratio','FontSize', 16)
legend({'Maximum profitability ratio','Ratio of profitable revenue to maximum potential revenue', 'Projection to zero cost'},'Location','northwest','FontSize', 12)
%}