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
nb_scenario = 10;
OperatingProfit_scenario = zeros(nb_scenario+1,length(Parameters.r));
for i_scenario = 1:nb_scenario+1
    if i_scenario>1
        [Y1,E1] = simulate(EstMdl_stochastic,length(time_vector));
        Y = [Y,Y1];
        DATA.PI_e_I(:,1) = p_sim+Y1*0.9;
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
        OperatingProfit_scenario
    end
end
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/ProCases
mkdir(CaseName);
CaseFolderName = strcat('/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/ProCases/',CaseName);
cd(CaseFolderName);
save(strcat(CaseName,'-result.mat'),'OperatingProfit_scenario');
%Data = struct('PI_e_I', 'PI_e_J', 'PI_r_J', 'DELTA_J','DELTA_PLUS_J','DELTA_MINUS_J','e_hat', 'r_hat', 'e_base', 'e_peak', 'time_vector')

%Parameters = struct('I','J','T','delta_t','zeta','eta_s', 'eta_d', 'eta_c', 's_0','n_0','n_plus', 'n_minus', 's_plus', 's_minus','r_max', 'E2P_ratio')