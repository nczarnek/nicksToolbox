%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 8 December 2013
%
% timeConverter
% The purpose of this function is to convert an input UTC time to human
% readable GMT time.
%
% Inputs:
%   timeIn        - vector of time values in UTC format
%
% Optional inputs:
%   hourOffset    - default = 0;
%                 - set to number of hours you want to shift the time by
%                 - useful if you want to see EST or the like rather than
%                   GMT
%
%   msCheck       - set to 1 if the UTC timestamp inputs were in ms form
%                 - default = 0;
%                 - if you happen to send in ms rather than seconds, this
%                   will scale by 1000
%
% Outputs:
%   timeOutStr    - time strings converted into human readable format
%
% Example usage:
% timeIn = [1381370429;1381370430];
% timeOut = timeConverter(timeIn)
%
% reference:
% http://stackoverflow.com/questions/12661862/converting-epoch-to-date-in-matlab

function timeOutStr = timeConverter(timeIn,hourOffset,msCheck)

%% Check inputs
if ~exist('hourOffset')
  hourOffset = 0;
end

if ~exist('msCheck')
  msCheck = false;
end

if ~exist('timeIn')
  error('Please send in a double array of UTC format times')
end

%% Establish the time reference
timeReference = datenum('1970', 'yyyy');

%% Set the matlab time to convert
if msCheck
  timeMatlab = timeReference + timeIn/ 8.64e7 + hourOffset/24;
else
  timeMatlab = timeReference + timeIn / 8.64e4 + hourOffset/24;
end

%% Calculate the time needed.
timeOutStr = datestr(timeMatlab, 'yyyymmdd HH:MM:SS.FFF');
