function [ rhoG, rhoS, rhoS_old, rho, rho_old, p ] = rhoTest( omega, L, X, Y, loc, sca )

    p.i = omega * rand(1, L);
    p.j = omega * rand(1, L);
    p.phi = 2 * pi * rand(1, L);
    p.psi = 2 * pi * rand(1, L);
    [mx, my] = meshgrid(1:X, 1:Y);
    points = [reshape(mx, [X*Y, 1]) reshape(my, [X*Y, 1])];
    
    vals = sum(cos(points(:, 1) * p.i + repmat(p.phi, [X*Y, 1])) .* ...
        cos(points(:, 2) * p.j + repmat(p.psi, [X*Y, 1])), 2) / L;
    rhoG = reshape(vals, [Y, X]);
    
    valsS = (vals - mean(vals)) / sqrt(var(vals));
    rhoS = reshape(valsS, [Y, X]);
    valsS = exp(sca * valsS + loc);
    rho = reshape(valsS, [Y, X]);
    
    valsS_old = vals / sqrt(var(vals));
    rhoS_old = reshape(valsS_old, [Y, X]);
    valsS_old = exp(sca * valsS_old + loc);
    rho_old = reshape(valsS_old, [Y, X]);

end
