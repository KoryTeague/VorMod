function cplexWriteDataTwoStage(filepath, ID, nResources,   ...
    nDemandPoints, nRealizations, cost, capacity, demand, probability,  ...
    alpha, rateNormalization)
%cplexWriteDataTwoStage Writes data for two-stage Voronoi model to file
%   Writes all data needed for the two-stage voronoi model to an input file
%   Header in the first two lines
%   Number of Resources; 0d
%   Number of Demand Points; 0d
%   Number of Realizations; 0d
%   1 - Will be removed later
%   Resource Cost; 1d, length: Number of Resources
%   Resource Capacity; 1d, length: Number of Resources
%   Demand Point Demand; 1d, length: Number of Demand Points
%   Realization Probability; 1d, length: Number of Realizations
%   Alpha; 1d, any length
%   Rate Normalization; 3d, Number of Demand Points x Number of Resources x
    % Number of Realizations

    % Create File
    fileID = fopen(filepath, 'W');
    
    % Header
    fprintf(fileID, ...
        '// CPLEX Two Stage Voronoi Model .dat File\n// %s\n', ID);
    
    % Number of Resources
    CppPlexFileWrite(fileID, nResources, 0, '%i');
    
    % Number of Demand Points
    CppPlexFileWrite(fileID, nDemandPoints, 0, '%i');
    
    % Number of Realizations
    CppPlexFileWrite(fileID, nRealizations, 0, '%i');
    
    % 1
    CppPlexFileWrite(fileID, 1, 0, '%.6e');
    
    % Resource Cost
    CppPlexFileWrite(fileID, cost, 1, '%.6e');
    
    % Resource Capacity
    CppPlexFileWrite(fileID, capacity, 1, '%.6e');
    
    % Demand Point Demand
    CppPlexFileWrite(fileID, demand, 1, '%.6e');
    
    % Scenario Probability
    CppPlexFileWrite(fileID, probability, 1, '%.6e');
    
    % Alpha
    CppPlexFileWrite(fileID, alpha, 1, '%.6e');
    
    % Rate Normalization
    CppPlexFileWrite(fileID, rateNormalization, 3, '%.6e');
    
    fclose(fileID);
end
