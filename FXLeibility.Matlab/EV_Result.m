EV_scenario = [ 74754, 129246, 900000]*3364428/51869730; % NSW 3364428; PJM 30331401
EV_case = [ 17];
summary_forchart = zeros(3*4,4);
for i_case = 1:length(EV_case)
    for i_scenario = 1:length(EV_scenario)
        for j_case = 2:length(SUMMARY(EV_case(i_case)).Result_details)
            x1 = SUMMARY(EV_case(i_case)).Result_details(j_case-1,1);
            x2 = SUMMARY(EV_case(i_case)).Result_details(j_case,1);
            x = EV_scenario(i_scenario);
            if  x2 > x
                y1 = SUMMARY(EV_case(i_case)).Result_details(j_case-1,3);
                y2 = SUMMARY(EV_case(i_case)).Result_details(j_case,3);
                summary_forchart (1+(i_scenario-1)*4,i_case) = (x-x1)/(x2-x1)*(y2-y1)+y1;%Explicit revenue
                y1 = SUMMARY(EV_case(i_case)).Result_details(j_case-1,6);
                y2 = SUMMARY(EV_case(i_case)).Result_details(j_case,6);
                summary_forchart (2+(i_scenario-1)*4,i_case) = ((x-x1)/(x2-x1)*(y2-y1)+y1);%Implicit cost
                summary_forchart (3+(i_scenario-1)*4,i_case) = summary_forchart (1+(i_scenario-1)*4,i_case)-summary_forchart (2+(i_scenario-1)*4,i_case);%Total
                y1 = SUMMARY(EV_case(i_case)).Result_details(j_case-1,4);
                y2 = SUMMARY(EV_case(i_case)).Result_details(j_case,4);
                summary_forchart (4+(i_scenario-1)*4,i_case) = summary_forchart (3+(i_scenario-1)*4,i_case)-((x-x1)/(x2-x1)*(y2-y1)+y1);
                break
            end
        end
    end
end