function [ location ] = FUNC_location( finaltable, id_selected )
%Get location-t profile for a person with a given houseid
%We define time step dt as 1 min
%Initialization
location=ones(1,60*24*7);
%Get the speed profile
speed=FUNC_speed(finaltable,id_selected);
%Selcet data for the given houseid
%only select the first person, which means PERSONID=1
rows = finaltable.veh_id==id_selected;
subtable_location= finaltable(rows, { 'start_time', 'end_time',...
    'destination_loc_type','start_date','date_number'});

    % 1: at home, -1: on road, 0: other locations 
for i=1:height(subtable_location)
    t_start=(datenum(subtable_location.start_time(i))-subtable_location.date_number(i)...
        +weekday(table2array(subtable_location(i,{'start_date'})))-1)*1440+1;
    t_end = (datenum(subtable_location.end_time(i))-subtable_location.date_number(i)...
        +weekday(table2array(subtable_location(i,{'start_date'})))-1)*1440+1;
    t_start=round(t_start);
    t_end=round(t_end);
    if t_end<=10080
        period = t_start:t_end;
        for t=period(period>0)
            location(t)=-1;
        end
    elseif t_start<=10080
        period = t_start:10080;
        for t=period(period>0)
            location(t)=-1;
        end
        period = 1:(t_end-10080);
        for t=period(period>0)
            location(t)=-1;
        end
    else
        period = (t_start-10080):(t_end-10080);
        for t=period(period>0)
            location(t)=-1;
        end
    end
    % consider the cases when the vehicle is not moving
    % change the location
    if t<10080
        t=t+1;
    else
        t=1;
    end
    if t<1
       t=t+1;
    end
    while (speed(t)==0) && (t<=(60*24*7-1))
            if strcmp(subtable_location.destination_loc_type(i),'HOME')
                location(t)=1;
            else
                location(t)=0;
            end
            t=t+1;
    end
    if speed(60*24*7)==0
            location(60*24*7)=location(60*24*7-1);
    else
            location(60*24*7)=-1;
    end
end




end

