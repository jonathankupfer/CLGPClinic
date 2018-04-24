% Kyocera PV modeling
% 
% KU265-6MCA
% Serial 16YB6A4N0001316
%       1000 W/m^2   800 W/m^2
% Voc = 38.3 V       
% Isc = 9.26 A
% Vpmax 31.0 V       27.9 V
% Ipmax 8.55 A       6.85 A
% Pmax  265 W        191 W
% 10 x 6 grid, so 20 cells per string

frac = 1 / 4;   % fraction of a full cell
Tn = 25;    % is this the right nominal temperature?
Voc = 38.3 / 60;
Isc = 9.26 * frac;
Rseries = 0.0042 * frac;
Rshunt = 91.8 * frac;
Kv = -0.0022;
Ki = 0.0004 * frac;
xvals = 0.001:0.0005:0.005;
xvar = 'Rseries';
xvals = xvals * frac;

Imax = 9 * frac;
Gcell = 800;
Tcell = 45;
Imax = 9.5 * frac * Gcell / 1000;

simul = 'kkKyocera_upd';
annot = sprintf('Rseries = %.2f mohm\nRshunt = %.1f ohm\n', ...
    Rseries * 1000, Rshunt);
annot = sprintf('%sKv = %.1f mV/K\nKi = %.1f mA/K', annot, 1000*Kv, 1000*Ki);

% simulate for a range of some parameter and produce a 
% plot of the relative discrepancy between computed values
% and the specifications of the Kyocera panels.

relmiss = zeros(length(xvals),6); % relative offsets for the 6 outputs

for j = 1:length(xvals)
    cmd = sprintf("%s = %g", xvar, xvals(j));
    eval(cmd);
    %Kv = xvals(j); % update the variable we're testing
    Gcell = 800; Tcell = 45; Imax = 9.5 * frac * Gcell / 1000;
    sim(simul);
    power = 60 * Vpvout .* Ipvout;
    [m, in] = max(power); % max value and index
    relmiss(j,1) = (m/frac - 191)/191;
    relmiss(j,3) = Ipvout(in)/6.85/frac - 1;
    relmiss(j,5) = 60 * Vpvout(in)/27.9 - 1;
    
    Gcell = 1000; Tcell = 25; Imax = 9.5 * frac * Gcell / 1000;
    sim(simul);
    power = 60 * Vpvout .* Ipvout;
    [m, in] = max(power); % max value and index
    relmiss(j,2) = m/265/frac - 1;
    relmiss(j,4) = Ipvout(in)/8.55/frac - 1;
    relmiss(j,6) = 60 * Vpvout(in)/31 - 1;
end

relmiss = relmiss * 100; % convert to percentage
plot(xvals, relmiss(:,1), '-r*', ...
    xvals, relmiss(:,2), '-ro',...
    xvals, relmiss(:,3),'-b*', xvals, relmiss(:,4), '-bo',...
    xvals, relmiss(:,5), '-k*', xvals, relmiss(:,6), '-ko', ...
    'MarkerSize', 12);
legend('P 0.8', 'P 1.0', 'I 0.8', 'I 1.0', 'V 0.8', 'V 1.0');
xlabel(xvar);
ylabel('Percent Error');
text(xlim * [0.9;0.1], ylim * [0.2;0.8], annot, 'FontSize', 14);
