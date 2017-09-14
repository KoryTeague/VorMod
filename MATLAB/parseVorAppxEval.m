% Parses the output of cpp formulated stage 2 evaluation for GA
% approximation across all alphas

if ~exist('betarng', 'var')
    if ~exist('beta', 'var')
        betarng = 1;
        fprintf('No betarng defined.\nDefining as beta = 1\n');
    else
        betarng = length(beta);
        fprintf('No betarng defined.\nDefining as length of beta\n');
    end
end

% Set this path before running
p = ['C++ Vormod\Results\' timestamp '\VorAppxEval\'];

del_VorAppxEval = cell(betarng, 1);
tim_VorAppxEval = cell(betarng, 1);
obj_VorAppxEval = cell(betarng, 1);

for index = 1:betarng
    fprintf('Reading %i\n', index)
    del_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2del.dat']);
    tim_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2tim.dat']);
    obj_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2opt.dat']);
end
    