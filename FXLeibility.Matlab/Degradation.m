%% This script is degradation cost calculation
% Data include DATA.DELTA_PLUS_J, DATA.DELTA_MINUS_J
% Parameters: I, J, zeta, T

function [Z] = Degradation(DATA,Parameters)
    T = size(DATA.time_vector,1);
    Z_I = [];
    for i = 1:length(Parameters.I)
        Z_I = [Z_I, Parameters.zeta*1000*ones(1,T)]; % *1000 to convert $/KWh to $/MWh
    end

    DELTA_PLUS_J = [];
    DELTA_MINUS_J = [];
    for j = 1:length(Parameters.J)
        DELTA_PLUS_J = [DELTA_PLUS_J,DATA.DELTA_PLUS_J(:,Parameters.J(j))'];
        DELTA_MINUS_J = [DELTA_MINUS_J,DATA.DELTA_MINUS_J(:,Parameters.J(j))'];
    end
    Z = [ Z_I, Z_I, Parameters.zeta*(DELTA_PLUS_J+DELTA_MINUS_J)];
end