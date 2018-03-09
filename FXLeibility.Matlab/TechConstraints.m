%% This function is to generate the technology constraints
% Parameters: r_max, E2P_ratio (s_max =r_max * E2P_ratio), delta_t, T, I, J
% For EV additional: N
function [A, RHS, Sense] = TechConstraints(Parameters, TechOutput, mode)
    T = Parameters.T;
    % Initialize
    A = [];
    I_I = [];
    I_J = [];
    if strcmp(mode,'DR')
        A = [-TechOutput.h;TechOutput.h];
        RHS = [Parameters.s_max*ones(T,1);Parameters.s_max*ones(T,1)];
    else
        % Identity matrix
        for i = 1:length(Parameters.I)
            I_I = [I_I, eye(T)];
        end
        for j = 1:length(Parameters.J)
            I_J = [I_J, eye(T)];
        end
        % Zeros matrix
        O_I = zeros(T,T*length(Parameters.I));
        % Contrain coefficients
        A = [A;-I_I,O_I,-I_J;O_I,-I_I,-I_J;I_I,O_I,I_J;O_I,I_I,I_J;-TechOutput.h;TechOutput.h];
        %RHS
        if strcmp(mode,'ESS')
            RHS = [zeros(T,1);zeros(T,1);Parameters.delta_t*Parameters.r_max*ones(T,1);Parameters.delta_t*Parameters.r_max*ones(T,1);TechOutput.h_0; Parameters.r_max*Parameters.E2P_ratio*ones(T,1) - TechOutput.h_0];
        else
            RHS = [zeros(T,1);zeros(T,1);Parameters.delta_t*Parameters.r_max*TechOutput.N;Parameters.delta_t*Parameters.r_max*TechOutput.N;TechOutput.h_0; Parameters.r_max*Parameters.E2P_ratio*TechOutput.N - TechOutput.h_0];
        end
        Sense = repmat('<', 6*T, 1);
    end
end