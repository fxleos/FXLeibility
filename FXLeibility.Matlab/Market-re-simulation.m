%% Market re-simulation

%% Germany
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

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

Data_missing = Consumption-data_file(:,2);
index = Data_missing >0;
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
        FLEX_all = [FLEX_all, struct()];
    else
        [FLEX] = FlexAnalyze (data_file(index,si), Mode);
        FLEX_all = [FLEX_all, FLEX];
    end
end

G_residual = Consumption - G_nondispatch;

Generation = zeros(size(data_file));
Generation(1,:) = data_file(1,:);
price_sim = zeros(Ti,1);
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
    price_sim(ti) = MarketSimulation(Data,Mdl_merit);
    if G_residual(ti) <= C_inflex(ti)
        for si = 1:Si
            if strcmp(Type{si},'inflex')
                Generation(ti,si) = c_inflex(si);
            end
        end
    elseif G_residual >=(C_inflex+C_flex)
        for si = 1:Si
            if strcmp(Type{si},'inflex')
                Generation(ti,si) = c_inflex(si)+c_flex(si);
            end
        end
    elseif G_residual(ti) > C_inflex(ti) && G_residual(ti) < (C_inflex+C_flex)
        ratio = (G_residual(ti) - C_inflex(ti))/C_flex;
        for si = 1:Si
            if strcmp(Type{si},'inflex')
                Generation(ti,si) = c_inflex(si)+ratio*c_flex(si);
            end
        end
    end
end



