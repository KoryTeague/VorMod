classdef LNField
    %LNField Class defining a 2D continuous-domain log-normal field
    %   Constructors:
    %       obj = LNField() generates an LNField object with default
    %           parameters
    %       The following each define the LNField object with specified
    %           parameters; otherwise default
    %       obj = LNField(omega, depth)
    %       obj = LNField(omega, depth, x, y)
    %       obj = LNField(omega, depth, x, y, location, scale)
    %       obj = LNField(omega, depth, x, y, location, scale, demandMod)
    %   Methods:
    %       vals = obj.pointvalue(points)
    %           Returns the value of a specific point within the field.
    %           This point does not need to be within the range (1:X, 1:Y)
    %               of the original field.
    %           'points' is a 2-column matrix (M x 2), where:
    %               each row represents a point
    %               the first column are the points' x-coordinate
    %               the second column are the points' y-coordinate
    %           'vals' is a M-length column vector, with each element
    %               as the value of the corresponding point in points
    %       obj = obj.setproperty(...)
    %           Sets specified properties of the object to tune the field
    %               without changing the field's random characteristics
    %           Returns an object with new properties and generated field
    %               Recommend overwriting the old object with the new
    %           Inputs are in pairs, alternating between string property
    %               descriptor and requisite data element
    %           Valid string descriptor/data element pairs:
    %               'x', 'X'    -   integer greater than zero
    %               'Y', 'Y'    -   integer greater than zero
    %               'loc', 'location'
    %                           -   real number (double)
    %               'sca', 'scale'
    %                           -   real number (double) greater than zero
    %               'dmod', 'demandMod'
    %                           -   real number (double) nonnegative
    %           ex = ex.setproperty('X', 10, 'Y', 10, 'loc', 0, 'sca', 1, 'dmod', 1)
    %           ex = ex.setproperty('x', 100, 'y', 100, 'location', 5, ...
    %               'scale', 1.5, 'demandMod', 0)
    %       PPP = obj.nonstationaryppp(mode)
    %       PPP = obj.nonstationaryppp(mode, pts)
    %       PPP = obj.nonstationaryppp(mode, pts, num_real)
    %           Returns a PPP using the lnfield as the density function
    %           PPP is a cell array of length num_real, each element
    %               containing one realization of a non-stationary Poisson
    %               Point Process, using the log-normal field as the PPP's
    %               density function.  Each realization is a two-column
    %               matrix whereby each row is a point within the PPP, the
    %               first column the list of x-coordinates and the second
    %               column the list of y-coordinates.  The points all fall
    %               within the domain of the object's field (on the domain
    %               (0, x) and (0, y).
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
    %                   approximately x*y*pts*1.6.
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
    %                   realization: x*y*pts*1.6, for loc = 0, scale = 1.
    %               For mode == 1:
    %                   the number of points each realization will be
    %                   returned with.  Each element of PPP will be a
    %                   matrix of size [pts, 2].
    %           num_real is a positive integer indictating the number of
    %               realizations to generate.  PPP is a cell array of
    %               length num_real.
    %       obj.dispfield(...)
    %           Draws a visualization of the log-normal field to an
    %               associated figure
    %           With no input parameters, draws the field using the surf
    %               function on the next unused figure.
    %           First input parameter is a given figure to draw to.  E.g.:
    %               obj.dispfield(figure(1)) or obj.dispfield(figure, ...)
    %           Following input parameters are settings added to the surf
    %               function.  Inputs are in pairs or triplets.  Valid
    %               pairs are first the setting being modified as a string,
    %               then the value of the setting.  See surf function for
    %               details on these parameters. Valid triple is modifying
    %               the perspective of the surf, and is first the setting
    %               'view', followed by the parameters that would be passed
    %               to the view function (e.g. 0, 90).
    %               Example:    obj.dispfield(figure, 'view', 0, 90)
    %               or          obj.dispfield(figure, 'linestyle', 'none')
    %   Properties:
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
    %           To view, run obj.dispfield(...)
    %       FIELDGAUSS is the gaussian (normal) predecessor of FIELD,
    %           represented as a X by Y matrix.
    %           FIELD is log(FIELD * scale + loc)
    %       DEMAND is the sum total demand of the whole field.
    %       DEMANDMOD is a multiplicative modifier applied to DEMAND
    
    properties (SetAccess=immutable, GetAccess=private)
        i
        j
        phi
        psi
    end
    properties (SetAccess=immutable, GetAccess=public)
        omega       =   2*pi/30
        depth       =   25
    end
    properties (SetAccess=private, GetAccess=private)
        stdF
        meanF
        lambdaMax
    end
    properties (SetAccess=private, GetAccess=public)
        location    =   0
        scale       =   1
        x           =   10
        y           =   10
        field
        fieldGauss
        fieldNormalizedGauss
        demand
        demandMod   =   1
    end
    methods
        function obj=LNField(omega, depth, varargin)
            % varargin contains x, y, location, scale, demandMod
            if nargin > 7
                warning('lnfield:constructor:numArg', ...
                    'Too many arguments detected.\n.')
            end
            if nargin == 7
                if isnumeric(varargin{5}) && varargin{5} >= 0
                    obj.demandMod = varargin{5};
                else
                    error('lnfield:constructor:incDemMod', ...
                        'Incorrect input.\ndemandMod must be a nonnegative number.\n')
                end
            end
            if nargin == 5 || nargin == 3
                warning('lnfield:constructor:numArg', ...
                    'Expecting an different number of arguments.\n')
            end
            if nargin >= 6
                if isnumeric(varargin{3}) && isnumeric(varargin{4}) && ...
                        varargin{4} > 0
                    obj.location = varargin{3};
                    obj.scale = varargin{4};
                else
                    error('lnfield:constructor:incLocSca', ...
                        'Incorrect inputs.\nlocation must be a number.\nscale must be a positive number.\n')
                end
            end
            if nargin >= 4
                if isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
                        floor(varargin{1}) == varargin{1} && ...
                        floor(varargin{2}) == varargin{2} && ...
                        varargin{1} > 0 && varargin{2} > 0
                    obj.x = varargin{1};
                    obj.y = varargin{2};
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
            obj = obj.generatefield();
        end
        function vals=pointvalue(obj, points)
            % points is a 2-column array, containing points to solve
                % column 1 are x-coords, column 2 are y-coords
            if ~isnumeric(points) || size(points, 2) ~= 2 || ...
                    any(any(points <= 0))
                error('lnfield:pointvalue:incArg', ...
                    'Incorrect inputs.\npoints must be a 2-column matrix of positive numbers.\n')
            end
            vals = sum(     ...
                cos(points(:, 1)*obj.i +    ...
                    repmat(obj.phi, [size(points, 1), 1])) .*   ...
                cos(points(:, 2)*obj.j +    ...
                    repmat(obj.psi, [size(points, 1), 1])), 2) / obj.depth;
            vals = exp(obj.scale * (vals - obj.meanF) / obj.stdF + obj.location);
        end
        function obj=setproperty(obj, varargin)
            % Changes properties of the lnfield which would require
            % regeneration of the field.
            % Inputs are in pairs:
                % First element is a string descriptor indicating the
                    % property to be changed
                % Second element is the parameter's new value
            % Valid string descriptors, type, and descriptions:
                % 'x', 'X'  -   int, x-coord extent (1:X) of lnfield domain
                % 'y', 'Y'  -   int, y-coord extent (1:Y) of lnfield domain
                % 'loc', 'location'
                %           -   double, location parameter of ln dist
                % 'sca', 'scale'
                %           -   double > 0, scale parameer of ln dist
                % 'dmod', 'demandMod'
                %           -   double >= 0, demand parameter modifier
            if (nargin+1)/2 ~= floor((nargin+1)/2)
                error('lnfield:setproperty:numArg', ...
                    'Incorrect number of input arguments.\nThere must be an even number of input arguments.\nArguments are included as pairs; the first element is a text descriptor of the parameter to be changed, the second element is the new value of the parameter.')
            end
            if nargin == 1
                warning('lnfield:setproperty:noChange', ...
                    'No input arguments.\nNo changes made to lnfield object.\n')
            end
            for iArg = 1:2:nargin-1
                switch varargin{iArg}
                    case {'X', 'x'}
                        if isnumeric(varargin{iArg+1}) && ...
                                floor(varargin{iArg+1}) == varargin{iArg+1}
                            obj.x = varargin{iArg+1};
                        else
                            error('lnfield:setproperty:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case {'Y', 'y'}
                        if isnumeric(varargin{iArg+1}) && ...
                                floor(varargin{iArg+1}) == varargin{iArg+1}
                            obj.y = varargin{iArg+1};
                        else
                            error('lnfield:setproperty:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case {'loc', 'location'}
                        if isnumeric(varargin{iArg+1})
                            obj.location = varargin{iArg+1};
                        else
                            error('lnfield:setproperty:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case {'sca', 'scale'}
                        if isnumeric(varargin{iArg+1}) && varargin{iArg+1} > 0
                            obj.scale = varargin{iArg+1};
                        else
                            error('lnfield:setproperty:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    case {'dmod', 'demandMod'}
                        if isnumeric(varargin{iArg+1}) && varargin{iArg+1} >= 0
                            obj.demandMod = varargin{iArg+1};
                        else
                            error('lnfield:setproperty:incArg', ...
                                'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                        end
                    otherwise
                        error('lnfield:setproperty:incArg', ...
                            'Incorrect input.\nInputs must be valid alternating string descriptors and value declarations.\n')
                end
            end
            obj = obj.generatefield();
        end
        function PPP=nonstationaryppp(obj, mode, varargin)
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
                    % max(max(obj.field))*obj.x*obj.y*pts
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
                error('lnfield:nonstationaryppp:numArg', ...
                    'Too many input arguments.\nThere are only up to four input arguments.\n')
            end
            if nargin == 4
                % num_real; positive integer
                if isnumeric(varargin{2}) && varargin{2} > 0 && ...
                        floor(varargin{2}) == varargin{2}
                    num_real = varargin{2};
                else
                    error('lnfield:nonstationaryppp:incArg', ...
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
                            error('lnield:nonstationaryppp:incArg', ...
                                'For mode == 0, pts must be a positive number.\n')
                        end
                    else
                        pts = 1;
                    end
                    
                    PPP = cell(num_real, 1);
                    for real = 1:num_real
                        PPP{real} = obj.generateppp(poissrnd(obj.lambdaMax*pts*obj.x*obj.y));
                    end
                case 1
                    % Specific
                    if nargin >= 3
                        % pts; positive integer
                        if varargin{1} > 0 && isnumeric(varargin{1}) && ...
                                floor(varargin{1}) == varargin{1}
                            pts = varargin{1};
                        else
                            error('lnfield:nonstationaryppp:incArg', ...
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
                        tmp = obj.generateppp(pts);
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
                    error('lnfield:nonstationaryppp:incArg', ...
                        'mode must be a boolean value of 0 or 1.\n')
            end
        end
        function dispfield(obj, varargin)
            % Draws a the associated field using surf
            % varargin contains fig and surf properties
                % fig is the figure handle to draw the field on
                % properties are the assorted graphing properties
                    % These properties are in gropus, with the first item
                    % being the property name and the second the property
                    % value
                    % See surf for details of settable properties
                    % Can also set the view by calling the property name
                    % 'view' and followed by the new two argins begin
                    % associated values
            if nargin < 2
                figure
            else
                figure(varargin{1})
            end
            hold off
            s = surf(obj.field, 'linestyle', 'none');
            view(0, 90)
            title('Log-Normal Distributed Demand Field')
            xlabel('(m)')
            ylabel('(m)')
            iArg = 2;
            while iArg < nargin-1
                if strcmp(varargin{iArg}, 'view')
                    view(varargin{iArg+1}, varargin{iArg+2})
                    iArg = iArg + 3;
                else
                    set(s, varargin{iArg}, varargin{iArg+1})
                    iArg = iArg + 2;
                end
            end
            drawnow
        end
    end
    methods (Access=private)
        function obj=generatefield(obj)
            % Generate the lognormal field generated over the specified
                % domain, x and y, set for the field object
            [mx, my] = meshgrid(1:obj.x, 1:obj.y);
            points = [ ...
                reshape(mx, [obj.x*obj.y, 1])    ...
                reshape(my, [obj.x*obj.y, 1])    ];
            vals = sum(     ...
                cos(points(:, 1)*obj.i +    ...
                    repmat(obj.phi, [obj.x*obj.y, 1])) .*   ...
                cos(points(:, 2)*obj.j +    ...
                    repmat(obj.psi, [obj.x*obj.y, 1])), 2) / obj.depth;
            points = [rand([100000, 1]) * obj.x,    ...
                rand([100000, 1]) * obj.y];
            pointVals = sum(    ...
                cos(points(:, 1)*obj.i +    ...
                    repmat(obj.phi, [100000, 1])) .*   ...
                cos(points(:, 2)*obj.j +    ...
                    repmat(obj.psi, [100000, 1])), 2) / obj.depth;
            obj.stdF = sqrt(var(pointVals));
            obj.meanF = mean(pointVals);
            obj.fieldGauss = reshape(vals, [obj.y, obj.x]);
            vals = (vals - obj.meanF) / obj.stdF;
            obj.fieldNormalizedGauss = reshape(vals, [obj.y, obj.x]);
            vals = exp(obj.scale * vals + obj.location);
            obj.field = reshape(vals, [obj.y, obj.x]);
            obj.lambdaMax = max(max(obj.field));
            obj.demand = sum(sum(obj.field)) * obj.demandMod;
        end
        function PPP=generateppp(obj, num_pts)
            % Generate a set of points for a PPP, abstracted from specifics
                % Used for public method PPP; both mode == 0 and mode == 1
            PPP = [ ...
                obj.x*rand([num_pts, 1]),    ...
                obj.y*rand([num_pts, 1])     ];
            lamb = obj.pointvalue(PPP) / obj.lambdaMax;
            PPP(lamb <= rand(num_pts, 1), :) = NaN;
            PPP = PPP(~isnan(PPP));
            PPP = reshape(PPP, [length(PPP)/2 2]);
        end
    end
end
