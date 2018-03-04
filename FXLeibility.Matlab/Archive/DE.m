cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
% Metering
MP = 51869730;
% Exchange rate
EX = 1.2;
% Cost
C_c = 30/EX;
C_d = 30/EX;

Year = 2016;
delta_t = 1;
DE_data = xlsread('DE_2016_EN_REG.xlsx');
time_vector = datetime(Year,01,01,00,30,00):(1/24*delta_t):datetime(Year,12,31,23,59,59);
time_vector = time_vector';

P_E_DA = DE_data(1:length(time_vector),1);
E_DA = DE_data(1:length(time_vector),2);
E_DA_base = zeros(size(E_DA));
E_DA_peak = zeros(size(E_DA));

window = 24*7;
reminder = mod(length(time_vector),window);
nb_w = (length(time_vector)-reminder)/window;

for w = 0:(nb_w-1)
    e_base =  min(E_DA((window*w+1):(window*w+window)));
    e_peak = max(E_DA((window*w+1):(window*w+window)));
    E_DA_base((window*w+1):(window*w+window)) = max(0,e_base);
    E_DA_peak((window*w+1):(window*w+window)) = max(0,e_peak);
end

E_DA_base((window*nb_w+1):length(time_vector)) = min(E_DA((window*nb_w+1):length(time_vector)));
E_DA_peak((window*nb_w+1):length(time_vector)) = max(E_DA((window*nb_w+1):length(time_vector)));



C_MAX = [0.1, 0.5, 1, 2, 5, 10, 15, 20];%kW/MP
C_MAX = C_MAX * MP / 1000; %MW
Output = [];
for ci = 1:length(C_MAX)
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
    [Revenue, E_D, E_C] = ESS_Energy ( C_MAX(ci), P_E_DA, E_DA, E_DA_peak, E_DA_base, time_vector, C_c, C_d);
    Output = [Output; C_MAX(ci) / MP * 1000, Revenue];
end


