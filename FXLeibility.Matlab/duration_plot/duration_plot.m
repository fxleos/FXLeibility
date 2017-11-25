function ret = duration_plot(y_data, varargin)

% Plots up a duration curve for the columns of y_data
%
% Inputs (Mandatory):
%       y_data with data in columns
%
% Inputs (Optional Parameter-value pairs)
%       'y_label' and 'x_label' e.g. 'River Flow (cumecs)'
%       'Title' e.g. 'Case A1'
%       'SortDirection' e.g. 'ascend' (default is 'descend'). Warning: If using 'ascend' then you probably should specify a non-default 'x_label'. 
%       'Legend' as a cell array of strings, e.g. {'Now', 'Then', 'Other'}
%       'SummerMonthsPartition' if the data is to be partitioned by months and plotted also
%           requires a serial-date vector (synchronised with y_data) and a vector of month numbers, bundled together into a cell-array
%           e.g. {sd, [6 7 8]} %Where summer is defined as June+July+August
%       'TraceColours' a matrix of trace colours (to over-ride the functions default colours)
%       'LineWidth' e.g. 1 (the default is 2)
%       'ProbabilityOnYAxis' puts probability data on the y-axis (default is to put it on the x-axis)
%
% Examples:
%   data = (5 * rand(366, 3)).^2; %Square some random data to give is some shape
%   sd = (datenum(2013,1,1):1: datenum(2014,1,1))'; %Date vector with above data
%   y = duration_plot(data);
%   y = duration_plot(data, 'Legend', {'Now', 'Then', 'Other'}, 'SummerMonthsPartition', {sd, [1 2 3]}, 'Title','Flow Curves'); %Includes Summer-period partition for Jan-Mar
%   y = duration_plot(data, 'SortDirection', 'ascend', 'x_label','Value ($M)', 'y_label','Proportion of Replicates Less Than Indicated Value (%)', 'ProbabilityOnYAxis',true);
% 
% Testing:
% % Inputs
% data = (15 * rand(366, 4)).^2; %Square some random data to give is some shape
% sd = (datenum(2013,1,1):1: datenum(2014,1,1))'; %Date vector with above data
% % Test 1-col data inputs:
% durn = duration_plot(data(:,1));
% durn = duration_plot(data(:,1), 'Legend',{'A'});
% durn = duration_plot(data(:,1), 'SummerMonthsPartition', {sd, [1 2 3]});
% durn = duration_plot(data(:,1), 'SummerMonthsPartition', {sd, [1 2 3]}, 'Legend',{'A'});
% durn = duration_plot(data(:,1), 'MonthPartition',sd);
% durn = duration_plot(data(:,1), 'MonthPartition',sd, 'Legend',{'A'});
% % Test multi-col data inputs:
% durn = duration_plot(data);
% durn = duration_plot(data, 'Legend',{'A', 'B', 'C', 'D'});
% durn = duration_plot(data, 'SummerMonthsPartition', {sd, [1 2 3]});
% durn = duration_plot(data, 'SummerMonthsPartition', {sd, [1 2 3]}, 'Legend',{'A', 'B', 'C', 'D'});
% % These should give an error-message
% durn = duration_plot(data, 'MonthPartition',sd);                                              %Gives an error message - can't do mult-cols for month-partition
% durn = duration_plot(data, 'MonthPartition',sd, 'Legend',{'A', 'B', 'C', 'D'});
% durn = duration_plot(data(:,1), 'MonthPartition',sd, 'SummerMonthsPartition', {sd, [1 2 3]}); %Gives an error message - can't do both partitions
%
% Related Functions:
%   recs_by_ps produces a duration curve specific to RECs production

% Default Trace Colours
trace_colours = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 0 0 0; ...   %Red Blue Green Pink Cyan Black
    0.7 0 0; 0 0.7 0; 0 0 0.7; 0.7 0.7 0;  0.7 0 0.7; 0 0.7 0.7; ...   %Red Green Blue Yellow Pink Cyan(but darker)
    0.8 0 0.8; 1 0 0.5; 0.5 0 0; 0.5 0.5 0];


%% Sort out the inputs
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('y_data');
p.addParamValue('y_label', 'Y-Value', @ischar);
p.addParamValue('x_label', 'Proportion of Data Greater Than y-value (%)', @ischar);
p.addParamValue('Title', [], @ischar);
p.addParamValue('SortDirection', 'descend', @(x)any(strcmpi(x,{'descend','ascend'})));
p.addParamValue('Legend', [], @iscell);
p.addParamValue('SummerMonthsPartition', [], @iscell); %If used, cell needs to contain a serial date vector and a vector of months; e.g. {sd, [1 2 3]}
p.addParamValue('MonthPartition', [], @isnumeric); %If used, this param requires a serial date vector
p.addParamValue('TraceColours', trace_colours); 
p.addParamValue('LineWidth', 2, @isscalar); 
p.addParamValue('ProbabilityOnYAxis', false, @islogical); 

p.parse(y_data, varargin{:});

