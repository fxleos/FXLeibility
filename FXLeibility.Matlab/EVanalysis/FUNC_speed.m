function [ speed ] = FUNC_speed( finaltable, id_selected)
%Get speed-t profile for a person with a given houseid
%We define time step dt as 1 min
%Initialization
speed=zeros(1,60*24*7);

% Select the row for a given houseid
% Only select the first member of the household whose PERSONID == 1
rows = finaltable.veh_id==id_selected;
subtable_speed= finaltable(rows, { 'start_time', 'end_time',...
    'avg_speed_mph','start_date','date_number'});

% Create speed profile
for i=1:height(subtable_speed)
    t_start=(datenum(subtable_speed.start_time(i))-subtable_speed.date_number(i)...
        +weekday(table2array(subtable_speed(i,{'start_date'})))-1)*1440+1; % plus 1 to avoid index=0
    t_end = (datenum(subtable_speed.end_time(i))-subtable_speed.date_number(i)...
        +weekday(table2array(subtable_speed(i,{'start_date'})))-1)*1440+1;
    t_start=round(t_start);
    t_end=round(t_end);
    if t_end<=10080
        t_range=t_start:t_end;
        speed(t_range)= subtable_speed.avg_speed_mph(i); 
    elseif t_start<=10080
        speed(t_start:10080)=subtable_speed.avg_speed_mph(i);
        speed(1:(t_end-10080))=subtable_speed.avg_speed_mph(i);
    else
        speed((t_start-10080):(t_end-10080))=subtable_speed.avg_speed_mph(i);
    end
end

if length(speed) > 60*24*7
    speed = speed(1:60*24*7);
end

end

