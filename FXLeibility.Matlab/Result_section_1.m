main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab';
case_path = strcat(main_path,'/Experiment/CostReduction/');
%case_path = strcat(main_path,'/Cases/');
cd(case_path);
list = dir;
CaseNames = cell(0);
for i = 1:size(list,1)
    if list(i).isdir && ~strcmp(list(i).name,'.') && ~strcmp(list(i).name,'..')
        CaseNames{end+1} = list(i).name;
    end
end
SUMMARY =[];
for i_list = 1: size(CaseNames,2)
    i_list
    Summary = struct();
    cd(case_path);
    load(strcat(CaseNames{i_list},'.mat'));
    cd(main_path);
    Result
    Summary.CaseName = CaseName;
    Summary.Scenarios = Scenarios;
    Summary.Result_summary = Result_summary;
    Summary.Result_summary_forchart = [Result_summary(1,:)';Result_summary(2,:)';Result_summary(3,:)';Result_summary(6,:)' ./ Result_summary(6,4)];
    Summary.Result_details = Result_rev_cost;
    Summary.N_window = N_window;
    Summary.N_window_nan = N_window_nan;
    SUMMARY = [SUMMARY,Summary];
end

%{
plot(SUMMARY(3).Result_details(:,1)/1000000,SUMMARY(3).N_window_nan/SUMMARY(3).N_window*100,'LineWidth',3);
xlim([0,10])
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
set(gca,'YTick',[0:25:100],'ylim',[0,110])
ylabel('Percentage of time (%)','FontSize',16);
xlabel('Number of EVs (million)','FontSize',16);

load('1.mat')
plot(E_D(1:240,1:2),'LineWidth',3);
hold on
plot(E_C(1:240,1:2),'LineWidth',3);
plot(R(1:240),'LineWidth',3);
xlim([0,240])
set(gca,'YTick',[0:0.1:0.5],'ylim',[0,0.5])
set(gca,'linewidth',2)
set(gca, 'FontSize', 12)
legend({'Day-ahead discharge','Real-time discharge','Day-ahead charge','Real-time charge', 'RegD reserve'},'Location','northeast')
ylabel('Capacity (MW)','FontSize',16);
xlabel('Time (h)','FontSize',16);
%}
