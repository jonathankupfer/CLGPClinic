% GENERATEVPVINTERPOLANT generates a 3-dimensional griddedInterpolant
% that makes it possible to quickly generate I-V curves at arbitrary
% insolation and temperature conditions. This script creates the
% interpolant and saves the data space for quick reloading. See
% Vsim.m for a convenience function that generates the I-V curve for a
% vector of current values and fixed pair of G and T values.

% Peter N. Saeta, 180412

% Because I don't know how to call the damned Simulink module from
% within a function, this is just a script. It interacts with the
% Simulink module called 'kkimpvEfficient' via the following globals:

% Gcell = insolation in W/m^2
% Tcell = temperature in �C
% Imax = maximum current to use for a particular simulation run


% First define the values to simulate

insolations = 20:20:1000;
temperatures = 20:5:80;
currents = 0.05:0.05:8;

Gcell = 20; Tcell = 20;
Inommax = 7.61; % This is the nominal short-circuit current, but it is 
% not passed into the simulink model; I just have it copied here, so if
% the value needs to be changed, it has to be changed in both places.

% First compute the rectangular grid of points in (i, G, T) space
[x, y, z] = ndgrid(currents, insolations, temperatures);
% Each of x, y, and z is a three-dimensional array, with the points
% on the grid specified by the values in currents, insolations, and
% temperatures in the customary Matlab order. We now need to fill out a
% similar three-dimensional array of voltage values corresponding to each of
% these input conditions.
v = x * 0; % just copy one of them to get the right size, but set the
              % values to NaN

% Now we need to call the simulink simulation for each pair of (G,T) values,
% take the output vector of Vpvout values and their corresponding Ipvout
% currents, and use those to interpolate in one dimension to generate the
% line in v for each of the current values in currents.

hold off; % release any plot hold that might be lingering

for j = 1:length(insolations)
    Gcell = insolations(j);
    % for idealPV cells, we don't need negative values of voltage.
    % Therefore, we don't need a current greater than the short-circuit
    % current, which depends linearly on the insolation. Because the
    % current version of the simulink model has Iscn = 7.61 A, which
    % presumably corresponds to 1000 W/m^2.
    % When we figure out how to package the parameters into a single
    % struct, we would fetch the value from the struct, which should
    % be added to the parameter list.
    Imax = 1.1 * Gcell * Inommax / 1000;  % for idealPV, we don't need negative
    
    for k = 1:length(temperatures)        
        Tcell = temperatures(k);
        sim('kkimpvEfficient');     % run the simulation for this (Gcell,
                                    % Tcell)
        % now interpolate the output of the simulation into our
        % 'data cube' that will become the interpolant.
        % For values that would be extrapolated, use a large negative
        % number. I tried using NaN, but that prevents the interpolant
        % from working. The pchip method provides sensible smoothing.
        v(:, j, k) = interp1(Ipvout, Vpvout, currents, 'pchip', -50);
        % So you can monitor the output as we simulate...
        plot(Vpvout, Ipvout, 'b-', v(:, j, k), currents, 'ro');
        xlabel('Voltage'); ylabel('Current');
        titl = sprintf('G = %d W/m^2, T = %d�C', Gcell, Tcell);
        title(titl);
        axis([0 0.7 0 inf]);
        pause(0.05) % to force a screen update
    end
end
% Set any errant values to 0
v(isnan(v)) = 0; % shouldn't happen anymore, since we set extrapolations to -50
interpolant = griddedInterpolant(x, y, z, v, 'makima');
save('Example_interpolant.mat');
