aborts = 0;
for iter = 1:GA_BETA_LENGTH
    if any(size(VorModGASolutions(iter).solutions) == 0)
        attempt = 1;
    else
        attempt = str2double(   ...
            extractAfter(VorModGASolutions(iter).solutions{end}, ',')) + 1;
    end
    while(VorModGASolutions(iter).nSolutions < 50)
        try
            fprintf('\nProcessing Beta = %1.5e, Iteration = %d',    ...
                GA_BETA(iter), attempt);
            VorModGA.setbeta(GA_BETA(iter))
            VorModGA.computesolution()
            VorModGASolutions(iter).addsolution(VorModGA,   ...
                [num2str(GA_BETA(iter)) ',' num2str(attempt)])
            attempt = attempt + 1;
        catch
            aborts = aborts + 1;
            warning(['Problem running GA;'  ...
                'aborting iteration and continuing']);
        end
    end
end