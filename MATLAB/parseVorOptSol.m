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

% Set this path before running
p = ['C++ Vormod\Results\' timestamp '\VorOptSol\'];

x_VorOptSol = cell(alpharng, 1);
del_VorOptSol = cell(alpharng, 1);
tim_VorOptSol = cell(alpharng, 1);
obj_VorOptSol = cell(alpharng, 1);

for index = 1:alpharng
    fprintf('Reading %i\n', index)
    x_VorOptSol{index} = CppPlexFileRead([p 'VorMod_outx_' ...
        num2str(index) '.dat']);
    del_VorOptSol{index} = CppPlexFileRead([p 'VorMod_outdel_' ...
        num2str(index) '.dat']);
    tim_VorOptSol{index} = CppPlexFileRead([p 'VorMod_outtim_' ...
        num2str(index) '.dat']);
    obj_VorOptSol{index} = CppPlexFileRead([p 'VorMod_outopt_' ...
        num2str(index) '.dat']);
end
