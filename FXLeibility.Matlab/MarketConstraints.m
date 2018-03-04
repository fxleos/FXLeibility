%% This function is used to generate market constraints
% Parameters: I,J,T,delta_T
% Data: e-hat, r-hat, e-base, e-peak, time_vector
function [A, RHS, Sense] = MarketConstraints(Parameters, Data, mode)
    I = Parameters.I;
    J = Parameters.J;
    T = Parameters.T;
    delta_t = Parameters.delta_t;
    time_vector = Data.time_vector;
    % Constraint 0: all trading volume will not exceed the actual volume
    A = [];%zeros(T,(length(I)*2+length(J))*T);
    RHS = [];
    Sense = [];
    for i = 1:length(I)
        a = zeros(T,(length(I)*2+length(J))*T);
        for ij = 1:T
            a(ij,ij+(i-1)*T) = 1;
        end
        for ij = 1:T
            a(ij,ij+(i-1)*T+length(I)*T) = -1;
        end
        A = [A;a];
        if (strcmp(mode,'Germany') || strcmp(mode,'DE')) && I(i) == 3
            %not synmetric
            RHS = [RHS;max(Data.e_hat(:,I(i)),0)];
        else
            RHS = [RHS;Data.e_hat(:,I(i))];
        end
        Sense = [Sense;repmat('<', T, 1)];
    end
    for i = 1:length(I)
        a = zeros(T,(length(I)*2+length(J))*T);
        for ij = 1:T
            a(ij,ij+(i-1)*T) = -1;
        end
        for ij = 1:T
            a(ij,ij+(i-1)*T+length(I)*T) = 1;
        end
        A = [A;a];
        if (strcmp(mode,'Germany') || strcmp(mode,'DE'))  && I(i) == 3
            %not synmetric
            RHS = [RHS;max(-Data.e_hat(:,I(i)),0)];
        else
            RHS = [RHS;Data.e_hat(:,I(i))];
        end
        Sense = [Sense;repmat('<', T, 1)];
    end
    for j = 1:length(J)
        a = zeros(T,(length(I)*2+length(J))*T);
        for ij = 1:T
            a(ij,ij+(j-1)*T+length(I)*2*T) = 1;
        end
        A = [A;a];
        RHS = [RHS;Data.r_hat(:,J(j))];
        Sense = [Sense;repmat('<', T, 1)];
    end
    
    % Constraint 1: DA energy trading is not to replace base generation or
    % activiate peak generation
    if ~isempty(I)
        if I(1) == 1
            a = zeros(T,(length(I)*2+length(J))*T);
            for ij = 1:T
                a(ij,ij) = 1;
                a(ij,ij+length(I)*T) = -1;
            end
            A = [A;a];
            RHS1 = Data.e_hat(:,I(1))-Data.e_base;
            RHS1(RHS1<0) = 0;
            RHS = [RHS;RHS1];
            Sense = [Sense;repmat('<', T, 1)];
            a = zeros(T,(length(I)*2+length(J))*T);
            for ij = 1:T
                a(ij,ij) = -1;
                a(ij,ij+length(I)*T) = 1;
            end
            A = [A;a];
            RHS1 = Data.e_peak-Data.e_hat(:,I(1));
            RHS1(RHS1<0) = 0;
            RHS = [RHS;RHS1];
            Sense = [Sense;repmat('<', T, 1)];
        end
    end
    %
    
    if strcmp(mode,'Germany') || strcmp(mode,'DE')
        % for Germany, the primary control was provided on a weekly basis
        % secondary control was provided in weekly peak/base blocks
        for j = 1:length(J)
            a = zeros(T,(length(I)*2+length(J))*T);
            if J(j) == 1
                if T*delta_t<=168
                    for ij = 2:T
                        a(ij,1+(j-1)*T+length(I)*2*T) = 1;
                        a(ij,ij+(j-1)*T+length(I)*2*T) = -1;
                    end
                    A = [A;a];
                    RHS = [RHS;zeros(T,1)];
                    Sense = [Sense;repmat('=', T, 1)];
                else
                    'This function is temporarily unavailable, please take care'
                end
            elseif J(j) ==2 || J(j) ==3
                %peak, off-peak
                if T*delta_t<=168
                    index_peak = weekday(time_vector) ~=1 & weekday(time_vector) ~=7 & hour(time_vector)>=8 & hour(time_vector)<16;
                    isfirst_peak = 1;
                    isfirst_offpeak = 1;
                    for ij=1:T
                        if index_peak
                            if isfirst_peak
                                i_first_peak = ij;
                                isfirst_peak = 0;
                            else
                                a(ij,i_first_peak+(j-1)*T+length(I)*2*T) = 1;
                                a(ij,ij+(j-1)*T+length(I)*2*T) = -1;
                            end
                        else
                            if isfirst_offpeak
                                i_first_offpeak = ij;
                                isfirst_offpeak = 0;
                            else
                                a(ij,i_first_offpeak+(j-1)*T+length(I)*2*T) = 1;
                                a(ij,ij+(j-1)*T+length(I)*2*T) = -1;
                            end
                        end
                    end
                    A = [A;a];
                    RHS = [RHS;zeros(T,1)];
                    Sense = [Sense;repmat('=', T, 1)];
                else
                    'This function is temporarily unavailable, please take care'
                end
            end
        end
    end
end