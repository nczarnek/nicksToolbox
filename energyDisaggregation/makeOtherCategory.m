%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 2 March 2015
%
% makeOtherCategory.m
% eventTimes = makeOtherCategory(eventTimes,classNumbers,varargin)
% The purpose of this function is to combine events into one
% energyEventClass based on the specified devices.

function eventTimes = makeOtherCategory(eventTimes,classNumbers,varargin)

%% Parse everything
% options.devices = 1:numel(eventTimes);
% parsedOut = prtUtilSimpleInputParser(options,varargin);
% devices = parsedOut.devices;

%% Determine which classes to combine.
eT = eventTimes;

eventIdx = zeros(numel(classNumbers),1);

for cInc = 1:numel(classNumbers)
    currentClass = classNumbers(cInc);
    
    eventIdx(cInc) = getEventClass(eventTimes,currentClass);
end


otherEvents = energyEventClass;
for eInc = 1:numel(eventIdx)
    otherEvents.offEventsIndex = cat(1,otherEvents.offEventsIndex,...
        eventTimes(eventIdx(eInc)).offEventsIndex);
    
    otherEvents.offEventsTimes = cat(1,otherEvents.offEventsTimes,...
        eventTimes(eventIdx(eInc)).offEventsTimes);
    
    otherEvents.onEventsIndex = cat(1,otherEvents.onEventsIndex,...
        eventTimes(eventIdx(eInc)).onEventsIndex);
    
    otherEvents.onEventsTimes = cat(1,otherEvents.onEventsTimes,...
        eventTimes(eventIdx(eInc)).onEventsTimes);
    
end

otherEvents.className = 'other';
otherEvents.classNumber = 1000;

%% Remove the other events from the eventTimes array, and append the new 
% combined events
keepEvents = true(numel(eventTimes),1);
keepEvents(eventIdx) = false;

eventTimes = eventTimes(keepEvents);

eventTimes = [eventTimes;otherEvents];

end

function classIdx = getEventClass(eventTimes,currentClass)
eventLogical = false(numel(eventTimes),1);
for eInc = 1:numel(eventTimes)
    if eventTimes(eInc).classNumber == currentClass
        eventLogical(eInc) = true;
    end
end

if sum(eventLogical) == 1
    classIdx = find(eventLogical);
else
    error('Multiple eventTimes have the same class\n');
end
end