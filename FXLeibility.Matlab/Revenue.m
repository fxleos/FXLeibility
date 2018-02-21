%% Revenue module
% Data includes PI_e_I, PI_e_J, PI_r_J, DELTA_J, I, J
function [f] = Revenue (DATA)
    Pi_e_I = [];
    Pi_e_J = [];
    Pi_r_J = [];
    Delta_J = [];
    for i = 1:length(DATA.I)
        Pi_e_I = [DATA.Pi_e_I, DATA.PI_e_I(:,I(i))'];
    end
    for j = 1:length(DATA.J)
        Pi_e_J = [DATA.Pi_e_J, DATA.PI_e_J(:,J(j))'];
        Pi_r_J = [DATA.Pi_r_J, DATA.PI_r_J(:,J(j))'];
        Delta_J = [DATA.Delta_J, DATA.DELTA_J(:,J(j))'];
    end
    Delta_J = diag(Delta_J);
    
    f = [Pi_e_I, -Pi_e_I, Pi_e_J*Delta_J + Pi_r_J];
end