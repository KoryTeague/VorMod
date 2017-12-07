function cplexWriteDataOneStage(filepath, ID1, ID2, nResources, ...
    nDemandPoints, nRealizations, fieldDemand, cost, capacity, demand,  ...
    probability, activeResources, rateNormalization)
%cplexWriteDataOneStage Writes data for one-stage Voronoi model to file
%   Writes all data needed for the one-stage voronoi model to an input file
%   Header in the first three lines
%   Number of Resources; 0d
%   Number of Demand Points; 0d
%   Number of Realizations; 0d
%   Field Capacity; 0d
%   Resource Cost; 1d, length: Number of Resources
%   Resource Capacity; 1d, length: Number of Resources
%   Demand Point Demand; 1d, length: Number of Demand Points
%   Realization Probability; 1d, length: Number of Realizations
%   Available Resources; 1d, length: Number of Resources
%   Rate Normalization; 3d, Number of Demand Points x Number of Resources x
    % Number of Realizations
    
    % Create File
    fileID = fopen(filepath, 'W');
    
    % Header
    fprintf(fileID, ...
        '// CPLEX One Stage Voronoi Model .dat File\n// %s\n// %s\n',   ...
        ID1, ID2);
    
    % Number of Resources
    CppPlexFileWrite(fileID, nResources, 0, '%i');
    
    % Number of Demand Points
    CppPlexFileWrite(fileID, nDemandPoints, 0, '%i');
    
    % Number of Realizations
    CppPlexFileWrite(fileID, nRealizations, 0, '%i');
    
    % Field Capacity
    CppPlexFileWrite(fileID, fieldDemand, 0, '%.6e');
    
    % Resource Cost
    CppPlexFileWrite(fileID, cost, 1, '%.6e');
    
    % Resource Capacity
    CppPlexFileWrite(fileID, capacity, 1, '%.6e');
    
    % Demand Point Demand
    CppPlexFileWrite(fileID, demand, 1, '%.6e');
    
    % Realization Probability
    CppPlexFileWrite(fileID, probability, 1, '%.6e');
    
    % Available Resources
    CppPlexFileWrite(fileID, activeResources, 1, '%.6e');
    
    % Rate Normalization
    CppPlexFileWrite(fileID, rateNormalization, 1, '%.6e');
    
    fclose(fileID);
end
