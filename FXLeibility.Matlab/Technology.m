%% Technology simulation module
% Parameters include: eta_s, eta_d, eta_c, s_0, (additional for EV: n_0,n_plus, n_minus, s_plus, s_minus)
% Data include: DATA.DELTA_PLUS_J, DATA.DELTA_MINUS_J, I, J (e.g J = [ 1 3]
function [h, h_0] = Technology (Parameters, DATA, mode)
    T = size (DATA.DELTA_PLUS_J,1);
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
    for i = 1:length(DATA.I)
        H_I = [H_I,H];
    end
    for j = 1:length(DATA.J)
        H_J = [H_J,H];
        DELTA_PLUS_J = [DELTA_PLUS_J,DATA.DELTA_PLUS_J(:,DATA.J(j))'];
        DELTA_MINUS_J = [DELTA_MINUS_J,DATA.DELTA_MINUS_J(:,DATA.J(j))'];
    end
    DELTA_PLUS_J = diag(DELTA_PLUS_J);
    DELTA_MINUS_J = diag(DELTA_MINUS_J);
    S_0 = Parameters.s_0 * ones(T,1);
    if  strcmp(mode,'ESS')
        h_0 = Parameters.eta_s * H * S_0;
    else
        len_cyc = length(Parameters.n_plus);
        nb_cyc = (T - mod(T,len_cyc))/len_cyc;
        N_plus = zeros(T,1);
        N_minus = zeros(T,1);
        for n = 1:nb_cyc
            N_plus((len_cyc*(n-1)+1):(len_cyc*n)) = Parameters.n_plus;
            N_minus((len_cyc*(n-1)+1):(len_cyc*n)) = Parameters.n_minus;
        end
        N_plus((len_cyc*n+1):T) = Parameters.n_plus(1:mod(T,len_cyc));
        N_minus((len_cyc*n+1):T) = Parameters.n_minus(1:mod(T,len_cyc));
        %{
        N_0 = ones(T,1) * Parameters.n_0;
        L = zeros(T);
        for i = 1:T
            for j = 1:i
                L(i,j) = 1;
            end
        end
        N = eye(T) * N_0 + L * N_plus - L * N_minus;
        %}
        h_0 = Parameters.eta_s * H * S_0 + Parameters.s_plus * H * N_plus - Parameters.s_minus * H * N_minus;
    end
    h = [-1/Parameters.eta_d * H_I, Parameters.eta_c * H_I, H_J * (-1/Parameters.eta_d * DELTA_PLUS_J + Parameters.eta_c * DELTA_MINUS_J)];
end