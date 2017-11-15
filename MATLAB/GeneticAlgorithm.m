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
    %       obj = GeneticAlgorithm() is the default constructor.  This
    %           generates an empty or default genetic algorithm
    %       obj = GeneticAlgorithm(...)
    
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
                % 'nElitism', 'Elitism' -   integer nonnegative
                % 'flagUniqueness', 'Uniqueness'
                %                       -   binary; 0 is off, >0 is on
            obj.nMembers = nMembers;
            obj.memberLength = memberLength;
            for iArg = 1:2:nargin-2
                switch varargin{iArg}
                    case {'nElitism', 'Elitism'}
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
                    case {'flagUniqueness', 'Uniqueness'}
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
        end
    end
    
end

