%% This script is used to preprocess the signal data

% Parameters
Year = '2017';
RegD = [];
RegA = [];
for Month = 1:12
    disp(Month)
    M = num2str(Month);
    filename = strcat(M, 32, Year, '.xlsx');
    if Month < 10
        filename = strcat('0', filename);
    end
    if exist('RegD_raw')
        'using existing file'
    else
        RegD_raw = xlsread(filename,1);
        RegD_raw(isnan(RegD_raw)) = 0;
        'RegD Reading Done'
    end
    disp(size(RegD_raw));
    temp = zeros((size(RegD_raw,1)-2)*(size(RegD_raw,2)-1)/1800,1);
    i = 1;
    for Day = 2:size(RegD_raw,2)
        for t = 1:24
            temp(i) = sum(RegD_raw(((t-1)*1800+2):(t*1800+1),Day),1);
            i = i + 1;
        end
    end
    RegD = [RegD;temp];
    if exist('RegA_raw')
        'using existing file'
    else
        RegA_raw = xlsread(filename,2);
        RegA_raw(isnan(RegA_raw)) = 0;
        'RegA Reading Done'
    end
    disp(size(RegA_raw));
    temp = zeros((size(RegA_raw,1)-2)*(size(RegA_raw,2)-1)/1800,1);
    i = 1;
    for Day = 2:size(RegA_raw,2)
        for t = 1:24
            temp(i) = sum(RegA_raw(((t-1)*1800+2):(t*1800+1),Day),1);
            i = i+1;
        end
    end
    RegA = [RegA;temp];
    clear RegD_raw
    clear RegA_raw
end
RegD = RegD/1800;
RegA = RegA/1800;
