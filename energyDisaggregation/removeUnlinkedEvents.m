%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 23 March 2015
%
% removeUnlinkedEvents.m
% The purpose of this file is to take in two energyEventClass objects and
% find the overlapping on and off times such that the overlaps can be later
% removed.  This function is a replacement for ignoreSpecificEvents.m.
%
% modifiedEvents = removeUnlinkedEvents(eEC1,eEC2)

function modifiedEvents = removeUnlinkedEvents(ignoredEvents,deviceEvents,varargin)

options.haloInS = 60;
parsedOuts = prtUtilSimpleInputParser(options,varargin);
haloInS = parsedOuts.haloInS;

%% Convert the haloInS into UTC time
haloInUTC = haloInS/86400;

%% Make new energyEventClass objects that represent the range of times for 
% each event
lowDevice = deviceEvents;
lowDevice.onEventsTimes = lowDevice.onEventsTimes - haloInUTC;
lowDevice.offEventsTimes = lowDevice.offEventsTimes - haloInUTC;

highDevice = deviceEvents;
highDevice.onEventsTimes = highDevice.onEventsTimes + haloInUTC;
highDevice.offEventsTimes = highDevice.offEventsTimes + haloInUTC;

%% Set up logical arrays for both on and off energyEventClass objects
keepOnIgnored = true(numel(ignoredEvents.onEventsTimes),1);
keepOffIgnored = true(numel(ignoredEvents.offEventsTimes),1);

%% Go through each of the ignored events to establish which to keep and 
% which to toss
% Modify on
for igInc = 1:numel(ignoredEvents.onEventsTimes)
    if any(ignoredEvents.onEventsTimes(igInc)>lowDevice.onEventsTimes & ...
            ignoredEvents.onEventsTimes(igInc)<highDevice.onEventsTimes)
        keepOnIgnored(igInc) = false;
    end
end

for igInc = 1:numel(deviceEvents.offEventsTimes)
    if any(ignoredEvents.offEventsTimes(igInc)>lowDevice.offEventsTimes & ...
            ignoredEvents.offEventsTimes(igInc)<highDevice.offEventsTimes)
        keepOffIgnored(igInc) = false;
    end
end

%% Make the modifiedEvents object
modifiedEvents = ignoredEvents;
modifiedEvents.onEvents = modifiedEvents.onEvents(keepOnIgnored);
modifiedEvents.onEventsIndex = modifiedEvents.onEventsIndex(keepOnIgnored);
modifiedEvents.onEventsTimes = modifiedEvents.onEventsTimes(keepOnIgnored);
modifiedEvents.onClass = modifiedEvents.onClass(keepOnIgnored);

modifiedEvents.offEvents = modifiedEvents.offEvents(keepOffIgnored);
modifiedEvents.offEventsTimes = modifiedEvents.offEventsTimes(keepOffIgnored);
modifiedEvents.offEventsIndex = modifiedEvents.offEventsIndex(keepOffIgnored);
modifiedEvents.offClass = modifiedEvents.offClass(keepOffIgnored);

end