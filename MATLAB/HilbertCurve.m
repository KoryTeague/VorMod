function [ op, ind ] = HilbertCurve( ip, lim_x, lim_y, varargin )
%HilbertCurve Performs a Hilbert curve fit onto a series of input points
%   Fits a potentially random 2D sequence of points onto a Hilbert curve
%   That is, it reorders the points so that they are in a Hilbert
%   curve-like sequence
%   Performed recursively by partitioning the points into quadrants,
%   passing the quadrant to itself, and ordering the return via the Hilbert
%   curve sequence
%   ip is the input points, an m by 2 array (col1 is x, col2 is y)
%   lim_x, lim_y are the limits in x and y, a 1 by 2 array [min_* max_*]
%   varargin contains up to two inputs: ori and dir
%       ori (varargin{1}) is the origin of the local hilbert curve
%           int input; defaults to 0 if not given
%           each curve is a square with one edge missing, and is defined by
%           its starting location and direction; ori defines starting loc
%           0: upper-left; dir 0 -> 'u', dir 1 -> 'e'
%           1: upper-right; dir 0 -> 'c', dir 1 -> 'u'
%           2: bottom-right; dir 0 -> 'n', dir 1 -> 'c'
%           3: bottom-left; dir 0 -> 'e', dir 1 -> 'n'
%       dir (varargin{2}) is the direction of the local hilbert curve
%           binary input; 'is clockwise', defaults to '0' if not given
%           0: curve moves counter-clockwise (is clockwise is false)
%           1: curve moves clockwise (is clockwise is true)
%   op is the output/ordered points, an m by 2 array
%   ind is the sorting vector of length m, mapping ip to op
    
    %% Exit if input is incorrect; error
    if size(ip, 2) ~= 2
        error('Error: input array incorrect size; Exiting');
    end
    
    %% Return if input is length 1 or 0; no sorting to perform
    if size(ip, 1) == 1
        op = ip;
        ind = 1;
        return
    elseif isempty(ip)
        op = ip;
        ind = [];
        return
    end

    %% Evaluate varargin
    if nargin == 4
        ori = varargin{1};
        dir = 0;
    elseif nargin == 5
        ori = varargin{1};
        dir = varargin{2};
    elseif nargin >= 6
        error('Error: too many inputs; Exiting');
    else
        ori = 0;
        dir = 0;
    end
    
    %% Determine Quadrants
    center = [sum(lim_x)/2, sum(lim_y)/2];  % Coordinates of domain center
    ri = ip(:, 1) >= center(1);
    hi = ip(:, 2) >= center(2);
    tmp = (1:length(hi))';
    ind_in = cell(4, 1);
    rng_x = ind_in;
    rng_y = ind_in;
    for i = 0:3
        switch mod(ori - i * (1 - 2 * dir), 4)
            case 0
                ind_in{i + 1} = tmp(hi & ~ri);
                rng_x{i + 1} = [lim_x(1) center(1)];
                rng_y{i + 1} = [center(2) lim_y(2)];
            case 1
                ind_in{i + 1} = tmp(hi & ri);
                rng_x{i + 1} = [center(1) lim_x(2)];
                rng_y{i + 1} = [center(2) lim_y(2)];
            case 2
                ind_in{i + 1} = tmp(~hi & ri);
                rng_x{i + 1} = [center(1) lim_x(2)];
                rng_y{i + 1} = [lim_y(1) center(2)];
            case 3
                ind_in{i + 1} = tmp(~hi & ~ri);
                rng_x{i + 1} = [lim_x(1) center(1)];
                rng_y{i + 1} = [lim_y(1) center(2)];
        end
    end

    %% Recursion Call
    %op_tmp = cell(4, 1);
    %ind_tmp = op_tmp;
    [op1, ind1] = HilbertCurve( ...
        ip(ind_in{1}, :), rng_x{1}, rng_y{1}, ori, ~dir);
    [op2, ind2] = HilbertCurve( ...
        ip(ind_in{2}, :), rng_x{2}, rng_y{2}, ori, dir);
    [op3, ind3] = HilbertCurve( ...
        ip(ind_in{3}, :), rng_x{3}, rng_y{3}, ori, dir);
    [op4, ind4] = HilbertCurve( ...
        ip(ind_in{4}, :), rng_x{4}, rng_y{4}, mod(ori + 2, 4), ~dir);
    
    %% Combine
    op = [op1; op2; op3; op4];
    ind = [ind_in{1}(ind1); ind_in{2}(ind2); ind_in{3}(ind3); ind_in{4}(ind4)];
end