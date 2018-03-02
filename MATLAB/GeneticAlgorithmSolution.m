classdef GeneticAlgorithmSolution < handle
    %GeneticAlgorithmSolution Wrapper for VorModGeneticAlgorithm Solution
    
    properties (SetAccess=private)
        solutions       =   [];
        nSolutions      =   0;
        bestFitnesses   =   [];
        bestMembers     =   [];
        runTimes        =   [];
        nGenerations    =   [];
    end
    
    methods
        function addsolution(obj, GA, ID)
            % GA is a GeneticAlgorithm object
            % ID is some identifier for the added solution
            obj.nSolutions = obj.nSolutions + 1;
            obj.solutions = [obj.solutions; ID];
            obj.bestFitnesses = [obj.bestFitnesses, GA.bestFitnesses];
            obj.bestMembers = cat(3, obj.bestMembers, GA.bestMembers);
            obj.runTimes = [obj.runTimes; GA.runTime];
            obj.nGenerations = [obj.nGenerations; GA.nGenerations];
        end
        function plotfitness(obj, fid, varargin)
            % Plots the fitness trend of the contained GAs or a specific GA
            % fid is the identifier for a given figure handle
            % varargin may contain ID
                % ID is a vector of positive integers
                % ID contains the indices of all GA's to be plotted
            if nargin == 2
                ID = (1:obj.nSolutions)';
            else
                ID = varargin{1};
            end
            fit = obj.bestFitnesses(:, ID);
            for iID = 1:length(ID)
                %fit(obj.nGenerations(ID(iID))+1:end, iID) = NaN;
                fit(obj.nGenerations(ID(iID))+1:end, iID) = ...
                    fit(obj.nGenerations(ID(iID)), iID);
            end
            figure(fid);
            plot(1:size(fit, 1), fit(:, ID));
            xlabel('Generations')
            ylabel('Fitness')
            title('Genetic Algorithm, Fitness of Fittest Individual')
            legend(num2str(ID))
        end
        function plottime(obj, fid, varargin)
            % Plots the solution run time as a trend of the specified GAs
            % fid is the identifier for a given figure handle
            % varargin may contain ID
                % ID is a vector of positive integers
                % ID contains the indices of all GA's to be plotted
            if nargin == 2
                ID = 1:obj.nSolutions;
            else
                ID = varargin{1};
            end
            figure(fid)
            plot(obj.solutions(ID), obj.runTimes(ID))
            xlabel('GA')
            ylabel('CPU Time (seconds)')
            title('GA Runtime')
        end
        function plotnumgenerations(obj, fid, varargin)
            % Plots the maximum number of generations before a solution was
                % was found as a trend of the specified GAs
            % fid is the identifier for a given figure handle
            % varargin may contain ID
                % ID is a vector of positive integers
                % ID contains the indices of all GA's to be plotted
            if nargin == 2
                ID = 1:obj.nSolutions;
            else
                ID = varargin{1};
            end
            figure(fid)
            plot(obj.solutions(ID), obj.nGenerations(ID))
            xlabel('GA')
            ylabel('CPU Time (seconds)')
            title('GA Runtime')
        end 
    end
    
end
