%% THIS VERSION IS DEPRECATED IN FAVOR OF A GENERAL EXTRACT SCRIPT
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
%   onOff:                  structure containing the following
%     onEventsTime          - array of UTC timestamps for on events
%     offEventsTime         - array of UTC timestamps for off events
%
%   halfWindowInS           number of seconds surrounding an event to be
%                           extracted as features
%
%   varargin                0 or 1 to indicate whether or not to subtract
%                           the baseline from the current feature
%
% Outputs:
%   energyFeats:            structure containing the following
%     onFeats               - MxD matrix for M on events and D datapoints
%                             per feature
%     offFeats              - PxD matrix for P off events and D datapoints
%                             per feature
%     onEventsTime          - onOff.onEventsTime
%     offEventsTime         - onOff.offEventsTime

function energyFeats = extractRawEnergyFeatures_old(ds,onOff,halfWindowInS,varargin)

if isempty(varargin)
  zeroMin = 0;
else
  zeroMin = varargin{1};
end

timeInterval = ds.timeStamps(2)-ds.timeStamps(1); % UTC

utcWindow = (2*halfWindowInS + 1)/86400;

windowLength = roundodd(utcWindow/timeInterval);
halfWindowLength = round(halfWindowInS/86400/timeInterval);

onEvents = zeros(size(onOff.onEventsTime,1),windowLength);
offEvents = zeros(size(onOff.offEventsTime,1),windowLength);

onTimes = onOff.onEventsTime;
offTimes = onOff.offEventsTime;

%% On features.
%%%%%%%%%%%%%%%
removeFeature = zeros(size(onOff.onEventsTime,1),1);
if ~zeroMin
  for onInc = 1:size(onOff.onEventsTime,1)
    try
      midPoint = find(ds.timeStamps == onOff.onEventsTime(onInc));
      onEvents(onInc,:) = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(onInc) = 1;
    end
  end
else
  % subtract the minimum from the window
  for onInc = 1:size(onOff.onEventsTime,1)
    try
      midPoint = find(ds.timeStamps == onOff.onEventsTime(onInc));
      currentFeature = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
      onEvents(onInc,:) = currentFeature - min(currentFeature);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(onInc) = 1;
    end
  end
end

% Remove the zeros from the times and the features.
onEvents = onEvents(~removeFeature,:);
onTimes = onTimes(~removeFeature,:);








%% Off features
%%%%%%%%%%%%%%%
removeFeature = zeros(size(onOff.offEventsTime,1),1);
if ~zeroMin
  for offInc = 1:size(onOff.offEventsTime,1)
    try
      midPoint = find(ds.timeStamps == onOff.offEventsTime(offInc));
      offEvents(offInc,:) = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(offInc) = 1;
    end
  end
else
  % Subtract the minimum from the window.
  for offInc = 1:size(onOff.offEventsTime,1)
    try
      midPoint = find(ds.timeStamps == onOff.offEventsTime(offInc));
      currentFeature = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength);
      offEvents(offInc,:) = currentFeature - min(currentFeature);
    catch
      %% There weren't enough datapoints on one side to make this a feature,
      % so just keep moving
      removeFeature(offInc) = 1;
    end
  end
end
% Remove the zeros from the times and the features.
offEvents = offEvents(~removeFeature,:);
offTimes = offTimes(~removeFeature);

%% Set the output structure.
energyFeats.onFeats             = onEvents;
energyFeats.offFeats            = offEvents;
energyFeats.onEventsTime        = onTimes;
energyFeats.offEventsTime       = offTimes;


end

function S = roundodd(S)
% This local function rounds the input to nearest odd integer.
idx = mod(S,2)<1;
S = floor(S);
S(idx) = S(idx)+1;
end

