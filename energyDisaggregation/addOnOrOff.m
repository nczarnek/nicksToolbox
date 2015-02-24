%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 23 February 2015
%
% The purpose of this function is to determine which events are on events and
% which are off events in the BLUED dataset.  This is based on the 3 times
% after the events and the three before the events.

function modSet = addOnOrOff(energyDataSet,varargin)

options.timeWindowInS = 5;
parsedOut = prtUtilSimpleInputParser(options,varargin);
timeWindowInS = parsedOut.timeWindowInS;

xT = energyDataSet.getTimesFromUTC('timeScale','s');
yT = energyDataSet.getTimesFromUTC('timeScale','days','zeroTimes',false);

nPoints = sum(xT<timeWindowInS);

nEvents = numel(energyDataSet.userData.eventIdx);

onEvents = false(nEvents,1);

eTimes = energyDataSet.userData.eventTimes;

eIdx = getEventIdx(yT,eTimes);

for eInc = 1:nEvents
    
    %% Check the times before and after the event.
    switch energyDataSet.userData.phase{eInc}
        case 'A'
            afterPoints = energyDataSet.data(eIdx(eInc)+1:eIdx(eInc)+nPoints,1);
            beforePoints = energyDataSet.data(eIdx(eInc)-nPoints:eIdx(eInc)-1,1);
            
        case 'B'
            afterPoints = energyDataSet.data(eIdx(eInc)+1:eIdx(eInc)+nPoints,2);
            beforePoints = energyDataSet.data(eIdx(eInc)-nPoints:eIdx(eInc)-1,2);
            
    end
    
    meanBefore = mean(beforePoints);
    meanAfter = mean(afterPoints);
    
    if meanAfter>meanBefore
        onEvents(eInc) = true;
    end
end

modSet = energyDataSet;
modSet.userData.onEvents = onEvents;

end