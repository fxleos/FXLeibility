%% This script is to get the duration plot of the generation by type
% read file
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

% Preprocessing data
G_gas = data_file(:,1);
G_coal_b = data_file(:,2);
G_coal_h = data_file(:,3);
G_bio = data_file(:,4);
G_hydro = data_file(:,5);
G_nuclear = data_file(:,6);
G_wind = sum(data_file(:,[7,8]),2);
G_pv = data_file(:,9);
G_otherRE = data_file(:,10);
G_phes = data_file(:,11);
G_otherCONV = data_file(:,12);
G_total = sum(data_file(:,:),2);

% There are a few rows where data is missing for genertions expect brown
% coal
Data_missing = G_total-G_coal_b;
index = Data_missing >0;
%
% Find the bounds for 10% (peak) and 99% (minimum) generations
G_bound_min = zeros(Si,1);
G_bound_peak = zeros(Si,1);
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/duration_plot
Duration_curve = duration_plot(G_gas(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Gas','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Gas.png'))
G_bound_min(1) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(1) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_coal_b(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Brown Coal','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Coal_b.png'))
G_bound_min(2) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(2) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_coal_h(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Hard Coal','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Coal_h.png'))
G_bound_min(3) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(3) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_bio(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Biomass','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Bio.png'))
G_bound_min(4) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(4) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_hydro(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Hydro','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_hydro.png'))
G_bound_min(5) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(5) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_nuclear(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Nuclear','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Nuclear.png'))
G_bound_min(6) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(6) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_wind(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Wind','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
G_bound_min(7) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(7) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_pv(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Solar','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_PV.png'))
G_bound_min(9) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(9) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_otherRE(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Other Renewables','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_otherRE.png'))
G_bound_min(10) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(10) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_phes(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Pumped-Hydro Storage','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_PHES.png'))
G_bound_min(11) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(11) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_otherCONV(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Other Conventional','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_otherCONV.png'))
G_bound_min(12) = Duration_curve.percentiles(2,2); % Minimum generation for 99% of time
G_bound_peak(12) = Duration_curve.percentiles(91,2); % Peak geneation for 10% of time

Duration_curve = duration_plot(G_total(index));
set(gca,'FontSize',12)
title('Generation Duration Curve - Total','FontSize',18);
ylabel('Actual Production(MWh/h)','FontSize',16);
xlabel('Percentage of Production Greater Than y-value (%)','FontSize',16);
%saveas(gcf,strcat(filename,'_Total.png'))

%% This script is to get the evenlope lines of the generation by type

% get the number of sources and time length
Bounds = [];
Curves = [];
for si = 1:Si
    G = data_file(:,si);
    G = G(index);
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


G_nondispatch = sum(data_file(:,[4,5,7:10]),2);
G_inflex = zeros(Ti,1);
G_flex = zeros(Ti,1);
G_peak = zeros(Ti,1);

for si = [2,6] 
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
        G_flex(ti) = G_flex(ti) + min(Curves(gi,(si*2-1)),G_bound_peak(si)) - Curves(gi,(si*2));
        G_peak(ti) = G_peak(ti) + max((Curves(gi,(si*2-1))-G_bound_peak(si)),0);
    end
end
G_inflex(1) = G_inflex(2);
G_flex(1) = G_flex(2);

G_inflex = G_inflex + ones(size(G_inflex))*sum(G_bound_min([1,11,12]));
G_flex = G_flex + ones(size(G_flex))*(sum(G_bound_peak([1,11,12]))-sum(G_bound_min([1,11,12])));
G_peak = G_peak + ones(size(G_peak))*(sum(Curves([1,21,23]))+sum(G_bound_peak([1,11,12])));

