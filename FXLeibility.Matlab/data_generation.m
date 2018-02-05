%% This script is to get the duration plot of the generation by type
% read file
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

% There are a few rows where data is missing for genertions expect brown
% coal
G_total = sum(data_file(:,:),2);
Data_missing = G_total-data_file(:,2);
index = Data_missing >0;

%% Min, Max and Peak thresholds for each source
Capacity_peak = zeros(Si,1);
Threshold_peak = 0.1;   % 10%
Capacity_base = zeros(Si,1);
Threshold_base = 0.9;
Capacity_min = zeros(Si,1);
Capacity_max = zeros(Si,1);

for si = 1: Si
    % Actual generation of source si
    G = data_file(index,si);
    G = sort(G,'descend');
    N_si = size(G,1);
    Capacity_peak(si) = (G(ceil(N_si*Threshold_peak))+G(floor(N_si*Threshold_peak)))/2;
    Capacity_base(si) = (G(ceil(N_si*Threshold_base))+G(floor(N_si*Threshold_base)))/2;
    Capacity_min(si) = G(N_si);
    Capacity_max(si) = G(1);
end

%% Economic envolop lines for each source
nb_intervals = 20;
Capacity_Eco_min = zeros(Si,nb_intervals);
Threshold_Eco_min = 0.95;
Capacity_Eco_max = zeros(Si,nb_intervals);
Threshold_Eco_max = 0.05;
Capacity_benchmark = zeros(Si,nb_intervals);
g = zeros(Si,1);

for si = 1: Si
    G = data_file(index,si);
    % length of each interval
    g(si) = (Capacity_max(si) - Capacity_min(si))/nb_intervals;
    for ni = 1:nb_intervals
        Capacity_benchmark(si,ni) = Capacity_min(si)+ (ni-0.5)*g(si);
        % Screen data within the window of each interval and get the data
        % of its next moment
        index_ni = (G >= (Capacity_min(si)+ (ni-1)*g(si))) & (G < (Capacity_min(si)+ ni*g(si)));
        index_ni(2:length(index_ni)) = index_ni(1:(length(index_ni)-1));
        index_ni(1) = 0;
        G_ni = G(index_ni);
        G_ni = sort(G_ni, 'descend');
        N_ni = size(G_ni, 1);
        if N_ni <= 1
            Capacity_Eco_max(si,ni) = Capacity_min(si)+ ni*g(si);
            Capacity_Eco_min(si,ni) = Capacity_min(si)+ (ni-1)*g(si);
        else
            Capacity_Eco_max(si,ni) = min(Capacity_peak(si),(G_ni(ceil(N_ni*Threshold_Eco_max)) + G_ni(max(1,floor(N_ni*Threshold_Eco_max))))/2);
            Capacity_Eco_min(si,ni) = max(Capacity_base(si), (G_ni(ceil(N_ni*Threshold_Eco_min)) + G_ni(max(1,floor(N_ni*Threshold_Eco_min))))/2);
        end
        Capacity_Eco_max(si,ni) = max(Capacity_Eco_max(si,ni),Capacity_base(si));
        Capacity_Eco_min(si,ni) = min(Capacity_Eco_min(si,ni),Capacity_peak(si));
    end
end


G_nondispatch = sum(data_file(:,[4,5,7:10]),2);
G_inflex = zeros(Ti,1);
G_flex = zeros(Ti,1);

for si = [2,3,6,12]
    G = data_file(:,si);
    
    for ti = 2:Ti
        gi = ceil((G(ti-1) - Capacity_min(si)) / g(si));
        if gi <= 0
            gi = 1;
        end
        G_inflex(ti) = G_inflex(ti) + Capacity_Eco_min(si, gi);
        G_flex(ti) = G_flex(ti) + Capacity_Eco_max(si,gi) - Capacity_Eco_min(si,gi);
    end
end
G_inflex(1) = G_inflex(2);
G_flex(1) = G_flex(2);
%G_inflex = G_inflex + ones(size(G_inflex))*sum(Capacity_base([1,11]));
G_flex = G_flex + ones(size(G_flex))*(sum(Capacity_peak([1,11])));%-sum(Capacity_base([1,11])));


%{
%% This script is to get the evenlope lines of the generation by type
% read file
data_file = xlsread('DE_2016_GEN.xlsx');
% get the number of sources and time length
[Ti, Si] = size(data_file);
Bounds = [];
Curves = [];
for si = 1:Si
    G = data_file(:,si);
    G = G(G~=0);
    G_max = max(G);
    G_min = min(G);
    %Divide into n intervals
    nb_intervals = 10;
    g = (G_max - G_min)/nb_intervals;
    G_up = zeros(nb_intervals,1);
    G_down = zeros(nb_intervals,1);
    for gi = 1: nb_intervals
        G_up(gi) = (gi+1)*g + G_min;
        G_down(gi) = gi*g + G_min;
    end
    G_divided = (G_up+G_down)/2;
    for ti = 2: size(G,1)
        gi = ceil((G(ti-1) - G_min) / g);
        if gi <= 0
            gi = 1;
        end
        if G(ti) > G_up(gi)
            G_up(gi) = G(ti);
        end
        if G(ti) < G_down(gi)
            G_down(gi) = G(ti);
        end
    end
    Bounds = [Bounds, G_max, G_min];
    Curves = [Curves, G_up, G_down];
end


G_inflex = zeros(Ti,1);
G_flex = zeros(Ti,1);

G_nondispatch = sum(data_file(:,4:10),2);
for si = [2,12] %[1:4,6,11,12]
    G = data_file(:,si);
    G_max = Bounds(si*2-1);
    G_min = Bounds(si*2);
    g = (G_max - G_min)/nb_intervals;
    for ti = 2:Ti
        gi = ceil((G(ti-1) - G_min) / g);
        if gi <= 0
            gi = 1;
        end
        G_inflex(ti) = G_inflex(ti) + Curves(gi,(si*2));
        G_flex(ti) = G_flex(ti) + Curves(gi,(si*2-1)) - Curves(gi,(si*2));
    end
end
G_inflex(1) = G_inflex(2);
G_flex(1) = G_flex(2);
%}
