%% This is the basic function of market simulation to get the bounds for market constraints

function [e_peak, e_base] = Market_Simulation_basic(Regime, Year, DATA)
    if strcmp(Regime,'NSW') || strcmp(Regime,'AEMO-NSW') || strcmp(Regime, 'Australia')
        Mode = struct();
        Mode.Threshold_peak = 0.1;
        Mode.Threshold_base = 0.9;
        T = length(DATA.e_hat(:,2));
        G_sorted = sort(DATA.e_hat(:,2),'descend');
        e_peak = (G_sorted(ceil(T*Mode.Threshold_peak))+G_sorted(floor(T*Mode.Threshold_peak)))/2*ones(T,1);
        e_base = (G_sorted(ceil(T*Mode.Threshold_base))+G_sorted(floor(T*Mode.Threshold_base)))/2*ones(T,1);
    else
        
        if strcmp(Regime,'Germany') || strcmp(Regime,'de')
            Regime = 'DE';
        end
        filename = strcat(Regime,'_',num2str(Year),'_GEN.xlsx');
        data_file = xlsread(filename);
        [Ti, Si] = size(data_file);

        % There are a few rows where data is missing for genertions expect brown
        % coal
        G_total = sum(data_file(:,:),2);
        Data_missing = G_total-data_file(:,2);
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
        
        if strcmp(Regime,'PJM')
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
        e_peak = G_nondispatch + C_inflex + C_flex;
        e_base = G_nondispatch + C_inflex;
    end
end