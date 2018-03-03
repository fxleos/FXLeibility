%% This function is to get the flex/inflex part of generation
% DATA: generation data-time
% Mode: Threshold_peak, Threshold_base, nb_intervals, Threshold_Eco_min, Threshold_Eco_max, type
% e.g. Mode = struct('Threshold_peak',0.1, 'Threshold_base',0.99, 'nb_intervals',20, 'Threshold_Eco_min',0.95, 'Threshold_Eco_max',0.05, 'type','inflex')
% Output: Envelope_up, Envelope_low, Envelope_benchmark, Capacity_max, Capacity_min
function [Output] = FlexAnalyze (DATA, Mode)
    T = length(DATA);
    G_sorted = sort(DATA,'descend');
    % Min, Max, Peak,Base thresholds
    Capacity_peak = (G_sorted(ceil(T*Mode.Threshold_peak))+G_sorted(floor(T*Mode.Threshold_peak)))/2;
    Capacity_base = (G_sorted(ceil(T*Mode.Threshold_base))+G_sorted(floor(T*Mode.Threshold_base)))/2;
    Capacity_min = G_sorted(T);
    Capacity_max = G_sorted(1);
    % Flexibility variables
    Output_inflex = zeros(1,Mode.nb_intervals);
    Output_flex = zeros(1,Mode.nb_intervals);
    Output_peak = zeros(1,Mode.nb_intervals);
    Output_benchmark = zeros(1,Mode.nb_intervals);
    %length of each interval
    g = (Capacity_max - Capacity_min)/Mode.nb_intervals;
    for ni = 1:Mode.nb_intervals
        Output_benchmark(ni) = Capacity_min+ (ni-0.5)*g;
    end
    if strcmp(Mode.type, 'flex')
        Output_inflex(:) = Capacity_base;
        Output_flex(:) = Capacity_peak - Capacity_base;
        Output_peak(:) = Capacity_max - Capacity_peak;
    else
        for ni = 1:Mode.nb_intervals
            % Screen data within the window of each interval and get the data
            % of its next moment
            index_ni = (DATA >= (Capacity_min+ (ni-1)*g)) & (DATA < (Capacity_min+ ni*g));
            index_ni(2:length(index_ni)) = index_ni(1:(length(index_ni)-1));
            index_ni(1) = 0;
            G_ni = DATA(index_ni);
            G_ni = sort(G_ni, 'descend');
            N_ni = size(G_ni, 1);
            if N_ni <= 1
                Output_inflex(ni) = max(Capacity_base, Capacity_min+ (ni-1)*g);
                Output_flex(ni) = min(Capacity_peak, Capacity_min+ ni*g)-Output_inflex(ni);
                Output_peak(ni) = max(0,Capacity_min+ ni*g - Capacity_peak);
            else
                Output_inflex(ni) = max(Capacity_base, (G_ni(ceil(N_ni*Mode.Threshold_Eco_min)) + G_ni(max(1,floor(N_ni*Mode.Threshold_Eco_min))))/2);
                Output_flex(ni) = min(Capacity_peak,(G_ni(ceil(N_ni*Mode.Threshold_Eco_max)) + G_ni(max(1,floor(N_ni*Mode.Threshold_Eco_max))))/2)-Output_inflex(ni);
                Output_peak(ni) = max(0,(G_ni(ceil(N_ni*Mode.Threshold_Eco_max)) + G_ni(max(1,floor(N_ni*Mode.Threshold_Eco_max))))-Capacity_peak);
            end
        end
    end
    Output = struct('Capacity_inflex',Output_inflex,'Capacity_flex',Output_flex, 'Capacity_peak',Output_peak,'Capacity_benchmark',Output_benchmark);
end
