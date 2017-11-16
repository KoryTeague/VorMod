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
    %       nGenerations is a counter of the number of (new) generations 
    %           that the genetic algorithm has processed since creation
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
    
    properties (SetAccess=immutable, GetAccess=public)
        nMembers
        memberLength
        nElitism        =   0
        flagUniqueness  =   0
    end
    properties (SetAccess=private, GetAccess=public)
        nGenerations    =   0
    end
    properties (Access=private)
        newMembers
    end
    properties (Access=protected)
        members
    end
    properties (Access=protected, Abstract)
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
                                obj.nElitism = int8(varargin{iArg+1});
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
                    otherwise
                        error('geneticalgorithm:constructor:invFlag',   ...
                            'Invalid Flag.\nSee documentation for valid flags.\n')
                end
            end
            obj.initializemembers();
            obj.newMembers = obj.members;
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
    end
    methods (Access=public)
        function onegeneration(obj)
            % Find new members
                % Elitism
            obj.newMembers(1:obj.nElitism, :) = ...
                obj.findfittestmembers(obj.nElitism);
                % Selection
                    % Crossover
                    % Mutation
                    % Uniqueness
            % Save new members
            obj.members = obj.newMembers;
            % Calculate fitness of new members
        end
        function fittestMembers = findfittestmembers(obj, num)
            % Find the fittest members in obj.members
            % num is how many members to return
            % fittestMembers is a 2D array (num x memberLength) containing
                % the num fittest members.  That is, if members is sorted
                % in order from highest fitness to lowest fitness,
                % (sortedMembers), then:
                % fittestMembers = sortedMembers(1:num, :);
            
        end
    end
    methods (Abstract)
        computefitness(obj)
        % Compute/Calculate fitness heuristic for the present members
        % Run after each operation that changes the group of members
    end
end
