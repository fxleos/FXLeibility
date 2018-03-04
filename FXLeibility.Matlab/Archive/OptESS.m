function [Revenue, D_DA, C_DA, D_RT, C_RT, R] = OptESS ( ESS_cap, P_DA, P_RT, P_R, P_RU, P_RD, L_DA, L_RT, R_M, time_vector)
%Optimization for Energy Storage System with given parameters

%% Built-in parameters
    % Efficiencies
    eta_c = 0.9;
    eta_d = 0.9;
    eta_s = 1.0;
    % Frequency control calling probability
    delta_RU = 0.1;
    delta_RD = 0.1;
    delta_r = 0.2;
    % Simulation time step
    t_sim = 7;      %Unit: day
    % Non-visual bidding limit
    delta_nvb = 0.05;

%% Interpret inputs
    L_DA_max = max(L_DA);
    L_RT_max = max(L_RT);
    delta_t = datenum(time_vector(2)-time_vector(1))*24;    %Unit: h
    d_max = ESS_cap;    %MW
    c_max = d_max;      %MW
    s_max = 4 * d_max;  %MWh
    s_0 = 0;

%% Initialization
    Revenue = 0;
    D_DA = zeros(length(time_vector),1);
    C_DA = D_DA;
    D_RT = D_DA;
    C_RT = D_DA;
    R = D_DA;
    Date = floor(datenum(time_vector(1)));

%% Simulation
    cd /Library/gurobi752/mac64/matlab 
    gurobi_setup
    
    while Date <= floor(datenum(time_vector(end)))
        % Define simulation scope
        index = datenum(time_vector) < (Date + t_sim) & datenum(time_vector) >= Date;
        
        % Extract data for period to be simulated
        P_DA_s = P_DA(index);
        P_RT_s = P_RT(index);
        P_R_s = P_R(index);
        P_RU_s = P_RU(index);
        P_RD_s = P_RD(index);
        L_DA_s = L_DA(index);
        L_RT_s = L_RT(index);
        R_M_s = R_M(index);
        T = length(P_DA_s);
        
        % Calculate matrix
        M_s = zeros(T);
        for i = 1 : T
            for j = 1 : i
                M_s(i,j) = eta_s^(i-j);
            end
        end
        I = eye(T);
        O = zeros(T);
        S_0 = s_0 * ones(T,1);
        S_max = s_max * ones(T,1);
        
        % Defined Model
        % Objective Function
        ObjFun = [P_DA_s', -P_DA_s', P_RT_s', -P_RT_s', P_R_s'+delta_RU*P_RU_s'-delta_RD*P_RD_s']*delta_t;
        % Constraint 1
        A1 = -[-1/eta_d*M_s, eta_c*M_s, -1/eta_d*M_s, eta_c*M_s,-1/eta_d*(delta_RU+delta_r)*M_s + eta_c*delta_RD*M_s]*delta_t;
        RHS1= eta_s * M_s * S_0;
        % C 2
        A2 = [-1/eta_d*M_s, eta_c*M_s, -1/eta_d*M_s, eta_c*M_s,-1/eta_d*delta_RU*M_s + eta_c*(delta_RD+delta_r)*M_s]*delta_t;
        RHS2= S_max - eta_s * M_s * S_0;
        % C 3
        A3 = [O, I, O, I, delta_RU*I];
        RHS3 = d_max * ones(T,1);
        % C 4
        A4 = [I, O, I, O, delta_RD*I];
        RHS4 = c_max * ones(T,1);
        % C 5
        A5 = [I, -I, O, O, O];
        RHS5 = L_DA_s;
        % C 6
        A6 = [I, -I, O, O, O];
        RHS6 = L_DA_s;
        % C 7
        A7 = [-I, I, O, O, O];
        RHS7 = L_DA_max*ones(T,1) -L_DA_s;
        % C 8
        A8 = [I, -I, O, O, O];
        RHS8 = L_RT_s;
        % C 9
        A9 = [-I, I, O, O, O];
        RHS9 = L_RT_max*ones(T,1) -L_RT_s;
        % C 10
        A10 = [O, O, O, O, I];
        RHS10 = R_M_s;
        % C 11
        A11 = [-delta_nvb*I, O, O, I, O];
        RHS11 = zeros(T,1);
        % C 11
        A12 = [O, -delta_nvb*I, I, O, O];
        RHS12 = zeros(T,1);
        
        
        try
            clear model;
            model.A = sparse([A1;A2;A3;A4;A5;A6;A7;A8;A9;A10;A11;A12]);
            model.obj = ObjFun;
            model.rhs = [RHS1;RHS2;RHS3;RHS4;RHS5;RHS6;RHS7;RHS8;RHS9;RHS10;RHS11;RHS12];
            model_sense = '<';
            for t = 2: length(model.rhs)
                model_sense = strcat(model_sense, '<'); 
            end

            model.sense = model_sense;
            model.vtype = 'C';
            model.modelsense = 'max';

            clear params;
            params.outputflag = 0;
            %params.resultfile = 'mip1.lp';

            result = gurobi(model, params);

            %disp(result)

            %fprintf('Obj: %e\n', result.objval);

        catch gurobiError
            'Error reported\n'
            disp(Date)

        end
        
        Revenue = Revenue + result.objval;
        D_DA(index) = result.x(1:T);
        C_DA(index) = result.x(T+1:(2*T));
        D_RT(index) = result.x((2*T+1):(3*T));
        C_RT(index) = result.x((3*T+1):(4*T));
        R(index) = result.x((4*T+1):(5*T));
        
        Date = Date + t_sim;
    end
    
end