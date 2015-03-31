%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 25 January 2015
%
% scoreEventDetectionQuickly.m
% The purpose of this code is to quickly score event detection based on
% code that Kenny Morton helped me with.
% function outputStruct = scoreEventDetectionQuickly(detectedConfidences,...
%     trueTimes,haloInS,varargin)

function outputStruct = scoreEventDetectionQuickly(detectedConfidences,...
    trueTimes,haloInS,varargin)

% keyboard

%% Check to make sure that there are true events to score against.
if isempty(trueTimes.onEventsTimes)

    outputStruct.onFa = [];
    outputStruct.onPd = [];
    outputStruct.onFalseAlarmConfidences = [];
    outputStruct.onFalseAlarmTimes = [];
    outputStruct.onThresholds = [];
    
    outputStruct.offFa = [];
    outputStruct.offPd = [];
    outputStruct.offFalseAlarmConfidences = [];
    outputStruct.offFalseAlarmTimes = [];
    outputStruct.offThresholds = [];

    return
end

%% Parse varargin
[tRes,debugMode,ignoredAlarms,miniHalo,minThreshold,ignoreInner,onlyOn] = ...
    parseStuff(detectedConfidences,trueTimes,haloInS,varargin);

%%

utcHour = 1/24;
if ~isempty(detectedConfidences.keepLogicals)
    nHours = tRes*sum(detectedConfidences.keepLogicals)/utcHour;
else
    nHours = tRes*numel(detectedConfidences.confidences)/utcHour;
end
utcHalo = haloInS/86400;

[onAlarmInds, onAlarmConfs] = as.thresholdedConnectedRegionMax(detectedConfidences.confidences,minThreshold);
onAlarmTimes = detectedConfidences.timeStamps(onAlarmInds);

[offAlarmInds, offAlarmConfs] = as.thresholdedConnectedRegionMax(-detectedConfidences.confidences,minThreshold);%,threshold)
offAlarmTimes = detectedConfidences.timeStamps(offAlarmInds);

detectedEvents.onEventsTimes = onAlarmTimes;
detectedEvents.offEventsTimes = offAlarmTimes;

if ignoreInner
    detectedEvents = ignoreInnerEvents(trueTimes,detectedEvents,haloInS,tRes);
end

onAlarmT = detectedEvents.onEventsTimes;
offAlarmT = detectedEvents.offEventsTimes;

%% Adjust on/offAlarmInds and on/offAlarmConfs
[~,keepOn] = intersect(onAlarmTimes,onAlarmT);
[~,keepOff] = intersect(offAlarmTimes,offAlarmT);

onAlarmInds = onAlarmInds(keepOn);
onAlarmConfs = onAlarmConfs(keepOn);
onAlarmTimes = onAlarmTimes(keepOn);

offAlarmInds = offAlarmInds(keepOff);
offAlarmConfs = offAlarmConfs(keepOff);
offAlarmTimes = offAlarmTimes(keepOff);

truthTimes = [trueTimes.onEventsTimes;trueTimes.offEventsTimes];

cleanedOns = ignoreSpecificEvents(onAlarmTimes,ignoredAlarms,tRes,'haloInS',miniHalo,'truthTimes',truthTimes);
cleanedOffs = ignoreSpecificEvents(offAlarmTimes,ignoredAlarms,tRes,'haloInS',miniHalo,'truthTimes',truthTimes);

[~,onAlarmIdx] = intersect(onAlarmTimes,cleanedOns);

onAlarmTimes = cleanedOns;
onAlarmConfs = onAlarmConfs(onAlarmIdx);
onAlarmInds = onAlarmInds(onAlarmIdx);

[~,offAlarmIdx] = intersect(offAlarmTimes,cleanedOffs);
offAlarmTimes = cleanedOffs;
offAlarmConfs = offAlarmConfs(offAlarmIdx);
offAlarmInds = offAlarmInds(offAlarmIdx);


%% On events

nOnAlarms = size(onAlarmConfs,1);
nOnEvents = size(trueTimes.onEventsIndex,1);

alarmTruthPairingsOn = sparse(nOnAlarms,nOnEvents);

