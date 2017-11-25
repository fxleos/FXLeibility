clear
cd /Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility.Matlab
%% Parameter settings
% Select region and year
Region = 'NSW';
Year = 2015;%2015:2016;

% Efficiencies
ita_c = 0.9;
ita_d = 0.9;
ita_s =1.0;

% Simulation time scope
scope_t = 7; %day

s_max = 80000;    %MWh
d_max = 20000;      %MW
c_max = 20000;      %MW

%% Initialization
filename = strcat(Region,'.csv');
data = csvread(filename);

switch Region
    case 'NSW'
        delta_t = 0.5; %hour
        time_vector = datetime(2007,01,01,00,30,00):(1/24*delta_t):datetime(2017,01,01,00,00,00);
    case 'PJM'
        delta_t = 1; %hour
    case 'DE'
        delta_t = 1; %hour
end


% Define overall simulating scope
index = zeros(1,length(time_vector));
for i = 1 : length(Year)
    index = index | year(time_vector) == Year(i);
end
time_vector = time_vector(index);
data = data(index,:);

Load_max = max(data(:,2));

Charge_DA = zeros(length(time_vector),1);
Discharge_DA = zeros(length(time_vector),1);
Charge_RT = zeros(length(time_vector),1);
Discharge_RT = zeros(length(time_vector),1);
Regulation_Up = zeros(length(time_vector),1);
Regulation_Down = zeros(length(time_vector),1);
Revenue = 0;

Date = floor(datenum(time_vector(1)));

%% Simulation roll-over
cd /Library/gurobi752/mac64/matlab 
gurobi_setup 
while Date <= floor(datenum(time_vector(end)))
    % Define sub simulating scope
    subindex = datenum(time_vector) < (Date + scope_t) & datenum(time_vector) >= Date;

    % Initialize model parameters
    P = data(subindex,1)';
    L = data(subindex,2)';
    T = length(P);

    M_d = zeros(T,T);
    M_c = zeros(T,T);

    I = eye(T);
    O = zeros(T);

    for i = 1 : T
        for j = 1 : i
            M_d(i,j) = - ita_s^(i-j)/ita_d;
            M_c(i,j) = ita_s^(i-j)*ita_c;
        end
    end
    M_d = M_d * delta_t;
    M_c = M_c * delta_t;


    try
        clear model;
        model.A = sparse([I,O;O,I;M_d,M_c; -M_d,-M_c;I,O;O,I]);
        model.obj = [P*delta_t,-P*delta_t];
        model.rhs = [d_max*ones(T,1); c_max*ones(T,1); s_max*ones(T,1);zeros(T,1);L';Load_max - L'];
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

    end
    Discharge_DA(subindex) = result.x(1:T);
    Charge_DA(subindex) = result.x(T+1:end);
    Revenue = Revenue + result.objval;
    Date = Date + scope_t
end