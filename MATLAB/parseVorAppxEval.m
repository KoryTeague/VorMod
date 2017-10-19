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

% Path - data should be in the appropriate directory
% Set so long as the associated data set is loaded into MATLAB (timestamp)
p = ['C++ Vormod\Results\' timestamp '\VorAppxEval\'];

% Variable Definition
%{
del_VorAppxEval = cell(betarng, 1);
tim_VorAppxEval = cell(betarng, 1);
obj_VorAppxEval = cell(betarng, 1);
%}
clear 'VAE'

VAE.del = cell(betarng, 1);
VAE.tim = zeros(betarng, 1);
VAE.obj = zeros(betarng, 1);
VAE.sat = zeros(betarng, 1);

% Read
for index = 1:betarng
    fprintf('Reading %i\n', index)
    
    VAE.del{index} = CppPlexFileRead([p 'Vormod_'   ...
        num2str(index, log_form) '_out2del.dat']);
    VAE.tim(index) = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2tim.dat']);
    VAE.obj(index) = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2opt.dat']);
    VAE.sat(index) = satis(VAE.del{index}, demand);
    %{
    del_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2del.dat']);
    tim_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2tim.dat']);
    obj_VorAppxEval{index} = CppPlexFileRead([p 'Vormod_' ...
        num2str(index, log_form) '_out2opt.dat']);
    %}
end

% Save
save(['C++ Vormod\Results\' timestamp '\VAEres'],   ...
    'beta', 'betarng', 'VAE');