trueOn = trueTimes.onEventsTimes;
% Check with the halo
for alarmInc = 1:nOnAlarms
    for truthInc = 1:nOnEvents
        % If an event is detected within the halo of a true event, mark that
        % alarm as successful.
        if abs(onAlarmTimes(alarmInc) - trueOn(truthInc)) < utcHalo
            alarmTruthPairingsOn(alarmInc,truthInc) = 1;
        end
    end
end

if debugMode
    % Each row corresponds to an alarm, and each column corresponds to an
    % event.  If a row doesn't have a 1, we see a false alarm.  Similarly,
    % if a column doesn't have a 1, we have a missed event. 
    figure;
    imagesc(alarmTruthPairingsOn)
    xlabel('Ordered events')
    ylabel('Ordered alarms')
    try
        className = trueTimes.className{1};
    catch
        className = trueTimes.className;
    end
    
    title([className,' on alarms vs truth'],'interpreter','none')
end

% Find the false alarms and hits
isFalseOn = sum(alarmTruthPairingsOn,2)==0;
isHitOn = ~isFalseOn;

% Find the misses
isMissedOn = sum(alarmTruthPairingsOn,1)==0;
isDetectedOn = ~isMissedOn;

eventConfidences = nan(nOnEvents,1);
eventAlarmTimes = nan(nOnEvents,1);
for iEvent = 1:nOnEvents
%     tStart = tic;
    correspondingAlarms = find(alarmTruthPairingsOn(:,iEvent));
    % if there are multiple hits within a halo of an event then  take maximum confidence
    [maxConf, localmaxInd]= max(onAlarmConfs(correspondingAlarms));

    if ~isempty(maxConf)
        eventConfidences(iEvent) = maxConf;
        eventAlarmTimes(iEvent) = onAlarmTimes(correspondingAlarms(localmaxInd));
    end
%     tStop = toc(tStart);
%     fprintf(1,['Event ',num2str(iEvent),' of ',num2str(nOnEvents),': ',num2str(tStop),'s\n'])
end

falseAlarmConfidences = onAlarmConfs(isFalseOn);
falseAlarmTimes = onAlarmTimes(isFalseOn);


%% In the event of no false alarms, add on a dummy section so that prtScoreRocNfa
% doesn't error out.
if isempty(falseAlarmConfidences)
    falseAlarmConfidences = min(eventConfidences) - 1;
end
[ nfaOn, pdOn, onThresholds] = prtScoreRocNfa(prtDataSetClass(cat(1,falseAlarmConfidences,...
    eventConfidences),prtUtilY(length(falseAlarmConfidences),length(eventConfidences))));

if debugMode
    figure;
    plot(nfaOn/nHours,pdOn)
    xlabel('False alarms/hour')
    ylabel('Sensitivity')
    ylim([0 1])
    
    try
        className = trueTimes.className{1};
    catch
        className = trueTimes.className;
    end
    title(['On ROC for ',className],'interpreter','none')
end

outputStruct.onFa = nfaOn/nHours;
outputStruct.onPd = pdOn;
outputStruct.onFalseAlarmConfidences = falseAlarmConfidences;
outputStruct.onFalseAlarmTimes = falseAlarmTimes;
outputStruct.onThresholds = onThresholds;


















%% Off events
if isempty(trueTimes.offEventsTimes)
    return
end
if onlyOn
    return
end

nOffAlarms = size(offAlarmConfs,1);
nOffEvents = size(trueTimes.offEventsIndex,1);

alarmTruthPairingsOff = sparse(nOffAlarms,nOffEvents);

trueOff = trueTimes.offEventsTimes;
% Check with the halo
for alarmInc = 1:nOffAlarms
    for truthInc = 1:nOffEvents
        % If an event is detected within the halo of a true event, mark that
        % alarm as successful.
        if abs(offAlarmTimes(alarmInc) - trueOff(truthInc)) < utcHalo
            alarmTruthPairingsOff(alarmInc,truthInc) = 1;
        end
    end
end

