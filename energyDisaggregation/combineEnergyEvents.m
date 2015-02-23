%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 4 February 2015
%
% combineEnergyEvents.m
% The purpose of this function is to combine energyEvents into one object.

function combinedEvents = combineEnergyEvents(eventTimes,varargin)

devices = parseStuff(eventTimes,varargin);

combinedEvents = energyEventClass;

combinedEvents.className = 'combinedEvents';
%% Leave confidences empty since we no longer are focusing on just one device
combinedEvents.confidences = [];
combinedEvents.house = eventTimes(1).house;
combinedEvents.houseNumber = eventTimes(1).houseNumber;
combinedEvents.keepLogicals = eventTimes(1).keepLogicals;

for dInc = 1:max(size(devices))
    combinedEvents.offEvents = cat(1,combinedEvents.offEvents,eventTimes(devices(dInc)).offEvents);
    combinedEvents.offEventsIndex = cat(1,combinedEvents.offEventsIndex,eventTimes(devices(dInc)).offEventsIndex);
    combinedEvents.offEventsTimes = cat(1,combinedEvents.offEventsTimes,eventTimes(devices(dInc)).offEventsTimes);
    
    combinedEvents.onEvents = cat(1,combinedEvents.onEvents,eventTimes(devices(dInc)).onEvents);
    combinedEvents.onEventsIndex = cat(1,combinedEvents.onEventsIndex,eventTimes(devices(dInc)).onEventsIndex);
    combinedEvents.onEventsTimes = cat(1,combinedEvents.onEventsTimes,eventTimes(devices(dInc)).onEventsTimes);
    
end

%% Correct to ensure all unique times.
% On
[~,uniqueOnIdx] = unique(combinedEvents.onEventsTimes);
combinedEvents.onEventsTimes = combinedEvents.onEventsTimes(uniqueOnIdx);
combinedEvents.onEvents = combinedEvents.onEvents(uniqueOnIdx);
combinedEvents.onEventsIndex = combinedEvents.onEventsIndex(uniqueOnIdx);

[~,uniqueOffIdx] = unique(combinedEvents.offEventsTimes);
combinedEvents.offEventsTimes = combinedEvents.offEventsTimes(uniqueOffIdx);
combinedEvents.offEventsIndex = combinedEvents.offEventsIndex(uniqueOffIdx);
combinedEvents.offEvents = combinedEvents.offEvents(uniqueOffIdx);


combinedEvents.timeStamps = eventTimes(1).timeStamps;

if isempty(combinedEvents.timeStamps)&&max(size(eventTimes))>1
    combinedEvents.timeStamps = eventTimes(2).timeStamps;
end

end

function devices = parseStuff(eventTimes,varIn)
    numDevices = max(size(eventTimes));

    options.eventTimes = eventTimes;
    options.devices = 2:numDevices;
    
    parsedOut = prtUtilSimpleInputParser(options,varIn(:));
    
    devices = parsedOut.devices;
end