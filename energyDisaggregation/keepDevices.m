%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 18 August 2014
%
% keepDevices.m
% The purpose of this function is to keep the devices listed for the
% energyDataSet and eventTimes inputs.  All of the devices not listed in
% the input list are summed together into an "other" category.
%
% "use" class containing aggregate load is not included in the sum of
% devices
%
% Inputs:
%   keepIdx:                - indices to the devices that you want to keep
%   energyDS:               - energyDataSet containing the raw data
%   eventTs:                - structure containing all of the labeled events
%
% Outputs
%   joinedDS:               - modified dataset with "other" category
%   joinedEvents:           - modified eventTimes structure with events for
%                             each type of device

function [joinedDS,joinedEvents] = keepDevices(keepIdx,energyDS,varargin)

if ~isempty(varargin)
  eventTs = varargin{1};
end

%% Dataset
keepIdx = keepIdx(:);

if ~any(keepIdx == 1)
  keepIdx = cat(1,1,keepIdx);
end

keepSubset = energyDS.retainFeatures(keepIdx);

keepLogicals = true(energyDS.nFeatures,1);

keepLogicals(keepIdx) = false;

otherDS = energyDS.retainFeatures(keepLogicals);

otherDS.data = sum(otherDS.data,2);

otherDS = otherDS.setFeatureNames({'other'});

featureInfo = struct('deviceName','other','unit','W','pecanClass',0);

otherDS = otherDS.setFeatureInfo(featureInfo);

joinedDS = keepSubset.catFeatures(otherDS);



%% We can join event times later if necessary, but for now, it makes more
% sense to just join the devices, then run detection.
% %% Event times
for featInc = 1:joinedDS.nFeatures - 1
  
  
  if isfield(eventTs,'onEvents')
    joinedEvents(featInc).onEvents = eventTs(keepIdx(featInc)).onEvents;
  end
  
  if isfield(eventTs,'offEvents')
    joinedEvents(featInc).offEvents = eventTs(keepIdx(featInc)).offEvents;
  end
  
  if isfield(eventTs,'onEventsIndex')
    joinedEvents(featInc).onEventsIndex = eventTs(keepIdx(featInc)).onEventsIndex;
  end
  
  if isfield(eventTs,'offEventsIndex')
    joinedEvents(featInc).offEventsIndex = eventTs(keepIdx(featInc)).offEventsIndex;
  end
  
  if isfield(eventTs,'onIdx')
    joinedEvents(featInc).onIdx = eventTs(keepIdx(featInc)).onIdx;
  end
  
  if isfield(eventTs,'offIdx')
    joinedEvents(featInc).offIdx= eventTs(keepIdx(featInc)).offIdx;
  end
  
  if isfield(eventTs,'onEventsTimes')
    joinedEvents(featInc).onEventsTimes = eventTs(keepIdx(featInc)).onEventsTimes;
  end
  
  if isfield(eventTs,'offEventsTimes')
    joinedEvents(featInc).offEventsTimes = eventTs(keepIdx(featInc)).offEventsTimes;
  end
  
  if isfield(eventTs,'confidences')
    joinedEvents(featInc).confidences = eventTs(keepIdx(featInc)).confidences;
  end
  
  if isfield(eventTs,'timeStamps')
    joinedEvents(featInc).timeStamps = eventTs(keepIdx(featInc)).timeStamps;
  end
  
  if isfield(eventTs,'classNumber')
    joinedEvents(featInc).classNumber = eventTs(keepIdx(featInc)).classNumber;
  end
  
  if isfield(eventTs,'className')
    joinedEvents(featInc).className = eventTs(keepIdx(featInc)).className;
  end
  
end
otherSubset = eventTs(keepLogicals);

featInc = featInc + 1;

if isfield(eventTs,'onEvents')
  joinedEvents(featInc).onEvents = [];
end

if isfield(eventTs,'offEvents')
  joinedEvents(featInc).offEvents = [];
end

if isfield(eventTs,'onEventsIndex')
  joinedEvents(featInc).onEventsIndex = [];
end

if isfield(eventTs,'offEventsIndex')
  joinedEvents(featInc).offEventsIndex = [];
end

if isfield(eventTs,'onIdx')
  joinedEvents(featInc).onIdx = [];
end

if isfield(eventTs,'offIdx')
  joinedEvents(featInc).offIdx = [];
end

if isfield(eventTs,'onEventsTimes')
  joinedEvents(featInc).onEventsTimes = [];
end

if isfield(eventTs,'offEventsTimes')
  joinedEvents(featInc).offEventsTimes = [];
end

if isfield(eventTs,'confidences')
  joinedEvents(featInc).confidences = [];
end

if isfield(eventTs,'timeStamps')
  joinedEvents(featInc).timeStamps = [];
end

if isfield(eventTs,'classNumber')
  joinedEvents(featInc).classNumber = [];
end

if isfield(eventTs,'className')
  joinedEvents(featInc).className = [];
end

for eventInc = 1:size(otherSubset,1)
  if isfield(eventTs,'onEvents')
    joinedEvents(featInc).onEvents = cat(1,joinedEvents(featInc).onEvents,otherSubset(eventInc).onEvents);
  end
  
  if isfield(eventTs,'offEvents')
    joinedEvents(featInc).offEvents = cat(1,joinedEvents(featInc).offEvents,otherSubset(eventInc).offEvents);
  end
  
  if isfield(eventTs,'onEventsIndex')
    joinedEvents(featInc).onEventsIndex = cat(1,joinedEvents(featInc).onEventsIndex,otherSubset(eventInc).onEventsIndex);
  end
  
  if isfield(eventTs,'offEventsIndex')
    joinedEvents(featInc).offEventsIndex = cat(1,joinedEvents(featInc).offEventsIndex,otherSubset(eventInc).offEventsIndex);
  end
  
  if isfield(eventTs,'onIdx')
    joinedEvents(featInc).onIdx = cat(1,joinedEvents(featInc).onIdx,otherSubset(eventInc).onIdx);
  end
  
  if isfield(eventTs,'offIdx')
    joinedEvents(featInc).offIdx = cat(1,joinedEvents(featInc).offIdx,otherSubset(eventInc).offIdx);
  end
  
  if isfield(eventTs,'onEventsTimes')
    joinedEvents(featInc).onEventsTimes = cat(1,joinedEvents(featInc).onEventsTimes,otherSubset(eventInc).onEventsTimes);
  end
  
  if isfield(eventTs,'offEventsTimes')
    joinedEvents(featInc).offEventsTimes = cat(1,joinedEvents(featInc).offEventsTimes,otherSubset(eventInc).offEventsTimes);
  end
  
  if isfield(eventTs,'confidences')
    joinedEvents(featInc).confidences = cat(1,joinedEvents(featInc).confidences,otherSubset(eventInc).confidences);
  end
  
  if isfield(eventTs,'timeStamps')
    joinedEvents(featInc).timeStamps = cat(1,joinedEvents(featInc).timeStamps,otherSubset(eventInc).timeStamps);
  end
  
  if isfield(eventTs,'classNumber')
    joinedEvents(featInc).classNumber = cat(1,joinedEvents(featInc).classNumber,otherSubset(eventInc).classNumber);
  end
  
  if isfield(eventTs,'className')
    joinedEvents(featInc).className = 'other';
  end
end
