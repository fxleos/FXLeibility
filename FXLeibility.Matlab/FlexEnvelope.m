%% This function is to get the evenlope lines for generation
% DATA: generation data-time
% Mode: Threshold_peak, Threshold_base, nb_intervals, Threshold_Eco_min, Threshold_Eco_max, type
% e.g. Mode = struct('Threshold_peak',0.1, 'Threshold_base',0.99, 'nb_intervals',20, 'Threshold_Eco_min',0.95, 'Threshold_Eco_max',0.05, 'type','inflex')

function [Envelope_up, Envelope_low, Envelope_benchmark, Capacity_max, Capacity_min] = FlexEnvelope (DATA, Mode)
    T = length(DATA);
    G_sorted = sort(DATA,'descend');
    % Min, Max, Peak,Base thresholds
    Capacity_peak = (G_sorted(ceil(T*Mode.Threshold_peak))+G_sorted(floor(T*Mode.Threshold_peak)))/2;
    Capacity_base = (G_sorted(ceil(T*Mode.Threshold_base))+G_sorted(floor(T*Mode.Threshold_base)))/2;
    Capacity_min = G_sorted(T);
    Capacity_max = G_sorted(1);
    % Economic envolop lines
    Envelope_up = zeros(1,Mode.nb_intervals);
    Envelope_low = Envelope_up;
    Envelope_benchmark = Envelope_up;
    %length of each interval
    g = (Capacity_max - Capacity_min)/Mode.nb_intervals;
    for ni = 1:Mode.nb_intervals
        Envelope_benchmark(ni) = Capacity_min+ (ni-0.5)*g;
    end
    if strcmp(Mode.type, 'flex')
        Envelope_up(:) = Capacity_peak;
        Envelope_low(:) = Capacity_base;
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
                Envelope_up(ni) = Capacity_min+ ni*g;
                Envelope_low(ni) = Capacity_min+ (ni-1)*g;
            else
                Envelope_up(ni) = min(Capacity_peak,(G_ni(ceil(N_ni*Mode.Threshold_Eco_max)) + G_ni(max(1,floor(N_ni*Mode.Threshold_Eco_max))))/2);
                Envelope_low(ni) = max(Capacity_base, (G_ni(ceil(N_ni*Mode.Threshold_Eco_min)) + G_ni(max(1,floor(N_ni*Mode.Threshold_Eco_min))))/2);
            end
        Envelope_up(ni) = max(Envelope_up(ni),Capacity_base);
        Envelope_low(ni) = min(Envelope_low(ni),Capacity_peak);
        end
    end
    
end
