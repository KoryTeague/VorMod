classdef lnfield
    %LNFIELD Class defining a 2D continuous-domain log-normal field
    %   Constructors:
    %       obj = LNFIELD() generates an LNFIELD object with default
    %           parameters
    %       The following each define the LNFIELD object with specified
    %           parameters; otherwise default
    %       obj = LNFIELD(omega, depth)
    %       obj = LNFIELD(omega, depth, X, Y)
    %       obj = LNFIELD(omega, depth, X, Y, loc, scale)
    %   Methods:
    %       vals = obj.pointValue(points)
    %           Returns the value of a specific point within the field.
    %           This point does not need to be within the range (1:X, 1:Y)
    %               of the original field.
    %           'points' is a 2-column matrix (M x 2), where:
    %               each row represents a point
    %               the first column is the points' x-coordinate
    %               the second column is the points' y-coordinate
    %           'vals' is a M-length column vector, with each element
    %               as the value of the corresponding point in points
    %       obj = obj.setParam(...)
    %           Sets specified parameters of the object to tune the field
    %               without changing the field's random characteristics
    %           Returns an object with new parameters and generated field
    %               Recommend overwriting the old object with the new
    %           Inputs are in pairs, alternating between string paramater
    %               descriptor and requisite data element
    %           Valid string descriptor/data element pairs:
    %               'X'     -   integer greater than zero
    %               'Y'     -   integer greater than zero
    %               'loc'   -   real number (double)
    %               'sca'   -   real number (double) greater than zero
    %           ex = ex.setParam('X', 10, 'Y', 10, 'loc', 0, 'sca', 1)
    %       PPP = obj.nsPPP(mode)
    %       PPP = obj.nsPPP(mode, pts)
    %       PPP = obj.nsPPP(mode, pts, num_real)
    %           Returns a PPP using the lnfield as the density function
    %           PPP is a cell array of length num_real, each element
    %               containing one realization of a non-stationary Poisson
    %               Point Process, using the log-normal field as the PPP's
    %               density function.  Each realization is a two-column
    %               matrix whereby each row is a point within the PPP, the
    %               first column the list of x-coordinates and the second
    %               column the list of y-coordinates.  The points all fall
    %               within the domain of the object's field (on the domain
    %               (0, X) and (0, Y).
    %           mode is a boolean declaration, dictating the form of PPP
    %               generation
    %               mode == 0 generates a non-stationary PPP using a
    %                   standard trimming process.  That is, a stationary
    %                   (constant density) PPP is generated with a density
    %                   of the max of the object's field, and each point is
    %                   then removed with a probability of that point on
    %                   the field to the maximum of the field.  Each
    %                   realization of the PPP contains a number of points
    %                   according to a poisson random variable with
    %                   density dependent on the object's parameters and
    %                   the input argument pts.  With loc = 0, scale = 1,
    %                   the number of points for each realization is
    %                   approximately X*Y*pts*1.6.
    %               mode == 1 generates a non-stationary PPP with a
    %                   specified number of points.  If a specific number
    %                   of points is required within each realization, this
    %                   method is recommended over mode == 0; mode == 0
    %                   would require generating many points, then
    %                   indiscriminantly removing points from each
    %                   realization to meet the target value (many wasted
    %                   generated points), and risks a realization
    %                   generating too few points, as the total number
    %                   varies.  For this implementation, points are
    %                   generated in batches, trimmed, and combined into
    %                   realizations with little over-generation.
    %           pts is a positive number (mode == 0) or positive integer
    %               (mode == 1), representing the number of points to be
    %               generated within each realization.
    %               For mode == 0:
    %                   acts as a scalar, proportionally scaling the max
    %                   value fo the field when generating the stationary
    %                   PPP.  Approximate number of points generated per
    %                   realization: X*Y*pts*1.6, for loc = 0, scale = 1.
    %               For mode == 1:
    %                   the number of points each realization will be
    %                   returned with.  Each element of PPP will be a
    %                   matrix of size [pts, 2].
    %           num_real is a positive integer indictating the number of
    %               realizations to generate.  PPP is a cell array of
    %               length num_real.
    %   Parameters:
    %       OMEGA is the maximum angular frequency of the sinusoids used to
    %           generate the field.  This directly correlates to the
    %           autocorrelation of the resulting log-normal field.  The
    %           distance between points of the field (1:X, 1:Y) are the
    %           reference unit.  Positive number.
    %       DEPTH is the the number of 2D sinusoidal fields used to
    %           generate the log-normal field.  The larger this value, the
    %           more the resulting field approaches a log-normal field.
    %           However, larger values of depth increases both the size of
    %           the object, and the amount of time to generate the field and
    %           process elements within.  Positive integer.
    %       X and Y are extent of the log-normal field (1:X, 1:Y), and are
    %           used to derive the size of the FIELD parameter.  Larger
    %           values increase the size of the field, and - in effect - the
    %           field's resolution.  Positive integer.
    %       LOC and SCALE correspond to the location and scale parameters
    %           of a standard log-normal distribution, and are the mean and
    %           standard deviation of the natural log of the field,
    %           respectively.
    %           loc: number
    %           scale: positive number
    %       FIELD is the log-normal field, represented as a X by Y matrix.
    %           To view, try surf(obj.field).
    
    properties (SetAccess=immutable, GetAccess=private)
        i
        j
        phi
        psi
    end
    properties (SetAccess=immutable, GetAccess=public)
        omega   =   2*pi/30
        depth   =   25
    end
    properties (SetAccess=private, GetAccess=private)
        std_f
        lamb_max
    end
    properties (SetAccess=private, GetAccess=public)
        loc     =   0
        scale   =   1
        X       =   10
        Y       =   10
        field
        Gfield
    end
    methods
        function obj=lnfield(omega, depth, varargin)
            % varargin contains X, Y, loc, scale
            if nargin > 6
                warning('lnfield:constructor:numArg', ...
                    'Too many arguments detected.\n.')
            end
            if nargin == 5 || nargin == 3
                warning('lnfield:constructor:numArg', ...
                    'Expecting an even number of arguments.\n')
            end
            if nargin == 6
                if isnumeric(varargin{3}) && isnumeric(varargin{4}) && ...
                        varargin{4} > 0
                    obj.loc = varargin{3};
                    obj.scale = varargin{4};
                else
                    error('lnfield:constructor:incLocSca', ...
                        'Incorrect inputs.\nloc must be a number.\nscale must be a positive number.\n')
                end
            end
            if nargin >= 4
                if isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
                        floor(varargin{1}) == varargin{1} && ...
                        floor(varargin{2}) == varargin{2} && ...
                        varargin{1} > 0 && varargin{2} > 0
                    obj.X = varargin{1};
                    obj.Y = varargin{2};
                else
                    error('lnfield:constructor:incXY', ...
                        'Incorrect inputs.\nX and Y must be positive integers.\n')
                end
            end
            if nargin > 0
                if isnumeric(omega) && isnumeric(depth) && omega > 0 && ...
                        depth > 0 && floor(depth) == depth
                    obj.omega = omega;
                    obj.depth = depth;
                else
                    error('lnfield:constructor:incOmeDep', ...
                        'Incorrect inputs.\nOmega must be a positive number.\nDepth must be a positive integer.\n')
                end
            end
            obj.i = obj.omega*rand(1, obj.depth);
            obj.j = obj.omega*rand(1, obj.depth);
            obj.phi = 2*pi*rand(1, obj.depth);
            obj.psi = 2*pi*rand(1, obj.depth);
            obj = obj.genField();
        end
        function vals=pointValue(obj, points)
            % points is a 2-column array, containing points to solve
                % column 1 are x-coords, column 2 are y-coords
            if ~isnumeric(points) || size(points, 2) ~= 2 || ...
                    any(any(points <= 0))
                error('lnfield:pointValue:incArg', ...
                    'Incorrect inputs.\npoints must be a 2-column matrix of positive numbers.\n')
            end
            vals = sum(     ...
                cos(points(:, 1)*obj.i +    ...
                    repmat(obj.phi, [size(points, 1), 1])) .*   ...
                cos(points(:, 2)*obj.j +    ...
                    repmat(obj.psi, [size(points, 1), 1])), 2) / obj.depth;
            vals = exp(obj.scale * vals / obj.std_f + obj.loc);
        end
        function obj=setParam(obj, varargin)
            % Changes parameters of the lnfield which would require
            % regeneration of the field.
            % Inputs are in pairs:
                % First element is a string descriptor indicating the
                    % parameter to be changed
                % Second element is the parameter's new value
            % Valid string descriptors, type, and descriptions:
                % 'X'   -   int, x-coord extent (1:X) of lnfield domain
                % 'Y'   -   int, y-coord extent (1:Y) of lnfield domain
                % 'loc' -   double, location parameter of ln distribution
                % 'sca' -   double > 0, scale parameer of ln distribution
            if (nargin+1)/2 ~= floor((nargin+1)/2)
                error('lnfield:setParam:numArg', ...
                    'Incorrect number of input arguments.\nThere must be an even number of input arguments.\nArguments are included as pairs; the first element is a text descriptor of the parameter to be changed, the second element is the new value of the parameter.')
            end
            if nargin == 1
                warning('lnfield:setParam:noChange', ...
                    'No input arguments.\nNo changes made to lnfield object.\n')
            end
            for a = 1:2:nargin-1
                switch varargin{a}
                    case 'X'
                        if isnumeric(varargin{a+1}) && ...
                                floor(varargin{a+1}) == varargin{a+1}
                            obj.X = varargin{a+1};
                        else
                            error('lnfield:setParam:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case 'Y'
                        if isnumeric(varargin{a+1}) && ...
                                floor(varargin{a+1}) == varargin{a+1}
                            obj.Y = varargin{a+1};
                        else
                            error('lnfield:setParam:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case 'loc'
                        if isnumeric(varargin{a+1})
                            obj.loc = varargin{a+1};
                        else
                            error('lnfield:setParam:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case 'sca'
                        if isnumeric(varargin{a+1}) && varargin{a+1} > 0
                            obj.scale = varargin{a+1};
                        else
                            error('lnfield:setParam:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    otherwise
                        error('lnfield:setParam:incArg', ...
                            'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                end
            end
            obj = obj.genField();
        end
        function PPP=nsPPP(obj, mode, varargin)
            % Generates a non-stationary PPP using the log-normal field of
                % ln field as the density function and domain.
            % varargin contains pts and num_real
                % num_real is the number of realizations to generate
                    % default 1; positive integer
                % pts (mode == 0) is a scalar that controls the expected
                    % number of points to generate in each realization
                    % default 1; positive real number
                % pts (mode == 1) is the specific number of points to
                    % generate in each realization
                    % default 1000; positive integer
            % mode is a control variable, dictating how to generate the PPP
                % mode == 0 generates a PPP with an unknown, but expected
                    % number of points, controled by scalar 'pts'
                % mode == 1 generates a PPP with a specific number of
                    % points.
                % The first method is the standard trimming method,
                    % generating a stationary PPP with a density of
                    % max(max(obj.field))*obj.X*obj.Y*pts
                % This is repeated for each realization.  To get a specific
                    % number of points, generate too many (assured with a
                    % sufficiently high value of pts), and throw out any
                    % points that exceed the value desired.  This is
                    % inefficient, as each realization will generate too
                    % many, only to be deleted.
                % The second method follows the first, by generating points
                    % not assigned to any specific realization in batches.
                    % Once pts points have been generated (post-trimming),
                    % assign them to a realization, keeping remainder for
                    % the next.  With some control, PPP can be generated
                    % with a specific number of points without any
                    % possibility of accidentally polling a PPP realization
                    % with too few points (when trimming the trimmed
                    % realization), and with more efficiency (fewer wasted
                    % points)
            % PPP is a cell array of size [num_real, 1] with each element 
                % containing a 2-column matrix.
                % Each row represents a point
                % Column 1 is the list of x-coordinates
                % Column 2 is the list of y-coordinates
                % If mode == 1, each element of PPP is of size [pts, 2]
                % If mode == 0, each element of PPP is of size [X, 2],
                % where X is some random variable with a distribution
                % dependent on lnfield's parameters and pts
            if nargin > 4
                error('lnfield:PPP:numArg', ...
                    'Too many input arguments.\nThere are only up to four input arguments.\n')
            end
            if nargin == 4
                % num_real; positive integer
                if isnumeric(varargin{2}) && varargin{2} > 0 && ...
                        floor(varargin{2}) == varargin{2}
                    num_real = varargin{2};
                else
                    error('lnfield:PPP:incArg', ...
                        'num_real must be a positive integer.\n')
                end
            else
                num_real = 1;
            end
            switch mode
                case 0
                    % Original
                    if nargin >= 3
                        % pts; positive number
                        if varargin{1} > 0 && isnumeric(varargin{1})
                            pts = varargin{1};
                        else
                            error('lnield:PPP:incArg', ...
                                'For mode == 0, pts must be a positive number.\n')
                        end
                    else
                        pts = 1;
                    end
                    
                    PPP = cell(num_real, 1);
                    for real = 1:num_real
                        PPP{real} = obj.genPPP(poissrnd(obj.lamb_max*pts*obj.X*obj.Y));
                    end
                case 1
                    % Specific
                    if nargin >= 3
                        % pts; positive integer
                        if varargin{1} > 0 && isnumeric(varargin{1}) && ...
                                floor(varargin{1}) == varargin{1}
                            pts = varargin{1};
                        else
                            error('lnfield:PPP:incArg', ...
                                'For mode == 1, pts must be a positive integer.\n')
                        end
                    else
                        pts = 1000;
                    end
                    
                    PPP = cell(num_real, 1);
                    a = 1;
                    buffer = zeros(pts, 2);
                    ind = 0;
                    while a <= num_real
                        tmp = obj.genPPP(pts);
                        if ind + size(tmp, 1) > pts
                            PPP{a} = [buffer(1:ind, :); tmp(1:pts-ind, :)];
                            buffer(1:ind + size(tmp, 1) - pts, :) = ...
                                tmp(pts-ind+1:end, :);
                            ind = ind + size(tmp, 1) - pts;
                            a = a + 1;
                        else
                            buffer(ind+1:ind+size(tmp, 1), :) = tmp;
                            ind = ind + size(tmp, 1);
                        end
                    end
                otherwise
                    error('lnfield:PPP:incArg', ...
                        'mode must be a boolean value of 0 or 1.\n')
            end
        end
    end
    methods (Access=private)
        function obj=genField(obj)
            % Generate the lognormal field generated over the specified
                % domain, X and Y, set for the field object
            [x, y] = meshgrid(1:obj.X, 1:obj.Y);
            points = [ ...
                reshape(x, [obj.X*obj.Y, 1])    ...
                reshape(y, [obj.X*obj.Y, 1])    ];
            vals = sum(     ...
                cos(points(:, 1)*obj.i +    ...
                    repmat(obj.phi, [obj.X*obj.Y, 1])) .*   ...
                cos(points(:, 2)*obj.j +    ...
                    repmat(obj.psi, [obj.X*obj.Y, 1])), 2) / obj.depth;
            obj.std_f = sqrt(var(vals));
            vals = vals / obj.std_f;
            obj.Gfield = reshape(vals, [obj.Y, obj.X]);
            vals = exp(obj.scale * vals + obj.loc);
            obj.field = reshape(vals, [obj.Y, obj.X]);
            obj.lamb_max = max(max(obj.field));
        end
        function PPP=genPPP(obj, num_pts)
            % Generate a set of points for a PPP, abstracted from specifics
                % Used for public method PPP; both mode == 0 and mode == 1
            PPP = [ ...
                obj.X*rand([num_pts, 1]),    ...
                obj.Y*rand([num_pts, 1])     ];
            lamb = obj.pointValue(PPP) / obj.lamb_max;
            PPP(lamb <= rand(num_pts, 1), :) = NaN;
            PPP = PPP(~isnan(PPP));
            PPP = reshape(PPP, [length(PPP)/2 2]);
        end
    end
end