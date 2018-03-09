%% Market re-simulation
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/ProCases/temp
load('MSOption.mat')
%% Germany
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
load('DE_MarketSimulation.mat')
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

Data_missing = sum(data_file(:,:),2)-data_file(:,2);
index = Data_missing >0;
for ti = 1:Ti
    if ~index(ti)
        data_file(ti,:) = data_file(ti-168,:);
    end
end

Consumption = sum(data_file(:,:),2)*MSOption.consumption;

Type = {'flex','inflex','inflex','non','non','inflex','wind','wind','solar','non','flex','inflex'};

for si = 1:Si
    if strcmp(Type{si},'wind')
        data_file(:,si) = data_file(:,si)*MSOption.wind;
    elseif strcmp(Type{si},'solar')
        data_file(:,si) = data_file(:,si)*MSOption.solar;
    elseif strcmp(Type{si},'inflex')
        data_file(:,si) = data_file(:,si)*MSOption.inflex;
    elseif strcmp(Type{si},'flex')
        data_file(:,si) = data_file(:,si)*MSOption.flex;
    end
end

% There are a few rows where data is missing for genertions expect brown
% coal


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
FLEX_all = [];
for si = 1:Si
     Mode.type = Type{si};
    if strcmp(Type{si},'non')
        G_nondispatch = G_nondispatch + data_file(:,si);
        FLEX_all = [FLEX_all, FLEX];
    else
        [FLEX] = FlexAnalyze (data_file(index,si), Mode);
        FLEX_all = [FLEX_all, FLEX];
    end
end

G_residual = Consumption - G_nondispatch;

Generation = zeros(size(data_file));
Generation(1,:) = data_file(1,:);
p_sim = zeros(Ti,1);
Data= struct();
ratio = 0;
for ti = 2:Ti
    c_inflex = zeros(Si,1);
    for si = 1:Si
        if ~strcmp(Type{si},'non')
            c_inflex(si) = FlexEnvelopMatch(Generation(ti-1,si),FLEX_all(si).Capacity_inflex,FLEX_all(si).Capacity_benchmark);
            c_flex(si) = FlexEnvelopMatch(Generation(ti-1,si),FLEX_all(si).Capacity_flex,FLEX_all(si).Capacity_benchmark);
            c_peak(si) = FlexEnvelopMatch(Generation(ti-1,si),FLEX_all(si).Capacity_peak,FLEX_all(si).Capacity_benchmark);
            C_inflex(ti) = C_inflex(ti) + c_inflex(si);
            C_flex(ti) = C_flex(ti) + c_flex(si);
            C_peak(ti) = C_peak(ti) + c_peak(si);
        end
    end
    Data.C_inflex = C_inflex(ti);
    Data.C_flex = C_flex(ti);
    Data.C_peak = C_peak(ti);
    Data.G_residual = G_residual(ti);
    p_sim(ti) = MarketSimulation(Data,Mdl_merit);
    if p_sim(ti) < -3000
        'pause'
    end
    if G_residual(ti) <= C_inflex(ti)
        for si = 1:Si
            if ~strcmp(Type{si},'non')
                Generation(ti,si) = c_inflex(si);
            end
        end
    elseif G_residual(ti) >=(C_inflex(ti)+C_flex(ti))
        ratio = (G_residual(ti) - C_inflex(ti)-C_flex(ti))/C_peak(ti);
        for si = 1:Si
            if ~strcmp(Type{si},'non')
                Generation(ti,si) = c_inflex(si)+c_flex(si)+ratio*c_peak(si);
            end
        end
    elseif G_residual(ti) > C_inflex(ti) && G_residual(ti) < (C_inflex(ti)+C_flex(ti))
        ratio = (G_residual(ti) - C_inflex(ti))/C_flex(ti);
        for si = 1:Si
            if ~strcmp(Type{si},'non')
                Generation(ti,si) = c_inflex(si)+ratio*c_flex(si);
            end
        end
    end
end


p_sim (p_sim >3000) = 3000;
p_sim (p_sim <-3000) = -3000;

