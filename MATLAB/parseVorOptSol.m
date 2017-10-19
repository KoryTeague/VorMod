% Parses the output of the cpp formulation to generate the entire sequence
% of data, across all alphas
if ~exist('alpharng', 'var')
    if ~exist('alpha', 'var')
        alpharng = 1;
        fprintf('No alpharng defined.\nDefining as alpha = 1\n');
    else
        alpharng = length(alpha);
        fprintf('No alpharng defined.\nDefining as length of alpha');
    end
end

% Path - data should be in the appropriate directory
% Set so long as the associated data set is loaded into MATLAB (timestamp)
p = ['C++ Vormod\Results\' timestamp '\VorOptSol\'];

% Variable Definition
clear 'VOS'

VOS.x = cell(alpharng, 1);
VOS.del = cell(alpharng, 1);
VOS.del_mod = cell(alpharng, 1);
VOS.tim = zeros(alpharng, 1);
VOS.obj = zeros(alpharng, 1);
VOS.sat = zeros(alpharng, 1);

% Read
for index = 1:alpharng
    fprintf('Reading %i\n', index)
    
    VOS.x{index} = CppPlexFileRead([p 'VorMod_outx_'	...
        num2str(index) '.dat']);
    VOS.del{index} = CppPlexFileRead([p 'VorMod_outdel_'	...
        num2str(index) '.dat']);
    VOS.del_mod{index} = VOS.del{index} *	...
        (sum(sum(field.field)) * scale * pix_dist^2);
    VOS.tim(index) = CppPlexFileRead([p 'VorMod_outtim_'	...
        num2str(index) '.dat']);
    VOS.obj(index) = CppPlexFileRead([p 'VorMod_outopt_'	...
        num2str(index) '.dat']);
    VOS.sat(index) = satis(VOS.del_mod{index}, demand);
end

% Save
save(['C++ Vormod\Results\' timestamp '\VOSres_'    ...
    strrep(num2str(alpha(1)), '.', '_') '-' ...
    strrep(num2str(alpha(2) - alpha(1)), '.', '_') '-'  ...
    strrep(num2str(alpha(end)), '.', '_')], 'alpha', 'alpharng', 'VOS');
