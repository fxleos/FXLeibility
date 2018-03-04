function [Revenue, E_D, E_C] = ESS_Energy ( ESS_cap, P_E, E, E_peak, E_base, time_vector, C_c, C_d)
%Optimization for Energy Storage System with given parameters

%% Built-in parameters
    % Efficiencies
    eta_c = 0.9;
    eta_d = 0.9;
    eta_s = 1.0;
    % Simulation time step
    t_sim = 7;      %Unit: day
    % Storage duration
    t_storage = 4; %h

%% Interpret inputs
    delta_t = datenum(time_vector(2)-time_vector(1))*24;    %Unit: h
    d_max = ESS_cap;    %MW
    c_max = d_max;      %MW
    s_max = t_storage * d_max;  %MWh
    s_0 = 0;
    P_E_d = P_E - C_d * ones(size(P_E));
    P_E_c = P_E + C_c * ones(size(P_E));

%% Initialization
    Revenue = 0;
    E_D = zeros(length(time_vector),1);
    E_C = E_D;
    Date = floor(datenum(time_vector(1)));

%% Simulation
    cd /Library/gurobi752/mac64/matlab 
    gurobi_setup
    
    while Date <= floor(datenum(time_vector(end)))
        % Define simulation scope
        index = datenum(time_vector) < (Date + t_sim) & datenum(time_vector) >= Date;
        
        % Extract data for period to be simulated
        P_E_d_s = P_E_d(index);
        P_E_c_s = P_E_c(index);
        E_s = E(index);
        E_peak_s = E_peak(index);
        E_base_s = E_base(index);
        T = length(P_E_d_s);
        
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
        ObjFun = [P_E_d_s', -P_E_c_s'];
        % Energy Constraint
        A1 = -[-1/eta_d*M_s, eta_c*M_s];
        RHS1= eta_s * M_s * S_0;
        % C 2
        A2 = [-1/eta_d*M_s, eta_c*M_s];
        RHS2= S_max - eta_s * M_s * S_0;
        % C 3
        A3 = [I,O];
        RHS3 = d_max * ones(T,1) * delta_t;
        % C 4
        A4 = [O,I];
        RHS4 = c_max * ones(T,1) * delta_t;
        % C 5
        A5 = -[I, -I];
        RHS5 = E_peak_s - E_s;
        % C 6
        A6 = [I, -I];
        RHS6 = E_s - E_base_s;
        
        try
            clear model;
            model.A = sparse([A1;A2;A3;A4;A5;A6]);
            model.obj = ObjFun;
            model.rhs = [RHS1;RHS2;RHS3;RHS4;RHS5;RHS6];
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
        E_D(index) = result.x(1:T);
        E_C(index) = result.x(T+1:(2*T));
        
        Date = Date + t_sim;
    end
    
end