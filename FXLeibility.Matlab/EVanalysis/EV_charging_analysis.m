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

time_vector = datetime(2018,01,07,00,30,00):(1/24):datetime(2018,01,13,23,59,59);
plot(time_vector,n_plus/n_total,'LineWidth',3)
hold on
plot(time_vector,n_minus/n_total,'LineWidth',3)
datetick('x','ddd-HH')
legend({'Plug-in','Plug-out'},'FontSize',14,'Location','northeast')
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
set(gca,'YTick',[0:0.05:0.2])
ylabel('Probability','FontSize',16);
xlabel('Time','FontSize',16);

hold off
plot(time_vector,s_plus./n_plus,'LineWidth',3)
hold on
plot(time_vector,s_minus./n_minus,'LineWidth',3)
datetick('x','ddd-HH')
legend({'Plug-in','Plug-out'},'FontSize',14,'Location','southeast')
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
set(gca,'YTick',[0:25:100],'ylim',[0,100])
ylabel('State-of-Charge','FontSize',16);
xlabel('Time','FontSize',16);