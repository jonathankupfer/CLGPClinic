% GENERATEVPVINTERPOLANT generates a 3-dimensional griddedInterpolant
% that makes it possible to quickly generate I-V curves at arbitrary
% insolation and temperature conditions. This script creates the
% interpolant and saves the data space for quick reloading. See
% Vsim.m for a convenience function that generates the I-V curve for a
% vector of current values and fixed pair of G and T values.

% Peter N. Saeta, 180412
% revised 180424

% Gcell = insolation in W/m^2
% Tcell = temperature in °C
% Imax = maximum current to use for a particular simulation run

% First define the values to simulate
version = 1;    % 1 for Kyocera, 2 for idealPV
style = 'linear'; % or 'makima'
if (version == 1)
    NameOfInterpolant = 'Kyocera_interpolant';
    frac = 1;
    currentMargin = 1.2; % how much to push the current in reverse bias
else
    NameOfInterpolant = 'idealPV_interpolant'; % name of saved .mat file
    frac = 1 / 4;   % fraction of a full cell
    currentMargin = 1.1;
end

Tn = 25;
Voc = 38.3 / 60;
Isc = 9.26 * frac;
Rseries = 0.0042 * frac;
Rshunt = 91.8 * frac;
Kv = -0.0022;
Ki = 0.0004 * frac;

NEGATIVE = -30; % value to use on extrapolation

simulinkModel = 'kkKyocera';
Gcell = 20; Tcell = 20;

%% Range of the interpolant
insolations = 0:20:1200;
temperatures = 0:5:80;
currents = 0.0:0.05:11 * frac;



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
    % current, which depends linearly on the insolation. For Kyoceras,
    % we will need to go a bit deeper into reverse bias currents.
    Imax = currentMargin * Isc * Gcell / 1000;
    
    for k = 1:length(temperatures)        
        Tcell = temperatures(k);
        sim(simulinkModel);     % run the simulation for this (Gcell, Tcell)
        % Now interpolate the output of the simulation into our
        % 'data cube' that will become the interpolant.
        % For values that would be extrapolated, use a large negative
        % number. I tried using NaN, but that prevents the interpolant
        % from working. The pchip method provides sensible smoothing.
        try
            v(:, j, k) = interp1(Ipvout, Vpvout, currents, 'pchip', NEGATIVE);
        catch
            v(:, j, k) = 0;
        end
        % So you can monitor the output as we simulate...
        plot(Vpvout, Ipvout, 'b-', v(:, j, k), currents, 'ro');
        xlabel('Voltage'); ylabel('Current');
        titl = sprintf('G = %d W/m^2, T = %d°C', Gcell, Tcell);
        title(titl);
        % axis([0 0.7 0 inf]);
        pause(0.05) % to force a screen update
    end
end
% Set any errant values to 0
v(isnan(v)) = 0; % shouldn't happen anymore, since we set extrapolations to -50
interpolant = griddedInterpolant(x, y, z, v, style);
eval(strcat(NameOfInterpolant, " = interpolant;"));
save(strcat(NameOfInterpolant, '.mat'), NameOfInterpolant);


