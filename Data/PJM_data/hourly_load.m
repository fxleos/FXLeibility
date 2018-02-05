%% Hourly metered data

year = 2016;

filename = strcat(num2str(year),  '-hourly-loads.xls');

data = xlsread(filename,'RTO');

load = zeros(24*(size(data,1)-2),1);
i = 1;

for date = 3:size(data,1)
    for h = 1 : 24
        load(i) = data(date,h);
        %{
        if isnan(load(i)) == 1
            load(i) = (load(i-1)+data(date,h+1));
        end
        %}
        i = i+1;
    end
    
end

load_file = array2table(load,'VariableNames',{'load'})

writetable(load_file,'hourly_loads.csv')

