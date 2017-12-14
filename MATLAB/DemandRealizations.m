classdef DemandRealizations < handle
    %DemandRealization Data object containing data point realization
        % Stores the demand point realization and generates the associated
        % data (Rate Normalization) for the data set
    
    properties (SetAccess=private, GetAccess=public)
        nResources
        nDemandPoints
        nRealizations
        demandPoints
            % cell array of length nRealizations.  Each element contains:
            % (nDemandPoints x 2) matrix containing coordinates of each
                % demand point with each row a demand point in (x, y) form
        resourceLocations
            % (nDemandPoints x 2) matrix containing coordinates of each
                % resource with each row a resource in (x, y) form
        normalizedResourceRange
            % vector of length nResources each containing the range radius
                % of each resource.  The ith element of vector corresponds
                % to the ith row of resourceLocations.  This value is in
                % distance units of the model normalized by the width of
                % the fundamental pixels of the model
        demandPointDemands
            % vector of length nDemandPoints each containing the demand of
                % each demand point
        ID
        
        rateNormalization
    end
    
    methods
        function obj = DemandRealizations(nResources, nDemandPoints,    ...
                nRealizations, demandPoints, resourceLocations, ...
                normalizedResourceRange, demandPointDemands, ID, mode)
            % mode determines how rateNormalization is determined
                % Only 'binary' is accepted
            if nargin ~= 0
                obj(nRealizations) = DemandRealizations;
                for iRealization = 1:nRealizations
                    %% Basic Parameters
                    obj(iRealization).nResources = nResources;
                    obj(iRealization).nDemandPoints = nDemandPoints;
                    obj(iRealization).nRealizations = nRealizations;
                    obj(iRealization).demandPoints =    ...
                        demandPoints{iRealization};
                    obj(iRealization).resourceLocations =   ...
                        resourceLocations;
                    obj(iRealization).normalizedResourceRange = ...
                        normalizedResourceRange;
                    obj(iRealization).demandPointDemands =  ...
                        demandPointDemands;
                    obj(iRealization).ID = ID;
                    
                    %% Compute rateNormalization
                    switch mode
                        case 'binary'
                            obj(iRealization).binaryratenormalization;
                        otherwise
                            error('demandrealizations:constructor:invMode', ...
                                'Invalid Mode.\nMode is character string.\nOnly "binary" is currently valid.\n');
                    end
                end
                %{
                %% Basic Parameters
                obj.nResources = nResources;
                obj.nDemandPoints = nDemandPoints;
                obj.nRealizations = nRealizations;
                obj.demandPoints = demandPoints;
                obj.resourceLocations = resourceLocations;
                obj.normalizedResourceRange = normalizedResourceRange;
                obj.demandPointDemands = demandPointDemands;
                obj.ID = ID;

                %% Compute rateNormalization
                switch mode
                    case 'binary'
                        obj.rateNormalization = obj.binaryratenormalization();
                    otherwise
                        error('demandrealizations:constructor:invMode', ...
                            'Invalid Mode.\nMode is character string.\nOnly "binary" is currently valid.\n');
                end
                %}
            end
        end
        function obj = appendrealizations(obj, nDemandPoints, nRealizations,  ...
                demandPoints, demandPointDemands, ID, mode)
            initialLength = length(obj);
            obj(initialLength + 1:initialLength + nRealizations) =  ...
                DemandRealizations;
            for iRealization = 1:nRealizations
                %% Basic Parameters
                obj(initialLength + iRealization).nResources =  ...
                    obj(1).nResources;
                obj(initialLength + iRealization).nDemandPoints =   ...
                    nDemandPoints;
                obj(initialLength + iRealization).nRealizations =   ...
                    nRealizations;
                obj(initialLength + iRealization).demandPoints =    ...
                    demandPoints{iRealization};
                obj(initialLength + iRealization).resourceLocations =   ...
                    obj(1).resourceLocations;
                obj(initialLength + iRealization).normalizedResourceRange = ...
                    obj(1).normalizedResourceRange;
                obj(initialLength + iRealization).demandPointDemands =	...
                    demandPointDemands;
                obj(initialLength + iRealization).ID = ID;
                
                %% Compute rateNormalization
                switch mode
                    case 'binary'
                        obj(iRealization).binaryratenormalization;
                    otherwise
                        error('demandrealizations:constructor:invMode', ...
                            'Invalid Mode.\nMode is character string.\nOnly "binary" is currently valid.\n');
                end
            end
        end
        function rateNorm = getratenormalization(obj, indices)
            % Returns rateNorm as a 3D array containing the rate
                % normalization property for the provided indices
                % Each matrix in rateNorm's depth is the rateNorm of a
                % specific index
            nDP = obj(indices(1)).nDemandPoints;
            rateNorm = zeros(nDP, nRes, length(indices));
            rateNorm(:, :, 1) = obj(indices(1)).rateNormalization;
            for iRealization = 2:length(indices)
                if obj(indices(iRealization)).nDemandPoints ~= nDP
                    error('demandrealizations:getratenormalization:invInd', ...
                        'Provided indexed realizations incompatable.\nAll Realizations pointed to in indices must have same number of demand points.\n')
                end
                rateNorm(:, :, iRealization) =  ...
                    obj(indices(iRealization)).rateNormalization;
            end
        end
    end
    
    methods(Access=private)
        function binaryratenormalization(obj)
            %{
            obj.rateNormalization = zeros(obj.nDemandPoints,    ...
                obj.nResources, obj.nRealizations);
            for iResource = 1:obj.nResources
                for jRealization = 1:obj.nRealizations
                    obj.rateNormalization(:, iResource, jRealization) = ...
                        sqrt((obj.demandPoints{jRealization}(:, 1) -    ...
                        obj.resourceLocations(iResource, 1)) .^ 2 + ...
                        (obj.demandPoints{jRealization}(:, 2) - ...
                        obj.resourceLocations(iResource, 2)) .^ 2);
                end
            end
            obj.rateNormalization(obj.rateNormalization >   ...
                obj.normalizedResourceRange) = 0;
            obj.rateNormalization(obj.rateNormalization ~= 0) = 1;
            %}
            obj.rateNormalization = zeros(obj.nDemandPoints,    ...
                obj.nResources);
            for iResource = 1:obj.nResources
                obj.rateNormalization(:, iResource) = sqrt( ...
                    (obj.demandPoints(:, 1) -   ...
                    obj.resourceLocations(iResource, 1)) .^ 2 + ...
                    (obj.demandPoints(:, 2) -   ...
                    obj.resourceLocations(iResource, 2)) .^ 2);
            end
            obj.rateNormalization(obj.rateNormalization >   ...
                obj.normalizedResourceRange) = 0;
            obj.rateNormalization(obj.rateNormalization ~= 0) = 1;
        end
    end
    
end
