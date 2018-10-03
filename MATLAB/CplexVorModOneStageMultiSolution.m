classdef CplexVorModOneStageMultiSolution < handle
    %CplexVorModOneStageSolution VorMod One-Stage Solution Data Object 
    %   Detailed explanation goes here
    
    properties (SetAccess=private, GetAccess=public)
        % Processed Data
        deltaSlice
        objectiveValues
        objectiveTimes
        
        % Field/Model Data
        ID
        nResources
        nDemandPoints
        nRealizations
        fieldDemand
        cost
        capacity
        demand
        probability
        activeResources
        rateNormalization
        
        % Other
        path
        ID2
    end
    
    methods
        function obj=CplexVorModOneStageMultiSolution(path, ID1, ID2)
            if nargin ~= 0
                obj(length(ID1), length(ID2)) = ...
                    CplexVorModOneStageMultiSolution;
                lF1 = ['%0' num2str(ceil(log10(length(ID1) + 1))) 'u'];
                lF2 = ['%0' num2str(ceil(log10(length(ID2) + 1))) 'u'];
                for iFile = 1:length(ID1)
                    for jFile = 1:length(ID2)
                        fprintf('Reading %i,%i\n', iFile, jFile)
                        obj(iFile, jFile).path = [path '\Vormod_'   ...
                            num2str(iFile, lF1) '_' num2str(jFile, lF2) ...
                            '.dat'];
                        obj(iFile, jFile).ID2 = [ID1(iFile), ID2(jFile)];
                        
                        %% Parse Model/Field Data
                        splitData = split(fileread( ...
                            obj(iFile, jFile).path), newline);
                        %   1, Header; ignore
                        %   2, Header; ignore
                        %   3, ID Header, ID
                        obj(iFile, jFile).ID =  ...
                            extractAfter(splitData{3}, '// ');
                        %   4, Number of Resources, nResources
                        obj(iFile, jFile).nResources =  ...
                            str2double(splitData{4});
                        %  5, Number of Demand Points, nDemandPoints
                        obj(iFile, jFile).nDemandPoints =   ...
                            str2double(splitData{5});
                        %  6, Number of Realizations, nRealizations
                        obj(iFile, jFile).nRealizations =   ...
                            str2double(splitData{6});
                        %  7, Field Capacity/Demand, fieldDemand
                        obj(iFile, jFile).fieldDemand = ...
                            str2double(splitData{7});
                        %  8, Resource Cost, cost
                        obj(iFile, jFile).cost =    ...
                            obj(iFile).parsestring(splitData{8});
                        %  9, Resource Capacity, capacity
                        obj(iFile, jFile).capacity =    ...
                            obj(iFile, jFile).parsestring(splitData{9});
                        % 10, Demand Point Demand, demand
                        obj(iFile, jFile).demand =  ...
                            obj(iFile, jFile).parsestring(splitData{10});
                        % 11, Realization Probability, probability
                        obj(iFile, jFile).probability = ...
                            obj(iFile, jFile).parsestring(splitData{11});
                        % 12, Active Resources, activeResources
                        obj(iFile, jFile).activeResources = ...
                            obj(iFile, jFile).parsestring(splitData{12});
                        % 13, Rate Normalization, rateNormalization
                        obj(iFile, jFile).rateNormalization =   ...
                            obj(iFile, jFile).parsestring(splitData{13});
    
                        %% Parse Processed Data
                        pathStart = ...
                            extractBefore(obj(iFile, jFile).path, '.');
                        % del; deltaSlice
                        obj(iFile, jFile).deltaSlice =  ...
                            obj(iFile, jFile).parsestring(fileread( ...
                            [pathStart '_out2del.dat']));
                        % opt; objectiveValues
                        obj(iFile, jFile).objectiveValues =	...
                            obj(iFile, jFile).parsestring(fileread( ...
                            [pathStart '_out2opt.dat']));
                        % tim; objectiveTimes
                        obj(iFile, jFile).objectiveTimes =  ...
                            obj(iFile, jFile).parsestring(fileread( ...
                            [pathStart '_out2tim.dat']));
                    end
                end
            end
        end
    end
    
    methods (Access=private)
        function data = parsestring(~, string)
            %% Setup
            a = 0;
            b = 0;
            c = 0;
            numStr = '';
            dim = 0;
            dimOver = 0;
            while string(dimOver + 1) == '['
                dimOver = dimOver + 1;
            end
            
            %% Parse Majority
            for index = 1:length(string)
                if string(index) == '['
                    % A dimension deeper, and shift index dimension
                    dim = dim + 1;
                    switch dim
                        case 1
                            a = a + 1;
                            b = 0;
                            c = 0;
                        case 2
                            b = b + 1;
                            c = 0;
                        case 3
                            c = c + 1;
                        otherwise
                            error('Something went wrong\ndim+\n')
                    end
                elseif string(index) == ']'
                    % A dimension shallower
                    dim = dim - 1;
                elseif string(index) == ','
                    % Parse numStr to value
                    tmp = str2double(numStr);
                    numStr = '';
                    switch dimOver
                        case 1
                            data{a} = tmp;
                        case 2
                            data{a, b} = tmp;
                        case 3
                            data{a, b, c} = tmp;
                        otherwise
                            error('Something went wrong\n,switch\n')
                    end
                    switch dim
                        case 1
                            a = a + 1;
                            b = 0;
                            c = 0;
                        case 2
                            b = b + 1;
                            c = 0;
                        case 3
                            c = c + 1;
                        otherwise
                            error('Something went wrong\n,\n')
                    end
                elseif string(index) == ' '
                    % Do nothing, ignore
                else
                    % Character is part of number
                    numStr = [numStr string(index)];
                end
            end

            %% Parse Final Element and Convert to Non-Cell Array
            % Elements are added to variable at commas.  No comma after final val
            tmp = str2double(numStr);
            switch dimOver
                case 0
                    data = tmp;
                case 1
                    data{a} = tmp;
                    data = cell2mat(data);
                case 2
                    data{a, b} = tmp;
                    data = cell2mat(data);
                case 3
                    data{a, b, c} = tmp;
                    data = cell2mat(data);
                otherwise
                    error('Something went wrong\nendswitch\n')
            end
        end
    end
    
end

