classdef (Abstract) GeneticAlgorithm < handle
    %GeneticAlgorithm 
    %   Binary Genetic Algorithm superclass
    %   Contains all the necessary data and functions to run a standard
    %   binary genetic algorithm.  This includes generating the initial
    %   starting set of members for the first generation; generating a new
    %   generation via selection, crossover, and mutation; determine
    %   fitness; handle special properties if desired, like Elitism and
    %   Member Uniquenes; and able to cycle until a specified halting
    %   condition.
    %   Constructors:
    %       obj = GeneticAlgorithm(nMembers, memberLength, ...)
    %   Methods:
    %   Properties:
    %       nMembers is the number of members within each generation
    %       memberLength is the length (in bits) of each members'
    %           chromosome
    %       nElitism is a nonnegative integer detailing whether and to what
    %           extend the genetic algorithm practices Elitism.  If
    %           nElitism is 0, then the genetic algorithm does not use
    %           elitism, if it is a positive integer, then, before
    %           selection begins on a new generation, the fittest nElitism
    %           members of the previous generation are added to the next
    %           generation unchanged (i.e. without selection or mutation).
    %       flagUniqueness is a binary flag declaring whether the members
    %           within a given generation are all simulataneously unique.
    %           If set to 0, a generation may contain multiple members with
    %           the same chromosome.  If set to 1, all members have unique
    %           chromosomes.
    %       rateCrossover is the crossover rate of the genetic algorithm.
    %           During chromosome selection, the two selected chromosomes
    %           might "crossover", where the two chromsomes trade bits via
    %           some manner (i.e., uniform, n-point, etc.).  The rate
    %           probability of which this occurs is rateCrossover.
    %       rateMutation is the mutation rate of the genetic algorithm.
    %           During chromosome selection and after crossover, every bit
    %           of the selected/crossovered chromosomes has a chance of
    %           mutating (i.e., the bit value inverts).  The rate
    %           probability of which this occurs is rateMutation.
    %       minGeneration is the minimum number of generations the genetic
    %           algorithm will automatically process.  A nonnegative
    %           integer.
    %       maxGeneration is the maximum number of generations the genetic
    %           algorithm will automatically process.  A nonnegative
    %           integer greater than or equal to minGeneration.
    %       nGenerations is a counter of the number of (new) generations 
    %           that the genetic algorithm has processed since creation
    %       newMembers is an internal buffer storing the newly generated
    %           members to be present in the next generation.  Once
    %           selection, crossover, and mutation occurs to fill the
    %           newMembers buffer, the new generation within newMembers is
    %           set/saved in the default members property
    %       members is a binary two-dimensional array
    %           (nMembers x memberLength)
    %           members is the collection of active members within the
    %           current (nGenerations)th generation.  Each row is an
    %           individual member of the generation, while each column is
    %           an element present within the chromosomes.
    %       memberFitness is an array containing the overall fitness of the
    %           current (nGenerations)th generation's members.  The ith
    %           element of memberFitness corresponds to the fitness of the
    %           ith member of the generation (that is, of the ith row of
    %           members)
    %       fitnessRoulette is a running-sum variant of memberFitness.
    %           fitnessRoulette is to be calculated at the end of the
    %           computefitness method, once memberFitness has been
    %           calculated.  This can be done by calling the
    %           computeroulette method.
    %           fitnessRoulette(i) = sum(fitnessRoulette(1:i))
    
    properties (SetAccess=immutable, GetAccess=public)
        nMembers
        memberLength
        nElitism        =   0
        flagUniqueness  =   0
        rateCrossover   =   0.5
        rateMutation    =   0.5
        minGeneration   =   0
        maxGeneration   =   1000
    end
    
    properties (SetAccess=private, GetAccess=public)
        nGenerations    =   0
    end
    
    properties (Access=public)
        % private
        newMembers
    end
    
    properties (Access=public)
        % protected
        members
        fitnessRoulette
    end
    
    properties (Access=public, Abstract)
        % protected
        memberFitness
    end
    
    methods
        function obj=GeneticAlgorithm(nMembers, memberLength, varargin)
            % object parameters:
                % nMembers, memberLength
            % varargin contains any flags to be set, grouped in pairs
                % first element of pair is string label of flag to be set
                % second element is the value the flag is to be set to
            % Valid flags to set:
                % 'nElitism', 'Elitism', 'Elite', 'elitism', 'elite'
                %                       -   integer nonnegative
                % 'flagUniqueness', 'Uniqueness', 'Unique', 'uniqueness',
                %   'unique'            -   binary; 0 is off, >0 is on (1)
                % 'rateCrossover', 'Crossover', 'crossover'
                %                       -   double over [0, 1]
                % 'rateMutation', 'Mutation', 'mutation'
                %                       -   double over [0, 1]
                % 'minGeneration', 'min'
                %                       -   integer nonnegative
                % 'maxGeneration', 'max'
                %                       -   integer >= minGeneration
            % Parse Inputs
            if isnumeric(nMembers)
                obj.nMembers = nMembers;
            else
                error('geneticalgorithm:constructor:invVal',    ...
                    'Invalid Value.\nnMembers is a nonnegative integer.\n')
            end
            if isnumeric(memberLength)
                obj.memberLength = memberLength;
            else
                error('geneticalgorithm:constructor:invVal',    ...
                    'Invalid Value.\nmemberLength is a nonnegative integer.\n')
            end
            for iArg = 1:2:nargin-2
                switch varargin{iArg}
                    case {'nElitism', 'Elitism', 'Elite', 'elitism', 'elite'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                obj.nElitism = int32(varargin{iArg+1});
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nElitism is a nonnegative integer.\n')
                            end
                        else
                            error('geneticalgorithm:constructor:invVal',    ...
                                'Invalid Value.\nElitism is a nonnegative integer.\n')
                        end
                    case {'flagUniqueness', 'Uniqueness', 'Unique', ...
                            'uniqueness', 'unique'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                obj.flagUniqueness = varargin{iArg+1};
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nUniqueness is binary.\n')
                            end
                        else
                            error('geneticalgorithm:constructor:invVal',    ...
                                'Invalid Value.\nUniqueness is binary.\n')
                        end
                    case {'rateCrossover', 'Crossover', 'crossover'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0 && ...
                                    varargin{iArg+1} <= 1
                                obj.rateCrossover = varargin{iArg+1};
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nrateCrossover is a double over [0, 1].\n')
                            end
                        else
                            error('geneticalgorithm:constructor:invVal',    ...
                                'Invalid Value.\nrateCrossover is a double over [0, 1].\n')
                        end
                    case {'rateMutation', 'Mutation', 'mutation'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0 && ...
                                    varargin{iArg+1} <= 1
                                obj.rateMutation = varargin{iArg+1};
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nrateMutation is a double over [0, 1].\n')
                            end
                        else
                            error('geneticalgorithm:constructor:invVal',    ...
                                'Invalid Value.\nrateMutation is a double over [0, 1].\n')
                        end
                    case {'minGeneration', 'min'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                obj.minGeneration = int32(varargin{iArg+1});
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nminGeneration is a nonnegative integer.\n')
                            end
                        end
                    case {'maxGeneration', 'max'}
                        if isnumeric(varargin{iArg+1})
                            if varargin{iArg+1} >= 0
                                obj.maxGeneration = int32(varargin{iArg+1});
                            else
                                error('geneticalgorithm:constructor:invVal',    ...
                                    'Invalid Value.\nmaxGeneration is a nonnegative integer.\n')
                            end
                        end
                    otherwise
                        error('geneticalgorithm:constructor:invFlag',   ...
                            'Invalid Flag.\nSee documentation for valid flags.\n')
                end
            end
            if obj.minGeneration > obj.maxGeneration
                error('geneticalgorithm:constructor:invVal',    ...
                    'Invalid Value.\nminGeneration must be smaller than maxGeneration.\n')
            end
            obj.initializemembers();
            obj.newMembers = obj.members;
        end
        function onegeneration(obj)
            obj.nGenerations = obj.nGenerations + 1;
            % Find new members
                % Elitism
            obj.newMembers(1:obj.nElitism, :) = ...
                obj.findfittestmembers(obj.nElitism);
            iMember = obj.nElitism + 1;
            while iMember <= obj.nMembers
                % Selection, Crossover, & Mutation
                selectionMembers = obj.mutation(obj.uniformcrossover(   ...
                    obj.selectmembers));
                if obj.flagUniqueness
                    % Check selection for uniqueness
                    selectionMembers = obj.unique(selectionMembers, ...
                        iMember - 1);
                end
                % Save selection to obj.newMembers buffer
                for jSelection = 1:size(selectionMembers, 1)
                    if iMember <= obj.nMembers
                        obj.newMembers(iMember, :) =    ...
                            selectionMembers(jSelection, :);
                        iMember = iMember + 1;
                    end
                end
            end
            % Save new members
            obj.members = obj.newMembers;
            % Calculate fitness of new members
            obj.computefitness()
            % Handle Reporting
            obj.showgenerationreport()
        end
        function varargout = findfittestmembers(obj, num)
            % Find the fittest members in obj.members
            % num is how many members to return
            % varargout can contain up to two elements: fittestMembers and
                % fittestIndex
            % fittestMembers is a 2D array (num x memberLength) containing
                % the num fittest members.  That is, if members is sorted
                % in order from highest fitness to lowest fitness,
                % (sortedMembers), then:
                % fittestMembers = sortedMembers(1:num, :);
            % fittestIndex is a vector (length num) containing the index of
                % the fittest members (as reported in fittestMembers)
                % within obj.members
            [~, fitIndex] = sort(obj.memberFitness, 'descend');
            varargout{1} = obj.members(fitIndex(1:num), :);
            if nargout == 2
                varargout{2} = fitIndex(1:num);
            end
        end
        function computesolution(obj)
            % Compute the solution of the genetic algorithm by processing a
                % sequence of generations until a/the halting condition is
                % reached.  Handles maximum and minimum number of
                % generations.
            while 1
                % Compute Generation
                obj.onegeneration();
                % Halting
                if obj.nGenerations >= obj.maxGeneration
                    fprintf('Maximum Number of Generations Reached\nHalting\n')
                    break;
                elseif (obj.nGenerations >= obj.minGeneration) &&   ...
                        obj.shouldhalt()
                    % Specific Conditions Halt
                    fprintf('Other, Specific Conditions Occured\nHalting\n')
                    break;
                end
            end
        end
        function reset(obj)
            obj.initializemembers()
            obj.computefitness()
            obj.nGenerations = 0;
            obj.childreset()
        end
    end
    
    methods (Access=private)
        function initializemembers(obj)
            if obj.flagUniqueness
                obj.members = zeros(obj.nMembers, obj.memberLength);
                iMem = 1;
                while iMem <= obj.nMembers
                    tmpMember = randi(2, 1, obj.memberLength) - 1;
                    if ~ismember(tmpMember, obj.members(1:iMem-1, :),   ...
                            'rows')
                        obj.members(iMem, :) = tmpMember;
                        iMem = iMem + 1;
                    end
                end
            else
                obj.members = randi(2, obj.nMembers, obj.memberLength) - 1;
            end
        end
        function selectionIndices = selectmembers(obj)
            % Performs selection.  Selects two members using the roulette
                % method.
            randomSelect = obj.fitnessRoulette(end) * rand(1, 2);
            selectionIndices(1) = find(obj.fitnessRoulette ==   ...
                min(obj.fitnessRoulette(obj.fitnessRoulette >=  ...
                randomSelect(1))));
            selectionIndices(2) = find(obj.fitnessRoulette ==   ...
                min(obj.fitnessRoulette(obj.fitnessRoulette >=  ...
                randomSelect(2))));
        end
        function selectionMembers = uniformcrossover(obj, selectionIndices)
            if rand(1) < obj.rateCrossover
                selectionMembers = zeros(2, obj.memberLength);
                for iBit = 1:obj.memberLength
                    if rand(1) > 0.5
                        selectionMembers(:, iBit) = ...
                            obj.members(selectionIndices, iBit);
                    else
                        selectionMembers(:, iBit) = ...
                            obj.members(selectionIndices(2:-1:1), iBit);
                    end
                end
            else
                selectionMembers = obj.members(selectionIndices, :);
            end
        end
        function newSelection = mutation(obj, oldSelection)
            newSelection = oldSelection;
            for iMember = 1:2
                for jBit = 1:obj.memberLength
                    if rand(1) < obj.rateMutation
                        newSelection(iMember, jBit) =   ...
                            ~newSelection(iMember, jBit);
                    end
                end
            end
        end
        function uniqueSelection = unique(obj, selection, nMembers)
            % Check selection for mutual uniqueness
            selectionIndices = ones(1, size(selection, 1));
            for iSelection = 2:size(selection, 1)
                for jOthers = 1:(iSelection - 1)
                    if ismember(selection(iSelection, :),   ...
                            selection(1:jOthers, :), 'rows')
                        selectionIndices(iSelection) = 0;
                    end
                end
            end
            % Check selection for uniqueness with newMembers
            for iSelection = find(selectionIndices == 1)
                if ismember(selection(iSelection, :), ...
                        obj.newMembers(1:nMembers, :), 'rows')
                    selectionIndices(iSelection) = 0;
                end
            end
            uniqueSelection = selection(selectionIndices == 1, :);
        end
    end
    
    methods (Access=protected)
        function computeroulette(obj)
            obj.fitnessRoulette(1) = obj.memberFitness(1);
            for iMem = 2:obj.nMembers
                obj.fitnessRoulette(iMem) = obj.memberFitness(iMem) +   ...
                    obj.fitnessRoulette(iMem - 1);
            end
        end
    end
    
    methods (Access=protected, Abstract)
        computefitness(obj)
        % Compute/Calculate fitness heuristic for the present members
            % Run after each operation that changes the group of members
        halt = shouldhalt(obj)
        % Returns a boolean (halt) which tells the genetic algorithm to
            % halt; halt = 1 iff GA should halt, halt = 0 otherwise;
            % handles any special halting conditions beyond minimum and
            % maximum generation count.
        showgenerationreport(obj)
        % Handles any reporting that happens at the end of each generation
            % processing
        childreset(obj)
        % Handles any additional resetting a child object would need.
            % Called at the end of obj.reset().
    end
end
