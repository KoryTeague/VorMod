function [ EvalSet ] = generateandwriteevaldata( path, ID, Field,   ...
    nDemandPoints, nRealizations, varargin )
%generateandwriteevaldata Generate and write 'evaluation' DemReals object
%   Generates a new DemandRealizations object ('eval') that is used for
%       evaluating earlier solved sets (i.e. for VOE and VAE stage) and
%       writes this object to file
%   path is a string, providing the relative path to where to write the
%       cplex model files
%   ID is the EvalSet ID property for the generated realizations.
%       Generatlly a timestamp
%   Field is the VorMod.m Field struct; contains information regarding the
%       demand field
%   nDemandPoints is the number of demand points to generate within the new
%       realizations
%   nRealizations is the number of realizations to generate
%   varargin may contain:
%       mode, string that is recognized by DemandRealizations constructor

    if nargin == 6
        mode = 'binary';
    else
        mode = varargin{7};
    end

    %% Generate DR Object
    EvalSet = DemandRealizations(   ...
        length(Field.baseStationCapacity),  ...
        nDemandPoints,  ...
        nRealizations,  ...
        Field.DemandField.nonstationaryppp(1, nDemandPoints,    ...
            nRealizations), ...
        Field.bsLocations,  ...
        Field.baseStationRange' / Field.pixelWidth,  ...
        Field.DemandField.demand / nDemandPoints *  ...
            ones(nDemandPoints, 1), ...
        ID, ...
        mode);
    
    %% Write VOE files
    logForm = ;
    for iReal = 1:nRealizations
        EvalSet.writeonestage(  ...
            [path '\VorOptEval\Vormod_' num2str(
    
    %% Write VAE file

end
