function uvec = UVector(angles)
% UVECTOR computes a unit vector pointing in the [theta, phi] direction
% angles are in degrees
    ang = angles * pi / 180;
    st = sin(ang(1));
    ct = cos(ang(1));
    sp = sin(ang(2));
    cp = cos(ang(2));
    uvec = [st * cp, st * sp, ct];
end