if debugMode
    % Each row corresponds to an alarm, and each column corresponds to an
    % event.  If a row doesn't have a 1, we see a false alarm.  Similarly,
    % if a column doesn't have a 1, we have a missed event. 
    figure;
    imagesc(alarmTruthPairingsOff)
    xlabel('Ordered events')
    ylabel('Ordered alarms')
    try
        className = trueTimes.className{1};
    catch
        className = trueTimes.className;
    end
    title([className,' off alarms vs truth'],'interpreter','none')
end

% Find the false alarms and hits
isFalseOff = sum(alarmTruthPairingsOff,2)==0;
isHitOff = ~isFalseOff;

% Find the misses
isMissedOff = sum(alarmTruthPairingsOn,1)==0;
isDetectedOff = ~isMissedOff;

eventConfidences = nan(nOffEvents,1);
eventAlarmTimes = nan(nOffEvents,1);
for iEvent = 1:nOffEvents
    correspondingAlarms = find(alarmTruthPairingsOff(:,iEvent));
    % if there are multiple hits within a halo of an event then  take maximum confidence
    [maxConf, localmaxInd]= max(offAlarmConfs(correspondingAlarms));

    if ~isempty(maxConf)
        eventConfidences(iEvent) = maxConf;
        eventAlarmTimes(iEvent) = offAlarmTimes(correspondingAlarms(localmaxInd));
    end
end

falseAlarmConfidences = offAlarmConfs(isFalseOff);
falseAlarmTimes = offAlarmTimes(isFalseOff);

%% In the event of no false alarms, add on a dummy section so that prtScoreRocNfa
% doesn't error out.
if isempty(falseAlarmConfidences)
    falseAlarmConfidences = min(eventConfidences) - 1;
end
[ nfaOff, pdOff, offThresholds] = prtScoreRocNfa(prtDataSetClass(cat(1,falseAlarmConfidences,eventConfidences),prtUtilY(length(falseAlarmConfidences),length(eventConfidences))));

if debugMode
    figure
    plot(nfaOff/nHours,pdOff)
    xlabel('False alarms/hour')
    ylabel('Sensitivity')
    try
        className = trueTimes.className{1};
    catch
        className = trueTimes.className;
    end
    title(['Off ROC for ',className],'interpreter','none')
    ylim([0 1])
end

outputStruct.offFa = nfaOff/nHours;
outputStruct.offPd = pdOff;
outputStruct.offFalseAlarmConfidences = falseAlarmConfidences;
outputStruct.offFalseAlarmTimes = falseAlarmTimes;
outputStruct.offThresholds = offThresholds;


end





















%% Subfunctions
function [tRes,debugMode,ignoredAlarms,miniHalo,minThreshold,ignoreInner,onlyOn] = parseStuff(detectedConfidences,trueTimes,...
    haloInS,varIn)

    p = inputParser;
    defaultDebug = false;
    defaultignoredAlarms = [];
    defaultTRes = detectedConfidences.timeStamps(2) - detectedConfidences.timeStamps(1);
    defaultMiniHalo = 20;
    defaultMinThreshold = 0.01;
    defaultIgnoreInner = false;
    defaultOnlyOn = true;

    
    addRequired(p,'detectedConfidences',@isobject);
    addRequired(p,'trueTimes',@isobject);
    addRequired(p,'haloInS',@isnumeric);
    addOptional(p,'tRes',defaultTRes,@isnumeric);
    addOptional(p,'debugMode',defaultDebug,@islogical);
    addOptional(p,'ignoredAlarms',defaultignoredAlarms,@isnumeric);
    addOptional(p,'miniHalo',defaultMiniHalo,@isnumeric);
    addOptional(p,'minThreshold',defaultMinThreshold,@isnumeric);
    addOptional(p,'ignoreInner',defaultIgnoreInner,@islogical);
    addOptional(p,'onlyOn',defaultOnlyOn,@islogical);

    parse(p,detectedConfidences,trueTimes,haloInS,varIn{:});


    debugMode = p.Results.debugMode;
    ignoredAlarms = p.Results.ignoredAlarms(:);
    tRes = p.Results.tRes;
    miniHalo = p.Results.miniHalo;
    minThreshold = p.Results.minThreshold;
    ignoreInner = p.Results.ignoreInner;
    onlyOn = p.Results.onlyOn;
end