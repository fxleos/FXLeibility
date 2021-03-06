%% Technology simulation module
% Parameters include: eta_s, eta_d, eta_c, s_0, (additional for EV:
% n_0,n_plus, n_minus, s_plus, s_minus), I, J (e.g J = [ 1 3]
% Data include: DATA.DELTA_PLUS_J, DATA.DELTA_MINUS_J
% Notice: n_plus/minus, s_plus, s_minus, start at SUN-00:00
function [Output] = Technology (Parameters, DATA, mode)
    Output = struct();
    T = size (DATA.time_vector,1);
    H = zeros(T);
    for i = 1:T
        for j = 1:i
            H(i,j) = Parameters.eta_s^(i-j);
        end
    end
    H_I = [];
    H_J = [];
    DELTA_PLUS_J = [];
    DELTA_MINUS_J = [];
    for i = 1:length(Parameters.I)
        H_I = [H_I,H];
    end
    for j = 1:length(Parameters.J)
        H_J = [H_J,H];
        DELTA_PLUS_J = [DELTA_PLUS_J,DATA.DELTA_PLUS_J(:,Parameters.J(j))'];
        DELTA_MINUS_J = [DELTA_MINUS_J,DATA.DELTA_MINUS_J(:,Parameters.J(j))'];
    end
    DELTA_PLUS_J = diag(DELTA_PLUS_J);
    DELTA_MINUS_J = diag(DELTA_MINUS_J);
    S_0 = Parameters.s_0 * ones(T,1);
    if  strcmp(mode,'ESS')
        Output.h_0 = Parameters.eta_s * H * S_0;
    else
        time_vector = DATA.time_vector;
        t_start = (weekday(time_vector(1))-1)*24+hour(time_vector(1))+1;
        % Re-organize the vector to have the same start time
        n_plus = [Parameters.n_plus(t_start:end),Parameters.n_plus(1:(t_start-1))];
        n_minus = [Parameters.n_minus(t_start:end),Parameters.n_minus(1:(t_start-1))];
        s_plus = [Parameters.s_plus(t_start:end),Parameters.s_plus(1:(t_start-1))];
        s_minus = [Parameters.s_minus(t_start:end),Parameters.s_minus(1:(t_start-1))];
        
        len_cyc = length(n_plus);
        nb_cyc = (T - mod(T,len_cyc))/len_cyc;
        N_plus = zeros(T,1);
        N_minus = zeros(T,1);
        S_plus = zeros(T,1);
        S_minus = zeros(T,1);
        for n = 1:nb_cyc
            N_plus((len_cyc*(n-1)+1):(len_cyc*n)) = n_plus;
            N_minus((len_cyc*(n-1)+1):(len_cyc*n)) = n_minus;
            S_plus((len_cyc*(n-1)+1):(len_cyc*n)) = s_plus;
            S_minus((len_cyc*(n-1)+1):(len_cyc*n)) = s_minus;
        end
        N_plus((len_cyc*n+1):T) = n_plus(1:mod(T,len_cyc));
        N_minus((len_cyc*n+1):T) = n_minus(1:mod(T,len_cyc));
        S_plus((len_cyc*n+1):T) = s_plus(1:mod(T,len_cyc));
        S_minus((len_cyc*n+1):T) = s_minus(1:mod(T,len_cyc));
        S_plus = diag(S_plus);
        S_minus = diag(S_minus);
        N_0 = ones(T,1) * Parameters.n_0;
        L = zeros(T);
        for i = 1:T
            for j = 1:i
                L(i,j) = 1;
            end
        end
        Output.N = eye(T) * N_0 + L * N_plus - L * N_minus;
        Output.S_driving = sum(S_plus * N_plus - S_minus * N_minus);    %Energy consumed for driving
        Output.h_0 = Parameters.eta_s * H * S_0 + H * S_plus * N_plus - H * S_minus * N_minus;
    end
    Output.h = [-1/Parameters.eta_d * H_I, Parameters.eta_c * H_I, H_J * (-1/Parameters.eta_d * DELTA_PLUS_J + Parameters.eta_c * DELTA_MINUS_J)];
end