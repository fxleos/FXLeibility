cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/PJM

%% Get Raw Data
    
% Day-ahead market price
    file_dap = xlsread('da_hrl_lmps_2016.xlsx');
    P_DA = file_dap(:,10);

% Real-time market price
    file_rtp = xlsread('rt_hrl_lmps_2016.xlsx');
    P_RT = file_rtp(:,10);

% Day-ahead market volume
    file_dav = xlsread('hrl_dmd_bids_2016.xlsx');
    L_DA_raw = file_dav(:,3);
    L_DA = [L_DA_raw(1:7441);L_DA_raw(7441);L_DA_raw(7442:end)];
    clear L_DA_raw
    
 % Real-time market volume not avalable, assuming 10% or day-ahead volume
    L_RT = 0.1 * L_DA;
    
% Regulation market price and volume
    file_r = xlsread('reserve_market_results_2016.xlsx');
    index = true(length(file_r),1);
    index(6577:2:8063) = false;
    index(1371) = false;
    P_R = file_r(index,5);
    R_M = file_r(index,9);
    P_R(isnan(P_R) == 1) = 0;
    R_M(isnan(R_M) == 1) = 0;
  
delta_t = 1;
time_vector = datetime(2016,01,01,00,00,00):(1/24*delta_t):datetime(2017,01,01,23,00,00);

%% Optimization
selection = [10, 100, 1000, 5000, 8000, 10000, 20000, 50000];
result_summary = zeros(length(selection),6);
for si = 1:length(selection)
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab
    [Revenue, D_DA, C_DA, D_RT, C_RT, R] = OptESS ( selection(si), P_DA, P_RT, P_R, P_RT, P_RT, L_DA, L_RT, R_M, time_vector);
    Revenue_DA = [P_DA',-P_DA']*[D_DA; C_DA];
    Revenue_RT = [P_RT',-P_RT']*[D_RT; C_RT];
    Revenue_AS = (P_R'+0.1*P_RT'-0.1*P_RT')*R;
    result_summary(si,:) = [selection(si), Revenue, Revenue_DA+Revenue_RT, Revenue_DA, Revenue_RT, Revenue_AS];
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/PJM
    filename = strcat('PJM_ESS_', num2str(selection(si)),'.csv');
    csvwrite(filename, [D_DA, C_DA, D_RT, C_RT, R]);
end
filename = strcat('PJM_ESS_summary.csv');
csvwrite(filename, result_summary);
    

selection = [100, 1000, 10000, 50000, 100000, 500000];
result_summary = zeros(length(selection),7);
for si = 1:length(selection)
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab
    [Revenue, D_DA, C_DA, D_RT, C_RT, R, N_plus, N_minus] = OptEV ( selection(si), P_DA, P_RT, P_R, P_RT, P_RT, L_DA, L_RT, R_M, time_vector);
    %% Calculated the number of EV that are being charged
    M_EV_c = zeros(length(time_vector));
    for i = 1:length(time_vector)
        for j = 1:i
            M_EV_c(i,j) = 1;
        end
    end

    for i = 6:length(time_vector)
        for j = 1:(i-5)
            M_EV_c(i,j) = 0;
        end
    end
    EV_nb_c = M_EV_c * N_plus;
    % Averge charging rate for each EV
    EV_c = (sum(C_DA)+sum(C_RT)-(sum(D_DA)+sum(D_RT)))/sum(EV_nb_c);
    % Total cost using day-ahead price
    Cost_EV_c = EV_c * P_DA' * EV_nb_c;
    Revenue_DA = [P_DA',-P_DA']*[D_DA; C_DA];
    Revenue_RT = [P_RT',-P_RT']*[D_RT; C_RT];
    Revenue_AS = (P_R'+0.1*P_RT'-0.1*P_RT')*R;
    result_summary(si,:) = [selection(si), Revenue, Revenue_DA+Revenue_RT, Revenue_DA, Revenue_RT, Revenue_AS, Cost_EV_c];
    cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/PJM
    filename = strcat('PJM_EV_', num2str(selection(si)),'.csv');
    csvwrite(filename, [D_DA, C_DA, D_RT, C_RT, R]);
end
filename = strcat('PJM_EV_summary.csv');
csvwrite(filename, result_summary);



