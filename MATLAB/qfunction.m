function [ q ] = qfunction( x )
%qfunction Calculates the q-function using erfc; gaussian tail probability
    % x is either a single value of a vector

    q = 1/2 * erfc(x / sqrt(2));

end

