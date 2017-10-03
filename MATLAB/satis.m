function [ sat ] = satis( del, dem )
%satis Derives the demand satisfaction of the given set of applied resource
%   del; double 3D array; demand points x base stations x scenarios (mso)
    %   each entry is the slice of the base station applied to the demand
    %   point for that scenario
%   dem; double vector; number of demand points in length
    %   each entry is the total demand of that demand point
    %   can also be a constant, if all demand points have the same demand
%   sat; average demand point satisfaction for the given data set

    if length(dem) == 1
        d = ones(size(del, 1), size(del, 3)) * dem;
    elseif iscolumn(dem)
        d = repmat(dem, [1, size(del, 3)]);
    elseif isrow(dem)
        d = repmat(dem', [1, size(dem, 3)]);
    else
        error('satis:inc_arg', ...
            'input argument dem must be either a constant or a vector');
    end
    sat = sum(sum(permute(sum(del, 2), [1 3 2]) ./ d)) / ...
        (size(del, 1) * size(del, 3));
    

end
