%EV Number analysis

% Germany
Year = 2010:2017;
N_EV = [541, 2154, 2956,7436, 13049, 23464,25154,54492];
N_EV_cumulative = zeros(size(N_EV));
for i = 1:length(N_EV)
    N_EV_cumulative(i) = sum(N_EV(1:i));
end

b = bar(Year, N_EV_cumulative,'FaceColor','flat');

labels = num2cell(N_EV_cumulative);
xt = get(gca, 'XTick');
text(xt, N_EV_cumulative, labels, 'HorizontalAlignment','center', 'VerticalAlignment','bottom','FontSize', 14)
set(gca,'linewidth',2)
set(gca, 'FontSize', 14)
xlabel('Year','FontSize', 16)
ylabel('Number of EV','FontSize', 16)