%% Model Validation Germany - DA
load('DE_MarketSimulation.mat')
%load('price_sim_2017.mat')
%price_sim = p_sim;
CaseName = 'Germany_DA_ESS';
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab
% Get parameters
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Cases
CaseFileName = strcat(CaseName,'.mat');
load(CaseFileName);
% Create folder for result
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Experiment/ModelValidation
mkdir(CaseName);
CaseFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/Experiment/ModelValidation/',CaseName);
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

cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
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
Y = [];
nb_scenario = 100;
OperatingProfit_scenario = zeros(nb_scenario+2,length(Parameters.r));
for i_scenario = 1:nb_scenario+2
    if i_scenario == nb_scenario+2
        DATA.PI_e_I(:,1) = price_sim;
    elseif i_scenario>1
        [Y1,E1] = simulate(EstMdl_stochastic,length(time_vector));
        Y = [Y,Y1];
        DATA.PI_e_I(:,1) = price_sim+Y1*0.9;
    end
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
            OperatingProfit_scenario(i_scenario,i_case) = OperatingProfit_scenario(i_scenario,i_case)+result.objval;
        end
        [OperatingProfit_scenario(1,:);OperatingProfit_scenario(i_scenario,:)]
    end
    
end
cd(CaseFolderName)
%save(strcat(CaseName,'.mat'),'OperatingProfit_scenario')
l5 = plot(Parameters.r*MP/1000,OperatingProfit_scenario(2,:)/1000000,':','Color',[0.5 0.5 0.5],'LineWidth',1);
hold on
for i_scenario = 2:nb_scenario
    plot(Parameters.r*MP/1000,OperatingProfit_scenario(i_scenario+1,:)/1000000,':','Color',[0.5 0.5 0.5],'LineWidth',1)
end
l1 = plot(Parameters.r*MP/1000,OperatingProfit_scenario(1,:)/1000000,'Color',[ 0.8500    0.3250    0.0980],'LineWidth',3);
l2 = plot(Parameters.r*MP/1000,OperatingProfit_scenario(end,:)/1000000,'Color',[0.4940    0.1840    0.5560],'LineWidth',3);
l3 =plot(Parameters.r*MP/1000,mean(OperatingProfit_scenario(2:end-1,:),1)/1000000,'Color',[0.4660    0.6740    0.1880],'LineWidth',3);
l4 =plot(Parameters.r*MP/1000,median(OperatingProfit_scenario(2:end-1,:),1)/1000000,'Color',[0.3010    0.7450    0.9330],'LineWidth',3);
legend([l1,l2,l3,l4,l5],{'Actual price','Fitted merit-order price','Fitted merit-order price with stochastic movement (Average of scenarios)','Fitted merit-order price with stochastic movement (Median of scenarios)','Fitted merit-order price with stochastic movement (100 scenarios)'},'Location','southeast')   
ylabel('Operating Profit (mUSD)','FontSize',16);
xlabel('System Size (MW)','FontSize',16);
xlim([0,max(Parameters.r*MP/1000)])