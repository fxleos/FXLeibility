P_E_RT = DE_data(1:8784,3);
E_RT = DE_data(1:8784,4);
E_RT_base = ones(size(E_RT))*min(E_RT);
E_RT_peak = ones(size(E_RT))*max(E_RT);


time_vector = datetime(year,01,01,00,30,00):(1/24*delta_t):datetime(year,12,31,23,59,59);
time_vector = time_vector';

C_MAX = [10, 100, 1000, 5000, 8000, 10000, 20000, 50000];%MW
Output = [];
for ci = 1:length(C_MAX)
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/
    [Revenue, E_D, E_C] = ESS_Energy ( C_MAX(ci), P_E_RT, E_RT, E_RT_peak, E_RT_base, time_vector);
    Output = [Output; C_MAX(ci), Revenue];
end