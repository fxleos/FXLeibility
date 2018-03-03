%% Market Simulation
% Data: C_inflex, C_flex, C_peak, G_residual
% Parameters: beta_inflex, b_1, b_2, b_3, beta_peak
function [Price] = MarketSimulation(Data, Parameters)
    if Data.G_residual <= Data.C_inflex
        x = 1 - (Data.C_inflex -Data.G_residual) / Data.C_inflex;
        modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
        beta = Parameters.beta_inflex;
    elseif Data.G_residual <= (Data.C_inflex+Data.C_flex)
        x = (Data.G_residual-Data.C_inflex) / Data.C_flex;
        modelfun =  @(b,x)(b(1)*x+b(2));
        if x<= 0.35
            beta = Parameters.b_1;
        elseif x>=0.65
            beta = Parameters.b_3;
        else
            beta = Parameters.b_2;
        end
    else
        x = 1 - (Data.G_residual - Data.C_inflex - Data.C_flex) / Data.C_peak;
        modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
        beta = Parameters.beta_peak;
    end
    Price = modelfun(beta,x);
end

%{
if strcmp(mode,'DE')
        
    elseif strcmp(mode,'PJM')
        
    elseif strcom(mode,'NSW')
        
    else
        'The mode is not recognizable. Please check your input'
    end
%}