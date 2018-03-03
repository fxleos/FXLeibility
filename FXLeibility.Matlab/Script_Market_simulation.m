%% Get P and C

cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
filename = 'DE_2016_GEN.xlsx';
data_file = xlsread(filename);
[Ti, Si] = size(data_file);

% There are a few rows where data is missing for genertions expect brown
% coal
G_total = sum(data_file(:,:),2);
Data_missing = G_total-data_file(:,2);
index = Data_missing >0;
% Initialization
Mode = struct('Threshold_peak',0.1, 'Threshold_base',0.99, 'nb_intervals',20, 'Threshold_Eco_min',0.95, 'Threshold_Eco_max',0.05, 'type','inflex');

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
        [Envelope_up, Envelope_low, Envelope_benchmark, Capacity_max, Capacity_min] = FlexEnvelope (data_file(index,si), Mode);
        for ti = 2:Ti
            c_inflex = FlexEnvelopMatch(data_file(ti,si),Envelope_low,Envelope_benchmark);
            c_flex = FlexEnvelopMatch(data_file(ti,si),Envelope_up,Envelope_benchmark) - c_inflex;
            C_inflex(ti) = C_inflex(ti) + c_inflex;
            C_flex(ti) = C_flex(ti) + c_flex;
            C_peak(ti) = Capacity_max - c_flex - c_inflex;%
            
        end
    end
end
% Adjust
C_inflex = C_inflex+ C_flex*0.1;
C_peak = C_peak+ C_flex*0.1;
C_flex = C_flex*0.8;
            
G_residual = G_total - G_nondispatch;
index_inflex = G_residual <= C_inflex;
index_inflex = index_inflex & index;
G_inflex = C_inflex - G_residual;
index_flex = G_residual > C_inflex & G_residual < (C_inflex+C_flex);
index_flex = index_flex & index;
G_flex = G_residual - C_inflex;
index_peak = G_residual >=(C_inflex+C_flex);
index_peak = index_peak & index;
G_peak = G_residual - C_inflex - C_flex;

% Regression
% flex
x = G_flex(index_flex) ./ C_flex (index_flex);
y = P_E_DA(index_flex);
X = [ones(length(x),1) x];
b = X\y;
yR = X*b;
Rsq = 1 - sum((y - yR).^2)/sum((y - mean(y)).^2)
% Peak
x = 1 - G_peak(index_peak) ./ C_peak(index_peak);
y = P_E_DA(index_peak);
modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
rng('default')
%b = [30;1000;4];
%y = modelfun(b,x)% + normrnd(0,0.1,100,1);
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
beta0 = [30;1000;4];
beta = nlinfit(x,y,modelfun,beta0,opts);
% inflex
x = 1 - G_inflex(index_inflex) ./ C_inflex(index_inflex);
y = P_E_DA(index_inflex);
modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
rng('default')
%b = [30;1000;4];
%y = modelfun(b,x)% + normrnd(0,0.1,100,1);
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
beta = nlinfit(x,y,modelfun,beta0);
