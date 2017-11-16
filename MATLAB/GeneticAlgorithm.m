classdef GeneticAlgorithm < handle
    %GENETICALGORITHM 
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
    
    properties (SetAccess=immutable, GetAccess=public)
        nMembers
        memberLength
        nElitism        =   0
    end
    properties (SetAccess=private, GetAccess=public)
        nGenerations    =   0
        flagUniqueness  =   0
    end
    properties (Access=private)
        members
    end
    
    methods
        function obj=GeneticAlgorithm(nMembers, memberLength, varargin)
            % object parameters:
                % nMembers, memberLength
            % varargin contains any flags to be set, grouped in pairs
                % first element of pair is string label of flag to be set
                % second element is the value the flag is to be set to
            % Valid flags to set:
                % 'nElitism', 'Elitism', 'Elite', 'elitism', 'elite'    -
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
            obj.generateMembers();
        end
    end
    methods (Access=private)
        function generateMembers(obj)
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
    
end
