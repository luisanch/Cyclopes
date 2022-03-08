function plot_results(data, num_cases, variables, legends)
    figure;
    num_variables = length(variables);
    for k=2:num_variables
        subplot(1, num_variables-1, k-1);
        for i=1:num_cases
            plot(data(:, 1, i), data(:, k, i));
            xlabel(variables{1})
            ylabel(variables{k})
            hold on;
        end
        legend(legends);
    end
end
