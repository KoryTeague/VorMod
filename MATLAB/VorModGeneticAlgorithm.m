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
    %       fitnessCountHalt is the number of generations the genetic
    %           algorithm can progress without the fitness value of the
    %           fittest member changing.  That is, once fitnessCount >=
    %           fitnessCountHalt, the GA halts.  Positive integer
    %       memberCountHalt is the number of generations the genetic
    %           algorithm can progress without the fittest member changing.
    %           That is, once memberCount >= memberCountHalt, the GA halts.
    %           Positive integer
    %       flagGenerationReport is a control flag.
    %           if 0, obj.showgenerationreport() reports nothing
    %           if 1, obj.showgenerationreport() reports after every
    %               generation
    %           if 2 or 3, obj.showgenerationreport() reports only when the
    %               fittest member changes
    %       flagGenerationReportGraph is a control flag
    %           if 0, obj.showgenerationreport() doesn't graph the fittest
    %               member
    %           if a positive integer, obj.showgenerationreport() graphes
    %               the fittest member in a figure with id
    %               flagGenerationReportGraph
    
    properties (Access=public)
        % SetAccess=private, GetAccess=public
        Field
        demandField
        normalizedPixelDistances
        rangeCost
        capacityCost
        fitnessCountHalt
        memberCountHalt
        beta
        flagGenerationReport
        flagGenerationReportGraph
    end
    properties (Access=public)
        % protected
        memberFitness
        fittestMember
        fittestMemberFitness
        fittestCost
        fittestOverage
        previousFittestMember           =   0
        previousFittestMemberFitness    =   0
        fitnessCount                    =   0
        memberCount                     =   0
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
                % 'flagGenerationReport', 'GenerationReport', 'genrep',
                %   'generationreport'
                %                       -   {0, 1, 2}
                % 'flagGenerationReportGraph', 'GenerationReportGraph',
                %   'Graph', 'graph', 'genrepgraph'
                %                       -   nonnegative integer
                % 'fitnessCountHalt', 'fitnesscounthalt', 'fitcounthalt'
                %   'fitcount'
                %                       -   positive
                % 'memberCountHalt', 'membercounthalt', 'memcounthalt',
                %   'memcount'
                %                       -   positive
            beta = 1;
            rangeCost = 1;
            capacityCost = 1;
            fitnessCountHalt = 100;
            memberCountHalt = 250;
            flagGenerationReport = 1;
            flagGenerationReportGraph = 0;
            args = {};
            for iArg = 1:2:nargin-3
                switch varargin{iArg}
                    case {'Beta', 'beta'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                beta = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nbeta is a nonnegative value.\n')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nbeta is a nonnegative value.\n')
                        end
                    case {'rangeCost', 'rangecost', 'range', 'Range'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                rangeCost = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nrangeCost is a nonnegative value')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nrangeCost is a nonnegative value')
                        end
                    case {'capacityCost', 'capacitycost', 'Capacity',   ...
                            'capacity'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                capacityCost = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\ncapacityCost is a nonnegative value')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\ncapacityCost is a nonnegative value')
                        end
                    case {'flagGenerationReport', 'GenerationReport',   ...
                            'genrep', 'generationreport'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                flagGenerationReport = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nflagReport is a boolean value.\n')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nflagReport is a boolean value.\n')
                        end
                    case {'flagGenerationReportGraph',  ...
                            'GenerationReportGraph', 'Graph', 'graph',  ...
                            'genrepgraph'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                flagGenerationReportGraph = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nflagReportGraph is a positive integer.\n')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nflagReportGraph is a positive integer.\n')
                        end
                    case {'fitnessCountHalt', 'fitnesscounthalt',   ...
                            'fitcounthalt', 'fitcount'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                fitnessCountHalt = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nfitnessCountHalt is a positive value.\n')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nfitnessCountHalt is a positive value.\n')
                        end
                    case {'memberCountHalt', 'membercounthalt', ...
                            'memcounthalt', 'memcount'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                memberCountHalt = varargin{iArg+1};
                            else
                                error('vormodgeneticalgorithm:constructor:invVal',  ...
                                    'Invalid Value.\nmemberCountHalt is a positive value.\n')
                            end
                        else
                            error('vormodgeneticalgorithm:constructor:invVal',  ...
                                'Invalid Value.\nmemberCountHalt is a positive value.\n')
                        end
                    otherwise
                        args{end+1} = varargin{iArg};
                        args{end+1} = varargin{iArg+1};
                end
            end
            obj@GeneticAlgorithm(nMembers, memberLength, args{:});
            obj.Field = Field;
            obj.normalizedPixelDistances = Field.pixelDistances ./  ...
                repmat(permute(Field.baseStationRange, [2 3 1]),    ...
                [200 200 1]);
            obj.beta = beta;
            obj.demandField = obj.beta *    ...
                obj.Field.DemandField.demandMod *   ...
                obj.Field.DemandField.field;
            obj.rangeCost = rangeCost;
            obj.capacityCost = capacityCost;
            obj.fitnessCountHalt = fitnessCountHalt;
            obj.memberCountHalt = memberCountHalt;
            if flagGenerationReport == 3
                obj.flagGenerationReport = 2;
            else
                obj.flagGenerationReport = flagGenerationReport;
            end
            obj.flagGenerationReportGraph = flagGenerationReportGraph;
            obj.computefitness();
        end
        function setbeta(obj, betaIn)
            if isnumeric(betaIn)
                if betaIn >= 0
                    obj.beta = betaIn;
                else
                    error('vormodgeneticalgorithm:constructor:invVal',  ...
                        'Invalid Value.\nbeta is a nonnegative value.\n')
                end
            else
                error('vormodgeneticalgorithm:constructor:invVal',  ...
                    'Invalid Value.\nbeta is a nonnegative value.\n')
            end
            obj.demandField = obj.beta *    ...
                obj.Field.DemandField.demandMod *   ...
                obj.Field.DemandField.field;
            obj.reset()
        end
        function plotmembergradient(obj, fig, member, plotTitle)
            % Determine member loading
            baseStationIndices = find(member);
            [~, distanceMinIndex] = ...
                min(obj.Field.pixelDistances(:, :, logical(member)),[],3);
            baseStationLoad = zeros(obj.memberLength, 1);
            for iResource = 1:length(baseStationIndices)
                baseStationLoad(baseStationIndices(iResource)) =    ...
                    sum(obj.demandField(distanceMinIndex == ...
                    iResource));
            end
            
            % Plot
            figure(fig)
            hold off
            surf(obj.Field.DemandField.field -  ...
                max(max(obj.Field.DemandField.field)), 'linestyle', 'none')
            hold on
            if sum(baseStationLoad > 0) > 2
                voronoi(obj.Field.bsLocations(baseStationLoad > 0, 1),  ...
                    obj.Field.bsLocations(baseStationLoad > 0, 2), 'w')
            end
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > 0 & baseStationLoad <= obj.Field.baseStationCapacity / 5, 1),   ...
                obj.Field.bsLocations(baseStationLoad > 0 & baseStationLoad <= obj.Field.baseStationCapacity / 5, 2),   ...
                'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k')
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > obj.Field.baseStationCapacity / 5 & baseStationLoad <= 2 * obj.Field.baseStationCapacity / 5, 1),   ...
                obj.Field.bsLocations(baseStationLoad > obj.Field.baseStationCapacity / 5 & baseStationLoad <= 2 * obj.Field.baseStationCapacity / 5, 2),   ...
                's', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k')
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > 2 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 3 * obj.Field.baseStationCapacity / 5, 1),   ...
                obj.Field.bsLocations(baseStationLoad > 2 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 3 * obj.Field.baseStationCapacity / 5, 2),   ...
                'v', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k')
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > 3 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 4 * obj.Field.baseStationCapacity / 5, 1),   ...
                obj.Field.bsLocations(baseStationLoad > 3 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 4 * obj.Field.baseStationCapacity / 5, 2),   ...
                'd', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k')
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > 4 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 1.0001 * obj.Field.baseStationCapacity, 1),  ...
                obj.Field.bsLocations(baseStationLoad > 4 * obj.Field.baseStationCapacity / 5 & baseStationLoad <= 1.0001 * obj.Field.baseStationCapacity, 2),  ...
                '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
            scatter(    ...
                obj.Field.bsLocations(baseStationLoad > 1.0001 * obj.Field.baseStationCapacity, 1), ...
                obj.Field.bsLocations(baseStationLoad > 1.0001 * obj.Field.baseStationCapacity, 2), ...
                'h', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k')
            view(0, 90)
            hold off
            title(plotTitle)
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
%                [distanceMin, distanceMinIndex] =   ...
%                    min(obj.Field.pixelDistances(:, :,  ...
%                    logical(obj.members(iMem, :))), [], 3);
                [distanceMin, distanceMinIndex] =   ...
                    min(obj.normalizedPixelDistances(:, :,  ...
                    logical(obj.members(iMem, :))), [], 3);
                % Determine load on each base station and
                % the max range of the closest base station
                baseStationLoad = zeros(obj.memberLength, 1);
%                baseStationMaxRange = zeros(size(distanceMin));
                baseStationOvercoverage = zeros(obj.memberLength, 1);
                for jResource = 1:length(baseStationIndices)
%                    baseStationMaxRange(distanceMinIndex == jResource) =...
%                        obj.Field.baseStationRange(jResource) - ...
%                        (obj.Field.pixelWidth/2 * sqrt(2));
                    baseStationOvercoverage(baseStationIndices( ...
                        jResource)) = any(distanceMin(distanceMinIndex  ...
                        == jResource) > 1);
                    baseStationLoad(baseStationIndices(jResource)) =    ...
                        sum(obj.demandField(distanceMinIndex == ...
                        jResource));
                end
                % Correct fitness calculation: evaluate on a per base
                % station basis, not on a per pixel basis.  Could just
                % check if anything in the BS's cell exceeds normalized
                % range > 1
                % Calculate Fitness
%                obj.memberFitness(iMem) = 1 / ( ...
%                    sum(obj.members(iMem, :) .* ...
%                    obj.Field.baseStationCost') + obj.rangeCost *   ...
%                    sum(sum(distanceMin > baseStationMaxRange)) +   ...
%                    ((1 + obj.capacityCost)^obj.nGenerations - 1) * ...
%                    sum(max(0, (baseStationLoad -   ...
%                    obj.Field.baseStationCapacity) ./   ...
%                    obj.Field.baseStationCapacity)));
                obj.memberFitness(iMem) = 1 / ( ...
                    sum(obj.members(iMem, :) .* ...
                    obj.Field.baseStationCost') + obj.rangeCost *   ...
                    sum(baseStationOvercoverage) +  ...
                    ((1 + obj.capacityCost)^obj.nGenerations - 1) * ...
                    sum(max(0, (baseStationLoad -   ...
                    obj.Field.baseStationCapacity) ./   ...
                    obj.Field.baseStationCapacity)));
            end
            obj.computeroulette();
            [obj.fittestMember, index] = obj.findfittestmembers(1);
            obj.fittestMemberFitness = obj.memberFitness(index, :);
            obj.fittestCost = sum(obj.Field.baseStationCost' .*  ...
                obj.fittestMember);
            obj.fittestOverage = 1/obj.fittestMemberFitness -   ...
                obj.fittestCost;
        end
        function halt = shouldhalt(obj)
            % Fitness Halt Count
            if obj.fittestMemberFitness == obj.previousFittestMemberFitness
                obj.fitnessCount = obj.fitnessCount + 1;
            else
                obj.fitnessCount = 0;
                obj.previousFittestMemberFitness =  ...
                    obj.fittestMemberFitness;
            end
            
            % Member Halt Count
            %{
            if all(obj.fittestMember == obj.previousFittestMember) &&   ...
                    obj.fittestOverage > max(obj.Field.baseStationCost)
                obj.memberCount = obj.memberCount + 1;
            %}
            if all(obj.fittestMember == obj.previousFittestMember)
                obj.memberCount = obj.memberCount + 1;
            else
                obj.memberCount = 0;
                obj.previousFittestMember = obj.fittestMember;
                if obj.flagGenerationReport == 3
                    obj.flagGenerationReport = 2;
                    obj.showgenerationreport();
                end
            end
            
            halt = obj.fitnessCount > obj.fitnessCountHalt ||   ...
                obj.memberCount > obj.memberCountHalt;
            
            if halt && (obj.nGenerations >= obj.minGeneration)
                obj.flagGenerationReport = 2;
                obj.showgenerationreport();
            end
        end
        function showgenerationreport(obj)
            if any(obj.flagGenerationReport == [1, 2])
                % Report
                fprintf(['\nProcessed Generation:\t%d\t(%d | %d)\n' ...
                    'Maximum Fitness:\t%1.5e\n' ...
                    'BS:\t%1.5e\n'  ...
                    'Overage:\t%1.5e\n'],	...
                    obj.nGenerations, obj.minGeneration,    ...
                    obj.maxGeneration, obj.fittestMemberFitness,    ...
                    obj.fittestCost, obj.fittestOverage);
                if obj.flagGenerationReportGraph
                    % Display fittest member
                    obj.plotmembergradient( ...
                        obj.flagGenerationReportGraph,  ...
                        obj.fittestMember,  ...
                        ['Fittest Member; Generation: ' num2str(obj.nGenerations)])
                    drawnow
                end
            end
            if obj.flagGenerationReport == 2
                obj.flagGenerationReport = 3;
            end
        end
        function childreset(obj)
            obj.previousFittestMember = 0;
            obj.previousFittestMemberFitness = 0;
            obj.fitnessCount = 0;
            obj.memberCount = 0;
            if obj.flagGenerationReport == 3
                obj.flagGenerationReport = 2;
            end
        end
    end
    
end
