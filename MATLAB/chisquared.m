function [ chi ] = chisquared( exp, obs )
%chisquared Computes the chi-squared test statistic for Pearson's test 
    % exp is a vector containing the expected count of type i in the pop
    % obs is a vector containing the observed count of type i in the pop

    chi = sum((obs - exp).^2 ./ exp);

end

