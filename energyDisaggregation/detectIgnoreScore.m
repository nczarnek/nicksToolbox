%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 15 September 2014
%
% detectScoreIgnore.m
% The purpose of this function is to detect events within a timeseries
% 
%
% [rocParameters,detectedEvents] = detectIgnoreScore(fridgeSet,eventTimes(10),ds,'sobel');

function [rocParameters,detectedEvents] = detectIgnoreScore(energyDataSet,eventTimes,ds,haloInS,varargin)

keyboard

%% Run event detection.
detectedEvents = detectEnergyEvents(energyDataSet,ds,varargin{1});

%%
numOn = size(eventTimes.onEvents,1);
numOff = size(eventTimes.offEvents,1);

trueStarts = eventTimes.onEventsIndex;
trueStops = eventTimes.offEventsIndex;


%% Check to make sure that everything was sent in as pairs
if abs(numOn-numOff)>2
  error('The number of on and off pairs is inconsistent');
elseif abs(numOn-numOff)==1
  if eventTimes.onEventsIndex(1)>eventTimes.offEventsIndex(1)
    % the device was on to start with
    trueStarts = [1;trueStarts];
  elseif eventTimes.onEventsIndex(end)>eventTimes.offEventsIndex(end)
    % the device was on to end with
    trueStops = [trueStops;energyDataSet.nObservations];
  end
    
elseif abs(numOn-numOff)==2
  if eventTimes.onEventsIndex(1)>eventTimes.offEventsIndex(1) & eventTimes.onEventsIndex(end)>eventTimes.offEventsIndex(end)
    % the device was on to start and to end with
    trueStarts = [1;trueStarts];
    trueStops = [trueStops;energyDataSet.nObservations];
  end
end

%% Do a final check to make sure that everything is in pairs now.
if ~all(trueStops>trueStarts)
  error('You have multiple on times before an off or multiple offs before an on');
end

%% Zero out all confide