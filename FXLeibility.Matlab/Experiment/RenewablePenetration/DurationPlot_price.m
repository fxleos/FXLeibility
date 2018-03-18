%% Renewable Penetration
Name_list = {'Germany_VRE-0.8_ESS','Germany_VRE-0.9_ESS','Germany_VRE-1.05_ESS','Germany_VRE-1.1_ESS','Germany_VRE-1.15_ESS'};
%Name_list = {'Germany_inflex2flex-0.05_ESS','Germany_inflex2flex-0.1_ESS','Germany_inflex2flex-0.2_ESS','Germany_inflex2flex-0.3_ESS',...
    %'Germany_inflex2flex-0.4_ESS','Germany_inflex2flex-0.5_ESS'};
main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab/';
P = [];
for i_name = 1:length(Name_list)
    i_name
    cd(main_path)
    CaseName = Name_list{i_name};
    Market_ReSimulation
    P = [P,p_sim];
end

P_forplot = [];
for i_name = 1:length(Name_list)
    cd(strcat(main_path,'duration_plot'));
    DP = duration_plot(P(:,i_name));
    close
    P_forplot = [P_forplot, DP.percentiles(:,2)];
end
DP = duration_plot(price_sim);
close
P_forplot = [P_forplot, DP.percentiles(:,2)];
