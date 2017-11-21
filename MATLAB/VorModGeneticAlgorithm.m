classdef VorModGeneticAlgorithm < GeneticAlgorithm
    %VorModGeneticAlgorithm Voronoi Model subclass of Genetic Algorithm
    %   Detailed explanation goes here
    %   Properties:
    %       beta is a weighting factor for weighing how much capacity the 
    %           genetic algorithm is to provide a given solution's
    %           allocation.  Assume '1' if not set.  Should be nonnegative.
    %       Field is a struct compiled within the VorMod script which holds
    %           important data for the field.  The Field contains:
    %           DemandField, an LNField object detailing the field
    %           baseStationRange, the range of each base station; the
    %               network is currently a homogeneous network, so it's a
    %               single value.
    %           baseStationCapacity, the capacity of each base station; the
    %               network is currently a homogeneous network, so it's a
    %               single value.
    %           pixelWidth, the width (in some distance such as meters) of
    %               a pixel in the field.
    %           bsLocations, a 2xnMembers matrix detailing the locations of
    %               the base stations with regards to the field.  The first
    %               column are x-coordinates, the second, y-.
    %           pixelDistances, a pre-calculated matrix (3D; rows x cols x
    %               base stations) detailing the distances from each pixel
    %               to each base station.
    %       demandField is a precalculated version of
    %           obj.Field.DemandField.field, weighted according to
    %           obj.Field.demandField.demandMod and obj.beta.  Additional
    %           memory usage to offset computation cost for computing
    %           fitness.
    %       rangeCost is the additional fitness cost for locations being
    %           out of range of available base stations.  Nonnegative
    %       capacityCost is the additional fitness cost for a base station
    %           (resource) being over-allocated.  Nonnegative
    
    properties (SetAccess=private, GetAccess=public)
        Field                   % Field struct from VorMod.m
        demandField
        rangeCost
        capacityCost
    end
    properties (Access=public)
        % protected
        memberFitness
    end
    properties (Access=public)
        beta
    end
    
    methods
        function obj=VorModGeneticAlgorithm(nMembers, memberLength, ...
                Field, varargin)
            % Subclass constructor
            % Adds support for Field and possible additional properties
            % (beta and rangeCost)
            % varargin contains any flags to be set, grouped in pairs
                % first element of pair is string label of flag to be set
                % second element is the value the flag is to be set to
            % Additional varargin flags:
                % 'Beta', 'beta'        -   nonnegative
                % 'rangeCost', 'rangecost', 'Range', 'range'
                %                       -   nonnegative
                % 'capacityCost', 'capacitycost', 'Capacity', 'capacity'
                %                       -   nonnegative
            beta = 1;
            rangeCost = 1;
            capacityCost = 1;
            args = {};
            for iArg = 1:2:nargin-3
                switch varargin{iArg}
                    case {'Beta', 'beta'}
                        if isnumeric(varargin{iArg+1})
                            beta = varargin{iArg+1};
                        end
                    case {'rangeCost', 'rangecost', 'range', 'Range'}
                        if isnumeric(varargin{iArg+1})
                            rangeCost = varargin{iArg+1};
                        end
                    case {'capacityCost', 'capacitycost', 'Capacity',   ...
                            'capacity'}
                        if isnumeric(varargin{iArg+1})
                            capacityCost = varargin{iArg+1};
                        end
                    otherwise
                        args{end+1} = varargin{iArg};
                        args{end+1} = varargin{iArg+1};
                end
            end
            obj@GeneticAlgorithm(nMembers, memberLength, args{:});
            obj.Field = Field;
            obj.beta = beta;
            obj.demandField = obj.beta *    ...
                obj.Field.DemandField.demandMod *   ...
                obj.Field.DemandField.field;
            obj.rangeCost = rangeCost;
            obj.capacityCost = capacityCost;
            obj.computefitness();
        end
    end
    
    methods (Access=protected)
        function computefitness(obj)
            obj.memberFitness = zeros(obj.nMembers, 1);
            for iMem = 1:obj.nMembers
                % Prep
                % Find which BS are in the current member
                baseStationIndices = find(obj.members(iMem, :));
                % Find closest BS and distance to BS for each pixel
                [distanceMin, distanceMinIndex] =   ...
                    min(obj.Field.pixelDistances(:, :, ...
                    logical(obj.members(iMem, :))), [], 3);
                % Determine load on each base station and
                % the max range of the closest base station
                baseStationLoad = zeros(obj.memberLength, 1);
                baseStationMaxRange = zeros(size(distanceMin));
                for jResource = 1:length(baseStationIndices)
                    baseStationMaxRange(distanceMinIndex == jResource) =...
                        obj.Field.baseStationRange(jResource) - ...
                        (obj.Field.pixelWidth/2 * sqrt(2));
                    baseStationLoad(baseStationIndices(jResource)) =    ...
                        sum(obj.demandField(distanceMinIndex == ...
                        jResource));
                end
                
                % Calculate Fitness
                obj.memberFitness(iMem) = 1 / ( ...
                    sum(obj.members(iMem, :) .* ...
                    obj.Field.baseStationCost') + obj.rangeCost *   ...
                    sum(sum(distanceMin > baseStationMaxRange)) +   ...
                    ((1 + obj.capacityCost)^obj.nGenerations - 1) * ...
                    sum(max(0, (baseStationLoad -   ...
                    obj.Field.baseStationCapacity) ./   ...
                    obj.Field.baseStationCapacity)));
            end
            obj.computeroulette();
        end
    end
    
end
