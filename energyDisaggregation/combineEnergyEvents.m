%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 4 February 2015
%
% combineEnergyEvents.m
% The purpose of this function is to combine energyEvents into one object.
% combinedEvents = combineEnergyEvents(eventTimes,varargin)
% varargin options: devices,onlyUnique

function combinedEvents = combineEnergyEvents(eventTimes,varargin)

[devices,onlyUnique,classNumber,className] = parseStuff(eventTimes,varargin);

combinedEvents = energyEventClass;

combinedEvents.className = className;
combinedEvents.classNumber = classNumber;
%% Leave confidences empty since we no longer are focusing on just one device
combinedEvents.confidences = eventTimes(1).confidences;
combinedEvents.house = eventTimes(1).house;
combinedEvents.houseNumber = eventTimes(1).houseNumber;
combinedEvents.keepLogicals = eventTimes(1).keepLogicals;
combinedEvents.timeStamps = eventTimes(1).timeStamps;

for dInc = 1:numel(devices)
    combinedEvents.offEvents = cat(1,combinedEvents.offEvents,eventTimes(devices(dInc)).offEvents);
    combinedEvents.offEventsIndex = cat(1,combinedEvents.offEventsIndex,eventTimes(devices(dInc)).offEventsIndex);
    combinedEvents.offEventsTimes = cat(1,combinedEvents.offEventsTimes,eventTimes(devices(dInc)).offEventsTimes);
    combinedEvents.offClass = cat(1,combinedEvents.offClass,eventTimes(devices(dInc)).offClass);
    
    combinedEvents.onEvents = cat(1,combinedEvents.onEvents,eventTimes(devices(dInc)).onEvents);
    combinedEvents.onEventsIndex = cat(1,combinedEvents.onEventsIndex,eventTimes(devices(dInc)).onEventsIndex);
    combinedEvents.onEventsTimes = cat(1,combinedEvents.onEventsTimes,eventTimes(devices(dInc)).onEventsTimes);
    combinedEvents.onClass = cat(1,combinedEvents.onClass,eventTimes(devices(dInc)).onClass);
end

%% Correct to ensure all unique times.
% On
if onlyUnique
    [~,uniqueOnIdx] = unique(combinedEvents.onEventsTimes);
    combinedEvents.onEventsTimes = combinedEvents.onEventsTimes(uniqueOnIdx);
    if ~isempty(combinedEvents.onEvents)
        combinedEvents.onEvents = combinedEvents.onEvents(uniqueOnIdx);
    end
    combinedEvents.onEventsIndex = combinedEvents.onEventsIndex(uniqueOnIdx);
    
    % Off
    [~,uniqueOffIdx] = unique(combinedEvents.offEventsTimes);
    combinedEvents.offEventsTimes = combinedEvents.offEventsTimes(uniqueOffIdx);
    combinedEvents.offEventsIndex = combinedEvents.offEventsIndex(uniqueOffIdx);
    if ~isempty(combinedEvents.offEvents)
        combinedEvents.offEvents = combinedEvents.offEvents(uniqueOffIdx);
    end
end

if isempty(combinedEvents.timeStamps)&&max(size(eventTimes))>1
    combinedEvents.timeStamps = eventTimes(2).timeStamps;
end

end

function [devices,onlyUnique,classNumber,className] = parseStuff(eventTimes,varIn)
numDevices = max(size(eventTimes));

options.onlyUnique = false;
options.devices = 1:numDevices;
options.classNumber = 0;
options.className = 'combinedEvents';

parsedOut = prtUtilSimpleInputParser(options,varIn(:));

devices = parsedOut.devices;
onlyUnique = parsedOut.onlyUnique;
classNumber = parsedOut.classNumber;
className = parsedOut.className;
end