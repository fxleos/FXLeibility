%% Fixed Cost

function [Cost_fixed] = FixCost (Parameters,Cost, size,  mode)
    if strcmp(mode,'ESS')
        Capacity_P = size;
        Capacity_E = Capacity_P * Parameters.E2P_ratio;
    else
        Capacity_P =  size * Parameters.BpEV;
        Capacity_E = Capacity_P * Parameters.E2P_ratio;
    end
    discount = Cost.discount /100;
    Cost_total = Cost.InvP * Capacity_P + Cost.InvE * Capacity_E + Cost.InvT;
    Cost_eac = (Cost_total * discount) / (1-1/((1+discount)^Cost.life_nm));
    Cost_fOaM = Cost_total * 0.02;
    Cost_fixed = Cost_eac + Cost_fOaM;
end