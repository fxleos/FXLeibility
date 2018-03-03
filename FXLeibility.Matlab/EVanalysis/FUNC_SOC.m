function [ SOC ] = FUNC_SOC( finaltable,id_selected, car )
%State of charge is function of location, speed and charging profile
%Get location and speed profile with given houseid using other function
%If it is a Markov car, no need to calculate
if id_selected<=10351980
    global location_profile;
    global speed_profile;
    location=location_profile(id_selected-10000000,:);
    speed=speed_profile(id_selected-10000000,:);
else
location=FUNC_location(finaltable, id_selected);
speed=FUNC_speed(finaltable,id_selected);
end

%Get battery statistics from data (input "car" is a one-row table)
fullchagtime=car.CapacityKWh/car.ChargeKW;    
SOCperMile_City=100/(car.MiPerKWhCity*car.CapacityKWh); % the percentage of SOC for a mile
SOCperMile_Highway=100/(car.MiPerKWhHighway*car.CapacityKWh);

%Initialize SOC
SOC=100*ones(1,24*60*7);

% Calculate SOC
    %SOC_2day=[SOC SOC];
    %speed_2day=[speed speed];
    %location_2day=[location location];
    for t=2:(24*60*7)
        switch location(t)
            case 1
                %at home, can be charged
                if SOC(t-1)<100
                    %SOC(t)=SOC(t-1)+charging_profile.CHARGE*1;
                    %Here I use data of Nissan
                    SOC(t)=SOC(t-1)+100/(fullchagtime*60);
                    if SOC(t)>100
                        SOC(t)=100;
                    end
                end
            case -1
                %on road, being discharged
                %SOC(t)=SOC(t-1)-charging_profile.DISCHARGE*speed(t);
                if speed(t)>60  % highway
                SOC(t)=SOC(t-1)-speed(t)/60*SOCperMile_Highway;    %??speed(t) is in mile/min
                else            % city
                SOC(t)=SOC(t-1)-speed(t)/60*SOCperMile_City;
                end

            case 0
                %at other place no charging/discharging
                SOC(t)=SOC(t-1);
        end
    end
    %find the SOC with negative element
    %if so output a zeros array(can be detected easily)
    if any(SOC<0)
        SOC=NaN;
    end

 
end
    


