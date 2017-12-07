classdef GeneticAlgorithmSolution < handle
    %GeneticAlgorithmSolution Wrapper for VorModGeneticAlgorithm Solution
    
    properties
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
    end
    
end
