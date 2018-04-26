% Generate Temperature vector at specific time
% date in format YYYY-MM-DD -- Currently not implemented
% time in military format (0 to 2400)
% TvectSize specifies output vector size
function [Tvect] = getTemperatures(date, time, TvectSize)

% Should concatenate date to get the correct .csv file, then read in the
% time and temp data columns from CIMIS
fileDate = strcat(date,'.csv');
fileName = fullfile('.','Temperatures',fileDate);
fid = fopen(fileName);
columnHeads = fgetl(fid);
fclose(fid);
commas = strfind(columnHeads,',');
hourcolumn = find(commas == (strfind(columnHeads, 'Hour')-1));
tempcolumn = find(commas == (strfind(columnHeads, 'Air Temp')-1));
fahrenheit = contains(columnHeads, '(F)');

CIMISTimeData = dlmread(fileName,',',[1,hourcolumn,24,hourcolumn]);
CIMISTempData = dlmread(fileName,',',[1,tempcolumn,24,tempcolumn]);

% File data to row 1x24 doubles
timeData = transpose(CIMISTimeData);
tempData = transpose(CIMISTempData);
if fahrenheit
    tempData = 5 * (tempData - 32) / 9;
end

% 1x24 doubles to piecewise polynomial
tempEq = spline(timeData,tempData);
theTemperature = ppval(tempEq, time);
% Turn piecewise polynomial into the temperature vector

Tvect = ones([1,TvectSize]) * theTemperature;
% Tvect = Tvect*ppval(tempEq,[time]);
