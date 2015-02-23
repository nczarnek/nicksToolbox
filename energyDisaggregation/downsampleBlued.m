%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 20 October 2014
%
% downsampleBlued.m
% This function downsamples data from the BLUED database and accounts for
% the userData appropriately.
% 
% Note that downsampling can yield equal event indices that correspond to
% different events.

function bluedDS = downsampleBlued(bluedDS,dsFactor)

retainedObs = [1:dsFactor:bluedDS.nObservations]';

bluedDS = bluedDS.retainObservations(retainedObs);

energyTimestamps = [bluedDS.observationInfo.times]';

%% Go through the userData, and find the events.
nEvents = max(size(bluedDS.userData.eventTimes));
for eventInc = 1:nEvents
  eventTime = bluedDS.userData.eventTimes(eventInc);
  
  %% Determine if the event is equal to any of the times.
  eventIdx = find(energyTimestamps == eventTime);
  
  if isempty(eventIdx)
    %% The event is between indices
    highIdx = find(energyTimestamps > eventTime,1);
    lowIdx = find(energyTimestamps < eventTime,1,'last');
    
    %% Which is the event closer to?
    if abs(energyTimestamps(highIdx) - eventTime)<abs(energyTimestamps(lowIdx) - eventTime)
      bluedDS.userData.eventIdx(eventInc) = highIdx;
    else
      bluedDS.userData.eventIdx(eventInc) = lowIdx;
    end
  else
    bluedDS.userData.eventIdx(eventInc) = eventIdx;
  end
end