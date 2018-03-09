main_path = '/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/FXLeibility.Matlab';
case_path = strcat(main_path,'/Cases');
cd(case_path);
list = dir;
CaseNames = cell(0);
for i = 1:size(list,1)
    if list(i).isdir && ~strcmp(list(i).name,'.') && ~strcmp(list(i).name,'..')
        CaseNames{end+1} = list(i).name;
    end
end
if_exist = 0;
for i_list = 1: size(CaseNames,2)
    cd(case_path);
    load(strcat(CaseNames{i_list},'.mat'));
    CaseName = strcat(CaseName,'-ReducedCost');
    cd(strcat(main_path,'/Experiment/CostReduction'));
    if_exist = exist(CaseName);
    cd(case_path);
    if ~if_exist && ~exist(CaseName)
        Cost.InvE = 140;
        Cost.RepE = 60;
        save(strcat(CaseName,'.mat'), 'CaseName','Year', 'Regime', 'Parameters','Cost','Option');
        cd(main_path);
        main
    end
    
end