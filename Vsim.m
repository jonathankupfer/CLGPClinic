function v = Vsim(interpolant, iV, g, temp)
% VSIM: computes a vector of voltage values corresponding to the currents
%       iV and to insolation g and temperature temp.
    pts = zeros(length(iV),3);
    pts(:,1) = iV;
    pts(:,2) = g;
    pts(:,3) = temp;
    v = interpolant(pts);
end