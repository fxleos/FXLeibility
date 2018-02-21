%% This function is used to look up the value for envelope lines

function [value] = FlexEnvelopMatch(value_to_be_searched, value_look_up, benchmark)
    n = length(benchmark);
    g = benchmark(2) - benchmark(1);
    benchmarket_min = benchmark(1) - 0.5*g;
    i = ceil((value_to_be_searched - benchmarket_min) / g);
    if i > n
        value = value_look_up(n);
        'Warning: the value exceeds the range of lookup table'
        disp(value_to_be_searched);
    elseif i<=0
        value = value_look_up(1);
        'Warning: the value exceeds the range of lookup table'
        disp(value_to_be_searched);
    else
        value = value_look_up(i);
    end
end