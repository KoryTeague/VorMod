classdef CplexVorModTwoStageSolution < handle
    %CplexVorModTwoStageSolution VorMod Two-Stage Solution Data Object 
    %   Detailed explanation goes here
    
    properties (SetAccess=private, GetAccess=public)
        % Processed Data
        deltaSlice
        resourcesActive
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
        alpha
        alphaLength
        rateNormalization
        
        % Other
        path
    end
    
    methods
        function obj=CplexVorModTwoStageSolution(path)
            obj.path = path;
            
            %% Parse Model/Field Data
            splitData = split(fileread(obj.path), newline);
            %  1, Header; ignore
            %  2, ID Header; ID
            obj.ID = extractAfter(splitData{2}, '// ');
            %  3, Number of Resources; nResources
            obj.nResources = str2double(splitData{3});
            %  4, Number of Demand Points; nDemandPoints
            obj.nDemandPoints = str2double(splitData{4});
            %  5, Number of Realizations; nRealizations
            obj.nRealizations = str2double(splitData{5});
            %  6, Field Capacity/Demand; fieldDemand
            obj.fieldDemand = str2double(splitData{6});
            %  7, Resource Cost; cost
            obj.cost = obj.parsestring(splitData{7});
            %  8, Resource Capacity; capacity
            obj.capacity = obj.parsestring(splitData{8});
            %  9, Demand Point Demand; demand
            obj.demand = obj.parsestring(splitData{9});
            % 10, Realization Probability, probability
            obj.probability = obj.parsestring(splitData{10});
            % 11, Alpha
            obj.alpha = obj.parsestring(splitData{11});
            obj.alphaLength = length(obj.alpha);
            % 12, Rate Normalization, rateNormalization
            obj.rateNormalization = obj.parsestring(splitData{12});
            
            %% Parse Processed Data
            pathStart = extractBefore(obj.path, '.');
            obj.deltaSlice = cell(obj.alphaLength, 1);
            obj.resourcesActive = cell(obj.alphaLength, 1);
            obj.objectiveValues = zeros(obj.alphaLength, 1);
            obj.objectiveTimes = zeros(obj.alphaLength, 1);
            for iFile = 1:obj.alphaLength
                % del; deltaSlice
                obj.deltaSlice{iFile} = obj.parsestring(fileread(   ...
                    [pathStart '_outdel_' num2str(iFile) '.dat']));
                % x; resourcesActive
                obj.resourcesActive{iFile} = obj.parsestring(fileread(  ...
                    [pathStart '_outx_' num2str(iFile) '.dat']));
                % opt; objectiveValues
                obj.objectiveValues(iFile) = obj.parsestring(fileread(  ...
                    [pathStart '_outopt_' num2str(iFile) '.dat']));
                % tim; objectiveTimes
                obj.objectiveTimes(iFile) = obj.parsestring(fileread(   ...
                    [pathStart '_outtim_' num2str(iFile) '.dat']));
            end
        end
        function plotruntime(obj, varargin)
            % Plots the runtime trend of the CPLEX two-stage model
            % varargin may contain fid, the figure ID/handle to plot to
            if nargin == 2
                figure(varargin{1})
            end
            plot(obj.alpha, obj.objectiveTimes);
        end
        function plotobjective(obj, varargin)
            % Plots the objective value trend of the CPLEX two-stage model
            % varargin may contain fid, the figure ID/handle to plot to
            if nargin == 2
                figure(varargin{1})
            end
            plot(obj.alpha, obj.objectiveValues);
        end
        function plotactiveresources(obj, index, Field, varargin)
            % Plots the active resources of the state solution
            % index is the index of the solution to plot
            % Field is the Field struct present within the Voronoi model
                % of interest: DemandField (LNField), bsLocations
            % varargin may contain fid, the figure ID/handle to plot to
            %if nargin == 3
                %figure(varargin{1})
            %end
            %voronoi(Field.bsLocations(obj.resourcesActive{index}, 1),   ...
                %Field.bsLocations(obj.resourcesActive{index}, 2));
        end
        function plotcosts(obj, varargin)
            % Plots the cost trend of the CPLEX two-stage model
            % varargin may contain fid, the figure ID/handle to plot to
            if nargin == 2
                figure(varargin{1})
            end
            costs = zeros(1, obj.alphaLength);
            for iAlpha = 1:obj.alphaLength
                costs(iAlpha) = sum(obj.resourcesActive{iAlpha} .*  ...
                    obj.cost);
            end
            plot(obj.alpha, costs);
        end
        function appendsolutions(obj, newSol)
            obj.ID = [obj.ID ',(' num2str(obj.alphaLength) ')' newSol.ID];
            obj.deltaSlice = [obj.deltaSlice; newSol.deltaSlice];
            obj.resourcesActive = [obj.resourcesActive; ...
                newSol.resourcesActive];
            obj.objectiveValues = [obj.objectiveValues; ...
                newSol.objectiveValues];
            obj.objectiveTimes = [obj.objectiveTimes;   ...
                newSol.objectiveTimes];
            obj.alpha = [obj.alpha newSol.alpha];
            obj.alphaLength = obj.alphaLength + newSol.alphaLength;
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

