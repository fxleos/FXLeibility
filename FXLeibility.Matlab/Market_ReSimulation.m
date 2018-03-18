%% Market re-simulation
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/ProCases/
load(strcat(CaseName,'.mat'))
%% Germany
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
load('DE_MarketSimulation.mat');
filename = 'DE_2017_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

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

Type = {'flex','inflex','inflex','non','non','inflex','non','non','non','non','flex','inflex'};

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

G_nondispatch = G_nondispatch*MSOption.nondispatch;
C_peak = (C_inflex*MSOption.inflex + C_flex * MSOption.flex)/(C_inflex+C_flex)*C_peak;
try
    C_inflex2flex = C_inflex * MSOption.inflex2flex;
catch
    C_inflex2flex = 0;
end
C_inflex = C_inflex*MSOption.inflex - C_inflex2flex;
C_flex = C_flex * MSOption.flex + C_inflex2flex;

G_residual = Consumption - G_nondispatch;

p_sim = zeros(Ti,1);

Data= struct();
for ti = 1:Ti
    if index(ti)
        Data.C_inflex = C_inflex(ti);
        Data.C_flex = C_flex(ti);
        Data.C_peak = C_peak(ti);
        Data.G_residual = G_residual(ti);
        p_sim(ti) = MarketSimulation(Data,Mdl_merit);
    else
        p_sim(ti) = 0;
    end
end

p_sim (p_sim >3600) = 3600;
p_sim (p_sim <-500) = -600;
