function sd = SolarState(the_date, the_hour, location)
% SOLARSTATE returns a struct holding info about the trajectory of the Sun on
% a specific calendar day
%   the_date is specified as a string: 'yyyy-mm-dd'
%   the_hour is the hours since local midnight
%   location is a tuple (latitude, longitude) in degrees. Claremont
%   is roughly at [34.103,-117.708]
%   We assume that we're in the America/Los_Angeles timezone and use
%   tzoffset to fine the offset from UTC.
%   Taken from the NOAA solar calculations spreadsheet
%
% OUTPUT: a struct with fields
%   t_transit = the local time at which the Sun is highest overhead
%   t_sunrise = hour of sunrise
%   t_sunset = hour of sunset
%   r_Earth = distance to Sun (in A.U.)
%   suns = 1 / r_Earth^2
%   sun_angles = [theta, phi] for Sun
%   uSun = [x, y, z] unit vector pointing to the Sun
% You can tell if the sun is up or not by if Z is positive or negative

sd.latitude = location(1);
sd.longitude = location(2);
sd.hours = the_hour;
refraction = 0;
sd.tzshift = hours(tzoffset(datetime(the_date, ...
    'TimeZone', 'America/Los_Angeles')));
% get the datetime utc
td = datetime(the_date);
the_day = datetime(year(td), month(td), day(td));
sd.day = the_day;
julian_day = juliandate(the_day);
julian_day = julian_day + the_hour / 24 - sd.tzshift / 24;
julian_century = (julian_day - 2451545) / 36525;
jc = julian_century;
geom_mean_long_sun = mod(280.46646 + jc * (36000.76983 + ...
    jc * 0.0003032), 360);
gmls = deg2rad(geom_mean_long_sun);
geom_mean_anom_sun = 357.52911 + jc * (35999.05029 - ...
    0.0001537 * jc);
gmas = deg2rad(geom_mean_anom_sun);
earth_eccent = 0.016708634 - jc * (0.000042037 + 0.0000001267 * jc);
sun_eq_of_center = sin(gmas) * (1.914602 - jc * (0.004817 + ...
    0.000014 * jc)) + sin(2 * gmas) * (0.019993 - 0.000101 * jc) + ...
    sin(3 * gmas) * 0.000289;
sun_true_long = geom_mean_long_sun + sun_eq_of_center;
sun_true_anom = geom_mean_anom_sun + sun_eq_of_center;
sun_radius = (1.000001018 * (1 - earth_eccent * earth_eccent)) / ...
    (1 + earth_eccent * cos(deg2rad(sun_true_anom))); % in A.U.
sun_app_long = sun_true_long - 0.00569 - 0.00478 * ...
    sin(deg2rad(125.04 - 1934.136 * jc));
salr = deg2rad(sun_app_long);
mean_obliq_ecliptic = 23 + (26 + ((21.448 - jc * (46.815 + ...
    jc * (0.00059 - jc * 0.001813))))/60)/60;
obliq_corr = mean_obliq_ecliptic + 0.00256 * cos(deg2rad(...
    125.04 - 1934.136 * jc));
ocrad = deg2rad(obliq_corr);
sd.sun_right_ascension = rad2deg(atan2(cos(ocrad) * sin(salr),...
    cos(salr)));
sdrad = asin(sin(ocrad) * sin(deg2rad(sun_app_long)));
sd.sun_declination = rad2deg(sdrad);
var_y = tan(ocrad / 2)^2;
eq_of_time = 4 * rad2deg(var_y * sin(2 * deg2rad(geom_mean_long_sun)) ...
             - 2 * earth_eccent * sin(gmas) ...
             + 4 * earth_eccent * var_y * sin(gmas) * cos(2 * gmls) ...
             - 0.5 * var_y*var_y* sin(4 * gmls) ...
    - 1.25 * earth_eccent * earth_eccent * sin(2 * gmas));

% Now we need to worry about latitude
lat = deg2rad(sd.latitude);
HA_sunrise = rad2deg(acos(cos(deg2rad(90.833)) / (cos(lat) ...
             * cos(sdrad)) - tan(lat) * tan(sdrad)));
solar_noon = (720 - 4 * sd.longitude - eq_of_time + sd.tzshift * 60) / 1440;
sunrise_time = solar_noon - HA_sunrise * 4/1440;
sunset_time = solar_noon + HA_sunrise * 4/1440;
sd.sunlight = 8 * HA_sunrise;
true_solar_time = mod(the_hour * 60 + eq_of_time + ...
     4 * sd.longitude - 60 * sd.tzshift, 1440); % in minutes
hour_angle = true_solar_time / 4; % in degrees
if hour_angle < 0
    hour_angle = hour_angle + 180;
else
    hour_angle = hour_angle - 180;
end
szrad = acos(sin(lat) * sin(sdrad) +...
    cos(lat) * cos(sdrad) * cos(deg2rad(hour_angle)));
solar_zenith = rad2deg(szrad);
solar_azimuth = rad2deg(acos( ( (sin(lat) * cos(szrad))...
    - sin(sdrad)) / (cos(lat) * sin(szrad)) ) );

if hour_angle > 0
    solar_azimuth = mod(solar_azimuth + 180, 360);
else
    solar_azimuth = mod(540 - solar_azimuth, 360);
end
sd.azimuth = solar_azimuth;
sd.sun_angles = [solar_zenith, mod(90 - solar_azimuth,360)];
sd.uSun = UVector(sd.sun_angles);
sd.t_transit = solar_noon * 24; % in hours
sd.t_sunrise = sunrise_time * 24;
sd.t_sunset = sunset_time * 24;
sd.r_Earth = sun_radius;
sd.suns = 1 / sun_radius^2;
