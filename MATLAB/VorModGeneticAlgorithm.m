classdef VorModGeneticAlgorithm < GeneticAlgorithm
    %VorModGeneticAlgorithm Voronoi Model subclass of Genetic Algorithm
    %   Detailed explanation goes here
    %   Properties:
    %       beta is a weighting factor for weighing how much capacity the 
    %           genetic algorithm is to provide a given solution's
    %           allocation.  Assume '1' if not set.  Should be nonnegative.
    
    properties (SetAccess=private, GetAccess=public)
        beta
        Field                   % Field struct from VorMod.m
        demandField
        rangeCost
        capacityCost
    end
    properties (Access=public)
        % protected
        memberFitness
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
                baseStationIndices = find(obj.members(iMem, :));
                [distanceMin, distanceMinIndex] =   ...
                    min(obj.Field.pixelDistances(:, :, ...
                    logical(obj.members(iMem, :))), [], 3);
                baseStationLoad = zeros(obj.memberLength, 1);
                for iRows = 1:size(obj.Field.pixelDistances, 1)
                    for jCols = 1:size(obj.Field.pixelDistances, 2)
                        index = baseStationIndices(	...
                            distanceMinIndex(iRows, jCols));
                        baseStationLoad(index) =    ...
                            baseStationLoad(index) +    ...
                            obj.demandField(iRows, jCols);
                    end
                end
                obj.memberFitness(iMem) = 1 / ( ...
                    sum(obj.members(iMem, :)) + ...
                    obj.rangeCost * sum(sum(distanceMin >	...
                    obj.Field.baseStationRange -    ...
                    sqrt(2)/2 * obj.Field.pixelWidth)) +    ...
                    ((1 + obj.capacityCost)^obj.nGenerations - 1) * ...
                    sum(max(0, baseStationLoad -    ...
                    obj.Field.baseStationCapacity)) /   ...
                    obj.Field.baseStationCapacity);
            end
            obj.computeroulette();
        end
    end
    
end
