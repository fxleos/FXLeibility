%% EV driving Analysis

load('id.mat');
load('finaltable.mat');
load('CarModel.mat');
car = model(2,:);

n_total = 0;
n_plus = zeros(1,168);
n_minus = zeros(1,168);
s_plus = zeros(1,168);
s_minus = zeros(1,168);
timer_start = now;

for i = 1:length(id)
    disp(i)
    location = FUNC_location(finaltable,id(i));
    SoC = FUNC_SOC( finaltable,id(i), car );
    if ~isnan(SoC)
        n_total = n_total+1;
        for h = 1:168
            if location((h-1)*60+1) == 1
                if location(h*60) == -1 || location(h*60) == 0
                    n_minus(h) = n_minus(h)+1;
                    for t = ((h-1)*60+1):(h*60)
                        if location(t) ~= 1
                            s_minus(h) = s_minus(h)+SoC(t);
                            break
                        end
                    end
                end
            end
            if location((h-1)*60+1) == -1 || location((h-1)*60+1) == 0
                if location(h*60) == 1
                    n_plus(h) = n_plus(h)+1;
                    for t = ((h-1)*60+1):(h*60)
                        if location(t) == 1
                            s_plus(h) = s_plus(h)+SoC(t);
                            break
                        end
                    end
                end
            end
        end
    end
end
