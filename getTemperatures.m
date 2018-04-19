% Generate Temperature vector at specific time
% date in format YYYY-MM-DD -- Currently not implemented
% time in military format (0 to 2400)
% TvectSize specifies output vector size
function [Tvect] = getTemperatures(date, time, TvectSize)

% Should concatenate date to get the correct .csv file, then read in the
% time and temp data columns from CIMIS
fileName = fullfile('.','Ambient Heating Data','2018-04-01.csv');
CIMISTimeData = dlmread(fileName,',',[1,4,24,4]);
CIMISTempData = dlmread(fileName,',',[1,14,24,14]);

% File data to row 1x24 doubles
timeData = transpose(CIMISTimeData);
tempData = transpose(CIMISTempData);

% 1x24 doubles to piecewise polynomial
tempEq = spline(timeData,tempData);

% Turn piecewise polynomial into the temperature vector
Tvect = ones([1,TvectSize]);
Tvect = Tvect*ppval(tempEq,[time]);