num_data_cols = size(y_data,2);
legend_str = p.Results.Legend;
if isempty(legend_str)
    show_legend = false;
    legend_str = cellstr([repmat('Col ', num_data_cols, 1) num2str((1:1:num_data_cols)')])';
else
    show_legend = true;
    if length(legend_str) ~= num_data_cols
        error('The Legend cell-array is the wrong length for the input data.');
    end
end
if ~isempty(p.Results.MonthPartition) && ((size(y_data,2) > 1) || (~isempty(p.Results.SummerMonthsPartition)))
    error('When monthly traces are used it is not possible to: a) analyse multi-column ydata or b) concurrently run a summer/winter partition');
end


%% Basic Curve
% Ranked Data (Duration Curve)
h = figure;
set(h,'DefaultAxesColorOrder',p.Results.TraceColours, 'DefaultAxesLineStyleOrder','-|-.|--|:');
tmp_x = 0 : 100/(length(y_data)-1) : 100;
if p.Results.ProbabilityOnYAxis
    plot(sort(y_data, p.Results.SortDirection), tmp_x, 'LineWidth',p.Results.LineWidth);
else
    plot(tmp_x, sort(y_data, p.Results.SortDirection), 'LineWidth',p.Results.LineWidth);
end
hold on;
xlabel(p.Results.x_label);
ylabel(p.Results.y_label);
title(p.Results.Title);
grid;
% Outputs (but only if partitions not active - if they are outputs will be added there). 
if isempty(p.Results.SummerMonthsPartition) && isempty(p.Results.MonthPartition)
    ret.percentiles = [(0:100)' prctile(y_data, (0:100)')]; %Output summary percentiles
    ret.percentiles_summary = [[{'Percentile'} legend_str]; num2cell(ret.percentiles)];
end



%% Summer & Winter Period
if ~isempty(p.Results.SummerMonthsPartition)
    show_legend = true; %Always show legend if this is specified
    sd = p.Results.SummerMonthsPartition{1};
    summer_month_nums = p.Results.SummerMonthsPartition{2}; %Specify the Summer months as a vector of month numbers, e.g. [1 2 3] for Jan-Mar
    [tmp_y tmp_m tmp_d] = datevec(sd);
    idx_summer = ismember(tmp_m, summer_month_nums);
    tmp_x = 0 : 100/(sum(idx_summer)-1) : 100;
    plot(tmp_x, sort(y_data(idx_summer,:), 1, p.Results.SortDirection), ':', 'LineWidth',p.Results.LineWidth);
    % Opposite (winter) Period
    idx_winter = ~idx_summer;
    tmp_x = 0 : 100/(sum(idx_winter)-1) : 100;
    plot(tmp_x, sort(y_data(idx_winter,:), 1, p.Results.SortDirection), '-.', 'LineWidth',p.Results.LineWidth);
    % Add Summer & winter subscripts to the legend text
    j = size(y_data, 2); %length(legend_str); %The number of input columns
    for i = 1:length(legend_str)
        legend_str{j+i}   = [legend_str{i} ' (Summer Period)'];
        legend_str{j+j+i} = [legend_str{i} ' (Winter Period)'];
    end
    % Outputs
    ret.percentiles = [(0:100)' prctile(y_data, (0:100)') prctile(y_data(idx_summer,:), (0:100)') prctile(y_data(idx_winter,:), (0:100)')]; %Output summary percentiles
    ret.percentiles_summary = [[{'Percentile'} legend_str]; num2cell(ret.percentiles)];
end


%% Month Traces
if ~isempty(p.Results.MonthPartition)
    show_legend = true; %Always show legend if this is specified
    sd = p.Results.MonthPartition;
    [y, m, d, ~, ~, ~] = datevec(sd);
    month_plot_line_styles = {'-'; '-.'; '--'; ':'}; %Linestyles ONLY for monthly plot. Note: these won't go beyond '-' unless 'TraceColours' are specified and have less than 12 colours.
    for i = 1:12
        idx = m == i;
        tmp_x = 0 : 100/(sum(idx)-1) : 100;
        trace_colour_num = mod(i-1, size(p.Results.TraceColours,1))+1;
        line_type_num = idivide(i-1,int32(size(p.Results.TraceColours,1)),'floor') + 1; 
        plot(tmp_x, sort(y_data(idx,:), 1, p.Results.SortDirection), '-', 'color',p.Results.TraceColours(trace_colour_num,:), 'LineStyle',month_plot_line_styles{line_type_num}, 'LineWidth',1);
        monthly_percentiles(:,i) = prctile(y_data(idx,:), (0:100)'); % Percentile data (for later output)
    end
    if isempty(legend_str)
        legend_str   = {'All Months', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
    else
        legend_str   = [legend_str{1} {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}];
    end
    % Outputs
    ret.percentiles = [(0:100)' prctile(y_data, (0:100)') monthly_percentiles]; %Output summary percentiles
    ret.percentiles_summary = [[{'Percentile'} legend_str]; num2cell(ret.percentiles)];
end


%% Add Legend
if show_legend
    legend(legend_str, 'FontSize',8);
end




