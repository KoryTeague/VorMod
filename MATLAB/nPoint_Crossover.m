function [ om1, om2 ] = nPoint_Crossover( im1, im2, n )
%nPoint_Crossover Performs an n-point crossover for genetic algorithms
%   Mixes (crossover) information from two chromosomes (members) of a
%       genetic algorithm to form two new chromosomes (members)
%   Each crossover point is randomly located within the chromosome; all
%       genes before the crossover point is given to one chromosome and all
%       genes after - but before the next crossover point - is given to the
%       other chromosome; this alternates for each crossover point
%   im1 and im2 are the input chromosomes (members)
%   n is an integer representing the number of crossover points
%   om1 and om2 are the output chromosomes (members)

    % Select crossover points; these can overlap as implemented
    xo_pts = [randi(length(im1), n, 1); length(im1)];
    xo_pts = sort(xo_pts);
    
    % Crossover
    om1 = im1;
    om2 = im2;
    for a = 1:2:n
        om1(xo_pts(a):(xo_pts(a+1)-1)) = im2(xo_pts(a):(xo_pts(a+1)-1));
        om2(xo_pts(a):(xo_pts(a+1)-1)) = im1(xo_pts(a):(xo_pts(a+1)-1));
    end

end
