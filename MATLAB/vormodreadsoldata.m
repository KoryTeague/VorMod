function [VOS, VAS] = vormodreadsoldata( path, betas )
%vormodreadsoldata Reads VorMod Sol data (learning set; VOS/VAS) from files
%   Reads the solution-stage Voronoi Model cplex output data
%   VOS - Voronoi model Optimization Solution - solution of two-stage cplex
%       optimization problem using initial learning set
%   VAS - Voronoi model Approximation Solution - solution of one-stage
%       cplex optimization problem using initial learning set and genetic
%       algorithm output
%   path - base path to find data folders (organized appropriately) and
%       where to save a matlab archives (.mat files)
%   betas - vector containing beta values; used as ID2 in each element of
%       VAS object array to identify the separate solutions to their
%       according genetic algorithm solution

    %% Read Files
    VOS = CplexVorModTwoStageSolution([path '\VorOptSol\Vormod.dat']);
    VAS = CplexVorModOneStageSolution([path '\VorAppxSol'], betas);

    %% Save
    save([path '\_ReadSolData.mat'], 'VOS', 'VAS');
end
