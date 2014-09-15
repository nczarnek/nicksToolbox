% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 7 August 2014
%
% extractRawEnergyFeatures.m
% This function creates features out of the raw energy surrounding events.
%
% Inputs:
%   ds:                     structure containing the following
%     data                  - Nx1 data array
%     timeStamps            - timeStamps for the data
%
%   eventTimes              the times at which events occurred
%
%   halfWindowInS           number of seconds surrounding an event to be
%                           extracted as features
%
%   varargin                0 or 1 to indicate whether or not to subtract
%                           the baseline from the current feature
%
% Outputs:
%   energyFeats:            structure containing the following
%     energyFeatures        - MxD matrix for M events and D datapoints
%                             per feature
%
%     eventTimes            - eventTimes
%
%     removedEvents         - logical array of events that were too close 
%                             to the edges of the measurement

function energyFeats = extractRawEnergyFeatures(ds,eventTimes,halfWindowInS,varargin)

if isempty(varargin)
  zeroMin = 0;
else
  zeroMin = varargin{1};
end

timeInterval = ds.timeStamps(2)-ds.timeStamps(1); % UTC

utcWindow = (2*halfWindowInS + 1)/86400;

windowLength = roundodd(utcWindow/timeInterval);
halfWindowLength = round(halfWindowInS/86400/timeInterval);

eventFeatures = zeros(size(eventTimes,1),windowLength);

%% On features.
%%%%%%%%%%%%%%%
removeFeature = zeros(size(eventTimes,1),1);
if ~zeroMin
  for eventInc = 1:size(eventTimes,1)
    try
      midPoint = find(ds.timeStamps == eventTimes(eventInc));
      eventFeatures(eventInc,:) = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(eventInc) = 1;
    end
  end
else
  % subtract the minimum from the window
  for eventInc = 1:size(eventTimes,1)
    try
      midPoint = find(ds.timeStamps == eventTimes(eventInc));
      currentFeature = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
      eventFeatures(eventInc,:) = currentFeature - min(currentFeature);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(eventInc) = 1;
    end
  end
end

% Remove the zeros from the times and the features.
eventFeatures = eventFeatures(~removeFeature,:);
eventTimes = eventTimes(~removeFeature,:);

%% Set the output structure.
energyFeats.eventFeatures       = eventFeatures;
energyFeats.eventTimes          = eventTimes;
energyFeats.removedEvents       = removeFeature;

end

function S = roundodd(S)
% This local function rounds the input to nearest odd integer.
idx = mod(S,2)<1;
S = floor(S);
S(idx) = S(idx)+1;
end

